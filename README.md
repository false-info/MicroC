<div align="center">

# MicroC

### A small self-hosted systems language for x86-64

`source.mc` → `native machine code`

<br>

<img src="https://img.shields.io/badge/x86--64-native-111111?style=flat-square" alt="x86-64 native">
<img src="https://img.shields.io/badge/compiler-self--hosted-111111?style=flat-square" alt="self-hosted">
<img src="https://img.shields.io/badge/output-ELF64%20%7C%20raw-111111?style=flat-square" alt="ELF64 and raw output">
<img src="https://img.shields.io/badge/status-experimental-7f1d1d?style=flat-square" alt="experimental">

<br><br>

<sub>No LLVM. No generated assembly. No external linker in the normal compile path.</sub>

</div>

---

<table>
<tr>
<td width="25%">

**Compiler**

Written in MicroC

</td>
<td width="25%">

**Backend**

Direct x86-64 emission

</td>
<td width="25%">

**Outputs**

ELF64 and raw binaries

</td>
<td width="25%">

**Design**

Small, explicit, low-level

</td>
</tr>
</table>

## About

MicroC is an experimental systems programming language and native compiler for x86-64.

The compiler reads `.mc` source and emits machine code directly. There is no required assembly-generation stage and no required linker step in the normal compile path.

```text
 source.mc
    │
    ▼
┌─────────┐
│ MicroC  │
└────┬────┘
     │
     ▼
 x86-64 bytes
   ┌─┴─────────┐
   ▼           ▼
 ELF64      raw .bin
```

The compiler itself is written in MicroC.

MicroC is intentionally narrow in scope. The project is built around the idea that the path from source code to executable bytes should stay short enough to understand.

---

## Quick start

```bash
git clone https://github.com/false-info/MicroC.git
cd MicroC
chmod +x compiler
```

Compile the included hello world:

```bash
./compiler microC-exemple/hello-world.mc -o hello
chmod +x hello
./hello
```

Minimal source:

```mc
head(custom) {
    fn main() {
        pin("hello, world")
    }
}
```

---

## Compiler

```text
compiler <input.mc> -o <output>
```

### ELF64

```bash
./compiler program.mc -o program
```

### Raw binary

```bash
./compiler boot.mc -o boot.bin
```

| Output name | Result |
|---|---|
| `program` | Linux x86-64 ELF executable |
| `program.bin` | Raw byte stream |

---

## Language overview

Every MicroC source file is contained in one `head(...)` block.

```mc
head(custom) {
    ...
}
```

The current language exposes two layers:

| Layer | Purpose |
|---|---|
| `custom` | Functions, variables, expressions and control flow |
| `asm-x86-64` | Integrated x86-64 assembly |

They can be enabled together:

```mc
head(asm-x86-64 custom) {
    ...
}
```

### Variables

```mc
I64 value = 10
I64 address = 0x400000

value = value + 1
```

### Functions

```mc
fn add(I64 a, I64 b) {
    return a + b
}
```

```mc
I64 result = add(10, 20)
```

### Conditions

```mc
if (value == 10) {
    pin("ten")
}
```

### Loops

```mc
while (value < 20) {
    value = value + 1
}
```

### Output

```mc
pin("hello")
pin("%c", 65)
```

---

## Expressions

Examples:

```mc
42
value
add(10, 20)
(a + b) * 2
x >= 10
```

Operator precedence:

| Priority | Operators |
|---:|---|
| 1 | `== != < > <= >=` |
| 2 | `|` |
| 3 | `^` |
| 4 | `&` |
| 5 | `<< >>` |
| 6 | `+ -` |
| 7 | `* / %` |

Parentheses override precedence:

```mc
I64 a = 2 + 3 * 4
I64 b = (2 + 3) * 4
```

---

## Built-ins

### Files

```text
open(path)
open(path, flags)
close(fd)

file_read8(fd)
file_write8(fd, value)

file_seek(fd, offset)
file_size(fd)
```

### Memory

```text
mem_read8(address)
mem_read64(address)

mem_write8(address, value)
mem_write64(address, value)
```

### Strings

```text
strlen(string)
strcmp(a, b)
```

### Process arguments

```text
argc()
argv(index)
```

### Debug output

```text
debug_char(value)
```

---

## Inline x86-64

MicroC contains an integrated x86-64 assembly layer.

```mc
head(asm-x86-64) {
    (asmb) {
        nop
        hlt
    } (asme)
}
```

The current focused instruction set includes:

```text
cli
sti
nop
hlt
ret
syscall
```

Boot helpers:

```text
pad_boot
sign_boot
```

Assembly blocks are parsed by MicroC itself rather than passed to an external assembler.

---

## Raw output and boot sectors

A filename ending in `.bin` selects raw output:

```bash
./compiler boot.mc -o boot.bin
```

A minimal boot-sector-shaped output can use:

```mc
head(asm-x86-64) {
    (asmb) {
        cli
        hlt

        pad_boot
        sign_boot
    } (asme)
}
```

`pad_boot` pads the binary to byte 510.

`sign_boot` emits:

```text
55 AA
```

These helpers format a 512-byte BIOS boot sector. They do not change the CPU mode in which the generated instructions execute.

---

## Compiler architecture

```text
.mc source
    │
    ▼
lexer / parser
    │
    ▼
single-pass compilation
    │
    ▼
x86-64 code emitter
    │
    ├────────► ELF64
    │
    └────────► raw binary
```

The normal path does not require:

- LLVM
- generated assembly
- object files
- an external linker

That is deliberate. MicroC is meant to remain understandable as a complete system, not only as a language surface.

---

## Self-hosting

The compiler source is:

```text
compiler.mc
```

The bootstrap direction is:

```text
existing compiler
       │
       ▼
 compiler.mc
       │
       ▼
new compiler
```

Self-hosting is part of the core design of the project, not a separate experiment.

---

## Repository layout

```text
MicroC/
├── compiler
├── compiler.mc
├── README.md
├── boot-strap/
└── microC-exemple/
    ├── README.md
    ├── hello-world.mc
    ├── boot-exemple.mc
    └── while-if-number-pointer.mc
```

---

## Examples

`microC-exemple/` contains small reference programs and a 50-project progression.

The progression starts with control flow and functions, then moves into memory, files, parsing, virtual machines, native code generation, ELF64, compiler construction and self-hosting.

See:

```text
microC-exemple/README.md
```

---

## Project principles

MicroC currently follows a few simple rules:

- keep the language small
- keep generated code close to the machine
- avoid unnecessary compiler layers
- add features because real programs need them
- keep self-hosting practical
- do not document syntax that the compiler does not implement

---

## Status

MicroC is experimental and evolving.

Syntax, built-ins, compiler internals and generated code may change while the language develops.

<div align="center">

<br>

**MicroC**

<sub>Source in. Machine code out.</sub>

</div>
