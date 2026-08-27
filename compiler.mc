head(asm-x86-64 custom) {
  i64 current = 0
  i64 in_asm_mode = 0

  fn emit_cli() {
    write_byte(0xFA)
  }

  fn emit_hlt() {
    write_byte(0xF4)
  }

  fn main() {
    i64 compiling = 1
    current = 0x05 

    while (current == 0) {
      if (in_asm_mode == 1) {
        emit_cli()
        emit_hlt()
      }
    }
  }
}
