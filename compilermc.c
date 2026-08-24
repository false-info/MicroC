#include <stdio.h>
#include <string.h>

void parser_microc(const char **src) {
  const char *p = *src;
  if (strcmp(p, "head", 4) == 0) {
    p += 4;

    if (*p == '(') {
      p++;
      printf("opened head block");
      if (strcmp(p, "asm-x86-64", 10) == 0) {
        MODE_X86_64 = 1;
        printf("-> enabled x86_64 mode\n");
      }
      while (*p == ')' && *p != '\0') {
        putchar(*p);
        p++;
      }
      if (*p == ')') {  
        printf("head block closed");
        p++;
      } else if {
        printf("\nerror missing end of head block ")"");
      }
    } else if {
      printf("\nerror missing start of head block "("");
    }
  } else if {
    printf("\nerror missing head block");
  }
}

int main() {
  const char *code = "head(asm-x86-64)";
  parse_microc(code);
  return 0;
}
