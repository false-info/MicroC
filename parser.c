#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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

void parser_code(char *code) {
    char *ptr = code;
    printf("[Parser]: starting parsing of source-code...\n");
    while (*ptr != '\0') {
        if (isspace(*ptr)) {
            ptr++;
            continue;
        }
        printf("[Parser DEBUG]: reading char: '%c'\n");
        ptr++;
    }
    printf("[Parser]: parsing done\n");
}
