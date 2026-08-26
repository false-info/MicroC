#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

extern char asm_storage[];

typedef struct {
    const char *name;
    unsigned char id;
} X86Register;

X86Register reg_table[] = {
    {"rax", 0}, {"rcx", 1}, {"rdx", 2}, {"rbx", 3},
    {"rsp", 4}, {"rbp", 5}, {"rsi", 6}, {"rdi", 7}
};
int reg_table_size = sizeof(reg_table) / sizeof(X86Register);

int get_register_id(const char *name) {
    for (int i = 0; i < reg_table_size; i++) {
        if (strcmp(name, reg_table[i].name) == 0) return reg_table[i].id;
    }
    return -1;
}

void generate_binary(const char *input_filename) {
    char output_filename[256];
    strncpy(output_filename, input_filename, sizeof(output_filename) - 1);
    output_filename[sizeof(output_filename) - 1] = '\0';
    char *dot = strrchr(output_filename, '.');
    if (dot != NULL) *dot = '\0';
    strcat(output_filename, ".bin");

    FILE *file = fopen(output_filename, "wb");
    if (file == NULL) {
        fprintf(stderr, "[Codegen Error]: Could not create binary file!\n");
        exit(1);
    }

    printf("[Codegen]: Generating raw machine code to '%s'...\n", output_filename);

    char *asm_copy = strdup(asm_storage);
    if (asm_copy == NULL) {
        fclose(file);
        return;
    }

    char *line = strtok(asm_copy, "\n");
    int bytes_written = 0;

    while (line != NULL) {
        while (*line == ' ' || *line == '\t') line++;

        if (*line == '\0' || *line == ';' || *line == '}' || *line == '{') {
            line = strtok(NULL, "\n");
            continue;
        }

        char cmd[32] = {0};
        char arg1[32] = {0};
        char arg2[32] = {0};

        int idx = 0;
        while (line[idx] != '\0' && !isspace((unsigned char)line[idx]) && idx < 31) {
            cmd[idx] = line[idx];
            idx++;
        }
        cmd[idx] = '\0';

        if (strcmp(cmd, "hlt") == 0) {
            fputc(0xF4, file);
            bytes_written++;
        }
        else if (strcmp(cmd, "pad_boot") == 0){
            while (bytes_written < 510) {
                fputc(0x00, file);
                bytes_written++;
            }
        }
        else if (strcmp(cmd, "sign_boot") == 0) {
            fputc(0x55, file);
            fputc(0xAA, file);
            bytes_written += 2;
        }
        else if (strcmp(cmd, "nop") == 0) {
            fputc(0x90, file);
            bytes_written++;
        }
        else if (strcmp(cmd, "cli") == 0) {
            fputc(0xFA, file);
            bytes_written++;
        }
        else if (strcmp(cmd, "ret") == 0) {
            fputc(0xC3, file);
            bytes_written++;
        }
        else if (strcmp(cmd, "mov") == 0) {
            int parsed = sscanf(line, "%*s %31[^,], %31s", arg1, arg2);
            
            if (parsed >= 2) {
                char *p1 = arg1; while(*p1 == ' ') p1++;
                char *p2 = arg2; while(*p2 == ' ') p2++;

                int reg1 = get_register_id(p1);
                if (reg1 != -1) {
                    int reg2 = get_register_id(p2);
                    if (reg2 != -1) {
                        fputc(0x48, file);
                        fputc(0x89, file);
                        fputc(0xC0 + (reg2 << 3) + reg1, file);
                        bytes_written += 3;
                    } else {
                        long long val = strtoll(p2, NULL, 0);
                        fputc(0x48, file);
                        fputc(0xB8 + reg1, file);
                        fwrite(&val, 1, 8, file);
                        bytes_written += 10;
                    }
                }
            }
        }
        else {
            printf("[Codegen Warning]: Skipping instruction: '%s'\n", cmd);
        }

        line = strtok(NULL, "\n");
    }

    free(asm_copy);
    fclose(file);
    printf("[Codegen]: Done! Wrote %d bytes to '%s'.\n", bytes_written, output_filename);
}
