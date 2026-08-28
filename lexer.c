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
	       strcmp(text, "while") == 0 ||
	       strcmp(text, "return") == 0;
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

		printf("[LEXER DEBUG] Read raw byte: %d (Hex: 0x%X)\n", c, c);

		if (isspace((unsigned char)c) || (unsigned char)c == 194 || (unsigned char)c == 160)
			continue;

		if (c == '/') {
			int next_char = fgetc(input);

			if (next_char == '/') {
				while ((c = fgetc(input)) != '\n' && c != EOF)
					;
				continue;
			}

			if (next_char != EOF)
				ungetc(next_char, input);
		}

		break;
	}


	if (c == '"') {
		int i = 0;
		token.type = TOKEN_STRING;

		while ((c = fgetc(input)) != EOF && c != '"') {
			if (c == '\\') {
				int next_char = fgetc(input);

				if (next_char == 'n')
					c = '\n';
				else if (next_char == 'r')
					c = '\r';
				else if (next_char == 't')
					c = '\t';
				else
					c = next_char;
			}

			if (i < 255)
				token.text[i++] = (char)c;
		}

		token.text[i] = '\0';
		return token;
	}

	if (c == '(') {
		char buffer[16];
		int i = 0;
		buffer[i++] = '(';

		int next_char = fgetc(input);
		
		if (next_char == 'a') {
			while (next_char != EOF && next_char != ')' && i < 15) {
				buffer[i++] = (char)next_char;
				next_char = fgetc(input);
			}

			if (next_char == ')') {
				buffer[i++] = ')';
				buffer[i] = '\0';

				if (strcmp(buffer, "(asmb)") == 0 || strcmp(buffer, "(asme)") == 0) {
					token.type = TOKEN_SYMBOL;
					strcpy(token.text, buffer);
					return token;
				}
			} else {
				if (next_char != EOF) {
					ungetc(next_char, input);
				}
			}
			
			for (int j = i - 1; j >= 1; j--) {
				ungetc((unsigned char)buffer[j], input);
			}
		} else {
			if (next_char != EOF) {
				ungetc(next_char, input);
			}
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

		int next_char = fgetc(input);

		token.type = TOKEN_SYMBOL;
		token.text[0] = (char)c;

		if (next_char == '=') {
			token.text[1] = '=';
			token.text[2] = '\0';
		} else if (c == '<' && next_char == '<') {
			token.text[1] = '<';
			token.text[2] = '\0';
		} else if (c == '>' && next_char == '>') {
			token.text[1] = '>';
			token.text[2] = '\0';
		} else {
			token.text[1] = '\0';

			if (next_char != EOF)
				ungetc(next_char, input);
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
			int next_char = fgetc(input);

			if (next_char == 'x' || next_char == 'X') {
				token.text[i++] = (char)next_char;

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

			if (next_char != EOF)
				ungetc(next_char, input);
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
