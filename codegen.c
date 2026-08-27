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
    fputc(0x48, output_file);
    fputc(0x89, output_file);
    fputc(0xEC, output_file);
    fputc(0x5D, output_file);
    fputc(0xC3, output_file);
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
