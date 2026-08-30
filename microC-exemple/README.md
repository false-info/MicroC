# MicroC examples

This directory is where I use MicroC instead of only working on the compiler.

The projects start tiny, then move into functions, algorithms, memory, files, parsers, native code and eventually compiler work. The empty files are intentional: they are future projects, not fake finished examples.

```text
01-05   foundations
06-10   functions
11-15   algorithms
16-20   memory and strings
21-25   files
26-30   parsing
31-35   interpreters
36-40   native code
41-45   compiler construction
46-50   self-hosting
```

## Layout

```text
microC-exemple/
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

A file marked **source** below currently contains MicroC code. A file marked **planned** exists as an empty project slot.

## 01 / 10 - Foundations

| # | File | Goal | State |
|---:|---|---|---|
| 01 | `01-ASCII-leters.mc` | Walk through ASCII `A` to `Z` and print each value. | **source** |
| 02 | `02-countdown.mc` | Count down and react when the counter reaches zero. | **source** |
| 03 | `03-counter.mc` | Count upward and detect the final value. | **source** |
| 04 | `04-number-check.mc` | Match selected numbers with `if`. | **source** |
| 05 | `05-running-sum.mc` | Add a sequence of integers. | **source** |

## 02 / 10 - Functions

| # | File | Goal | State |
|---:|---|---|---|
| 06 | `06-add-function.mc` | Call a function that adds values. | **source** |
| 07 | `07-maximum-number.mc` | Return the larger of two values. | **source** |
| 08 | `08-minimum-number.mc` | Return the smaller of two values. | **source** |
| 09 | `09-small-calculator.mc` | Split arithmetic into reusable functions. | planned |
| 10 | `10-power-function.mc` | Calculate integer powers. | planned |

## 03 / 10 - Algorithms

| # | File | Goal | State |
|---:|---|---|---|
| 11 | `11-manual-multiply.mc` | Multiply using addition and loops. | planned |
| 12 | `12-manual-divide.mc` | Divide using repeated subtraction. | planned |
| 13 | `13-modulo-from-scratch.mc` | Calculate a remainder without `%`. | planned |
| 14 | `14-fibonacci.mc` | Generate Fibonacci values. | planned |
| 15 | `15-prime-checker.mc` | Test whether an integer is prime. | planned |

## 04 / 10 - Memory and strings

| # | File | Goal | State |
|---:|---|---|---|
| 16 | `16-string-walker.mc` | Walk through a string one byte at a time. | **source** |
| 17 | `17-strlen.mc` | Implement string length manually. | planned |
| 18 | `18-string-compare.mc` | Compare strings byte by byte. | planned |
| 19 | `19-memory-copy.mc` | Copy a memory region. | planned |
| 20 | `20-tiny-byte-buffer.mc` | Build a small fixed byte buffer. | planned |

## 05 / 10 - Files

| # | File | Goal | State |
|---:|---|---|---|
| 21 | `21-file-reader.mc` | Read a file one byte at a time. | planned |
| 22 | `22-file-copy.mc` | Copy one file to another. | planned |
| 23 | `23-byte-counter.mc` | Count bytes manually. | planned |
| 24 | `24-character-counter.mc` | Count occurrences of a selected byte. | planned |
| 25 | `25-tiny-hex-dump.mc` | Print a byte-oriented file dump. | planned |

## 06 / 10 - Parsing

| # | File | Goal | State |
|---:|---|---|---|
| 26 | `26-digit-parser.mc` | Convert decimal ASCII into an integer. | planned |
| 27 | `27-integer-printer.mc` | Convert an integer into decimal text. | planned |
| 28 | `28-word-scanner.mc` | Split input into words. | planned |
| 29 | `29-tiny-lexer.mc` | Recognize identifiers, numbers and punctuation. | planned |
| 30 | `30-token-stream-inspector.mc` | Inspect and classify a token stream. | planned |

## 07 / 10 - Interpreters

| # | File | Goal | State |
|---:|---|---|---|
| 31 | `31-expression-evaluator.mc` | Evaluate arithmetic expressions. | planned |
| 32 | `32-expression-parser.mc` | Parse nested expressions. | planned |
| 33 | `33-tiny-command-language.mc` | Implement a tiny command language. | planned |
| 34 | `34-stack-machine.mc` | Execute arithmetic on a software stack. | planned |
| 35 | `35-bytecode-interpreter.mc` | Execute a compact bytecode format. | planned |

## 08 / 10 - Native code

| # | File | Goal | State |
|---:|---|---|---|
| 36 | `36-tiny-assembler-front-end.mc` | Parse a small instruction language. | planned |
| 37 | `37-x86-64-code-emitter.mc` | Emit x86-64 instruction bytes. | planned |
| 38 | `38-machine-code-function.mc` | Generate a callable native function. | planned |
| 39 | `39-binary-patcher.mc` | Locate and rewrite bytes in a binary. | planned |
| 40 | `40-minimal-elf64-writer.mc` | Write a minimal ELF64 executable. | planned |

## 09 / 10 - Compiler construction

| # | File | Goal | State |
|---:|---|---|---|
| 41 | `41-expression-compiler.mc` | Compile expressions into x86-64. | planned |
| 42 | `42-tiny-language-compiler.mc` | Compile a small language. | planned |
| 43 | `43-control-flow-compiler.mc` | Compile `if` and `while` with patched jumps. | planned |
| 44 | `44-function-compiler.mc` | Compile functions and calls. | planned |
| 45 | `45-single-pass-compiler.mc` | Emit native code while parsing. | planned |

## 10 / 10 - Self-hosting

| # | File | Goal | State |
|---:|---|---|---|
| 46 | `46-raw-binary-toolchain.mc` | Emit structured raw binaries. | planned |
| 47 | `47-mini-microc-compiler.mc` | Compile a useful MicroC subset. | planned |
| 48 | `48-self-rebuilding-compiler.mc` | Build a compiler that can rebuild itself. | planned |
| 49 | `49-compiler-bootstrap-chain.mc` | Compare multiple compiler generations. | planned |
| 50 | `50-microc-toolchain-from-scratch.mc` | Put lexer, parser, emitter and ELF writer together. | planned |

# Current source

These blocks mirror the source files that currently contain code in the repository.

<details>
<summary><b>01 - ASCII letters</b></summary>

```mc
head(custom) {
    fn main() {
        I64 x = 65
        while (x <= 90) {
            pin("character: %c\nposition: %I64\n", x, x)
            x = x + 1
        }
    }
}
```

</details>

<details>
<summary><b>02 - Countdown</b></summary>

```mc
head(custom) {
    fn main() {
        I64 x = 10
        while (x >= 0) {
            x = x - 1
            if (x == 0) {
                pin("zero\n")
            }
        }
    }
}
```

</details>

<details>
<summary><b>03 - Counter</b></summary>

```mc
head(custom) {
    fn main() {
        I64 x = 0
        while (x <= 10) {
            x = x + 1
            if (x == 10) {
                pin("done\n")
            }
        }
    }
}
```

</details>

<details>
<summary><b>04 - Number check</b></summary>

```mc
head(custom) {
    fn main() {
        I64 x = 0
        while (x <= 20) {
            x = x + 1
            if (x == 5) {
                pin("five\n")
            }
            if (x == 10) {
                pin("ten\n")
            }
            if (x == 20) {
                pin("twenty\n")
            }
        }
    }
}
```

</details>

<details>
<summary><b>05 - Running sum</b></summary>

```mc
head(custom) {
    fn main() {
        I64 x = 0
        I64 sum = 0
        while (x <= 10) {
            sum = sum + x
            x = x + 1
        }
        pin("sum: %I64\n", sum)
    }
}
```

</details>

<details>
<summary><b>06 - Add function</b></summary>

```mc
head(custom) {
    fn add(I64 x, I64 y) {
        return x + y
    }
    fn main() {
        I64 result = add(7 + 5)
        pin("result: %I64\n", result)
    }
}
```

</details>

<details>
<summary><b>07 - Maximum number</b></summary>

```mc
head(custom) {
    fn biggest(I64 x, I64 y) {
        if (x >= y) {
            return x
        }
        return y
    }
    fn main() {
        I64 result = biggest(32, 1)
        pin("the bigger one is: %I64", result)
    }
}
```

</details>

<details>
<summary><b>08 - Minimum number</b></summary>

```mc
head(custom) {
    fn smallest(I64 a, I64 a) {
        if (a <= b) {
            return a
        }
        return b
    }
    fn main() {
        I64 result = smallest(9859285082058292, 9492389428498249829)
        pin("the smallest is:%I64\n", result)
    }
}
```

</details>

<details>
<summary><b>16 - String walker</b></summary>

```mc
head(custom) {
    fn main() {
        U64 str = "MicroC"
        I64 position = 0
        U8 character = mem_read8(str + position)
        while (position <= 5) {
            pin("character: %c\n", character)
            position = position + 1
            character = mem_read8(str + position)
        }
    }
}
```

</details>

## How I use this folder

The point of the progression is to make the language prove itself.

If a project is awkward because MicroC is missing something important, I would rather improve the language and then come back than hide the problem behind a special case. By the later levels the examples stop being syntax exercises and start becoming small pieces of a real toolchain.
