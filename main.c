#include <stdio.h>
#include <stdlib.h>

void tokenize(char* source);

int main(int argc, char* argv[]) {
    
    if (argc < 2 || argv[1] == NULL) { 
        printf("error: found no file run the right command example ./microc test.mc\n");
        return 1;
    }

    FILE* file = fopen(argv[1], "r");
    if (file == NULL) {
        printf("error: could not open file '%s'\n", argv[1]);
        return 1;
    }

    fseek(file, 0, SEEK_END);
    long file_size = ftell(file);
    fseek(file, 0, SEEK_SET);

    char* source_code = malloc(file_size + 1);
    if (source_code == NULL) {
        fclose(file);
        return 1;
    }

    size_t read_bytes = fread(source_code, 1, file_size, file);
    source_code[read_bytes] = '\0'; 
    fclose(file);

    tokenize(source_code);

    free(source_code);
    return 0;
}
