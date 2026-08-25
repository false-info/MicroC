#include <stdio.h>
#include <string.h>
#include <ctype.h>

void tokenize(char* source) {
    int i = 0;
    int length = strlen(source);
    printf("[lexer] start goind thru source code...\n");
    while (i < length) {
        if (isspace((unsigned char)source[i])) {
            i++;
            continue;
        }
        if (strncmp(&source[i], "(asmb)", 6) == 0) {
            i += 6;
            printf("found asmb\n");
            
            while (i < length) {
                if (strncmp(&source[i], "(asme)", 6) == 0) {
                    i += 6;
                    break;
                }
                putchar(source[i]);
                i++;
            }
            continue;
        }
        if (strncmp(&source[i], "asm-x86-64", 10) == 0) {
            i += 10;
            continue;
        }
        if (strncmp(&source[i], "head", 4) == 0) {
            i += 4;
            continue;
        }
        if (source[i] == '(' || source[i] == ')' || source[i] == '{' || source[i] == '}') {
            i++;
            continue;
        }
        i++;
    }
}
