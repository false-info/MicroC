#include <stdio.h>
#include <string.h>
#include <ctype.h>


void tokenize(char* source) {
    int i = 0;
    int length = strlen(source);
    printf("[lexer] start goind thru source code...\n");
    while (i < length) {
        if (isspace(source[i])) {
            i++;
            continue;
        }
        if (strncmp(&source[i], "head", 4) == 0) {
            i += 4;
            continue;
        }
        if (source[i] == '(') {
            i++;
            continue;
        }
        if (strncmp(&source[i], "asm-x86-64", 10) == 0) {
            i += 10;
            continue;
        }
        if (source[i] == ')') {
            i++;
            continue;
        }
        if (source[i] == '{') {
            i++;
            continue;
        }
        if (source[i] == '{') {
            i++;
            continue;
            
        }
        if (strncmp(&source[i], "(asmb)", 6) == 0) {
            i += 6;
            printf("found asmb");
            while (i < length) {
                if (strncmp(&source[i], "(asme)", 6) == 0) {
                    i += 6;
                    break;
                }
            }
            continue;
        }

    }

    printf("[Lexer] done! found end of file\n");
}
