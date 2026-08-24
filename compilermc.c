#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int MODE_X86_64 = 0;

void parser_microc(const char **src) {
    const char *p = *src;
    while ((*p == '\n') || (*p == '\t') || (*p == ' ')) {
        p++;
    }
    if  (strncmp(p, "head", 4) == 0) {
        p += 4;

        if (*p == '(') {
            p++;

            if (strncmp(p, "asm-x86-64", 10) == 0) {
                MODE_X86_64 = 1;
                p += 10;
            
            }
            while (*p != ')' && *p != '\0') {
                putchar(*p);
                p++;
            } 
            if (*p == ')') {
                p++;
            } else {
                printf("error: end of head block not found")
            }
            while (*p != '{' && *p != '\0') {
                putchar(*p);
                p++;
            }
            while ((*p == '\n') || (*p == '\t') || (*p == ' ')) {
                p++;
            }
            if (strncmp(p, "(asmb)", 6) == 0) {
                p += 6;
                while ((*p == '\n') || (*p == '\t') || (*p == ' ')) {
                    p++;
                }
                if (*p == '{') {
                    p++;
                    while (*p != '}' && *p != '\0') {
                        putchar(*p);
                        p++;
                    }
                    if (*p == '}') {
                        p++;
                    } else {
                        printf("error: end of assembly not found");
                    }
                    while ((*p == '\n') || (*p == '\t') || (*p == ' ')) {
                        p++;
                    }
                    if (strncmp(p, "(asme)", 6) == 0) {
                        p += 6;
                    } else {
                        printf("error: (asme) not found");
                    }
                }
            }
        } else {
            printf("error: start of head block not found");
        }
    } else {
        printf("error: head block not found");
    }
    *src = p;
}
