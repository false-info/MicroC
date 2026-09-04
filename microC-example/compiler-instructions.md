# Building a Small Compiler in MicroC

This guide is for learning compiler construction by writing a tiny compiler in MicroC.

It is **not** a replacement for `compiler.mc`, and it deliberately does not begin by copying the real compiler.

The goal is to understand the machine one gear at a time.

---

# Target

The first compiler understands only expressions like:

```text
12 + 5
```

and eventually emits x86-64 code equivalent to:

```asm
mov rax, 12
add rax, 5
```

That tiny language is enough to learn the complete compiler path.

<table>
<tr>
<td align="center"><b>source</b></td>
<td align="center">→</td>
<td align="center"><b>lexer</b></td>
<td align="center">→</td>
<td align="center"><b>parser</b></td>
<td align="center">→</td>
<td align="center"><b>emitter</b></td>
<td align="center">→</td>
<td align="center"><b>x86-64</b></td>
</tr>
</table>

---

# Stage 0 — Know the input

Start with a fixed source string or file containing:

```text
12 + 5
```

Do not add variables, functions, `if`, strings, or types yet.

Your compiler has only four token kinds:

```text
NUMBER
PLUS
EOF
INVALID
```

---

# Stage 1 — Read one character

The lexer needs one current character.

Conceptually:

```text
source:  1 2   +   5
         ^
       current
```

After `advance()`:

```text
source:  1 2   +   5
           ^
         current
```

Your first helper should have one job:

```text
advance:
    move input position forward
    read the next byte
    store it as current
```

### Checkpoint

Print each byte of the source one at a time.

Do not continue until you understand exactly when the position changes.

---

# Stage 2 — Recognize digits

ASCII digits occupy:

```text
'0' = 48
...
'9' = 57
```

A helper can therefore answer:

```text
is_digit(c)
```

with:

```text
1 if c is between 48 and 57
0 otherwise
```

MicroC shape:

```mc
fn is_digit(I64 c) {
    if (c >= 48) {
        if (c <= 57) {
            return 1
        }
    }

    return 0
}
```

### Test

```text
is_digit(55) → 1
is_digit(43) → 0
```

because:

```text
55 = '7'
43 = '+'
```

---

# Stage 3 — Read an integer

To convert:

```text
"123"
```

into:

```text
123
```

use:

```text
number = number * 10 + digit
```

The digit comes from ASCII:

```text
digit = current - 48
```

Walkthrough:

```text
number = 0

'1' → 0 * 10 + 1   = 1
'2' → 1 * 10 + 2   = 12
'3' → 12 * 10 + 3  = 123
```

Your `read_number()` algorithm:

```text
number = 0

while current is a digit:
    number = number * 10 + (current - 48)
    advance()

return number
```

Important:

> `read_number()` stops **before** the first non-digit.

For:

```text
123+
```

it should return `123` while leaving `current` on `+`.

---

# Stage 4 — Produce tokens

Now build `next_token()`.

Pseudo-code:

```text
skip spaces

if end of input:
    token = EOF

else if current is digit:
    token_value = read_number()
    token = NUMBER

else if current is '+':
    advance()
    token = PLUS

else:
    token = INVALID
```

For:

```text
12 + 5
```

the result should be:

<table>
<tr><th>Token</th><th>Value</th></tr>
<tr><td><code>NUMBER</code></td><td>12</td></tr>
<tr><td><code>PLUS</code></td><td></td></tr>
<tr><td><code>NUMBER</code></td><td>5</td></tr>
<tr><td><code>EOF</code></td><td></td></tr>
</table>

### Stop here and test hard

Try:

```text
1+2
10 + 20
999+1
7
+
12x5
```

A lexer that works only for the happy path will become a parser bug later.

---

# Stage 5 — Parse the first grammar

Your first grammar can be:

```text
expression := NUMBER "+" NUMBER
```

That means the parser expects exactly:

```text
NUMBER
PLUS
NUMBER
EOF
```

Pseudo-code:

```text
parse_expression:

    expect NUMBER
    left = token_value

    expect PLUS

    expect NUMBER
    right = token_value

    expect EOF
```

At first, do not generate code.

Simply calculate:

```text
left + right
```

and print the result.

If:

```text
12 + 5
```

prints:

```text
17
```

your lexer and parser are cooperating.

---

# Stage 6 — Add a real expression grammar

Once the fixed grammar works, use:

```text
expression := term { ("+" | "-") term }
term       := factor { ("*" | "/" | "%") factor }
factor     := NUMBER | "(" expression ")"
```

This is the important structure:

<table>
<tr>
<td></td>
<td align="center"><b>expression</b></td>
<td></td>
</tr>
<tr>
<td align="center">↙</td>
<td></td>
<td align="center">↘</td>
</tr>
<tr>
<td align="center"><b>term</b></td>
<td></td>
<td align="center"><code>+ term</code><br><code>- term</code></td>
</tr>
</table>

and:

<table>
<tr>
<td></td>
<td align="center"><b>term</b></td>
<td></td>
</tr>
<tr>
<td align="center">↙</td>
<td></td>
<td align="center">↘</td>
</tr>
<tr>
<td align="center"><b>factor</b></td>
<td></td>
<td align="center"><code>* factor</code><br><code>/ factor</code></td>
</tr>
</table>

This is what makes:

```text
2 + 3 * 4
```

mean:

```text
2 + (3 * 4)
```

instead of:

```text
(2 + 3) * 4
```

---

# Stage 7 — Stop evaluating, start emitting

Until now the compiler can behave like a calculator.

Now change the destination.

Instead of:

```text
return left + right
```

emit machine instructions.

The code generator needs primitive byte writers:

```text
emit8
emit32
emit64
```

Then instruction helpers:

```text
emit_mov_rax_imm64
emit_add_rax_...
```

Do not begin with fifty x86 instructions.

Start with enough to emit:

```asm
mov rax, 12
```

Then verify the raw bytes using a disassembler.

Only after that add `add`.

---

# Stage 8 — Give generated code a place to live

There are two useful targets.

## Raw `.bin`

Simplest while learning:

```text
machine-code bytes only
```

Compile the compiler itself normally:

```bash
./mcc tiny-compiler.mc -o tiny-compiler
```

Then let the tiny compiler write:

```text
program.bin
```

Raw output is easiest for inspecting exact bytes.

## ELF64

Later add:

```text
ELF header
program header
payload
```

MicroC's current ELF layout begins at:

```text
0x400000
```

with generated payload beginning after the headers.

Do **not** start your learning compiler with a full ELF writer. Get raw machine-code emission correct first.

---

# Stage 9 — Add variables

After expressions work, add:

```text
let x = 5
```

or, if you want the language to resemble MicroC:

```text
I64 x = 5
```

Now you need a symbol table.

A minimal entry contains:

```text
name
stack offset / storage location
```

Conceptually:

| name | location |
|---|---|
| `x` | `-8` |
| `y` | `-16` |

The parser sees an identifier and asks:

```text
which variable is this?
where is it stored?
```

---

# Stage 10 — Add statements

Recommended order:

```text
expression
    ↓
declaration
    ↓
assignment
    ↓
pin / output
    ↓
return
    ↓
if
    ↓
while
    ↓
functions
```

Do not add function calls before basic statements are boring.

---

# Stage 11 — Add control flow

An `if` eventually becomes:

```text
evaluate condition
       │
       ▼
compare
       │
       ▼
jump if false ───────────┐
       │                 │
       ▼                 │
      body               │
       │                 │
       └─────────────────┘
```

A `while` becomes:

```text
loop_start:
    condition
    jump false → loop_end
    body
    jump → loop_start
loop_end:
```

This introduces **patching** because the compiler may emit a jump before it knows the destination address.

Record:

```text
patch position
```

and fill in the displacement later.

---

# Stage 12 — Add functions

Now you need:

```text
function name
function position
parameter count
unresolved calls
```

A call can appear before the compiler has seen the function body.

That gives you the classic compiler problem:

```text
call foo
     │
     └── where is foo?
```

If unknown:

```text
record patch
```

When `foo` is finally parsed:

```text
resolve its pending calls
```

This is one of the places where a single-pass compiler gets interesting.

---

# Stage 13 — Compare with real `compiler.mc`

Only now start reading the real compiler.

Pick one subsystem at a time:

```text
lexer
parser
expression parser
function table
call patching
ELF writer
runtime emitters
inline assembler
```

Do not ask:

> "How does `compiler.mc` work?"

Ask:

> "Where does `next_token` get the next character?"

or:

> "Where is an unresolved function call stored?"

Small questions have traceable answers.

---

# Suggested tiny compiler milestones

| Version | Understands |
|---|---|
| v0 | one integer |
| v1 | `12 + 5` |
| v2 | `+ - * /` |
| v3 | parentheses |
| v4 | variables |
| v5 | assignments |
| v6 | comparisons |
| v7 | `if` |
| v8 | `while` |
| v9 | functions |
| v10 | raw x86-64 output |
| v11 | ELF64 |
| v12 | enough language to compile itself |

Self-hosting is the summit, not the trailhead.

---

# Debugging checklist

If a compiler test fails, identify which stage failed.

```text
wrong characters?
    ↓
reader

wrong token?
    ↓
lexer

right token, wrong structure?
    ↓
parser

right structure, wrong bytes?
    ↓
codegen

right bytes, program crashes?
    ↓
ABI / executable layout / generated machine code
```

Print intermediate state.

For example:

```text
TOKEN NUMBER 12
TOKEN PLUS
TOKEN NUMBER 5
TOKEN EOF
```

A compiler is much easier to debug when every stage can prove what it believes.

---

# Final test

You understand the tiny compiler when you can explain this complete path:

```text
"12 + 5"
    │
    ▼
characters
    │
    ▼
NUMBER(12) PLUS NUMBER(5)
    │
    ▼
expression
    │
    ▼
x86-64 instructions
    │
    ▼
machine-code bytes
    │
    ▼
CPU
```

without opening `compiler.mc`.
