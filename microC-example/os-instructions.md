# Building a Minimal OS in MicroC

This is a code-along guide for a tiny BIOS x86 operating system written with MicroC.

Target:

```text
BIOS
 ↓
stage1.mc
 ↓
stage2.mc
 ↓
protected mode
 ↓
long mode
 ↓
kernel.mc
```

The first goal is not a desktop.

The first goal is:

> **reach the kernel and prove it.**

---

# 1. Project layout

```text
minimal-os/
├── stage1.mc
├── stage2.mc
├── kernel.mc
└── os.img
```

---

# 2. Stage1 skeleton

Stage1 is loaded by BIOS at `0x7C00`.

Start with:

```mc
head(asm-x86-16) {
    (asmb) {
        org(0x7C00)
        bits16

        cli

        xor(ax, ax)

        mov(ds, ax)
        mov(es, ax)
        mov(ss, ax)

        mov(sp, 0x7C00)

        sti
        cld

        pad_boot
        sign_boot
    } (asme)
}
```

The important pieces:

```text
org(0x7C00)
```

means:

```text
this code expects to run at 0x7C00
```

and:

```text
pad_boot
sign_boot
```

finish the 512-byte BIOS boot sector.

---

# 3. Prove stage1 runs

Before disk loading, print one character.

```mc
head(asm-x86-16) {
    (asmb) {
        org(0x7C00)
        bits16

        mov(ah, 0x0E)
        mov(al, 0x31)
        int(0x10)

        cli

        label(hang)
        hlt
        jmp(hang)

        pad_boot
        sign_boot
    } (asme)
}
```

You should see:

```text
1
```

That means:

```text
BIOS → stage1 works
```

---

# 4. Stage1 loads stage2

A BIOS Disk Address Packet can describe where stage2 should be loaded.

Example:

```mc
head(asm-x86-16) {
    (asmb) {
        org(0x7C00)
        bits16

        cli
        xor(ax, ax)

        mov(ds, ax)
        mov(es, ax)
        mov(ss, ax)
        mov(sp, 0x7C00)

        sti
        cld

        mov(si, stage2_dap)

        mov(ah, 0x42)
        int(0x13)

        jc(disk_error)

        jmp_far(0x0000, 0x8000)

        label(disk_error)

        mov(ah, 0x0E)
        mov(al, 0x45)
        int(0x10)

        cli

        label(hang)
        hlt
        jmp(hang)

        label(stage2_dap)

        db(0x10)
        db(0x00)

        dw(16)

        dw(0x8000)
        dw(0x0000)

        dd(1)
        dd(0)

        pad_boot
        sign_boot
    } (asme)
}
```

Conceptually:

```text
disk LBA 1
    │
    ▼
0x8000
    │
    ▼
jump 0x0000:0x8000
```

---

# 5. Stage2 skeleton

Stage2 can use all three x86 modes:

```mc
head(asm-x86-16 asm-x86-32 asm-x86-64) {
    (asmb) {
        org(0x8000)

        bits16

        // real mode

        bits32

        // protected mode

        bits64

        // long mode
    } (asme)
}
```

This file is where the CPU changes worlds.

---

# 6. Prove stage2 runs

At the beginning of stage2:

```mc
head(asm-x86-16 asm-x86-32 asm-x86-64) {
    (asmb) {
        org(0x8000)
        bits16

        mov(ah, 0x0E)
        mov(al, 0x32)
        int(0x10)

        cli

        label(hang)
        hlt
        jmp(hang)
    } (asme)
}
```

Expected boot markers:

```text
12
```

Meaning:

```text
1 = stage1
2 = stage2
```

---

# 7. Set up stage2 real-mode state

```mc
head(asm-x86-16 asm-x86-32 asm-x86-64) {
    (asmb) {
        org(0x8000)

        bits16

        cli
        cld

        xor(ax, ax)

        mov(ds, ax)
        mov(es, ax)
        mov(ss, ax)

        mov(sp, 0x7000)

        sti

        // continue here
    } (asme)
}
```

Why `0x7000`?

Because stage2 itself starts at `0x8000`, so the stack grows downward away from it.

---

# 8. Enable A20

One simple path uses port `0x92`:

```mc
in(al, 0x92)
or(al, 0x02)
and(al, 0xFE)
out(0x92, al)
```

Inside:

```mc
head(asm-x86-16 asm-x86-32 asm-x86-64) {
    (asmb) {
        org(0x8000)

        bits16

        in(al, 0x92)
        or(al, 0x02)
        and(al, 0xFE)
        out(0x92, al)
    } (asme)
}
```

This lets you safely use memory above 1 MiB.

---

# 9. Load kernel chunks

While BIOS services are still available in real mode, load kernel sectors into low memory.

Example DAP:

```mc
label(kernel_dap_1)

db(0x10)
db(0x00)

dw(96)

dw(0x0000)
dw(0x1000)

dd(17)
dd(0)
```

This buffer is:

```text
segment 0x1000
offset  0x0000
```

which corresponds to:

```text
0x10000
```

A second chunk can go to:

```text
0x20000
```

Then protected-mode code copies both chunks to `0x100000+`.

---

# 10. Minimal GDT

A tiny GDT can contain:

```text
null
32-bit code
32-bit data
64-bit code
```

MicroC inline assembly:

```mc
align(8)

label(gdt_start)

dq(0x0000000000000000)
dq(0x00CF9A000000FFFF)
dq(0x00CF92000000FFFF)
dq(0x00AF9A000000FFFF)

label(gdt_descriptor)

dw(31)
dd(gdt_start)
```

Then load it:

```mc
lgdt(gdt_descriptor)
```

---

# 11. Enter protected mode

Enable CR0.PE:

```mc
mov(eax, cr0)
or(eax, 0x00000001)
mov(cr0, eax)
```

Then far jump:

```mc
jmp_far(0x08, protected_entry)
```

After that:

```mc
bits32

label(protected_entry)
```

---

# 12. Initialize 32-bit segments

```mc
bits32

label(protected_entry)

mov(ax, 0x10)

mov(ds, ax)
mov(es, ax)
mov(ss, ax)
mov(fs, ax)
mov(gs, ax)

mov(esp, 0x90000)

cld
```

At this point you are in protected mode with a known stack.

---

# 13. Copy kernel to 0x100000

First chunk:

```mc
mov(esi, 0x00010000)
mov(edi, 0x00100000)
mov(ecx, 49152)

rep_movsb
```

Second chunk:

```mc
mov(esi, 0x00020000)
mov(edi, 0x0010C000)
mov(ecx, 49152)

rep_movsb
```

Memory picture:

```text
0x10000 ────────┐
                ├────▶ 0x100000+
0x20000 ────────┘
```

---

# 14. Clear page-table memory

Your current simple paging setup can use:

```text
0x1000
0x2000
0x3000
```

Clear it first:

```mc
xor(eax, eax)

mov(edi, 0x1000)
mov(ecx, 0x3000)

rep_stosb
```

---

# 15. Build identity mapping

Minimal entries:

```mc
store32(0x1000, 0x00002003)
store32(0x1004, 0x00000000)

store32(0x2000, 0x00003003)
store32(0x2004, 0x00000000)

store32(0x3000, 0x00000083)
store32(0x3004, 0x00000000)
```

This gives you a simple low-memory mapping using a 2 MiB page.

Later the kernel can extend the mapping to more low memory.

---

# 16. Load CR3

```mc
mov(eax, 0x1000)
mov(cr3, eax)
```

Now the CPU knows where the top-level paging structure begins.

---

# 17. Enable PAE

```mc
mov(eax, cr4)
or(eax, 0x20)
mov(cr4, eax)
```

---

# 18. Enable long-mode capability

Use EFER:

```mc
mov(ecx, 0xC0000080)

rdmsr

or(eax, 0x00000100)

wrmsr
```

This sets `LME`.

---

# 19. Enable paging

```mc
mov(eax, cr0)
or(eax, 0x80000000)
mov(cr0, eax)
```

Then far jump to the 64-bit code selector:

```mc
jmp_far(0x18, long_mode_entry)
```

---

# 20. Enter 64-bit mode

```mc
bits64

label(long_mode_entry)

mov(ax, 0x10)

mov(ds, ax)
mov(es, ax)
mov(ss, ax)

mov(rsp, 0x90000)
mov(rbp, rsp)
```

Now the CPU is in long mode.

---

# 21. Jump to the kernel

```mc
mov(rax, 0x100000)
jmp_reg(rax)
```

This is the moment the bootloader hands control to your kernel.

Boot path:

```text
BIOS
 ↓
0x7C00
 ↓
0x8000
 ↓
32-bit protected mode
 ↓
paging
 ↓
64-bit long mode
 ↓
0x100000
```

---

# 22. Minimal kernel

Start ridiculously small.

```mc
head(custom) {
    fn main() {
        while (1 == 1) {
        }
    }
}
```

That proves almost nothing visually, so add a memory write next.

---

# 23. VGA clear helper

Your current graphics path uses VGA memory around:

```text
0xA0000
```

A minimal memory-fill function:

```mc
head(custom) {
    fn mem_set(I64 dest, I64 value, I64 size) {
        I64 i = 0

        while (i < size) {
            mem_write8(dest + i, value & 255)
            i = i + 1
        }

        return dest
    }

    fn main() {
        mem_set(0xA0000, 0, 38400)

        while (1 == 1) {
        }
    }
}
```

That alone is not a full planar-VGA color setup, but it is a useful first memory test.

---

# 24. VGA register helper

For planar VGA work, you need port output.

A graphics-controller helper:

```mc
fn gc_write(I64 index, I64 value) {
    port_out8(0x3CE, index)
    port_out8(0x3CF, value)

    return 0
}
```

Palette helper:

```mc
fn dac_color(I64 index, I64 r, I64 g, I64 b) {
    port_out8(0x3C8, index)
    port_out8(0x3C9, r)
    port_out8(0x3C9, g)
    port_out8(0x3C9, b)

    return 0
}
```

---

# 25. Initialize a small palette

```mc
fn palette_init() {
    dac_color(0, 0, 0, 0)
    dac_color(1, 0, 0, 42)
    dac_color(2, 0, 35, 0)
    dac_color(4, 42, 0, 0)
    dac_color(15, 63, 63, 63)

    return 0
}
```

Then:

```mc
fn vga_init() {
    gc_write(1, 0x0F)
    gc_write(3, 0)
    gc_write(5, 0)
    gc_write(8, 0xFF)

    palette_init()

    return 0
}
```

---

# 26. Plot one pixel

For 640×480 planar VGA:

```mc
fn set_color(I64 color) {
    gc_write(0, color & 15)
    gc_write(1, 0x0F)

    return 0
}

fn set_mask(I64 mask) {
    gc_write(8, mask & 255)

    return 0
}
```

Pixel helper:

```mc
fn plot_current(I64 x, I64 y) {
    if (x < 0) {
        return 0
    }

    if (y < 0) {
        return 0
    }

    if (x >= 640) {
        return 0
    }

    if (y >= 480) {
        return 0
    }

    I64 address = 0xA0000 + y * 80 + (x >> 3)
    I64 mask = 0x80 >> (x & 7)

    set_mask(mask)

    mem_read8(address)
    mem_write8(address, 0xFF)

    return 0
}
```

Wrapper:

```mc
fn plot(I64 x, I64 y, I64 color) {
    set_color(color)
    return plot_current(x, y)
}
```

Now your kernel can make one visible dot.

That is already much easier to debug than a full terminal.

---

# 27. Horizontal line

```mc
fn hline(I64 x, I64 y, I64 width, I64 color) {
    I64 i = 0

    set_color(color)

    while (i < width) {
        plot_current(x + i, y)
        i = i + 1
    }

    return 0
}
```

Vertical line:

```mc
fn vline(I64 x, I64 y, I64 height, I64 color) {
    I64 i = 0

    set_color(color)

    while (i < height) {
        plot_current(x, y + i)
        i = i + 1
    }

    return 0
}
```

Rectangle:

```mc
fn rect(I64 x, I64 y, I64 width, I64 height, I64 color) {
    hline(x, y, width, color)
    hline(x, y + height - 1, width, color)

    vline(x, y, height, color)
    vline(x + width - 1, y, height, color)

    return 0
}
```

---

# 28. Kernel memory constants

Do not scatter raw addresses everywhere.

Prefer:

```mc
fn HEAP_START() {
    return 0x120000
}

fn HEAP_END() {
    return 0x180000
}

fn TERM_BUFFER() {
    return 0x183000
}

fn SHELL_BUFFER() {
    return 0x186000
}
```

Then use:

```mc
mem_write8(TERM_BUFFER(), 65)
```

instead of:

```mc
mem_write8(0x183000, 65)
```

The first version explains itself.

---

# 29. Tiny fixed-block allocator

A first allocator can be intentionally simple.

Constants:

```mc
fn HEAP_START() {
    return 0x120000
}

fn HEAP_BLOCK_SIZE() {
    return 256
}

fn HEAP_BITMAP() {
    return 0x182000
}

fn HEAP_BLOCKS() {
    return 1536
}
```

Find a free block:

```mc
fn heap_alloc_block() {
    I64 i = 0

    while (i < HEAP_BLOCKS()) {
        if (mem_read8(HEAP_BITMAP() + i) == 0) {
            mem_write8(HEAP_BITMAP() + i, 1)

            return HEAP_START() + i * HEAP_BLOCK_SIZE()
        }

        i = i + 1
    }

    return 0
}
```

Free:

```mc
fn heap_free_block(I64 address) {
    if (address < HEAP_START()) {
        return 0
    }

    I64 index = (address - HEAP_START()) / HEAP_BLOCK_SIZE()

    if (index >= HEAP_BLOCKS()) {
        return 0
    }

    mem_write8(HEAP_BITMAP() + index, 0)

    return 1
}
```

This is not a fancy allocator.

That is exactly why it is good for a first kernel.

---

# 30. String length

Useful kernel helper:

```mc
fn str_len(I64 text) {
    I64 n = 0

    while (mem_read8(text + n) != 0) {
        n = n + 1
    }

    return n
}
```

String equality:

```mc
fn str_eq(I64 a, I64 b) {
    I64 i = 0

    while (1 == 1) {
        I64 ac = mem_read8(a + i)
        I64 bc = mem_read8(b + i)

        if (ac != bc) {
            return 0
        }

        if (ac == 0) {
            return 1
        }

        i = i + 1
    }

    return 0
}
```

These become useful for shell commands and filesystem names later.

---

# 31. Memory copy

```mc
fn mem_copy(I64 dest, I64 src, I64 size) {
    I64 i = 0

    while (i < size) {
        mem_write8(dest + i, mem_read8(src + i))
        i = i + 1
    }

    return dest
}
```

Memory move:

```mc
fn mem_move(I64 dest, I64 src, I64 size) {
    if (dest <= src) {
        return mem_copy(dest, src, size)
    }

    I64 i = size

    while (i > 0) {
        i = i - 1

        mem_write8(
            dest + i,
            mem_read8(src + i)
        )
    }

    return dest
}
```

These are core OS building blocks.

---

# 32. Keyboard learning path

Do not begin with full text input.

Start with:

```text
read one scancode
 ↓
print / display numeric value
 ↓
map one key
 ↓
map alphabet
 ↓
Shift
 ↓
Caps Lock
 ↓
layout
```

A helper shape:

```mc
fn keyboard_read_scancode() {
    return port_in8(0x60)
}
```

Then test the raw value before creating a complete keyboard driver.

---

# 33. Page more than the first 2 MiB

Once the kernel itself runs, map more low memory.

Your current simple kernel pattern can use 2 MiB pages:

```mc
fn map_low_16mb() {
    I64 index = 0

    while (index < 8) {
        I64 physical = index * 0x200000

        mem_write64(
            0x3000 + index * 8,
            physical | 0x83
        )

        index = index + 1
    }

    cpu_write_cr3(0x1000)

    return 0
}
```

Math:

```text
8 pages × 2 MiB = 16 MiB
```

That covers:

```text
0x000000 - 0xFFFFFF
```

---

# 34. Minimal kernel main

A useful early kernel can be:

```mc
head(custom) {
    fn main() {
        map_low_16mb()

        vga_init()

        plot(100, 100, 12)

        rect(120, 120, 100, 60, 15)

        while (1 == 1) {
        }
    }
}
```

That gives you:

```text
boot
 ↓
64-bit kernel
 ↓
paging
 ↓
VGA init
 ↓
pixel
 ↓
rectangle
```

This is already a real tiny OS kernel.

---

# 35. Build commands

Compile:

```bash
./mcc stage1.mc -o stage1.bin
./mcc stage2.mc -o stage2.bin
./mcc kernel.mc -o kernel.bin
```

Check size:

```bash
wc -c stage1.bin stage2.bin kernel.bin
```

Stage1 must be:

```text
512 bytes
```

Create image:

```bash
dd if=/dev/zero of=os.img bs=512 count=32768
```

Write stage1:

```bash
dd if=stage1.bin of=os.img bs=512 seek=0 conv=notrunc
```

Write stage2:

```bash
dd if=stage2.bin of=os.img bs=512 seek=1 conv=notrunc
```

Write kernel to the LBAs expected by stage2.

The `dd seek=` values and DAP LBAs must match.

---

# 36. Run

```bash
qemu-system-x86_64 \
  -drive file=os.img,format=raw \
  -m 512M
```

---

# 37. Debug markers

Keep tiny boot markers while learning:

```text
1 = stage1
2 = stage2
P = protected mode
L = long mode
K = kernel
```

If you see:

```text
12P
```

you know exactly which part to inspect next.

A black screen contains zero information.

A three-character breadcrumb trail contains a map.

---

# Minimal OS roadmap

```text
01 stage1 boots
02 stage1 loads stage2
03 stage2 loads kernel
04 protected mode
05 paging
06 long mode
07 jump to 0x100000
08 visible pixel
09 basic text
10 keyboard
11 timer / interrupts
12 heap
13 filesystem
14 shell
15 editor
16 compiler inside OS
```

Do them in that order and each new layer has something underneath it you already trust.
