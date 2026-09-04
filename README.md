# MicroC

<p align="center">
  <b>Small systems language. Self-hosted compiler. Direct x86 output.</b>
</p>

<p align="center">
  MicroC keeps the distance between source code and the processor deliberately short.
  The compiler is written in MicroC and emits native machine code without using LLVM.
</p>

---

## Architecture targets

MicroC keeps architecture selection inside `head(...)`.

```mc
head(asm-x86-16 custom) {
    ...
}
```

```mc
head(asm-x86-32 custom) {
    ...
}
```

```mc
head(asm-x86-64 custom) {
    ...
}
```

The normal language layer is enabled with `custom`.  
The architecture feature selects the integrated x86 mode available to the source file.

<table>
<tr>
<td>

<table>
<tr><td align="center"><b>x86-16</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>real-mode / small bare-metal work</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
<td align="center">→</td>
<td>

<table>
<tr><td align="center"><b>x86-32</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>32-bit protected-mode target</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
<td align="center">→</td>
<td>

<table>
<tr><td align="center"><b>x86-64</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>native 64-bit target</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
</tr>
</table>

---

## Compiler path

The normal compile path is intentionally compact. Source is scanned, parsed, and lowered directly into machine code.

<table>
<tr>
<td>

<table>
<tr><td align="center"><b>source.mc</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>MicroC source</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
<td align="center">→</td>
<td>

<table>
<tr><td align="center"><b>LEXER</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>characters → tokens</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
<td align="center">→</td>
<td>

<table>
<tr><td align="center"><b>PARSER</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>tokens → structure</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
<td align="center">→</td>
<td>

<table>
<tr><td align="center"><b>EMITTER</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>structure → x86</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
</tr>
</table>

<p align="center">
  <sub>No LLVM backend · no generated assembly file in the normal path · direct native output</sub>
</p>

---

## A small syntax tree

For:

```mc
I64 result = 2 + 3 * 4
```

the parser sees structure, not just a line of text.

<table>
<tr>
<td></td>
<td></td>
<td>

<table>
<tr><td align="center"><b>+</b></td><td rowspan="2">▓</td></tr>
<tr><td>▓▓▓▓▓</td></tr>
</table>

</td>
<td></td>
<td></td>
</tr>

<tr>
<td></td>
<td align="center">╱</td>
<td></td>
<td align="center">╲</td>
<td></td>
</tr>

<tr>
<td>

<table>
<tr><td align="center"><b>2</b></td><td rowspan="2">▓</td></tr>
<tr><td>▓▓▓▓▓</td></tr>
</table>

</td>
<td></td>
<td></td>
<td></td>
<td>

<table>
<tr><td align="center"><b>*</b></td><td rowspan="2">▓</td></tr>
<tr><td>▓▓▓▓▓</td></tr>
</table>

</td>
</tr>

<tr>
<td></td>
<td></td>
<td></td>
<td align="center">╱</td>
<td align="center">╲</td>
</tr>

<tr>
<td></td>
<td></td>
<td></td>
<td>

<table>
<tr><td align="center"><b>3</b></td><td rowspan="2">▓</td></tr>
<tr><td>▓▓▓▓▓</td></tr>
</table>

</td>
<td>

<table>
<tr><td align="center"><b>4</b></td><td rowspan="2">▓</td></tr>
<tr><td>▓▓▓▓▓</td></tr>
</table>

</td>
</tr>
</table>

<p align="center"><code>2 + (3 * 4)</code></p>

That precedence is part of the parser. Multiplication binds before addition unless parentheses change the structure.

---

## Program structure

A MicroC source file has one `head(...)` block. From there the parser recognizes functions, statements, expressions, and optional integrated assembly.

<table>
<tr>
<td></td>
<td colspan="5">

<table>
<tr><td align="center"><b>program</b></td><td rowspan="2">▓</td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
</tr>

<tr>
<td></td>
<td colspan="5" align="center">↓</td>
</tr>

<tr>
<td></td>
<td colspan="5">

<table>
<tr><td align="center"><b>head(...)</b></td><td rowspan="2">▓</td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
</tr>

<tr>
<td align="center">↙</td>
<td align="center">↓</td>
<td align="center">↓</td>
<td align="center">↓</td>
<td align="center">↘</td>
</tr>

<tr>
<td>

<table>
<tr><td align="center"><b>architecture</b></td><td rowspan="3">▓</td></tr>
<tr><td><sub>asm-x86-16<br>asm-x86-32<br>asm-x86-64</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
<td>

<table>
<tr><td align="center"><b>functions</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>fn</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
<td>

<table>
<tr><td align="center"><b>control</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>if · while</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
<td>

<table>
<tr><td align="center"><b>data</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>I8 … U64 · F64 · Bool</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
<td>

<table>
<tr><td align="center"><b>asm</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>(asmb) … (asme)</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
</tr>
</table>

---

## Function structure

```mc
fn add(I64 a, I64 b) {
    return a + b
}
```

<table>
<tr>
<td>

<table>
<tr><td align="center"><b>fn</b></td><td rowspan="2">▓</td></tr>
<tr><td>▓▓▓▓</td></tr>
</table>

</td>
<td align="center">→</td>
<td>

<table>
<tr><td align="center"><b>add</b></td><td rowspan="2">▓</td></tr>
<tr><td>▓▓▓▓▓</td></tr>
</table>

</td>
<td align="center">→</td>
<td>

<table>
<tr><td align="center"><b>parameters</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>I64 a · I64 b</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
<td align="center">→</td>
<td>

<table>
<tr><td align="center"><b>block</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>return a + b</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
</tr>
</table>

---

## Single-pass style

MicroC does not need to build a huge full-program tree before useful code can be emitted. Parsing and code generation stay close together.

<table>
<tr>
<td>

<table>
<tr><td align="center"><b>1 · token</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>read next token</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
<td align="center">→</td>
<td>

<table>
<tr><td align="center"><b>2 · syntax</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>recognize construct</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
<td align="center">→</td>
<td>

<table>
<tr><td align="center"><b>3 · emit</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>write machine code</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
<td align="center">→</td>
<td>

<table>
<tr><td align="center"><b>4 · patch</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>resolve later if needed</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
</tr>
</table>

---

## MicroC next to other languages

This is a design comparison, not a benchmark chart. Performance depends on the program and compiler quality, so the table avoids fake percentage claims.

<table>
<tr>
<th>Language</th>
<th>Execution / compilation model</th>
<th>Machine control</th>
<th>Compiler complexity</th>
<th>Portability</th>
<th>Typical strength</th>
</tr>

<tr>
<td><b>x86-64 Assembly</b></td>
<td>Written directly as machine-level instructions</td>
<td align="center">Maximum</td>
<td align="center">None as a language compiler</td>
<td align="center">Low</td>
<td>Exact instruction-level control</td>
</tr>

<tr>
<td><b>C</b></td>
<td>Native compiler, usually through a mature optimizer and backend</td>
<td align="center">Very high</td>
<td align="center">High</td>
<td align="center">High</td>
<td>Portable low-level systems software</td>
</tr>

<tr>
<td><b>MicroC</b></td>
<td>Direct native x86 emission from a small self-hosted compiler</td>
<td align="center">Very high</td>
<td align="center">Small by design</td>
<td align="center">x86-focused</td>
<td>Understanding the whole source-to-machine path</td>
</tr>

<tr>
<td><b>HolyC</b></td>
<td>Native compiled language integrated tightly with TempleOS</td>
<td align="center">High</td>
<td align="center">Compact / integrated</td>
<td align="center">Low</td>
<td>Fast interactive systems programming inside TempleOS</td>
</tr>

<tr>
<td><b>Python</b></td>
<td>Normally interpreted through CPython bytecode and runtime machinery</td>
<td align="center">Low</td>
<td align="center">Hidden from user</td>
<td align="center">Very high</td>
<td>Fast development and high-level scripting</td>
</tr>
</table>

### Rough mental model

<table>
<tr>
<td>

<table>
<tr><td align="center"><b>Assembly</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>you choose the instructions</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
<td align="center">← more direct</td>
<td>

<table>
<tr><td align="center"><b>MicroC</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>small compiler → native x86</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
<td align="center">↔</td>
<td>

<table>
<tr><td align="center"><b>C</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>native + mature optimization</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
<td align="center">→ more abstraction</td>
<td>

<table>
<tr><td align="center"><b>Python</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>runtime + bytecode</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
</tr>
</table>

HolyC sits in an unusual place: it is native and low-level, but it was designed as part of a single integrated operating environment rather than as a portable general-purpose toolchain.

---

## Self-hosting

The compiler source is `compiler.mc`.

```bash
./mcc compiler.mc -o mcc-new
chmod +x mcc-new
./mcc-new compiler.mc -o mcc-second
```

<table>
<tr>
<td>

<table>
<tr><td align="center"><b>mcc</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>current compiler</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
<td align="center">compiles →</td>
<td>

<table>
<tr><td align="center"><b>compiler.mc</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>compiler source</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
<td align="center">→</td>
<td>

<table>
<tr><td align="center"><b>mcc-new</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>compiler made by MicroC</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
</tr>
</table>

<p align="center">↓</p>

<table>
<tr>
<td>

<table>
<tr><td align="center"><b>mcc-new</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>generated compiler</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
<td align="center">compiles →</td>
<td>

<table>
<tr><td align="center"><b>compiler.mc</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>same source</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
<td align="center">→</td>
<td>

<table>
<tr><td align="center"><b>mcc-second</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>second generation</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
</tr>
</table>

If the compiler generated by MicroC can compile `compiler.mc` again, the compiler is self-hosting.

---

## Inline x86

```mc
head(asm-x86-16) {
    (asmb) {
        ...
    } (asme)
}
```

```mc
head(asm-x86-32) {
    (asmb) {
        ...
    } (asme)
}
```

```mc
head(asm-x86-64) {
    (asmb) {
        cli
        hlt
    } (asme)
}
```

The integrated assembly path is intended to keep low-level code inside the same source format rather than handing it to a separate assembler.

---

## Output

<table>
<tr>
<td></td>
<td>

<table>
<tr><td align="center"><b>x86 machine code</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>emitted by MicroC</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
<td></td>
</tr>

<tr>
<td align="center">↙</td>
<td></td>
<td align="center">↘</td>
</tr>

<tr>
<td>

<table>
<tr><td align="center"><b>ELF64</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>Linux executable</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
<td></td>
<td>

<table>
<tr><td align="center"><b>raw .bin</b></td><td rowspan="3">▓</td></tr>
<tr><td align="center"><sub>bare-metal output</sub></td></tr>
<tr><td>▓▓▓▓▓▓▓▓▓▓▓</td></tr>
</table>

</td>
</tr>
</table>

---

## Project direction

MicroC is not trying to win by collecting the largest feature list.

The project is about keeping the language, compiler, and generated code close enough together that the complete system can still be understood.

That makes the design question fairly simple:

> How much systems-programming power can fit inside a compiler that is still small enough to take apart and understand?
