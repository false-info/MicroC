#include <stdio.h>
#include <string.h>
#include <ctype.h>

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

int is_valid_identifier(const char* text)
{
    if (!text || !text[0])
        return 0;

    if (!isalpha((unsigned char)text[0]) &&
        text[0] != '_')
        return 0;

    for (int i = 1; text[i] != '\0'; i++) {
        if (!isalnum((unsigned char)text[i]) &&
            text[i] != '_')
            return 0;
    }

    return 1;
}

static int is_keyword(const char* text)
{
    static const char* words[] = {
        "head",
        "i64",
        "fn",
        "return",
        "if",
        "while",
        "pin",
        "custom",
        "asm-x86-64"
    };

    size_t count =
        sizeof(words) / sizeof(words[0]);

    for (size_t i = 0; i < count; i++) {
        if (strcmp(text, words[i]) == 0)
            return 1;
    }

    return 0;
}

static Token make_token(
    TokenType type,
    const char* text
)
{
    Token token;

    memset(
        &token,
        0,
        sizeof(token)
    );

    token.type = type;

    if (text) {
        size_t length =
            strlen(text);

        if (length >= sizeof(token.text))
            length =
                sizeof(token.text) - 1;

        memcpy(
            token.text,
            text,
            length
        );

        token.text[length] = '\0';
    }

    return token;
}

Token next_token(FILE* input)
{
    int c;

    while (1) {
        c = fgetc(input);

        if (c == EOF)
            return make_token(
                TOKEN_EOF,
                "EOF"
            );

        if (isspace((unsigned char)c))
            continue;

        if (c == '/') {
            int next =
                fgetc(input);

            if (next == '/') {
                while ((c = fgetc(input)) != EOF &&
                       c != '\n')
                    ;

                continue;
            }

            if (next != EOF)
                ungetc(next, input);
        }

        break;
    }

    if (c == '"') {
        char buffer[256];
        int index = 0;

        while (1) {
            c = fgetc(input);

            if (c == EOF ||
                c == '"')
                break;

            if (c == '\\') {
                int next =
                    fgetc(input);

                if (next == 'n')
                    c = '\n';
                else if (next == 'r')
                    c = '\r';
                else if (next == 't')
                    c = '\t';
                else if (next == '\\')
                    c = '\\';
                else if (next == '"')
                    c = '"';
                else
                    c = next;
            }

            if (index < 255)
                buffer[index++] =
                    (char)c;
        }

        buffer[index] = '\0';

        return make_token(
            TOKEN_STRING,
            buffer
        );
    }

    if (c == '(') {
        char buffer[16];
        int index = 0;

        buffer[index++] =
            '(';

        int next =
            fgetc(input);

        while (next != EOF &&
               next != ')' &&
               index < 15) {

            buffer[index++] =
                (char)next;

            next =
                fgetc(input);
        }

        if (next == ')') {
            buffer[index++] =
                ')';

            buffer[index] =
                '\0';

            if (!strcmp(
                    buffer,
                    "(asmb)"
                ) ||
                !strcmp(
                    buffer,
                    "(asme)"
                )) {

                return make_token(
                    TOKEN_SYMBOL,
                    buffer
                );
            }

            for (int i = index - 1;
                 i >= 1;
                 i--) {

                ungetc(
                    (unsigned char)buffer[i],
                    input
                );
            }
        }
        else {
            if (next != EOF)
                ungetc(
                    next,
                    input
                );

            for (int i = index - 1;
                 i >= 1;
                 i--) {

                ungetc(
                    (unsigned char)buffer[i],
                    input
                );
            }
        }

        return make_token(
            TOKEN_SYMBOL,
            "("
        );
    }

    if (c == '=' ||
        c == '!' ||
        c == '<' ||
        c == '>') {

        char buffer[3];

        buffer[0] =
            (char)c;

        buffer[1] =
            '\0';

        buffer[2] =
            '\0';

        int next =
            fgetc(input);

        if (next == '=') {
            buffer[1] =
                '=';
        }
        else if (c == '<' &&
                 next == '<') {

            buffer[1] =
                '<';
        }
        else if (c == '>' &&
                 next == '>') {

            buffer[1] =
                '>';
        }
        else if (next != EOF) {
            ungetc(
                next,
                input
            );
        }

        return make_token(
            TOKEN_SYMBOL,
            buffer
        );
    }

    if (strchr(
            "){},[]+-*/%&|^",
            c
        )) {

        char buffer[2];

        buffer[0] =
            (char)c;

        buffer[1] =
            '\0';

        return make_token(
            TOKEN_SYMBOL,
            buffer
        );
    }

    if (isdigit((unsigned char)c)) {
        char buffer[256];
        int index = 0;

        buffer[index++] =
            (char)c;

        if (c == '0') {
            int next =
                fgetc(input);

            if (next == 'x' ||
                next == 'X') {

                buffer[index++] =
                    (char)next;

                while ((c = fgetc(input)) != EOF &&
                       isxdigit((unsigned char)c)) {

                    if (index < 255)
                        buffer[index++] =
                            (char)c;
                }

                if (c != EOF)
                    ungetc(
                        c,
                        input
                    );

                buffer[index] =
                    '\0';

                return make_token(
                    TOKEN_NUMBER,
                    buffer
                );
            }

            if (next != EOF)
                ungetc(
                    next,
                    input
                );
        }

        while ((c = fgetc(input)) != EOF &&
               isdigit((unsigned char)c)) {

            if (index < 255)
                buffer[index++] =
                    (char)c;
        }

        if (c != EOF)
            ungetc(
                c,
                input
            );

        buffer[index] =
            '\0';

        return make_token(
            TOKEN_NUMBER,
            buffer
        );
    }

    if (isalpha((unsigned char)c) ||
        c == '_') {

        char buffer[256];
        int index = 0;

        while ((isalnum((unsigned char)c) ||
                c == '_' ||
                c == '-') &&
               index < 255) {

            buffer[index++] =
                (char)c;

            c =
                fgetc(input);
        }

        if (c != EOF)
            ungetc(
                c,
                input
            );

        buffer[index] =
            '\0';

        if (is_keyword(buffer))
            return make_token(
                TOKEN_KEYWORD,
                buffer
            );

        return make_token(
            TOKEN_IDENTIFIER,
            buffer
        );
    }

    return make_token(
        TOKEN_SYMBOL,
        (char[]){(char)c, '\0'}
    );
}#include <stdio.h>
#include <string.h>
#include <ctype.h>

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

int is_valid_identifier(const char* text) {
    if (!text || !text[0])
        return 0;

    if (!isalpha((unsigned char)text[0]) && text[0] != '_')
        return 0;

    for (int i = 1; text[i] != '\0'; i++) {
        if (!isalnum((unsigned char)text[i]) && text[i] != '_')
            return 0;
    }

    return 1;
}

static int is_keyword(const char* text) {
    return strcmp(text, "head") == 0 ||
           strcmp(text, "i64") == 0 ||
           strcmp(text, "fn") == 0 ||
           strcmp(text, "pin") == 0 ||
           strcmp(text, "custom") == 0 ||
           strcmp(text, "asm-x86-64") == 0 ||
           strcmp(text, "if") == 0 ||
           strcmp(text, "while") == 0;
}

Token next_token(FILE* input) {
    Token token;
    memset(&token, 0, sizeof(token));

    int c;

    while (1) {
        c = fgetc(input);

        if (c == EOF) {
            token.type = TOKEN_EOF;
            strcpy(token.text, "EOF");
            return token;
        }

        if (isspace((unsigned char)c))
            continue;

        if (c == '/') {
            int next = fgetc(input);

            if (next == '/') {
                while ((c = fgetc(input)) != '\n' && c != EOF)
                    ;
                continue;
            }

            if (next != EOF)
                ungetc(next, input);
        }

        break;
    }

    if (c == '"') {
        int i = 0;
        token.type = TOKEN_STRING;

        while ((c = fgetc(input)) != EOF && c != '"') {
            if (c == '\\') {
                int next = fgetc(input);

                if (next == 'n')
                    c = '\n';
                else if (next == 'r')
                    c = '\r';
                else if (next == 't')
                    c = '\t';
                else
                    c = next;
            }

            if (i < 255)
                token.text[i++] = (char)c;
        }

        token.text[i] = '\0';
        return token;
    }

    if (c == '(') {
        char buffer[8];
        int i = 0;

        buffer[i++] = '(';

        int next = fgetc(input);

        while (next != EOF &&
               next != ')' &&
               i < 7) {
            buffer[i++] = (char)next;
            next = fgetc(input);
        }

        if (next == ')') {
            buffer[i++] = ')';
            buffer[i] = '\0';

            if (strcmp(buffer, "(asmb)") == 0 ||
                strcmp(buffer, "(asme)") == 0) {
                token.type = TOKEN_SYMBOL;
                strcpy(token.text, buffer);
                return token;
            }

            for (int j = i - 1; j >= 1; j--)
                ungetc((unsigned char)buffer[j], input);
        } else {
            if (next != EOF)
                ungetc(next, input);

            for (int j = i - 1; j >= 1; j--)
                ungetc((unsigned char)buffer[j], input);
        }

        token.type = TOKEN_SYMBOL;
        token.text[0] = '(';
        token.text[1] = '\0';
        return token;
    }

    if (c == '=' ||
        c == '!' ||
        c == '<' ||
        c == '>') {

        int next = fgetc(input);

        token.type = TOKEN_SYMBOL;
        token.text[0] = (char)c;

        if (next == '=') {
            token.text[1] = '=';
            token.text[2] = '\0';
        } else {
            token.text[1] = '\0';

            if (next != EOF)
                ungetc(next, input);
        }

        return token;
    }

    if (c == ')' ||
        c == '{' ||
        c == '}' ||
        c == ',' ||
        c == '+' ||
        c == '-' ||
        c == '*' ||
        c == '/') {

        token.type = TOKEN_SYMBOL;
        token.text[0] = (char)c;
        token.text[1] = '\0';
        return token;
    }

    if (isdigit((unsigned char)c)) {
        int i = 0;

        token.type = TOKEN_NUMBER;
        token.text[i++] = (char)c;

        if (c == '0') {
            int next = fgetc(input);

            if (next == 'x' || next == 'X') {
                token.text[i++] = (char)next;

                while ((c = fgetc(input)) != EOF &&
                       isxdigit((unsigned char)c)) {

                    if (i < 255)
                        token.text[i++] = (char)c;
                }

                if (c != EOF)
                    ungetc(c, input);

                token.text[i] = '\0';
                return token;
            }

            if (next != EOF)
                ungetc(next, input);
        }

        while ((c = fgetc(input)) != EOF &&
               isdigit((unsigned char)c)) {

            if (i < 255)
                token.text[i++] = (char)c;
        }

        if (c != EOF)
            ungetc(c, input);

        token.text[i] = '\0';
        return token;
    }

    if (isalpha((unsigned char)c) || c == '_') {
        int i = 0;

        while ((isalnum((unsigned char)c) ||
                c == '_' ||
                c == '-') &&
               i < 255) {

            token.text[i++] = (char)c;
            c = fgetc(input);
        }

        if (c != EOF)
            ungetc(c, input);

        token.text[i] = '\0';

        if (is_keyword(token.text))
            token.type = TOKEN_KEYWORD;
        else
            token.type = TOKEN_IDENTIFIER;

        return token;
    }

    token.type = TOKEN_SYMBOL;
    token.text[0] = (char)c;
    token.text[1] = '\0';

    return token;
}
