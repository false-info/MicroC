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
    char text[256];
} Token;

extern Token next_token(FILE* input);
extern int is_valid_identifier(const char* text);

extern void emit_program_prolog(FILE* out);
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
extern void emit_read_file_byte_syscall(FILE* out);
extern void emit_write_byte_syscall(int val, FILE* out);
extern long emit_call(FILE* out);
extern void patch_call(FILE* out, long patch_pos, long target_pos);
extern void patch_elf_entry(FILE* out, long position);
extern void emit_function_epilog(FILE* out);
extern void patch_elf_entry(FILE* out, long position);

#define MAX_FUNCTIONS 256
#define MAX_CALLS 1024

typedef struct {
    char name[256];
    long position;
} Function;

typedef struct {
    char name[256];
    long position;
} PendingCall;

static Function functions[MAX_FUNCTIONS];
static int function_count = 0;

static PendingCall pending_calls[MAX_CALLS];
static int pending_call_count = 0;

static Token lookahead;
static int has_lookahead = 0;

static long main_position = -1;

static void compiler_error(const char* text) {
    fprintf(
        stderr,
        "Compiler Error: %s\n",
        text
    );

    exit(1);
}

static Token take_token(FILE* input) {
    if (has_lookahead) {
        has_lookahead = 0;
        return lookahead;
    }

    return next_token(input);
}

static Token peek_token(FILE* input) {
    if (!has_lookahead) {
        lookahead = next_token(input);
        has_lookahead = 1;
    }

    return lookahead;
}

static void expect(
    FILE* input,
    const char* expected
) {
    Token token =
        take_token(input);

    if (strcmp(
            token.text,
            expected
        ) != 0) {

        compiler_error(
            "Unexpected token"
        );
    }
}

static int parse_number(Token token) {
    char* end = NULL;

    long value =
        strtol(
            token.text,
            &end,
            0
        );

    if (end == token.text ||
        *end != '\0') {

        compiler_error(
            "Invalid number"
        );
    }

    return (int)value;
}

static int find_function(
    const char* name
) {
    for (int i = 0;
         i < function_count;
         i++) {

        if (strcmp(
                functions[i].name,
                name
            ) == 0) {

            return i;
        }
    }

    return -1;
}

static void register_function(
    const char* name,
    long position
) {
    if (function_count >= MAX_FUNCTIONS)
        compiler_error(
            "Function limit exceeded"
        );

    if (find_function(name) >= 0)
        compiler_error(
            "Duplicate function"
        );

    strcpy(
        functions[function_count].name,
        name
    );

    functions[function_count].position =
        position;

    function_count++;
}

static void register_call(
    const char* name,
    long position
) {
    if (pending_call_count >= MAX_CALLS)
        compiler_error(
            "Call limit exceeded"
        );

    strcpy(
        pending_calls[pending_call_count].name,
        name
    );

    pending_calls[pending_call_count].position =
        position;

    pending_call_count++;
}

static void resolve_calls(FILE* output) {
    for (int i = 0;
         i < pending_call_count;
         i++) {

        int function =
            find_function(
                pending_calls[i].name
            );

        if (function < 0)
            compiler_error(
                "Unknown function"
            );

        patch_call(
            output,
            pending_calls[i].position,
            functions[function].position
        );
    }
}

static void parse_inline_asm(
    FILE* input,
    FILE* output
) {
    while (1) {
        Token token =
            take_token(input);

        if (token.type == TOKEN_EOF)
            compiler_error(
                "Unterminated asm block"
            );

        if (strcmp(
                token.text,
                "(asme)"
            ) == 0)
            return;

        if (strcmp(
                token.text,
                "{"
            ) == 0 ||
            strcmp(
                token.text,
                "}"
            ) == 0)
            continue;

        if (strcmp(token.text, "cli") == 0) {
            fputc(0xFA, output);
        }
        else if (strcmp(token.text, "sti") == 0) {
            fputc(0xFB, output);
        }
        else if (strcmp(token.text, "nop") == 0) {
            fputc(0x90, output);
        }
        else if (strcmp(token.text, "hlt") == 0) {
            fputc(0xF4, output);
        }
        else if (strcmp(token.text, "ret") == 0) {
            fputc(0xC3, output);
        }
        else if (strcmp(token.text, "syscall") == 0) {
            fputc(0x0F, output);
            fputc(0x05, output);
        }
        else if (strcmp(
                    token.text,
                    "pad_boot"
                ) == 0) {

            long position =
                ftell(output);

            if (position < 0 ||
                position > 510) {

                compiler_error(
                    "Invalid pad_boot position"
                );
            }

            while (position < 510) {
                fputc(0x00, output);
                position++;
            }
        }
        else if (strcmp(
                    token.text,
                    "sign_boot"
                ) == 0) {

            long position =
                ftell(output);

            if (position != 510)
                compiler_error(
                    "Invalid sign_boot position"
                );

            fputc(0x55, output);
            fputc(0xAA, output);
        }
        else {
            compiler_error(
                "Unsupported asm instruction"
            );
        }
    }
}

parse_block(
    input_file,
    output_file
);

if (strcmp(name.text, "main") != 0) {
    emit_function_epilog(
        output_file
    );
}

static void parse_assignment(
    FILE* input,
    FILE* output,
    const char* name
) {
    expect(input, "=");

    Token value =
        take_token(input);

    int index =
        get_or_register_variable(
            name
        );

    if (value.type == TOKEN_NUMBER) {
        Token op =
            peek_token(input);

        if (strcmp(op.text, "+") == 0 ||
            strcmp(op.text, "-") == 0) {

            take_token(input);

            Token right =
                take_token(input);

            if (right.type != TOKEN_NUMBER)
                compiler_error(
                    "Invalid arithmetic expression"
                );

            emit_load_variable(
                index,
                output
            );

            if (strcmp(op.text, "+") == 0) {
                emit_add_int(
                    parse_number(right),
                    output
                );
            }
            else {
                emit_sub_int(
                    parse_number(right),
                    output
                );
            }

            emit_store_rax_to_variable(
                index,
                output
            );

            return;
        }

        emit_store_int(
            index,
            parse_number(value),
            output
        );

        return;
    }

    if (value.type == TOKEN_IDENTIFIER &&
        strcmp(
            value.text,
            "read_file_byte"
        ) == 0) {

        expect(input, "(");
        expect(input, ")");

        emit_read_file_byte_syscall(
            output
        );

        emit_store_rax_to_variable(
            index,
            output
        );

        return;
    }

    compiler_error(
        "Invalid assignment"
    );
}

static void parse_if(
    FILE* input,
    FILE* output
) {
    expect(input, "(");

    Token left =
        take_token(input);

    Token op =
        take_token(input);

    Token right =
        take_token(input);

    expect(input, ")");

    if (strcmp(op.text, "==") != 0)
        compiler_error(
            "Unsupported if operator"
        );

    if (left.type != TOKEN_IDENTIFIER)
        compiler_error(
            "Invalid if expression"
        );

    int index =
        get_or_register_variable(
            left.text
        );

    emit_load_variable(
        index,
        output
    );

    if (right.type == TOKEN_NUMBER) {
        emit_cmp_rax_int(
            parse_number(right),
            output
        );
    }
    else if (right.type == TOKEN_STRING) {
        emit_cmp_rax_str(
            right.text,
            output
        );
    }
    else {
        compiler_error(
            "Invalid if value"
        );
    }

    long jump =
        emit_jump_if_not_equal(
            output
        );

    expect(input, "{");

    parse_block(
        input,
        output
    );

    patch_jump_distance(
        jump,
        ftell(output),
        output
    );
}

static void parse_while(
    FILE* input,
    FILE* output
) {
    long loop_start =
        ftell(output);

    expect(input, "(");

    Token left =
        take_token(input);

    Token op =
        take_token(input);

    Token right =
        take_token(input);

    expect(input, ")");

    if (strcmp(op.text, "==") != 0)
        compiler_error(
            "Unsupported while operator"
        );

    int index =
        get_or_register_variable(
            left.text
        );

    emit_load_variable(
        index,
        output
    );

    if (right.type == TOKEN_NUMBER) {
        emit_cmp_rax_int(
            parse_number(right),
            output
        );
    }
    else if (right.type == TOKEN_STRING) {
        emit_cmp_rax_str(
            right.text,
            output
        );
    }
    else {
        compiler_error(
            "Invalid while value"
        );
    }

    long exit_jump =
        emit_jump_if_not_equal(
            output
        );

    expect(input, "{");

    parse_block(
        input,
        output
    );

    long back_jump =
        emit_jump_always(
            output
        );

    patch_jump_distance(
        back_jump,
        loop_start,
        output
    );

    patch_jump_distance(
        exit_jump,
        ftell(output),
        output
    );
}

static void parse_pin(
    FILE* input,
    FILE* output
) {
    expect(input, "(");

    Token value =
        take_token(input);

    if (value.type == TOKEN_NUMBER) {
        expect(input, ")");

        emit_pin_raw_int(
            parse_number(value),
            output
        );

        return;
    }

    if (value.type == TOKEN_STRING) {
        Token comma =
            peek_token(input);

        if (strcmp(
                comma.text,
                ","
            ) == 0) {

            take_token(input);

            Token argument =
                take_token(input);

            if (argument.type != TOKEN_IDENTIFIER)
                compiler_error(
                    "Invalid pin argument"
                );

            int index =
                get_or_register_variable(
                    argument.text
                );

            emit_load_to_rsi(
                index,
                output
            );
        }

        expect(input, ")");

        emit_pin_fmt(
            value.text,
            output
        );

        return;
    }

    compiler_error(
        "Invalid pin argument"
    );
}

static void parse_call(
    FILE* input,
    FILE* output,
    const char* name
) {
    expect(input, "(");
    expect(input, ")");

    long patch =
        emit_call(output);

    register_call(
        name,
        patch
    );
}

static void parse_statement(
    FILE* input,
    FILE* output
) {
    Token token =
        take_token(input);

    if (token.type == TOKEN_EOF)
        return;

    if (strcmp(
            token.text,
            "(asmb)"
        ) == 0) {

        parse_inline_asm(
            input,
            output
        );

        return;
    }

    if (strcmp(
            token.text,
            "if"
        ) == 0) {

        parse_if(
            input,
            output
        );

        return;
    }

    if (strcmp(
            token.text,
            "while"
        ) == 0) {

        parse_while(
            input,
            output
        );

        return;
    }

    if (strcmp(
            token.text,
            "pin"
        ) == 0) {

        parse_pin(
            input,
            output
        );

        return;
    }

    if (strcmp(
            token.text,
            "write_byte"
        ) == 0) {

        expect(input, "(");

        Token value =
            take_token(input);

        expect(input, ")");

        if (value.type != TOKEN_NUMBER)
            compiler_error(
                "write_byte requires number"
            );

        emit_write_byte_syscall(
            parse_number(value),
            output
        );

        return;
    }

    if (strcmp(
            token.text,
            "i64"
        ) == 0) {

        Token name =
            take_token(input);

        if (!is_valid_identifier(
                name.text
            )) {

            compiler_error(
                "Invalid variable name"
            );
        }

        parse_assignment(
            input,
            output,
            name.text
        );

        return;
    }

    if (token.type == TOKEN_IDENTIFIER) {
        Token next =
            peek_token(input);

        if (strcmp(
                next.text,
                "("
            ) == 0) {

            parse_call(
                input,
                output,
                token.text
            );

            return;
        }

        if (strcmp(
                next.text,
                "="
            ) == 0) {

            parse_assignment(
                input,
                output,
                token.text
            );

            return;
        }
    }

    if (strcmp(
            token.text,
            "{"
        ) == 0) {

        parse_block(
            input,
            output
        );

        return;
    }

    if (strcmp(
            token.text,
            "}"
        ) == 0)
        return;

    compiler_error(
        "Unknown statement"
    );
}

static void parse_block(
    FILE* input,
    FILE* output
) {
    while (1) {
        Token token =
            peek_token(input);

        if (token.type == TOKEN_EOF)
            compiler_error(
                "Unexpected EOF"
            );

        if (strcmp(
                token.text,
                "}"
            ) == 0) {

            take_token(input);
            return;
        }

        parse_statement(
            input,
            output
        );
    }
}

void parse_microc_program(
    FILE* input,
    FILE* output
) {
    while (1) {
        Token token =
            take_token(input);

        if (token.type == TOKEN_EOF)
            return;

        if (strcmp(
                token.text,
                "head"
            ) == 0) {

            expect(input, "(");

            take_token(input);
            take_token(input);

            expect(input, ")");

            expect(input, "{");

            continue;
        }

        if (strcmp(
                token.text,
                "fn"
            ) == 0) {

            Token name =
                take_token(input);

            if (!is_valid_identifier(
                    name.text
                )) {

                compiler_error(
                    "Invalid function name"
                );
            }

            expect(input, "(");
            expect(input, ")");
            expect(input, "{");

            long position =
                ftell(output);

            register_function(
                name.text,
                position
            );

            if (strcmp(
                    name.text,
                    "main"
                ) == 0) {

                main_position =
                    position;

                emit_program_prolog(
                    output
                );
            }

            parse_block(
                input,
                output
            );

            continue;
        }

        if (strcmp(
                token.text,
                "(asmb)"
            ) == 0) {

            parse_inline_asm(
                input,
                output
            );

            continue;
        }

        if (strcmp(
                token.text,
                "}"
            ) == 0)
            return;

        has_lookahead = 1;
        lookahead = token;

        parse_statement(
            input,
            output
        );
    }
}

int parse_and_resolve(
    FILE* input,
    FILE* output
) {
    parse_microc_program(
        input,
        output
    );

    resolve_calls(
        output
    );

    if (main_position < 0)
        compiler_error(
            "Missing main function"
        );

    patch_elf_entry(
        output,
        main_position
    );

    return 0;
}
