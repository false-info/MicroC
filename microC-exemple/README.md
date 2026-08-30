<div align="center">

# MicroC Examples

### 50 projects, arranged as a progression

`basics` → `memory` → `parsing` → `native code` → `compiler` → `self-hosting`

</div>

---

<table>
<tr>
<td width="20%"><b>01–10</b><br><sub>language basics</sub></td>
<td width="20%"><b>11–20</b><br><sub>algorithms & memory</sub></td>
<td width="20%"><b>21–30</b><br><sub>files & parsing</sub></td>
<td width="20%"><b>31–40</b><br><sub>interpreters & native code</sub></td>
<td width="20%"><b>41–50</b><br><sub>compilers & bootstrap</sub></td>
</tr>
</table>

## Purpose

This directory is a practical MicroC progression.

The first projects are deliberately small. Every group of five raises the difficulty and introduces a different kind of problem. The later projects move into the same territory as the compiler itself.

The point is not to create fifty placeholder files. A project should only become a real `.mc` file when it is actually implemented.

### Rules

- use only syntax and built-ins that exist in MicroC
- keep each finished project as a separate `.mc` file
- mark completed projects in the tables below
- add source to the **Completed projects** section only after the project works
- if a project exposes a missing language capability, improve MicroC first

## Roadmap

### 01 / 10 &nbsp; Foundations

| # | Project | Target | Done |
|---:|---|---|:---:|
| 01 | **Counter** | Count from `0` to `10` and react to the final value. | [x] |
| 02 | **Number checker** | Recognize selected integer values with `if`. | [x] |
| 03 | **Countdown** | Count from `10` down to `0`. | [x] |
| 04 | **ASCII letters** | Print a range of characters with `pin("%c", value)`. | [ ] |
| 05 | **Running sum** | Add every integer from `1` to a chosen limit. | [ ] |


### 02 / 10 &nbsp; Functions

| # | Project | Target | Done |
|---:|---|---|:---:|
| 06 | **Add function** | Return the sum of two parameters. | [ ] |
| 07 | **Maximum** | Return the larger of two values. | [ ] |
| 08 | **Minimum** | Return the smaller of two values. | [ ] |
| 09 | **Small calculator** | Split arithmetic into reusable functions. | [ ] |
| 10 | **Power** | Calculate integer powers with repeated multiplication. | [ ] |


### 03 / 10 &nbsp; Algorithms

| # | Project | Target | Done |
|---:|---|---|:---:|
| 11 | **Manual multiply** | Implement multiplication using addition and loops. | [ ] |
| 12 | **Manual divide** | Implement integer division using subtraction. | [ ] |
| 13 | **Modulo from scratch** | Calculate a remainder without `%`. | [ ] |
| 14 | **Fibonacci** | Generate a Fibonacci sequence. | [ ] |
| 15 | **Prime checker** | Determine whether a positive integer is prime. | [ ] |


### 04 / 10 &nbsp; Memory and strings

| # | Project | Target | Done |
|---:|---|---|:---:|
| 16 | **String walker** | Walk through text one byte at a time. | [ ] |
| 17 | **Own strlen** | Calculate string length without calling `strlen`. | [ ] |
| 18 | **String compare** | Compare two strings byte by byte. | [ ] |
| 19 | **Memory copy** | Copy a block of bytes between memory regions. | [ ] |
| 20 | **Byte buffer** | Build a fixed-size buffer with read and write positions. | [ ] |


### 05 / 10 &nbsp; Files

| # | Project | Target | Done |
|---:|---|---|:---:|
| 21 | **File reader** | Read and print a file one byte at a time. | [ ] |
| 22 | **File copy** | Duplicate a file using MicroC file operations. | [ ] |
| 23 | **Byte counter** | Count file bytes manually. | [ ] |
| 24 | **Character counter** | Count occurrences of one selected byte. | [ ] |
| 25 | **Tiny hex dump** | Display file contents in a byte-oriented format. | [ ] |


### 06 / 10 &nbsp; Parsing

| # | Project | Target | Done |
|---:|---|---|:---:|
| 26 | **Digit parser** | Convert decimal ASCII into an integer. | [ ] |
| 27 | **Integer printer** | Convert an integer into decimal output. | [ ] |
| 28 | **Word scanner** | Split a byte stream into words. | [ ] |
| 29 | **Tiny lexer** | Recognize identifiers, integers and punctuation. | [ ] |
| 30 | **Token inspector** | Classify a complete token stream. | [ ] |


### 07 / 10 &nbsp; Interpreters

| # | Project | Target | Done |
|---:|---|---|:---:|
| 31 | **Expression evaluator** | Evaluate arithmetic with precedence. | [ ] |
| 32 | **Expression parser** | Parse nested expressions explicitly. | [ ] |
| 33 | **Command language** | Implement commands such as `SET`, `ADD` and `PRINT`. | [ ] |
| 34 | **Stack machine** | Execute arithmetic on a software stack. | [ ] |
| 35 | **Bytecode interpreter** | Design and execute a compact bytecode format. | [ ] |


### 08 / 10 &nbsp; Native code

| # | Project | Target | Done |
|---:|---|---|:---:|
| 36 | **Assembler front end** | Parse a small textual instruction language. | [ ] |
| 37 | **x86-64 emitter** | Emit selected x86-64 instructions as bytes. | [ ] |
| 38 | **Machine-code function** | Generate a small callable native function. | [ ] |
| 39 | **Binary patcher** | Read and rewrite selected bytes in a binary. | [ ] |
| 40 | **Minimal ELF64 writer** | Produce a valid ELF64 executable directly. | [ ] |


### 09 / 10 &nbsp; Compiler construction

| # | Project | Target | Done |
|---:|---|---|:---:|
| 41 | **Expression compiler** | Compile arithmetic expressions to x86-64. | [ ] |
| 42 | **Tiny language compiler** | Compile variables, arithmetic and output. | [ ] |
| 43 | **Control-flow compiler** | Emit and backpatch jumps for `if` and `while`. | [ ] |
| 44 | **Function compiler** | Compile definitions, calls, arguments and returns. | [ ] |
| 45 | **Single-pass compiler** | Emit native code while parsing. | [ ] |


### 10 / 10 &nbsp; Self-hosting

| # | Project | Target | Done |
|---:|---|---|:---:|
| 46 | **Raw binary toolchain** | Emit structured raw binaries from MicroC. | [ ] |
| 47 | **Mini MicroC compiler** | Compile a useful subset of real MicroC syntax. | [ ] |
| 48 | **Self-rebuilding compiler** | Build a compiler that can compile programs itself. | [ ] |
| 49 | **Bootstrap chain** | Compare multiple compiler generations. | [ ] |
| 50 | **MicroC toolchain** | Build lexer, parser, x86-64 emitter, ELF64 writer and bootstrap path. | [ ] |

---

## Completed projects

This section stays empty until a project is actually finished.

When one is done, add the source here:

#### Foundation


<details>
<summary><b>01 - Counter</b></summary>

```mc
head(custom) {
    fn main() {
        I64 x = 0
        while (x <= 10) {
            x = x + 1
            if (x == 10) {
                pin("ten\n")
            }
        }
    }
}
```
</details>

<details>
<summary><b>02 - Number-check</b></summary>

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
<summary><b>03 - Countdown</b></summary>

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
<summary><b>04 - ASCII-Leters</b></summary>

```mc
head(custom) {
    fn main() {
        I64 x = 65
        while (x <= 90) {
            pin("%c", x)
            x = x + 1
        }
    }
}
```
</details>

<details>
<summary><b>05 - Running-sum</b></summary>

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

#### Functions


<details>
<summary><b>06 - </b></summary>

```mc

```
</details>

<details>
<summary><b>07 - </b></summary>

```mc

```
</details>

<details>
<summary><b>08 - </b></summary>

```mc

```
</details>

<details>
<summary><b>09 - </b></summary>

```mc

```
</details>

<details>
<summary><b>10 - </b></summary>

```mc

```
</details>

#### 
<details>
<summary><b>11 - </b></summary>

```mc

```
</details>

<details>
<summary><b>12 - </b></summary>

```mc

```
</details>

<details>
<summary><b>13 - </b></summary>

```mc

```
</details>

<details>
<summary><b>14 - </b></summary>

```mc

```
</details>

<details>
<summary><b>15 - </b></summary>

```mc

```
</details>

####


<details>
<summary><b>16 - </b></summary>

```mc

```
</details>


<details>
<summary><b>17 - </b></summary>

```mc

```
</details>

<details>
<summary><b>18 - </b></summary>

```mc

```
</details>

<details>
<summary><b>19 - </b></summary>

```mc

```
</details>


<details>
<summary><b>20 - </b></summary>

```mc

```
</details>

#### 


<details>
<summary><b>21 - </b></summary>

```mc

```
</details>

<details>
<summary><b>22 - </b></summary>

```mc

```
</details>
Keeping unfinished projects out of this section makes the README much easier to scan.

---

## Difficulty

```text
01–05   program structure
06–10   functions
11–15   algorithms
16–20   memory and strings
21–25   files
26–30   parsing
31–35   interpreters
36–40   machine code and executable formats
41–45   compiler construction
46–50   self-hosting
```

By project 20, the work has moved beyond syntax exercises.

By project 30, the focus is parsing.

By project 40, MicroC is generating executable structures and native code.

Projects 46–50 are toolchain work.

---

<div align="center">

<sub>Build the language by using it.</sub>

</div>
