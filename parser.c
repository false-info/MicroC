#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

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
extern void emit_debug_char(FILE* out);
extern void emit_program_prolog(FILE* out);
extern void emit_program_epilog(FILE* out);
extern void emit_function_epilog(FILE* out);
extern void emit_main_exit(FILE* out);
extern void emit_main_return(FILE* out);

extern int get_or_register_variable(const char* name);

extern void emit_load_imm(int64_t value, FILE* out);
extern void emit_store_int(int idx, int64_t value, FILE* out);
extern void emit_load_variable(int idx, FILE* out);
extern void emit_store_rax_to_variable(int idx, FILE* out);

extern void emit_push_rax(FILE* out);
extern void emit_pop_reg(int reg, FILE* out);

extern void emit_binary_op(
    const char* op,
    FILE* out
);
extern void emit_store_arg_reg(
    int arg,
    int index,
    FILE* out
);
extern long emit_jump_if_zero(FILE* out);
extern long emit_jump_always(FILE* out);

extern void patch_jump_distance(
    long patch,
    long target,
    FILE* out
);

extern long emit_call(FILE* out);

extern void patch_call(
    FILE* out,
    long patch,
    long target
);

extern void patch_elf_entry(
    FILE* out,
    long position
);

extern long emit_string_load(
    const char* text,
    int reg,
    FILE* out
);

extern void emit_open_file(FILE* out);
extern void emit_close_file(FILE* out);
extern void emit_file_read8(FILE* out);
extern void emit_file_write8(FILE* out);
extern void emit_file_size(FILE* out);
extern void emit_file_seek(FILE* out);

extern void emit_mem_read8(FILE* out);
extern void emit_mem_write8(FILE* out);
extern void emit_mem_read64(FILE* out);
extern void emit_mem_write64(FILE* out);

extern void emit_alloc(FILE* out);
extern void emit_free(FILE* out);

extern void emit_strlen(FILE* out);
extern void emit_strcmp(FILE* out);
extern void emit_strchr(FILE* out);

extern void emit_argc(FILE* out);
extern void emit_argv(FILE* out);

extern void emit8_value(
    int64_t value,
    FILE* out
);

extern void emit16_value(
    int64_t value,
    FILE* out
);

extern void emit32_value(
    int64_t value,
    FILE* out
);

extern void emit64_value(
    int64_t value,
    FILE* out
);

extern void emit_patch8(
    int64_t address,
    int64_t value,
    FILE* out
);

extern void emit_patch32(
    int64_t address,
    int64_t value,
    FILE* out
);

extern void emit_patch64(
    int64_t address,
    int64_t value,
    FILE* out
);

extern void emit_pin_char(FILE* out);
extern void emit_pin_string(
    const char* text,
    FILE* out
);

extern void emit_write_byte_syscall(
    int64_t value,
    FILE* out
);

extern void emit_read_file_byte_syscall(
    FILE* out
);

#define MAX_FUNCTIONS 256
#define MAX_CALLS 2048
#define MAX_PARAMS 16
#define MAX_ARGS 16

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

static int current_params[MAX_PARAMS];
static int current_param_count = 0;

static char current_function[256];
static int current_is_main = 0;

static Token lookahead;
static int has_lookahead = 0;

static long main_position = -1;

static void parse_block(
    FILE* input,
    FILE* output
);

static void parse_expression(
    FILE* input,
    FILE* output,
    int min_precedence
);

static void compiler_error(
    const char* text
)
{
    fprintf(
        stderr,
        "Compiler Error: %s\n",
        text
    );

    fprintf(
        stderr,
        "Kraschade vid token-text: '%s'\n",
        lookahead.text
    );

    exit(1);
}


static Token take_token(
    FILE* input
)
{
    if (has_lookahead) {
        has_lookahead = 0;
        printf("[DEBUG] Take token (from lookahead): '%s' (Type: %d)\n", lookahead.text, lookahead.type);
        return lookahead;
    }

    Token t = next_token(input);
    printf("[DEBUG] Read token (from lexer): '%s' (Type: %d)\n", t.text, t.type);
    return t;
}


static Token peek_token(
    FILE* input
)
{
    if (!has_lookahead) {
        lookahead =
            next_token(input);

        has_lookahead = 1;
    }

    return lookahead;
}

static void expect(
    FILE* input,
    const char* text
)
{
    Token token =
        take_token(input);

    if (strcmp(
            token.text,
            text
        ) != 0)
        compiler_error(
            "Unexpected token"
        );
}

static int64_t parse_number(
    Token token
)
{
    char* end = NULL;

    int64_t value =
        strtoll(
            token.text,
            &end,
            0
        );

    if (end == token.text ||
        *end != '\0')
        compiler_error(
            "Invalid number"
        );

    return value;
}

static int precedence(
    const char* op
)
{
    if (!strcmp(op, "==") ||
        !strcmp(op, "!=") ||
        !strcmp(op, "<") ||
        !strcmp(op, ">") ||
        !strcmp(op, "<=") ||
        !strcmp(op, ">="))
        return 1;

    if (!strcmp(op, "|"))
        return 2;

    if (!strcmp(op, "^"))
        return 3;

    if (!strcmp(op, "&"))
        return 4;

    if (!strcmp(op, "<<") ||
        !strcmp(op, ">>"))
        return 5;

    if (!strcmp(op, "+") ||
        !strcmp(op, "-"))
        return 6;

    if (!strcmp(op, "*") ||
        !strcmp(op, "/") ||
        !strcmp(op, "%"))
        return 7;

    return -1;
}

static int find_function(
    const char* name
)
{
    for (int i = 0;
         i < function_count;
         i++) {

        if (!strcmp(
                functions[i].name,
                name
            ))
            return i;
    }

    return -1;
}

static void register_function(
    const char* name,
    long position
)
{
    if (function_count >= MAX_FUNCTIONS)
        compiler_error(
            "Function limit exceeded"
        );

    if (find_function(name) >= 0)
        compiler_error(
            "Duplicate function"
        );

    size_t length =
        strlen(name);

    if (length >=
        sizeof(
            functions[function_count].name
        ))
        length =
            sizeof(
                functions[function_count].name
            ) - 1;

    memcpy(
        functions[function_count].name,
        name,
        length
    );

    functions[function_count].name[length] =
        '\0';

    functions[function_count].position =
        position;

    function_count++;
}

static void register_call(
    const char* name,
    long position
)
{
    if (pending_call_count >= MAX_CALLS)
        compiler_error(
            "Call limit exceeded"
        );

    size_t length =
        strlen(name);

    if (length >=
        sizeof(
            pending_calls[pending_call_count].name
        ))
        length =
            sizeof(
                pending_calls[pending_call_count].name
            ) - 1;

    memcpy(
        pending_calls[pending_call_count].name,
        name,
        length
    );

    pending_calls[pending_call_count].name[length] =
        '\0';

    pending_calls[pending_call_count].position =
        position;

    pending_call_count++;
}

static void resolve_calls(
    FILE* output
)
{
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

static int variable(
    const char* name
)
{
    char full[512];
    size_t function_length =
        strlen(current_function);
    size_t name_length =
        strlen(name);

    if (function_length != 0) {
        if (function_length + 2 + name_length >= sizeof(full))
            compiler_error(
                "Variable name too long"
            );

        memcpy(
            full,
            current_function,
            function_length
        );

        full[function_length] = ':';
        full[function_length + 1] = ':';

        memcpy(
            full + function_length + 2,
            name,
            name_length
        );

        full[
            function_length +
            2 +
            name_length
        ] = '\0';
    }
    else {
        if (name_length >= sizeof(full))
            compiler_error(
                "Variable name too long"
            );

        memcpy(
            full,
            name,
            name_length
        );

        full[name_length] = '\0';
    }

    return get_or_register_variable(
        full
    );
}

static void parse_call(
    FILE* input,
    FILE* output,
    const char* name
)
{
    expect(
        input,
        "("
    );

    if (!strcmp(name, "open")) {
        Token path =
            take_token(input);

        if (path.type != TOKEN_STRING)
            compiler_error(
                "open requires string"
            );

        expect(
            input,
            ")"
        );

        emit_string_load(
            path.text,
            7,
            output
        );

        emit_open_file(
            output
        );

        return;
    }

    if (!strcmp(name, "close")) {
        parse_expression(
            input,
            output,
            0
        );

        expect(
            input,
            ")"
        );

        emit_close_file(
            output
        );

        return;
    }
        if (!strcmp(name, "debug_char")) {
        parse_expression(input, output, 0);
        expect(input, ")");
        emit_debug_char(output);
        return;
    }

    if (!strcmp(name, "file_read8")) {
        parse_expression(
            input,
            output,
            0
        );

        expect(
            input,
            ")"
        );

        emit_file_read8(
            output
        );

        return;
    }

        if (!strcmp(name, "file_write8")) {
        parse_expression(input, output, 0);
        emit_push_rax(output);
        expect(input, ",");
        parse_expression(input, output, 0);
        emit_pop_reg(7, output);
        emit_file_write8(output);
        expect(input, ")");
        return;
    }

    if (!strcmp(name, "file_size")) {
        parse_expression(
            input,
            output,
            0
        );

        expect(
            input,
            ")"
        );

        emit_file_size(
            output
        );

        return;
    }

        if (!strcmp(name, "file_seek")) {
        parse_expression(input, output, 0);
        emit_push_rax(output);
        expect(input, ",");
        parse_expression(input, output, 0);
        emit_pop_reg(7, output);
        emit_file_seek(output);
        expect(input, ")");
        return;
	}

    if (!strcmp(name, "mem_read8")) {
        parse_expression(
            input,
            output,
            0
        );

        expect(
            input,
            ")"
        );

        emit_mem_read8(
            output
        );

        return;
    }

        if (!strcmp(name, "mem_write8")) {
        parse_expression(input, output, 0);
        emit_push_rax(output);
        expect(input, ",");
        parse_expression(input, output, 0);
        emit_pop_reg(7, output);
        expect(input, ")");
        emit_mem_write8(output);
        return;
    }

    if (!strcmp(name, "mem_read64")) {
        parse_expression(
            input,
            output,
            0
        );

        expect(
            input,
            ")"
        );

        emit_mem_read64(
            output
        );

        return;
    }

        if (!strcmp(name, "mem_write64")) {
        parse_expression(input, output, 0);
        emit_push_rax(output);
        expect(input, ",");
        parse_expression(input, output, 0);
        emit_pop_reg(7, output);
        expect(input, ")");
        emit_mem_write64(output);
        return;
    }

    if (!strcmp(name, "alloc")) {
        parse_expression(
            input,
            output,
            0
        );

        expect(
            input,
            ")"
        );

        emit_alloc(
            output
        );

        return;
    }

    if (!strcmp(name, "free")) {
        parse_expression(
            input,
            output,
            0
        );

        expect(
            input,
            ")"
        );

        emit_free(
            output
        );

        return;
    }

    if (!strcmp(name, "strlen")) {
        Token token =
            take_token(input);

        if (token.type == TOKEN_STRING) {
            emit_string_load(
                token.text,
                7,
                output
            );
        }
        else if (token.type == TOKEN_IDENTIFIER) {
            emit_load_variable(
                variable(token.text),
                output
            );

            fputc(
                0x48,
                output
            );

            fputc(
                0x89,
                output
            );

            fputc(
                0xC7,
                output
            );
        }
        else {
            compiler_error(
                "Invalid strlen argument"
            );
        }

        expect(
            input,
            ")"
        );

        emit_strlen(
            output
        );

        return;
    }

    if (!strcmp(name, "strcmp")) {
        Token left =
            take_token(input);

        if (left.type == TOKEN_STRING) {
            emit_string_load(
                left.text,
                7,
                output
            );
        }
        else if (left.type == TOKEN_IDENTIFIER) {
            emit_load_variable(
                variable(left.text),
                output
            );

            fputc(0x48, output);
            fputc(0x89, output);
            fputc(0xC7, output);
        }
        else {
            compiler_error(
                "Invalid strcmp argument"
            );
        }

        expect(
            input,
            ","
        );

        Token right =
            take_token(input);

        if (right.type == TOKEN_STRING) {
            emit_string_load(
                right.text,
                6,
                output
            );
        }
        else if (right.type == TOKEN_IDENTIFIER) {
            emit_load_variable(
                variable(right.text),
                output
            );

            fputc(0x48, output);
            fputc(0x89, output);
            fputc(0xC6, output);
        }
        else {
            compiler_error(
                "Invalid strcmp argument"
            );
        }

        expect(
            input,
            ")"
        );

        emit_strcmp(
            output
        );

        return;
    }

    if (!strcmp(name, "strchr")) {
        parse_expression(
            input,
            output,
            0
        );

        expect(
            input,
            ","
        );

        parse_expression(
            input,
            output,
            0
        );

        expect(
            input,
            ")"
        );

        emit_strchr(
            output
        );

        return;
    }

    if (!strcmp(name, "argc")) {
        expect(
            input,
            ")"
        );

        emit_argc(
            output
        );

        return;
    }

    if (!strcmp(name, "argv")) {
        parse_expression(
            input,
            output,
            0
        );

        expect(
            input,
            ")"
        );

        emit_argv(
            output
        );

        return;
    }

    if (!strcmp(name, "emit8") ||
        !strcmp(name, "emit16") ||
        !strcmp(name, "emit32") ||
        !strcmp(name, "emit64")) {

        parse_expression(
            input,
            output,
            0
        );

        emit_pop_reg(
            0,
            output
        );

        if (!strcmp(name, "emit8"))
            emit8_value(
                0,
                output
            );
        else if (!strcmp(name, "emit16"))
            emit16_value(
                0,
                output
            );
        else if (!strcmp(name, "emit32"))
            emit32_value(
                0,
                output
            );
        else
            emit64_value(
                0,
                output
            );

        expect(
            input,
            ")"
        );

        return;
    }

    if (!strcmp(name, "patch8") ||
        !strcmp(name, "patch32") ||
        !strcmp(name, "patch64")) {

        parse_expression(
            input,
            output,
            0
        );

        emit_push_rax(
            output
        );

        expect(
            input,
            ","
        );

        parse_expression(
            input,
            output,
            0
        );

        emit_pop_reg(
            7,
            output
        );

        if (!strcmp(name, "patch8"))
            emit_patch8(
                0,
                0,
                output
            );
        else if (!strcmp(name, "patch32"))
            emit_patch32(
                0,
                0,
                output
            );
        else
            emit_patch64(
                0,
                0,
                output
            );

        expect(
            input,
            ")"
        );

        return;
    }

    int argument_count = 0;

    while (1) {
        Token token =
            peek_token(input);

        if (!strcmp(
                token.text,
                ")"
            )) {

            take_token(input);
            break;
        }

        if (argument_count >= MAX_ARGS)
            compiler_error(
                "Too many arguments"
            );

        parse_expression(
            input,
            output,
            0
        );

        emit_push_rax(
            output
        );

        argument_count++;

        token =
            peek_token(input);

        if (!strcmp(
                token.text,
                ","
            )) {

            take_token(input);
            continue;
        }

        if (!strcmp(
                token.text,
                ")"
            )) {

            take_token(input);
            break;
        }

        compiler_error(
            "Expected ',' or ')'"
        );
    }

    for (int i = argument_count - 1;
         i >= 0;
         i--) {

        int reg =
            i == 0 ? 7 :
            i == 1 ? 6 :
            i == 2 ? 2 :
            i == 3 ? 8 :
            i == 4 ? 9 :
            10;

        emit_pop_reg(
            reg,
            output
        );
    }

    long patch =
        emit_call(
            output
        );

    register_call(
        name,
        patch
    );
}

static void parse_primary(
    FILE* input,
    FILE* output
)
{
    Token token =
        take_token(input);

    if (token.type == TOKEN_NUMBER) {
        emit_load_imm(
            parse_number(token),
            output
        );

        return;
    }

    if (token.type == TOKEN_IDENTIFIER) {
        Token next =
            peek_token(input);

        if (!strcmp(
                next.text,
                "("
            )) {

            parse_call(
                input,
                output,
                token.text
            );

            return;
        }

        emit_load_variable(
            variable(token.text),
            output
        );

        return;
    }

    if (token.type == TOKEN_STRING) {
        emit_string_load(
            token.text,
            0,
            output
        );

        return;
    }

    if (!strcmp(
            token.text,
            "("
        )) {

        parse_expression(
            input,
            output,
            0
        );

        expect(
            input,
            ")"
        );

        return;
    }

    fprintf(
        stderr,
        "Compiler Error: Invalid expression: %s\n",
        token.text
    );

    exit(1);
}

static void parse_expression(
    FILE* input,
    FILE* output,
    int min_precedence
)
{
    parse_primary(
        input,
        output
    );

    while (1) {
        Token token =
            peek_token(input);

        int current_precedence =
            precedence(
                token.text
            );

        if (current_precedence < 0 ||
            current_precedence <
                min_precedence)
            break;

        take_token(input);

        emit_push_rax(
            output
        );

        parse_expression(
            input,
            output,
            current_precedence + 1
        );

        emit_binary_op(
            token.text,
            output
        );
    }
}

static void parse_assignment(
    FILE* input,
    FILE* output,
    const char* name
)
{
    int index =
        variable(name);

    expect(
        input,
        "="
    );

    Token token =
        peek_token(input);

    if (token.type == TOKEN_STRING)
		compiler_error(
			"String cannot initialize i64"
		);

	parse_expression(
		input,
		output,
		0
	);

	if (strlen(current_function) > 0) {
		emit_store_rax_to_variable(
			index,
			output
		);
	}
}

static void parse_pin(
    FILE* input,
    FILE* output
)
{
    expect(
        input,
        "("
    );

    Token token =
        take_token(input);

    if (token.type == TOKEN_STRING) {
        Token next =
            peek_token(input);

        if (!strcmp(
                token.text,
                "%c"
            ) &&
            !strcmp(
                next.text,
                ","
            )) {

            take_token(input);

            parse_expression(
                input,
                output,
                0
            );

            fputc(0x48, output);
            fputc(0x89, output);
            fputc(0xC6, output);

            expect(
                input,
                ")"
            );

            emit_pin_char(
                output
            );

            return;
        }

        expect(
            input,
            ")"
        );

        emit_pin_string(
            token.text,
            output
        );

        return;
    }

    if (token.type == TOKEN_NUMBER) {
        expect(
            input,
            ")"
        );

        emit_write_byte_syscall(
            parse_number(token),
            output
        );

        return;
    }

    compiler_error(
        "Invalid pin argument"
    );
}

static void parse_if(
    FILE* input,
    FILE* output
)
{
    expect(
        input,
        "("
    );

    parse_expression(
        input,
        output,
        0
    );

    expect(
        input,
        ")"
    );

    long jump =
        emit_jump_if_zero(
            output
        );

    expect(
        input,
        "{"
    );

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
)
{
    long start =
        ftell(output);

    expect(
        input,
        "("
    );

    parse_expression(
        input,
        output,
        0
    );

    expect(
        input,
        ")"
    );

    long exit =
        emit_jump_if_zero(
            output
        );

    expect(
        input,
        "{"
    );

    parse_block(
        input,
        output
    );

    long back =
        emit_jump_always(
            output
        );

    patch_jump_distance(
        back,
        start,
        output
    );

    patch_jump_distance(
        exit,
        ftell(output),
        output
    );
}

static void parse_return(
    FILE* input,
    FILE* output
)
{
    Token token =
        peek_token(input);

    if (!strcmp(
            token.text,
            "}"
        )) {

        if (current_is_main)
            emit_main_exit(output);
        else
            emit_function_epilog(output);

        return;
    }

    parse_expression(
        input,
        output,
        0
    );

    if (current_is_main)
        emit_main_return(output);
    else
        emit_function_epilog(output);
}

static void parse_inline_asm(
    FILE* input,
    FILE* output
)
{
    while (1) {
        Token token =
            take_token(input);

        if (token.type == TOKEN_EOF)
            compiler_error(
                "Unterminated asm"
            );

        if (!strcmp(
                token.text,
                "(asme)"
            ))
            return;

        if (!strcmp(
                token.text,
                "{"
            ) ||
            !strcmp(
                token.text,
                "}"
            ))
            continue;

        if (!strcmp(
                token.text,
                "cli"
            ))
            fputc(
                0xfa,
                output
            );
        else if (!strcmp(
                     token.text,
                     "sti"
                 ))
            fputc(
                0xfb,
                output
            );
        else if (!strcmp(
                     token.text,
                     "nop"
                 ))
            fputc(
                0x90,
                output
            );
        else if (!strcmp(
                     token.text,
                     "hlt"
                 ))
            fputc(
                0xf4,
                output
            );
        else if (!strcmp(
                     token.text,
                     "ret"
                 ))
            fputc(
                0xc3,
                output
            );
        else if (!strcmp(
                     token.text,
                     "syscall"
                 )) {
            fputc(
                0x0f,
                output
            );

            fputc(
                0x05,
                output
            );
        }
        else if (!strcmp(
                     token.text,
                     "pad_boot"
                 )) {

            long position =
                ftell(output);

            if (position < 0 ||
                position > 510)
                compiler_error(
                    "Invalid pad_boot"
                );

            while (position < 510) {
                fputc(
                    0,
                    output
                );

                position++;
            }
        }
        else if (!strcmp(
                     token.text,
                     "sign_boot"
                 )) {

            if (ftell(output) != 510)
                compiler_error(
                    "Invalid sign_boot"
                );

            fputc(
                0x55,
                output
            );

            fputc(
                0xaa,
                output
            );
        }
        else {
            compiler_error(
                "Unsupported asm instruction"
            );
        }
    }
}

static void parse_statement(
    FILE* input,
    FILE* output
)
{
    Token token =
        take_token(input);

    if (token.type == TOKEN_EOF)
        return;

    if (!strcmp(
            token.text,
            "(asmb)"
        )) {

        parse_inline_asm(
            input,
            output
        );

        return;
    }

    if (!strcmp(
            token.text,
            "if"
        )) {

        parse_if(
            input,
            output
        );

        return;
    }

    if (!strcmp(
            token.text,
            "while"
        )) {

        parse_while(
            input,
            output
        );

        return;
    }

    if (!strcmp(
            token.text,
            "return"
        )) {

        parse_return(
            input,
            output
        );

        return;
    }

    if (!strcmp(
            token.text,
            "pin"
        )) {

        parse_pin(
            input,
            output
        );

        return;
    }

    if (!strcmp(
            token.text,
            "file_write8"
        ) ||
        !strcmp(
            token.text,
            "mem_write8"
        ) ||
        !strcmp(
            token.text,
            "mem_write64"
        ) ||
        !strcmp(
            token.text,
            "file_seek"
        )) {

        parse_call(
            input,
            output,
            token.text
        );

        return;
    }

    if (!strcmp(
            token.text,
            "i64"
        )) {

        Token name =
            take_token(input);

        if (!is_valid_identifier(
                name.text
            )) {
            fprintf(
                stderr,
                "Compiler Error: Unknown statement: %s\n",
                token.text
            );
            exit(1);
        }

        parse_assignment(
            input,
            output,
            name.text
        );

        return;
    }

    if (token.type ==
        TOKEN_IDENTIFIER) {

        Token next =
            peek_token(input);

        if (!strcmp(
                next.text,
                "("
            )) {

            parse_call(
                input,
                output,
                token.text
            );

            return;
        }

        if (!strcmp(
                next.text,
                "="
            )) {

            parse_assignment(
                input,
                output,
                token.text
            );

            return;
        }
    }

    compiler_error(
        "Unknown statement"
    );
}

static void parse_block(
    FILE* input,
    FILE* output
)
{
    while (1) {
        Token token =
            peek_token(input);

        if (token.type == TOKEN_EOF)
            compiler_error(
                "Unexpected EOF"
            );

        if (!strcmp(
                token.text,
                "}"
            )) {

            take_token(input);
            return;
        }

        parse_statement(
            input,
            output
        );
    }
}

static void parse_function(
    FILE* input,
    FILE* output
)
{
    Token name =
        take_token(input);

    if (!is_valid_identifier(
            name.text
        ))
        compiler_error(
            "Invalid function name"
        );

    strcpy(
        current_function,
        name.text
    );

    current_is_main =
        !strcmp(
            name.text,
            "main"
        );

    current_param_count = 0;

    expect(
        input,
        "("
    );

    while (1) {
        Token token =
            peek_token(input);

        if (!strcmp(
                token.text,
                ")"
            )) {

            take_token(input);
            break;
        }

        Token type =
            take_token(input);

        if (strcmp(
                type.text,
                "i64"
            ) != 0)
            compiler_error(
                "Parameters must be i64"
            );

        Token parameter =
            take_token(input);

        if (!is_valid_identifier(
                parameter.text
            ))
            compiler_error(
                "Invalid parameter"
            );

        if (current_param_count >=
            MAX_PARAMS)
            compiler_error(
                "Too many parameters"
            );

        current_params[
            current_param_count++
        ] =
            variable(
                parameter.text
            );

        token =
            peek_token(input);

        if (!strcmp(
                token.text,
                ","
            )) {

            take_token(input);
            continue;
        }

        if (!strcmp(
                token.text,
                ")"
            ))
            continue;

        compiler_error(
            "Expected ',' or ')'"
        );
    }

    expect(
        input,
        "{"
    );

    long position =
        ftell(output);

    register_function(
        name.text,
        position
    );

    if (current_is_main)
        main_position =
            position;

    emit_program_prolog(
        output
    );

    for (int i = 0;
         i < current_param_count;
         i++) {

        emit_store_arg_reg(
            i,
            current_params[i],
            output
        );
    }

    parse_block(
        input,
        output
    );

    if (current_is_main)
        emit_main_exit(output);
    else
        emit_function_epilog(output);

    current_function[0] =
        '\0';

    current_is_main =
        0;

    current_param_count =
        0;
}

void parse_microc_program(
	FILE* input,
	FILE* output
)
{
	while (1) {
		Token token =
			take_token(input);

		if (token.type == TOKEN_EOF)
			break;

		if (!strcmp(
				token.text,
				"head"
			)) {

			expect(
				input,
				"("
			);

			Token target =
				take_token(input);

			Token mode =
				take_token(input);

			if (strcmp(
					target.text,
					"asm-x86-64"
				) != 0 ||
				strcmp(
					mode.text,
					"custom"
				) != 0)
				compiler_error(
					"Invalid head\n"
				);

			expect(
				input,
				")"
			);

			expect(
				input,
				"{"
			);

			continue;
		}

		if (!strcmp(
				token.text,
				"fn"
			)) {

			parse_function(
				input,
				output
			);

			continue;
		}

		if (!strcmp(
				token.text,
				"}"
			))
			continue;

		if (!strcmp(
				token.text,
				"i64"
			)) {

			Token name =
				take_token(input);

			if (!is_valid_identifier(
					name.text
				)) {
				compiler_error(
					"Invalid variable name\n"
				);
			}

			parse_assignment(
				input,
				output,
				name.text
			);

			continue;
		}

		has_lookahead = 1;
		lookahead = token;

		parse_statement(
			input,
			output
		);
	}

	resolve_calls(
		output
	);

	if (main_position < 0)
		compiler_error(
			"Missing main function\n"
		);

	patch_elf_entry(
		output,
		main_position
	);
}
