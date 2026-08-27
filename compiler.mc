head(asm-x86-64 custom) {
  i64 current = 0
  i64 in_asm_mode = 0

  fn next() {
    current = read_file_byte()
  }
  fn emit_cli() {
    write_byte(0xFA)
  }
  fn emit_hlt() {
    write_byte(0xF4)
  }
  fn main() {
    i64 compiling = 1
    next()
    while (current == 0) {
      if (current == "(asmb)") {
        in_asm_mode = 1
        next()
      }
      if (current == "(asme)") {
        in_asm_mode = 0
        next()
      }
      if (in_asm_mode == 1) {
        if (current == "cli") {
          emit_cli()
        }
        if (current == "hlt") {
          emit_hlt()
        }
      }
      next()
    }
  }
}
