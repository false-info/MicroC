#include <stdio.h>
#include <stdlib.h>
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
    if (!isalpha(text[0]) && text[0] != '_') return 0;
    for (int i = 1; text[i] != '\0'; i++) {
        if (!isalnum(text[i]) && text[i] != '_') return 0;
    }
    return 1;
}

Token next_token(FILE* input) {
    Token token;
    memset(token.text, 0, sizeof(token.text));
    int c;

    while (1) {
        c = fgetc(input);
        if (c == EOF) {
            token.type = TOKEN_EOF;
            strcpy(token.text, "EOF");
            return token;
        }

        if (isspace(c)) continue;

        if (c == '/') {
            int next_c = fgetc(input);
            if (next_c == '/') {
                while ((c = fgetc(input)) != '\n' && c != EOF);
                continue;
            } else {
                if (next_c != EOF) ungetc(next_c, input);
            }
        }

        break;
    }

    if (c == '"') {
        token.type = TOKEN_STRING;
        int idx = 0;
        while ((c = fgetc(input)) != '"' && c != EOF) {
            if (idx < 255) {
                token.text[idx++] = c;
            }
        }
        token.text[idx] = '\0';
        return token;
    }

    if (c == '(' || c == ')') {
        token.type = TOKEN_SYMBOL;
        token.text[0] = c;
        token.text[1] = '\0';
        
        if (c == '(') {
            int next_c = fgetc(input);
            if (next_c == 'a') {
                int c2 = fgetc(input);
                int c3 = fgetc(input);
                int c4 = fgetc(input);
                int c5 = fgetc(input);
                if (c2 == 's' && c3 == 'm' && c4 == 'b' && c5 == ')') {
                    strcpy(token.text, "(asmb)");
                    return token;
                }
                if (c5 != EOF) ungetc(c5, input);
                if (c4 != EOF) ungetc(c4, input);
                if (c3 != EOF) ungetc(c3, input);
                if (next_c != EOF) ungetc(next_c, input);
            } else {
                if (next_c != EOF) ungetc(next_c, input);
            }
        }
        return token;
    }

    if (c == '{' || c == '}' || c == ',' || c == '=') {
        token.type = TOKEN_SYMBOL;
        token.text[0] = c;
        token.text[1] = '\0';
        return token;
    }

    if (isdigit(c)) {
        token.type = TOKEN_NUMBER;
        int idx = 0;
        while (isdigit(c)) {
            if (idx < 255) token.text[idx++] = c;
            c = fgetc(input);
        }
        if (c != EOF) ungetc(c, input);
        token.text[idx] = '\0';
        return token;
    }

    if (isalpha(c) || c == '_' || c == '-') {
        int idx = 0;
        while (isalnum(c) || c == '_' || c == '-') {
            if (idx < 255) token.text[idx++] = c;
            c = fgetc(input);
        }
        if (c != EOF) ungetc(c, input);
        token.text[idx] = '\0';

        if (strcmp(token.text, "head") == 0 || 
            strcmp(token.text, "i64") == 0 || 
            strcmp(token.text, "fn") == 0 || 
            strcmp(token.text, "pin") == 0 ||
            strcmp(token.text, "custom") == 0 ||
            strcmp(token.text, "asm-x86-64") == 0) {
            token.type = TOKEN_KEYWORD;
        } else if (strcmp(token.text, "(asme)") == 0) {
            token.type = TOKEN_SYMBOL;
        } else {
            token.type = TOKEN_IDENTIFIER;
        }
        return token;
    }

    token.type = TOKEN_SYMBOL;
    token.text[0] = c;
    token.text[1] = '\0';
    return token;
}
