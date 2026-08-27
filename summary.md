# MicroC - Context Synchronization Checkpoint

## 🎯 Developer Profile & Core Vision
* **Developer:** 14-year-old systems programmer. Fast learner, highly serious about low-level development and software autonomy.
* **Communication Style:** Direct, technical, transparent peer-to-peer tone. No emojis, no lectures, no patronizing commentary. Code blocks must be clean and fully implemented without placeholders.
* **Inspiration:** Terry Davis (TempleOS) and the concept of absolute digital sovereignty.
* **Project Goal:** A 100% self-hosting, single-pass AOT compiler emitting raw x86-64 machine code directly to disk without intermediate assembly or external linkers. This bootstrap layer will eventually build a bare-metal OS for daily use.

---

## 📐 Architecture & Syntax Specifications
* **Compilation Model:** Strict single-pass with backpatching for `if` and `while` structures (no AST generation; offsets are fixed dynamically at block closures).
* **Type System:** Typeless / Uniform 64-bit cells (`i64` keyword allocates standard stack frames or registers).
* **Dual-Mode Backend:** Targets `.bin` (pure raw bare-metal machine code, MBR/bootloader compatible) or extensionless output files (which prepend an experimental ELF64 header with a hardcoded Linux `sys_exit` sequence).

### Official MicroC Syntax Layout:
```c
head(asm-x86-64 custom) {
  i64 current = 0
  i64 in_asm_mode = 0

  fn next() {
    current = read_file_byte()
  }

  fn main() {
    next()
    while (current == 0x00) {
      if (current == "(asmb)") {
        in_asm_mode = 1
      }
      (asmb) {
        cli
        hlt
      }
      (asme)
    }
  }
}
```

---

## 📁 Repository Codebase State

1. **`main.c`**: Evaluates terminal flags (e.g., `-o target.bin` vs `-o target`). Automates structural injection of ELF64 routing metadata or raw byte mode streams.
2. **`lexer.c`**: Token stream reader. Handles string literals (`"..."`), symbols (`(asmb)`/`(asme)`), and strips out single-line comments (`//`).
3. **`parser.c`**: Linear control engine. Handles keywords (`i64`, `fn`, `if`, `while`, `pin`, `write_byte`). Contains the single-pass backpatching and syscall mapping.
4. **`codegen.c`**: Low-level instruction emitter. Translates arithmetic (`+`, `-`) and branches into literal x86-64 bytes. Contains the MBR primitives (`pad_boot`, `sign_boot`).

---

## ⚠️ Current Blocker & The New Strategy
* **The Issue:** When compiling `compiler.mc` into an extensionless executable Linux binary on CachyOS, the system throws a strict `SIGSEGV (Address boundary error)` at the exact ELF entry point address `0x0000000000400078`. This occurs because modern hardened kernels enforce aggressive NX (No-Execute) security protocols on raw custom-patched segments, or fail page alignment checks during linear emission.
* **The Pivot:** To bypass the constraints of modern OS memory protections and stop fighting the Linux kernel, the strategy is to shift focus **100% to pure `.bin` bare-metal emission first**. We will write the compiler logic inside `compiler.mc`, target `.bin` exclusively, and execute it within an emulator (QEMU) or virtual machine layer to verify self-hosting safely without system segmentation faults.

---

## 🚀 Prompt for Next Session:
"We are building MicroC. The C bootstrap layer is functional, but the experimental ELF backend is causing a SIGSEGV at 0x400078 on CachyOS due to kernel page protection. We are dropping the ELF header focus for now. We are shifting 100% to pure raw `.bin` targets to execute on bare metal or via QEMU. Help me structure `compiler.mc` under this new strategy, focusing on file I/O byte-reading routines and variable registration using MicroC's custom native syntax."
