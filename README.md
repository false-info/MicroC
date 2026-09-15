# MicroC

**A small self-hosted systems language with direct x86 code generation.**

MicroC is built to keep the path from source code to machine code short. The compiler is written in MicroC, emits native x86 code directly, and does not use LLVM.

The project is aimed at systems programming, compiler work, low-level experiments and eventually a daily-use operating system written largely in MicroC.

## Current syntax

The repository now uses the current top-level syntax.

```mc
head(custom)

fn main() {
    pin("Hello from MicroC!\n")
    return 0
}
```

Feature heads are separate top-level statements:

```mc
head(custom)
head(math)
head(time)

fn main() {
    F64 value = math_sqrt(144.0)
    pin("sqrt = %F64\n", value)

    sleep_ms(100)
    return 0
}
```

Old code that wraps the whole source file inside:

```mc
head(custom) {
    ...
}
```

is legacy syntax and should not be used for new MicroC programs.

## Build and run

Compile a hosted program:

```bash
./mcc program.mc -o program
./program
```

Self-host the compiler:

```bash
./mcc compiler.mc -o mcc-new
chmod +x mcc-new
./mcc-new compiler.mc -o mcc-stage2
```

The main compiler source is [`compiler.mc`](compiler.mc).

## Core language

MicroC supports typed variables, functions, expressions, branches and loops.

```mc
head(custom)

fn add(I64 a, I64 b) {
    return a + b
}

fn main() {
    I64 x = 20
    I64 y = 22
    I64 result = add(x, y)

    if (result == 42) {
        pin("correct\n")
    }
    else {
        pin("wrong\n")
    }

    return 0
}
```

Current core types include:

- `I8`, `I16`, `I32`, `I64`
- `U8`, `U16`, `U32`, `U64`
- lowercase aliases such as `i64` and `u64`
- `usize`
- `Ptr`
- `F64`
- `Bool` / `bool`

## Official heads

MicroC currently recognizes these feature heads:

| Head | Purpose |
| --- | --- |
| `custom` | normal MicroC functions and language syntax |
| `memory` | memory and managed allocation helpers |
| `input` | hosted input |
| `file` | file I/O |
| `network` / `networking` | networking |
| `time` | clocks and sleeping |
| `math` | floating-point math |
| `graphics` | software graphics and frame presentation |
| `audio` | audio feature namespace |
| `thread` | threading feature namespace |
| `crypto` | crypto feature namespace |
| `process` | process and argument helpers |
| `game` | game feature namespace |
| `safe` | safe-mode restrictions |
| `system` | CPU and low-level system operations |

Only enable the heads a file needs.

## Memory

The `memory` head provides raw and managed memory tools.

```mc
head(custom)
head(memory)

fn main() {
    I64 buffer = safe_alloc(16)

    safe_write64(buffer, 0, 1234)
    I64 value = safe_read64(buffer, 0)

    pin("value = %I64\n", value)

    safe_free(buffer)
    return 0
}
```

Managed helpers include allocation, reallocation, freeing and bounds-checked reads and writes.

## Math

The current math API includes:

- `math_abs`
- `math_sqrt`
- `math_min`
- `math_max`
- `math_clamp`
- `math_lerp`
- `math_hypot`
- `math_inv_sqrt`
- `math_pi`
- `math_tau`
- `math_e`
- `math_sin`
- `math_cos`
- `math_atan2`
- degree/radian conversion

Example:

```mc
head(custom)
head(math)

fn main() {
    F64 x = 3.0
    F64 y = 4.0
    F64 distance = math_hypot(x, y)

    pin("distance = %F64\n", distance)
    return 0
}
```

## Time

Hosted time helpers include Unix time, monotonic clocks and sleeping.

```mc
head(custom)
head(time)

fn main() {
    I64 before = time_monotonic_ms()

    sleep_ms(250)

    I64 after = time_monotonic_ms()
    pin("elapsed = %I64 ms\n", after - before)
    return 0
}
```

## Graphics

MicroC has a software framebuffer graphics API with:

- `gfx_open`
- `gfx_close`
- `gfx_buffer`
- `gfx_width`
- `gfx_height`
- `gfx_pitch`
- `gfx_clear`
- `gfx_pixel`
- `gfx_line`
- `gfx_rect_fill`
- `gfx_bind_target`
- `gfx_present`
- `gfx_rgb`
- `gfx_rgba`
- `gfx_save_bmp`

A live animation can be written directly in MicroC:

```mc
head(custom)
head(graphics)
head(time)

fn main() {
    gfx_open(640, 360)

    I64 running = 1
    I64 x = 0

    while (running != 0) {
        gfx_clear(gfx_rgb(0, 0, 0))
        gfx_rect_fill(x, 160, 30, 30, gfx_rgb(255, 70, 20))

        if (gfx_present() < 0) {
            running = 0
        }

        x = x + 2

        if (x > 640) {
            x = 0
        }

        sleep_ms(16)
    }

    gfx_close()
    return 0
}
```

The current hosted Linux window backend presents frames through `ffplay`, so FFmpeg is required for the live graphics window.

## Integrated x86

MicroC has integrated x86 modes for low-level work:

```mc
head(asm-x86-16)
```

```mc
head(asm-x86-32)
```

```mc
head(asm-x86-64)
```

The normal language layer is enabled with `head(custom)`.

## Compiler path

```text
source.mc
   |
   v
 lexer
   |
   v
 parser
   |
   v
 x86 emitter
   |
   v
native output
```

The compiler keeps parsing and code generation close together. The normal path does not generate an intermediate assembly file and does not use LLVM.

## Repository layout

```text
MicroC/
├── compiler.mc
├── mcc
├── bootstrap.zig
├── README.md
├── compiler-+-OS-address-helper.md
├── microC-example/
│   ├── README.md
│   ├── compiler-instructions.md
│   ├── os-instructions.md
│   ├── 01-basics/
│   ├── 02-functions/
│   ├── 03-algorithms/
│   ├── 04-compiler/
│   └── 05-kernel/
├── kernel-mc/
└── graphics-slop/
```

## Learn MicroC

The [`microC-example`](microC-example/) directory contains 50 examples using the current syntax.

Start with:

```bash
./mcc microC-example/01-basics/01-hello.mc -o hello
./hello
```

Then continue in numeric order.

The path is:

```text
01-10  basics
11-20  functions
21-30  algorithms
31-40  compiler concepts
41-50  kernel concepts
```

## Project status

MicroC is experimental and changes quickly. The current compiler source and current examples are the best reference for the language as it exists now.