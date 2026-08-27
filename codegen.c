#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#define MAX_VARIABLES 1024
#define MAX_STRINGS 512

typedef struct {
    char name[256];
    int index;
} Variable;

typedef struct {
    char text[256];
    long patch;
} StringItem;

Variable var_table[MAX_VARIABLES];
int var_count = 0;

static StringItem strings[MAX_STRINGS];
static int string_count = 0;

static void write_u32(
    FILE* out,
    uint32_t value
)
{
    fputc(value & 0xff, out);
    fputc((value >> 8) & 0xff, out);
    fputc((value >> 16) & 0xff, out);
    fputc((value >> 24) & 0xff, out);
}

static void write_u64(
    FILE* out,
    uint64_t value
)
{
    for (int i = 0;
         i < 8;
         i++)
        fputc(
            (value >> (i * 8)) & 0xff,
            out
        );
}

static long pos(
    FILE* out
)
{
    long value =
        ftell(out);

    if (value < 0) {
        fprintf(
            stderr,
            "Compiler Error: output position\n"
        );

        exit(1);
    }

    return value;
}

void emit_elf64_header(
    FILE* out
)
{
    unsigned char header[64];
    unsigned char program[56];

    memset(
        header,
        0,
        sizeof(header)
    );

    memset(
        program,
        0,
        sizeof(program)
    );

    header[0] = 0x7f;
    header[1] = 'E';
    header[2] = 'L';
    header[3] = 'F';
    header[4] = 2;
    header[5] = 1;
    header[6] = 1;

    uint16_t type = 2;
    uint16_t machine = 0x3e;
    uint32_t version = 1;
    uint64_t entry = 0;
    uint64_t phoff = 64;

    uint16_t ehsize = 64;
    uint16_t phentsize = 56;
    uint16_t phnum = 1;

    memcpy(header + 16, &type, 2);
    memcpy(header + 18, &machine, 2);
    memcpy(header + 20, &version, 4);
    memcpy(header + 24, &entry, 8);
    memcpy(header + 32, &phoff, 8);
    memcpy(header + 52, &ehsize, 2);
    memcpy(header + 54, &phentsize, 2);
    memcpy(header + 56, &phnum, 2);

    fwrite(
        header,
        1,
        64,
        out
    );

    uint32_t p_type = 1;
    uint32_t p_flags = 7;

    uint64_t p_offset = 0;
    uint64_t p_vaddr = 0x400000;
    uint64_t p_paddr = 0x400000;

    uint64_t p_filesz = 0;
    uint64_t p_memsz = 0;

    uint64_t p_align = 0x1000;

    memcpy(program + 0, &p_type, 4);
    memcpy(program + 4, &p_flags, 4);
    memcpy(program + 8, &p_offset, 8);
    memcpy(program + 16, &p_vaddr, 8);
    memcpy(program + 24, &p_paddr, 8);
    memcpy(program + 32, &p_filesz, 8);
    memcpy(program + 40, &p_memsz, 8);
    memcpy(program + 48, &p_align, 8);

    fwrite(
        program,
        1,
        56,
        out
    );
}

void patch_elf_entry(
    FILE* out,
    long position
)
{
    long current =
        pos(out);

    fseek(
        out,
        24,
        SEEK_SET
    );

    write_u64(
        out,
        0x400000ULL +
        (uint64_t)position
    );

    fseek(
        out,
        current,
        SEEK_SET
    );
}

void patch_elf_sizes(
    FILE* out
)
{
    long current =
        pos(out);

    fseek(
        out,
        96,
        SEEK_SET
    );

    write_u64(
        out,
        (uint64_t)current
    );

    write_u64(
        out,
        (uint64_t)current
    );

    fseek(
        out,
        current,
        SEEK_SET
    );
}

void emit_program_prolog(
    FILE* out
)
{
    fputc(
        0x55,
        out
    );

    fputc(0x48, out);
    fputc(0x89, out);
    fputc(0xe5, out);

    fputc(0x48, out);
    fputc(0x81, out);
    fputc(0xec, out);

    write_u32(
        out,
        0x4000
    );
}

void emit_function_epilog(
    FILE* out
)
{
    fputc(
        0xc9,
        out
    );

    fputc(
        0xc3,
        out
    );
}

void emit_main_exit(
    FILE* out
)
{
    fputc(0x48, out);
    fputc(0xc7, out);
    fputc(0xc0, out);

    write_u32(
        out,
        60
    );

    fputc(0x48, out);
    fputc(0x31, out);
    fputc(0xff, out);

    fputc(0x0f, out);
    fputc(0x05, out);
}

void emit_main_return(
    FILE* out
)
{
    fputc(0x48, out);
    fputc(0x89, out);
    fputc(0xc7, out);

    fputc(0x48, out);
    fputc(0xc7, out);
    fputc(0xc0, out);

    write_u32(
        out,
        60
    );

    fputc(0x0f, out);
    fputc(0x05, out);
}

int get_or_register_variable(
    const char* name
)
{
    for (int i = 0;
         i < var_count;
         i++) {

        if (!strcmp(
                var_table[i].name,
                name
            ))
            return
                var_table[i].index;
    }

    if (var_count >= MAX_VARIABLES)
        exit(1);

    size_t length =
        strlen(name);

    if (length >=
        sizeof(
            var_table[var_count].name
        ))
        length =
            sizeof(
                var_table[var_count].name
            ) - 1;

    memcpy(
        var_table[var_count].name,
        name,
        length
    );

    var_table[var_count].name[length] =
        '\0';

    var_table[var_count].index =
        var_count;

    return var_count++;
}

static void stack_store(
    int reg,
    int index,
    FILE* out
)
{
    int offset =
        (index + 1) * 8;

    fputc(
        0x48,
        out
    );

    fputc(
        0x89,
        out
    );

    if (offset <= 128) {
        fputc(
            0x45 | (reg << 3),
            out
        );

        fputc(
            (unsigned char)(-offset),
            out
        );
    }
    else {
        fputc(
            0x85 | (reg << 3),
            out
        );

        write_u32(
            out,
            (uint32_t)(-offset)
        );
    }
}

static void stack_load(
    int reg,
    int index,
    FILE* out
)
{
    int offset =
        (index + 1) * 8;

    fputc(
        0x48,
        out
    );

    fputc(
        0x8b,
        out
    );

    if (offset <= 128) {
        fputc(
            0x45 | (reg << 3),
            out
        );

        fputc(
            (unsigned char)(-offset),
            out
        );
    }
    else {
        fputc(
            0x85 | (reg << 3),
            out
        );

        write_u32(
            out,
            (uint32_t)(-offset)
        );
    }
}

void emit_store_arg_reg(
    int arg,
    int index,
    FILE* out
)
{
    int reg;

    if (arg == 0)
        reg = 7;
    else if (arg == 1)
        reg = 6;
    else if (arg == 2)
        reg = 2;
    else if (arg == 3)
        reg = 8;
    else if (arg == 4)
        reg = 9;
    else if (arg == 5)
        reg = 10;
    else
        exit(1);

    stack_store(
        reg,
        index,
        out
    );
}

void emit_load_imm(
    int64_t value,
    FILE* out
)
{
    if (value >= INT32_MIN &&
        value <= INT32_MAX) {

        fputc(0x48, out);
        fputc(0xc7, out);
        fputc(0xc0, out);

        write_u32(
            out,
            (uint32_t)(int32_t)value
        );

        return;
    }

    fputc(0x48, out);
    fputc(0xb8, out);

    write_u64(
        out,
        (uint64_t)value
    );
}

void emit_store_int(
    int index,
    int64_t value,
    FILE* out
)
{
    emit_load_imm(
        value,
        out
    );

    stack_store(
        0,
        index,
        out
    );
}

void emit_load_variable(
    int index,
    FILE* out
)
{
    stack_load(
        0,
        index,
        out
    );
}

void emit_store_rax_to_variable(
    int index,
    FILE* out
)
{
    stack_store(
        0,
        index,
        out
    );
}

void emit_push_rax(
    FILE* out
)
{
    fputc(
        0x50,
        out
    );
}

void emit_pop_reg(
    int reg,
    FILE* out
)
{
    if (reg == 0)
        fputc(0x58, out);
    else if (reg == 1)
        fputc(0x59, out);
    else if (reg == 2)
        fputc(0x5a, out);
    else if (reg == 6)
        fputc(0x5e, out);
    else if (reg == 7)
        fputc(0x5f, out);
    else if (reg == 8) {
        fputc(0x41, out);
        fputc(0x58, out);
    }
    else if (reg == 9) {
        fputc(0x41, out);
        fputc(0x59, out);
    }
    else if (reg == 10) {
        fputc(0x41, out);
        fputc(0x5a, out);
    }
    else
        exit(1);
}

void emit_binary_op(
    const char* op,
    FILE* out
)
{
    fputc(
        0x59,
        out
    );

    if (!strcmp(op, "+")) {
        fputc(0x48, out);
        fputc(0x01, out);
        fputc(0xc1, out);

        fputc(0x48, out);
        fputc(0x89, out);
        fputc(0xc8, out);

        return;
    }

    if (!strcmp(op, "-")) {
        fputc(0x48, out);
        fputc(0x29, out);
        fputc(0xc1, out);

        fputc(0x48, out);
        fputc(0x89, out);
        fputc(0xc8, out);

        return;
    }

    if (!strcmp(op, "*")) {
        fputc(0x48, out);
        fputc(0x0f, out);
        fputc(0xaf, out);
        fputc(0xc1, out);

        fputc(0x48, out);
        fputc(0x89, out);
        fputc(0xc8, out);

        return;
    }

    if (!strcmp(op, "/") ||
        !strcmp(op, "%")) {

        fputc(0x48, out);
        fputc(0x87, out);
        fputc(0xc8, out);

        fputc(0x48, out);
        fputc(0x99, out);

        fputc(0x48, out);
        fputc(0xf7, out);
        fputc(0xf9, out);

        if (!strcmp(op, "%")) {
            fputc(0x48, out);
            fputc(0x89, out);
            fputc(0xd0, out);
        }

        return;
    }

    if (!strcmp(op, "&")) {
        fputc(0x48, out);
        fputc(0x21, out);
        fputc(0xc1, out);

        fputc(0x48, out);
        fputc(0x89, out);
        fputc(0xc8, out);

        return;
    }

    if (!strcmp(op, "|")) {
        fputc(0x48, out);
        fputc(0x09, out);
        fputc(0xc1, out);

        fputc(0x48, out);
        fputc(0x89, out);
        fputc(0xc8, out);

        return;
    }

    if (!strcmp(op, "^")) {
        fputc(0x48, out);
        fputc(0x31, out);
        fputc(0xc1, out);

        fputc(0x48, out);
        fputc(0x89, out);
        fputc(0xc8, out);

        return;
    }

    if (!strcmp(op, "<<") ||
        !strcmp(op, ">>")) {

        fputc(0x48, out);
        fputc(0x89, out);
        fputc(0xc1, out);

        fputc(0x48, out);
        fputc(0x89, out);
        fputc(0xc8, out);

        return;
    }

    if (!strcmp(op, "==") ||
        !strcmp(op, "!=") ||
        !strcmp(op, "<") ||
        !strcmp(op, ">") ||
        !strcmp(op, "<=") ||
        !strcmp(op, ">=")) {

        unsigned char condition = 0x94;

        fputc(0x48, out);
        fputc(0x39, out);
        fputc(0xc1, out);

        if (!strcmp(op, "=="))
            condition = 0x94;
        else if (!strcmp(op, "!="))
            condition = 0x95;
        else if (!strcmp(op, "<"))
            condition = 0x9c;
        else if (!strcmp(op, ">"))
            condition = 0x9f;
        else if (!strcmp(op, "<="))
            condition = 0x9e;
        else
            condition = 0x9d;

        fputc(0x0f, out);
        fputc(condition, out);
        fputc(0x48, out);
        fputc(0x0f, out);
        fputc(0xb6, out);
        fputc(0xc0, out);

        return;
    }

    exit(1);
}

long emit_jump_if_zero(
    FILE* out
)
{
    fputc(0x48, out);
    fputc(0x85, out);
    fputc(0xc0, out);

    fputc(0x0f, out);
    fputc(0x84, out);

    long patch =
        pos(out);

    write_u32(
        out,
        0
    );

    return patch;
}

long emit_jump_always(
    FILE* out
)
{
    fputc(
        0xe9,
        out
    );

    long patch =
        pos(out);

    write_u32(
        out,
        0
    );

    return patch;
}

void patch_jump_distance(
    long patch,
    long target,
    FILE* out
)
{
    long current =
        pos(out);

    fseek(
        out,
        patch,
        SEEK_SET
    );

    write_u32(
        out,
        (uint32_t)(
            (int32_t)(
                target -
                (patch + 4)
            )
        )
    );

    fseek(
        out,
        current,
        SEEK_SET
    );
}

long emit_call(
    FILE* out
)
{
    fputc(
        0xe8,
        out
    );

    long patch =
        pos(out);

    write_u32(
        out,
        0
    );

    return patch;
}

void patch_call(
    FILE* out,
    long patch,
    long target
)
{
    patch_jump_distance(
        patch,
        target,
        out
    );
}

long emit_string_load(
    const char* text,
    int reg,
    FILE* out
)
{
    if (string_count >= MAX_STRINGS)
        exit(1);

    size_t length =
        strlen(text);

    if (length >=
        sizeof(
            strings[string_count].text
        ))
        exit(1);

    memcpy(
        strings[string_count].text,
        text,
        length
    );

    strings[string_count].text[length] =
        '\0';

    if (reg == 0) {
        fputc(0x48, out);
        fputc(0xb8, out);
    }
    else if (reg == 6) {
        fputc(0x48, out);
        fputc(0xbe, out);
    }
    else if (reg == 7) {
        fputc(0x48, out);
        fputc(0xbf, out);
    }
    else
        exit(1);

    long patch =
        pos(out);

    write_u64(
        out,
        0
    );

    strings[string_count].patch =
        patch;

    string_count++;

    return patch;
}

void emit_open_file(
    FILE* out
)
{
    fputc(0x48, out);
    fputc(0xc7, out);
    fputc(0xc0, out);
    write_u32(out, 2);

    fputc(0x48, out);
    fputc(0xc7, out);
    fputc(0xc6, out);
    write_u32(out, 2);

    fputc(0x48, out);
    fputc(0x31, out);
    fputc(0xd2, out);

    fputc(0x0f, out);
    fputc(0x05, out);
}

void emit_close_file(
    FILE* out
)
{
    fputc(0x48, out);
    fputc(0x89, out);
    fputc(0xc7, out);

    fputc(0x48, out);
    fputc(0xc7, out);
    fputc(0xc0, out);
    write_u32(out, 3);

    fputc(0x0f, out);
    fputc(0x05, out);
}

void emit_file_read8(
    FILE* out
)
{
    fputc(0x48, out);
    fputc(0x89, out);
    fputc(0xc7, out);

    fputc(0x48, out);
    fputc(0x83, out);
    fputc(0xec, out);
    fputc(8, out);

    fputc(0x48, out);
    fputc(0x89, out);
    fputc(0xe6, out);

    fputc(0x48, out);
    fputc(0xc7, out);
    fputc(0xc2, out);
    write_u32(out, 1);

    fputc(0x48, out);
    fputc(0xc7, out);
    fputc(0xc0, out);
    write_u32(out, 0);

    fputc(0x0f, out);
    fputc(0x05, out);

    fputc(0x48, out);
    fputc(0x0f, out);
    fputc(0xb6, out);
    fputc(0x04, out);
    fputc(0x24, out);

    fputc(0x48, out);
    fputc(0x83, out);
    fputc(0xc4, out);
    fputc(8, out);
}

void emit_file_write8(
    FILE* out
)
{
    fputc(0x48, out);
    fputc(0x89, out);
    fputc(0xc7, out);

    fputc(0x48, out);
    fputc(0x83, out);
    fputc(0xec, out);
    fputc(8, out);

    fputc(0x40, out);
    fputc(0x88, out);
    fputc(0x34, out);
    fputc(0x24, out);

    fputc(0x48, out);
    fputc(0x89, out);
    fputc(0xe6, out);

    fputc(0x48, out);
    fputc(0xc7, out);
    fputc(0xc2, out);
    write_u32(out, 1);

    fputc(0x48, out);
    fputc(0xc7, out);
    fputc(0xc0, out);
    write_u32(out, 1);

    fputc(0x0f, out);
    fputc(0x05, out);

    fputc(0x48, out);
    fputc(0x83, out);
    fputc(0xc4, out);
    fputc(8, out);
}

void emit_file_size(
    FILE* out
)
{
    fputc(0x48, out);
    fputc(0x89, out);
    fputc(0xc7, out);

    fputc(0x48, out);
    fputc(0xc7, out);
    fputc(0xc0, out);
    write_u32(out, 8);

    fputc(0x48, out);
    fputc(0x31, out);
    fputc(0xf6, out);

    fputc(0x48, out);
    fputc(0xc7, out);
    fputc(0xc2, out);
    write_u32(out, 0);

    fputc(0x0f, out);
    fputc(0x05, out);
}

void emit_file_seek(
    FILE* out
)
{
    fputc(0x48, out);
    fputc(0xc7, out);
    fputc(0xc0, out);
    write_u32(out, 8);

    fputc(0x48, out);
    fputc(0x31, out);
    fputc(0xd2, out);

    fputc(0x0f, out);
    fputc(0x05, out);
}

void emit_mem_read8(
    FILE* out
)
{
    fputc(0x48, out);
    fputc(0x0f, out);
    fputc(0xb6, out);
    fputc(0x00, out);
}

void emit_mem_write8(
    FILE* out
)
{
    fputc(0x40, out);
    fputc(0x88, out);
    fputc(0x30, out);
}

void emit_mem_read64(
    FILE* out
)
{
    fputc(0x48, out);
    fputc(0x8b, out);
    fputc(0x00, out);
}

void emit_mem_write64(
    FILE* out
)
{
    fputc(0x48, out);
    fputc(0x89, out);
    fputc(0x30, out);
}

void emit_alloc(
    FILE* out
)
{
    fputc(0x48, out);
    fputc(0x89, out);
    fputc(0xc2, out);

    fputc(0x48, out);
    fputc(0xc7, out);
    fputc(0xc0, out);
    write_u32(out, 9);

    fputc(0x48, out);
    fputc(0xc7, out);
    fputc(0xc7, out);
    write_u32(out, 0);

    fputc(0x48, out);
    fputc(0x31, out);
    fputc(0xf6, out);

    fputc(0x48, out);
    fputc(0x31, out);
    fputc(0xd2, out);

    fputc(0x0f, out);
    fputc(0x05, out);
}

void emit_free(
    FILE* out
)
{
    fputc(
        0x90,
        out
    );
}

void emit_strlen(
    FILE* out
)
{
    fputc(0x48, out);
    fputc(0x31, out);
    fputc(0xc0, out);

    fputc(0x48, out);
    fputc(0x89, out);
    fputc(0xf9, out);

    fputc(0x80, out);
    fputc(0x39, out);
    fputc(0x00, out);

    fputc(0x74, out);
    fputc(0x06, out);

    fputc(0x48, out);
    fputc(0xff, out);
    fputc(0xc0, out);

    fputc(0x48, out);
    fputc(0xff, out);
    fputc(0xc1, out);

    fputc(0xeb, out);
    fputc(0xf1, out);
}

void emit_strcmp(
    FILE* out
)
{
    fputc(0x48, out);
    fputc(0x89, out);
    fputc(0xf9, out);

    fputc(0x48, out);
    fputc(0x89, out);
    fputc(0xf2, out);

    long loop =
        pos(out);

    fputc(0x0f, out);
    fputc(0xb6, out);
    fputc(0x01, out);

    fputc(0x0f, out);
    fputc(0xb6, out);
    fputc(0x0a, out);

    fputc(0x48, out);
    fputc(0x38, out);
    fputc(0xd0, out);

    fputc(0x75, out);
    fputc(0x12, out);

    fputc(0x48, out);
    fputc(0x85, out);
    fputc(0xc0, out);

    fputc(0x74, out);
    fputc(0x10, out);

    fputc(0x48, out);
    fputc(0xff, out);
    fputc(0xc1, out);

    fputc(0x48, out);
    fputc(0xff, out);
    fputc(0xc2, out);

    fputc(0xeb, out);
    fputc((unsigned char)(
        loop -
        (pos(out) + 1)
    ), out);
}

void emit_strchr(
    FILE* out
)
{
    fputc(0x48, out);
    fputc(0x85, out);
    fputc(0xff, out);

    fputc(0x74, out);
    fputc(0x0e, out);

    fputc(0x48, out);
    fputc(0x0f, out);
    fputc(0xb6, out);
    fputc(0x07, out);

    fputc(0x48, out);
    fputc(0x39, out);
    fputc(0xf0, out);

    fputc(0x74, out);
    fputc(0x06, out);

    fputc(0x48, out);
    fputc(0xff, out);
    fputc(0xc7, out);

    fputc(0xeb, out);
    fputc(0xf0, out);
}

void emit_argc(
    FILE* out
)
{
    fputc(0x48, out);
    fputc(0x8b, out);
    fputc(0x45, out);
    fputc(0x10, out);
}

void emit_argv(
    FILE* out
)
{
    fputc(0x48, out);
    fputc(0x8b, out);
    fputc(0x45, out);
    fputc(0x18, out);
}

void emit8_value(
    int64_t value,
    FILE* out
)
{
    fputc(
        (unsigned char)value,
        out
    );
}

void emit16_value(
    int64_t value,
    FILE* out
)
{
    fputc(
        value & 0xff,
        out
    );

    fputc(
        (value >> 8) & 0xff,
        out
    );
}

void emit32_value(
    int64_t value,
    FILE* out
)
{
    write_u32(
        out,
        (uint32_t)value
    );
}

void emit64_value(
    int64_t value,
    FILE* out
)
{
    write_u64(
        out,
        (uint64_t)value
    );
}

void emit_patch8(
    int64_t address,
    int64_t value,
    FILE* out
)
{
    long current =
        pos(out);

    fseek(
        out,
        (long)address,
        SEEK_SET
    );

    fputc(
        (unsigned char)value,
        out
    );

    fseek(
        out,
        current,
        SEEK_SET
    );
}

void emit_patch32(
    int64_t address,
    int64_t value,
    FILE* out
)
{
    long current =
        pos(out);

    fseek(
        out,
        (long)address,
        SEEK_SET
    );

    write_u32(
        out,
        (uint32_t)value
    );

    fseek(
        out,
        current,
        SEEK_SET
    );
}

void emit_patch64(
    int64_t address,
    int64_t value,
    FILE* out
)
{
    long current =
        pos(out);

    fseek(
        out,
        (long)address,
        SEEK_SET
    );

    write_u64(
        out,
        (uint64_t)value
    );

    fseek(
        out,
        current,
        SEEK_SET
    );
}

void emit_pin_char(
    FILE* out
)
{
    fputc(0x48, out);
    fputc(0x83, out);
    fputc(0xec, out);
    fputc(8, out);

    fputc(0x40, out);
    fputc(0x88, out);
    fputc(0x34, out);
    fputc(0x24, out);

    fputc(0x48, out);
    fputc(0xc7, out);
    fputc(0xc7, out);
    write_u32(out, 1);

    fputc(0x48, out);
    fputc(0x89, out);
    fputc(0xe6, out);

    fputc(0x48, out);
    fputc(0xc7, out);
    fputc(0xc2, out);
    write_u32(out, 1);

    fputc(0x48, out);
    fputc(0xc7, out);
    fputc(0xc0, out);
    write_u32(out, 1);

    fputc(0x0f, out);
    fputc(0x05, out);

    fputc(0x48, out);
    fputc(0x83, out);
    fputc(0xc4, out);
    fputc(8, out);
}

void emit_pin_string(
    const char* text,
    FILE* out
)
{
    emit_string_load(
        text,
        6,
        out
    );

    fputc(0x48, out);
    fputc(0xc7, out);
    fputc(0xc7, out);
    write_u32(out, 1);

    fputc(0x48, out);
    fputc(0xc7, out);
    fputc(0xc2, out);

    write_u32(
        out,
        (uint32_t)strlen(text)
    );

    fputc(0x48, out);
    fputc(0xc7, out);
    fputc(0xc0, out);
    write_u32(out, 1);

    fputc(0x0f, out);
    fputc(0x05, out);
}

void emit_write_byte_syscall(
    int64_t value,
    FILE* out
)
{
    fputc(0x48, out);
    fputc(0x83, out);
    fputc(0xec, out);
    fputc(8, out);

    fputc(0xc6, out);
    fputc(0x04, out);
    fputc(0x24, out);
    fputc(
        (unsigned char)value,
        out
    );

    fputc(0x48, out);
    fputc(0xc7, out);
    fputc(0xc7, out);
    write_u32(out, 1);

    fputc(0x48, out);
    fputc(0x89, out);
    fputc(0xe6, out);

    fputc(0x48, out);
    fputc(0xc7, out);
    fputc(0xc2, out);
    write_u32(out, 1);

    fputc(0x48, out);
    fputc(0xc7, out);
    fputc(0xc0, out);
    write_u32(out, 1);

    fputc(0x0f, out);
    fputc(0x05, out);

    fputc(0x48, out);
    fputc(0x83, out);
    fputc(0xc4, out);
    fputc(8, out);
}

void emit_read_file_byte_syscall(
    FILE* out
)
{
    fputc(0x48, out);
    fputc(0x83, out);
    fputc(0xec, out);
    fputc(8, out);

    fputc(0x48, out);
    fputc(0x31, out);
    fputc(0xff, out);

    fputc(0x48, out);
    fputc(0x89, out);
    fputc(0xe6, out);

    fputc(0x48, out);
    fputc(0xc7, out);
    fputc(0xc2, out);
    write_u32(out, 1);

    fputc(0x48, out);
    fputc(0x31, out);
    fputc(0xc0, out);

    fputc(0x0f, out);
    fputc(0x05, out);

    fputc(0x48, out);
    fputc(0x0f, out);
    fputc(0xb6, out);
    fputc(0x04, out);
    fputc(0x24, out);

    fputc(0x48, out);
    fputc(0x83, out);
    fputc(0xc4, out);
    fputc(8, out);

    return;
}

void emit_program_epilog(
    FILE* out
)
{
    fputc(0x48, out);
    fputc(0xc7, out);
    fputc(0xc0, out);
    write_u32(out, 60);

    fputc(0x48, out);
    fputc(0x31, out);
    fputc(0xff, out);

    fputc(0x0f, out);
    fputc(0x05, out);

    long data =
        pos(out);

    for (int i = 0;
         i < string_count;
         i++) {

        long current =
            pos(out);

        fseek(
            out,
            strings[i].patch,
            SEEK_SET
        );

        write_u64(
            out,
            0x400000ULL +
            (uint64_t)data
        );

        fseek(
            out,
            current,
            SEEK_SET
        );

        fwrite(
            strings[i].text,
            1,
            strlen(
                strings[i].text
            ) + 1,
            out
        );

        data +=
            (long)(
                strlen(
                    strings[i].text
                ) + 1
            );
    }

    patch_elf_sizes(
        out
    );
}
