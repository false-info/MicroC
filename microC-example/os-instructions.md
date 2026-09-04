# Building a Minimal OS in MicroC

This guide describes a small BIOS x86 boot path using MicroC's integrated x86-16, x86-32, and x86-64 assembly support.

The target is deliberately tiny:

> BIOS → stage1 → stage2 → long mode → MicroC kernel

Do not begin with a GUI, filesystem, editor, shell, compiler, USB, or networking.

First make the CPU reach the kernel reliably.

---

# The complete path

<table>
<tr>
<td align="center"><b>BIOS</b></td>
<td align="center">→</td>
<td align="center"><b>stage1</b><br><code>0x7C00</code></td>
<td align="center">→</td>
<td align="center"><b>stage2</b><br><code>0x8000</code></td>
<td align="center">→</td>
<td align="center"><b>32-bit setup</b></td>
<td align="center">→</td>
<td align="center"><b>64-bit mode</b></td>
<td align="center">→</td>
<td align="center"><b>kernel</b><br><code>0x100000</code></td>
</tr>
</table>

---

# Files

A minimal project can be:

```text
minimal-os/
├── stage1.mc
├── stage2.mc
├── kernel.mc
└── os.img
```

Optional later:

```text
├── memory.md
├── serial.mc
├── keyboard.mc
└── heap.mc
```

Keep the first three files small.

---

# Stage 1 — BIOS boot sector

BIOS loads the first boot sector at:

```text
0x7C00
```

The first stage should do almost nothing:

1. initialize basic segment registers
2. keep the BIOS boot-drive number
3. load stage2 from disk
4. jump to stage2
5. end with `55 AA`

MicroC head:

```mc
head(asm-x86-16) {
    (asmb) {
        org(0x7C00)
        bits16

        ...
    } (asme)
}
```

Your current MicroC assembler provides boot helpers such as:

```text
pad_boot
sign_boot
```

A valid BIOS stage1 must finish as exactly one 512-byte sector with the boot signature at the end.

### Memory picture

```text
0x0000
   │
   │ conventional memory
   │
0x7C00 ┌───────────────────┐
       │ stage1            │
       │ BIOS boot sector  │
0x7DFF └───────────────────┘
   │
0x8000 ┌───────────────────┐
       │ stage2            │
       └───────────────────┘
```

### First checkpoint

Before loading anything else, prove stage1 runs by printing one character through BIOS interrupt `0x10`.

Then remove or keep that character as a debug marker.

---

# Stage 2 — Load the kernel

Stage2 starts in 16-bit real mode.

Your current architecture form can be:

```mc
head(asm-x86-16 asm-x86-32 asm-x86-64) {
    (asmb) {
        org(0x8000)

        bits16
        ...
        bits32
        ...
        bits64
        ...
    } (asme)
}
```

Stage2 has four jobs:

```text
load kernel
    ↓
enable protected mode
    ↓
build paging + enable long mode
    ↓
jump to kernel
```

Do not make stage2 into a kernel.

---

# Stage 3 — Load kernel bytes

A simple BIOS disk-load path uses interrupt `0x13`.

While still in real mode:

```text
disk
  │
  ▼
temporary low-memory buffer
```

Then, once protected mode is available:

```text
temporary buffer
       │
       ▼
0x100000 kernel destination
```

Your current boot design uses temporary chunks around:

```text
0x10000
0x20000
```

and copies them to the kernel starting at:

```text
0x100000
```

Why not ask BIOS to write directly everywhere?

Because BIOS disk services operate under real-mode addressing constraints. A low temporary buffer keeps stage2 simple.

---

# Stage 4 — Enable A20

Before relying on addresses above 1 MiB, enable A20.

Conceptually:

```text
20-bit wraparound OFF
         ↓
addresses above 0xFFFFF become distinct
```

Do this before copying the kernel to `0x100000`.

---

# Stage 5 — Build a GDT

To enter protected mode, create a Global Descriptor Table.

Minimal entries:

```text
null
32-bit code
32-bit data
64-bit code
```

Then:

```text
lgdt
set CR0.PE
far jump to 32-bit code selector
```

The far jump is important because it reloads the code segment using the new descriptor table.

---

# Stage 6 — Enter 32-bit protected mode

After the far jump:

```text
bits32
```

Load data selectors:

```text
DS
ES
SS
FS
GS
```

Set a known stack:

```text
ESP = 0x90000
```

Now you have a much easier environment for copying the kernel and preparing page tables.

---

# Stage 7 — Copy kernel to 1 MiB

The minimal kernel base:

```text
0x100000
```

Conceptual copy:

```text
0x10000 ─────┐
             ├──▶ 0x100000+
0x20000 ─────┘
```

Do not overwrite:

```text
0x1000-0x3FFF   page tables
0x7C00          stage1
0x8000          stage2
0x90000 ↓       stack
0xA0000+        legacy VGA / video region
```

---

# Stage 8 — Build page tables

For a tiny identity-mapped kernel, begin with:

```text
virtual address == physical address
```

So:

```text
0x100000 virtual
      ↓
0x100000 physical
```

A minimal hierarchy can place paging structures at:

```text
0x1000
0x2000
0x3000
```

Using 2 MiB pages makes the first mapping much simpler.

To identity-map the first 16 MiB:

```text
8 × 2 MiB pages = 16 MiB
```

That is enough for the current low-memory SuperNovaOS layout.

---

# Stage 9 — Enable long mode

The conceptual sequence:

```text
load CR3
   ↓
enable PAE in CR4
   ↓
set EFER.LME
   ↓
enable paging in CR0
   ↓
far jump to 64-bit code selector
```

Then:

```text
bits64
```

Set:

```text
RSP = 0x90000
RBP = RSP
```

and jump to:

```text
0x100000
```

---

# Stage 10 — Minimal kernel

The first kernel does not need a terminal.

It needs proof of life.

Possible first proofs:

```text
write one visible byte
or
write one VGA pixel
or
write one serial character
or
halt at a known point
```

Keep the first `kernel.mc` tiny:

```mc
head(custom) {
    fn main() {
        // prove kernel execution here
        while (1 == 1) {
        }
    }
}
```

The exact entry convention depends on how the MicroC raw kernel image is emitted, so verify the generated entry before assuming `main` is at byte zero.

---

# Stage 11 — Add screen output

Once boot is reliable, add one output path.

For the current VGA graphics path, memory begins at:

```text
0xA0000
```

But do not start with a complete GUI.

Recommended order:

```text
clear screen
   ↓
plot pixel
   ↓
horizontal line
   ↓
rectangle
   ↓
font glyph
   ↓
text
```

Each step gives you something visible to debug.

---

# Stage 12 — Keyboard

A keyboard driver introduces:

```text
I/O ports
scancodes
modifier state
character conversion
```

Start by reading a key and printing its raw scancode.

Only later add:

```text
Shift
Caps Lock
layout
AltGr
```

Do not debug keyboard layout and hardware input simultaneously.

---

# Stage 13 — Interrupts

A more complete kernel eventually needs:

```text
IDT
interrupt handlers
PIC/APIC setup
timer
keyboard IRQ
```

Do this after basic polling works.

Why?

Because:

```text
polling bug
```

is much easier to isolate than:

```text
IDT + PIC + handler + stack + acknowledgement bug
```

all at once.

---

# Stage 14 — Memory allocator

Do not begin with a clever allocator.

First define a safe heap region.

In the current SuperNovaOS layout:

```text
0x120000 - 0x17FFFF
```

is the kernel heap.

A simple first allocator can divide it into fixed-size blocks.

Mental model:

```text
heap
┌────┬────┬────┬────┬────┬────┐
│free│used│free│free│used│free│
└────┴────┴────┴────┴────┴────┘
          ▲
        bitmap
```

Build:

```text
alloc
free
bounds checking
```

before attempting more complex memory management.

---

# Stage 15 — Minimal filesystem

Only after disk reads are reliable.

Build in this order:

```text
read sector
    ↓
write sector
    ↓
fixed directory
    ↓
find file
    ↓
read file
    ↓
write file
```

A full filesystem should not be required just to boot the kernel.

---

# Building the files

Compile raw boot components:

```bash
./mcc stage1.mc -o stage1.bin
./mcc stage2.mc -o stage2.bin
./mcc kernel.mc -o kernel.bin
```

Verify sizes:

```bash
wc -c stage1.bin stage2.bin kernel.bin
```

Stage1 should be:

```text
512 bytes
```

Create a blank image, for example:

```bash
dd if=/dev/zero of=os.img bs=512 count=32768
```

Write stage1 to sector 0:

```bash
dd if=stage1.bin of=os.img conv=notrunc bs=512 seek=0
```

Write stage2 after it:

```bash
dd if=stage2.bin of=os.img conv=notrunc bs=512 seek=1
```

Then place the kernel at the sectors expected by your stage2 DAP.

**The disk LBAs in stage2 and the `dd seek=` values must agree exactly.**

---

# Run in QEMU

Basic command:

```bash
qemu-system-x86_64 \
  -drive file=os.img,format=raw \
  -m 512M
```

For serial debugging, once your kernel supports it:

```bash
qemu-system-x86_64 \
  -drive file=os.img,format=raw \
  -m 512M \
  -serial stdio
```

---

# Debug markers

During boot, one-character markers are gold.

Example plan:

```text
1   stage1 started
2   stage2 started
P   protected mode reached
L   long mode reached
K   kernel reached
```

Then if the machine shows:

```text
12P
```

you immediately know the failure is between protected mode and long mode.

This beats staring at a black screen and negotiating with the void.

---

# Minimal OS milestones

| Version | Goal |
|---|---|
| v0 | BIOS executes stage1 |
| v1 | stage1 loads stage2 |
| v2 | stage2 loads kernel bytes |
| v3 | protected mode |
| v4 | page tables |
| v5 | long mode |
| v6 | jump to `0x100000` |
| v7 | visible kernel output |
| v8 | keyboard input |
| v9 | interrupts / timer |
| v10 | heap |
| v11 | simple filesystem |
| v12 | shell / editor |
| v13 | compiler running inside the OS |

Do not jump from v1 directly to v13.

---

# Memory addresses to remember

| Address | Meaning |
|---|---|
| `0x1000` | page-table area begins |
| `0x7C00` | BIOS stage1 |
| `0x8000` | stage2 |
| `0x90000` | bootstrap stack top |
| `0xA0000` | VGA graphics area |
| `0x100000` | kernel base |
| `0x120000` | kernel heap start |
| `0x180000` | kernel state region |
| `0x1FF000` | current ABI table |
| `0x400000` | program area |
| `0x800000` | MicroC compiler workspace in current OS map |
| `0xC00000` | JIT output |
| `0xD00000` | AOT output |

Use the repository's address-helper document before assigning new fixed memory.

---

# When the screen is black

Debug in this order:

```text
Did BIOS run stage1?
        ↓
Did stage1 read stage2?
        ↓
Did stage2 read kernel sectors?
        ↓
Did protected mode work?
        ↓
Are page tables correct?
        ↓
Did long mode activate?
        ↓
Is RSP valid?
        ↓
Did the jump reach 0x100000?
        ↓
Is the generated kernel code valid?
```

Never debug all eight at once.

---

# Final minimal definition

A minimal MicroC OS is complete when:

```text
BIOS
  ↓
MicroC stage1
  ↓
MicroC stage2
  ↓
x86-64 long mode
  ↓
MicroC kernel
  ↓
visible proof of execution
```

Everything after that is operating-system development rather than bootstrapping.
