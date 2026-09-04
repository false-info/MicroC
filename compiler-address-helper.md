# MicroC + SuperNovaOS Address Helper

This file is the fixed-address reference for the current compiler and kernel.

It is meant to answer three questions quickly:

1. **What owns this address now?**
2. **What must never be overwritten?**
3. **Where can a new fixed region go without colliding with the current layout?**

> This is a map of the current code, not a permanent ABI.  
> Update it in the same commit whenever a fixed address or region changes.

---

# MicroC compiler map

The compiler has two large areas: the generated executable around `0x400000`, and compiler workspace around `0x800000`.

<table>
<tr>
<td valign="top">

### ELF / generated image detail

<table>
<tr><th>Address</th><th>Use</th></tr>
<tr><td><code>0x400000</code></td><td><b>ELF64 header</b></td></tr>
<tr><td><code>0x400040</code></td><td><b>program header</b></td></tr>
<tr><td><code>0x400078</code></td><td><b>generated payload begins</b></td></tr>
<tr><td><code>0x400078+</code></td><td>generated code · runtime · strings</td></tr>
</table>

<p align="center"><b>━━━━━━━━━━━━━━▶</b></p>

### Compiler-state detail

<table>
<tr><th>Address</th><th>Use</th></tr>
<tr><td><code>0x800000</code></td><td>input FD</td></tr>
<tr><td><code>0x800008</code></td><td>output FD</td></tr>
<tr><td><code>0x800010</code></td><td>input position</td></tr>
<tr><td><code>0x800018</code></td><td>input size</td></tr>
<tr><td><code>0x800020</code></td><td>current character</td></tr>
<tr><td><code>0x800038</code></td><td>function count</td></tr>
<tr><td><code>0x800040</code></td><td>unresolved-call count</td></tr>
<tr><td><code>0x800048</code></td><td>variable count</td></tr>
<tr><td><code>0x800050</code></td><td>string count</td></tr>
<tr><td><code>0x800068</code></td><td>dynamic-pool pointer</td></tr>
<tr><td><code>0x800090</code></td><td>output position</td></tr>
<tr><td><code>0x8000C0</code></td><td>source line</td></tr>
<tr><td><code>0x8000C8</code></td><td>source column</td></tr>
<tr><td><code>0x8000D0</code></td><td>errors</td></tr>
<tr><td><code>0x8000D8</code></td><td>warnings</td></tr>
</table>

<p align="center"><b>━━━━━━━━━━━━━━▶</b></p>

### Table detail

<table>
<tr><th>Range</th><th>Use</th></tr>
<tr><td><code>0x810000-0x810FFF</code></td><td>function table</td></tr>
<tr><td><code>0x812000-0x819FFF</code></td><td>unresolved calls</td></tr>
<tr><td><code>0x820000-0x823FFF</code></td><td>variables</td></tr>
<tr><td><code>0x830000-0x832FFF</code></td><td>string metadata</td></tr>
<tr><td><code>0x840000+</code></td><td>dynamic string/data pool</td></tr>
</table>

</td>

<td width="28"></td>

<td valign="top">

### Main compiler address map

<table>
<tr><th>High</th><th>Region</th><th>Low</th></tr>

<tr>
<td align="right"><code>0x8FFFFF</code></td>
<td align="center"><b>DYNAMIC DATA POOL</b><br><sub>grows upward from 0x840000</sub></td>
<td><code>0x840000</code></td>
</tr>

<tr>
<td align="right"><code>0x83FFFF</code></td>
<td align="center">future metadata / currently unused</td>
<td><code>0x833000</code></td>
</tr>

<tr>
<td align="right"><code>0x832FFF</code></td>
<td align="center"><b>STRING METADATA</b></td>
<td><code>0x830000</code></td>
</tr>

<tr>
<td align="right"><code>0x82FFFF</code></td>
<td align="center">future type / safety metadata</td>
<td><code>0x824000</code></td>
</tr>

<tr>
<td align="right"><code>0x823FFF</code></td>
<td align="center"><b>VARIABLE TABLE</b></td>
<td><code>0x820000</code></td>
</tr>

<tr>
<td align="right"><code>0x81FFFF</code></td>
<td align="center">future relocations / references</td>
<td><code>0x81A000</code></td>
</tr>

<tr>
<td align="right"><code>0x819FFF</code></td>
<td align="center"><b>UNRESOLVED CALLS</b></td>
<td><code>0x812000</code></td>
</tr>

<tr>
<td align="right"><code>0x811FFF</code></td>
<td align="center">future function metadata</td>
<td><code>0x811000</code></td>
</tr>

<tr>
<td align="right"><code>0x810FFF</code></td>
<td align="center"><b>FUNCTION TABLE</b></td>
<td><code>0x810000</code></td>
</tr>

<tr>
<td align="right"><code>0x80FFFF</code></td>
<td align="center">parser / token reserve</td>
<td><code>0x801300</code></td>
</tr>

<tr>
<td align="right"><code>0x8012FF</code></td>
<td align="center"><b>TOKEN 1 TEXT</b></td>
<td><code>0x801200</code></td>
</tr>

<tr>
<td align="right"><code>0x8011FF</code></td>
<td align="center">free token-buffer slot</td>
<td><code>0x801100</code></td>
</tr>

<tr>
<td align="right"><code>0x8010FF</code></td>
<td align="center"><b>TOKEN 0 TEXT</b></td>
<td><code>0x801000</code></td>
</tr>

<tr>
<td align="right"><code>0x800FFF</code></td>
<td align="center">scratch / reserve</td>
<td><code>0x800140</code></td>
</tr>

<tr>
<td align="right"><code>0x80013F</code></td>
<td align="center"><b>TOKEN METADATA</b></td>
<td><code>0x800100</code></td>
</tr>

<tr>
<td align="right"><code>0x8000FF</code></td>
<td align="center"><b>CORE COMPILER STATE</b></td>
<td><code>0x800000</code></td>
</tr>

<tr>
<td align="right"><code>0x7FFFFF</code></td>
<td align="center"><b>generated executable / growth space</b></td>
<td><code>0x400078</code></td>
</tr>

<tr>
<td align="right"><code>0x400077</code></td>
<td align="center"><b>ELF64 PROGRAM HEADER</b></td>
<td><code>0x400040</code></td>
</tr>

<tr>
<td align="right"><code>0x40003F</code></td>
<td align="center"><b>ELF64 HEADER</b></td>
<td><code>0x400000</code></td>
</tr>
</table>

</td>
</tr>
</table>

The ELF entry address is:

```text
0x400000 + entry_position
```

---

# SuperNovaOS memory map

The current kernel identity-maps the low **16 MiB**. The map below therefore stays inside `0x000000-0xFFFFFF`.

<table>
<tr>
<td valign="top">

### Boot-memory zoom

<table>
<tr><th>Address / range</th><th>Use</th></tr>
<tr><td><code>0x1000-0x3FFF</code></td><td>page tables</td></tr>
<tr><td><code>0x7000 ↓</code></td><td>stage2 16-bit stack</td></tr>
<tr><td><code>0x7C00-0x7DFF</code></td><td>stage1 boot sector</td></tr>
<tr><td><code>0x8000-0x9FFF</code></td><td>stage2 load window</td></tr>
<tr><td><code>0x10000-0x1BFFF</code></td><td>kernel load chunk 1</td></tr>
<tr><td><code>0x20000-0x2BFFF</code></td><td>kernel load chunk 2</td></tr>
<tr><td><code>0x90000 ↓</code></td><td>32/64-bit bootstrap stack</td></tr>
<tr><td><code>0xA0000+</code></td><td>VGA / legacy video area</td></tr>
</table>

<p align="center"><b>━━━━━━━━━━━━━━▶</b></p>

### Kernel zoom

<table>
<tr><th>Address / range</th><th>Use</th></tr>
<tr><td><code>0x100000-0x117FFF</code></td><td>kernel image loaded by stage2</td></tr>
<tr><td><code>0x120000-0x17FFFF</code></td><td>kernel heap</td></tr>
<tr><td><code>0x180000+</code></td><td>kernel state</td></tr>
<tr><td><code>0x182000</code></td><td>heap bitmap</td></tr>
<tr><td><code>0x183000</code></td><td>terminal buffer</td></tr>
<tr><td><code>0x186000</code></td><td>shell buffer</td></tr>
<tr><td><code>0x188000</code></td><td>sector buffer</td></tr>
<tr><td><code>0x190000</code></td><td>directory buffer</td></tr>
<tr><td><code>0x192000</code></td><td>file buffer</td></tr>
<tr><td><code>0x1F0000</code></td><td>ABI handle table</td></tr>
<tr><td><code>0x1FF000</code></td><td>ABI function table</td></tr>
</table>

<p align="center"><b>━━━━━━━━━━━━━━▶</b></p>

### Programs / editor / compiler zoom

<table>
<tr><th>Range</th><th>Use</th></tr>
<tr><td><code>0x400000-0x47FFFF</code></td><td>program window</td></tr>
<tr><td><code>0x4F0000+</code></td><td>argc / argv / argument text</td></tr>
<tr><td><code>0x500000-0x53FFFF</code></td><td>editor buffer</td></tr>
<tr><td><code>0x540000</code></td><td>editor path</td></tr>
<tr><td><code>0x550000+</code></td><td>editor cache</td></tr>
<tr><td><code>0x800000-0x8FFFFF</code></td><td>MicroC compiler workspace</td></tr>
<tr><td><code>0xA00000-0xA3FFFF</code></td><td>ABI file buffer</td></tr>
<tr><td><code>0xC00000-0xC3FFFF</code></td><td>JIT output</td></tr>
<tr><td><code>0xD00000-0xD3FFFF</code></td><td>AOT output</td></tr>
</table>

</td>

<td width="28"></td>

<td valign="top">

### Main SuperNovaOS map

<table>
<tr><th>High</th><th>Region</th><th>Low</th></tr>

<tr>
<td align="right"><code>0xFFFFFF</code></td>
<td align="center"><b>LOW-16-MiB MAP LIMIT</b></td>
<td><code>0xD40000</code></td>
</tr>

<tr>
<td align="right"><code>0xD3FFFF</code></td>
<td align="center"><b>AOT OUTPUT</b><br><sub>256 KiB</sub></td>
<td><code>0xD00000</code></td>
</tr>

<tr>
<td align="right"><code>0xCFFFFF</code></td>
<td align="center">reserve / JIT growth</td>
<td><code>0xC40000</code></td>
</tr>

<tr>
<td align="right"><code>0xC3FFFF</code></td>
<td align="center"><b>JIT OUTPUT</b><br><sub>256 KiB</sub></td>
<td><code>0xC00000</code></td>
</tr>

<tr>
<td align="right"><code>0xBFFFFF</code></td>
<td align="center">currently free low-memory window</td>
<td><code>0xA40000</code></td>
</tr>

<tr>
<td align="right"><code>0xA3FFFF</code></td>
<td align="center"><b>ABI FILE BUFFER</b><br><sub>256 KiB</sub></td>
<td><code>0xA00000</code></td>
</tr>

<tr>
<td align="right"><code>0x9FFFFF</code></td>
<td align="center">currently free</td>
<td><code>0x900000</code></td>
</tr>

<tr>
<td align="right"><code>0x8FFFFF</code></td>
<td align="center"><b>MICROC COMPILER WORKSPACE</b></td>
<td><code>0x800000</code></td>
</tr>

<tr>
<td align="right"><code>0x7FFFFF</code></td>
<td align="center">currently free / subsystem growth</td>
<td><code>0x560000</code></td>
</tr>

<tr>
<td align="right"><code>0x55FFFF</code></td>
<td align="center">editor growth reserve</td>
<td><code>0x550000</code></td>
</tr>

<tr>
<td align="right"><code>0x54FFFF</code></td>
<td align="center">editor path / reserve</td>
<td><code>0x540000</code></td>
</tr>

<tr>
<td align="right"><code>0x53FFFF</code></td>
<td align="center"><b>EDITOR BUFFER</b><br><sub>256 KiB</sub></td>
<td><code>0x500000</code></td>
</tr>

<tr>
<td align="right"><code>0x4FFFFF</code></td>
<td align="center"><b>PROGRAM ARGUMENT AREA</b></td>
<td><code>0x4F0000</code></td>
</tr>

<tr>
<td align="right"><code>0x4EFFFF</code></td>
<td align="center">currently free</td>
<td><code>0x480000</code></td>
</tr>

<tr>
<td align="right"><code>0x47FFFF</code></td>
<td align="center"><b>PROGRAM AREA</b><br><sub>512 KiB</sub></td>
<td><code>0x400000</code></td>
</tr>

<tr>
<td align="right"><code>0x3FFFFF</code></td>
<td align="center"><b>preferred kernel-extension space</b></td>
<td><code>0x200000</code></td>
</tr>

<tr>
<td align="right"><code>0x1FFFFF</code></td>
<td align="center"><b>KERNEL ABI / SERVICE AREA</b></td>
<td><code>0x1F0000</code></td>
</tr>

<tr>
<td align="right"><code>0x1EFFFF</code></td>
<td align="center"><b>KERNEL STATE + BUFFERS</b></td>
<td><code>0x180000</code></td>
</tr>

<tr>
<td align="right"><code>0x17FFFF</code></td>
<td align="center"><b>KERNEL HEAP</b></td>
<td><code>0x120000</code></td>
</tr>

<tr>
<td align="right"><code>0x11FFFF</code></td>
<td align="center">kernel growth guard</td>
<td><code>0x118000</code></td>
</tr>

<tr>
<td align="right"><code>0x117FFF</code></td>
<td align="center"><b>KERNEL IMAGE</b></td>
<td><code>0x100000</code></td>
</tr>

<tr>
<td align="right"><code>0xFFFFF</code></td>
<td align="center"><b>legacy BIOS / ROM / video region</b></td>
<td><code>0xA0000</code></td>
</tr>

<tr>
<td align="right"><code>0x9FFFF</code></td>
<td align="center">bootstrap / conventional memory</td>
<td><code>0x000000</code></td>
</tr>
</table>

</td>
</tr>
</table>

---

# Boot path

<table>
<tr>
<td align="center"><b>BIOS</b></td>
<td align="center"><b>━━━━▶</b></td>
<td align="center"><b>stage1</b><br><code>0x7C00</code></td>
<td align="center"><b>━━━━▶</b></td>
<td align="center"><b>stage2</b><br><code>0x8000</code></td>
<td align="center"><b>━━━━▶</b></td>
<td align="center"><b>kernel load buffers</b><br><code>0x10000</code> + <code>0x20000</code></td>
<td align="center"><b>━━━━▶</b></td>
<td align="center"><b>kernel</b><br><code>0x100000</code></td>
</tr>
</table>

Stage2 builds page tables at `0x1000`, `0x2000`, and `0x3000`, then enters long mode and jumps to the kernel at `0x100000`.

---

# Addresses and ranges you should NOT use

These ranges already have an owner, are hardware/firmware space, or are deliberately left as guards.

## Compiler: do not use

| Address / range | Why |
|---|---|
| `0x000000` | NULL. A valid compiler pointer should never intentionally point here |
| `0x400000-0x40003F` | ELF64 header |
| `0x400040-0x400077` | ELF64 program header |
| `0x400078-0x7FFFFF` | generated executable, runtime, strings, and growth space |
| `0x800000-0x8000FF` | live compiler state |
| `0x800100-0x80013F` | token metadata |
| `0x800400-0x80045F` | function-parameter scratch |
| `0x801000-0x8010FF` | token 0 text |
| `0x801200-0x8012FF` | token 1 text |
| `0x810000-0x810FFF` | function table |
| `0x812000-0x819FFF` | unresolved-call table |
| `0x820000-0x823FFF` | variable table |
| `0x830000-0x832FFF` | string metadata |
| `0x840000-0x8FFFFF` | dynamic compiler pool. It can grow, so fixed data here can be overwritten |

## Kernel / OS: do not use

| Address / range | Why |
|---|---|
| `0x000000-0x000FFF` | low BIOS/real-mode structures and NULL area. Do not treat as normal heap memory |
| `0x001000-0x003FFF` | current long-mode page tables |
| `0x7000` and immediately below | stage2's 16-bit stack grows downward from here |
| `0x7C00-0x7DFF` | BIOS stage1 boot sector |
| `0x8000-0x9FFF` | stage2 load window |
| `0x10000-0x1BFFF` | temporary kernel-load chunk 1 |
| `0x20000-0x2BFFF` | temporary kernel-load chunk 2 |
| `0x90000` and below while booting | bootstrap stack grows downward |
| `0xA0000-0xBFFFF` | legacy video memory. SuperNovaOS currently writes VGA graphics at `0xA0000` |
| `0xC0000-0xFFFFF` | legacy ROM / firmware address area |
| `0x100000-0x117FFF` | current kernel image load window |
| `0x118000-0x11FFFF` | intentional growth/guard space before the heap |
| `0x120000-0x17FFFF` | kernel heap |
| `0x180000-0x1EFFFF` | kernel state and working buffers |
| `0x1F0000-0x1FFFFF` | ABI handles, argc state, ABI table, and service data |
| `0x400000-0x47FFFF` | executable program window |
| `0x4F0000-0x4FFFFF` | program argv / argument storage reserve |
| `0x500000-0x53FFFF` | editor buffer |
| `0x540000-0x54FFFF` | editor path + nearby editor reserve |
| `0x550000-0x55FFFF` | editor cache + growth reserve |
| `0x800000-0x8FFFFF` | MicroC compiler workspace when the compiler runs inside SuperNovaOS |
| `0xA00000-0xA3FFFF` | ABI file buffer |
| `0xC00000-0xC3FFFF` | compiler JIT output |
| `0xD00000-0xD3FFFF` | compiler AOT output |
| `0x1000000+` | not covered by the current low-16-MiB identity map |

---

# Good places for NEW compiler state

These are **candidate regions in the current layout**. Check the source again before assigning one permanently.

## Small compiler additions

| Candidate | Space | Good use |
|---|---:|---|
| `0x800028-0x80002F` | 8 B | one extra core flag / counter |
| `0x800140-0x8003FF` | 704 B | lexer/parser state |
| `0x800460-0x800FFF` | 2976 B | temporary parser/codegen scratch |
| `0x801100-0x8011FF` | 256 B | another token buffer |

## Page-aligned compiler additions

| Recommended base | Available region | Suggested use |
|---|---|---|
| `0x811000` | `0x811000-0x811FFF` | extended function metadata |
| `0x81A000` | `0x81A000-0x81FFFF` | relocations |
| `0x81B000` | inside the range above | symbol/reference table |
| `0x81C000` | inside the range above | patch metadata |
| `0x824000` | `0x824000-0x82FFFF` | type metadata |
| `0x825000` | inside the range above | ownership metadata |
| `0x826000` | inside the range above | borrow-check state |
| `0x827000` | inside the range above | lifetime metadata |
| `0x828000` | inside the range above | bounds metadata |
| `0x829000` | inside the range above | memory-safety metadata |
| `0x833000` | `0x833000-0x83FFFF` | constant metadata |
| `0x834000` | inside the range above | debug metadata |
| `0x835000` | inside the range above | symbol names |
| `0x836000` | inside the range above | source-map metadata |

### Preferred compiler rule

For a new **large** compiler structure, prefer a free **4 KiB-aligned** page such as:

```text
0x811000
0x81A000
0x824000
0x833000
```

Do not put new fixed tables at `0x840000+`; that belongs to the dynamic pool.

---

# Good places for NEW kernel / OS state

These are candidate windows in the **current low-16-MiB map**. They are not hardware guarantees.

## Preferred kernel-extension window

The cleanest large gap is:

```text
0x200000 - 0x3FFFFF
```

That is **2 MiB** between the current kernel ABI area and the program window.

Suggested page-aligned assignments:

| Suggested base | Example purpose |
|---|---|
| `0x200000` | kernel extension / subsystem state |
| `0x210000` | process or task table |
| `0x220000` | scheduler state |
| `0x230000` | VFS / filesystem metadata |
| `0x240000` | device / driver table |
| `0x250000` | event / IPC queues |
| `0x260000` | networking state |
| `0x270000` | kernel log / debug ring |
| `0x280000` | physical-memory allocator metadata |
| `0x300000` | larger kernel caches or subsystem buffers |

This is the best place to grow the kernel without crowding the bootloader, heap, programs, editor, or compiler.

## Other useful free windows

| Candidate range | Size | Best use |
|---|---:|---|
| `0x480000-0x4EFFFF` | 448 KiB | program-loader metadata, program scratch, executable guard structures |
| `0x560000-0x7FFFFF` | 2.625 MiB | large OS buffers, caches, editor/compiler support data |
| `0x900000-0x9FFFFF` | 1 MiB | compiler/OS shared scratch or cache |
| `0xA40000-0xBFFFFF` | 1.75 MiB | large temporary buffers if you do not need JIT expansion nearby |
| `0xC40000-0xCFFFFF` | 768 KiB | possible JIT-adjacent data, but better kept as JIT growth reserve |
| `0xD40000-0xFFFFFF` | 2.75 MiB | possible AOT/build data, but keep some space for future AOT growth |

### Recommended kernel rule

Use the `0x200000-0x3FFFFF` window first.

It is easier to reason about this:

```text
kernel image
     ↓
kernel heap
     ↓
kernel state / ABI
     ↓
0x200000 ┌──────────────────────────┐
         │ new kernel subsystems    │
         │ process table            │
         │ scheduler                │
         │ VFS                      │
         │ drivers                  │
         │ logs                     │
0x3FFFFF └──────────────────────────┘
     ↓
0x400000 program area
```

than to scatter fixed addresses through every free hole in low memory.

---

# Quick visual: ownership vs free space

<table>
<tr><th>Range</th><th>Status</th><th>Owner / recommendation</th></tr>
<tr><td><code>0x000000-0x1FFFFF</code></td><td><b>RESERVED / USED</b></td><td>boot + kernel + heap + ABI</td></tr>
<tr><td><code>0x200000-0x3FFFFF</code></td><td><b>FREE · PREFERRED</b></td><td>new kernel subsystems</td></tr>
<tr><td><code>0x400000-0x47FFFF</code></td><td><b>USED</b></td><td>program area</td></tr>
<tr><td><code>0x480000-0x4EFFFF</code></td><td><b>FREE</b></td><td>program/loader support</td></tr>
<tr><td><code>0x4F0000-0x55FFFF</code></td><td><b>USED / RESERVED</b></td><td>arguments + editor</td></tr>
<tr><td><code>0x560000-0x7FFFFF</code></td><td><b>FREE</b></td><td>large OS buffers / caches</td></tr>
<tr><td><code>0x800000-0x8FFFFF</code></td><td><b>USED</b></td><td>MicroC compiler workspace</td></tr>
<tr><td><code>0x900000-0x9FFFFF</code></td><td><b>FREE</b></td><td>OS/compiler shared scratch</td></tr>
<tr><td><code>0xA00000-0xA3FFFF</code></td><td><b>USED</b></td><td>ABI file buffer</td></tr>
<tr><td><code>0xA40000-0xBFFFFF</code></td><td><b>FREE</b></td><td>large temporary buffers</td></tr>
<tr><td><code>0xC00000-0xC3FFFF</code></td><td><b>USED</b></td><td>JIT</td></tr>
<tr><td><code>0xC40000-0xCFFFFF</code></td><td><b>RESERVE</b></td><td>prefer leaving room for JIT growth</td></tr>
<tr><td><code>0xD00000-0xD3FFFF</code></td><td><b>USED</b></td><td>AOT</td></tr>
<tr><td><code>0xD40000-0xFFFFFF</code></td><td><b>RESERVE / FREE</b></td><td>future AOT/build data</td></tr>
<tr><td><code>0x1000000+</code></td><td><b>NOT CURRENTLY MAPPED</b></td><td>extend page tables before using</td></tr>
</table>

---

# Before adding an address

1. Search `compiler.mc`, `stage1.mc`, `stage2.mc`, `kernel.mc`, and this file for the address.
2. Prefer a page-aligned base such as `0x210000`, not an arbitrary value such as `0x210123`.
3. Give every region an explicit size or limit.
4. Leave room for structures that grow.
5. Do not place persistent data in a stack, dynamic pool, generated-code area, or device-memory area.
6. Keep compiler tables below the dynamic compiler pool at `0x840000`.
7. Keep new kernel subsystems in `0x200000-0x3FFFFF` until there is a reason not to.
8. If you need `0x1000000+`, extend the current page-table mapping first.
9. Add bounds checks before a table can grow into the next region.
10. Update this map immediately when the layout changes.
