# Building a Small Compiler in MicroC

This guide is meant to be coded along with.

The goal is not to copy `compiler.mc`. The goal is to build a much smaller compiler first, understand every part, and only then compare it with the real MicroC compiler.

The first language will understand:

```text
12 + 5
```

Then it grows into:

```text
2 + 3 * 4
(2 + 3) * 4
```

and later:

```text
I64 x = 10
x = x + 1
```

---

# 0. The pipeline

<table>
<tr>
<td align="center"><b>source</b></td>
<td align="center">→</td>
<td align="center"><b>reader</b></td>
<td align="center">→</td>
<td align="center"><b>lexer</b></td>
<td align="center">→</td>
<td align="center"><b>parser</b></td>
<td align="center">→</td>
<td align="center"><b>codegen</b></td>
<td align="center">→</td>
<td align="center"><b>x86-64 bytes</b></td>
</tr>
</table>

Start small enough that you can explain every arrow.

---

# 1. Read source bytes

A compiler begins by reading source one byte at a time.

A first test program can simply print every byte in a file:

```mc
head(custom) {
    fn main() {
        I64 fd = open("test.mc", 0)
        I64 size = file_size(fd)
        I64 i = 0

        file_seek(fd, 0)

        while (i < size) {
            I64 ch = file_read8(fd)
            pin("%c", ch)
            i = i + 1
        }

        close(fd)
    }
}
```

If `test.mc` contains:

```text
12 + 5
```

your program should print:

```text
12 + 5
```

That sounds trivial, but this is the first compiler component: **source input**.

---

# 2. Learn ASCII

The lexer sees bytes, not abstract characters.

Important values:

```text
'0' = 48
'1' = 49
...
'9' = 57

'+' = 43
'-' = 45
'*' = 42
'/' = 47

' ' = 32
'\n' = 10
```

A digit checker:

```mc
head(custom) {
    fn is_digit(I64 c) {
        if (c >= 48) {
            if (c <= 57) {
                return 1
            }
        }

        return 0
    }

    fn main() {
        pin("%I64\n", is_digit(55))
        pin("%I64\n", is_digit(43))
    }
}
```

Expected:

```text
1
0
```

because:

```text
55 = '7'
43 = '+'
```

---

# 3. Convert one ASCII digit to a number

ASCII digit → numeric value:

```mc
fn digit_value(I64 c) {
    return c - 48
}
```

Examples:

```text
'0' = 48 → 0
'5' = 53 → 5
'9' = 57 → 9
```

Test:

```mc
head(custom) {
    fn digit_value(I64 c) {
        return c - 48
    }

    fn main() {
        pin("%I64\n", digit_value(53))
    }
}
```

Expected:

```text
5
```

---

# 4. Build a number from many digits

The rule:

```text
number = number * 10 + digit
```

MicroC:

```mc
head(custom) {
    fn push_digit(I64 number, I64 ascii_digit) {
        return number * 10 + (ascii_digit - 48)
    }

    fn main() {
        I64 n = 0

        n = push_digit(n, 49)
        n = push_digit(n, 50)
        n = push_digit(n, 51)

        pin("%I64\n", n)
    }
}
```

Expected:

```text
123
```

This is the heart of `read_number()`.

---

# 5. A tiny lexer without hidden state

Before writing a full lexer, practice on known bytes.

```mc
head(custom) {
    fn token_kind(I64 c) {
        if (c >= 48) {
            if (c <= 57) {
                return 1
            }
        }

        if (c == 43) {
            return 2
        }

        if (c == 32) {
            return 3
        }

        return 0
    }

    fn main() {
        pin("%I64\n", token_kind(49))
        pin("%I64\n", token_kind(43))
        pin("%I64\n", token_kind(32))
    }
}
```

Use a simple token numbering scheme while learning:

```text
0 = INVALID
1 = NUMBER
2 = PLUS
3 = SPACE
4 = EOF
```

Do not worry about elegant enums yet.

---

# 6. Skip whitespace

A helper:

```mc
fn is_space(I64 c) {
    if (c == 32) {
        return 1
    }

    if (c == 10) {
        return 1
    }

    if (c == 9) {
        return 1
    }

    return 0
}
```

Test:

```mc
head(custom) {
    fn is_space(I64 c) {
        if (c == 32) {
            return 1
        }

        if (c == 10) {
            return 1
        }

        if (c == 9) {
            return 1
        }

        return 0
    }

    fn main() {
        pin("%I64\n", is_space(32))
        pin("%I64\n", is_space(43))
    }
}
```

---

# 7. First token stream

For learning, you can print token names directly instead of storing complicated token objects.

```mc
head(custom) {
    fn is_digit(I64 c) {
        if (c >= 48) {
            if (c <= 57) {
                return 1
            }
        }

        return 0
    }

    fn main() {
        I64 fd = open("test.mc", 0)
        I64 size = file_size(fd)
        I64 i = 0

        file_seek(fd, 0)

        while (i < size) {
            I64 c = file_read8(fd)

            if (is_digit(c) == 1) {
                pin("NUMBER_CHAR %c\n", c)
            }
            else {
                if (c == 43) {
                    pin("PLUS\n")
                }
                else {
                    if (c == 32) {
                        pin("SPACE\n")
                    }
                    else {
                        pin("INVALID %I64\n", c)
                    }
                }
            }

            i = i + 1
        }

        pin("EOF\n")
        close(fd)
    }
}
```

For:

```text
12 + 5
```

you should see something like:

```text
NUMBER_CHAR 1
NUMBER_CHAR 2
SPACE
PLUS
SPACE
NUMBER_CHAR 5
EOF
```

Not a real lexer yet, but now you can see what the scanner is doing.

---

# 8. Read a complete number from a file

Now combine digits.

A simple version can use file position explicitly:

```mc
head(custom) {
    fn is_digit(I64 c) {
        if (c >= 48) {
            if (c <= 57) {
                return 1
            }
        }

        return 0
    }

    fn read_number_at(I64 fd, I64 start, I64 size) {
        I64 pos = start
        I64 number = 0

        file_seek(fd, pos)

        while (pos < size) {
            I64 c = file_read8(fd)

            if (is_digit(c) == 0) {
                return number
            }

            number = number * 10 + (c - 48)
            pos = pos + 1
        }

        return number
    }

    fn main() {
        I64 fd = open("test.mc", 0)
        I64 size = file_size(fd)

        I64 n = read_number_at(fd, 0, size)

        pin("%I64\n", n)

        close(fd)
    }
}
```

If the file starts with:

```text
123 + 5
```

this should print:

```text
123
```

Later you will also need to know **where the number ended**. That is where lexer state becomes useful.

---

# 9. Lexer state

A real lexer needs state such as:

```text
input fd
input size
position
current character
token kind
token value
```

The conceptual state:

```text
position = 0
current  = '1'
token    = NONE
value    = 0
```

A MicroC learning compiler can keep this state in a small fixed scratch region, or pass it through helper functions. If you use fixed memory, document every address and keep it away from your program/code regions.

The important idea is the API:

```text
advance()
skip_space()
read_number()
next_token()
```

---

# 10. What `next_token()` should do

Pseudo-MicroC:

```mc
fn next_token() {
    skip_space()

    if (at_end() == 1) {
        set_token(4)
        return 4
    }

    if (is_digit(current()) == 1) {
        I64 n = read_number()
        set_token_value(n)
        set_token(1)
        return 1
    }

    if (current() == 43) {
        advance()
        set_token(2)
        return 2
    }

    set_token(0)
    return 0
}
```

Token meanings:

```text
0 INVALID
1 NUMBER
2 PLUS
4 EOF
```

Goal:

```text
12 + 5
```

becomes:

```text
NUMBER 12
PLUS
NUMBER 5
EOF
```

---

# 11. First parser

Your first grammar:

```text
expression := NUMBER PLUS NUMBER
```

Parser logic:

```mc
fn parse_expression() {
    next_token()

    if (token_kind() != 1) {
        pin("expected number\n")
        return 0
    }

    I64 left = token_value()

    next_token()

    if (token_kind() != 2) {
        pin("expected +\n")
        return 0
    }

    next_token()

    if (token_kind() != 1) {
        pin("expected number\n")
        return 0
    }

    I64 right = token_value()

    return left + right
}
```

This is not code generation yet.

It is a parser acting as a calculator.

For:

```text
12 + 5
```

it returns:

```text
17
```

---

# 12. Add `-`

New token:

```text
3 = MINUS
```

Lexer idea:

```mc
if (current() == 45) {
    advance()
    set_token(3)
    return 3
}
```

Parser:

```mc
fn parse_expression() {
    next_token()

    I64 left = token_value()

    next_token()

    I64 op = token_kind()

    next_token()

    I64 right = token_value()

    if (op == 2) {
        return left + right
    }

    if (op == 3) {
        return left - right
    }

    return 0
}
```

Now:

```text
12 + 5 → 17
12 - 5 → 7
```

---

# 13. Expression / term / factor

Once `+` and `-` work, add real precedence.

Grammar:

```text
expression := term { ("+" | "-") term }
term       := factor { ("*" | "/" | "%") factor }
factor     := NUMBER | "(" expression ")"
```

MicroC-shaped parser:

```mc
fn parse_expression() {
    I64 value = parse_term()

    while (token_kind() == TOKEN_PLUS()) {
        next_token()
        value = value + parse_term()
    }

    return value
}
```

Then extend for minus:

```mc
fn parse_expression() {
    I64 value = parse_term()

    while (token_kind() == TOKEN_PLUS() || token_kind() == TOKEN_MINUS()) {
        I64 op = token_kind()
        next_token()

        I64 right = parse_term()

        if (op == TOKEN_PLUS()) {
            value = value + right
        }
        else {
            value = value - right
        }
    }

    return value
}
```

If your MicroC build does not yet support `||`, write the equivalent with nested `if` logic.

Term:

```mc
fn parse_term() {
    I64 value = parse_factor()

    while (token_kind() == TOKEN_STAR()) {
        next_token()
        value = value * parse_factor()
    }

    return value
}
```

Factor:

```mc
fn parse_factor() {
    if (token_kind() == TOKEN_NUMBER()) {
        I64 value = token_value()
        next_token()
        return value
    }

    pin("expected factor\n")
    return 0
}
```

---

# 14. Add parentheses

Tokens:

```text
LPAREN
RPAREN
```

Factor becomes:

```mc
fn parse_factor() {
    if (token_kind() == TOKEN_NUMBER()) {
        I64 value = token_value()
        next_token()
        return value
    }

    if (token_kind() == TOKEN_LPAREN()) {
        next_token()

        I64 value = parse_expression()

        if (token_kind() != TOKEN_RPAREN()) {
            pin("expected )\n")
            return 0
        }

        next_token()
        return value
    }

    pin("expected factor\n")
    return 0
}
```

Now:

```text
2 + 3 * 4
```

→ `14`

and:

```text
(2 + 3) * 4
```

→ `20`

---

# 15. Start code generation

Stop returning the result.

Start writing bytes.

A byte writer:

```mc
fn emit8(I64 fd, I64 value) {
    file_write8(fd, value & 255)
    return 0
}
```

A little-endian 32-bit writer:

```mc
fn emit32(I64 fd, I64 value) {
    emit8(fd, value)
    emit8(fd, value >> 8)
    emit8(fd, value >> 16)
    emit8(fd, value >> 24)
    return 0
}
```

A little-endian 64-bit writer:

```mc
fn emit64(I64 fd, I64 value) {
    emit8(fd, value)
    emit8(fd, value >> 8)
    emit8(fd, value >> 16)
    emit8(fd, value >> 24)
    emit8(fd, value >> 32)
    emit8(fd, value >> 40)
    emit8(fd, value >> 48)
    emit8(fd, value >> 56)
    return 0
}
```

This is real compiler infrastructure.

---

# 16. Emit `mov rax, imm64`

x86-64 encoding:

```text
48 B8 imm64
```

MicroC:

```mc
fn emit_mov_rax_imm64(I64 fd, I64 value) {
    emit8(fd, 0x48)
    emit8(fd, 0xB8)
    emit64(fd, value)
    return 0
}
```

To emit:

```asm
mov rax, 12
```

call:

```mc
emit_mov_rax_imm64(out_fd, 12)
```

---

# 17. Emit a tiny raw program

A minimal generated Linux function also needs a way to exit or return somewhere valid.

For learning, first generate code and inspect it with a disassembler instead of executing it immediately.

Example generator:

```mc
head(custom) {
    fn emit8(I64 fd, I64 value) {
        file_write8(fd, value & 255)
        return 0
    }

    fn emit64(I64 fd, I64 value) {
        emit8(fd, value)
        emit8(fd, value >> 8)
        emit8(fd, value >> 16)
        emit8(fd, value >> 24)
        emit8(fd, value >> 32)
        emit8(fd, value >> 40)
        emit8(fd, value >> 48)
        emit8(fd, value >> 56)
        return 0
    }

    fn emit_mov_rax_imm64(I64 fd, I64 value) {
        emit8(fd, 0x48)
        emit8(fd, 0xB8)
        emit64(fd, value)
        return 0
    }

    fn main() {
        I64 out = open("out.bin", 577)

        emit_mov_rax_imm64(out, 12)

        close(out)
    }
}
```

If your `open` flags differ, use the output-file pattern already supported by your current MicroC build.

---

# 18. Add arithmetic emission

One easy strategy for a learning compiler:

```text
left expression → RAX
save left
right expression → RAX
combine
```

Later you can use stack operations or another register.

Conceptually:

```text
2 + 3
```

becomes:

```asm
mov rax, 2
push rax
mov rax, 3
pop rcx
add rax, rcx
```

You do not need a register allocator yet.

---

# 19. Add variables

Source:

```mc
I64 x = 5
```

You need a symbol table.

Minimal entry:

```text
name
stack offset
```

Example:

```text
x → -8
y → -16
```

Parser flow:

```text
type
 ↓
identifier
 ↓
=
 ↓
expression
 ↓
allocate stack slot
 ↓
emit store
```

A simple MicroC helper shape:

```mc
fn add_variable(I64 name_ptr, I64 offset) {
    // store name + offset in your variable table
    return 0
}
```

Lookup:

```mc
fn find_variable(I64 name_ptr) {
    // linear search is fine for the first compiler
    return 0
}
```

Do not optimize the symbol table yet.

---

# 20. Add assignments

Source:

```mc
x = x + 1
```

Parser:

```text
identifier
    ↓
is next token '=' ?
    ↓
parse expression
    ↓
find variable storage
    ↓
emit store
```

---

# 21. Add `if`

Source:

```mc
if (x == 10) {
    ...
}
```

Generated structure:

```text
condition
   ↓
comparison
   ↓
jump-if-false ????
   ↓
body
   ↓
end:
```

The `????` is unknown when you first emit the jump.

So record:

```text
patch_position
```

After the body:

```text
end_position = current_output_position
```

Then patch the jump displacement.

---

# 22. Add `while`

Source:

```mc
while (x < 10) {
    x = x + 1
}
```

Structure:

```text
loop_start:
    condition
    jump false → loop_end
    body
    jump → loop_start
loop_end:
```

Now you have both forward and backward jumps.

This is the right time to learn relative displacement math.

---

# 23. Add functions

Minimal function metadata:

```text
name
output position
parameter count
```

Conceptual table:

```text
add   → 0x120
main  → 0x180
```

If a call appears before the function:

```mc
foo()
```

record:

```text
call patch position
function name
```

Later:

```text
foo definition found
        ↓
patch all calls to foo
```

---

# 24. Add ELF64 last

Do raw bytes first.

Then add:

```text
ELF64 header
program header
generated payload
```

Your current MicroC executable layout uses:

```text
0x400000  ELF base
0x400040  program header
0x400078  generated payload
```

A learning compiler does not need every ELF feature.

One loadable segment is enough for the first version.

---

# 25. Compare with real `compiler.mc`

Only after your tiny compiler has:

```text
lexer
parser
expressions
emission
patching
functions
```

start tracing the real compiler.

Good questions:

```text
Where is current character stored?
Where does next_token advance input?
Where are function entries stored?
How are unresolved calls patched?
Where is ELF entry calculated?
Where are strings appended?
```

Bad first question:

```text
How does the whole compiler work?
```

That question is too big to hold in your head at once.

---

# Final compiler challenge

Build this sequence without copying the real compiler:

```text
v1  12 + 5
v2  12 - 5
v3  2 + 3 * 4
v4  (2 + 3) * 4
v5  variables
v6  assignment
v7  comparisons
v8  if
v9  while
v10 functions
v11 raw x86-64
v12 ELF64
```

At that point `compiler.mc` stops looking like a wall and starts looking like a collection of familiar machines.
