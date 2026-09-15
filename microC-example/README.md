# MicroC Examples

50 progressive MicroC examples using the current MicroC syntax.

The examples start with basic syntax and gradually move toward algorithms, compiler internals and kernel concepts.

The README contains the reference implementation for every exercise. The actual `.mc` files can be written separately while learning.

## Current syntax

Modern MicroC code uses top-level heads:

```mc
head(custom)

fn main() {
    pin("Hello\n")
    return 0
}
```

When another feature is required:

```mc
head(custom)
head(memory)
```

Do not use the old wrapped syntax:

```text
head(custom) {
    ...
}
```

## Learning path

```text
01-10  Basics
        ↓
11-20  Functions
        ↓
21-30  Algorithms
        ↓
31-40  Compiler internals
        ↓
41-50  Kernel concepts
```

# 01 - Basics

<details>
<summary><strong>01 - hello.mc</strong></summary>

### Goal

Learn the basic program structure and print text.

### Code

```mc
head(custom)

fn main() {
    pin("Hello from MicroC!\n")
    return 0
}
```

</details>

<details>
<summary><strong>02 - variable.mc</strong></summary>

### Goal

Create and use a typed variable.

### Code

```mc
head(custom)

fn main() {
    I64 x = 42

    pin("x = %I64\n", x)

    return 0
}
```

</details>

<details>
<summary><strong>03 - arithmetic.mc</strong></summary>

### Goal

Use arithmetic operators.

### Code

```mc
head(custom)

fn main() {
    I64 a = 20
    I64 b = 5

    I64 add = a + b
    I64 sub = a - b
    I64 mul = a * b
    I64 div = a / b

    pin("add = %I64\n", add)
    pin("sub = %I64\n", sub)
    pin("mul = %I64\n", mul)
    pin("div = %I64\n", div)

    return 0
}
```

</details>

<details>
<summary><strong>04 - compare.mc</strong></summary>

### Goal

Compare integer values.

### Code

```mc
head(custom)

fn main() {
    I64 x = 10

    if (x > 5) {
        pin("x > 5\n")
    }

    if (x < 20) {
        pin("x < 20\n")
    }

    if (x == 10) {
        pin("x == 10\n")
    }

    return 0
}
```

</details>

<details>
<summary><strong>05 - if.mc</strong></summary>

### Goal

Execute code only when a condition is true.

### Code

```mc
head(custom)

fn main() {
    I64 temperature = 30

    if (temperature >= 25) {
        pin("It is warm\n")
    }

    return 0
}
```

</details>

<details>
<summary><strong>06 - if-else.mc</strong></summary>

### Goal

Choose between two code paths.

### Code

```mc
head(custom)

fn main() {
    I64 x = 7

    if (x >= 10) {
        pin("large\n")
    }
    else {
        pin("small\n")
    }

    return 0
}
```

</details>

<details>
<summary><strong>07 - counter.mc</strong></summary>

### Goal

Learn `while` loops and counters.

### Code

```mc
head(custom)

fn main() {
    I64 i = 0

    while (i < 10) {
        pin("%I64\n", i)
        i = i + 1
    }

    return 0
}
```

</details>

<details>
<summary><strong>08 - countdown.mc</strong></summary>

### Goal

Count downward.

### Code

```mc
head(custom)

fn main() {
    I64 i = 10

    while (i > 0) {
        pin("%I64\n", i)
        i = i - 1
    }

    pin("done\n")

    return 0
}
```

</details>

<details>
<summary><strong>09 - even.mc</strong></summary>

### Goal

Use modulo to detect even and odd numbers.

### Code

```mc
head(custom)

fn main() {
    I64 i = 1

    while (i <= 10) {
        if ((i % 2) == 0) {
            pin("%I64 even\n", i)
        }
        else {
            pin("%I64 odd\n", i)
        }

        i = i + 1
    }

    return 0
}
```

</details>

<details>
<summary><strong>10 - fizz-like.mc</strong></summary>

### Goal

Combine loops, modulo and nested conditions.

### Code

```mc
head(custom)

fn main() {
    I64 i = 1

    while (i <= 15) {
        if ((i % 15) == 0) {
            pin("both\n")
        }
        else {
            if ((i % 3) == 0) {
                pin("three\n")
            }
            else {
                if ((i % 5) == 0) {
                    pin("five\n")
                }
                else {
                    pin("%I64\n", i)
                }
            }
        }

        i = i + 1
    }

    return 0
}
```

</details>

# 02 - Functions

<details>
<summary><strong>11 - first-function.mc</strong></summary>

### Goal

Create and call your first function.

### Code

```mc
head(custom)

fn hello() {
    pin("Hello from a function\n")
    return 0
}

fn main() {
    hello()
    return 0
}
```

</details>

<details>
<summary><strong>12 - function-argument.mc</strong></summary>

### Goal

Pass an argument into a function.

### Code

```mc
head(custom)

fn show_number(I64 number) {
    pin("number = %I64\n", number)
    return 0
}

fn main() {
    show_number(42)
    return 0
}
```

</details>

<details>
<summary><strong>13 - two-arguments.mc</strong></summary>

### Goal

Use multiple function arguments.

### Code

```mc
head(custom)

fn add(I64 a, I64 b) {
    return a + b
}

fn main() {
    I64 result = add(12, 30)

    pin("result = %I64\n", result)

    return 0
}
```

</details>

<details>
<summary><strong>14 - global-state.mc</strong></summary>

### Goal

Learn how multiple functions can work with shared state.

### Code

```mc
head(custom)
head(memory)

fn set_state(I64 state, I64 value) {
    safe_write64(state, 0, value)
    return 0
}

fn get_state(I64 state) {
    return safe_read64(state, 0)
}

fn main() {
    I64 state = safe_alloc(8)

    set_state(state, 123)

    I64 value = get_state(state)

    pin("state = %I64\n", value)

    safe_free(state)

    return 0
}
```

</details>

<details>
<summary><strong>15 - counter-function.mc</strong></summary>

### Goal

Move loop logic into a function.

### Code

```mc
head(custom)

fn count_to(I64 maximum) {
    I64 i = 0

    while (i <= maximum) {
        pin("%I64\n", i)
        i = i + 1
    }

    return 0
}

fn main() {
    count_to(10)
    return 0
}
```

</details>

<details>
<summary><strong>16 - character-values.mc</strong></summary>

### Goal

Understand that characters are numeric values.

### Code

```mc
head(custom)

fn main() {
    I64 a = 65
    I64 b = 66
    I64 c = 67

    pin("%c\n", a)
    pin("%c\n", b)
    pin("%c\n", c)

    return 0
}
```

</details>

<details>
<summary><strong>17 - is-digit.mc</strong></summary>

### Goal

Detect ASCII digits.

### Code

```mc
head(custom)

fn is_digit(I64 c) {
    if (c >= 48) {
        if (c <= 57) {
            return 1
        }
    }

    return 0
}

fn main() {
    pin("5 = %I64\n", is_digit(53))
    pin("A = %I64\n", is_digit(65))

    return 0
}
```

</details>

<details>
<summary><strong>18 - is-letter.mc</strong></summary>

### Goal

Detect ASCII letters.

### Code

```mc
head(custom)

fn is_letter(I64 c) {
    if (c >= 65) {
        if (c <= 90) {
            return 1
        }
    }

    if (c >= 97) {
        if (c <= 122) {
            return 1
        }
    }

    return 0
}

fn main() {
    pin("A = %I64\n", is_letter(65))
    pin("z = %I64\n", is_letter(122))
    pin("7 = %I64\n", is_letter(55))

    return 0
}
```

</details>

<details>
<summary><strong>19 - is-whitespace.mc</strong></summary>

### Goal

Recognize spaces, tabs and newlines.

### Code

```mc
head(custom)

fn is_whitespace(I64 c) {
    if (c == 32) {
        return 1
    }

    if (c == 9) {
        return 1
    }

    if (c == 10) {
        return 1
    }

    if (c == 13) {
        return 1
    }

    return 0
}

fn main() {
    pin("space = %I64\n", is_whitespace(32))
    pin("A = %I64\n", is_whitespace(65))

    return 0
}
```

</details>

<details>
<summary><strong>20 - dispatch.mc</strong></summary>

### Goal

Dispatch different behavior based on a value.

### Code

```mc
head(custom)

fn action_one() {
    pin("action one\n")
    return 0
}

fn action_two() {
    pin("action two\n")
    return 0
}

fn dispatch(I64 action) {
    if (action == 1) {
        action_one()
        return 1
    }

    if (action == 2) {
        action_two()
        return 1
    }

    pin("unknown action\n")
    return 0
}

fn main() {
    dispatch(1)
    dispatch(2)
    dispatch(99)

    return 0
}
```

</details>

# 03 - Algorithms

<details>
<summary><strong>21 - digit-to-number.mc</strong></summary>

### Goal

Convert an ASCII digit into its numeric value.

### Code

```mc
head(custom)

fn digit_to_number(I64 c) {
    return c - 48
}

fn main() {
    I64 value = digit_to_number(55)

    pin("7 becomes %I64\n", value)

    return 0
}
```

</details>

<details>
<summary><strong>22 - parse-number.mc</strong></summary>

### Goal

Convert a string containing decimal digits into an integer.

### Code

```mc
head(custom)
head(memory)

fn parse_number(I64 text) {
    I64 value = 0
    I64 i = 0
    I64 length = strlen(text)

    while (i < length) {
        I64 c = mem_read8(text + i)

        value = value * 10
        value = value + c - 48

        i = i + 1
    }

    return value
}

fn main() {
    I64 value = parse_number("583")

    pin("value = %I64\n", value)

    return 0
}
```

</details>

<details>
<summary><strong>23 - scan-until.mc</strong></summary>

### Goal

Scan through input until a target character is found.

### Code

```mc
head(custom)
head(memory)

fn scan_until(I64 text, I64 target) {
    I64 i = 0
    I64 length = strlen(text)

    while (i < length) {
        I64 c = mem_read8(text + i)

        if (c == target) {
            return i
        }

        i = i + 1
    }

    return 0 - 1
}

fn main() {
    I64 position = scan_until("hello:world", 58)

    pin("':' at %I64\n", position)

    return 0
}
```

</details>

<details>
<summary><strong>24 - skip-whitespace.mc</strong></summary>

### Goal

Find the first non-whitespace character.

### Code

```mc
head(custom)
head(memory)

fn whitespace(I64 c) {
    if (c == 32) {
        return 1
    }

    if (c == 9) {
        return 1
    }

    if (c == 10) {
        return 1
    }

    return 0
}

fn skip_whitespace(I64 text) {
    I64 i = 0
    I64 length = strlen(text)
    I64 done = 0

    while (done == 0) {
        if (i >= length) {
            done = 1
        }
        else {
            I64 c = mem_read8(text + i)

            if (whitespace(c) == 0) {
                done = 1
            }
            else {
                i = i + 1
            }
        }
    }

    return i
}

fn main() {
    I64 position = skip_whitespace("   hello")

    pin("first token starts at %I64\n", position)

    return 0
}
```

</details>

<details>
<summary><strong>25 - find-character.mc</strong></summary>

### Goal

Implement a simple linear search.

### Code

```mc
head(custom)
head(memory)

fn find_character(I64 text, I64 target) {
    I64 i = 0
    I64 length = strlen(text)

    while (i < length) {
        if (mem_read8(text + i) == target) {
            return i
        }

        i = i + 1
    }

    return 0 - 1
}

fn main() {
    I64 index = find_character("MicroC", 67)

    pin("C index = %I64\n", index)

    return 0
}
```

</details>

<details>
<summary><strong>26 - copy-bytes.mc</strong></summary>

### Goal

Understand the idea behind `memcpy`.

### Code

```mc
head(custom)
head(memory)

fn copy_bytes(I64 destination, I64 source, I64 count) {
    I64 i = 0

    while (i < count) {
        I64 value = safe_read8(source, i)

        safe_write8(destination, i, value)

        i = i + 1
    }

    return 0
}

fn main() {
    I64 source = safe_alloc(4)
    I64 destination = safe_alloc(4)

    safe_write8(source, 0, 10)
    safe_write8(source, 1, 20)
    safe_write8(source, 2, 30)
    safe_write8(source, 3, 40)

    copy_bytes(destination, source, 4)

    pin("%I64\n", safe_read8(destination, 0))
    pin("%I64\n", safe_read8(destination, 1))
    pin("%I64\n", safe_read8(destination, 2))
    pin("%I64\n", safe_read8(destination, 3))

    safe_free(source)
    safe_free(destination)

    return 0
}
```

</details>

<details>
<summary><strong>27 - fill-bytes.mc</strong></summary>

### Goal

Understand the idea behind `memset`.

### Code

```mc
head(custom)
head(memory)

fn fill_bytes(I64 memory, I64 count, I64 value) {
    I64 i = 0

    while (i < count) {
        safe_write8(memory, i, value)
        i = i + 1
    }

    return 0
}

fn main() {
    I64 buffer = safe_alloc(8)

    fill_bytes(buffer, 8, 65)

    I64 i = 0

    while (i < 8) {
        pin("%c", safe_read8(buffer, i))
        i = i + 1
    }

    pin("\n")

    safe_free(buffer)

    return 0
}
```

</details>

<details>
<summary><strong>28 - state-machine.mc</strong></summary>

### Goal

Build a simple state machine.

### Code

```mc
head(custom)

fn main() {
    I64 state = 0
    I64 running = 1

    while (running != 0) {
        if (state == 0) {
            pin("START\n")
            state = 1
        }
        else {
            if (state == 1) {
                pin("READ\n")
                state = 2
            }
            else {
                if (state == 2) {
                    pin("DONE\n")
                    running = 0
                }
            }
        }
    }

    return 0
}
```

</details>

<details>
<summary><strong>29 - command-parser.mc</strong></summary>

### Goal

Recognize simple commands.

### Code

```mc
head(custom)

fn parse_command(I64 command) {
    if (strcmp(command, "run") == 0) {
        pin("running\n")
        return 1
    }

    if (strcmp(command, "stop") == 0) {
        pin("stopping\n")
        return 2
    }

    if (strcmp(command, "help") == 0) {
        pin("commands: run stop help\n")
        return 3
    }

    pin("unknown command\n")

    return 0
}

fn main() {
    parse_command("run")
    parse_command("help")
    parse_command("stop")

    return 0
}
```

</details>

<details>
<summary><strong>30 - mini-tokenizer.mc</strong></summary>

### Goal

Recognize simple token categories.

### Code

```mc
head(custom)
head(memory)

fn is_digit(I64 c) {
    if (c >= 48) {
        if (c <= 57) {
            return 1
        }
    }

    return 0
}

fn is_letter(I64 c) {
    if (c >= 65) {
        if (c <= 90) {
            return 1
        }
    }

    if (c >= 97) {
        if (c <= 122) {
            return 1
        }
    }

    return 0
}

fn main() {
    I64 source = "x = 42"
    I64 i = 0
    I64 length = strlen(source)

    while (i < length) {
        I64 c = mem_read8(source + i)

        if (is_letter(c) != 0) {
            pin("%c : identifier\n", c)
        }
        else {
            if (is_digit(c) != 0) {
                pin("%c : number\n", c)
            }
            else {
                if (c == 61) {
                    pin("= : operator\n")
                }
            }
        }

        i = i + 1
    }

    return 0
}
```

</details>

# 04 - Compiler Internals

<details>
<summary><strong>31 - next-char.mc</strong></summary>

### Goal

Read source code one character at a time.

### Code

```mc
head(custom)
head(memory)

fn next_char(I64 source, I64 position) {
    return mem_read8(source + position)
}

fn main() {
    I64 source = "MicroC"

    I64 position = 0

    while (position < strlen(source)) {
        I64 c = next_char(source, position)

        pin("%c\n", c)

        position = position + 1
    }

    return 0
}
```

</details>

<details>
<summary><strong>32 - peek-char.mc</strong></summary>

### Goal

Look ahead without changing the current source position.

### Code

```mc
head(custom)
head(memory)

fn current_char(I64 source, I64 position) {
    return mem_read8(source + position)
}

fn peek_char(I64 source, I64 position) {
    return mem_read8(source + position + 1)
}

fn main() {
    I64 source = "abc"
    I64 position = 0

    pin("current = %c\n", current_char(source, position))
    pin("peek = %c\n", peek_char(source, position))

    return 0
}
```

</details>

<details>
<summary><strong>33 - read-number-token.mc</strong></summary>

### Goal

Read a numeric token from source code.

### Code

```mc
head(custom)
head(memory)

fn is_digit(I64 c) {
    if (c >= 48) {
        if (c <= 57) {
            return 1
        }
    }

    return 0
}

fn read_number(I64 source) {
    I64 value = 0
    I64 position = 0
    I64 reading = 1

    while (reading != 0) {
        I64 c = mem_read8(source + position)

        if (is_digit(c) == 0) {
            reading = 0
        }
        else {
            value = value * 10 + c - 48
            position = position + 1
        }
    }

    return value
}

fn main() {
    I64 value = read_number("12345+")

    pin("number = %I64\n", value)

    return 0
}
```

</details>

<details>
<summary><strong>34 - read-identifier.mc</strong></summary>

### Goal

Read an identifier into a new buffer.

### Code

```mc
head(custom)
head(memory)

fn identifier_char(I64 c) {
    if (c >= 65) {
        if (c <= 90) {
            return 1
        }
    }

    if (c >= 97) {
        if (c <= 122) {
            return 1
        }
    }

    if (c >= 48) {
        if (c <= 57) {
            return 1
        }
    }

    if (c == 95) {
        return 1
    }

    return 0
}

fn main() {
    I64 source = "kernel_main("
    I64 output = safe_alloc(64)

    I64 position = 0
    I64 reading = 1

    while (reading != 0) {
        I64 c = mem_read8(source + position)

        if (identifier_char(c) == 0) {
            reading = 0
        }
        else {
            safe_write8(output, position, c)
            position = position + 1
        }
    }

    safe_write8(output, position, 0)

    pin("identifier = %s\n", output)

    safe_free(output)

    return 0
}
```

</details>

<details>
<summary><strong>35 - keyword-check.mc</strong></summary>

### Goal

Recognize language keywords.

### Code

```mc
head(custom)

fn keyword_id(I64 text) {
    if (strcmp(text, "fn") == 0) {
        return 1
    }

    if (strcmp(text, "if") == 0) {
        return 2
    }

    if (strcmp(text, "else") == 0) {
        return 3
    }

    if (strcmp(text, "while") == 0) {
        return 4
    }

    if (strcmp(text, "return") == 0) {
        return 5
    }

    return 0
}

fn main() {
    pin("fn = %I64\n", keyword_id("fn"))
    pin("while = %I64\n", keyword_id("while"))
    pin("hello = %I64\n", keyword_id("hello"))

    return 0
}
```

</details>

<details>
<summary><strong>36 - token-loop.mc</strong></summary>

### Goal

Loop through source and classify characters.

### Code

```mc
head(custom)
head(memory)

fn main() {
    I64 source = "I64 x = 42"
    I64 position = 0
    I64 length = strlen(source)

    while (position < length) {
        I64 c = mem_read8(source + position)

        if (c == 32) {
            pin("SPACE\n")
        }
        else {
            if (c >= 48) {
                if (c <= 57) {
                    pin("DIGIT %c\n", c)
                }
                else {
                    pin("CHAR %c\n", c)
                }
            }
            else {
                if (c == 61) {
                    pin("EQUAL\n")
                }
                else {
                    pin("CHAR %c\n", c)
                }
            }
        }

        position = position + 1
    }

    return 0
}
```

</details>

<details>
<summary><strong>37 - variable-table.mc</strong></summary>

### Goal

Understand a simple compiler symbol table.

### Code

```mc
head(custom)
head(memory)

fn main() {
    I64 table = safe_alloc(64)

    safe_write64(table, 0, 1001)
    safe_write64(table, 8, 42)

    safe_write64(table, 16, 1002)
    safe_write64(table, 24, 99)

    I64 hash1 = safe_read64(table, 0)
    I64 value1 = safe_read64(table, 8)

    I64 hash2 = safe_read64(table, 16)
    I64 value2 = safe_read64(table, 24)

    pin("entry 1: hash=%I64 value=%I64\n", hash1, value1)
    pin("entry 2: hash=%I64 value=%I64\n", hash2, value2)

    safe_free(table)

    return 0
}
```

</details>

<details>
<summary><strong>38 - find-variable.mc</strong></summary>

### Goal

Search a symbol table.

### Code

```mc
head(custom)
head(memory)

fn find_variable(I64 table, I64 count, I64 target) {
    I64 i = 0

    while (i < count) {
        I64 offset = i * 16
        I64 hash = safe_read64(table, offset)

        if (hash == target) {
            return safe_read64(table, offset + 8)
        }

        i = i + 1
    }

    return 0 - 1
}

fn main() {
    I64 table = safe_alloc(64)

    safe_write64(table, 0, 1001)
    safe_write64(table, 8, 42)

    safe_write64(table, 16, 1002)
    safe_write64(table, 24, 99)

    I64 value = find_variable(table, 2, 1002)

    pin("value = %I64\n", value)

    safe_free(table)

    return 0
}
```

</details>

<details>
<summary><strong>39 - emit-byte.mc</strong></summary>

### Goal

Understand how a compiler writes machine-code bytes.

### Code

```mc
head(custom)
head(memory)

fn emit_byte(I64 output, I64 position, I64 value) {
    safe_write8(output, position, value)
    return position + 1
}

fn main() {
    I64 output = safe_alloc(16)
    I64 position = 0

    position = emit_byte(output, position, 0x90)
    position = emit_byte(output, position, 0x90)
    position = emit_byte(output, position, 0xC3)

    I64 i = 0

    while (i < position) {
        pin("%X64\n", safe_read8(output, i))
        i = i + 1
    }

    safe_free(output)

    return 0
}
```

</details>

<details>
<summary><strong>40 - emit-instruction.mc</strong></summary>

### Goal

Emit a complete x86 instruction.

### Code

```mc
head(custom)
head(memory)

fn emit_xor_eax_eax(I64 output) {
    safe_write8(output, 0, 0x31)
    safe_write8(output, 1, 0xC0)

    return 2
}

fn main() {
    I64 output = safe_alloc(16)

    I64 size = emit_xor_eax_eax(output)

    pin("instruction size = %I64\n", size)
    pin("byte 0 = %X64\n", safe_read8(output, 0))
    pin("byte 1 = %X64\n", safe_read8(output, 1))

    safe_free(output)

    return 0
}
```

</details>

# 05 - Kernel Concepts

<details>
<summary><strong>41 - memory-write.mc</strong></summary>

### Goal

Write structured values into memory.

### Code

```mc
head(custom)
head(memory)

fn main() {
    I64 memory = safe_alloc(32)

    safe_write64(memory, 0, 0x1234)
    safe_write64(memory, 8, 0x5678)
    safe_write64(memory, 16, 0x9ABC)

    pin("memory written\n")

    safe_free(memory)

    return 0
}
```

</details>

<details>
<summary><strong>42 - memory-read.mc</strong></summary>

### Goal

Read structured values from memory.

### Code

```mc
head(custom)
head(memory)

fn main() {
    I64 memory = safe_alloc(16)

    safe_write64(memory, 0, 123)
    safe_write64(memory, 8, 456)

    I64 a = safe_read64(memory, 0)
    I64 b = safe_read64(memory, 8)

    pin("a = %I64\n", a)
    pin("b = %I64\n", b)

    safe_free(memory)

    return 0
}
```

</details>

<details>
<summary><strong>43 - vga-character.mc</strong></summary>

### Goal

Understand the layout of a VGA text-mode cell.

### Code

```mc
head(custom)

fn vga_cell(I64 character, I64 color) {
    return character + color * 256
}

fn main() {
    I64 cell = vga_cell(65, 15)

    pin("VGA cell = %X64\n", cell)

    return 0
}
```

</details>

<details>
<summary><strong>44 - kernel-putc.mc</strong></summary>

### Goal

Write a character into a simulated VGA text buffer.

### Code

```mc
head(custom)
head(memory)

fn kernel_putc(I64 buffer, I64 cursor, I64 character, I64 color) {
    I64 cell = character + color * 256

    safe_write16(buffer, cursor * 2, cell)

    return cursor + 1
}

fn main() {
    I64 vga = safe_alloc(4000)

    I64 cursor = 0

    cursor = kernel_putc(vga, cursor, 72, 15)
    cursor = kernel_putc(vga, cursor, 105, 15)

    pin("cursor = %I64\n", cursor)

    safe_free(vga)

    return 0
}
```

</details>

<details>
<summary><strong>45 - kernel-newline.mc</strong></summary>

### Goal

Move a text cursor to the next row.

### Code

```mc
head(custom)

fn newline(I64 cursor, I64 width) {
    I64 row = cursor / width
    row = row + 1

    return row * width
}

fn main() {
    I64 cursor = 17

    cursor = newline(cursor, 80)

    pin("new cursor = %I64\n", cursor)

    return 0
}
```

</details>

<details>
<summary><strong>46 - clear-screen.mc</strong></summary>

### Goal

Clear a simulated VGA text screen.

### Code

```mc
head(custom)
head(memory)

fn clear_screen(I64 buffer, I64 cells, I64 color) {
    I64 i = 0
    I64 empty_cell = 32 + color * 256

    while (i < cells) {
        safe_write16(buffer, i * 2, empty_cell)
        i = i + 1
    }

    return 0
}

fn main() {
    I64 screen = safe_alloc(4000)

    clear_screen(screen, 2000, 15)

    pin("screen cleared\n")

    safe_free(screen)

    return 0
}
```

</details>

<details>
<summary><strong>47 - serial-putc.mc</strong></summary>

### Goal

Understand how characters can be queued for a serial output device.

This hosted example simulates the transmit queue instead of accessing privileged hardware ports.

### Code

```mc
head(custom)
head(memory)

fn serial_putc(I64 queue, I64 position, I64 character) {
    safe_write8(queue, position, character)

    return position + 1
}

fn main() {
    I64 queue = safe_alloc(64)

    I64 position = 0

    position = serial_putc(queue, position, 72)
    position = serial_putc(queue, position, 101)
    position = serial_putc(queue, position, 108)
    position = serial_putc(queue, position, 108)
    position = serial_putc(queue, position, 111)

    I64 i = 0

    while (i < position) {
        pin("%c", safe_read8(queue, i))
        i = i + 1
    }

    pin("\n")

    safe_free(queue)

    return 0
}
```

</details>

<details>
<summary><strong>48 - keyboard-state.mc</strong></summary>

### Goal

Understand keyboard press and release state.

### Code

```mc
head(custom)
head(memory)

fn update_key(I64 state, I64 scancode) {
    if (scancode < 128) {
        safe_write8(state, scancode, 1)
        return 1
    }

    I64 key = scancode - 128

    safe_write8(state, key, 0)

    return 0
}

fn main() {
    I64 keyboard = safe_alloc(128)

    update_key(keyboard, 30)

    pin("key 30 pressed = %I64\n", safe_read8(keyboard, 30))

    update_key(keyboard, 158)

    pin("key 30 pressed = %I64\n", safe_read8(keyboard, 30))

    safe_free(keyboard)

    return 0
}
```

</details>

<details>
<summary><strong>49 - clock-counter.mc</strong></summary>

### Goal

Use a monotonic clock for kernel-style ticks.

### Code

```mc
head(custom)
head(time)

fn main() {
    I64 start = time_monotonic_ms()
    I64 tick = 0

    while (tick < 5) {
        sleep_ms(100)

        I64 now = time_monotonic_ms()
        I64 elapsed = now - start

        pin("tick %I64 at %I64 ms\n", tick, elapsed)

        tick = tick + 1
    }

    return 0
}
```

</details>

<details>
<summary><strong>50 - mini-compiler-kernel.mc</strong></summary>

### Goal

Combine parsing, memory and machine-code emission.

The example reads a number and builds a tiny x86 instruction stream.

### Code

```mc
head(custom)
head(memory)

fn parse_number(I64 source) {
    I64 value = 0
    I64 position = 0
    I64 reading = 1

    while (reading != 0) {
        I64 c = mem_read8(source + position)

        if (c < 48) {
            reading = 0
        }
        else {
            if (c > 57) {
                reading = 0
            }
            else {
                value = value * 10 + c - 48
                position = position + 1
            }
        }
    }

    return value
}

fn main() {
    I64 source = "42"
    I64 value = parse_number(source)

    I64 output = safe_alloc(16)

    safe_write8(output, 0, 0xB8)
    safe_write8(output, 1, value)
    safe_write8(output, 2, 0)
    safe_write8(output, 3, 0)
    safe_write8(output, 4, 0)
    safe_write8(output, 5, 0xC3)

    pin("parsed = %I64\n", value)
    pin("machine code:\n")

    I64 i = 0

    while (i < 6) {
        pin("%X64\n", safe_read8(output, i))
        i = i + 1
    }

    safe_free(output)

    return 0
}
```

</details>

# After example 50

At this point you should understand the basic pieces behind:

```text
MicroC source
      ↓
characters
      ↓
tokens
      ↓
parser
      ↓
variables / symbol tables
      ↓
machine-code emitter
      ↓
native x86
```

Good projects after the 50 examples:

- build a tokenizer without looking at the solution
- build a tiny expression parser
- emit several x86 instructions
- build a small allocator
- build a text terminal
- build a framebuffer renderer
- build a small software 3D engine
- build a tiny compiler from scratch
- reverse engineer `compiler.mc`
- rebuild parts of MicroC from memory
- build kernel components in MicroC

The final goal is not to memorize these files line by line.

The goal is to understand the concepts well enough that you can create your own versions without needing the examples.