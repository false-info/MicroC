<!-- HEADER SECTION -->
<div align="center">
  <h1>⚡ MicroC ⚡</h1>
  <p><strong>A Native Systems Programming Language & AOT Compiler Built Completely From Scratch</strong></p>
  
  <p>
    <img src="https://shields.io" alt="Compiler AOT" />
    <img src="https://shields.io" alt="x86-64" />
    <img src="https://shields.io" alt="Stage" />
  </p>
</div>

<hr />

<!-- MISSION & VISION SECTION -->
<h2>🎯 The Grand Vision</h2>
<p>
  Inspired by the legendary absolute control of Terry Davis's TempleOS, <strong>MicroC</strong> is built with a modern twist. The ultimate goal is to achieve 100% self-hosting and construct a fully functional, bare-metal <strong>Daily Use Operating System</strong>. 
</p>
<p>
  Unlike academic toy compilers, MicroC cuts out all heavy intermediate toolchains and outputs pure binary directly. It is designed to be small, fast, and entirely understandable by a single developer.
</p>

<table width="100%">
  <tr>
    <td width="50%">
      <strong>🚀 Near-Term Goal</strong><br />
      Achieve self-hosting by rewriting the compiler pipeline inside MicroC itself.
    </td>
    <td width="50%">
      <strong>🖥️ Long-Term Goal</strong><br />
      A fully independent, graphical daily-use OS running native applications.
    </td>
  </tr>
</table>

<hr />

<!-- FEATURES & CAPABILITIES -->
<h2>✨ Core Capabilities</h2>
<ul>
  <li><strong>Zero Dependencies:</strong> Emits raw machine code without invoking an assembler or linker.</li>
  <li><strong>Inline Assembly:</strong> Direct hardware access through integrated <code>(asmb) ... (asme)</code> blocks.</li>
  <li><strong>Bare-Metal Primitives:</strong> Built-in instructions like <code>pad_boot</code> and <code>sign_boot</code> for automatic bootloader structuring.</li>
</ul>

<hr />

<!-- COMPILER PIPELINE ARCHITECTURE -->
<h2>📐 Pipeline Architecture</h2>
<p>The compiler is split into highly optimized, modular stages:</p>

<pre>
[ MicroC Source (.mc) ]
          │
          ▼
     [ Lexer.c ] ──────► Tokenizes raw text stream
          │
          ▼
    [ Parser.c ] ──────► Syntactic structural validation
          │
          ▼
   [ Codegen.c ] ──────► Direct opcode generation
          │
          ▼
[ Native x86-64 Machine Code ]
</pre>

<hr />

<!-- CODE INTERACTIVE SECTION -->
<h2>💻 Language Syntax</h2>
<p>Click below to inspect how MicroC targets low-level hardware environment generation:</p>

<details>
<summary>📂 <strong>View Sample Source Code (test.mc)</strong></summary>
<br />

```c
head(asm-x86-64 custom){ 
    (asmb) { 
        cli            // Clear interrupts
        hlt            // Halt the processor
        pad_boot       // Automatically pad to 510 bytes
        sign_boot      // Insert 0xAA55 boot signature
    } 
    (asme) 
}
```
</details>

<hr />

<!-- REPOSITORY MAP -->
<h2>📁 Project Structure</h2>
<table width="100%">
  <thead>
    <tr>
      <th align="left">File</th>
      <th align="left">Responsibility</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>lexer.c</code></td>
      <td>Lexical scanning and token parsing</td>
    </tr>
    <tr>
      <td><code>parser.c</code></td>
      <td>Abstract syntax and grammatical checks</td>
    </tr>
    <tr>
      <td><code>codegen.c</code></td>
      <td>x86-64 binary instruction emission</td>
    </tr>
    <tr>
      <td><code>main.c</code></td>
      <td>Compiler driver and file I/O entry point</td>
    </tr>
  </tbody>
</table>

<hr />

<!-- GETTING STARTED -->
<h2>🚀 Getting Started</h2>

<h3>1. Clone the environment</h3>
<pre>git clone https://github.com MicroC</pre>

<h3>2. Build the bootstrap compiler</h3>
<pre>gcc codegen.c lexer.c parser.c main.c -o microc</pre>

<h3>3. Generate native binary</h3>
<pre>./microc test.mc -o output</pre>

<hr />

<!-- DETAILED ROADMAP -->
<h2>🗺️ Roadmap</h2>

<details>
<summary>🛠️ <strong>Phase 1: Compiler Fundamentals (In Progress)</strong></summary>
<ul>
  <li>[x] Raw token generation loop</li>
  <li>[x] Abstract hardware binding validation</li>
  <li>[x] Direct x86-64 machine code generation</li>
  <li>[ ] Detailed syntax error logging & line pointing</li>
  <li>[ ] Native variable evaluation & type checking</li>
</ul>
</details>

<details>
<summary>🖥️ <strong>Phase 2: The MicroC OS Lifecycle</strong></summary>
<ul>
  <li>[ ] Minimalist AOT-compiled Kernel core</li>
  <li>[ ] Keyboard drivers & video text-mode buffers</li>
  <li>[ ] Standard daily-use filesystem execution (FAT32/Custom)</li>
</ul>
</details>

<details>
<summary>🌌 <strong>Phase 3: Ultimate Autonomy</strong></summary>
<ul>
  <li>[ ] Self-hosting implementation (MicroC compiling MicroC)</li>
  <li>[ ] Monolithic daily-use desktop environment interface</li>
</ul>
</details>

<hr />

<div align="center">
  <p><sub>MicroC is experimental, open-source, and dedicated to pure low-level computing sovereignty.</sub></p>
</div>
