# MicroC

MicroC is a small systems language and native x86-64 compiler. The compiler is written in MicroC and emits machine code directly.

There is no LLVM backend, no generated assembly file and no linker in the normal compile path.

```text
source.mc
   |
   v
  mcc
   |
   +------------------+
   |                  |
   v                  v
ELF64               raw .bin
```

The project is experimental. The language is still changing while I use it to build larger programs and find out what is actually missing.

## Why I made it

I wanted a language where I could understand the complete path from source code to the bytes the CPU runs.

C was the obvious starting point because it stays close to the machine, but I did not want the compiler project to stay dependent on C forever. x86-64 assembly pushed the design in the other direction: keep things explicit, keep the compiler small, and do as little hidden work as possible. Small self-hosted languages such as HolyC were also part of the inspiration. The interesting part to me is not copying their syntax, but the idea that the language can be simple enough to build itself.

MicroC started with a bootstrap compiler and then moved to `compiler.mc`. The current compiler can compile MicroC source directly to native x86-64 output.

## Quick start

The repository includes the compiler binary as `mcc`.

```bash
git clone https://github.com/false-info/MicroC.git
cd MicroC
chmod +x mcc
```

Compile a program:

```bash
./mcc program.mc -o program
chmod +x program
./program
```

A minimal program:

```mc
head(custom) {
    fn main() {
        pin("hello from MicroC\n")
    }
}
```

Raw output is selected by giving the output a `.bin` extension:

```bash
./mcc boot.mc -o boot.bin
```

If you want `mcc` available from anywhere on Linux, one simple option is:

```bash
sudo ln -sf "$PWD/mcc" /usr/local/bin/mcc
```

## Language shape

Every source file has one `head(...)` block. Features are enabled in the head itself.

```mc
head(custom) {
    ...
}
```

```mc
head(asm-x86-64) {
    ...
}
```

```mc
head(asm-x86-64 custom) {
    ...
}
```

`custom` enables the normal language layer. `asm-x86-64` enables the integrated assembly block.

## Syntax tree

This is the current shape of the parser, not a wish-list grammar.

```text
source
└── head
    ├── "head"
    ├── "("
    ├── feature-list
    │   ├── custom
    │   └── asm-x86-64
    ├── ")"
    ├── "{"
    ├── top-level*
    │   ├── function
    │   │   ├── "fn"
    │   │   ├── identifier
    │   │   ├── parameter-list
    │   │   └── block
    │   │       └── statement*
    │   │           ├── variable-declaration
    │   │           ├── assignment
    │   │           ├── function-call
    │   │           ├── if
    │   │           ├── while
    │   │           ├── return
    │   │           ├── pin
    │   │           └── inline-asm
    │   └── inline-asm
    └── "}"
```

A more exact grammar:

```text
program         := "head" "(" feature+ ")" "{" top-level* "}"

feature         := "custom"
                 | "asm-x86-64"

top-level       := function
                 | asm-block

function        := "fn" identifier "(" parameters? ")" block
parameters      := parameter ("," parameter)*
parameter       := type identifier

block           := "{" statement* "}"

statement       := declaration
                 | assignment
                 | call
                 | if-statement
                 | while-statement
                 | return-statement
                 | pin-statement
                 | asm-block

declaration     := type identifier "=" expression
assignment      := identifier "=" expression

if-statement    := "if" "(" expression ")" block
while-statement := "while" "(" expression ")" block
return-statement:= "return" expression?

call            := identifier "(" arguments? ")"
arguments       := expression ("," expression)*

pin-statement   := "pin" "(" string ("," expression)* ")"

asm-block       := "(" "asmb" ")" "{" asm-instruction* "}" "(" "asme" ")"

expression      := primary (binary-op expression)*
primary         := integer
                 | float
                 | string
                 | "true"
                 | "false"
                 | identifier
                 | call
                 | "(" expression ")"
                 | "+" primary
                 | "-" primary
```

There are no semicolons.

Identifiers start with a letter or `_`. The lexer also accepts `-` after the first character, which means subtraction is safest written with spaces:

```mc
I64 result = a - b
```

rather than:

```text
a-b
```

## Types

MicroC currently has fixed-width integer types, one floating-point type and a boolean type.

| Type | Meaning |
|---|---|
| `I8` | signed 8-bit integer |
| `I16` | signed 16-bit integer |
| `I32` | signed 32-bit integer |
| `I64` | signed 64-bit integer |
| `U8` | unsigned 8-bit integer |
| `U16` | unsigned 16-bit integer |
| `U32` | unsigned 32-bit integer |
| `U64` | unsigned 64-bit integer |
| `F64` | 64-bit floating-point value |
| `Bool` | boolean value |

Variables are declared with an initial value:

```mc
I64 count = 0
U64 address = 0x400000
F64 value = 2.5
Bool ready = true
```

## Functions

Functions use `fn`. Parameters are typed and the current calling path supports up to six arguments.

```mc
fn add(I64 a, I64 b) {
    return a + b
}

fn main() {
    I64 result = add(10, 20)
    pin("%I64\n", result)
}
```

`main` is the program entry function for normal `custom` programs.

A `return` inside `main` becomes the process exit value. In another function it returns to the caller.

## Control flow

```mc
if (value >= 10) {
    pin("large\n")
}
```

```mc
while (value < 10) {
    value = value + 1
}
```

## Operators

The current binary operators are:

```text
==  !=  <  >  <=  >=
|   ^   &
<<  >>
+   -
*   /   %
```

Current precedence, low to high:

| Precedence | Operators |
|---:|---|
| 1 | `== != < > <= >=` |
| 2 | `|` |
| 3 | `^` |
| 4 | `&` |
| 5 | `<< >>` |
| 6 | `+ -` |
| 7 | `* / %` |

Parentheses can be used normally:

```mc
I64 a = 2 + 3 * 4
I64 b = (2 + 3) * 4
```

## Literals

Decimal integer:

```mc
I64 n = 123
```

Hex integer:

```mc
U64 address = 0x400000
```

Floating point:

```mc
F64 value = 12.5
```

Strings support `\n`, `\r` and `\t` escapes.

```mc
U64 text = "MicroC\n"
```

## `pin`

`pin` is MicroC's formatted output statement.

```mc
pin("hello\n")
pin("value: %I64\n", value)
pin("char: %c\n", 65)
```

Supported formats:

| Format | Output |
|---|---|
| `%c` | character |
| `%s` | zero-terminated string |
| `%p` | pointer, prefixed with `0x` |
| `%X64` | hexadecimal 64-bit value |
| `%%` | literal `%` |
| `%I8` | signed 8-bit integer |
| `%I16` | signed 16-bit integer |
| `%I32` | signed 32-bit integer |
| `%I64` | signed 64-bit integer |
| `%U8` | unsigned 8-bit integer |
| `%U16` | unsigned 16-bit integer |
| `%U32` | unsigned 32-bit integer |
| `%U64` | unsigned 64-bit integer |
| `%F64` | floating-point value |
| `%B` | boolean |

## Built-ins

These are implemented directly by the compiler/runtime path.

### `open(path)` / `open(path, flags)`

Opens a file and returns its file descriptor.

```mc
I64 fd = open("data.bin", 0)
```

### `close(fd)`

Closes an open file descriptor.

```mc
close(fd)
```

### `file_read8(fd)`

Reads one byte from a file.

```mc
U8 byte = file_read8(fd)
```

### `file_write8(fd, value)`

Writes the low byte of `value` to a file.

```mc
file_write8(fd, 65)
```

### `file_size(fd)`

Returns the file size. The current implementation uses seeking internally, so code that needs a specific file position should seek explicitly afterwards.

```mc
I64 size = file_size(fd)
file_seek(fd, 0)
```

### `file_seek(fd, offset)`

Moves the file position to `offset`.

```mc
file_seek(fd, 0)
```

### `mem_read8(address)`

Reads one byte from an address.

```mc
U8 value = mem_read8(address)
```

### `mem_write8(address, value)`

Writes one byte to an address.

```mc
mem_write8(address, 0xFF)
```

### `mem_read64(address)`

Reads a 64-bit value from an address.

```mc
U64 value = mem_read64(address)
```

### `mem_write64(address, value)`

Writes a 64-bit value to an address.

```mc
mem_write64(address, value)
```

### `strlen(string)`

Returns the number of bytes before the zero terminator.

```mc
I64 length = strlen(text)
```

### `strcmp(a, b)`

Compares two zero-terminated strings. `0` means equal.

```mc
if (strcmp(a, b) == 0) {
    pin("same\n")
}
```

### `argc()`

Returns the process argument count.

```mc
I64 count = argc()
```

### `argv(index)`

Returns a pointer to one process argument.

```mc
U64 first = argv(1)
```

### `debug_char(value)`

Writes a single byte to standard output. It is useful when debugging very small generated programs where formatted output would just get in the way.

```mc
debug_char(65)
```

## Inline x86-64

Assembly is written inside an `asm-x86-64` head feature and an `(asmb)` / `(asme)` block.

```mc
head(asm-x86-64) {
    (asmb) {
        cli
        hlt
    } (asme)
}
```

Currently recognized instructions/helpers:

```text
cli
sti
nop
hlt
ret
syscall
pad_boot
sign_boot
```

`pad_boot` pads raw output to byte 510. `sign_boot` writes `55 AA` and finishes a 512-byte BIOS boot sector.

The assembly block is parsed by MicroC itself. It is not passed to NASM or another external assembler.

## Compiler structure

`compiler.mc` contains the lexer, parser, code emitter, ELF writer and the small runtime emitters used by generated programs.

The rough compile path is:

```text
input bytes
   |
   v
read_char
   |
   v
lexer
   |
   v
token stream
   |
   v
parser --------------+
   |                  |
   | emits while      |
   | parsing          |
   v                  |
x86-64 bytes          |
   |                  |
   +---- patch calls -+
   |
   +---- append strings
   |
   +---- patch ELF fields
   v
output file
```

There is no full AST in the normal compile path. Code is emitted while the source is being parsed, with small tables used for things such as functions, unresolved calls, variables and string data.

## ELF64 and raw output

Without a `.bin` suffix, `mcc` writes a small Linux x86-64 ELF executable.

```bash
./mcc program.mc -o program
```

With `.bin`, it writes the emitted bytes as a raw stream.

```bash
./mcc boot.mc -o boot.bin
```

## Self-hosting

The compiler source is `compiler.mc`.

A normal rebuild looks like this:

```bash
./mcc compiler.mc -o mcc-new
chmod +x mcc-new
./mcc-new compiler.mc -o mcc-second
```

That second command is the important part: the compiler produced by MicroC is itself able to compile MicroC source.

## Repository

```text
MicroC/
├── README.md
├── compiler.mc
├── mcc
└── microC-exemple/
    ├── README.md
    ├── level-01-foundations/
    ├── level-02-functions/
    ├── level-03-algorithms/
    ├── level-04-memory/
    ├── level-05-files/
    ├── level-06-parsing/
    ├── level-07-interpreters/
    ├── level-08-native-code/
    ├── level-09-compilers/
    └── level-10-self-hosting/
```

The examples directory is both a set of small programs and a roadmap for testing the language with progressively harder projects.


## MicroC next to other languages

This is the comparison I usually have in mind when I think about MicroC.

The important distinction is not just syntax. It is how far the source code is from the CPU, how much optimization happens on the way, and how much control the programmer keeps.

| Language | Execution model | Runtime ceiling | Ease | Control |
|---|---|---:|---:|---:|
| x86-64 assembly | native machine instructions | extremely high | hard | maximum |
| C | compiled native code | extremely high | medium | very high |
| MicroC | direct native x86-64 emission | high | medium-small | very high |
| HolyC | compiled native x86-64 | high | medium | high |
| Python / CPython | bytecode interpreter | much lower for tight CPU loops | easiest | low |

This is a rough engineering comparison, not a benchmark result.

For raw CPU-bound code, a reasonable mental model is:

```text
hand-written x86-64 ASM
        ≈
optimized C with GCC/Clang
        >
current MicroC / HolyC
        >>
CPython for tight interpreted loops
```

The middle two are deliberately not ordered. Both produce native code, but compiler quality and the exact workload matter more than the language name.

MicroC already removes a lot of overhead by going straight to native x86-64. What it does **not** currently have is the decades of optimization work inside GCC and Clang. That means a simple MicroC loop can be very close to the machine, while a larger C program compiled with `-O2` or `-O3` may still get better register allocation, constant folding, instruction selection and loop optimization.

So the goal is not to claim that MicroC magically beats C. The goal is that the path is short:

```text
MicroC source
     |
     v
 parser + emitter
     |
     v
 x86-64 bytes
```

### The same idea in five languages

A tiny sum function makes the difference in style pretty obvious.

#### MicroC

```mc
head(custom) {
    fn sum_to(I64 limit) {
        I64 i = 1
        I64 total = 0

        while (i <= limit) {
            total = total + i
            i = i + 1
        }

        return total
    }

    fn main() {
        I64 result = sum_to(10)
        pin("sum: %I64\n", result)
    }
}
```

No semicolons, no headers and no separate linker step in the normal MicroC path.

#### C

```c
#include <stdio.h>

long long sum_to(long long limit) {
    long long i = 1;
    long long total = 0;

    while (i <= limit) {
        total += i;
        i++;
    }

    return total;
}

int main(void) {
    printf("sum: %lld\n", sum_to(10));
    return 0;
}
```

C is still one of the strongest baselines for systems programming because optimizing compilers can turn small code like this into extremely efficient machine code.

#### HolyC

```c
I64 SumTo(I64 limit)
{
    I64 i = 1;
    I64 total = 0;

    while (i <= limit) {
        total += i;
        i++;
    }

    return total;
}

"sum: %d\n", SumTo(10);
```

HolyC is interesting to me because it keeps a very direct, interactive relationship with native code. It is much closer to C and MicroC than to an interpreted language.

#### Python

```python
def sum_to(limit):
    i = 1
    total = 0

    while i <= limit:
        total += i
        i += 1

    return total

print("sum:", sum_to(10))
```

Python wins hard on convenience. For normal scripting that often matters more than raw loop speed.

For a tight loop like this, CPython has to execute interpreter machinery around the operations, so native C, MicroC, HolyC or assembly normally have a much higher performance ceiling.

#### x86-64 assembly

The core loop can collapse into something close to this:

```asm
xor rax, rax
mov rcx, 1

.loop:
    add rax, rcx
    inc rcx
    cmp rcx, 10
    jle .loop
```

Here there is almost nothing between the programmer and the CPU. That is also why assembly gets painful quickly: every register, instruction and calling-convention detail becomes your problem.

### Which one is easiest?

It depends on what "easy" means.

```text
Fastest to write ordinary programs:
Python

Easiest native low-level code:
C / MicroC / HolyC, depending on what you are building

Most mature systems ecosystem:
C

Smallest path from MicroC source to emitted machine code:
MicroC

Maximum manual control:
x86-64 assembly
```

My personal design target for MicroC sits between C and assembly.

I want code to stay short enough to write quickly, but I also want it to be obvious that an integer eventually becomes a register, a function call eventually becomes a `call`, and an executable is just bytes with a format around them.

### Performance ceiling vs compiler intelligence

Native code does not automatically mean equally fast code.

Consider:

```text
              source language
                    |
                    v
              compiler decisions
                    |
          +---------+---------+
          |                   |
          v                   v
   good instruction      poor instruction
     selection              selection
          |                   |
          +---------+---------+
                    |
                    v
                  CPU
```

Assembly gives the programmer control over those decisions.

C gives them mostly to a very mature optimizer.

MicroC currently makes much simpler decisions and keeps the generated code easier to trace back to the source.

That is a trade I am making on purpose for now. As MicroC grows, optimization can be added without turning the compiler into a black box.

### Rough comparison

| Property | ASM | C | MicroC | HolyC | Python |
|---|:---:|:---:|:---:|:---:|:---:|
| Native x86-64 execution | yes | yes | yes | yes | no, not normally in CPython |
| Direct hardware control | excellent | excellent | excellent | strong | limited |
| Optimizing compiler maturity | manual | excellent | early | relatively simple | not the main model |
| Easy to read | low | medium | high for low-level code | medium-high | very high |
| Easy to write quickly | low | medium | high | high | very high |
| Good for OS/compiler work | excellent | excellent | target use | yes | mostly tooling |
| External assembler needed in normal MicroC-style path | n/a | compiler-dependent | no | implementation-dependent | n/a |

The interesting part for MicroC is not winning every column. It is trying to keep **native output, a tiny language and a compiler small enough to understand** in the same project.


## Current direction

The rules I try to keep are simple:

- keep the language small enough to understand
- emit native code directly
- avoid compiler layers that do not buy anything useful
- add syntax when a real program needs it
- keep self-hosting working
- keep the source readable enough that the complete compiler can still be followed

MicroC is not trying to replace every systems language. It is a project for learning how far a small language can go when the compiler, executable format and machine-code output are all part of the same codebase.
