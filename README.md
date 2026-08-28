<div align="center">
<pre>
 __  __ _             ____     

|  \/  (_) ___ _ __ _/ ___|    
| |\/| | |/ __| '__/ \___ \    
| |  | | | (__| |  | |___) |   
|_|  |_|_|\___|_|  |_|____/    
</pre>
<p><strong>A Native Systems Programming Language & AOT Compiler Built From Scratch In C</strong></p>
</div>

<hr />

<div align="center">
<pre>
 _   _ _     _             

| | | (_)___(_) ___  _ __  
| | | | / __| |/ _ \| '_ \ 
\ \_/ / \__ \ | (_) | | | |
 \___/|_|___/_|\___/|_| |_|
</pre>
</div>

<p>
  MicroC is a minimalist systems programming language designed without dependencies on external toolchains, linkers, or traditional macro-assemblers. The bootstrap compiler operates as a direct text-to-binary engine, outputting raw x86-64 machine instructions in a single compilation pass.
</p>

<p>
  The architectural philosophy draws heavy inspiration from the paradigm of absolute software sovereignty achieved by Terry Davis with HolyC and TempleOS. The target is an isolated development environment where software components can operate without the overhead of heavy and opaque abstractions.
</p>

<table width="100%">
  <tr>
    <td width="50%">
      <strong>Milestone 1: Complete Self-Hosting</strong><br />
      Re-implementing the lexical scanner, conditional loop parser, and machine-code emitter directly within native MicroC syntax to drop the C infrastructure.
    </td>
    <td width="50%">
      <strong>Milestone 2: Independent Boot Layer</strong><br />
      Developing a bare-metal execution environment equipped with real-mode interfaces, basic drivers, and structural disk routines engineered directly inside the language.
    </td>
  </tr>
</table>

<hr />

<div align="center">
<pre>
 _____             _                     

|  ___|__  __ _ _ _| |_ _   _ _ __ ___ ___ 
| |_ / _ \/ _` | '_\ __| | | | '__/ _ / __|
|  _|  __/ (_| | | | |_| |_| | | |  __\__ \
|_|  \___|\__,_|_|  \__| \__,_|_|  \___|___/
</pre>
</div>

<ul>
  <li><strong>Single-Pass Architecture:</strong> Translates structures down to native machine code on a single sequential stream traversal.</li>
  <li><strong>Label-Free Backpatching:</strong> Emits placeholder offsets for conditional evaluation logic on the fly. It records branch pointers internally and rewrites target positions back into the output stream once the scope terminates.</li>
  <li><strong>Context-Switching Wrappers:</strong> Utilizes a unified <code>head(asm-x86-64 custom)</code> environment block to toggle high-level syntax parsing states and deep inline hardware interactions seamlessly.</li>
  <li><strong>Inline Assembly Escapes:</strong> Introduces <code>(asmb)</code> and <code>(asme)</code> inline delimiters, allowing direct x86-64 hardware control routines to sit right within high-level statement flows.</li>
  <li><strong>Automatic Targets:</strong> Evaluates command-line file extension layouts dynamically. Emits standalone Linux ELF64 system payloads with safe execution traps or pure bare-metal raw byte fields based purely on output file configuration.</li>
  <li><strong>Low-Level Primitives:</strong> Provides native directives such as <code>pad_boot</code> to automatically fill bin blocks to 510 bytes and <code>sign_boot</code> to write the 0xAA55 MBR identification words.</li>
  <li><strong>Integrated Low-Level IO:</strong> Exposes raw compiler primitives like <code>write_byte</code> and <code>read_file_byte</code> that interface with kernel operations without an standard C runtime library.</li>
</ul>

<hr />

<div align="center">
<pre>
 ____                       _                 _                 

|  _ \ ___  ___ ___ _ __ __| |__   ___   ___ | | __             
| |_) / _ \/ __/ __| '__/ _` | '_ \ / _ \ / _ \| |/ /             
|  _ <  __/\__ \__ \ | | (_| | |_) | (_) | (_) |   <              
|_| \_\___||___/___/_|  \__,_|_.__/ \___/ \___/|_|\_\             
</pre>
</div>

<p>Every language primitive, function, and keyword built into MicroC, along with its precise technical purpose and structural syntax requirements:</p>

<h3>Environment & Configuration Primitives</h3>

<ul>
  <li><strong><code>head(asm-x86-64 custom)</code></strong><br />
    <strong>Purpose:</strong> The global master context block. It configures the parser state machine to process both standard operations and hardware commands inside a single pass.<br />
    <strong>Syntax:</strong> <code>head(asm-x86-64 custom) { /* code */ }</code>
  </li>
  <li><strong><code>(asmb)</code> / <code>(asme)</code></strong><br />
    <strong>Purpose:</strong> Inline assembly delimiters. <code>(asmb)</code> switches the compiler into a raw hardware byte emission state, while <code>(asme)</code> safely closes the escape and returns to custom standard parsing rules.<br />
    <strong>Syntax:</strong> <code>(asmb) { cli hlt } (asme)</code>
  </li>
</ul>

<h3>Core Data & Flow Keywords</h3>

<ul>
  <li><strong><code>i64</code></strong><br />
    <strong>Purpose:</strong> Declares a signed 64-bit integer variable allocated locally on the execution stack frame. Supports standard decimal entries and hexadecimal notation parsed via <code>strtol</code>.<br />
    <strong>Syntax:</strong> <code>i64 variable_name = 0xFA</code>
  </li>
  <li><strong><code>if</code></strong><br />
    <strong>Purpose:</strong> Evaluates a comparison operation against the central <code>rax</code> calculation register or local stack boundaries, generating conditional short relative jumps via single-pass backpatching.<br />
    <strong>Syntax:</strong> <code>if (variable_name == 0x01) { /* conditional block */ }</code>
  </li>
  <li><strong><code>while</code></strong><br />
    <strong>Purpose:</strong> Generates a looping structure. Emits a trailing unconditional jump back to the entry offset and patches the entry conditional jump to skip past the loop scope when evaluation fails.<br />
    <strong>Syntax:</strong> <code>while (current == 0x00) { /* loop block */ }</code>
  </li>
  <li><strong><code>fn</code></strong><br />
    <strong>Purpose:</strong> Declares a procedural code routine. Generates a standard x86-64 execution stack prologue frame allocating isolated boundaries for localized data.<br />
    <strong>Syntax:</strong> <code>fn routine_name() { /* procedure scope */ }</code>
  </li>
</ul>

<h3>Native Input/Output Functions</h3>

<ul>
  <li><strong><code>pin</code></strong><br />
    <strong>Purpose:</strong> The built-in printing architecture. Emits raw data integers or format string arrays handling localized parameters directly through Linux console output traps.<br />
    <strong>Syntax:</strong> <code>pin(493)</code> or <code>pin("%c", variable_name)</code> or <code>pin("hello")</code>
  </li>
  <li><strong><code>write_byte</code></strong><br />
    <strong>Purpose:</strong> High-utility AOT compilation primitive. Invokes a native Linux <code>sys_write</code> system call under the hood to output a raw, unformatted single byte straight onto the standard output pipeline or target file descriptor.<br />
    <strong>Syntax:</strong> <code>write_byte(0xFA)</code>
  </li>
  <li><strong><code>read_file_byte</code></strong><br />
    <strong>Purpose:</strong> Low-level lexical streaming primitive. Invokes a raw Linux <code>sys_read</code> transaction to fetch a single byte from the active file descriptor buffer and places it directly into the <code>rax</code> register for immediate conditional token verification.<br />
    <strong>Syntax:</strong> <code>variable_name = read_file_byte()</code>
  </li>
</ul>

<h3>Hardware MBR / Bootsector Macros (Valid only inside inline assembly)</h3>

<ul>
  <li><strong><code>cli</code></strong><br />
    <strong>Purpose:</strong> Clear Interrupt Flag. Disables maskable hardware interrupts to prevent external events from disrupting low-level boot loader logic.<br />
    <strong>Syntax:</strong> <code>cli</code>
  </li>
  <li><strong><code>hlt</code></strong><br />
    <strong>Purpose:</strong> Halt Processor. Stops execution until the next external interrupt occurs, putting the CPU into a low-power sleep state.<br />
    <strong>Syntax:</strong> <code>hlt</code>
  </li>
  <li><strong><code>pad_boot</code></strong><br />
    <strong>Purpose:</strong> Sector padding utility. Calculates the current binary stream offset and fills the remainder of the allocation space with <code>0x00</code> bytes until it reaches exactly byte index 510.<br />
    <strong>Syntax:</strong> <code>pad_boot</code>
  </li>
  <li><strong><code>sign_boot</code></strong><br />
    <strong>Purpose:</strong> Boot signature validator. Writes the standard 2-byte verification sequence (<code>0x55</code> and <code>0xAA</code>) to byte indices 511 and 512, establishing a bootable sector topology recognized by BIOS systems.<br />
    <strong>Syntax:</strong> <code>sign_boot</code>
  </li>
</ul>

<hr />

<div align="center">
<pre>
    _               _     _ _            _                 
   / \   _ __  ___ | |__ (_) |_ ___  ___| |_ _   _ _ __    
  / _ \ | '_ \/ __|| '_ \| | __/ _ \/ __| __| | | | '__|   
 / ___ \| | | \__ \| | | | | ||  __/ (__| |_| |_| | |      
/_/   \_\_| |_|___/|_| |_|_|\__\___|\___|\__|\__,_|_|      
</pre>
</div>

<p>The compiler reads code in a linear execution sequence, mutating states and updating the destination binary concurrently:</p>

<pre>
[ MicroC Source File (.mc) ]
             │
             ▼
       [ Stream Lexer ] ───────────► Eliminates comments (//) and breaks down strings,
             │                       numbers, symbols, identifiers, and compiler keywords.
             ▼
    [ Single-Pass Parser ] ────────► Asserts grammar patterns and maps variable definitions.
             │                       Manages nested branch tables and tracks backpatch offsets.
             ▼
     [ Machine Code Driver ] ──────► Emits native executable instructions.
             │
             ├─── Target: *.bin ───► [ Raw 512-Byte Boot Sector ]
             │
