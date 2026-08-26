#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char* run_asm_vaccum(char *ptr);
extern char asm_storage[];

typedef struct Variable {
    char *name;
    int stack_offset;
    struct Variable *next;
} Variable;

Variable *symbol_table = NULL;

void add_variable(char *var_name, int offset) {
    Variable *new_node = (Variable *)malloc(sizeof(Variable));
    if (new_node == NULL) {
        fprintf(stderr, "compiler-error: no more RAM-memory in the compiler\n");
        exit(1);
    }
    new_node->name = strdup(var_name);
    new_node->stack_offset = offset;
    new_node->next = symbol_table;
    symbol_table = new_node;
    printf("compiler-info: registrated the variable '%s' on stack-ofset %d\n", var_name, offset);
}

Variable* find_variable(char *var_name) {
    Variable *current = symbol_table;
    while (current != NULL) {
        if (strcmp(current->name, var_name) == 0) {
            return current;
        }
        current = current->next;
    }
    return NULL;
}

void read_word(char *src, char *dest) {
    int i = 0;
    while (src[i] != '\0' && (isalnum((unsigned char)src[i]) || src[i] == '_') && i < 31) {
        dest[i] = src[i];
        i++;
    }
    dest[i] = '\0';
}
void parser_code(char *code) {
    if (code == NULL) return;

    char *ptr = code;
    int current_stack_offset = -8;
    int inside_head = 0;
    int custom_supported = 0;
    printf("[Parser]: starting parsing of source-code...\n");

    while (*ptr != '\0') {
        if (isspace((unsigned char)*ptr)) {
            ptr++;
            continue;
        }
        if (strncmp(ptr, "head", 4) == 0) {
            printf("[Parser]: found keyword 'head'\n");
            ptr += 4;
            if (strstr(ptr, "custom") != NULL) custom_supported = 1;
            while (*ptr != '{' && *ptr != '\0') ptr++;
            if (*ptr == '{') {
                inside_head = 1;
                ptr++;
            }
            continue;
        }
        if (inside_head) {
            if (strncmp(ptr, "(asmb)", 6) == 0) {
                printf("[parser]: sending to the vaccum...\n");
                ptr = run_asm_vaccum(ptr);
                continue;
            }

            if (isalpha((unsigned char)*ptr)) {
                char current_word[32] = {0};
                read_word(ptr, current_word);

                if (strcmp(current_word, "int") == 0) {
                    ptr += strlen(current_word);
                    while (isspace((unsigned char)*ptr)) ptr++;
                    char var_name[32] = {0};
                    read_word(ptr, var_name);

                    if (find_variable(var_name) != NULL) {
                        fprintf(stderr, "[Parser error]: Variable '%s' is already defined\n", var_name);
                        exit(1);
                    }
                    if (!custom_supported) {
                        fprintf(stderr, "[Parser error]: cannot use 'int' without decalring 'custom' mode in head block\n");
                        exit(1);
                    }
                    add_variable(var_name, current_stack_offset);
                    current_stack_offset -= 8;

                    ptr += strlen(var_name);
                    continue;
                }
            }
        }
        if (*ptr == '}') {
            inside_head = 0;
            printf("[Parser]: exiting head block\n");
        }
        ptr++;
    }
    printf("\n[Parser]: parsing done\n");
}
