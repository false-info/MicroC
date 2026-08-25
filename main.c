#include <stdio.h>
#include <stdlib.h>

void tokenize(char* source);

int main(int argc, char* argv[]) {
    if (argc < 2) {
        printf("error: found no file run the right command exemple ./microc test.mc");
        return 1;
    }

    FILE* file = fopen(argv[1], "r");
    if (file = NULL) {
        printf("error: could not open file '%s'");
        return 1;
    }
    fseek(file, 0, SEEK_END);
    long file_size = ftell(file);
    fseek(file, 0, SEEK_END);

    char* source_code = malloc(file_size + 1);
    if (source_code == NULL) {
        printf("error: couldn't alloc memory for source code");
        fclose(file);
        return 1;
    }
    fread(source_code, 1, file_size, file);
    source_code[file_size] = '\0';
    fclose(file);
    tokenize(source_code);
    free(source_code);
    return 0;
}
