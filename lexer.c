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
