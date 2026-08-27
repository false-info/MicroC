#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

typedef struct {
    char name[256];
    long position;
} Label;

#define MAX_LABELS 256

Label label_table[MAX_LABELS];
int label_count = 0;

typedef struct {
    char name[256];
    int index;
} Variable;

#define MAX_VARIABLES 256

Variable var_table[MAX_VARIABLES];
int var_count = 0;
void emit_write_byte_syscall(
    int value,
    FILE* output_file
);

static void write_u32(
    FILE* output_file,
    uint32_t value
) {
    fputc(
        value & 0xFF,
        output_file
    );

    fputc(
        (value >> 8) & 0xFF,
        output_file
    );

    fputc(
        (value >> 16) & 0xFF,
        output_file
    );

    fputc(
        (value >> 24) & 0xFF,
        output_file
    );
}

static void write_u64(
    FILE* output_file,
    uint64_t value
) {
    for (int i = 0; i < 8; i++) {
        fputc(
            (value >> (i * 8)) & 0xFF,
            output_file
        );
    }
}

void emit_elf64_header(
    FILE* output_file
) {
    unsigned char header[64];

    memset(
        header,
        0,
        sizeof(header)
    );

    header[0] = 0x7F;
    header[1] = 'E';
    header[2] = 'L';
    header[3] = 'F';

    header[4] = 2;
    header[5] = 1;
    header[6] = 1;

    uint16_t type = 2;
    uint16_t machine = 0x3E;
    uint32_t version = 1;
    uint64_t entry = 0;
    uint64_t phoff = 64;
    uint16_t ehsize = 64;
    uint16_t phentsize = 56;
    uint16_t phnum = 1;

    memcpy(
        header + 16,
        &type,
        2
    );

    memcpy(
        header + 18,
        &machine,
        2
    );

    memcpy(
        header + 20,
        &version,
        4
    );

    memcpy(
        header + 24,
        &entry,
        8
    );

    memcpy(
        header + 32,
        &phoff,
        8
    );

    memcpy(
        header + 52,
        &ehsize,
        2
    );

    memcpy(
        header + 54,
        &phentsize,
        2
    );

    memcpy(
        header + 56,
        &phnum,
        2
    );

    fwrite(
        header,
        1,
        64,
        output_file
    );

    unsigned char program[56];

    memset(
        program,
        0,
        sizeof(program)
    );

    uint32_t p_type = 1;
    uint32_t p_flags = 7;

    uint64_t p_offset = 0;
    uint64_t p_vaddr = 0x400000;
    uint64_t p_paddr = 0x400000;
    uint64_t p_filesz = 0;
    uint64_t p_memsz = 0;
    uint64_t p_align = 0x1000;

    memcpy(
        program + 0,
        &p_type,
        4
    );

    memcpy(
        program + 4,
        &p_flags,
        4
    );

    memcpy(
        program + 8,
        &p_offset,
        8
    );

    memcpy(
        program + 16,
        &p_vaddr,
        8
    );

    memcpy(
        program + 24,
        &p_paddr,
        8
    );

    memcpy(
        program + 32,
        &p_filesz,
        8
    );

    memcpy(
        program + 40,
        &p_memsz,
        8
    );

    memcpy(
        program + 48,
        &p_align,
        8
    );

    fwrite(
        program,
        1,
        56,
        output_file
    );
}

void patch_elf_entry(
    FILE* output_file,
    long position
) {
    long current =
        ftell(output_file);

    uint64_t entry =
        0x400000ULL +
        (uint64_t)position;

    fseek(
        output_file,
        24,
        SEEK_SET
    );

    write_u64(
        output_file,
        entry
    );

    fseek(
        output_file,
        current,
        SEEK_SET
    );
}

void patch_elf_sizes(
    FILE* output_file
) {
    long current =
        ftell(output_file);

    if (current < 0)
        return;

    uint64_t size =
        (uint64_t)current;

    fseek(
        output_file,
        96,
        SEEK_SET
    );

    write_u64(
        output_file,
        size
    );

    write_u64(
        output_file,
        size
    );

    fseek(
        output_file,
        current,
        SEEK_SET
    );
}

void emit_program_prolog(
    FILE* output_file
) {
    fputc(
        0x55,
        output_file
    );

    fputc(
        0x48,
        output_file
    );

    fputc(
        0x89,
        output_file
    );

    fputc(
        0xE5,
        output_file
    );

    fputc(
        0x48,
        output_file
    );

    fputc(
        0x81,
        output_file
    );

    fputc(
        0xEC,
        output_file
    );

    write_u32(
        output_file,
        0x1000
    );
}

void emit_function_epilog(FILE* output_file) {
    fputc(0xC3, output_file);

    fputc(
        0xC9,
        output_file
    );

    fputc(
        0xC3,
        output_file
    );
}

void emit_program_epilog(
    FILE* output_file
) {
    fputc(
        0x48,
        output_file
    );

    fputc(
        0xC7,
        output_file
    );

    fputc(
        0xC0,
        output_file
    );

    write_u32(
        output_file,
        60
    );

    fputc(
        0x48,
        output_file
    );

    fputc(
        0x31,
        output_file
    );

    fputc(
        0xFF,
        output_file
    );

    fputc(
        0x0F,
        output_file
    );

    fputc(
        0x05,
        output_file
    );

    patch_elf_sizes(
        output_file
    );
}

int get_or_register_variable(
    const char* name
) {
    for (int i = 0;
         i < var_count;
         i++) {

        if (strcmp(
                var_table[i].name,
                name
            ) == 0) {

            return var_table[i].index;
        }
    }

    if (var_count >= MAX_VARIABLES) {
        printf(
            "Compiler Error: Variable limit exceeded\n"
        );

        exit(1);
    }

    strcpy(
        var_table[var_count].name,
        name
    );

    var_table[var_count].index =
        var_count;

    var_count++;

    return var_count - 1;
}

static void emit_stack_disp(
    FILE* output_file,
    int reg,
    int offset
) {
    if (offset <= 128) {
        fputc(
            0x45 | (reg << 3),
            output_file
        );

        fputc(
            (unsigned char)(-offset),
            output_file
        );

        return;
    }

    fputc(
        0x85 | (reg << 3),
        output_file
    );

    write_u32(
        output_file,
        (uint32_t)(-offset)
    );
}

void emit_store_int(
    int variable_index,
    int value,
    FILE* output_file
) {
    int offset =
        (variable_index + 1) * 8;

    fputc(
        0x48,
        output_file
    );

    fputc(
        0xC7,
        output_file
    );

    emit_stack_disp(
        output_file,
        0,
        offset
    );

    write_u32(
        output_file,
        (uint32_t)value
    );
}

void emit_load_variable(
    int variable_index,
    FILE* output_file
) {
    int offset =
        (variable_index + 1) * 8;

    fputc(
        0x48,
        output_file
    );

    fputc(
        0x8B,
        output_file
    );

    emit_stack_disp(
        output_file,
        0,
        offset
    );
}

void emit_store_rax_to_variable(
    int variable_index,
    FILE* output_file
) {
    int offset =
        (variable_index + 1) * 8;

    fputc(
        0x48,
        output_file
    );

    fputc(
        0x89,
        output_file
    );

    emit_stack_disp(
        output_file,
        0,
        offset
    );
}

void emit_add_int(
    int value,
    FILE* output_file
) {
    if (value >= -128 &&
        value <= 127) {

        fputc(0x48, output_file);
        fputc(0x83, output_file);
        fputc(0xC0, output_file);
        fputc(
            value & 0xFF,
            output_file
        );

        return;
    }

    fputc(0x48, output_file);
    fputc(0x05, output_file);

    write_u32(
        output_file,
        (uint32_t)value
    );
}

void emit_sub_int(
    int value,
    FILE* output_file
) {
    if (value >= -128 &&
        value <= 127) {

        fputc(0x48, output_file);
        fputc(0x83, output_file);
        fputc(0xE8, output_file);
        fputc(
            value & 0xFF,
            output_file
        );

        return;
    }

    fputc(0x48, output_file);
    fputc(0x2D, output_file);

    write_u32(
        output_file,
        (uint32_t)value
    );
}

void emit_cmp_rax_int(
    int value,
    FILE* output_file
) {
    if (value >= -128 &&
        value <= 127) {

        fputc(0x48, output_file);
        fputc(0x83, output_file);
        fputc(0xF8, output_file);
        fputc(
            value & 0xFF,
            output_file
        );

        return;
    }

    fputc(0x48, output_file);
    fputc(0x3D, output_file);

    write_u32(
        output_file,
        (uint32_t)value
    );
}

void emit_cmp_rax_str(
    const char* str,
    FILE* output_file
) {
    if (!str || !str[0]) {
        emit_cmp_rax_int(
            0,
            output_file
        );

        return;
    }

    emit_cmp_rax_int(
        (unsigned char)str[0],
        output_file
    );
}

long emit_jump_if_not_equal(
    FILE* output_file
) {
    fputc(0x0F, output_file);
    fputc(0x85, output_file);

    long position =
        ftell(output_file);

    write_u32(
        output_file,
        0
    );

    return position;
}

long emit_jump_always(
    FILE* output_file
) {
    fputc(
        0xE9,
        output_file
    );

    long position =
        ftell(output_file);

    write_u32(
        output_file,
        0
    );

    return position;
}

void patch_jump_distance(
    long patch_position,
    long target_position,
    FILE* output_file
) {
    long current =
        ftell(output_file);

    int32_t relative =
        (int32_t)(
            target_position -
            (patch_position + 4)
        );

    fseek(
        output_file,
        patch_position,
        SEEK_SET
    );

    write_u32(
        output_file,
        (uint32_t)relative
    );

    fseek(
        output_file,
        current,
        SEEK_SET
    );
}

long emit_call(
    FILE* output_file
) {
    fputc(
        0xE8,
        output_file
    );

    long position =
        ftell(output_file);

    write_u32(
        output_file,
        0
    );

    return position;
}

void patch_call(
    FILE* output_file,
    long patch_position,
    long target_position
) {
    long current =
        ftell(output_file);

    int32_t relative =
        (int32_t)(
            target_position -
            (patch_position + 4)
        );

    fseek(
        output_file,
        patch_position,
        SEEK_SET
    );

    write_u32(
        output_file,
        (uint32_t)relative
    );

    fseek(
        output_file,
        current,
        SEEK_SET
    );
}

void emit_load_to_rsi(
    int variable_index,
    FILE* output_file
) {
    int offset =
        (variable_index + 1) * 8;

    fputc(
        0x48,
        output_file
    );

    fputc(
        0x8B,
        output_file
    );

    emit_stack_disp(
        output_file,
        6,
        offset
    );
}

void emit_pin_raw_int(
    int value,
    FILE* output_file
) {
    emit_write_byte_syscall(
        value,
        output_file
    );
}

void emit_pin_fmt(
    const char* format_str,
    FILE* output_file
) {
    (void)format_str;

    fputc(
        0x90,
        output_file
    );
}

void emit_read_file_byte_syscall(
    FILE* output_file
) {
    fputc(0x48, output_file);
    fputc(0xC7, output_file);
    fputc(0xC0, output_file);

    write_u32(
        output_file,
        0
    );

    fputc(0x48, output_file);
    fputc(0x31, output_file);
    fputc(0xFF, output_file);

    fputc(0x48, output_file);
    fputc(0x8D, output_file);
    fputc(0x74, output_file);
    fputc(0x24, output_file);
    fputc(0xF8, output_file);

    fputc(0x48, output_file);
    fputc(0xC7, output_file);
    fputc(0xC2, output_file);

    write_u32(
        output_file,
        1
    );

    fputc(0x0F, output_file);
    fputc(0x05, output_file);

    fputc(0x48, output_file);
    fputc(0x0F, output_file);
    fputc(0xB6, output_file);
    fputc(0x44, output_file);
    fputc(0x24, output_file);
    fputc(0xF8, output_file);
}

void emit_write_byte_syscall(
    int value,
    FILE* output_file
) {
    fputc(0x48, output_file);
    fputc(0xC7, output_file);
    fputc(0xC0, output_file);

    write_u32(
        output_file,
        1
    );

    fputc(0x48, output_file);
    fputc(0xC7, output_file);
    fputc(0xC7, output_file);

    write_u32(
        output_file,
        1
    );

    fputc(0x48, output_file);
    fputc(0x83, output_file);
    fputc(0xEC, output_file);
    fputc(0x08, output_file);

    fputc(0xC6, output_file);
    fputc(0x04, output_file);
    fputc(0x24, output_file);
    fputc(
        value & 0xFF,
        output_file
    );

    fputc(0x48, output_file);
    fputc(0x89, output_file);
    fputc(0xE6, output_file);

    fputc(0x48, output_file);
    fputc(0xC7, output_file);
    fputc(0xC2, output_file);

    write_u32(
        output_file,
        1
    );

    fputc(0x0F, output_file);
    fputc(0x05, output_file);

    fputc(0x48, output_file);
    fputc(0x83, output_file);
    fputc(0xC4, output_file);
    fputc(0x08, output_file);
}
