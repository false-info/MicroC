MicroC

<p align="center">
  <b>A small, native systems programming language.</b><br>
  Designed for low-level programming, operating systems, and bare-metal development.
</p>
<p align="center">
  <img src="https://img.shields.io/badge/Language-MicroC-red">
  <img src="https://img.shields.io/badge/Target-x86--64-black">
  <img src="https://img.shields.io/badge/Compiler-AOT-blue">
  <img src="https://img.shields.io/badge/Status-Development-orange">
</p>

⸻

What is MicroC?

MicroC is a custom systems programming language and compiler written from scratch.

The goal is to provide a small, understandable language that can operate close to the hardware while still providing higher-level programming features.

MicroC is designed with low-level development in mind, including:

* Operating systems
* Kernels
* Bare-metal programs
* Firmware
* Native applications
* System utilities
* Embedded development

MicroC does not need to generate assembly as an intermediate output.

The compiler can generate native machine code directly.

MicroC source
     │
     ▼
   Lexer
     │
     ▼
   Parser
     │
     ▼
  Code Generator
     │
     ▼
Machine Code
     │
     ▼
 Native executable

⸻

Why MicroC?

MicroC exists because low-level programming does not have to mean writing everything in assembly.

The idea is to combine:

C-like programming
        +
direct machine-code generation
        +
inline assembly
        +
low-level control

This allows MicroC programs to remain relatively simple while still giving the programmer direct access to the machine when necessary.

⸻

Example

A minimal MicroC program can look like:

pin("Hello from MicroC!");
exit();

The MicroC compiler translates the source into native code rather than producing an assembly file that must then be assembled separately.

Conceptually:

test.mc
   │
   ▼
 MicroC
   │
   ▼
x86-64 machine code
   │
   ▼
 executable

⸻

Compiler Architecture

MicroC is split into several stages.

              MicroC source
                    │
                    ▼
              ┌───────────┐
              │   Lexer   │
              └─────┬─────┘
                    │
                    ▼
              ┌───────────┐
              │  Parser   │
              └─────┬─────┘
                    │
                    ▼
              ┌───────────┐
              │ Code Gen  │
              └─────┬─────┘
                    │
                    ▼
             Machine Code

Lexer

The lexer converts the source code into tokens.

For example:

pin("Hello");

becomes a sequence of tokens representing things such as:

identifier
(
string
)
;

The lexer is responsible for recognizing the basic building blocks of MicroC.

⸻

Parser

The parser takes the tokens produced by the lexer and determines whether they form valid MicroC syntax.

It converts the token stream into a structure that the compiler can understand.

Conceptually:

Source
  ↓
Tokens
  ↓
Parser
  ↓
Program structure

⸻

Code Generator

The code generator converts the parsed MicroC program into native machine code.

Unlike a traditional compiler pipeline such as:

MicroC → Assembly → Assembler → Machine Code

MicroC aims for:

MicroC → Machine Code

This gives the compiler direct control over the generated instructions.

⸻

Inline Assembly

MicroC also provides inline assembly for situations where direct control over the CPU is required.

Example:

head(asm-x86-64 custom) {
    (asmb) {
        cli
        hlt
    } (asme)
}

The assembly block is passed directly through the compiler.

This means MicroC can mix normal language constructs with low-level CPU instructions.

MicroC
   │
   ├── High-level code
   │
   └── Inline x86-64 ASM
             │
             ▼
       Native machine code

The inline assembly system is intentionally flexible, allowing the programmer to write the assembly instructions they need instead of restricting them to a small predefined instruction set.

⸻

Bare-Metal Development

One of MicroC’s goals is making bare-metal development easier.

For example, MicroC includes compiler functionality designed around boot-sector development.

A simple boot-sector ASM block can contain:

head(asm-x86-64 custom) {
    (asmb) {
        cli
        hlt
        pad_boot
        sign_boot
    } (asme)
}

Special compiler functionality can handle boot-sector requirements such as:

pad_boot
    ↓
Pads the generated boot sector to 512 bytes
sign_boot
    ↓
Adds the boot signature

This allows the programmer to focus on the actual boot code instead of manually calculating padding and inserting the boot signature.

Conceptually:

MicroC source
      │
      ▼
Inline ASM
      │
      ▼
Machine code
      │
      ▼
512-byte boot sector
      │
      ├── Boot code
      ├── Padding
      └── 0x55AA

⸻

Current Compiler

MicroC currently focuses on AOT compilation.

AOT means Ahead-Of-Time compilation.

The program is compiled before execution:

MicroC source
      │
      ▼
   Compiler
      │
      ▼
Machine code
      │
      ▼
    Execute

The future plan is to add JIT compilation after the MicroC-based operating system is established.

⸻

AOT vs JIT

The current compiler:

             MicroC
                │
                ▼
              AOT
                │
                ▼
        Native machine code

Future architecture:

                 MicroC
                    │
          ┌─────────┴─────────┐
          ▼                   ▼
        AOT                   JIT
          │                   │
          ▼                   ▼
   Native executable    Runtime machine code

JIT functionality is planned for a later stage of MicroC development.

⸻

Project Structure

The compiler is currently organized around several core components.

MicroC/
├── lexer.c
├── parser.c
├── codegen.c
├── main.c
├── test.mc
├── Makefile
└── README.md

lexer.c

Handles lexical analysis and tokenization.

parser.c

Handles parsing of MicroC source code.

codegen.c

Responsible for generating native machine code.

main.c

Controls the compiler pipeline and command-line interface.

test.mc

Contains MicroC test programs used during development.

Makefile

Build system for the compiler.

⸻

Compilation

Build MicroC using:

make

Then compile a MicroC program:

./microc test.mc -o hello

Run the generated executable:

./hello

⸻

Design Philosophy

MicroC follows a few simple principles.

Small

The language should remain understandable.

Native

The compiler should have direct control over the generated machine code.

Low-level

Programmers should be able to interact with the hardware when necessary.

Practical

The language should be useful for real programs, not only compiler experiments.

Extensible

The compiler architecture should allow new language features and targets to be added over time.

⸻

Roadmap

Compiler

* Lexer
* Parser
* Native machine-code generation
* Inline x86-64 assembly
* Boot-sector helpers
* More language constructs
* Better error messages
* More complete type system
* Standard library
* Cross-compilation

Operating System

MicroC is being developed alongside a custom operating system.

The long-term goal is to use MicroC for increasingly large parts of the system.

MicroC
   │
   ▼
Bootloader
   │
   ▼
Kernel
   │
   ▼
Operating System

Future

After the operating system side is established:

* JIT compiler
* Runtime compilation
* Additional architectures
* Self-hosting compiler
* Larger standard library
* More advanced optimization

⸻

The Long-Term Goal

The ultimate goal is for MicroC to become a complete systems programming language rather than simply a compiler experiment.

The intended direction is:

              MicroC
                 │
        ┌────────┼────────┐
        ▼        ▼        ▼
       AOT      JIT      ASM
        │        │        │
        └────────┼────────┘
                 ▼
          Native execution
                 │
       ┌─────────┼─────────┐
       ▼         ▼         ▼
      OS      Programs   Firmware

MicroC is being built from the ground up, including its compiler and code-generation system.

No existing C compiler is required to define the language itself.

⸻

Status

🚧 MicroC is currently under active development.

The compiler is functional, but the language and compiler architecture are still evolving.

Breaking changes are expected.

⸻

License

See the repository for licensing information.

⸻

<p align="center">
  <b>MicroC</b><br>
  Small language. Native code. Full control.
</p>