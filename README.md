# MicroC — Professional GitHub HTML Blocks

> GitHub-safe diagrams using only Markdown + HTML that GitHub renders directly.
> No CSS, no Mermaid, no external SVG files.

---

## Compiler pipeline

<table>
  <tr>
    <td align="center"><b>source.mc</b><br><sub>MicroC source</sub></td>
    <td align="center">→</td>
    <td align="center"><b>Lexer</b><br><sub>characters → tokens</sub></td>
    <td align="center">→</td>
    <td align="center"><b>Parser</b><br><sub>tokens → syntax</sub></td>
    <td align="center">→</td>
    <td align="center"><b>Codegen</b><br><sub>syntax → x86-64</sub></td>
    <td align="center">→</td>
    <td align="center"><b>Native output</b><br><sub>ELF64 / raw .bin</sub></td>
  </tr>
</table>

<p align="center">
  <sub>MicroC keeps the distance between source code and machine code intentionally short.</sub>
</p>

---

## Source structure

<table>
  <tr>
    <td colspan="5" align="center"><b>program</b></td>
  </tr>
  <tr>
    <td colspan="5" align="center">↓</td>
  </tr>
  <tr>
    <td colspan="5" align="center"><b>head(...)</b></td>
  </tr>
  <tr>
    <td align="center">↙</td>
    <td align="center">↓</td>
    <td align="center">↓</td>
    <td align="center">↓</td>
    <td align="center">↘</td>
  </tr>
  <tr>
    <td align="center"><b>features</b><br><sub>custom<br>asm-x86-64</sub></td>
    <td align="center"><b>functions</b><br><sub>fn</sub></td>
    <td align="center"><b>statements</b><br><sub>if · while · return</sub></td>
    <td align="center"><b>output</b><br><sub>pin</sub></td>
    <td align="center"><b>inline asm</b><br><sub>(asmb) … (asme)</sub></td>
  </tr>
</table>

---

## Function syntax tree

<table>
  <tr>
    <td colspan="7" align="center"><b>function</b></td>
  </tr>
  <tr>
    <td align="center">↓</td>
    <td align="center">↓</td>
    <td align="center">↓</td>
    <td align="center">↓</td>
    <td align="center">↓</td>
    <td align="center">↓</td>
    <td align="center">↓</td>
  </tr>
  <tr>
    <td align="center"><code>fn</code></td>
    <td align="center"><b>identifier</b><br><sub>add</sub></td>
    <td align="center"><code>(</code></td>
    <td align="center"><b>parameters</b><br><sub>I64 a, I64 b</sub></td>
    <td align="center"><code>)</code></td>
    <td align="center"><b>block</b></td>
    <td align="center"><b>return</b></td>
  </tr>
</table>

Example:

```mc
fn add(I64 a, I64 b) {
    return a + b
}
```

---

## Statement syntax tree

<table>
  <tr>
    <td colspan="6" align="center"><b>statement</b></td>
  </tr>
  <tr>
    <td align="center">↓</td>
    <td align="center">↓</td>
    <td align="center">↓</td>
    <td align="center">↓</td>
    <td align="center">↓</td>
    <td align="center">↓</td>
  </tr>
  <tr>
    <td align="center"><b>declaration</b><br><sub>I64 x = 5</sub></td>
    <td align="center"><b>assignment</b><br><sub>x = x + 1</sub></td>
    <td align="center"><b>call</b><br><sub>add(1, 2)</sub></td>
    <td align="center"><b>control flow</b><br><sub>if / while</sub></td>
    <td align="center"><b>return</b></td>
    <td align="center"><b>pin</b></td>
  </tr>
</table>

---

## Lexer example

<table>
  <tr>
    <th colspan="6">Source characters</th>
  </tr>
  <tr>
    <td align="center"><code>1</code></td>
    <td align="center"><code>2</code></td>
    <td align="center"><code> </code></td>
    <td align="center"><code>+</code></td>
    <td align="center"><code> </code></td>
    <td align="center"><code>5</code></td>
  </tr>
  <tr>
    <td colspan="6" align="center">↓ lexical analysis ↓</td>
  </tr>
  <tr>
    <td colspan="2" align="center"><b>NUMBER</b><br><code>12</code></td>
    <td align="center"><sub>skip</sub></td>
    <td align="center"><b>PLUS</b></td>
    <td align="center"><sub>skip</sub></td>
    <td align="center"><b>NUMBER</b><br><code>5</code></td>
  </tr>
</table>

---

## Token categories

<table>
  <tr>
    <th>Category</th>
    <th>Examples</th>
    <th>Meaning</th>
  </tr>
  <tr>
    <td><b>Identifiers</b></td>
    <td><code>main</code> <code>value</code> <code>add</code></td>
    <td>Names of functions and variables</td>
  </tr>
  <tr>
    <td><b>Literals</b></td>
    <td><code>42</code> <code>0x400000</code> <code>"hello"</code></td>
    <td>Values written directly in source</td>
  </tr>
  <tr>
    <td><b>Keywords</b></td>
    <td><code>fn</code> <code>if</code> <code>while</code> <code>return</code></td>
    <td>Reserved language words</td>
  </tr>
  <tr>
    <td><b>Operators</b></td>
    <td><code>+</code> <code>-</code> <code>*</code> <code>==</code></td>
    <td>Expression operations</td>
  </tr>
  <tr>
    <td><b>Punctuation</b></td>
    <td><code>( ) { } ,</code></td>
    <td>Syntax structure</td>
  </tr>
</table>

---

## Expression syntax tree

For:

```mc
I64 result = 2 + 3 * 4
```

<table>
  <tr>
    <td></td>
    <td colspan="3" align="center"><b>expression</b><br><code>+</code></td>
    <td></td>
  </tr>
  <tr>
    <td align="center">↙</td>
    <td></td>
    <td></td>
    <td></td>
    <td align="center">↘</td>
  </tr>
  <tr>
    <td align="center"><b>number</b><br><code>2</code></td>
    <td></td>
    <td></td>
    <td></td>
    <td align="center"><b>term</b><br><code>*</code></td>
  </tr>
  <tr>
    <td></td>
    <td></td>
    <td></td>
    <td align="center">↙</td>
    <td align="center">↘</td>
  </tr>
  <tr>
    <td></td>
    <td></td>
    <td></td>
    <td align="center"><b>number</b><br><code>3</code></td>
    <td align="center"><b>number</b><br><code>4</code></td>
  </tr>
</table>

<p align="center"><code>2 + (3 * 4)</code></p>

---

## Expression grammar

<table>
  <tr>
    <td align="center"><b>expression</b></td>
    <td align="center">→</td>
    <td align="center"><b>term</b></td>
    <td align="center"><code>{ (+ | -) term }</code></td>
  </tr>
  <tr>
    <td align="center"><b>term</b></td>
    <td align="center">→</td>
    <td align="center"><b>factor</b></td>
    <td align="center"><code>{ (* | / | %) factor }</code></td>
  </tr>
  <tr>
    <td align="center"><b>factor</b></td>
    <td align="center">→</td>
    <td align="center"><b>primary</b></td>
    <td align="center"><code>integer | identifier | call | ( expression )</code></td>
  </tr>
</table>

---

## Operator precedence

<table>
  <tr>
    <th>Priority</th>
    <th>Operators</th>
    <th>Group</th>
  </tr>
  <tr>
    <td align="center">7</td>
    <td align="center"><code>* / %</code></td>
    <td>Multiplicative</td>
  </tr>
  <tr>
    <td align="center">6</td>
    <td align="center"><code>+ -</code></td>
    <td>Additive</td>
  </tr>
  <tr>
    <td align="center">5</td>
    <td align="center"><code>&lt;&lt; &gt;&gt;</code></td>
    <td>Shift</td>
  </tr>
  <tr>
    <td align="center">4</td>
    <td align="center"><code>&amp;</code></td>
    <td>Bitwise AND</td>
  </tr>
  <tr>
    <td align="center">3</td>
    <td align="center"><code>^</code></td>
    <td>Bitwise XOR</td>
  </tr>
  <tr>
    <td align="center">2</td>
    <td align="center"><code>|</code></td>
    <td>Bitwise OR</td>
  </tr>
  <tr>
    <td align="center">1</td>
    <td align="center"><code>== != &lt; &gt; &lt;= &gt;=</code></td>
    <td>Comparison</td>
  </tr>
</table>

---

## Parser decision flow

<table>
  <tr>
    <td align="center"><b>next token</b></td>
    <td align="center">→</td>
    <td align="center"><b>what starts here?</b></td>
  </tr>
</table>

<table>
  <tr>
    <td align="center"><code>I64 / U64 / ...</code><br>↓<br><b>declaration</b></td>
    <td align="center"><code>if</code><br>↓<br><b>if statement</b></td>
    <td align="center"><code>while</code><br>↓<br><b>while statement</b></td>
    <td align="center"><code>return</code><br>↓<br><b>return statement</b></td>
    <td align="center"><code>identifier</code><br>↓<br><b>call / assignment</b></td>
    <td align="center"><code>pin</code><br>↓<br><b>output statement</b></td>
  </tr>
</table>

---

## Single-pass compiler flow

<table>
  <tr>
    <td align="center"><b>1</b><br>Read token</td>
    <td align="center">→</td>
    <td align="center"><b>2</b><br>Recognize construct</td>
    <td align="center">→</td>
    <td align="center"><b>3</b><br>Emit x86-64</td>
    <td align="center">→</td>
    <td align="center"><b>4</b><br>Record patch</td>
  </tr>
  <tr>
    <td align="center">↑</td>
    <td></td>
    <td colspan="3" align="center"><b>more source?</b></td>
    <td></td>
    <td align="center">↓</td>
  </tr>
  <tr>
    <td colspan="5" align="center">← yes</td>
    <td align="center">no →</td>
    <td align="center"><b>finish output</b></td>
  </tr>
</table>

---

## Function call path

<table>
  <tr>
    <td align="center"><b>call expression</b><br><code>add(10, 20)</code></td>
    <td align="center">→</td>
    <td align="center"><b>parse arguments</b><br><code>10</code> · <code>20</code></td>
    <td align="center">→</td>
    <td align="center"><b>prepare registers</b></td>
    <td align="center">→</td>
    <td align="center"><b>CALL</b></td>
    <td align="center">→</td>
    <td align="center"><b>return value</b><br><sub>RAX</sub></td>
  </tr>
</table>

---

## Control flow: if

<table>
  <tr>
    <td align="center"><b>condition</b></td>
    <td align="center">→</td>
    <td align="center"><b>compare</b></td>
    <td align="center">→</td>
    <td align="center"><b>conditional jump</b></td>
  </tr>
  <tr>
    <td colspan="3"></td>
    <td align="center">↙</td>
    <td align="center">↘</td>
  </tr>
  <tr>
    <td colspan="3"></td>
    <td align="center"><b>true</b><br>execute block</td>
    <td align="center"><b>false</b><br>skip block</td>
  </tr>
</table>

---

## Control flow: while

<table>
  <tr>
    <td align="center"><b>loop start</b></td>
    <td align="center">→</td>
    <td align="center"><b>condition</b></td>
    <td align="center">→</td>
    <td align="center"><b>body</b></td>
    <td align="center">→</td>
    <td align="center"><b>jump back</b></td>
  </tr>
  <tr>
    <td align="center">↑</td>
    <td colspan="5" align="center">──────────────────── true ────────────────────</td>
    <td align="center">↵</td>
  </tr>
  <tr>
    <td colspan="2"></td>
    <td align="center">↓ false</td>
    <td colspan="4"></td>
  </tr>
  <tr>
    <td colspan="2"></td>
    <td align="center"><b>continue</b></td>
    <td colspan="4"></td>
  </tr>
</table>

---

## Output formats

<table>
  <tr>
    <td colspan="3" align="center"><b>x86-64 emitted bytes</b></td>
  </tr>
  <tr>
    <td align="center">↙</td>
    <td></td>
    <td align="center">↘</td>
  </tr>
  <tr>
    <td align="center"><b>ELF64</b><br><sub>Linux executable</sub></td>
    <td></td>
    <td align="center"><b>raw .bin</b><br><sub>boot / bare metal</sub></td>
  </tr>
</table>

---

## Inline assembly path

<table>
  <tr>
    <td align="center"><b>(asmb)</b></td>
    <td align="center">→</td>
    <td align="center"><b>asm parser</b></td>
    <td align="center">→</td>
    <td align="center"><b>instruction encoder</b></td>
    <td align="center">→</td>
    <td align="center"><b>x86-64 bytes</b></td>
    <td align="center">→</td>
    <td align="center"><b>(asme)</b></td>
  </tr>
</table>

---

## Self-hosting

<table>
  <tr>
    <td align="center"><b>mcc</b><br><sub>current compiler</sub></td>
    <td align="center">compiles →</td>
    <td align="center"><b>compiler.mc</b></td>
    <td align="center">→</td>
    <td align="center"><b>mcc-new</b></td>
  </tr>
</table>

<table>
  <tr>
    <td align="center"><b>mcc-new</b></td>
    <td align="center">compiles →</td>
    <td align="center"><b>compiler.mc</b></td>
    <td align="center">→</td>
    <td align="center"><b>mcc-second</b></td>
  </tr>
</table>

<p align="center">
  <sub>If the generated compiler can compile the compiler source again, MicroC is self-hosting.</sub>
</p>

---

## Built-in subsystems

<table>
  <tr>
    <td colspan="4" align="center"><b>MicroC built-ins</b></td>
  </tr>
  <tr>
    <td align="center">↓</td>
    <td align="center">↓</td>
    <td align="center">↓</td>
    <td align="center">↓</td>
  </tr>
  <tr>
    <td align="center"><b>Files</b><br><sub>open<br>close<br>file_read8<br>file_write8</sub></td>
    <td align="center"><b>Memory</b><br><sub>mem_read8<br>mem_write8<br>mem_read64<br>mem_write64</sub></td>
    <td align="center"><b>Strings</b><br><sub>strlen<br>strcmp</sub></td>
    <td align="center"><b>Process</b><br><sub>argc<br>argv</sub></td>
  </tr>
</table>

---

## Compact header diagram

<p align="center">
  <kbd>source.mc</kbd>
  &nbsp;→&nbsp;
  <kbd>LEXER</kbd>
  &nbsp;→&nbsp;
  <kbd>PARSER</kbd>
  &nbsp;→&nbsp;
  <kbd>X86-64 EMITTER</kbd>
  &nbsp;→&nbsp;
  <kbd>ELF64 / .BIN</kbd>
</p>

<p align="center">
  <sub>small language · direct native code · self-hosted compiler</sub>
</p>
