#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

#define ASM_BUFFER_SIZE 65536

char asm_storage[ASM_BUFFER_SIZE];
int asm_index = 0;

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

char* run_asm_vaccum(char *ptr) {
    ptr += 6;
    asm_index = 0;
    asm_storage[0] = '\0';
    while (*ptr != '\0') {
        if (strncmp(ptr, "(asme)", 6) == 0) {
            ptr += 6;
            break;
        }
        if (asm_index < ASM_BUFFER_SIZE - 1) {
            asm_storage[asm_index] = *ptr;
            asm_index++;
        } else {
            fprintf(stderr, "[compiler-error]: inline-asm block is too big for the memorybuffer\n");
            exit(1);
        }
        ptr++;
    }
    asm_storage[asm_index] = '\0';
    return ptr;
}
