#include <stdio.h>
#include <string.h>

int MODE_X86_64 = 0;

void parser_microc(const char **src) {
  const char *p = *src;
  if ((*p == '\n') || (*p == 't\') || (*p == ' ')){
    p++;
    
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
      } else {
        printf("\nerror missing end of head block \")\"\n");
      }
    } else {
      printf("\nerror missing start of head block \"(\"\n");
    }
  } else {
    printf("\nerror missing head block\n");
  }
  }
  *src = p;
}

int main() {
  const char *code = "head(asm-x86-64)";
  const char *p_code = code;
  parser_microc(&p_code);
  return 0;
}
