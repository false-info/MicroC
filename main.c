#include <stdio.h>
#include <string.h>

typedef enum {
    TOKEN_KEYWORD,
    TOKEN_IDENTIFIER,
    TOKEN_NUMBER,
    TOKEN_STRING,
    TOKEN_SYMBOL,
    TOKEN_EOF
} TokenType;

typedef struct {
    TokenType type;
    char text[256];
} Token;

extern void parse_microc_program(FILE* input_file, FILE* output_file);
extern void emit_program_epilog(FILE* output_file);
extern void emit_elf64_header(FILE* output_file);

int main(int argc, char* argv[]) {
    if (argc < 2) {
        printf("Usage: %s <input_file.mc> [-o <output_file>]\n", argv[0]);
        return 1;
    }

    char* input_filename = argv[1];
    char* output_filename = "output.bin";

    for (int i = 2; i < argc; i++) {
        if (strcmp(argv[i], "-o") == 0 && i + 1 < argc) {
            output_filename = argv[i + 1];
            break;
        }
    }

    FILE* input_file = fopen(input_filename, "r");
    if (!input_file) {
        printf("Error: Could not open input file '%s'\n", input_filename);
        return 1;
    }

    FILE* output_file = fopen(output_filename, "wb");
    if (!output_file) {
        printf("Error: Could not create output file '%s'\n", output_filename);
        fclose(input_file);
        return 1;
    }

    int is_bin = 0;
    int len = strlen(output_filename);
    if (len >= 4 && strcmp(&output_filename[len - 4], ".bin") == 0) {
        is_bin = 1;
    }

    if (!is_bin) {
        emit_elf64_header(output_file);
    }

    parse_microc_program(input_file, output_file);

    if (!is_bin) {
        emit_program_epilog(output_file);
    }

    fclose(input_file);
    fclose(output_file);

    return 0;
}
