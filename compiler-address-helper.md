# MicroC Compiler Address Helper

## Compiler addresses

| Address | Meaning |
|---|---|
| `0x800000` | Input file descriptor |
| `0x800008` | Output file descriptor |
| `0x800010` | Input position |
| `0x800018` | Input size |
| `0x800020` | Current character |
| `0x800030` | Raw output flag |
| `0x800068` | Memory/data pointer |
| `0x800078` | Compilation failed flag |
| `0x800088` | Output disabled flag |
| `0x800090` | Output position |
| `0x800098` | `custom` enabled |
| `0x8000A0` | `asm-x86-64` enabled |
| `0x8000A8` | `custom` used |
| `0x8000B0` | `asm-x86-64` used |
| `0x8000C0` | Current line |
| `0x8000C8` | Current column |
| `0x8000D0` | Error count |
| `0x8000D8` | Warning count |
| `0x8000E0` | Source path |
| `0x8000E8` | Diagnostic line |
| `0x8000F0` | Diagnostic column |
| `0x800100` | Token state base |
| `0x801000` | Token 0 text buffer |
| `0x801200` | Token 1 text buffer |
| `0x840000` | Compiler data/memory area |

## Do not use

### Reserved by the MicroC compiler

| Range | Reason |
|---|---|
| `0x800000 - 0x8000FF` | Compiler state |
| `0x800100 - 0x80013F` | Token metadata |
| `0x801000 - 0x8010FF` | Token 0 text |
| `0x801200 - 0x8012FF` | Token 1 text |
| `0x840000+` | Dynamic compiler data |

Do not manually store unrelated data in these ranges unless the compiler memory layout is intentionally changed.

### Linux x86-64 userspace

| Address / Range | Reason |
|---|---|
| `0x0` | NULL pointer |
| Low NULL page | Normally unmapped |
| Kernel address space | Not accessible from userspace |
| Non-canonical addresses | Invalid x86-64 virtual addresses |

These Linux restrictions do not necessarily apply to bare-metal MicroC programs or an operating system kernel.