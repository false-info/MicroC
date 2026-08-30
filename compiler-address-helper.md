# MicroC Compiler Address Helper

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