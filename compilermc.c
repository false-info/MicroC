#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int MODE_X86_64 = 0;

void parser_microc(const char **src) {
  const char *p = *src;
  while ((*p == '\n') || (*p == '\t') || (*p == ' ')){
    p++;
  }
  if (strncmp(p, "head", 4) == 0) {
    p += 4;

    if (*p == '(') {
      p++;
      printf("opened head block\n");

      if (strncmp(p, "asm-x86-64", 10) == 0) {
        MODE_X86_64 = 1;
        printf("-> enabled x86_64 mode\n");
        p += 10;
      }

      while (*p != ')' && *p != '\0') {
        putchar(*p);
        p++;
      }

      if (*p == ')') {  
        printf("\nhead block closed\n");
        p++;
      }
      while ((*p == '\n') || (*p == '\t') || (*p == ' ')) {
        p++;
      }
      if (strncmp(p, "(asmb)", 6) == 0) {
        p += 6;
        printf("asmb found and opened\n");
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
            }
            while ((*p == '\n') || (*p == '\t') || (*p == ' ')) {
              p++;
            }
            if (strncmp(p, "(asme)", 6) == 0) {
              p += 6;
              printf("asme found and closed");
            } else {
              printf("error (asme) not found\n");
            }
            
        }
      }
    } else {
      printf("\nerror missing start of head block \"(\"\n");
    }
  } else {
    printf("\nerror missing head block\n");
  }
  *src = p;
}

int main() {
  FILE *file = fopen("test.mc", "r");
  if (file = NULL) {
    printf("error: could not open test.mc");
    return 1;
  }
  char *buffer = malloc(46 + 1);
  fread(buffer, 1, 46, file);
  buffer[46] = '\0';
  fclose(file);
  free(buffer);
  return 0;
}
