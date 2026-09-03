# MicroC Examples

A progressive collection of 50 MicroC exercises.

The goal is not to copy solutions.

The goal is to understand MicroC deeply enough to eventually write:

- normal programs
- algorithms
- lexer functions
- parser functions
- compiler functions
- memory functions
- kernel functions
- hardware-related code

Every exercise starts with an empty code block.

Write the implementation yourself, then add your finished code to this README.

---

## Learning path

```text
Basics
  ↓
Functions
  ↓
Algorithms
  ↓
Compiler internals
  ↓
Kernel programming
  ↓
MicroC + SuperNovaOS
```

---

<details>
<summary><strong>01 - Basics</strong></summary>

Learn the core MicroC syntax until you can write it without thinking about it.

---

<details>
<summary>01 - hello.mc</summary>

### Goal

Write the smallest useful MicroC program and print text.

### You should understand

- `head(...)`
- `fn main()`
- code blocks
- `pin`
- where program execution begins

### Code

```mc
head(custom) {
    fn main() {
        pin("hello\n")
    }
}
```

</details>

<details>
<summary>02 - variable.mc</summary>

### Goal

Create an integer variable, assign a value to it and use it.

### You should understand

- `I64`
- variable names
- assignment with `=`
- reading a variable after assigning it

### Code

```mc
head(custom) {
    fn main() {
        I64 x = 5
        pin("x is %I64", x)
    }
}
```

</details>

<details>
<summary>03 - arithmetic.mc</summary>

### Goal

Perform arithmetic using variables.

### You should understand

- addition
- subtraction
- multiplication
- expression evaluation
- storing a result in a variable

### Code

```mc

```

</details>

<details>
<summary>04 - compare.mc</summary>

### Goal

Compare numeric values.

### You should understand

- `==`
- `<`
- `>`
- the difference between assignment and comparison
- true and false conditions

### Code

```mc
```

</details>

<details>
<summary>05 - if.mc</summary>

### Goal

Execute code only when a condition is true.

### You should understand

- `if`
- conditions
- comparison expressions
- conditional code blocks

### Code

```mc
```

</details>

<details>
<summary>06 - if-else.mc</summary>

### Goal

Choose between two different paths.

### You should understand

- `if`
- `else`
- mutually exclusive branches
- how execution continues after a branch

### Code

```mc
```

</details>

<details>
<summary>07 - counter.mc</summary>

### Goal

Create a counter that changes inside a loop.

### You should understand

- `while`
- counters
- changing variables
- loop conditions
- avoiding infinite loops

### Code

```mc
```

</details>

<details>
<summary>08 - countdown.mc</summary>

### Goal

Count downward instead of upward.

### You should understand

- decreasing values
- loop termination
- greater-than comparisons
- changing control variables

### Code

```mc
```

</details>

<details>
<summary>09 - even.mc</summary>

### Goal

Determine whether numbers follow an even-number pattern.

### You should understand

- arithmetic patterns
- conditions
- repeated decisions
- breaking a problem into smaller operations

### Code

```mc
```

</details>

<details>
<summary>10 - fizz-like.mc</summary>

### Goal

Use several conditions while iterating through numbers.

### You should understand

- loops
- multiple `if` statements
- condition ordering
- counters
- combining arithmetic and control flow

### Code

```mc
```

</details>

</details>

---

<details>
<summary><strong>02 - Functions</strong></summary>

Learn how larger MicroC programs are divided into small reusable pieces.

---

<details>
<summary>11 - first-function.mc</summary>

### Goal

Create a function outside `main` and call it.

### You should understand

- `fn`
- function names
- function calls
- control returning to the caller

### Code

```mc
```

</details>

<details>
<summary>12 - function-argument.mc</summary>

### Goal

Pass information into a function.

### You should understand

- function parameters
- arguments
- local values
- caller and callee

### Code

```mc
```

</details>

<details>
<summary>13 - two-arguments.mc</summary>

### Goal

Write a function that operates on two inputs.

### You should understand

- multiple parameters
- parameter order
- expressions using parameters
- reusable functions

### Code

```mc
```

</details>

<details>
<summary>14 - global-state.mc</summary>

### Goal

Use a value that can be accessed by multiple functions.

### You should understand

- global state
- local state
- changing shared values
- why global state must be handled carefully

### Code

```mc
```

</details>

<details>
<summary>15 - counter-function.mc</summary>

### Goal

Move counter logic out of `main` and into a function.

### You should understand

- separating responsibilities
- functions that modify state
- loops inside functions
- clean program structure

### Code

```mc
```

</details>

<details>
<summary>16 - character-values.mc</summary>

### Goal

Work with characters as numeric values.

### You should understand

- ASCII
- characters are represented by numbers
- `'0'` through `'9'`
- `'A'` through `'Z'`
- `'a'` through `'z'`

### Code

```mc
```

</details>

<details>
<summary>17 - is-digit.mc</summary>

### Goal

Determine whether a character represents a decimal digit.

### You should understand

- ASCII value ranges
- `'0'` to `'9'`
- range checking
- why lexers need character classification

### Code

```mc
```

</details>

<details>
<summary>18 - is-letter.mc</summary>

### Goal

Determine whether a character is a letter.

### You should understand

- uppercase ASCII ranges
- lowercase ASCII ranges
- combining multiple conditions
- identifier parsing

### Code

```mc
```

</details>

<details>
<summary>19 - is-whitespace.mc</summary>

### Goal

Recognize whitespace characters.

### You should understand

- spaces
- newlines
- tabs
- character classification
- why compilers skip whitespace

### Code

```mc
```

</details>

<details>
<summary>20 - dispatch.mc</summary>

### Goal

Choose which function to call based on a value or type.

### You should understand

- dispatch
- branching
- function calls
- separating behavior by type

### Code

```mc
```

</details>

</details>

---

<details>
<summary><strong>03 - Algorithms</strong></summary>

Build small algorithms that are directly useful inside compilers and kernels.

---

<details>
<summary>21 - digit-to-number.mc</summary>

### Goal

Convert an ASCII digit into its numeric value.

### You should understand

- ASCII
- `'0'` has a numeric character code
- converting character representation into integer representation
- arithmetic on character values

### Code

```mc
```

</details>

<details>
<summary>22 - parse-number.mc</summary>

### Goal

Convert several digit characters into one integer.

### You should understand

The idea behind:

```text
"583"

0
0 * 10 + 5 = 5
5 * 10 + 8 = 58
58 * 10 + 3 = 583
```

You should also understand:

- loops
- ASCII digit conversion
- decimal place values
- numeric parsing

### Code

```mc
```

</details>

<details>
<summary>23 - scan-until.mc</summary>

### Goal

Process input until a specific terminating character is reached.

### You should understand

- sequential input
- positions
- sentinel values
- loop termination
- advancing through data

### Code

```mc
```

</details>

<details>
<summary>24 - skip-whitespace.mc</summary>

### Goal

Advance through input until the next meaningful character.

### You should understand

- character positions
- whitespace detection
- repeatedly advancing input
- lexer preprocessing

### Code

```mc
```

</details>

<details>
<summary>25 - find-character.mc</summary>

### Goal

Search through a sequence for a particular character.

### You should understand

- linear searching
- positions
- comparison
- stopping when a match is found

### Code

```mc
```

</details>

<details>
<summary>26 - copy-bytes.mc</summary>

### Goal

Copy a sequence of bytes from one location to another.

### You should understand

- source
- destination
- offsets
- byte-by-byte loops
- the basic idea behind `memcpy`

### Code

```mc
```

</details>

<details>
<summary>27 - fill-bytes.mc</summary>

### Goal

Fill an area with the same byte value.

### You should understand

- memory ranges
- addresses
- repeated writes
- the basic idea behind `memset`

### Code

```mc
```

</details>

<details>
<summary>28 - state-machine.mc</summary>

### Goal

Build a program whose behavior depends on its current state.

### You should understand

Concepts such as:

```text
START
NUMBER
IDENTIFIER
DONE
```

You should also understand:

- state variables
- transitions
- dispatch
- why parsers and lexers often behave like state machines

### Code

```mc
```

</details>

<details>
<summary>29 - command-parser.mc</summary>

### Goal

Recognize simple textual commands.

### You should understand

- comparing input
- command recognition
- dispatch
- separating input parsing from command execution

### Code

```mc
```

</details>

<details>
<summary>30 - mini-tokenizer.mc</summary>

### Goal

Break simple MicroC source into meaningful pieces.

### Example concept

```text
I64 x = 42
```

should conceptually contain:

```text
keyword
identifier
operator
number
```

### You should understand

- tokens
- identifiers
- keywords
- numbers
- operators
- whitespace

### Code

```mc
```

</details>

</details>

---

<details>
<summary><strong>04 - Compiler Internals</strong></summary>

Start implementing the same kinds of components found inside a real compiler.

---

<details>
<summary>31 - next-char.mc</summary>

### Goal

Advance through source code one character at a time.

### You should understand

- source position
- current character
- advancing a pointer or index
- end-of-file handling

### Code

```mc
```

</details>

<details>
<summary>32 - peek-char.mc</summary>

### Goal

Inspect the next character without consuming it.

### You should understand

The difference between:

```text
current character
next character
source position
```

You should also understand why a lexer sometimes needs lookahead.

### Code

```mc
```

</details>

<details>
<summary>33 - read-number-token.mc</summary>

### Goal

Read an entire numeric token from source code.

### You should understand

- `is_digit`
- `next_char`
- `parse_number`
- where a number starts
- where a number ends

### Code

```mc
```

</details>

<details>
<summary>34 - read-identifier.mc</summary>

### Goal

Read identifiers such as variable and function names.

### Examples

```text
x
counter
kernel_main
parse_number
```

### You should understand

- valid identifier characters
- identifier boundaries
- source positions
- storing characters while scanning

### Code

```mc
```

</details>

<details>
<summary>35 - keyword-check.mc</summary>

### Goal

Determine whether an identifier is a MicroC keyword.

### Examples

```text
fn
if
else
while
I64
```

### You should understand

- identifiers
- keywords
- comparison
- token types
- why lexers distinguish keywords from names

### Code

```mc
```

</details>

<details>
<summary>36 - token-loop.mc</summary>

### Goal

Continue producing tokens until the source ends.

### You should understand

Conceptually:

```text
while source remains
    get next token
    process token
```

You should also understand:

- EOF
- lexer state
- token streams
- advancing correctly

### Code

```mc
```

</details>

<details>
<summary>37 - variable-table.mc</summary>

### Goal

Store information about declared variables.

### Example concept

```text
x       -> slot 0
y       -> slot 1
counter -> slot 2
```

### You should understand

- symbol tables
- variable names
- slots or offsets
- compiler state
- declaration tracking

### Code

```mc
```

</details>

<details>
<summary>38 - find-variable.mc</summary>

### Goal

Search the variable table for an existing variable.

### You should understand

- symbol lookup
- searching
- identifiers
- what should happen when a symbol does not exist

### Code

```mc
```

</details>

<details>
<summary>39 - emit-byte.mc</summary>

### Goal

Write one byte into compiler output.

### You should understand

- machine code consists of bytes
- output position
- writing binary output
- incrementing the output position
- why code generators need primitive emit functions

### Code

```mc
```

</details>

<details>
<summary>40 - emit-instruction.mc</summary>

### Goal

Construct a machine instruction from multiple bytes.

### You should understand

- opcodes
- operands
- immediates
- instruction encoding
- calling `emit_byte` multiple times
- x86-64 instructions are encoded as byte sequences

### Code

```mc
```

</details>

</details>

---

<details>
<summary><strong>05 - Kernel</strong></summary>

Use MicroC for low-level code that resembles functions inside SuperNovaOS.

---

<details>
<summary>41 - memory-write.mc</summary>

### Goal

Write a value to a specific memory address.

### You should understand

- memory addresses
- bytes
- address and value are different things
- direct memory access
- why kernels need memory operations

### Code

```mc
```

</details>

<details>
<summary>42 - memory-read.mc</summary>

### Goal

Read a value from a specific memory address.

### You should understand

- addresses
- reading versus writing
- returned values
- memory-mapped data

### Code

```mc
```

</details>

<details>
<summary>43 - vga-character.mc</summary>

### Goal

Write one character directly into VGA text memory.

### You should understand

- VGA text memory begins at `0xB8000`
- characters are stored as bytes
- VGA attributes
- character cells
- memory-mapped display output

### Code

```mc
```

</details>

<details>
<summary>44 - kernel-putc.mc</summary>

### Goal

Create a kernel function that prints one character at the current cursor position.

### You should understand

- VGA text memory
- cursor position
- rows and columns
- moving to the next character cell
- persistent kernel state

### Code

```mc
```

</details>

<details>
<summary>45 - kernel-newline.mc</summary>

### Goal

Teach your character output system how to handle a newline.

### You should understand

- rows
- columns
- screen width
- resetting the column
- moving to the next row
- newline character handling

### Code

```mc
```

</details>

<details>
<summary>46 - clear-screen.mc</summary>

### Goal

Clear every character cell on a text-mode screen.

### You should understand

- VGA memory layout
- screen dimensions
- loops
- repeated memory writes
- resetting cursor state

### Code

```mc
```

</details>

<details>
<summary>47 - serial-putc.mc</summary>

### Goal

Send a character through a serial port for kernel debugging.

### You should understand

- I/O ports are different from normal RAM
- COM1
- port reads and writes
- hardware status
- why kernels use serial debugging
- why QEMU can redirect serial output to a terminal

### Code

```mc
```

</details>

<details>
<summary>48 - keyboard-state.mc</summary>

### Goal

Convert keyboard input information into something usable by the kernel.

### You should understand

- keyboard scancodes
- key presses
- ASCII characters
- hardware input versus text
- keyboard state
- mapping one representation into another

### Code

```mc
```

</details>

<details>
<summary>49 - clock-counter.mc</summary>

### Goal

Implement the software logic behind a digital clock.

### You should understand

- ticks
- seconds
- minutes
- hours
- counters overflowing into larger units
- how timer interrupts can later drive this logic

### Example concept

```text
59 seconds
+ 1 tick
↓
0 seconds
+ 1 minute
```

### Code

```mc
```

</details>

<details>
<summary>50 - mini-compiler-kernel.mc</summary>

### Goal

Combine what you have learned into one final systems-programming project.

Build a very small compiler-like pipeline.

### You should understand

```text
source
  ↓
characters
  ↓
lexer
  ↓
tokens
  ↓
parser logic
  ↓
output
```

### Before attempting this

You should be comfortable with:

- functions
- variables
- loops
- conditions
- ASCII
- source positions
- tokens
- identifiers
- numeric parsing
- symbol lookup
- binary output
- memory
- byte operations
- state machines

The goal is **not** to rewrite the complete MicroC compiler.

The goal is to understand enough of the process that the real `compiler.mc` no longer looks mysterious.

### Code

```mc
```

</details>

</details>

---

# After exercise 50

You should be able to open real MicroC or SuperNovaOS code and investigate functions such as:

```text
is_digit()
next_char()
next_token()
parse_number()
parse_statement()
find_variable()
emit_byte()
memcpy()
memset()
putc()
serial_putc()
keyboard_read()
clock_update()
```

Instead of asking only:

> What code do I need?

you should increasingly be able to ask:

> What state does this function need?

> What does it receive?

> What does it modify?

> What should it return?

> What hardware or memory does it interact with?

> Which smaller functions should it be built from?

That is the point of this repository.

---

# Rule

For every exercise:

1. Read the requirements.
2. Try to design the algorithm yourself.
3. Write the MicroC implementation.
4. Test it.
5. Fix your own errors first.
6. Explain to yourself why every line exists.
7. Add the finished implementation to the empty code block in this README.
8. Only then continue to the next exercise.

By exercise 50, the goal is not simply to **know MicroC syntax**.

The goal is to **think in MicroC**.