# MicroC + SuperNovaOS Address Helper

A compact memory-map reference for the current MicroC compiler and SuperNovaOS layout.

> Keep this file in sync with `compiler.mc`, `kernel-mc/src/stage1.mc`, `kernel-mc/src/stage2.mc`, and `kernel-mc/src/kernel.mc`.
> Fixed addresses are useful only while the code that owns them still agrees with this map.

---

# 1. MicroC compiler memory map

The compiler uses two important fixed regions:

- `0x400000+` for the generated ELF image.
- `0x800000+` for compiler state, tables, scratch buffers, and the dynamic pool.

## Compiler overview

<table>
  <tr>
    <th>High address</th>
    <th>Region</th>
    <th>Low address</th>
  </tr>

  <tr>
    <td align="right"><code>0x8FFFFF</code></td>
    <td>
      <table>
        <tr>
          <td align="center"><b>DYNAMIC COMPILER POOL</b><br><sub>strings / compiler data</sub></td>
          <td rowspan="2">▓</td>
        </tr>
        <tr><td>▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
      </table>
    </td>
    <td><code>0x840000</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x83FFFF</code></td>
    <td align="center"><b>free / future metadata</b></td>
    <td><code>0x833000</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x832FFF</code></td>
    <td>
      <table>
        <tr>
          <td align="center"><b>STRING METADATA</b><br><sub>512 entries · 24 bytes</sub></td>
          <td rowspan="2">▓</td>
        </tr>
        <tr><td>▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
      </table>
    </td>
    <td><code>0x830000</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x82FFFF</code></td>
    <td align="center"><b>free / future type + safety metadata</b></td>
    <td><code>0x824000</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x823FFF</code></td>
    <td>
      <table>
        <tr>
          <td align="center"><b>VARIABLE TABLE</b><br><sub>1024 entries · 16 bytes</sub></td>
          <td rowspan="2">▓</td>
        </tr>
        <tr><td>▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
      </table>
    </td>
    <td><code>0x820000</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x81FFFF</code></td>
    <td align="center"><b>free / future relocations + references</b></td>
    <td><code>0x81A000</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x819FFF</code></td>
    <td>
      <table>
        <tr>
          <td align="center"><b>UNRESOLVED CALL TABLE</b><br><sub>2048 entries · 16 bytes</sub></td>
          <td rowspan="2">▓</td>
        </tr>
        <tr><td>▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
      </table>
    </td>
    <td><code>0x812000</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x811FFF</code></td>
    <td align="center"><b>free / extended function metadata</b></td>
    <td><code>0x811000</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x810FFF</code></td>
    <td>
      <table>
        <tr>
          <td align="center"><b>FUNCTION TABLE</b><br><sub>256 entries · 16 bytes</sub></td>
          <td rowspan="2">▓</td>
        </tr>
        <tr><td>▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
      </table>
    </td>
    <td><code>0x810000</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x80FFFF</code></td>
    <td align="center"><b>parser / token storage</b></td>
    <td><code>0x801300</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x8012FF</code></td>
    <td align="center"><b>token 1 text buffer</b></td>
    <td><code>0x801200</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x8011FF</code></td>
    <td align="center"><b>currently free token-buffer slot</b></td>
    <td><code>0x801100</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x8010FF</code></td>
    <td align="center"><b>token 0 text buffer</b></td>
    <td><code>0x801000</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x800FFF</code></td>
    <td align="center"><b>compiler scratch space</b></td>
    <td><code>0x800460</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x80045F</code></td>
    <td align="center"><b>function parameter scratch</b></td>
    <td><code>0x800400</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x8003FF</code></td>
    <td align="center"><b>lexer / parser reserve</b></td>
    <td><code>0x800140</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x80013F</code></td>
    <td align="center"><b>token metadata</b></td>
    <td><code>0x800100</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x8000FF</code></td>
    <td>
      <table>
        <tr>
          <td align="center"><b>CORE COMPILER STATE</b><br><sub>FDs · lexer state · counters · diagnostics</sub></td>
          <td rowspan="2">▓</td>
        </tr>
        <tr><td>▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
      </table>
    </td>
    <td><code>0x800000</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x7FFFFF</code></td>
    <td align="center"><sub>not compiler workspace</sub></td>
    <td><code>0x400078+</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x400077</code></td>
    <td align="center"><b>ELF64 program header</b></td>
    <td><code>0x400040</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x40003F</code></td>
    <td>
      <table>
        <tr>
          <td align="center"><b>ELF64 HEADER</b></td>
          <td rowspan="2">▓</td>
        </tr>
        <tr><td>▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
      </table>
    </td>
    <td><code>0x400000</code></td>
  </tr>
</table>

### Generated-image layout

<table>
  <tr>
    <td><code>0x400000 - 0x40003F</code></td>
    <td><b>ELF64 header</b></td>
  </tr>
  <tr>
    <td><code>0x400040 - 0x400077</code></td>
    <td><b>Program header</b></td>
  </tr>
  <tr>
    <td><code>0x400078+</code></td>
    <td><b>Generated payload</b> · code · runtime · strings</td>
  </tr>
</table>

The executable entry is:

```text
0x400000 + entry_position
```

`0x400078` is the first byte of the generated payload. It is not necessarily the final entry point.

---

## Core compiler-state addresses

<table>
  <tr><th>Address</th><th>Meaning</th></tr>
  <tr><td><code>0x800000</code></td><td>input file descriptor</td></tr>
  <tr><td><code>0x800008</code></td><td>output file descriptor</td></tr>
  <tr><td><code>0x800010</code></td><td>input position</td></tr>
  <tr><td><code>0x800018</code></td><td>input size</td></tr>
  <tr><td><code>0x800020</code></td><td>current lexer character</td></tr>
  <tr><td><code>0x800030</code></td><td>raw-output flag</td></tr>
  <tr><td><code>0x800038</code></td><td>function count</td></tr>
  <tr><td><code>0x800040</code></td><td>unresolved-call count</td></tr>
  <tr><td><code>0x800048</code></td><td>variable count</td></tr>
  <tr><td><code>0x800050</code></td><td>string count</td></tr>
  <tr><td><code>0x800060</code></td><td>main output position</td></tr>
  <tr><td><code>0x800068</code></td><td>dynamic pool pointer</td></tr>
  <tr><td><code>0x800070</code></td><td>peek-token flag</td></tr>
  <tr><td><code>0x800078</code></td><td>compilation-failed flag</td></tr>
  <tr><td><code>0x800080</code></td><td>raw entry-jump patch</td></tr>
  <tr><td><code>0x800090</code></td><td>current output position</td></tr>
  <tr><td><code>0x8000C0</code></td><td>source line</td></tr>
  <tr><td><code>0x8000C8</code></td><td>source column</td></tr>
  <tr><td><code>0x8000D0</code></td><td>error count</td></tr>
  <tr><td><code>0x8000D8</code></td><td>warning count</td></tr>
</table>

---

# 2. SuperNovaOS memory map

The current kernel identity-maps the low 16 MiB, so the addresses below are physical and directly reachable through the current low-memory mapping.

## OS overview

<table>
  <tr>
    <th>High address</th>
    <th>Region</th>
    <th>Low address</th>
  </tr>

  <tr>
    <td align="right"><code>0xD3FFFF</code></td>
    <td>
      <table>
        <tr>
          <td align="center"><b>AOT OUTPUT BUFFER</b><br><sub>compiler ahead-of-time output</sub></td>
          <td rowspan="2">▓</td>
        </tr>
        <tr><td>▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
      </table>
    </td>
    <td><code>0xD00000</code></td>
  </tr>

  <tr>
    <td align="right"><code>0xC3FFFF</code></td>
    <td>
      <table>
        <tr>
          <td align="center"><b>JIT OUTPUT BUFFER</b><br><sub>compiler JIT output</sub></td>
          <td rowspan="2">▓</td>
        </tr>
        <tr><td>▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
      </table>
    </td>
    <td><code>0xC00000</code></td>
  </tr>

  <tr>
    <td align="right"><code>0xA3FFFF</code></td>
    <td>
      <table>
        <tr>
          <td align="center"><b>ABI FILE BUFFER</b><br><sub>256 KiB</sub></td>
          <td rowspan="2">▓</td>
        </tr>
        <tr><td>▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
      </table>
    </td>
    <td><code>0xA00000</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x55....</code></td>
    <td align="center"><b>editor cache</b></td>
    <td><code>0x550000</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x54....</code></td>
    <td align="center"><b>editor path</b></td>
    <td><code>0x540000</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x53FFFF</code></td>
    <td>
      <table>
        <tr>
          <td align="center"><b>EDITOR BUFFER</b><br><sub>256 KiB maximum</sub></td>
          <td rowspan="2">▓</td>
        </tr>
        <tr><td>▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
      </table>
    </td>
    <td><code>0x500000</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x4F....</code></td>
    <td align="center"><b>program argv + argument text</b></td>
    <td><code>0x4F0000</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x47FFFF</code></td>
    <td>
      <table>
        <tr>
          <td align="center"><b>PROGRAM AREA</b><br><sub>current program window · 512 KiB</sub></td>
          <td rowspan="2">▓</td>
        </tr>
        <tr><td>▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
      </table>
    </td>
    <td><code>0x400000</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x1FFFFF</code></td>
    <td align="center"><b>ABI / kernel service area</b></td>
    <td><code>0x1F0000</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x1EFFFF</code></td>
    <td align="center"><b>kernel buffers / state</b></td>
    <td><code>0x180000</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x17FFFF</code></td>
    <td>
      <table>
        <tr>
          <td align="center"><b>KERNEL HEAP</b><br><sub>0x120000 → 0x180000</sub></td>
          <td rowspan="2">▓</td>
        </tr>
        <tr><td>▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
      </table>
    </td>
    <td><code>0x120000</code></td>
  </tr>

  <tr>
    <td align="right"><code>kernel + ...</code></td>
    <td>
      <table>
        <tr>
          <td align="center"><b>SUPERNOVA KERNEL</b><br><sub>64-bit kernel entry</sub></td>
          <td rowspan="2">▓</td>
        </tr>
        <tr><td>▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
      </table>
    </td>
    <td><code>0x100000</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x90000</code></td>
    <td align="center"><b>bootstrap stack top</b><br><sub>stack grows downward</sub></td>
    <td><code>RSP = 0x90000</code></td>
  </tr>

  <tr>
    <td align="right"><code>0xA095FF</code></td>
    <td>
      <table>
        <tr>
          <td align="center"><b>VGA GRAPHICS MEMORY</b><br><sub>0xA0000 base · 640×480 planar path</sub></td>
          <td rowspan="2">▓</td>
        </tr>
        <tr><td>▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
      </table>
    </td>
    <td><code>0xA0000</code></td>
  </tr>

  <tr>
    <td align="right"><code>stage2 + ...</code></td>
    <td>
      <table>
        <tr>
          <td align="center"><b>STAGE 2</b><br><sub>second-stage bootloader</sub></td>
          <td rowspan="2">▓</td>
        </tr>
        <tr><td>▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
      </table>
    </td>
    <td><code>0x8000</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x7DFF</code></td>
    <td>
      <table>
        <tr>
          <td align="center"><b>STAGE 1 / BIOS BOOT SECTOR</b><br><sub>512-byte boot sector</sub></td>
          <td rowspan="2">▓</td>
        </tr>
        <tr><td>▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
      </table>
    </td>
    <td><code>0x7C00</code></td>
  </tr>

  <tr>
    <td align="right"><code>0x7BFF</code></td>
    <td align="center"><sub>low BIOS / bootstrap memory</sub></td>
    <td><code>0x000000</code></td>
  </tr>
</table>

> The rows are a reference map, not a statement that every byte between every labeled base is occupied.
> When a region has an explicit size in the code, the full range is shown. Otherwise the map marks the important base address.

---

## Kernel detail map

<table>
  <tr><th>Address</th><th>Kernel use</th></tr>

  <tr><td><code>0x100000</code></td><td><b>kernel entry / kernel image base</b></td></tr>

  <tr><td><code>0x120000 - 0x17FFFF</code></td><td><b>heap</b></td></tr>

  <tr><td><code>0x180000</code></td><td>terminal column</td></tr>
  <tr><td><code>0x180008</code></td><td>terminal row</td></tr>
  <tr><td><code>0x180010</code></td><td>terminal color</td></tr>
  <tr><td><code>0x180018</code></td><td>shift state</td></tr>
  <tr><td><code>0x180020</code></td><td>heap-ready flag</td></tr>
  <tr><td><code>0x180028</code></td><td>extended-key state</td></tr>
  <tr><td><code>0x180030</code></td><td>keyboard layout</td></tr>
  <tr><td><code>0x180038</code></td><td>AltGr state</td></tr>
  <tr><td><code>0x180040</code></td><td>Caps Lock state</td></tr>
  <tr><td><code>0x180048</code></td><td>editor-cache-valid flag</td></tr>

  <tr><td><code>0x182000</code></td><td><b>heap bitmap</b></td></tr>
  <tr><td><code>0x183000</code></td><td><b>terminal buffer</b></td></tr>
  <tr><td><code>0x186000</code></td><td><b>shell buffer</b></td></tr>
  <tr><td><code>0x187000</code></td><td>number buffer</td></tr>
  <tr><td><code>0x188000</code></td><td>sector buffer</td></tr>
  <tr><td><code>0x190000</code></td><td>directory buffer</td></tr>
  <tr><td><code>0x192000</code></td><td>file buffer</td></tr>

  <tr><td><code>0x1F0000</code></td><td><b>ABI handle table</b></td></tr>
  <tr><td><code>0x1F1000</code></td><td>program argc</td></tr>
  <tr><td><code>0x1FF000</code></td><td><b>ABI function table</b></td></tr>

  <tr><td><code>0x400000 - 0x47FFFF</code></td><td><b>program area</b></td></tr>
  <tr><td><code>0x4F0000</code></td><td>program argv table</td></tr>
  <tr><td><code>0x4F1000</code></td><td>program argument text</td></tr>

  <tr><td><code>0x500000 - 0x53FFFF</code></td><td><b>editor buffer</b></td></tr>
  <tr><td><code>0x540000</code></td><td>editor path</td></tr>
  <tr><td><code>0x550000</code></td><td>editor cache</td></tr>

  <tr><td><code>0xA00000 - 0xA3FFFF</code></td><td><b>ABI file buffer</b></td></tr>
  <tr><td><code>0xC00000 - 0xC3FFFF</code></td><td><b>compiler JIT buffer</b></td></tr>
  <tr><td><code>0xD00000 - 0xD3FFFF</code></td><td><b>compiler AOT buffer</b></td></tr>
</table>

---

# 3. Boot path

<table>
  <tr>
    <td>
      <table>
        <tr><td align="center"><b>BIOS</b></td><td rowspan="2">▓</td></tr>
        <tr><td>▓▓▓▓▓▓▓▓</td></tr>
      </table>
    </td>
    <td align="center">loads →</td>
    <td>
      <table>
        <tr><td align="center"><b>stage1</b><br><code>0x7C00</code></td><td rowspan="2">▓</td></tr>
        <tr><td>▓▓▓▓▓▓▓▓</td></tr>
      </table>
    </td>
    <td align="center">loads →</td>
    <td>
      <table>
        <tr><td align="center"><b>stage2</b><br><code>0x8000</code></td><td rowspan="2">▓</td></tr>
        <tr><td>▓▓▓▓▓▓▓▓</td></tr>
      </table>
    </td>
    <td align="center">jumps →</td>
    <td>
      <table>
        <tr><td align="center"><b>kernel</b><br><code>0x100000</code></td><td rowspan="2">▓</td></tr>
        <tr><td>▓▓▓▓▓▓▓▓</td></tr>
      </table>
    </td>
  </tr>
</table>

Stage 2 enters the kernel with the bootstrap stack at:

```text
RSP = 0x90000
```

---

# 4. Compiler inside SuperNovaOS

MicroC has dedicated OS-side output regions.

<table>
  <tr>
    <td>
      <table>
        <tr><td align="center"><b>MicroC source</b></td><td rowspan="2">▓</td></tr>
        <tr><td>▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
      </table>
    </td>
    <td align="center">→</td>
    <td>
      <table>
        <tr><td align="center"><b>compiler</b></td><td rowspan="2">▓</td></tr>
        <tr><td>▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
      </table>
    </td>
    <td align="center">→</td>
    <td>
      <table>
        <tr><td align="center"><b>JIT</b><br><code>0xC00000</code></td><td rowspan="2">▓</td></tr>
        <tr><td>▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
      </table>
    </td>
    <td align="center">or</td>
    <td>
      <table>
        <tr><td align="center"><b>AOT</b><br><code>0xD00000</code></td><td rowspan="2">▓</td></tr>
        <tr><td>▓▓▓▓▓▓▓▓▓▓▓▓</td></tr>
      </table>
    </td>
  </tr>
</table>

Both current output windows are `0x40000` bytes:

```text
JIT  0xC00000 - 0xC3FFFF
AOT  0xD00000 - 0xD3FFFF
```

---

# 5. Addresses worth memorizing

<table>
  <tr><th>Address</th><th>Meaning</th></tr>
  <tr><td><code>0x000000</code></td><td>NULL / bottom of address space</td></tr>
  <tr><td><code>0x7C00</code></td><td>BIOS stage 1</td></tr>
  <tr><td><code>0x8000</code></td><td>stage 2</td></tr>
  <tr><td><code>0x90000</code></td><td>bootstrap stack top</td></tr>
  <tr><td><code>0xA0000</code></td><td>VGA graphics memory</td></tr>
  <tr><td><code>0x100000</code></td><td>kernel</td></tr>
  <tr><td><code>0x120000</code></td><td>heap start</td></tr>
  <tr><td><code>0x180000</code></td><td>kernel state begins</td></tr>
  <tr><td><code>0x1FF000</code></td><td>ABI table</td></tr>
  <tr><td><code>0x400000</code></td><td>OS program base / Linux MicroC ELF base</td></tr>
  <tr><td><code>0x500000</code></td><td>editor buffer</td></tr>
  <tr><td><code>0x800000</code></td><td>Linux-side MicroC compiler workspace</td></tr>
  <tr><td><code>0xA00000</code></td><td>OS ABI file buffer</td></tr>
  <tr><td><code>0xC00000</code></td><td>OS compiler JIT buffer</td></tr>
  <tr><td><code>0xD00000</code></td><td>OS compiler AOT buffer</td></tr>
</table>

---

# 6. Rules before adding a new fixed address

1. Search this file first.
2. Check the actual source before trusting an old diagram.
3. Do not overlap boot, kernel, ABI, program, editor, compiler, or framebuffer regions.
4. Prefer page-aligned addresses for large structures.
5. Give buffers an explicit maximum size when possible.
6. Put a guard between regions that can grow.
7. Keep compiler workspace separate from generated code.
8. Update this map in the same commit that changes the address.
9. Never assume a region is writable just because its numeric address looks unused.
10. For OS code, remember that mapping and physical placement are separate questions once higher-half or non-identity mappings are introduced.
