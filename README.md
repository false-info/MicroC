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

<div align="center">
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
</div>
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

<div align="center">
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
</div>

<h3>⚡ Current Features</h3>
<ul>
  <li><strong>Dual-Mode Extension Detection:</strong> The compiler automatically evaluates your terminal flags. Typing <code>-o app.bin</code> outputs a raw bootsector, while <code>-o app</code> auto-appends an ELF64 Linux header.</li>
  <li><strong>Single-Pass Backpatching:</strong> Emits jumps instantly for <code>if</code> and <code>while</code> and tracks unresolved branches dynamically. It goes back and patches exact offsets once a closing brace <code>}</code> is encountered.</li>
  <li><strong>AOT Binary Emission:</strong> No temporary assembly text files (.s) are generated. The compiler writes pure, raw x86-64 machine code directly to disk.</li>
  <li><strong>Unified Mode Head Switching:</strong> Context configurations are driven via a singular <code>head(asm-x86-64 custom)</code> syntax statement.</li>
  <li><strong>Inline Assembly Escapes:</strong> Low-level hardware blocks can be declared seamlessly anywhere inside standard code routines via <code>(asmb) ... (asme)</code> statements.</li>
  <li><strong>Hardware MBR Primitives:</strong> Hardcoded macro keywords like <code>pad_boot</code> (zero-fills to 510 bytes) and <code>sign_boot</code> (writes 0xAA55) allow direct bootloader creation.</li>
  <li><strong>Format-Aware Printing:</strong> The native <code>pin()</code> engine emits raw integers, strings, character formats (<code>%c</code>), and string pointers (<code>%s</code>).</li>
</ul>

<h3>🚀 Coming Features (OS & Language Expansion)</h3>
<ul>
  <li><strong>Pointer Indirection:</strong> Support for raw 64-bit memory addresses to read and write directly to hardware text buffers.</li>
  <li><strong>Kernel Trap Interfaces:</strong> Native Linux/Bare-Metal <code>syscall</code> blocks to invoke software interrupts natively.</li>
  <li><strong>Self-Compiling Engine:</strong> Complete removal of the C files (`main.c`, `lexer.c`, `parser.c`, `codegen.c`) by writing the parser inside MicroC.</li>
  <li><strong>Monolithic Boot Core:</strong> A fully integrated MicroC kernel containing keyboard drivers (PS/2) and custom graphical fönstersystem elements.</li>
</ul>

<hr />

<div align="center">
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
</div>
<p>The compiler reads code in a linear execution sequence, mutating states and updating the destination binary concurrently:</p>

<pre>
[ Raw Input Stream (.mc) ]
           │
           ▼
     [ Lexer Loop ] ─────────────► Filters whitespace & comments (//)
           │                       Extracts TOKEN_KEYWORD, TOKEN_STRING, etc.
           ▼
    [ Single-Pass Parser ] ──────► Matches loops/conditionals & handles bracket states
           │                       Triggers immediate target opcode mapping
           ▼
   [ Codegen Byte Driver ]
           │
           ├─── (Output == *.bin) ───► Skipped Header ───► [ Raw Bare-Metal Binary ]
           │
           └─── (Output == No Ext) ──► Write ELF64  ─────► [ Linux Executable File ]
</pre>

<hr />

<div align="center">
<pre>
                                █████                         
                               ░░███                          
  █████  █████ ████ ████████   ███████    ██████   █████ █████
 ███░░  ░░███ ░███ ░░███░░███ ░░░███░    ░░░░░███ ░░███ ░░███ 
░░█████  ░███ ░███  ░███ ░███   ░███      ███████  ░░░█████░  
 ░░░░███ ░███ ░███  ░███ ░███   ░███ ███ ███░░███   ███░░░███ 
 ██████  ░░███████  ████ █████  ░░█████ ░░████████ █████ █████
░░░░░░    ░░░░░███ ░░░░ ░░░░░    ░░░░░   ░░░░░░░░ ░░░░░ ░░░░░ 
          ███ ░███                                            
         ░░██████                                             
          ░░░░░░                                                
</pre>
</div>
<p>Example of valid MicroC code initializing variables, looping with a single pass, and embedding hardware switches:</p>

<details>
<summary>View test.mc</summary>
<br />

```c
head(asm-x86-64 custom) {
    i64 x = 5
    while (x = x - 1) {
        pin("%c", x)
    }
    (asmb) {
        cli
        hlt
        pad_boot
        sign_boot
    }
    (asme)
}
```
</details>

<hr />

<div align="center">
<pre>
 ███████████              ███  ████      █████  ███                     
░░███░░░░░███            ░░░  ░░███     ░░███  ░░░                      
 ░███    ░███ █████ ████ ████  ░███   ███████  ████  ████████    ███████
 ░██████████ ░░███ ░███ ░░███  ░███  ███░░███ ░░███ ░░███░░███  ███░░███
 ░███░░░░░███ ░███ ░███  ░███  ░███ ░███ ░███  ░███  ░███ ░███ ░███ ░███
 ░███    ░███ ░███ ░███  ░███  ░███ ░███ ░███  ░███  ░███ ░███ ░███ ░███
 ███████████  ░░████████ █████ █████░░████████ █████ ████ █████░░███████
░░░░░░░░░░░    ░░░░░░░░ ░░░░░ ░░░░░  ░░░░░░░░ ░░░░░ ░░░░ ░░░░░  ░░░░░███
                                                                ███ ░███
                                                               ░░██████ 
                                                                ░░░░░░  
</pre>
</div>

<h3>1. Clone the repository</h3>
<pre>git clone https://github.com MicroC</pre>

<h3>2. Compile the bootstrap compiler via GCC</h3>
<pre>gcc lexer.c codegen.c parser.c main.c -o microc</pre>

<h3>3. Generate a native Linux executable</h3>
<pre>./microc test.mc -o my_program&#10;chmod +x my_program&#10;./my_program</pre>

<h3>4. Generate a 512-byte raw bootsector binary</h3>
<pre>./microc test.mc -o bootloader.bin</pre>

<hr />

<div align="center">
<pre>
 ███████████                          █████                                    
░░███░░░░░███                        ░░███                                     
 ░███    ░███   ██████   ██████    ███████  █████████████    ██████   ████████ 
 ░██████████   ███░░███ ░░░░░███  ███░░███ ░░███░░███░░███  ░░░░░███ ░░███░░███
 ░███░░░░░███ ░███ ░███  ███████ ░███ ░███  ░███ ░███ ░███   ███████  ░███ ░███
 ░███    ░███ ░███ ░███ ███░░███ ░███ ░███  ░███ ░███ ░███  ███░░███  ░███ ░███
 █████   █████░░██████ ░░████████░░████████ █████░███ █████░░████████ ░███████ 
░░░░░   ░░░░░  ░░░░░░   ░░░░░░░░  ░░░░░░░░ ░░░░░ ░░░ ░░░░░  ░░░░░░░░  ░███░░░  
                                                                      ░███     
                                                                      █████    
                                                                     ░░░░░     
</pre>
</div>

<details>
<summary>Phase 1: Compiler Engineering (Completed Bootstrap)</summary>
<ul>
  <li>[x] Raw tokenization and lexical scanning</li>
  <li>[x] Grammatical single-pass parsing with backpatching</li>
  <li>[x] Direct x86-64 opcode emission</li>
  <li>[x] Automatic ELF64 and raw binary terminal switching</li>
  <li>[x] Custom <code>pin</code> syntax supporting integers and format strings</li>
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
