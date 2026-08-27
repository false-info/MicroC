<div align="center">
<pre>
 ██████   ██████  ███                                   █████████ 
░░██████ ██████  ░░░                                   ███░░░░░███
 ░███░█████░███  ████   ██████  ████████   ██████     ███     ░░░ 
 ░███░░███ ░███ ░░███  ███░░███░░███░░███ ███░░███   ░███         
 ░███ ░░░  ░███  ░███ ░███ ░░░  ░███ ░░░ ░███ ░███   ░███         
 ░███      ░███  ░███ ░███  ███ ░███     ░███ ░███   ░░███     ███
 █████     █████ █████░░██████  █████    ░░██████     ░░█████████ 
░░░░░     ░░░░░ ░░░░░  ░░░░░░  ░░░░░      ░░░░░░       ░░░░░░░░░  
</pre>
<p><strong>A Native Systems Programming Language & AOT Compiler Built From Scratch In C</strong></p>
</div>

<hr />

<pre>
 █████   █████  ███           ███                     
░░███   ░░███  ░░░           ░░░                      
 ░███    ░███  ████   █████  ████   ██████  ████████  
 ░███    ░███ ░░███  ███░░  ░░███  ███░░███░░███░░███ 
 ░░███   ███   ░███ ░░█████  ░███ ░███ ░███ ░███ ░███ 
  ░░░█████░    ░███  ░░░░███ ░███ ░███ ░███ ░███ ░███ 
    ░░███      █████ ██████  █████░░██████  ████ █████
     ░░░      ░░░░░ ░░░░░░  ░░░░░  ░░░░░░  ░░░░ ░░░░░ 
                           
</pre>
<p>
  MicroC is a minimalist systems programming language built entirely without external toolchains, assemblers, or linkers. The compiler generates raw x86-64 machine code directly from source text. The primary objective of this project is to achieve full self-hosting, which will then serve as the foundation for an independent operating system engineered for daily use.
</p>
<p>
  Inspiration is drawn from the absolute software sovereignty achieved by Terry Davis with TempleOS, but with a fundamental shift in purpose: MicroC OS is being developed for modern hardware, network stacks, and daily developer workflows, entirely free from heavy and opaque modern operating system layers.
</p>

<table width="100%">
  <tr>
    <td width="50%">
      <strong>Milestone 1: Self-Hosting</strong><br />
      Re-implementing the lexer, parser, and code generator directly in MicroC to eliminate the C bootstrapping layer.
    </td>
    <td width="50%">
      <strong>Milestone 2: Daily Use OS</strong><br />
      Developing a bare-metal OS with a graphical interface, file system, and native drivers capable of replacing standard environments for systems-level work.
    </td>
  </tr>
</table>

<hr />

<pre>
 ███████████                     █████                                         
░░███░░░░░░█                    ░░███                                          
 ░███   █ ░   ██████   ██████   ███████   █████ ████ ████████   ██████   █████ 
 ░███████    ███░░███ ░░░░░███ ░░░███░   ░░███ ░███ ░░███░░███ ███░░███ ███░░  
 ░███░░░█   ░███████   ███████   ░███     ░███ ░███  ░███ ░░░ ░███████ ░░█████ 
 ░███  ░    ░███░░░   ███░░███   ░███ ███ ░███ ░███  ░███     ░███░░░   ░░░░███
 █████      ░░██████ ░░████████  ░░█████  ░░████████ █████    ░░██████  ██████ 
░░░░░        ░░░░░░   ░░░░░░░░    ░░░░░    ░░░░░░░░ ░░░░░      ░░░░░░  ░░░░░░  
                                            
</pre>
<ul>
  <li><strong>Raw Binary Emission:</strong> Writes opcodes directly to disk without generating temporary text-based assembly files.</li>
  <li><strong>Inline Assembly:</strong> Direct hardware interaction via explicitly defined <code>(asmb) ... (asme)</code> blocks.</li>
  <li><strong>Bootloader Primitives:</strong> Built-in compiler instructions (<code>pad_boot</code>, <code>sign_boot</code>) for automatic structuring of MBR/boot sectors.</li>
</ul>

<hr />

<pre>
   █████████                      █████       ███   █████                       █████                                 
  ███░░░░░███                    ░░███       ░░░   ░░███                       ░░███                                  
 ░███    ░███  ████████   ██████  ░███████   ████  ███████    ██████   ██████  ███████   █████ ████ ████████   ██████ 
 ░███████████ ░░███░░███ ███░░███ ░███░░███ ░░███ ░░░███░    ███░░███ ███░░███░░░███░   ░░███ ░███ ░░███░░███ ███░░███
 ░███░░░░░███  ░███ ░░░ ░███ ░░░  ░███ ░███  ░███   ░███    ░███████ ░███ ░░░   ░███     ░███ ░███  ░███ ░░░ ░███████ 
 ░███    ░███  ░███     ░███  ███ ░███ ░███  ░███   ░███ ███░███░░░  ░███  ███  ░███ ███ ░███ ░███  ░███     ░███░░░  
 █████   █████ █████    ░░██████  ████ █████ █████  ░░█████ ░░██████ ░░██████   ░░█████  ░░████████ █████    ░░██████ 
░░░░░   ░░░░░ ░░░░░      ░░░░░░  ░░░░ ░░░░░ ░░░░░    ░░░░░   ░░░░░░   ░░░░░░     ░░░░░    ░░░░░░░░ ░░░░░      ░░░░░░      
                                                           
</pre>
<p>The compiler's internal execution pipeline is divided into four strictly isolated stages:</p>

<pre>
[ MicroC Source (.mc) ]
          │
          ▼
     [ Lexer.c ] ──────► Generates token stream from raw text
          │
          ▼
    [ Parser.c ] ──────► Validates grammatical structure and syntax tree
          │
          ▼
   [ Codegen.c ] ──────► Translates logic directly into x86-64 opcodes
          │
          ▼
[ Executable Machine Code ]
</pre>

<hr />

<pre>
 ____             _                  
/ ___| _   _ _ __ | |_ __ ___  __     
\___ \| | | | '_ \| __/ _` \ \/ /     
 ___) | |_| | | | | || (_| |>  <      

|____/ \__, |_| |_|\__\__,_/_/\_\     
       |___/                          
</pre>
<p>Example of valid MicroC code initializing a minimal boot environment:</p>

<details>
<summary>View test.mc</summary>
<br />

```c
head(asm-x86-64 custom){ 
    (asmb) { 
        cli            // Disable interrupts
        hlt            // Halt the processor
        pad_boot       // Pad the binary to the 510-byte boundary
        sign_boot      // Write boot signature 0xAA55 at bytes 511-512
    } 
    (asme) 
}
```
</details>

<hr />

<pre>
 ____  _             _ _     _   _             

| __ )| |__  _   _  (_) | __| |_ (_)_ __   __ _ 
|  _ \| '_ \| | | | | | |/ _` __| | '_ \ / _` |
| |_) | | | | |_| | | | | (_| |_  | | | | (_| |
|____/|_| |_|\__,_| |_|_|\__,_|\__|_|_| |_|\__, |
                                           |___/ 
</pre>

<h3>1. Clone the repository</h3>
<pre>git clone https://github.com MicroC</pre>

<h3>2. Compile the bootstrap compiler via GCC</h3>
<pre>gcc codegen.c lexer.c parser.c main.c -o microc</pre>

<h3>3. Generate machine code from source</h3>
<pre>./microc test.mc -o output</pre>

<hr />

<pre>
 ____                _ _            

|  _ \ ___   __ _  __| | |__   __ _  
| |_) / _ \ / _` |/ _` | '_ \ / _` | 
|  _ < (_) | (_| | (_| | |_) | (_| | 
|_| \_\___/ \__,_|\__,_|_.__/ \__,_| 
                                     
</pre>

<details>
<summary>Phase 1: Compiler Engineering (In Progress)</summary>
<ul>
  <li>[x] Raw tokenization and lexical scanning</li>
  <li>[x] Grammatical parsing of control structures</li>
  <li>[x] Direct x86-64 opcode emission</li>
  <li>[ ] Implementation of line-based error reporting</li>
  <li>[ ] Type checking and variable stack allocation</li>
</ul>
</details>

<details>
<summary>Phase 2: MicroC Kernel & OS Architecture</summary>
<ul>
  <li>[ ] Minimalist AOT-compiled monolithic kernel core</li>
  <li>[ ] Basic keyboard driver (PS/2) and VGA text-mode buffer</li>
  <li>[ ] Custom file system or FAT32 reader for binary execution</li>
</ul>
</details>

<details>
<summary>Phase 3: Ultimate Autonomy</summary>
<ul>
  <li>[ ] Self-hosting (MicroC compiling its own source code)</li>
  <li>[ ] Graphical window system and shell for daily use</li>
</ul>
</details>

<hr />

<div align="center">
  <p><sub>MicroC is developed experimentally under an open-source license with the ultimate goal of absolute digital sovereignty.</sub></p>
</div>
