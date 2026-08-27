#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    char name[64];
    long position;
} Label;

#define MAX_LABELS 256
Label label_table[MAX_LABELS];
int label_count = 0;

typedef struct {
    char name[64];
    int index;
} Variable;

#define MAX_VARIABLES 256
Variable var_table[MAX_VARIABLES];
int var_count = 0;

void emit_elf64_header(FILE* output_file) {
    unsigned char elf_header[] = {
        0x7F, 0x45, 0x4C, 0x46, 0x02, 0x01, 0x01, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x02, 0x00, 0x3E, 0x00, 0x01, 0x00, 0x00, 0x00,
        0x78, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x38, 0x00,
        0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    };
    unsigned char prog_header[] = {
        0x01, 0x00, 0x00, 0x00, 0x05, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00
    };
    fwrite(elf_header, 1, 64, output_file);
    fwrite(prog_header, 1, 56, output_file);
}

void emit_program_prolog(FILE* output_file) {
    fputc(0x55, output_file);
    fputc(0x48, output_file);
    fputc(0x89, output_file);
    fputc(0xE5, output_file);
    fputc(0x48, output_file);
    fputc(0x81, output_file);
    fputc(0xEC, output_file);
    fputc(0x00, output_file); fputc(0x01, output_file); fputc(0x00, output_file); fputc(0x00, output_file);
}

void emit_program_epilog(FILE* output_file) {
    fputc(0x48, output_file); fputc(0xC7, output_file); fputc(0xC0, output_file);
    fputc(0x3C, output_file); fputc(0x00, output_file); fputc(0x00, output_file); fputc(0x00, output_file);
    fputc(0x48, output_file); fputc(0x31, output_file); fputc(0xFF, output_file);
    fputc(0x0F, output_file); fputc(0x05, output_file);
}

int get_or_register_variable(const char* name) {
    for (int i = 0; i < var_count; i++) {
        if (strcmp(var_table[i].name, name) == 0) return var_table[i].index;
    }
    if (var_count < MAX_VARIABLES) {
        strcpy(var_table[var_count].name, name);
        var_table[var_count].index = var_count;
        var_count++;
        return var_table[var_count - 1].index;
    }
    printf("Compiler Error: Variable limit exceeded\n");
    exit(1);
}

void emit_store_int(int variable_index, int value, FILE* output_file) {
    int offset = (variable_index + 1) * 8;
    fputc(0x48, output_file);
    fputc(0xC7, output_file);
    fputc(0x45, output_file);
    fputc((signed char)(-offset), output_file);
    fputc(value & 0xFF, output_file);
    fputc((value >> 8) & 0xFF, output_file);
    fputc((value >> 16) & 0xFF, output_file);
    fputc((value >> 24) & 0xFF, output_file);
}

void emit_load_variable(int variable_index, FILE* output_file) {
    int offset = (variable_index + 1) * 8;
    fputc(0x48, output_file);
    fputc(0x8B, output_file);
    fputc(0x45, output_file);
    fputc((signed char)(-offset), output_file);
}

void emit_store_rax_to_variable(int variable_index, FILE* output_file) {
    int offset = (variable_index + 1) * 8;
    fputc(0x48, output_file);
    fputc(0x89, output_file);
    fputc(0x45, output_file);
    fputc((signed char)(-offset), output_file);
}

void emit_add_int(int value, FILE* output_file) {
    fputc(0x48, output_file);
    fputc(0x05, output_file);
    fputc(value & 0xFF, output_file);
    fputc((value >> 8) & 0xFF, output_file);
    fputc((value >> 16) & 0xFF, output_file);
    fputc((value >> 24) & 0xFF, output_file);
}

void emit_sub_int(int value, FILE* output_file) {
    fputc(0x48, output_file);
    fputc(0x2D, output_file);
    fputc(value & 0xFF, output_file);
    fputc((value >> 8) & 0xFF, output_file);
    fputc((value >> 16) & 0xFF, output_file);
    fputc((value >> 24) & 0xFF, output_file);
}

void emit_cmp_rax_int(int value, FILE* output_file) {
    fputc(0x48, output_file);
    fputc(0x3D, output_file);
    fputc(value & 0xFF, output_file);
    fputc((value >> 8) & 0xFF, output_file);
    fputc((value >> 16) & 0xFF, output_file);
    fputc((value >> 24) & 0xFF, output_file);
}

void emit_cmp_rax_str(const char* str, FILE* output_file) {
    fputc(0x48, output_file);
    fputc(0xBB, output_file);
    long dummy_addr = 0;
    for (int i = 0; i < 8; i++) {
        fputc((dummy_addr >> (i * 8)) & 0xFF, output_file);
    }
}

long emit_jump_if_not_equal(FILE* output_file) {
    fputc(0x0F, output_file);
    fputc(0x85, output_file);
    long patch_pos = ftell(output_file);
    for (int i = 0; i < 4; i++) fputc(0x00, output_file);
    return patch_pos;
}

long emit_jump_always(FILE* output_file) {
    fputc(0xE9, output_file);
    long patch_pos = ftell(output_file);
    for (int i = 0; i < 4; i++) fputc(0x00, output_file);
    return patch_pos;
}

void patch_jump_distance(long patch_position, long target_position, FILE* output_file) {
    long current_pos = ftell(output_file);
    long relative_offset = target_position - (patch_position + 4);
    fseek(output_file, patch_position, SEEK_SET);
    fputc(relative_offset & 0xFF, output_file);
    fputc((relative_offset >> 8) & 0xFF, output_file);
    fputc((relative_offset >> 16) & 0xFF, output_file);
    fputc((relative_offset >> 24) & 0xFF, output_file);
    fseek(output_file, current_pos, SEEK_SET);
}

void emit_load_to_rsi(int variable_index, FILE* output_file) {
    int offset = (variable_index + 1) * 8;
    fputc(0x48, output_file);
    fputc(0x8B, output_file);
    fputc(0x75, output_file);
    fputc((signed char)(-offset), output_file);
}

void emit_pin_raw_int(int value, FILE* output_file) {
    fputc(0x48, output_file);
    fputc(0xC7, output_file);
    fputc(0xC7, output_file);
    fputc(value & 0xFF, output_file);
    fputc((value >> 8) & 0xFF, output_file);
    fputc((value >> 16) & 0xFF, output_file);
    fputc((value >> 24) & 0xFF, output_file);
}

void emit_pin_fmt(const char* format_str, FILE* output_file) {
    fputc(0x48, output_file);
    fputc(0xBF, output_file);
    long dummy_addr = 0;
    for (int i = 0; i < 8; i++) {
        fputc((dummy_addr >> (i * 8)) & 0xFF, output_file);
    }
}
