#include <stdio.h>
#include <stdlib.h>
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
    char text;
} Token;

extern Token next_token(FILE* input);
extern int is_valid_identifier(const char* text);
extern void emit_elf64_header(FILE* out);
extern void emit_program_prolog(FILE* out);
extern void emit_program_epilog(FILE* out);
extern int get_or_register_variable(const char* name);
extern void emit_store_int(int idx, int val, FILE* out);
extern void emit_load_variable(int idx, FILE* out);
extern void emit_store_rax_to_variable(int idx, FILE* out);
extern void emit_add_int(int val, FILE* out);
extern void emit_sub_int(int val, FILE* out);
extern void emit_cmp_rax_int(int val, FILE* out);
extern void emit_cmp_rax_str(const char* str, FILE* out);
extern long emit_jump_if_not_equal(FILE* out);
extern long emit_jump_always(FILE* out);
extern void patch_jump_distance(long patch_pos, long target_pos, FILE* out);
extern void emit_load_to_rsi(int idx, FILE* out);
extern void emit_pin_raw_int(int val, FILE* out);
extern void emit_pin_fmt(const char* fmt, FILE* out);

void parse_microc_program(FILE* input_file, FILE* output_file) {
    Token token;
    int in_asm_mode = 0;

    while ((token = next_token(input_file)).type != TOKEN_EOF) {
        
        if (strcmp(token.text, "head") == 0) {
            next_token(input_file);
            next_token(input_file);
            next_token(input_file);
            next_token(input_file);
            next_token(input_file);
            emit_elf64_header(output_file);
            continue;
        }

        if (strcmp(token.text, "(asmb)") == 0) {
            in_asm_mode = 1;
            continue;
        }
        if (strcmp(token.text, "(asme)") == 0) {
            in_asm_mode = 0;
            continue;
        }

        if (strcmp(token.text, "}") == 0 && !in_asm_mode) {
            break;
        }

        if (in_asm_mode) {
            if (strcmp(token.text, "cli") == 0) {
                fputc(0xFA, output_file);
            } else if (strcmp(token.text, "hlt") == 0) {
                fputc(0xF4, output_file);
            } else if (strcmp(token.text, "pad_boot") == 0) {
                long pos = ftell(output_file);
                while (pos < 510) {
                    fputc(0x00, output_file);
                    pos++;
                }
            } else if (strcmp(token.text, "sign_boot") == 0) {
                fputc(0x55, output_file);
                fputc(0xAA, output_file);
            }
        } 
        else {
            if (strcmp(token.text, "fn") == 0) {
                Token fn_name = next_token(input_file);
                next_token(input_file);
                next_token(input_file);
                next_token(input_file);
                emit_program_prolog(output_file);
            }
            else if (strcmp(token.text, "if") == 0) {
                next_token(input_file);
                Token left = next_token(input_file);
                next_token(input_file);
                Token right = next_token(input_file);
                next_token(input_file);
                next_token(input_file);
                
                if (strcmp(left.text, "current") == 0) {
                    if (right.type == TOKEN_STRING) {
                        emit_cmp_rax_str(right.text, output_file);
                    } else if (right.type == TOKEN_NUMBER) {
                        emit_cmp_rax_int(atoi(right.text), output_file);
                    }
                } else {
                    int idx = get_or_register_variable(left.text);
                    emit_load_variable(idx, output_file);
                    emit_cmp_rax_int(atoi(right.text), output_file);
                }
                
                long patch_pos = emit_jump_if_not_equal(output_file);
                
                parse_microc_program(input_file, output_file);
                
                long end_pos = ftell(output_file);
                patch_jump_distance(patch_pos, end_pos, output_file);
            }
            else if (strcmp(token.text, "while") == 0) {
                next_token(input_file);
                Token left = next_token(input_file);
                next_token(input_file);
                Token right = next_token(input_file);
                next_token(input_file);
                next_token(input_file);
                
                long loop_start = ftell(output_file);
                
                if (strcmp(left.text, "current") == 0) {
                    if (right.type == TOKEN_STRING) {
                        emit_cmp_rax_str(right.text, output_file);
                    } else if (right.type == TOKEN_NUMBER) {
                        emit_cmp_rax_int(atoi(right.text), output_file);
                    }
                } else {
                    int idx = get_or_register_variable(left.text);
                    emit_load_variable(idx, output_file);
                    emit_cmp_rax_int(atoi(right.text), output_file);
                }
                
                long patch_pos = emit_jump_if_not_equal(output_file);
                
                parse_microc_program(input_file, output_file);
                
                long jump_back_pos = emit_jump_always(output_file);
                patch_jump_distance(jump_back_pos, loop_start, output_file);
                
                long end_pos = ftell(output_file);
                patch_jump_distance(patch_pos, end_pos, output_file);
            }
            else if (strcmp(token.text, "pin") == 0) {
                next_token(input_file);
                Token format_tok = next_token(input_file);
                
                if (format_tok.type == TOKEN_NUMBER) {
                    emit_pin_raw_int(atoi(format_tok.text), output_file);
                    next_token(input_file);
                } 
                else if (format_tok.type == TOKEN_STRING) {
                    Token comma_or_close = next_token(input_file);
                    if (strcmp(comma_or_close.text, ",") == 0) {
                        Token arg_tok = next_token(input_file);
                        if (arg_tok.type == TOKEN_IDENTIFIER) {
                            int idx = get_or_register_variable(arg_tok.text);
                            emit_load_to_rsi(idx, output_file);
                        }
                        emit_pin_fmt(format_tok.text, output_file);
                        next_token(input_file);
                    } else {
                        emit_pin_fmt(format_tok.text, output_file);
                    }
                }
            }
            else if (strcmp(token.text, "i64") == 0) {
                Token var_name = next_token(input_file);
                next_token(input_file);
                Token val = next_token(input_file);
                
                int idx = get_or_register_variable(var_name.text);
                emit_store_int(idx, atoi(val.text), output_file);
            }
            else if (is_valid_identifier(token.text)) {
                char var_name;
                strcpy(var_name, token.text);
                Token op = next_token(input_file);
                
                if (strcmp(op.text, "=") == 0) {
                    Token val = next_token(input_file);
                    int idx = get_or_register_variable(var_name);
                    
                    Token next_op = next_token(input_file);
                    if (strcmp(next_op.text, "+") == 0) {
                        Token right_num = next_token(input_file);
                        emit_load_variable(idx, output_file);
                        emit_add_int(atoi(right_num.text), output_file);
                        emit_store_rax_to_variable(idx, output_file);
                    } else if (strcmp(next_op.text, "-") == 0) {
                        Token right_num = next_token(input_file);
                        emit_load_variable(idx, output_file);
                        emit_sub_int(atoi(right_num.text), output_file);
                        emit_store_rax_to_variable(idx, output_file);
                    } else {
                        emit_store_int(idx, atoi(val.text), output_file);
                    }
                }
            }
        }
    }
}
