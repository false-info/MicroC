MicroC

<p align="center">
  <b>A small native systems programming language.</b>
</p>
<p align="center">
  Built from scratch for low-level programming, machine-code generation and bare-metal development.
</p>
<p align="center">
  <img src="https://img.shields.io/badge/target-x86--64-111111">
  <img src="https://img.shields.io/badge/compiler-AOT-8b0000">
  <img src="https://img.shields.io/badge/status-development-555555">
</p>

⸻

About

MicroC is a custom programming language and compiler built from scratch.

The compiler is designed around a simple idea:

Write low-level code without having to write every part of the toolchain yourself.

MicroC currently targets x86-64 and generates machine code directly.

It does not use an assembly file as an intermediate output.

MicroC source
      │
      ▼
    Lexer
      │
      ▼
    Parser
      │
      ▼
   Codegen
      │
      ▼
Machine code

⸻

Example

A MicroC program is contained inside a head block.

head(asm-x86-64 custom){
    (asmb) {
        cli
        hlt
        pad_boot
        sign_boot
    } (asme)
}

The head block defines the program and its target.

head(asm-x86-64 custom)

       │     │       │
       │     │       └── compiler mode
       │     └────────── target architecture
       └──────────────── program entry

⸻

Inline Assembly

MicroC supports inline x86-64 assembly directly inside the language.

head(asm-x86-64 custom){
    (asmb) {
        cli
        hlt
    } (asme)
}

The assembly block is placed between:

(asmb)
    ...
(asme)

This allows MicroC to operate very close to the hardware while still providing a language and compiler around the assembly.

⸻

Bootloader Support

MicroC includes built-in functionality for generating boot-sector compatible output.

For example:

head(asm-x86-64 custom){
    (asmb) {
        cli
        hlt
        pad_boot
        sign_boot
    } (asme)
}

pad_boot

Pads the generated output to the required boot-sector size.

sign_boot

Adds the x86 boot signature:

55 AA

This means the compiler can handle the repetitive boot-sector requirements automatically.

Conceptually:

MicroC
  │
  ▼
x86-64 machine code
  │
  ▼
padding
  │
  ▼
boot signature
  │
  ▼
boot sector

⸻

Compiler

MicroC currently uses an Ahead-Of-Time (AOT) compilation model.

The source is compiled before execution:

source.mc
    │
    ▼
 MicroC
    │
    ▼
machine code
    │
    ▼
 executable / binary

The code generator writes machine code directly rather than generating assembly and invoking a separate assembler.

⸻

Architecture

The compiler is split into a few core stages.

             MicroC
               │
               ▼
            Lexer
               │
               ▼
            Parser
               │
               ▼
           Codegen
               │
               ▼
        Machine code

Lexer

Converts source text into tokens.

Parser

Processes the token stream and validates the MicroC structure.

Codegen

Translates the parsed representation into native x86-64 machine code.

⸻

Project Structure

MicroC/
├── lexer.c
├── parser.c
├── codegen.c
├── main.c
├── test.mc
└── README.md

File	Purpose
lexer.c	Lexical analysis
parser.c	Parsing MicroC
codegen.c	Native machine-code generation
main.c	Compiler entry point
test.mc	MicroC test program

⸻

Building

Clone the repository:

git clone https://github.com/false-info/MicroC.git
cd MicroC

Build the compiler:

gcc codegen.c lexer.c parser.c main.c -o microc

Then compile a MicroC source file:

./microc test.mc -o output

⸻

Design

MicroC is intentionally being built from the ground up.

The compiler is not designed around producing readable assembly as its final output.

Instead:

MicroC
  ↓
Compiler
  ↓
Machine code

This gives the compiler direct control over the generated instructions and makes it possible to build increasingly low-level software directly with MicroC.

⸻

Current Direction

MicroC is currently focused on:

* Native x86-64 code generation
* AOT compilation
* Inline assembly
* Bare-metal development
* Bootloader development
* Expanding the language itself

The language is still under active development and syntax may change.

⸻

Roadmap

Compiler

* Lexer
* Parser
* x86-64 code generation
* Direct machine-code generation
* Inline assembly
* Boot-sector helpers
* More language features
* Improved compiler diagnostics
* More complete type system
* Standard library

Operating System

MicroC is being developed alongside a custom operating system.

The long-term goal is to use MicroC for increasingly large parts of the OS.

MicroC
  │
  ├── Bootloader
  │
  ├── Kernel
  │
  └── System software

Future

After the operating-system stage:

* JIT compilation
* Runtime code generation
* Self-hosting compiler
* Additional architectures
* Expanded standard library

⸻

Philosophy

MicroC aims to stay small while giving the programmer direct control.

Simple syntax
     +
Native code
     +
Low-level control
     =
MicroC

⸻

Status

MicroC is experimental and actively developed.

The compiler, language syntax and architecture are continuously evolving.

⸻

<p align="center">
  <b>MicroC</b><br>
  Native code. Low-level control. Built from scratch.
</p>
