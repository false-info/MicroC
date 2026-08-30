# MicroC Compiler Address Helper

Quick reference for the fixed memory layout used by the current `mcc`.

> This file describes the current compiler layout.
> Update it whenever a fixed address, table, buffer or memory region changes.

---

# ELF Memory Map

| Address / Range | Meaning |
|---|---|
| `0x0000000000000000` | NULL. Never use as a valid pointer |
| `0x0000000000400000` | MicroC ELF image base |
| `0x0000000000400000 - 0x000000000040003F` | ELF64 header |
| `0x0000000000400040 - 0x0000000000400077` | ELF64 program header |
| `0x0000000000400078` | Start of generated payload |
| `0x0000000000400078+` | Generated code, runtime and string data |
| `0x0000000000800000` | Compiler workspace |
| `0x00000000008FFFFF` | End of current fixed PT_LOAD mapping |
| `0x0000000000900000+` | Outside current fixed MicroC mapping |

The executable entry point is calculated as:

```text
0x400000 + entry_position
```

`0x400078` is therefore the beginning of the generated payload, but is not guaranteed to be the final program entry point.

---

# Compiler State

| Address | Meaning |
|---|---|
| `0x800000` | Input file descriptor |
| `0x800008` | Output file descriptor |
| `0x800010` | Input position |
| `0x800018` | Input size |
| `0x800020` | Current character |
| `0x800030` | Raw output flag |
| `0x800038` | Function count |
| `0x800040` | Unresolved call count |
| `0x800048` | Variable count |
| `0x800050` | String count |
| `0x800058` | Current function is `main` |
| `0x800060` | `main` output position |
| `0x800068` | Dynamic string pool pointer |
| `0x800070` | Peek token available flag |
| `0x800078` | Compilation failed flag |
| `0x800080` | Raw entry jump patch position |
| `0x800088` | Output disabled / boot output finished |
| `0x800090` | Current output position |
| `0x800098` | `custom` enabled |
| `0x8000A0` | `asm-x86-64` enabled |
| `0x8000A8` | `custom` used |
| `0x8000B0` | `asm-x86-64` used |
| `0x8000B8` | ASM entry position |
| `0x8000C0` | Current source line |
| `0x8000C8` | Current source column |
| `0x8000D0` | Error count |
| `0x8000D8` | Warning count |
| `0x8000E0` | Source path pointer |
| `0x8000E8` | Diagnostic line |
| `0x8000F0` | Diagnostic column |

---

# Compiler Tables and Buffers

| Range | Purpose |
|---|---|
| `0x800000 - 0x8000FF` | Core compiler state |
| `0x800100 - 0x80013F` | Token metadata |
| `0x800400 - 0x80045F` | Function parameter scratch area |
| `0x801000 - 0x8010FF` | Token 0 text buffer |
| `0x801200 - 0x8012FF` | Token 1 text buffer |
| `0x810000 - 0x810FFF` | Function table |
| `0x812000 - 0x819FFF` | Unresolved call table |
| `0x820000 - 0x823FFF` | Variable table |
| `0x830000 - 0x832FFF` | String metadata table |
| `0x840000+` | Dynamic compiler string/data pool |

---

# Table Sizes

```text
Function table
0x810000
256 entries
16 bytes per entry
4096 bytes total

Unresolved call table
0x812000
2048 entries
16 bytes per entry
32768 bytes total

Variable table
0x820000
1024 entries
16 bytes per entry
16384 bytes total

String metadata table
0x830000
512 entries
24 bytes per entry
12288 bytes total
```

---

# Critical Addresses

These addresses are part of important compiler or executable state.

Do not overwrite them with unrelated data.

| Address | Critical because |
|---|---|
| `0x000000` | NULL |
| `0x400000` | ELF64 header begins |
| `0x400040` | Program header begins |
| `0x400078` | Generated payload begins |
| `0x800000` | Input FD |
| `0x800008` | Output FD |
| `0x800010` | Input position |
| `0x800018` | Input size |
| `0x800020` | Lexer current character |
| `0x800038` | Function table count |
| `0x800040` | Call table count |
| `0x800048` | Variable table count |
| `0x800050` | String table count |
| `0x800060` | Main function position |
| `0x800068` | Dynamic pool pointer |
| `0x800070` | Peek-token state |
| `0x800078` | Compiler failure state |
| `0x800080` | Raw entry patch |
| `0x800088` | Output state |
| `0x800090` | Output position |
| `0x800098` | `custom` feature state |
| `0x8000A0` | ASM feature state |
| `0x8000B8` | ASM entry position |
| `0x8000C0` | Source line |
| `0x8000C8` | Source column |
| `0x8000D0` | Error counter |
| `0x8000D8` | Warning counter |
| `0x8000E0` | Source path |
| `0x8000E8` | Diagnostic line |
| `0x8000F0` | Diagnostic column |

---

# Do Not Use

Never manually place unrelated data in these regions:

```text
0x400000 - ELF image / generated executable

0x800000 - compiler state
0x800100 - token metadata
0x800400 - parameter scratch

0x801000 - token 0 buffer
0x801200 - token 1 buffer

0x810000 - function table
0x812000 - unresolved calls

0x820000 - variable table

0x830000 - string metadata

0x840000 - dynamic string/data pool
```

The following must also never be treated as normal fixed writable storage:

```text
0x000000                  NULL

0x400000 - 0x40003F       ELF header
0x400040 - 0x400077       ELF program header
0x400078+                 generated executable payload

0x900000+                 outside current fixed MicroC mapping
```

Linux can additionally contain unmapped, protected, stack, library, kernel and ASLR-controlled regions.

Their locations are not guaranteed to remain fixed.

---

# Currently Unused Compiler Space

These ranges are currently unused by `mcc`.

They may be used for future compiler features, but they are not guaranteed to remain free forever.

| Range | Possible Future Use |
|---|---|
| `0x800028 - 0x80002F` | Extra core state |
| `0x800140 - 0x8003FF` | Lexer/parser state |
| `0x800460 - 0x800FFF` | Temporary compiler scratch space |
| `0x801100 - 0x8011FF` | Extra token buffer |
| `0x801300 - 0x80FFFF` | Parser / token storage |
| `0x811000 - 0x811FFF` | Extended function metadata |
| `0x81A000 - 0x81FFFF` | Relocations / references |
| `0x824000 - 0x82FFFF` | Type and ownership metadata |
| `0x833000 - 0x83FFFF` | Constants / debug metadata |

---

# Recommended Future Addresses

Page-aligned addresses are preferred for larger new compiler structures.

| Address | Suggested Purpose |
|---|---|
| `0x811000` | Extended function metadata |
| `0x81A000` | Relocation table |
| `0x81B000` | Symbol/reference table |
| `0x81C000` | Patch metadata |
| `0x824000` | Type metadata |
| `0x825000` | Ownership metadata |
| `0x826000` | Borrow checker state |
| `0x827000` | Lifetime metadata |
| `0x828000` | Bounds-check metadata |
| `0x829000` | Memory safety metadata |
| `0x833000` | Constant metadata |
| `0x834000` | Debug metadata |
| `0x835000` | Symbol names |
| `0x836000` | Source mapping information |

---

# Suggested Future Memory Layout

```text
0x400000
│
├── ELF header
├── program header
├── generated code
├── runtime code
└── generated strings
│
│
0x800000
│
├── compiler state
│
├── 0x800100 token metadata
├── 0x800400 parameter scratch
│
├── 0x801000 token 0 buffer
├── 0x801100 future token buffer
├── 0x801200 token 1 buffer
│
├── 0x810000 function table
├── 0x811000 future function metadata
│
├── 0x812000 unresolved calls
├── 0x81A000 future relocations
├── 0x81B000 future references
├── 0x81C000 future patches
│
├── 0x820000 variable table
│
├── 0x824000 future type metadata
├── 0x825000 future ownership metadata
├── 0x826000 future borrow checker
├── 0x827000 future lifetime metadata
├── 0x828000 future bounds metadata
├── 0x829000 future memory safety metadata
│
├── 0x830000 string metadata
├── 0x833000 future constants
├── 0x834000 future debug metadata
├── 0x835000 future symbols
├── 0x836000 future source maps
│
└── 0x840000 dynamic string/data pool
        |
        v
     0x8FFFFF

0x900000
    outside current fixed mapping
```

---

# Quick Reference

```text
0x000000  NULL

0x400000  ELF base
0x400040  program header
0x400078  generated payload

0x800000  compiler state
0x800100  token metadata
0x800400  parameter scratch

0x801000  token 0 text
0x801200  token 1 text

0x810000  functions
0x811000  FREE

0x812000  unresolved calls
0x81A000  FREE

0x820000  variables
0x824000  FREE

0x830000  strings
0x833000  FREE

0x840000  dynamic data pool

0x900000  outside mapping
```

---

# Address Rules

1. Check this file before assigning a new fixed address.
2. Never overlap an existing compiler region.
3. Prefer page-aligned addresses for large structures.
4. Keep compiler state separate from generated code.
5. Keep fixed tables below the dynamic pool.
6. Do not assume memory above `0x8FFFFF` is mapped.
7. Update this file whenever the memory layout changes.
8. Give every important memory region one clear purpose.
9. Add bounds checks before allowing a table to grow into another region.
10. Never hardcode a new address without documenting why it exists.