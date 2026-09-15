# MicroC Examples

This README is a complete learning path for the current MicroC syntax.

Every section contains the full reference code for the matching `.mc` file. Try to build each example yourself first, then compare your version with the code here.

## Current syntax

```mc
head(custom)

fn main() {
    pin("Hello from MicroC!\n")
    return 0
}
```

Feature heads are separate top-level statements:

```mc
head(custom)
head(memory)
head(math)
head(time)
head(graphics)
head(networking)
```

Do not wrap the program inside `head(custom) { ... }`.

## Folder layout

```text
microC-example/
├── 01-basics/
│   ├── 01-hello.mc
│   ├── 02-variables.mc
│   ├── 03-arithmetic.mc
│   ├── 04-if-else.mc
│   ├── 05-while.mc
│   ├── 06-functions.mc
│   ├── 07-bool-logic.mc
│   ├── 08-types-and-cast.mc
│   ├── 09-strings.mc
│   └── 10-fizzbuzz.mc
├── 02-math-time/
│   ├── 01-sqrt.mc
│   ├── 02-hypot.mc
│   ├── 03-constants.mc
│   ├── 04-clamp-lerp.mc
│   ├── 05-sin-cos.mc
│   ├── 06-atan2.mc
│   ├── 07-normalize-vector.mc
│   ├── 08-degrees-radians.mc
│   ├── 09-monotonic-time.mc
│   └── 10-orbit-math.mc
├── 03-memory/
│   ├── 01-alloc-free.mc
│   ├── 02-read-write-widths.mc
│   ├── 03-calloc.mc
│   ├── 04-realloc.mc
│   ├── 05-byte-array.mc
│   ├── 06-copy-buffer.mc
│   ├── 07-fill-buffer.mc
│   ├── 08-struct-layout.mc
│   ├── 09-stack.mc
│   └── 10-arena.mc
├── 04-graphics-2d/
│   ├── 01-window.mc
│   ├── 02-pixels.mc
│   ├── 03-lines.mc
│   ├── 04-rectangles.mc
│   ├── 05-gradient.mc
│   ├── 06-grid-2d.mc
│   ├── 07-circle.mc
│   ├── 08-bouncing-box.mc
│   ├── 09-orbit-2d.mc
│   └── 10-two-body-2d.mc
├── 05-graphics-3d/
│   ├── 11-perspective-point.mc
│   ├── 12-perspective-grid.mc
│   ├── 13-rotating-3d-point.mc
│   ├── 14-wireframe-cube.mc
│   ├── 15-3d-axis.mc
│   ├── 16-starfield-3d.mc
│   ├── 17-orbit-3d.mc
│   ├── 18-height-mesh.mc
│   ├── 19-gravity-mesh.mc
│   └── 20-mini-3d-scene.mc
├── 06-networking/
│   ├── 01-create-socket.mc
│   ├── 02-loopback-address.mc
│   ├── 03-local-tcp-bind.mc
│   ├── 04-local-tcp-listen.mc
│   ├── 05-local-tcp-client.mc
│   ├── 06-local-tcp-send.mc
│   ├── 07-local-tcp-echo-server.mc
│   ├── 08-udp-loopback-send.mc
│   ├── 09-socket-reuse.mc
│   └── 10-poll.mc
├── 07-red-team/
│   ├── 50-scope-check.mc
│   ├── 51-local-port-probe.mc
│   ├── 52-local-port-inventory.mc
│   ├── 53-local-banner-reader.mc
│   ├── 54-http-request-builder.mc
│   ├── 55-http-status-parser.mc
│   ├── 56-http-header-counter.mc
│   ├── 57-file-magic.mc
│   ├── 58-hexdump.mc
│   ├── 59-string-extractor.mc
│   ├── 60-fnv-fingerprint.mc
│   ├── 61-integrity-check.mc
│   ├── 62-input-boundary-test.mc
│   ├── 63-toy-parser-fuzzer.mc
│   ├── 64-canary-check.mc
│   ├── 65-failed-login-counter.mc
│   ├── 66-rate-limit-simulator.mc
│   ├── 67-path-traversal-detector.mc
│   ├── 68-protocol-be-parser.mc
│   ├── 69-finding-score.mc
│   └── 70-report-summary.mc
├── 08-compiler/
│   ├── 01-source.mc
│   ├── 02-next-char.mc
│   ├── 03-peek-char.mc
│   ├── 04-char-classes.mc
│   ├── 05-skip-whitespace.mc
│   ├── 06-read-number.mc
│   ├── 07-read-identifier.mc
│   ├── 08-token-kinds.mc
│   ├── 09-next-token.mc
│   ├── 10-keywords.mc
│   ├── 11-token-structure.mc
│   ├── 12-parser-cursor.mc
│   ├── 13-parse-primary.mc
│   ├── 14-parse-addition.mc
│   ├── 15-expression-precedence.mc
│   ├── 16-symbol-table.mc
│   ├── 17-emitter-buffer.mc
│   ├── 18-emit-mov-return.mc
│   ├── 19-compile-return.mc
│   └── 20-mini-compiler.mc
└── README.md
```

## Learning order

| Folder | Examples | What you learn |
| --- | ---: | --- |
| `01-basics` | 10 | Core syntax, variables, branches, loops, functions and strings. |
| `02-math-time` | 10 | Floating-point math, vectors, trigonometry and clocks. |
| `03-memory` | 10 | Managed memory, arrays, layouts and small allocators. |
| `04-graphics-2d` | 10 | Framebuffer basics, shapes, animation and 2D gravity. |
| `05-graphics-3d` | 10 | Perspective projection and software 3D built on the 2D graphics API. |
| `06-networking` | 10 | Sockets, localhost TCP/UDP, sending, receiving and polling. |
| `07-red-team` | 21 | Authorized localhost/offline security exercises numbered 50 through 70. |
| `08-compiler` | 20 | Twenty steps from reading source text to emitting a tiny x86 binary. |

Compile an example from the repository root:

```bash
./mcc microC-example/01-basics/01-hello.mc -o hello
./hello
```

For hosted graphics, your current window backend uses `ffplay`.

## Red-team rule

The red-team folder is for systems you own or have explicit permission to test. The examples are intentionally limited to localhost or offline data so you can learn the workflow safely.

---

<details>
<summary><strong>📁 01 - Basics</strong></summary>

Core syntax, variables, branches, loops, functions and strings.

<details>
<summary><strong>01 - 01-hello.mc</strong></summary>

### Goal

Write the smallest useful MicroC program.

### Code

```mc
head(custom)

fn main() {
    pin("Hello from MicroC!\n")
    return 0
}
```

</details>

<details>
<summary><strong>02 - 02-variables.mc</strong></summary>

### Goal

Create signed, unsigned, floating-point and boolean variables.

### Code

```mc
head(custom)

fn main() {
    I64 signed_value = -42
    U64 unsigned_value = 42
    F64 gravity = 9.81
    Bool running = true

    pin("signed = %I64\n", signed_value)
    pin("unsigned = %U64\n", unsigned_value)
    pin("gravity = %F64\n", gravity)
    pin("running = %I64\n", running)

    return 0
}
```

</details>

<details>
<summary><strong>03 - 03-arithmetic.mc</strong></summary>

### Goal

Use integer arithmetic and precedence.

### Code

```mc
head(custom)

fn main() {
    I64 a = 20
    I64 b = 5

    pin("add = %I64\n", a + b)
    pin("sub = %I64\n", a - b)
    pin("mul = %I64\n", a * b)
    pin("div = %I64\n", a / b)
    pin("mod = %I64\n", a % b)
    pin("precedence = %I64\n", 2 + 3 * 4)

    return 0
}
```

</details>

<details>
<summary><strong>04 - 04-if-else.mc</strong></summary>

### Goal

Choose between branches.

### Code

```mc
head(custom)

fn main() {
    I64 temperature = 27

    if (temperature >= 25) {
        pin("warm\n")
    }
    else {
        pin("cool\n")
    }

    return 0
}
```

</details>

<details>
<summary><strong>05 - 05-while.mc</strong></summary>

### Goal

Build a basic loop.

### Code

```mc
head(custom)

fn main() {
    I64 i = 0

    while (i < 10) {
        pin("%I64\n", i)
        i = i + 1
    }

    return 0
}
```

</details>

<details>
<summary><strong>06 - 06-functions.mc</strong></summary>

### Goal

Create and call functions.

### Code

```mc
head(custom)

fn add(I64 a, I64 b) {
    return a + b
}

fn multiply(I64 a, I64 b) {
    return a * b
}

fn main() {
    I64 x = add(10, 5)
    I64 y = multiply(x, 3)

    pin("result = %I64\n", y)

    return 0
}
```

</details>

<details>
<summary><strong>07 - 07-bool-logic.mc</strong></summary>

### Goal

Use boolean logic.

### Code

```mc
head(custom)

fn main() {
    I64 age = 15
    I64 has_key = 1

    if ((age >= 13) && (has_key != 0)) {
        pin("condition true\n")
    }

    if ((age < 13) || (has_key == 0)) {
        pin("alternative condition true\n")
    }
    else {
        pin("alternative condition false\n")
    }

    return 0
}
```

</details>

<details>
<summary><strong>08 - 08-types-and-cast.mc</strong></summary>

### Goal

Convert between numeric types.

### Code

```mc
head(custom)

fn main() {
    I64 integer = 42
    F64 floating = cast(F64, integer)
    I64 back = cast(I64, floating)

    pin("integer = %I64\n", integer)
    pin("floating = %F64\n", floating)
    pin("back = %I64\n", back)

    return 0
}
```

</details>

<details>
<summary><strong>09 - 09-strings.mc</strong></summary>

### Goal

Work with strings, length and comparison.

### Code

```mc
head(custom)

fn main() {
    I64 text = "MicroC"
    I64 length = strlen(text)

    pin("text = %s\n", text)
    pin("length = %I64\n", length)

    if (strcmp(text, "MicroC") == 0) {
        pin("strings match\n")
    }

    return 0
}
```

</details>

<details>
<summary><strong>10 - 10-fizzbuzz.mc</strong></summary>

### Goal

Combine loops, modulo and nested conditions.

### Code

```mc
head(custom)

fn main() {
    I64 i = 1

    while (i <= 30) {
        if ((i % 15) == 0) {
            pin("FizzBuzz\n")
        }
        else {
            if ((i % 3) == 0) {
                pin("Fizz\n")
            }
            else {
                if ((i % 5) == 0) {
                    pin("Buzz\n")
                }
                else {
                    pin("%I64\n", i)
                }
            }
        }

        i = i + 1
    }

    return 0
}
```

</details>

---

</details>

<details>
<summary><strong>📁 02 - Math & Time</strong></summary>

Floating-point math, vectors, trigonometry and clocks.

<details>
<summary><strong>01 - 01-sqrt.mc</strong></summary>

### Goal

Calculate square roots.

### Code

```mc
head(custom)
head(math)

fn main() {
    F64 value = math_sqrt(144.0)

    pin("sqrt = %F64\n", value)

    return 0
}
```

</details>

<details>
<summary><strong>02 - 02-hypot.mc</strong></summary>

### Goal

Calculate a 2D distance.

### Code

```mc
head(custom)
head(math)

fn main() {
    F64 x = 3.0
    F64 y = 4.0
    F64 distance = math_hypot(x, y)

    pin("distance = %F64\n", distance)

    return 0
}
```

</details>

<details>
<summary><strong>03 - 03-constants.mc</strong></summary>

### Goal

Use pi, tau and e.

### Code

```mc
head(custom)
head(math)

fn main() {
    F64 pi = math_pi()
    F64 tau = math_tau()
    F64 e = math_e()

    pin("pi = %F64\n", pi)
    pin("tau = %F64\n", tau)
    pin("e = %F64\n", e)

    return 0
}
```

</details>

<details>
<summary><strong>04 - 04-clamp-lerp.mc</strong></summary>

### Goal

Clamp values and interpolate between two numbers.

### Code

```mc
head(custom)
head(math)

fn main() {
    F64 value = math_clamp(15.0, 0.0, 10.0)
    F64 halfway = math_lerp(10.0, 20.0, 0.5)

    pin("clamp = %F64\n", value)
    pin("lerp = %F64\n", halfway)

    return 0
}
```

</details>

<details>
<summary><strong>05 - 05-sin-cos.mc</strong></summary>

### Goal

Generate points on a circle.

### Code

```mc
head(custom)
head(math)

fn main() {
    F64 angle = 0.0

    while (angle < math_tau()) {
        F64 x = math_cos(angle) * 100.0
        F64 y = math_sin(angle) * 100.0

        pin("x=%F64 y=%F64\n", x, y)

        angle = angle + 0.5
    }

    return 0
}
```

</details>

<details>
<summary><strong>06 - 06-atan2.mc</strong></summary>

### Goal

Calculate an angle from a vector.

### Code

```mc
head(custom)
head(math)

fn main() {
    F64 x = 1.0
    F64 y = 1.0

    F64 angle = math_atan2(y, x)
    F64 degrees = math_rad_to_deg(angle)

    pin("angle = %F64 degrees\n", degrees)

    return 0
}
```

</details>

<details>
<summary><strong>07 - 07-normalize-vector.mc</strong></summary>

### Goal

Normalize a 3D vector with inverse square root.

### Code

```mc
head(custom)
head(math)

fn main() {
    F64 x = 3.0
    F64 y = 4.0
    F64 z = 12.0

    F64 length2 = x * x + y * y + z * z
    F64 inv_length = math_inv_sqrt(length2)

    x = x * inv_length
    y = y * inv_length
    z = z * inv_length

    pin("x=%F64 y=%F64 z=%F64\n", x, y, z)

    return 0
}
```

</details>

<details>
<summary><strong>08 - 08-degrees-radians.mc</strong></summary>

### Goal

Convert between degrees and radians.

### Code

```mc
head(custom)
head(math)

fn main() {
    F64 degrees = 90.0
    F64 radians = math_deg_to_rad(degrees)
    F64 back = math_rad_to_deg(radians)

    pin("radians = %F64\n", radians)
    pin("degrees = %F64\n", back)

    return 0
}
```

</details>

<details>
<summary><strong>09 - 09-monotonic-time.mc</strong></summary>

### Goal

Measure elapsed time.

### Code

```mc
head(custom)
head(time)

fn main() {
    I64 start = time_monotonic_ms()

    sleep_ms(250)

    I64 finish = time_monotonic_ms()

    pin("elapsed = %I64 ms\n", finish - start)

    return 0
}
```

</details>

<details>
<summary><strong>10 - 10-orbit-math.mc</strong></summary>

### Goal

Combine time and trigonometry for orbital motion.

### Code

```mc
head(custom)
head(math)
head(time)

fn main() {
    F64 angle = 0.0
    I64 frame = 0

    while (frame < 20) {
        F64 x = math_cos(angle) * 120.0
        F64 y = math_sin(angle) * 120.0

        pin("frame=%I64 x=%F64 y=%F64\n", frame, x, y)

        angle = angle + 0.2
        frame = frame + 1

        sleep_ms(50)
    }

    return 0
}
```

</details>

---

</details>

<details>
<summary><strong>📁 03 - Memory</strong></summary>

Managed memory, arrays, layouts and small allocators.

<details>
<summary><strong>01 - 01-alloc-free.mc</strong></summary>

### Goal

Allocate and free managed memory.

### Code

```mc
head(custom)
head(memory)

fn main() {
    I64 buffer = safe_alloc(64)

    pin("length = %I64\n", safe_len(buffer))

    safe_free(buffer)

    return 0
}
```

</details>

<details>
<summary><strong>02 - 02-read-write-widths.mc</strong></summary>

### Goal

Read and write 8, 16, 32 and 64-bit values.

### Code

```mc
head(custom)
head(memory)

fn main() {
    I64 buffer = safe_alloc(32)

    safe_write8(buffer, 0, 0x12)
    safe_write16(buffer, 2, 0x3456)
    safe_write32(buffer, 4, 0x789ABCDE)
    safe_write64(buffer, 8, 0x123456789ABCDEF)

    pin("8  = %X64\n", safe_read8(buffer, 0))
    pin("16 = %X64\n", safe_read16(buffer, 2))
    pin("32 = %X64\n", safe_read32(buffer, 4))
    pin("64 = %X64\n", safe_read64(buffer, 8))

    safe_free(buffer)

    return 0
}
```

</details>

<details>
<summary><strong>03 - 03-calloc.mc</strong></summary>

### Goal

Allocate zero-initialized memory.

### Code

```mc
head(custom)
head(memory)

fn main() {
    I64 buffer = safe_calloc(16, 1)

    I64 i = 0
    while (i < 16) {
        pin("%I64 ", safe_read8(buffer, i))
        i = i + 1
    }

    pin("\n")

    safe_free(buffer)

    return 0
}
```

</details>

<details>
<summary><strong>04 - 04-realloc.mc</strong></summary>

### Goal

Grow a managed allocation.

### Code

```mc
head(custom)
head(memory)

fn main() {
    I64 buffer = safe_alloc(4)

    safe_write8(buffer, 0, 10)
    safe_write8(buffer, 1, 20)
    safe_write8(buffer, 2, 30)
    safe_write8(buffer, 3, 40)

    buffer = safe_realloc(buffer, 16)

    pin("new length = %I64\n", safe_len(buffer))
    pin("first = %I64\n", safe_read8(buffer, 0))

    safe_free(buffer)

    return 0
}
```

</details>

<details>
<summary><strong>05 - 05-byte-array.mc</strong></summary>

### Goal

Use managed memory as an array.

### Code

```mc
head(custom)
head(memory)

fn main() {
    I64 array = safe_alloc(10)

    I64 i = 0
    while (i < 10) {
        safe_write8(array, i, i * 10)
        i = i + 1
    }

    i = 0
    while (i < 10) {
        pin("%I64\n", safe_read8(array, i))
        i = i + 1
    }

    safe_free(array)

    return 0
}
```

</details>

<details>
<summary><strong>06 - 06-copy-buffer.mc</strong></summary>

### Goal

Copy bytes between two allocations.

### Code

```mc
head(custom)
head(memory)

fn copy_buffer(I64 destination, I64 source, I64 count) {
    I64 i = 0

    while (i < count) {
        safe_write8(destination, i, safe_read8(source, i))
        i = i + 1
    }

    return 0
}

fn main() {
    I64 source = safe_alloc(8)
    I64 destination = safe_alloc(8)

    I64 i = 0
    while (i < 8) {
        safe_write8(source, i, i + 1)
        i = i + 1
    }

    copy_buffer(destination, source, 8)

    i = 0
    while (i < 8) {
        pin("%I64 ", safe_read8(destination, i))
        i = i + 1
    }

    pin("\n")

    safe_free(source)
    safe_free(destination)

    return 0
}
```

</details>

<details>
<summary><strong>07 - 07-fill-buffer.mc</strong></summary>

### Goal

Fill a region with one byte value.

### Code

```mc
head(custom)
head(memory)

fn fill_buffer(I64 buffer, I64 count, I64 value) {
    I64 i = 0

    while (i < count) {
        safe_write8(buffer, i, value)
        i = i + 1
    }

    return 0
}

fn main() {
    I64 buffer = safe_alloc(32)

    fill_buffer(buffer, 32, 65)

    I64 i = 0
    while (i < 32) {
        pin("%c", safe_read8(buffer, i))
        i = i + 1
    }

    pin("\n")

    safe_free(buffer)

    return 0
}
```

</details>

<details>
<summary><strong>08 - 08-struct-layout.mc</strong></summary>

### Goal

Lay out a small structure manually.

### Code

```mc
head(custom)
head(memory)

fn main() {
    I64 object = safe_alloc(24)

    safe_write64(object, 0, 100)
    safe_write64(object, 8, 200)
    safe_write64(object, 16, 300)

    I64 x = safe_read64(object, 0)
    I64 y = safe_read64(object, 8)
    I64 z = safe_read64(object, 16)

    pin("x=%I64 y=%I64 z=%I64\n", x, y, z)

    safe_free(object)

    return 0
}
```

</details>

<details>
<summary><strong>09 - 09-stack.mc</strong></summary>

### Goal

Build a tiny stack on top of managed memory.

### Code

```mc
head(custom)
head(memory)

fn main() {
    I64 stack = safe_alloc(80)
    I64 top = 0

    safe_write64(stack, top * 8, 10)
    top = top + 1

    safe_write64(stack, top * 8, 20)
    top = top + 1

    safe_write64(stack, top * 8, 30)
    top = top + 1

    while (top > 0) {
        top = top - 1
        pin("pop %I64\n", safe_read64(stack, top * 8))
    }

    safe_free(stack)

    return 0
}
```

</details>

<details>
<summary><strong>10 - 10-arena.mc</strong></summary>

### Goal

Build a tiny bump allocator inside one allocation.

### Code

```mc
head(custom)
head(memory)

fn main() {
    I64 arena = safe_alloc(256)
    I64 used = 0

    I64 object_a = used
    used = used + 32

    I64 object_b = used
    used = used + 64

    safe_write64(arena, object_a, 111)
    safe_write64(arena, object_b, 222)

    pin("A = %I64\n", safe_read64(arena, object_a))
    pin("B = %I64\n", safe_read64(arena, object_b))
    pin("used = %I64 bytes\n", used)

    safe_free(arena)

    return 0
}
```

</details>

---

</details>

<details>
<summary><strong>📁 04 - 2D Graphics</strong></summary>

Framebuffer basics, shapes, animation and 2D gravity.

These examples use `gfx_open`, `gfx_pixel`, `gfx_line`, `gfx_rect_fill`, `gfx_present` and the math/time heads where needed.

<details>
<summary><strong>01 - 01-window.mc</strong></summary>

### Goal

Open a graphics window and clear it.

### Code

```mc
head(custom)
head(graphics)
head(time)

fn main() {
    gfx_open(800, 500)
    gfx_clear(gfx_rgb(8, 10, 18))
    gfx_present()
    sleep_ms(1500)
    gfx_close()

    return 0
}
```

</details>

<details>
<summary><strong>02 - 02-pixels.mc</strong></summary>

### Goal

Draw individual pixels.

### Code

```mc
head(custom)
head(graphics)
head(time)

fn main() {
    gfx_open(800, 500)
    gfx_clear(gfx_rgb(0, 0, 0))

    I64 x = 100
    while (x < 700) {
        gfx_pixel(x, 250, gfx_rgb(255, 80, 20))
        x = x + 2
    }

    gfx_present()
    sleep_ms(1500)
    gfx_close()

    return 0
}
```

</details>

<details>
<summary><strong>03 - 03-lines.mc</strong></summary>

### Goal

Draw colored lines.

### Code

```mc
head(custom)
head(graphics)
head(time)

fn main() {
    gfx_open(800, 500)
    gfx_clear(gfx_rgb(0, 0, 0))

    gfx_line(50, 50, 750, 450, gfx_rgb(255, 80, 20))
    gfx_line(750, 50, 50, 450, gfx_rgb(40, 160, 255))
    gfx_line(50, 250, 750, 250, gfx_rgb(240, 240, 240))

    gfx_present()
    sleep_ms(1500)
    gfx_close()

    return 0
}
```

</details>

<details>
<summary><strong>04 - 04-rectangles.mc</strong></summary>

### Goal

Draw filled rectangles.

### Code

```mc
head(custom)
head(graphics)
head(time)

fn main() {
    gfx_open(800, 500)
    gfx_clear(gfx_rgb(5, 5, 8))

    gfx_rect_fill(100, 100, 180, 100, gfx_rgb(255, 70, 20))
    gfx_rect_fill(310, 160, 180, 100, gfx_rgb(40, 130, 255))
    gfx_rect_fill(520, 220, 180, 100, gfx_rgb(180, 60, 255))

    gfx_present()
    sleep_ms(1500)
    gfx_close()

    return 0
}
```

</details>

<details>
<summary><strong>05 - 05-gradient.mc</strong></summary>

### Goal

Render a simple horizontal gradient.

### Code

```mc
head(custom)
head(graphics)
head(time)

fn main() {
    gfx_open(800, 500)

    I64 x = 0
    while (x < 800) {
        I64 red = x * 255 / 799
        I64 blue = 255 - red
        I64 color = gfx_rgb(red, 30, blue)

        gfx_rect_fill(x, 0, 1, 500, color)

        x = x + 1
    }

    gfx_present()
    sleep_ms(1500)
    gfx_close()

    return 0
}
```

</details>

<details>
<summary><strong>06 - 06-grid-2d.mc</strong></summary>

### Goal

Render a 2D grid.

### Code

```mc
head(custom)
head(graphics)
head(time)

fn main() {
    gfx_open(800, 500)
    gfx_clear(gfx_rgb(0, 0, 0))

    I64 color = gfx_rgb(70, 75, 90)

    I64 x = 0
    while (x < 800) {
        gfx_line(x, 0, x, 499, color)
        x = x + 25
    }

    I64 y = 0
    while (y < 500) {
        gfx_line(0, y, 799, y, color)
        y = y + 25
    }

    gfx_present()
    sleep_ms(1500)
    gfx_close()

    return 0
}
```

</details>

<details>
<summary><strong>07 - 07-circle.mc</strong></summary>

### Goal

Rasterize a filled circle.

### Code

```mc
head(custom)
head(graphics)
head(time)

fn main() {
    gfx_open(800, 500)
    gfx_clear(gfx_rgb(0, 0, 0))

    I64 cx = 400
    I64 cy = 250
    I64 radius = 80

    I64 y = 0 - radius

    while (y <= radius) {
        I64 x = 0 - radius

        while (x <= radius) {
            if (x * x + y * y <= radius * radius) {
                gfx_pixel(cx + x, cy + y, gfx_rgb(255, 75, 20))
            }

            x = x + 1
        }

        y = y + 1
    }

    gfx_present()
    sleep_ms(1500)
    gfx_close()

    return 0
}
```

</details>

<details>
<summary><strong>08 - 08-bouncing-box.mc</strong></summary>

### Goal

Build a live 2D animation loop.

### Code

```mc
head(custom)
head(graphics)
head(time)

fn main() {
    gfx_open(800, 500)

    I64 x = 50
    I64 velocity = 5
    I64 running = 1

    while (running != 0) {
        gfx_clear(gfx_rgb(0, 0, 0))
        gfx_rect_fill(x, 220, 50, 50, gfx_rgb(255, 70, 20))

        if (gfx_present() < 0) {
            running = 0
        }

        x = x + velocity

        if (x >= 750) {
            velocity = 0 - velocity
        }

        if (x <= 0) {
            velocity = 0 - velocity
        }

        sleep_ms(16)
    }

    gfx_close()

    return 0
}
```

</details>

<details>
<summary><strong>09 - 09-orbit-2d.mc</strong></summary>

### Goal

Animate a point in a circular orbit.

### Code

```mc
head(custom)
head(graphics)
head(math)
head(time)

fn main() {
    gfx_open(800, 500)

    F64 angle = 0.0
    I64 running = 1

    while (running != 0) {
        gfx_clear(gfx_rgb(0, 0, 0))

        F64 xf = 400.0 + math_cos(angle) * 160.0
        F64 yf = 250.0 + math_sin(angle) * 160.0

        I64 x = cast(I64, xf)
        I64 y = cast(I64, yf)

        gfx_rect_fill(396, 246, 8, 8, gfx_rgb(255, 200, 30))
        gfx_rect_fill(x - 5, y - 5, 10, 10, gfx_rgb(255, 70, 20))

        if (gfx_present() < 0) {
            running = 0
        }

        angle = angle + 0.02
        sleep_ms(16)
    }

    gfx_close()

    return 0
}
```

</details>

<details>
<summary><strong>10 - 10-two-body-2d.mc</strong></summary>

### Goal

Simulate two equal bodies orbiting through gravity.

### Code

```mc
head(custom)
head(graphics)
head(math)
head(time)

fn main() {
    gfx_open(800, 500)

    F64 x1 = 320.0
    F64 y1 = 250.0
    F64 x2 = 480.0
    F64 y2 = 250.0

    F64 vx1 = 0.0
    F64 vy1 = -38.0
    F64 vx2 = 0.0
    F64 vy2 = 38.0

    F64 gravity = 500000.0
    F64 dt = 0.02
    I64 running = 1

    while (running != 0) {
        F64 dx = x2 - x1
        F64 dy = y2 - y1
        F64 d2 = dx * dx + dy * dy + 400.0
        F64 inv = math_inv_sqrt(d2)
        F64 inv3 = inv * inv * inv

        F64 ax = gravity * dx * inv3
        F64 ay = gravity * dy * inv3

        vx1 = vx1 + ax * dt
        vy1 = vy1 + ay * dt
        vx2 = vx2 - ax * dt
        vy2 = vy2 - ay * dt

        x1 = x1 + vx1 * dt
        y1 = y1 + vy1 * dt
        x2 = x2 + vx2 * dt
        y2 = y2 + vy2 * dt

        gfx_clear(gfx_rgb(0, 0, 0))

        gfx_rect_fill(cast(I64, x1) - 5, cast(I64, y1) - 5, 10, 10, gfx_rgb(255, 70, 20))
        gfx_rect_fill(cast(I64, x2) - 5, cast(I64, y2) - 5, 10, 10, gfx_rgb(255, 70, 20))

        if (gfx_present() < 0) {
            running = 0
        }

        sleep_ms(16)
    }

    gfx_close()

    return 0
}
```

</details>

---

</details>

<details>
<summary><strong>📁 05 - 3D Rendering</strong></summary>

Perspective projection and software 3D built on the 2D graphics API.

MicroC's current graphics API is 2D framebuffer based, so these examples implement 3D transforms and perspective in MicroC and then rasterize with the 2D primitives.

<details>
<summary><strong>11 - 11-perspective-point.mc</strong></summary>

### Goal

Project a 3D point onto the 2D screen.

### Code

```mc
head(custom)
head(graphics)
head(time)

fn main() {
    gfx_open(800, 500)
    gfx_clear(gfx_rgb(0, 0, 0))

    F64 x = 80.0
    F64 y = 40.0
    F64 z = 250.0
    F64 focal = 400.0

    I64 sx = cast(I64, 400.0 + x * focal / z)
    I64 sy = cast(I64, 250.0 - y * focal / z)

    gfx_rect_fill(sx - 4, sy - 4, 8, 8, gfx_rgb(255, 80, 20))

    gfx_present()
    sleep_ms(1500)
    gfx_close()

    return 0
}
```

</details>

<details>
<summary><strong>12 - 12-perspective-grid.mc</strong></summary>

### Goal

Render a simple perspective ground grid.

### Code

```mc
head(custom)
head(graphics)
head(time)

fn main() {
    gfx_open(800, 500)
    gfx_clear(gfx_rgb(0, 0, 0))

    I64 color = gfx_rgb(95, 100, 115)
    F64 focal = 420.0

    F64 z = 120.0
    while (z <= 800.0) {
        I64 x1 = cast(I64, 400.0 + (-350.0) * focal / z)
        I64 x2 = cast(I64, 400.0 + 350.0 * focal / z)
        I64 y = cast(I64, 120.0 + 170.0 * focal / z)

        gfx_line(x1, y, x2, y, color)

        z = z + 40.0
    }

    F64 x = -350.0
    while (x <= 350.0) {
        I64 near_x = cast(I64, 400.0 + x * focal / 120.0)
        I64 near_y = cast(I64, 120.0 + 170.0 * focal / 120.0)
        I64 far_x = cast(I64, 400.0 + x * focal / 800.0)
        I64 far_y = cast(I64, 120.0 + 170.0 * focal / 800.0)

        gfx_line(near_x, near_y, far_x, far_y, color)

        x = x + 50.0
    }

    gfx_present()
    sleep_ms(1500)
    gfx_close()

    return 0
}
```

</details>

<details>
<summary><strong>13 - 13-rotating-3d-point.mc</strong></summary>

### Goal

Rotate and project a 3D point.

### Code

```mc
head(custom)
head(graphics)
head(math)
head(time)

fn main() {
    gfx_open(800, 500)

    F64 angle = 0.0
    I64 running = 1

    while (running != 0) {
        gfx_clear(gfx_rgb(0, 0, 0))

        F64 x = math_cos(angle) * 120.0
        F64 z = 350.0 + math_sin(angle) * 120.0
        F64 y = 0.0
        F64 focal = 420.0

        I64 sx = cast(I64, 400.0 + x * focal / z)
        I64 sy = cast(I64, 250.0 - y * focal / z)

        gfx_rect_fill(sx - 5, sy - 5, 10, 10, gfx_rgb(255, 80, 20))

        if (gfx_present() < 0) {
            running = 0
        }

        angle = angle + 0.025
        sleep_ms(16)
    }

    gfx_close()

    return 0
}
```

</details>

<details>
<summary><strong>14 - 14-wireframe-cube.mc</strong></summary>

### Goal

Render a rotating wireframe cube.

### Code

```mc
head(custom)
head(graphics)
head(math)
head(time)

fn main() {
    gfx_open(800, 500)

    F64 angle = 0.0
    I64 running = 1

    while (running != 0) {
        gfx_clear(gfx_rgb(0, 0, 0))

        F64 c = math_cos(angle)
        F64 s = math_sin(angle)
        F64 focal = 420.0

        F64 x0 = -70.0
        F64 z0 = -70.0
        F64 rx0 = x0 * c - z0 * s
        F64 rz0 = x0 * s + z0 * c + 420.0

        F64 x1 = 70.0
        F64 z1 = -70.0
        F64 rx1 = x1 * c - z1 * s
        F64 rz1 = x1 * s + z1 * c + 420.0

        F64 x2 = 70.0
        F64 z2 = 70.0
        F64 rx2 = x2 * c - z2 * s
        F64 rz2 = x2 * s + z2 * c + 420.0

        F64 x3 = -70.0
        F64 z3 = 70.0
        F64 rx3 = x3 * c - z3 * s
        F64 rz3 = x3 * s + z3 * c + 420.0

        I64 ax0 = cast(I64, 400.0 + rx0 * focal / rz0)
        I64 ax1 = cast(I64, 400.0 + rx1 * focal / rz1)
        I64 ax2 = cast(I64, 400.0 + rx2 * focal / rz2)
        I64 ax3 = cast(I64, 400.0 + rx3 * focal / rz3)

        I64 top0 = cast(I64, 250.0 - 70.0 * focal / rz0)
        I64 top1 = cast(I64, 250.0 - 70.0 * focal / rz1)
        I64 top2 = cast(I64, 250.0 - 70.0 * focal / rz2)
        I64 top3 = cast(I64, 250.0 - 70.0 * focal / rz3)

        I64 bot0 = cast(I64, 250.0 + 70.0 * focal / rz0)
        I64 bot1 = cast(I64, 250.0 + 70.0 * focal / rz1)
        I64 bot2 = cast(I64, 250.0 + 70.0 * focal / rz2)
        I64 bot3 = cast(I64, 250.0 + 70.0 * focal / rz3)

        I64 color = gfx_rgb(220, 225, 235)

        gfx_line(ax0, top0, ax1, top1, color)
        gfx_line(ax1, top1, ax2, top2, color)
        gfx_line(ax2, top2, ax3, top3, color)
        gfx_line(ax3, top3, ax0, top0, color)

        gfx_line(ax0, bot0, ax1, bot1, color)
        gfx_line(ax1, bot1, ax2, bot2, color)
        gfx_line(ax2, bot2, ax3, bot3, color)
        gfx_line(ax3, bot3, ax0, bot0, color)

        gfx_line(ax0, top0, ax0, bot0, color)
        gfx_line(ax1, top1, ax1, bot1, color)
        gfx_line(ax2, top2, ax2, bot2, color)
        gfx_line(ax3, top3, ax3, bot3, color)

        if (gfx_present() < 0) {
            running = 0
        }

        angle = angle + 0.02
        sleep_ms(16)
    }

    gfx_close()

    return 0
}
```

</details>

<details>
<summary><strong>15 - 15-3d-axis.mc</strong></summary>

### Goal

Render projected X, Y and Z axes.

### Code

```mc
head(custom)
head(graphics)
head(time)

fn main() {
    gfx_open(800, 500)
    gfx_clear(gfx_rgb(0, 0, 0))

    F64 focal = 420.0
    F64 z0 = 400.0

    I64 ox = 400
    I64 oy = 250

    I64 xx = cast(I64, 400.0 + 120.0 * focal / z0)
    I64 xy = 250

    I64 yx = 400
    I64 yy = cast(I64, 250.0 - 120.0 * focal / z0)

    I64 zx = 400
    I64 zy = cast(I64, 250.0 + 80.0 * focal / 520.0)

    gfx_line(ox, oy, xx, xy, gfx_rgb(255, 60, 40))
    gfx_line(ox, oy, yx, yy, gfx_rgb(60, 255, 100))
    gfx_line(ox, oy, zx, zy, gfx_rgb(70, 140, 255))

    gfx_present()
    sleep_ms(1500)
    gfx_close()

    return 0
}
```

</details>

<details>
<summary><strong>16 - 16-starfield-3d.mc</strong></summary>

### Goal

Create a simple moving 3D starfield.

### Code

```mc
head(custom)
head(graphics)
head(time)

fn main() {
    gfx_open(800, 500)

    I64 frame = 0
    I64 running = 1

    while (running != 0) {
        gfx_clear(gfx_rgb(0, 0, 0))

        I64 i = 1

        while (i <= 120) {
            F64 x = cast(F64, ((i * 97) % 700) - 350)
            F64 y = cast(F64, ((i * 53) % 420) - 210)
            F64 z = cast(F64, ((i * 71 + frame * 6) % 700) + 80)

            I64 sx = cast(I64, 400.0 + x * 300.0 / z)
            I64 sy = cast(I64, 250.0 - y * 300.0 / z)

            gfx_pixel(sx, sy, gfx_rgb(220, 225, 235))

            i = i + 1
        }

        if (gfx_present() < 0) {
            running = 0
        }

        frame = frame + 1
        sleep_ms(16)
    }

    gfx_close()

    return 0
}
```

</details>

<details>
<summary><strong>17 - 17-orbit-3d.mc</strong></summary>

### Goal

Project a tilted 3D orbit.

### Code

```mc
head(custom)
head(graphics)
head(math)
head(time)

fn main() {
    gfx_open(800, 500)

    F64 angle = 0.0
    I64 running = 1

    while (running != 0) {
        gfx_clear(gfx_rgb(0, 0, 0))

        F64 x = math_cos(angle) * 150.0
        F64 y = math_sin(angle) * 55.0
        F64 z = 420.0 + math_sin(angle) * 120.0

        I64 sx = cast(I64, 400.0 + x * 420.0 / z)
        I64 sy = cast(I64, 250.0 - y * 420.0 / z)

        gfx_rect_fill(396, 246, 8, 8, gfx_rgb(255, 210, 40))
        gfx_rect_fill(sx - 5, sy - 5, 10, 10, gfx_rgb(255, 70, 20))

        if (gfx_present() < 0) {
            running = 0
        }

        angle = angle + 0.02
        sleep_ms(16)
    }

    gfx_close()

    return 0
}
```

</details>

<details>
<summary><strong>18 - 18-height-mesh.mc</strong></summary>

### Goal

Render a curved 3D wireframe surface.

### Code

```mc
head(custom)
head(graphics)
head(math)
head(time)

fn main() {
    gfx_open(800, 500)
    gfx_clear(gfx_rgb(0, 0, 0))

    I64 color = gfx_rgb(125, 130, 145)
    F64 focal = 460.0

    F64 z = -220.0

    while (z <= 220.0) {
        F64 x = -320.0
        I64 have = 0
        I64 px = 0
        I64 py = 0

        while (x <= 320.0) {
            F64 y = math_sin(x * 0.02) * 25.0 + math_cos(z * 0.02) * 25.0
            F64 depth = z + 620.0

            I64 sx = cast(I64, 400.0 + x * focal / depth)
            I64 sy = cast(I64, 170.0 - y * focal / depth + z * 0.45)

            if (have != 0) {
                gfx_line(px, py, sx, sy, color)
            }

            px = sx
            py = sy
            have = 1

            x = x + 12.0
        }

        z = z + 24.0
    }

    gfx_present()
    sleep_ms(2000)
    gfx_close()

    return 0
}
```

</details>

<details>
<summary><strong>19 - 19-gravity-mesh.mc</strong></summary>

### Goal

Animate two moving gravity wells in a smooth 3D mesh.

### Code

```mc
head(custom)
head(graphics)
head(math)
head(time)

fn main() {
    gfx_open(960, 720)

    I64 running = 1
    F64 angle = 0.0
    F64 pitch = 0.75
    F64 pitch_cos = math_cos(pitch)
    F64 pitch_sin = math_sin(pitch)

    while (running != 0) {
        F64 body1_x = math_cos(angle) * 150.0
        F64 body1_z = math_sin(angle) * 100.0
        F64 body2_x = 0.0 - body1_x
        F64 body2_z = 0.0 - body1_z

        gfx_clear(gfx_rgb(0, 0, 0))

        F64 row_z = -320.0

        while (row_z <= 320.0) {
            F64 row_x = -470.0
            I64 have = 0
            I64 px = 0
            I64 py = 0

            while (row_x <= 470.0) {
                F64 dx1 = row_x - body1_x
                F64 dz1 = row_z - body1_z
                F64 dx2 = row_x - body2_x
                F64 dz2 = row_z - body2_z

                F64 well1 = 1.0 + (dx1 * dx1 + dz1 * dz1) / 7000.0
                F64 well2 = 1.0 + (dx2 * dx2 + dz2 * dz2) / 7000.0
                F64 world_y = -105.0 / well1 - 105.0 / well2

                F64 camera_y = world_y * pitch_cos - row_z * pitch_sin
                F64 camera_z = world_y * pitch_sin + row_z * pitch_cos + 820.0

                I64 sx = cast(I64, 480.0 + row_x * 560.0 / camera_z)
                I64 sy = cast(I64, 300.0 - camera_y * 560.0 / camera_z)

                if (have != 0) {
                    gfx_line(px, py, sx, sy, gfx_rgb(135, 138, 148))
                }

                px = sx
                py = sy
                have = 1

                row_x = row_x + 8.0
            }

            row_z = row_z + 20.0
        }

        I64 b1x = cast(I64, 480.0 + body1_x * 0.72)
        I64 b1y = cast(I64, 330.0 + body1_z * 0.30)
        I64 b2x = cast(I64, 480.0 + body2_x * 0.72)
        I64 b2y = cast(I64, 330.0 + body2_z * 0.30)

        gfx_rect_fill(b1x - 5, b1y - 5, 10, 10, gfx_rgb(245, 65, 18))
        gfx_rect_fill(b2x - 5, b2y - 5, 10, 10, gfx_rgb(245, 65, 18))

        if (gfx_present() < 0) {
            running = 0
        }

        angle = angle + 0.012
        sleep_ms(16)
    }

    gfx_close()

    return 0
}
```

</details>

<details>
<summary><strong>20 - 20-mini-3d-scene.mc</strong></summary>

### Goal

Combine a grid, rotating cube and orbiting object.

### Code

```mc
head(custom)
head(graphics)
head(math)
head(time)

fn main() {
    gfx_open(960, 600)

    F64 angle = 0.0
    I64 running = 1

    while (running != 0) {
        gfx_clear(gfx_rgb(2, 3, 8))

        I64 grid = gfx_rgb(55, 60, 75)

        I64 x = 80
        while (x <= 880) {
            gfx_line(x, 360, 480 + (x - 480) / 4, 250, grid)
            x = x + 40
        }

        I64 y = 270
        while (y <= 520) {
            gfx_line(80, y, 880, y, grid)
            y = y + 30
        }

        F64 orbit_x = math_cos(angle) * 150.0
        F64 orbit_z = 420.0 + math_sin(angle) * 120.0

        I64 sx = cast(I64, 480.0 + orbit_x * 420.0 / orbit_z)
        I64 sy = 280

        gfx_rect_fill(474, 274, 12, 12, gfx_rgb(255, 210, 40))
        gfx_rect_fill(sx - 6, sy - 6, 12, 12, gfx_rgb(255, 70, 20))

        F64 c = math_cos(angle)
        F64 s = math_sin(angle)

        F64 ax = -60.0 * c - (-60.0) * s
        F64 az = -60.0 * s + (-60.0) * c + 450.0
        F64 bx = 60.0 * c - (-60.0) * s
        F64 bz = 60.0 * s + (-60.0) * c + 450.0
        F64 cx = 60.0 * c - 60.0 * s
        F64 cz = 60.0 * s + 60.0 * c + 450.0
        F64 dx = -60.0 * c - 60.0 * s
        F64 dz = -60.0 * s + 60.0 * c + 450.0

        I64 a2x = cast(I64, 480.0 + ax * 420.0 / az)
        I64 a2y = cast(I64, 280.0 - 60.0 * 420.0 / az)
        I64 b2x = cast(I64, 480.0 + bx * 420.0 / bz)
        I64 b2y = cast(I64, 280.0 - 60.0 * 420.0 / bz)
        I64 c2x = cast(I64, 480.0 + cx * 420.0 / cz)
        I64 c2y = cast(I64, 280.0 - 60.0 * 420.0 / cz)
        I64 d2x = cast(I64, 480.0 + dx * 420.0 / dz)
        I64 d2y = cast(I64, 280.0 - 60.0 * 420.0 / dz)

        I64 white = gfx_rgb(225, 230, 240)

        gfx_line(a2x, a2y, b2x, b2y, white)
        gfx_line(b2x, b2y, c2x, c2y, white)
        gfx_line(c2x, c2y, d2x, d2y, white)
        gfx_line(d2x, d2y, a2x, a2y, white)

        if (gfx_present() < 0) {
            running = 0
        }

        angle = angle + 0.02
        sleep_ms(16)
    }

    gfx_close()

    return 0
}
```

</details>

---

</details>

<details>
<summary><strong>📁 06 - Networking</strong></summary>

Sockets, localhost TCP/UDP, sending, receiving and polling.

All runnable network targets in this learning path use `127.0.0.1`. The current compiler accepts both `head(network)` and `head(networking)`; these examples use `head(networking)`.

<details>
<summary><strong>01 - 01-create-socket.mc</strong></summary>

### Goal

Create and close a TCP socket.

### Code

```mc
head(custom)
head(networking)
head(file)

fn main() {
    I64 fd = net_socket(2, 1, 0)

    if (fd < 0) {
        pin("socket failed\n")
        return 1
    }

    pin("socket fd = %I64\n", fd)

    net_shutdown(fd, 2)
    close(fd)

    return 0
}
```

</details>

<details>
<summary><strong>02 - 02-loopback-address.mc</strong></summary>

### Goal

Build a sockaddr_in for 127.0.0.1:8080.

### Code

```mc
head(custom)
head(memory)

fn main() {
    I64 address = safe_alloc(16)

    safe_write8(address, 0, 2)
    safe_write8(address, 1, 0)
    safe_write8(address, 2, 31)
    safe_write8(address, 3, 144)
    safe_write8(address, 4, 127)
    safe_write8(address, 5, 0)
    safe_write8(address, 6, 0)
    safe_write8(address, 7, 1)

    I64 i = 8
    while (i < 16) {
        safe_write8(address, i, 0)
        i = i + 1
    }

    pin("sockaddr ready\n")

    safe_free(address)
    return 0
}
```

</details>

<details>
<summary><strong>03 - 03-local-tcp-bind.mc</strong></summary>

### Goal

Bind a TCP socket to localhost port 8080.

### Code

```mc
head(custom)
head(networking)
head(memory)
head(file)

fn fill_address(I64 address) {
    safe_write8(address, 0, 2)
    safe_write8(address, 1, 0)
    safe_write8(address, 2, 31)
    safe_write8(address, 3, 144)
    safe_write8(address, 4, 127)
    safe_write8(address, 5, 0)
    safe_write8(address, 6, 0)
    safe_write8(address, 7, 1)

    I64 i = 8
    while (i < 16) {
        safe_write8(address, i, 0)
        i = i + 1
    }

    return 0
}

fn main() {
    I64 fd = net_socket(2, 1, 0)
    I64 address = safe_alloc(16)

    fill_address(address)

    I64 result = net_bind(fd, address, 16)
    pin("bind = %I64\n", result)

    net_shutdown(fd, 2)
    close(fd)
    safe_free(address)

    return 0
}
```

</details>

<details>
<summary><strong>04 - 04-local-tcp-listen.mc</strong></summary>

### Goal

Create a localhost TCP listener.

### Code

```mc
head(custom)
head(networking)
head(memory)
head(file)

fn fill_address(I64 address) {
    safe_write8(address, 0, 2)
    safe_write8(address, 1, 0)
    safe_write8(address, 2, 31)
    safe_write8(address, 3, 144)
    safe_write8(address, 4, 127)
    safe_write8(address, 5, 0)
    safe_write8(address, 6, 0)
    safe_write8(address, 7, 1)

    I64 i = 8
    while (i < 16) {
        safe_write8(address, i, 0)
        i = i + 1
    }

    return 0
}

fn main() {
    I64 fd = net_socket(2, 1, 0)
    I64 address = safe_alloc(16)

    fill_address(address)

    if (net_bind(fd, address, 16) < 0) {
        pin("bind failed\n")
        return 1
    }

    if (net_listen(fd, 8) < 0) {
        pin("listen failed\n")
        return 1
    }

    pin("listening on 127.0.0.1:8080\n")

    net_shutdown(fd, 2)
    close(fd)
    safe_free(address)

    return 0
}
```

</details>

<details>
<summary><strong>05 - 05-local-tcp-client.mc</strong></summary>

### Goal

Connect to a server on localhost:8080.

### Code

```mc
head(custom)
head(networking)
head(memory)
head(file)

fn fill_address(I64 address) {
    safe_write8(address, 0, 2)
    safe_write8(address, 1, 0)
    safe_write8(address, 2, 31)
    safe_write8(address, 3, 144)
    safe_write8(address, 4, 127)
    safe_write8(address, 5, 0)
    safe_write8(address, 6, 0)
    safe_write8(address, 7, 1)

    I64 i = 8
    while (i < 16) {
        safe_write8(address, i, 0)
        i = i + 1
    }

    return 0
}

fn main() {
    I64 fd = net_socket(2, 1, 0)
    I64 address = safe_alloc(16)

    fill_address(address)

    I64 result = net_connect(fd, address, 16)
    pin("connect = %I64\n", result)

    net_shutdown(fd, 2)
    close(fd)
    safe_free(address)

    return 0
}
```

</details>

<details>
<summary><strong>06 - 06-local-tcp-send.mc</strong></summary>

### Goal

Connect to localhost and send a short message.

### Code

```mc
head(custom)
head(networking)
head(memory)
head(file)

fn fill_address(I64 address) {
    safe_write8(address, 0, 2)
    safe_write8(address, 1, 0)
    safe_write8(address, 2, 31)
    safe_write8(address, 3, 144)
    safe_write8(address, 4, 127)
    safe_write8(address, 5, 0)
    safe_write8(address, 6, 0)
    safe_write8(address, 7, 1)

    I64 i = 8
    while (i < 16) {
        safe_write8(address, i, 0)
        i = i + 1
    }

    return 0
}

fn main() {
    I64 fd = net_socket(2, 1, 0)
    I64 address = safe_alloc(16)
    I64 message = "hello from MicroC\n"

    fill_address(address)

    if (net_connect(fd, address, 16) == 0) {
        I64 sent = net_sendto(fd, message, strlen(message), 0, 0, 0)
        pin("sent = %I64\n", sent)
    }
    else {
        pin("connect failed\n")
    }

    net_shutdown(fd, 2)
    close(fd)
    safe_free(address)

    return 0
}
```

</details>

<details>
<summary><strong>07 - 07-local-tcp-echo-server.mc</strong></summary>

### Goal

Accept one localhost client and echo received bytes.

### Code

```mc
head(custom)
head(networking)
head(memory)
head(file)

fn fill_address(I64 address) {
    safe_write8(address, 0, 2)
    safe_write8(address, 1, 0)
    safe_write8(address, 2, 31)
    safe_write8(address, 3, 144)
    safe_write8(address, 4, 127)
    safe_write8(address, 5, 0)
    safe_write8(address, 6, 0)
    safe_write8(address, 7, 1)

    I64 i = 8
    while (i < 16) {
        safe_write8(address, i, 0)
        i = i + 1
    }

    return 0
}

fn main() {
    I64 server = net_socket(2, 1, 0)
    I64 address = safe_alloc(16)
    I64 buffer = safe_alloc(256)

    fill_address(address)

    if (net_bind(server, address, 16) < 0) {
        pin("bind failed\n")
        return 1
    }

    if (net_listen(server, 8) < 0) {
        pin("listen failed\n")
        return 1
    }

    pin("waiting on 127.0.0.1:8080\n")

    I64 client = net_accept(server, 0, 0)

    if (client >= 0) {
        I64 count = net_recvfrom(client, buffer, 255, 0, 0, 0)

        if (count > 0) {
            net_sendto(client, buffer, count, 0, 0, 0)
            pin("echoed %I64 bytes\n", count)
        }

        net_shutdown(client, 2)
        close(client)
    }

    net_shutdown(server, 2)
    close(server)
    safe_free(buffer)
    safe_free(address)

    return 0
}
```

</details>

<details>
<summary><strong>08 - 08-udp-loopback-send.mc</strong></summary>

### Goal

Send a UDP datagram to localhost:8080.

### Code

```mc
head(custom)
head(networking)
head(memory)
head(file)

fn fill_address(I64 address) {
    safe_write8(address, 0, 2)
    safe_write8(address, 1, 0)
    safe_write8(address, 2, 31)
    safe_write8(address, 3, 144)
    safe_write8(address, 4, 127)
    safe_write8(address, 5, 0)
    safe_write8(address, 6, 0)
    safe_write8(address, 7, 1)

    I64 i = 8
    while (i < 16) {
        safe_write8(address, i, 0)
        i = i + 1
    }

    return 0
}

fn main() {
    I64 fd = net_socket(2, 2, 0)
    I64 address = safe_alloc(16)
    I64 message = "MicroC UDP"

    fill_address(address)

    I64 sent = net_sendto(fd, message, strlen(message), 0, address, 16)

    pin("sent = %I64\n", sent)

    close(fd)
    safe_free(address)

    return 0
}
```

</details>

<details>
<summary><strong>09 - 09-socket-reuse.mc</strong></summary>

### Goal

Enable SO_REUSEADDR on a local TCP socket.

### Code

```mc
head(custom)
head(networking)
head(memory)
head(file)

fn main() {
    I64 fd = net_socket(2, 1, 0)
    I64 option = safe_alloc(4)

    safe_write32(option, 0, 1)

    I64 result = net_setsockopt(fd, 1, 2, option, 4)

    pin("setsockopt = %I64\n", result)

    close(fd)
    safe_free(option)

    return 0
}
```

</details>

<details>
<summary><strong>10 - 10-poll.mc</strong></summary>

### Goal

Wait briefly for data on a socket with poll.

### Code

```mc
head(custom)
head(networking)
head(memory)
head(file)

fn main() {
    I64 fd = net_socket(2, 1, 0)
    I64 pollfd = safe_alloc(8)

    safe_write32(pollfd, 0, fd)
    safe_write16(pollfd, 4, 1)
    safe_write16(pollfd, 6, 0)

    I64 ready = net_poll(pollfd, 1, 100)

    pin("poll result = %I64\n", ready)

    close(fd)
    safe_free(pollfd)

    return 0
}
```

</details>

---

</details>

<details>
<summary><strong>📁 07 - Red Teaming</strong></summary>

Authorized localhost/offline security exercises numbered 50 through 70.

Files are numbered `50` through `70` as requested. They teach scope checks, localhost enumeration, protocol inspection, file analysis, fuzzing of toy parsers, integrity checks, log analysis and reporting without exploit payloads or persistence.

<details>
<summary><strong>50 - 50-scope-check.mc</strong></summary>

### Goal

Refuse targets outside the local authorized lab scope.

### Code

```mc
head(custom)

fn in_scope(I64 target) {
    if (strcmp(target, "127.0.0.1") == 0) { return 1 }
    if (strcmp(target, "localhost") == 0) { return 1 }
    return 0
}

fn main() {
    I64 target = "127.0.0.1"

    if (in_scope(target) == 0) {
        pin("out of scope\n")
        return 1
    }

    pin("authorized lab target: %s\n", target)
    return 0
}
```

</details>

<details>
<summary><strong>51 - 51-local-port-probe.mc</strong></summary>

### Goal

Probe one TCP port on 127.0.0.1 and report whether a local lab service accepts a connection.

### Code

```mc
head(custom)
head(networking)
head(memory)
head(file)

fn make_loopback(I64 address, I64 port) {
    safe_write8(address, 0, 2)
    safe_write8(address, 1, 0)
    safe_write8(address, 2, port / 256)
    safe_write8(address, 3, port % 256)
    safe_write8(address, 4, 127)
    safe_write8(address, 5, 0)
    safe_write8(address, 6, 0)
    safe_write8(address, 7, 1)

    I64 i = 8
    while (i < 16) {
        safe_write8(address, i, 0)
        i = i + 1
    }

    return 0
}

fn main() {
    I64 port = 8080
    I64 address = safe_alloc(16)
    I64 fd = net_socket(2, 1, 0)

    make_loopback(address, port)

    I64 result = net_connect(fd, address, 16)

    if (result == 0) {
        pin("127.0.0.1:%I64 open\n", port)
    }
    else {
        pin("127.0.0.1:%I64 closed or unavailable\n", port)
    }

    net_shutdown(fd, 2)
    close(fd)
    safe_free(address)

    return 0
}
```

</details>

<details>
<summary><strong>52 - 52-local-port-inventory.mc</strong></summary>

### Goal

Inventory a tiny localhost lab range from port 8000 through 8010.

### Code

```mc
head(custom)
head(networking)
head(memory)
head(file)

fn make_loopback(I64 address, I64 port) {
    safe_write8(address, 0, 2)
    safe_write8(address, 1, 0)
    safe_write8(address, 2, port / 256)
    safe_write8(address, 3, port % 256)
    safe_write8(address, 4, 127)
    safe_write8(address, 5, 0)
    safe_write8(address, 6, 0)
    safe_write8(address, 7, 1)

    I64 i = 8
    while (i < 16) {
        safe_write8(address, i, 0)
        i = i + 1
    }

    return 0
}

fn main() {
    I64 address = safe_alloc(16)
    I64 port = 8000

    while (port <= 8010) {
        I64 fd = net_socket(2, 1, 0)
        make_loopback(address, port)

        if (net_connect(fd, address, 16) == 0) {
            pin("open: %I64\n", port)
        }

        net_shutdown(fd, 2)
        close(fd)
        port = port + 1
    }

    safe_free(address)
    return 0
}
```

</details>

<details>
<summary><strong>53 - 53-local-banner-reader.mc</strong></summary>

### Goal

Connect to a localhost lab service and print the first bytes it sends.

### Code

```mc
head(custom)
head(networking)
head(memory)
head(file)

fn make_loopback(I64 address, I64 port) {
    safe_write8(address, 0, 2)
    safe_write8(address, 1, 0)
    safe_write8(address, 2, port / 256)
    safe_write8(address, 3, port % 256)
    safe_write8(address, 4, 127)
    safe_write8(address, 5, 0)
    safe_write8(address, 6, 0)
    safe_write8(address, 7, 1)

    I64 i = 8
    while (i < 16) {
        safe_write8(address, i, 0)
        i = i + 1
    }

    return 0
}

fn main() {
    I64 address = safe_alloc(16)
    I64 buffer = safe_alloc(129)
    I64 fd = net_socket(2, 1, 0)

    make_loopback(address, 8080)

    if (net_connect(fd, address, 16) != 0) {
        pin("local service unavailable\n")
        return 1
    }

    I64 count = net_recvfrom(fd, buffer, 128, 0, 0, 0)

    if (count > 0) {
        safe_write8(buffer, count, 0)
        pin("banner: %s\n", buffer)
    }

    net_shutdown(fd, 2)
    close(fd)
    safe_free(buffer)
    safe_free(address)

    return 0
}
```

</details>

<details>
<summary><strong>54 - 54-http-request-builder.mc</strong></summary>

### Goal

Build a harmless HTTP request for a local lab service.

### Code

```mc
head(custom)

fn main() {
    I64 request = "GET / HTTP/1.1\r\nHost: 127.0.0.1\r\nConnection: close\r\n\r\n"

    pin("%s", request)
    pin("request bytes = %I64\n", strlen(request))

    return 0
}
```

</details>

<details>
<summary><strong>55 - 55-http-status-parser.mc</strong></summary>

### Goal

Parse the numeric status code from a sample HTTP response.

### Code

```mc
head(custom)
head(memory)

fn main() {
    I64 response = "HTTP/1.1 404 Not Found\r\nContent-Length: 0\r\n\r\n"

    I64 a = mem_read8(response + 9) - 48
    I64 b = mem_read8(response + 10) - 48
    I64 c = mem_read8(response + 11) - 48

    I64 status = a * 100 + b * 10 + c

    pin("status = %I64\n", status)

    return 0
}
```

</details>

<details>
<summary><strong>56 - 56-http-header-counter.mc</strong></summary>

### Goal

Count header lines in a sample HTTP response without attacking any service.

### Code

```mc
head(custom)
head(memory)

fn main() {
    I64 response = "HTTP/1.1 200 OK\r\nServer: lab\r\nContent-Type: text/plain\r\nX-Test: yes\r\n\r\n"
    I64 length = strlen(response)

    I64 i = 0
    I64 headers = 0

    while (i + 1 < length) {
        I64 a = mem_read8(response + i)
        I64 b = mem_read8(response + i + 1)

        if (a == 13) {
            if (b == 10) {
                headers = headers + 1
                i = i + 1
            }
        }

        i = i + 1
    }

    pin("CRLF lines = %I64\n", headers)

    return 0
}
```

</details>

<details>
<summary><strong>57 - 57-file-magic.mc</strong></summary>

### Goal

Inspect the first bytes of a file and recognize a few common signatures.

### Code

```mc
head(custom)
head(file)
head(process)

fn main() {
    if (argc() < 2) {
        pin("usage: file-magic path\n")
        return 1
    }

    I64 fd = open(argv(1), 0)

    if (fd < 0) {
        pin("open failed\n")
        return 1
    }

    I64 b0 = file_read8(fd)
    I64 b1 = file_read8(fd)
    I64 b2 = file_read8(fd)
    I64 b3 = file_read8(fd)

    if ((b0 == 0x7F) && (b1 == 0x45) && (b2 == 0x4C) && (b3 == 0x46)) {
        pin("ELF executable\n")
    }
    else {
        if ((b0 == 0x89) && (b1 == 0x50) && (b2 == 0x4E) && (b3 == 0x47)) {
            pin("PNG image\n")
        }
        else {
            pin("unknown signature\n")
        }
    }

    close(fd)
    return 0
}
```

</details>

<details>
<summary><strong>58 - 58-hexdump.mc</strong></summary>

### Goal

Print the first 64 bytes of a file as hexadecimal for offline inspection.

### Code

```mc
head(custom)
head(file)
head(process)

fn main() {
    if (argc() < 2) {
        pin("usage: hexdump path\n")
        return 1
    }

    I64 fd = open(argv(1), 0)

    if (fd < 0) {
        pin("open failed\n")
        return 1
    }

    I64 size = file_size(fd)

    if (size > 64) {
        size = 64
    }

    I64 i = 0

    while (i < size) {
        I64 value = file_read8(fd)
        pin("%X64 ", value)

        if ((i % 16) == 15) {
            pin("\n")
        }

        i = i + 1
    }

    pin("\n")
    close(fd)

    return 0
}
```

</details>

<details>
<summary><strong>59 - 59-string-extractor.mc</strong></summary>

### Goal

Extract printable runs from a controlled in-memory binary sample.

### Code

```mc
head(custom)
head(memory)

fn main() {
    I64 buffer = safe_alloc(32)

    safe_write8(buffer, 0, 1)
    safe_write8(buffer, 1, 2)
    safe_write8(buffer, 2, 72)
    safe_write8(buffer, 3, 69)
    safe_write8(buffer, 4, 76)
    safe_write8(buffer, 5, 76)
    safe_write8(buffer, 6, 79)
    safe_write8(buffer, 7, 0)
    safe_write8(buffer, 8, 10)
    safe_write8(buffer, 9, 87)
    safe_write8(buffer, 10, 79)
    safe_write8(buffer, 11, 82)
    safe_write8(buffer, 12, 76)
    safe_write8(buffer, 13, 68)

    I64 i = 0
    I64 run = 0

    while (i < 14) {
        I64 c = safe_read8(buffer, i)

        if ((c >= 32) && (c <= 126)) {
            pin("%c", c)
            run = run + 1
        }
        else {
            if (run >= 4) {
                pin("\n")
            }
            run = 0
        }

        i = i + 1
    }

    if (run >= 4) {
        pin("\n")
    }

    safe_free(buffer)
    return 0
}
```

</details>

<details>
<summary><strong>60 - 60-fnv-fingerprint.mc</strong></summary>

### Goal

Create a fast FNV-1a fingerprint for controlled data.

### Code

```mc
head(custom)
head(memory)

fn main() {
    I64 text = "authorized-lab-sample"
    I64 hash = fnv1a64(text, strlen(text))

    pin("FNV-1a = %X64\n", hash)

    return 0
}
```

</details>

<details>
<summary><strong>61 - 61-integrity-check.mc</strong></summary>

### Goal

Detect when a managed buffer changes by comparing fingerprints.

### Code

```mc
head(custom)
head(memory)

fn main() {
    I64 buffer = safe_alloc(8)

    I64 i = 0
    while (i < 8) {
        safe_write8(buffer, i, i + 10)
        i = i + 1
    }

    I64 baseline = fnv1a64(buffer, 8)

    safe_write8(buffer, 3, 99)

    I64 current = fnv1a64(buffer, 8)

    if (baseline == current) {
        pin("unchanged\n")
    }
    else {
        pin("integrity change detected\n")
    }

    safe_free(buffer)
    return 0
}
```

</details>

<details>
<summary><strong>62 - 62-input-boundary-test.mc</strong></summary>

### Goal

Test how a small parser handles empty, short and oversized-looking inputs without touching an external target.

### Code

```mc
head(custom)

fn valid_name(I64 text) {
    I64 length = strlen(text)

    if (length == 0) { return 0 }
    if (length > 16) { return 0 }

    return 1
}

fn test(I64 text) {
    pin("%s -> %I64\n", text, valid_name(text))
    return 0
}

fn main() {
    test("")
    test("a")
    test("normal_name")
    test("this_name_is_far_too_long")

    return 0
}
```

</details>

<details>
<summary><strong>63 - 63-toy-parser-fuzzer.mc</strong></summary>

### Goal

Fuzz a toy integer parser with a small deterministic local corpus.

### Code

```mc
head(custom)
head(memory)

fn parse_number(I64 text) {
    I64 length = strlen(text)
    I64 i = 0
    I64 value = 0

    if (length == 0) {
        return 0 - 1
    }

    while (i < length) {
        I64 c = mem_read8(text + i)

        if ((c < 48) || (c > 57)) {
            return 0 - 1
        }

        value = value * 10 + c - 48
        i = i + 1
    }

    return value
}

fn test(I64 text) {
    pin("input='%s' result=%I64\n", text, parse_number(text))
    return 0
}

fn main() {
    test("")
    test("0")
    test("42")
    test("00042")
    test("12x")
    test("-1")
    test("999999")

    return 0
}
```

</details>

<details>
<summary><strong>64 - 64-canary-check.mc</strong></summary>

### Goal

Use a canary value to notice unexpected writes inside a controlled buffer layout.

### Code

```mc
head(custom)
head(memory)

fn main() {
    I64 block = safe_alloc(24)
    I64 canary = 0x1122334455667788

    safe_write64(block, 16, canary)

    I64 i = 0
    while (i < 16) {
        safe_write8(block, i, 65)
        i = i + 1
    }

    if (safe_read64(block, 16) == canary) {
        pin("canary intact\n")
    }
    else {
        pin("memory corruption detected\n")
    }

    safe_free(block)
    return 0
}
```

</details>

<details>
<summary><strong>65 - 65-failed-login-counter.mc</strong></summary>

### Goal

Analyze a tiny synthetic authentication event stream and count failed attempts.

### Code

```mc
head(custom)
head(memory)

fn main() {
    I64 events = safe_alloc(10)

    safe_write8(events, 0, 0)
    safe_write8(events, 1, 1)
    safe_write8(events, 2, 0)
    safe_write8(events, 3, 0)
    safe_write8(events, 4, 1)
    safe_write8(events, 5, 0)
    safe_write8(events, 6, 0)
    safe_write8(events, 7, 0)
    safe_write8(events, 8, 1)
    safe_write8(events, 9, 0)

    I64 failures = 0
    I64 i = 0

    while (i < 10) {
        if (safe_read8(events, i) == 0) {
            failures = failures + 1
        }

        i = i + 1
    }

    pin("failed attempts = %I64\n", failures)

    safe_free(events)
    return 0
}
```

</details>

<details>
<summary><strong>66 - 66-rate-limit-simulator.mc</strong></summary>

### Goal

Simulate a defensive login rate limit and see when requests would be blocked.

### Code

```mc
head(custom)

fn main() {
    I64 attempts = 0
    I64 request = 1

    while (request <= 8) {
        attempts = attempts + 1

        if (attempts > 5) {
            pin("request %I64 blocked\n", request)
        }
        else {
            pin("request %I64 allowed\n", request)
        }

        request = request + 1
    }

    return 0
}
```

</details>

<details>
<summary><strong>67 - 67-path-traversal-detector.mc</strong></summary>

### Goal

Detect `../` and `..\` patterns in a supplied path before a file operation.

### Code

```mc
head(custom)
head(memory)

fn suspicious_path(I64 path) {
    I64 length = strlen(path)
    I64 i = 0

    while (i + 2 < length) {
        I64 a = mem_read8(path + i)
        I64 b = mem_read8(path + i + 1)
        I64 c = mem_read8(path + i + 2)

        if ((a == 46) && (b == 46)) {
            if ((c == 47) || (c == 92)) {
                return 1
            }
        }

        i = i + 1
    }

    return 0
}

fn main() {
    pin("safe path = %I64\n", suspicious_path("assets/image.bmp"))
    pin("bad path = %I64\n", suspicious_path("../../secret"))

    return 0
}
```

</details>

<details>
<summary><strong>68 - 68-protocol-be-parser.mc</strong></summary>

### Goal

Practice parsing big-endian network fields from a controlled packet buffer.

### Code

```mc
head(custom)
head(memory)

fn main() {
    I64 packet = safe_alloc(16)

    safe_write_be16(packet, 0, 0x1234)
    safe_write_be16(packet, 2, 0x0050)
    safe_write_be32(packet, 4, 0x7F000001)

    I64 type = safe_read_be16(packet, 0)
    I64 port = safe_read_be16(packet, 2)
    I64 address = safe_read_be32(packet, 4)

    pin("type = %X64\n", type)
    pin("port = %I64\n", port)
    pin("address = %X64\n", address)

    safe_free(packet)
    return 0
}
```

</details>

<details>
<summary><strong>69 - 69-finding-score.mc</strong></summary>

### Goal

Turn impact and confidence values into a simple finding severity score.

### Code

```mc
head(custom)

fn severity(I64 impact, I64 confidence) {
    I64 score = impact * confidence

    if (score >= 20) { return 4 }
    if (score >= 12) { return 3 }
    if (score >= 6) { return 2 }
    return 1
}

fn main() {
    I64 impact = 5
    I64 confidence = 4
    I64 level = severity(impact, confidence)

    pin("severity level = %I64\n", level)

    return 0
}
```

</details>

<details>
<summary><strong>70 - 70-report-summary.mc</strong></summary>

### Goal

Produce a tiny red-team lab finding summary from structured values.

### Code

```mc
head(custom)

fn main() {
    I64 target = "127.0.0.1"
    I64 finding = "unexpected local service"
    I64 port = 8080
    I64 severity = 2

    pin("Red Team Lab Report\n")
    pin("target: %s\n", target)
    pin("finding: %s\n", finding)
    pin("port: %I64\n", port)
    pin("severity: %I64\n", severity)
    pin("recommendation: verify the service and restrict exposure\n")

    return 0
}
```

</details>

---

</details>

<details>
<summary><strong>📁 08 - Build a Compiler</strong></summary>

Twenty steps from reading source text to emitting a tiny x86 binary.

The final example accepts the tiny language `return NUMBER` and emits raw x86 machine-code bytes. The previous files isolate the lexer, parser, symbol-table and emitter ideas first.

<details>
<summary><strong>01 - 01-source.mc</strong></summary>

### Goal

Store compiler input and walk over its bytes.

### Code

```mc
head(custom)
head(memory)

fn main() {
    I64 source = "return 42"
    I64 length = strlen(source)
    I64 i = 0

    while (i < length) {
        pin("%c\n", mem_read8(source + i))
        i = i + 1
    }

    return 0
}
```

</details>

<details>
<summary><strong>02 - 02-next-char.mc</strong></summary>

### Goal

Build a source cursor that consumes characters.

### Code

```mc
head(custom)
head(memory)

fn next_char(I64 source, I64 state) {
    I64 position = safe_read64(state, 0)
    I64 c = mem_read8(source + position)

    safe_write64(state, 0, position + 1)

    return c
}

fn main() {
    I64 source = "abc"
    I64 state = safe_alloc(8)

    safe_write64(state, 0, 0)

    pin("%c\n", next_char(source, state))
    pin("%c\n", next_char(source, state))
    pin("%c\n", next_char(source, state))

    safe_free(state)

    return 0
}
```

</details>

<details>
<summary><strong>03 - 03-peek-char.mc</strong></summary>

### Goal

Look ahead without consuming the character.

### Code

```mc
head(custom)
head(memory)

fn peek_char(I64 source, I64 position) {
    return mem_read8(source + position)
}

fn main() {
    I64 source = "abc"
    I64 position = 1

    pin("peek = %c\n", peek_char(source, position))
    pin("position = %I64\n", position)

    return 0
}
```

</details>

<details>
<summary><strong>04 - 04-char-classes.mc</strong></summary>

### Goal

Classify digits, letters and whitespace.

### Code

```mc
head(custom)

fn is_digit(I64 c) {
    if (c >= 48) {
        if (c <= 57) {
            return 1
        }
    }

    return 0
}

fn is_letter(I64 c) {
    if (c >= 65) {
        if (c <= 90) {
            return 1
        }
    }

    if (c >= 97) {
        if (c <= 122) {
            return 1
        }
    }

    return 0
}

fn is_space(I64 c) {
    if (c == 32) { return 1 }
    if (c == 9) { return 1 }
    if (c == 10) { return 1 }
    if (c == 13) { return 1 }

    return 0
}

fn main() {
    pin("digit = %I64\n", is_digit(53))
    pin("letter = %I64\n", is_letter(65))
    pin("space = %I64\n", is_space(32))

    return 0
}
```

</details>

<details>
<summary><strong>05 - 05-skip-whitespace.mc</strong></summary>

### Goal

Advance over whitespace before lexing a token.

### Code

```mc
head(custom)
head(memory)

fn is_space(I64 c) {
    if (c == 32) { return 1 }
    if (c == 9) { return 1 }
    if (c == 10) { return 1 }
    if (c == 13) { return 1 }

    return 0
}

fn skip_whitespace(I64 source, I64 position) {
    I64 length = strlen(source)
    I64 done = 0

    while (done == 0) {
        if (position >= length) {
            done = 1
        }
        else {
            I64 c = mem_read8(source + position)

            if (is_space(c) == 0) {
                done = 1
            }
            else {
                position = position + 1
            }
        }
    }

    return position
}

fn main() {
    I64 source = "    return 42"
    I64 position = skip_whitespace(source, 0)

    pin("token begins at %I64\n", position)

    return 0
}
```

</details>

<details>
<summary><strong>06 - 06-read-number.mc</strong></summary>

### Goal

Lex an integer literal.

### Code

```mc
head(custom)
head(memory)

fn is_digit(I64 c) {
    if (c >= 48) {
        if (c <= 57) {
            return 1
        }
    }

    return 0
}

fn read_number(I64 source, I64 start) {
    I64 position = start
    I64 value = 0
    I64 reading = 1

    while (reading != 0) {
        I64 c = mem_read8(source + position)

        if (is_digit(c) == 0) {
            reading = 0
        }
        else {
            value = value * 10 + c - 48
            position = position + 1
        }
    }

    return value
}

fn main() {
    I64 source = "583+"
    I64 value = read_number(source, 0)

    pin("number = %I64\n", value)

    return 0
}
```

</details>

<details>
<summary><strong>07 - 07-read-identifier.mc</strong></summary>

### Goal

Lex an identifier into a buffer.

### Code

```mc
head(custom)
head(memory)

fn identifier_char(I64 c) {
    if (c >= 65) {
        if (c <= 90) { return 1 }
    }

    if (c >= 97) {
        if (c <= 122) { return 1 }
    }

    if (c >= 48) {
        if (c <= 57) { return 1 }
    }

    if (c == 95) { return 1 }

    return 0
}

fn main() {
    I64 source = "kernel_main("
    I64 token = safe_alloc(64)

    I64 i = 0
    I64 reading = 1

    while (reading != 0) {
        I64 c = mem_read8(source + i)

        if (identifier_char(c) == 0) {
            reading = 0
        }
        else {
            safe_write8(token, i, c)
            i = i + 1
        }
    }

    safe_write8(token, i, 0)

    pin("identifier = %s\n", token)

    safe_free(token)

    return 0
}
```

</details>

<details>
<summary><strong>08 - 08-token-kinds.mc</strong></summary>

### Goal

Define numeric token kinds and classify one character.

### Code

```mc
head(custom)

fn token_kind(I64 c) {
    if (c >= 48) {
        if (c <= 57) {
            return 2
        }
    }

    if (c >= 65) {
        if (c <= 90) {
            return 1
        }
    }

    if (c >= 97) {
        if (c <= 122) {
            return 1
        }
    }

    if (c == 43) { return 3 }
    if (c == 45) { return 3 }
    if (c == 42) { return 3 }
    if (c == 47) { return 3 }

    return 0
}

fn main() {
    pin("A token = %I64\n", token_kind(65))
    pin("7 token = %I64\n", token_kind(55))
    pin("+ token = %I64\n", token_kind(43))

    return 0
}
```

</details>

<details>
<summary><strong>09 - 09-next-token.mc</strong></summary>

### Goal

Build a tiny lexer that walks a source string.

### Code

```mc
head(custom)
head(memory)

fn is_space(I64 c) {
    if (c == 32) { return 1 }
    if (c == 9) { return 1 }
    if (c == 10) { return 1 }

    return 0
}

fn is_digit(I64 c) {
    if (c >= 48) {
        if (c <= 57) { return 1 }
    }

    return 0
}

fn is_letter(I64 c) {
    if (c >= 65) {
        if (c <= 90) { return 1 }
    }

    if (c >= 97) {
        if (c <= 122) { return 1 }
    }

    return 0
}

fn main() {
    I64 source = "x + 42"
    I64 i = 0
    I64 length = strlen(source)

    while (i < length) {
        I64 c = mem_read8(source + i)

        if (is_space(c) != 0) {
            i = i + 1
        }
        else {
            if (is_letter(c) != 0) {
                pin("IDENT %c\n", c)
            }
            else {
                if (is_digit(c) != 0) {
                    pin("NUMBER %c\n", c)
                }
                else {
                    pin("SYMBOL %c\n", c)
                }
            }

            i = i + 1
        }
    }

    return 0
}
```

</details>

<details>
<summary><strong>10 - 10-keywords.mc</strong></summary>

### Goal

Recognize compiler keywords.

### Code

```mc
head(custom)

fn keyword_id(I64 text) {
    if (strcmp(text, "fn") == 0) { return 1 }
    if (strcmp(text, "return") == 0) { return 2 }
    if (strcmp(text, "if") == 0) { return 3 }
    if (strcmp(text, "else") == 0) { return 4 }
    if (strcmp(text, "while") == 0) { return 5 }

    return 0
}

fn main() {
    pin("fn = %I64\n", keyword_id("fn"))
    pin("return = %I64\n", keyword_id("return"))
    pin("hello = %I64\n", keyword_id("hello"))

    return 0
}
```

</details>

<details>
<summary><strong>11 - 11-token-structure.mc</strong></summary>

### Goal

Store token kind, value and source position in memory.

### Code

```mc
head(custom)
head(memory)

fn main() {
    I64 token = safe_alloc(24)

    safe_write64(token, 0, 2)
    safe_write64(token, 8, 42)
    safe_write64(token, 16, 7)

    pin("kind = %I64\n", safe_read64(token, 0))
    pin("value = %I64\n", safe_read64(token, 8))
    pin("position = %I64\n", safe_read64(token, 16))

    safe_free(token)

    return 0
}
```

</details>

<details>
<summary><strong>12 - 12-parser-cursor.mc</strong></summary>

### Goal

Build a parser cursor over an array of token values.

### Code

```mc
head(custom)
head(memory)

fn current_token(I64 tokens, I64 position) {
    return safe_read64(tokens, position * 8)
}

fn main() {
    I64 tokens = safe_alloc(32)

    safe_write64(tokens, 0, 10)
    safe_write64(tokens, 8, 20)
    safe_write64(tokens, 16, 30)
    safe_write64(tokens, 24, 0)

    I64 position = 0

    while (current_token(tokens, position) != 0) {
        pin("token = %I64\n", current_token(tokens, position))
        position = position + 1
    }

    safe_free(tokens)

    return 0
}
```

</details>

<details>
<summary><strong>13 - 13-parse-primary.mc</strong></summary>

### Goal

Parse the simplest expression: one number.

### Code

```mc
head(custom)
head(memory)

fn parse_primary(I64 source) {
    I64 value = 0
    I64 i = 0
    I64 reading = 1

    while (reading != 0) {
        I64 c = mem_read8(source + i)

        if (c < 48) {
            reading = 0
        }
        else {
            if (c > 57) {
                reading = 0
            }
            else {
                value = value * 10 + c - 48
                i = i + 1
            }
        }
    }

    return value
}

fn main() {
    I64 value = parse_primary("123")

    pin("primary = %I64\n", value)

    return 0
}
```

</details>

<details>
<summary><strong>14 - 14-parse-addition.mc</strong></summary>

### Goal

Parse a simple A+B expression.

### Code

```mc
head(custom)
head(memory)

fn read_number(I64 source, I64 start) {
    I64 value = 0
    I64 i = start
    I64 reading = 1

    while (reading != 0) {
        I64 c = mem_read8(source + i)

        if (c < 48) {
            reading = 0
        }
        else {
            if (c > 57) {
                reading = 0
            }
            else {
                value = value * 10 + c - 48
                i = i + 1
            }
        }
    }

    return value
}

fn main() {
    I64 source = "12+30"

    I64 left = read_number(source, 0)
    I64 right = read_number(source, 3)

    pin("result = %I64\n", left + right)

    return 0
}
```

</details>

<details>
<summary><strong>15 - 15-expression-precedence.mc</strong></summary>

### Goal

Evaluate multiplication before addition.

### Code

```mc
head(custom)

fn main() {
    I64 left = 2
    I64 middle = 3
    I64 right = 4

    I64 multiplied = middle * right
    I64 result = left + multiplied

    pin("2 + 3 * 4 = %I64\n", result)

    return 0
}
```

</details>

<details>
<summary><strong>16 - 16-symbol-table.mc</strong></summary>

### Goal

Create a tiny symbol table with hash/value entries.

### Code

```mc
head(custom)
head(memory)

fn add_symbol(I64 table, I64 index, I64 hash, I64 value) {
    I64 offset = index * 16

    safe_write64(table, offset, hash)
    safe_write64(table, offset + 8, value)

    return 0
}

fn find_symbol(I64 table, I64 count, I64 hash) {
    I64 i = 0

    while (i < count) {
        I64 offset = i * 16

        if (safe_read64(table, offset) == hash) {
            return safe_read64(table, offset + 8)
        }

        i = i + 1
    }

    return 0 - 1
}

fn main() {
    I64 table = safe_alloc(160)

    add_symbol(table, 0, 1001, 42)
    add_symbol(table, 1, 1002, 99)

    pin("symbol = %I64\n", find_symbol(table, 2, 1002))

    safe_free(table)

    return 0
}
```

</details>

<details>
<summary><strong>17 - 17-emitter-buffer.mc</strong></summary>

### Goal

Create a machine-code output buffer.

### Code

```mc
head(custom)
head(memory)

fn emit8(I64 output, I64 state, I64 value) {
    I64 position = safe_read64(state, 0)

    safe_write8(output, position, value)
    safe_write64(state, 0, position + 1)

    return 0
}

fn main() {
    I64 output = safe_alloc(64)
    I64 state = safe_alloc(8)

    safe_write64(state, 0, 0)

    emit8(output, state, 0x90)
    emit8(output, state, 0x90)
    emit8(output, state, 0xC3)

    pin("size = %I64\n", safe_read64(state, 0))

    safe_free(state)
    safe_free(output)

    return 0
}
```

</details>

<details>
<summary><strong>18 - 18-emit-mov-return.mc</strong></summary>

### Goal

Emit x86-64 code for mov eax,42 followed by ret.

### Code

```mc
head(custom)
head(memory)

fn main() {
    I64 output = safe_alloc(16)

    safe_write8(output, 0, 0xB8)
    safe_write8(output, 1, 42)
    safe_write8(output, 2, 0)
    safe_write8(output, 3, 0)
    safe_write8(output, 4, 0)
    safe_write8(output, 5, 0xC3)

    I64 i = 0

    while (i < 6) {
        pin("%X64\n", safe_read8(output, i))
        i = i + 1
    }

    safe_free(output)

    return 0
}
```

</details>

<details>
<summary><strong>19 - 19-compile-return.mc</strong></summary>

### Goal

Parse `return NUMBER` and emit the matching x86 bytes.

### Code

```mc
head(custom)
head(memory)

fn parse_return_value(I64 source) {
    I64 position = 7
    I64 value = 0
    I64 reading = 1

    while (reading != 0) {
        I64 c = mem_read8(source + position)

        if (c < 48) {
            reading = 0
        }
        else {
            if (c > 57) {
                reading = 0
            }
            else {
                value = value * 10 + c - 48
                position = position + 1
            }
        }
    }

    return value
}

fn main() {
    I64 source = "return 42"
    I64 value = parse_return_value(source)
    I64 output = safe_alloc(16)

    safe_write8(output, 0, 0xB8)
    safe_write8(output, 1, value & 255)
    safe_write8(output, 2, (value >> 8) & 255)
    safe_write8(output, 3, (value >> 16) & 255)
    safe_write8(output, 4, (value >> 24) & 255)
    safe_write8(output, 5, 0xC3)

    pin("compiled return value = %I64\n", value)

    I64 i = 0
    while (i < 6) {
        pin("%X64\n", safe_read8(output, i))
        i = i + 1
    }

    safe_free(output)

    return 0
}
```

</details>

<details>
<summary><strong>20 - 20-mini-compiler.mc</strong></summary>

### Goal

Build a tiny compiler that turns `return NUMBER` into a raw x86 binary file.

### Code

```mc
head(custom)
head(memory)
head(file)

fn parse_return_value(I64 source) {
    I64 position = 7
    I64 value = 0
    I64 reading = 1

    while (reading != 0) {
        I64 c = mem_read8(source + position)

        if (c < 48) {
            reading = 0
        }
        else {
            if (c > 57) {
                reading = 0
            }
            else {
                value = value * 10 + c - 48
                position = position + 1
            }
        }
    }

    return value
}

fn emit_program(I64 output, I64 value) {
    safe_write8(output, 0, 0xB8)
    safe_write8(output, 1, value & 255)
    safe_write8(output, 2, (value >> 8) & 255)
    safe_write8(output, 3, (value >> 16) & 255)
    safe_write8(output, 4, (value >> 24) & 255)
    safe_write8(output, 5, 0xC3)

    return 6
}

fn write_binary(I64 path, I64 output, I64 size) {
    I64 fd = open(path, 577)

    if (fd < 0) {
        return 0
    }

    I64 i = 0

    while (i < size) {
        file_write8(fd, safe_read8(output, i))
        i = i + 1
    }

    close(fd)

    return 1
}

fn main() {
    I64 source = "return 42"
    I64 output = safe_alloc(64)

    I64 value = parse_return_value(source)
    I64 size = emit_program(output, value)

    if (write_binary("mini.bin", output, size) == 0) {
        pin("could not write mini.bin\n")
        return 1
    }

    pin("compiled: %s\n", source)
    pin("output: mini.bin\n")
    pin("bytes: %I64\n", size)

    safe_free(output)

    return 0
}
```

</details>

---

</details>

# After the examples

Once you finish the sections, rebuild selected examples without looking at the reference code.

```text
basics
  ↓
math + time
  ↓
memory
  ↓
2D graphics
  ↓
3D rendering
  ↓
networking
  ↓
authorized red teaming
  ↓
lexer
  ↓
parser
  ↓
x86 emitter
  ↓
your own compiler
```

After folder 08, open the real `compiler.mc` and map the small ideas from these examples to its lexer, parser, type handling, builtin dispatch and x86 code emitter.