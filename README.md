# MicroC

<p align="center">
  <b>A small self-hosted systems language that compiles directly to native x86-64.</b>
</p>

MicroC is built around a simple idea: the complete path from source code to CPU instructions should stay understandable.

<p align="center">
  <img src="assets/compiler_pipeline.svg" width="900" alt="MicroC compilation pipeline">
</p>

## Why MicroC

MicroC does not use LLVM, does not generate an assembly file in the normal compile path, and does not depend on an external linker to produce its normal native output.

The compiler is written in MicroC itself and emits x86-64 bytes directly.

## Quick start

```bash
git clone https://github.com/false-info/MicroC.git
cd MicroC
chmod +x mcc
./mcc program.mc -o program
./program
```

```mc
head(custom) {
    fn main() {
        pin("hello from MicroC\n")
    }
}
```

## Language structure

<p align="center">
  <img src="assets/syntax_structure.svg" width="920" alt="MicroC source structure">
</p>

A MicroC program starts with a `head(...)` block. `custom` enables the normal language layer and `asm-x86-64` enables integrated assembly.

```mc
head(asm-x86-64 custom) {
    fn main() {
        pin("MicroC\n")
    }
}
```

## Expressions

MicroC keeps operator precedence while parsing expressions.

<p align="center">
  <img src="assets/expression_grammar.svg" width="900" alt="MicroC expression grammar">
</p>

For example:

```mc
I64 a = 2 + 3 * 4
I64 b = (2 + 3) * 4
```

## Compiler architecture

The compiler closely connects parsing and code generation instead of building a large full-program AST first.

<p align="center">
  <img src="assets/single_pass.svg" width="790" alt="MicroC single pass compilation">
</p>

Conceptually:

```text
source bytes → lexer → parser → x86-64 emitter → output
```

## Output

MicroC currently emits:

- Linux x86-64 ELF64 executables
- raw `.bin` output

```bash
./mcc program.mc -o program
./mcc boot.mc -o boot.bin
```

## Self-hosting

`compiler.mc` is the MicroC compiler source.

<p align="center">
  <img src="assets/self_hosting.svg" width="930" alt="MicroC self hosting chain">
</p>

A normal rebuild:

```bash
./mcc compiler.mc -o mcc-new
chmod +x mcc-new
./mcc-new compiler.mc -o mcc-second
```

The second compile is the interesting one: a compiler produced by MicroC is compiling the MicroC compiler again.

## Inline x86-64

```mc
head(asm-x86-64) {
    (asmb) {
        cli
        hlt
    } (asme)
}
```

The assembly block is parsed by MicroC itself rather than being passed to NASM.

## Project status

MicroC is experimental. The language and compiler are being developed together, with a focus on keeping the implementation small, explicit and understandable.
