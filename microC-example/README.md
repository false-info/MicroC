# MicroC Examples

This README is the complete learning path for the current MicroC syntax.

Every example contains complete reference code. Try writing each `.mc` file yourself first, then compare it with the version here.

# Current syntax

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

Do not use the old wrapped syntax:

```text
head(custom) {
    ...
}
```

# Folder layout

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
│
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
│
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
│
├── 04-graphics-2d/
│   ├── 01-window.mc
│   ├── 02-pixels.mc
│   ├── 03-lines.mc
│   ├── 04-rectangles.mc
│   ├── 05-gradient.mc
│   ├── 06-grid.mc
│   ├── 07-circle.mc
│   ├── 08-animation.mc
│   ├── 09-orbit.mc
│   └── 10-gravity.mc
│
├── 05-graphics-3d/
│   ├── 01-perspective.mc
│   ├── 02-perspective-grid.mc
│   ├── 03-rotating-point.mc
│   ├── 04-wireframe-cube.mc
│   ├── 05-axis.mc
│   ├── 06-starfield.mc
│   ├── 07-orbit.mc
│   ├── 08-height-mesh.mc
│   ├── 09-gravity-mesh.mc
│   └── 10-scene.mc
│
├── 06-networking/
│   ├── 01-socket.mc
│   ├── 02-address.mc
│   ├── 03-bind.mc
│   ├── 04-listen.mc
│   ├── 05-connect.mc
│   ├── 06-send.mc
│   ├── 07-receive.mc
│   ├── 08-echo-server.mc
│   ├── 09-udp.mc
│   └── 10-poll.mc
│
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
│
└── 08-compiler/
    ├── 01-source.mc
    ├── 02-next-char.mc
    ├── 03-peek-char.mc
    ├── 04-char-classes.mc
    ├── 05-skip-whitespace.mc
    ├── 06-read-number.mc
    ├── 07-read-identifier.mc
    ├── 08-token-kinds.mc
    ├── 09-next-token.mc
    ├── 10-keywords.mc
    ├── 11-token-structure.mc
    ├── 12-parser-cursor.mc
    ├── 13-parse-primary.mc
    ├── 14-parse-addition.mc
    ├── 15-expression-precedence.mc
    ├── 16-symbol-table.mc
    ├── 17-emitter-buffer.mc
    ├── 18-emit-mov-return.mc
    ├── 19-compile-return.mc
    └── 20-mini-compiler.mc
```

# 01 - Basics

## 01-hello.mc

```mc
head(custom)

fn main() {
    pin("Hello from MicroC!\n")
    return 0
}
```

## 02-variables.mc

```mc
head(custom)

fn main() {
    I64 x = 42
    U64 y = 100
    F64 gravity = 9.81
    Bool running = true

    pin("x = %I64\n", x)
    pin("y = %U64\n", y)
    pin("gravity = %F64\n", gravity)
    pin("running = %I64\n", running)

    return 0
}
```

## 03-arithmetic.mc

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

    return 0
}
```

## 04-if-else.mc

```mc
head(custom)

fn main() {
    I64 x = 10

    if (x >= 10) {
        pin("large\n")
    }
    else {
        pin("small\n")
    }

    return 0
}
```

## 05-while.mc

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

## 06-functions.mc

```mc
head(custom)

fn add(I64 a, I64 b) {
    return a + b
}

fn main() {
    I64 result = add(20, 22)
    pin("result = %I64\n", result)
    return 0
}
```

## 07-bool-logic.mc

```mc
head(custom)

fn main() {
    I64 a = 1
    I64 b = 1

    if ((a == 1) && (b == 1)) {
        pin("both true\n")
    }

    if ((a == 0) || (b == 1)) {
        pin("at least one true\n")
    }

    return 0
}
```

## 08-types-and-cast.mc

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

## 09-strings.mc

```mc
head(custom)

fn main() {
    I64 text = "MicroC"

    pin("%s\n", text)
    pin("length = %I64\n", strlen(text))

    if (strcmp(text, "MicroC") == 0) {
        pin("match\n")
    }

    return 0
}
```

## 10-fizzbuzz.mc

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

# 02 - Math and Time

## 01-sqrt.mc

```mc
head(custom)
head(math)

fn main() {
    F64 result = math_sqrt(144.0)
    pin("%F64\n", result)
    return 0
}
```

## 02-hypot.mc

```mc
head(custom)
head(math)

fn main() {
    F64 x = 3.0
    F64 y = 4.0

    F64 distance = math_hypot(x, y)

    pin("%F64\n", distance)
    return 0
}
```

## 03-constants.mc

```mc
head(custom)
head(math)

fn main() {
    pin("pi = %F64\n", math_pi())
    pin("tau = %F64\n", math_tau())
    pin("e = %F64\n", math_e())

    return 0
}
```

## 04-clamp-lerp.mc

```mc
head(custom)
head(math)

fn main() {
    F64 a = math_clamp(15.0, 0.0, 10.0)
    F64 b = math_lerp(10.0, 20.0, 0.5)

    pin("clamp = %F64\n", a)
    pin("lerp = %F64\n", b)

    return 0
}
```

## 05-sin-cos.mc

```mc
head(custom)
head(math)

fn main() {
    F64 angle = 0.0

    while (angle < math_tau()) {
        F64 x = math_cos(angle)
        F64 y = math_sin(angle)

        pin("x=%F64 y=%F64\n", x, y)

        angle = angle + 0.5
    }

    return 0
}
```

## 06-atan2.mc

```mc
head(custom)
head(math)

fn main() {
    F64 angle = math_atan2(1.0, 1.0)
    F64 degrees = math_rad_to_deg(angle)

    pin("%F64\n", degrees)

    return 0
}
```

## 07-normalize-vector.mc

```mc
head(custom)
head(math)

fn main() {
    F64 x = 3.0
    F64 y = 4.0
    F64 z = 12.0

    F64 d2 = x * x + y * y + z * z
    F64 inv = math_inv_sqrt(d2)

    x = x * inv
    y = y * inv
    z = z * inv

    pin("%F64 %F64 %F64\n", x, y, z)

    return 0
}
```

## 08-degrees-radians.mc

```mc
head(custom)
head(math)

fn main() {
    F64 radians = math_deg_to_rad(90.0)
    F64 degrees = math_rad_to_deg(radians)

    pin("rad = %F64\n", radians)
    pin("deg = %F64\n", degrees)

    return 0
}
```

## 09-monotonic-time.mc

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

## 10-orbit-math.mc

```mc
head(custom)
head(math)
head(time)

fn main() {
    F64 angle = 0.0
    I64 frame = 0

    while (frame < 20) {
        F64 x = math_cos(angle) * 100.0
        F64 y = math_sin(angle) * 100.0

        pin("%F64 %F64\n", x, y)

        angle = angle + 0.2
        frame = frame + 1

        sleep_ms(50)
    }

    return 0
}
```

# 03 - Memory

## 01-alloc-free.mc

```mc
head(custom)
head(memory)

fn main() {
    I64 buffer = safe_alloc(64)

    pin("size = %I64\n", safe_len(buffer))

    safe_free(buffer)
    return 0
}
```

## 02-read-write-widths.mc

```mc
head(custom)
head(memory)

fn main() {
    I64 buffer = safe_alloc(32)

    safe_write8(buffer, 0, 0x12)
    safe_write16(buffer, 2, 0x3456)
    safe_write32(buffer, 4, 0x789ABCDE)
    safe_write64(buffer, 8, 0x123456789ABCDEF)

    pin("%X64\n", safe_read8(buffer, 0))
    pin("%X64\n", safe_read16(buffer, 2))
    pin("%X64\n", safe_read32(buffer, 4))
    pin("%X64\n", safe_read64(buffer, 8))

    safe_free(buffer)
    return 0
}
```

## 03-calloc.mc

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

## 04-realloc.mc

```mc
head(custom)
head(memory)

fn main() {
    I64 buffer = safe_alloc(4)

    safe_write8(buffer, 0, 42)

    buffer = safe_realloc(buffer, 32)

    pin("size = %I64\n", safe_len(buffer))
    pin("value = %I64\n", safe_read8(buffer, 0))

    safe_free(buffer)
    return 0
}
```

## 05-byte-array.mc

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

## 06-copy-buffer.mc

```mc
head(custom)
head(memory)

fn copy(I64 destination, I64 source, I64 count) {
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

    safe_write8(source, 0, 42)

    copy(destination, source, 8)

    pin("%I64\n", safe_read8(destination, 0))

    safe_free(source)
    safe_free(destination)

    return 0
}
```

## 07-fill-buffer.mc

```mc
head(custom)
head(memory)

fn main() {
    I64 buffer = safe_alloc(32)
    I64 i = 0

    while (i < 32) {
        safe_write8(buffer, i, 65)
        i = i + 1
    }

    i = 0

    while (i < 32) {
        pin("%c", safe_read8(buffer, i))
        i = i + 1
    }

    pin("\n")

    safe_free(buffer)
    return 0
}
```

## 08-struct-layout.mc

```mc
head(custom)
head(memory)

fn main() {
    I64 object = safe_alloc(24)

    safe_write64(object, 0, 100)
    safe_write64(object, 8, 200)
    safe_write64(object, 16, 300)

    pin("x=%I64\n", safe_read64(object, 0))
    pin("y=%I64\n", safe_read64(object, 8))
    pin("z=%I64\n", safe_read64(object, 16))

    safe_free(object)
    return 0
}
```

## 09-stack.mc

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
        pin("%I64\n", safe_read64(stack, top * 8))
    }

    safe_free(stack)
    return 0
}
```

## 10-arena.mc

```mc
head(custom)
head(memory)

fn main() {
    I64 arena = safe_alloc(256)
    I64 used = 0

    I64 first = used
    used = used + 32

    I64 second = used
    used = used + 64

    safe_write64(arena, first, 111)
    safe_write64(arena, second, 222)

    pin("%I64\n", safe_read64(arena, first))
    pin("%I64\n", safe_read64(arena, second))
    pin("used = %I64\n", used)

    safe_free(arena)
    return 0
}
```

# 04 - 2D Graphics

## 01-window.mc

```mc
head(custom)
head(graphics)
head(time)

fn main() {
    gfx_open(800, 500)

    gfx_clear(gfx_rgb(5, 5, 10))
    gfx_present()

    sleep_ms(1500)

    gfx_close()
    return 0
}
```

## 02-pixels.mc

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

## 03-lines.mc

```mc
head(custom)
head(graphics)
head(time)

fn main() {
    gfx_open(800, 500)
    gfx_clear(gfx_rgb(0, 0, 0))

    gfx_line(50, 50, 750, 450, gfx_rgb(255, 60, 20))
    gfx_line(750, 50, 50, 450, gfx_rgb(50, 140, 255))

    gfx_present()
    sleep_ms(1500)

    gfx_close()
    return 0
}
```

## 04-rectangles.mc

```mc
head(custom)
head(graphics)
head(time)

fn main() {
    gfx_open(800, 500)
    gfx_clear(gfx_rgb(0, 0, 0))

    gfx_rect_fill(100, 100, 200, 100, gfx_rgb(255, 70, 20))
    gfx_rect_fill(400, 250, 200, 100, gfx_rgb(50, 140, 255))

    gfx_present()
    sleep_ms(1500)

    gfx_close()
    return 0
}
```

## 05-gradient.mc

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

        gfx_rect_fill(x, 0, 1, 500, gfx_rgb(red, 20, blue))

        x = x + 1
    }

    gfx_present()
    sleep_ms(1500)

    gfx_close()
    return 0
}
```

## 06-grid.mc

```mc
head(custom)
head(graphics)
head(time)

fn main() {
    gfx_open(800, 500)
    gfx_clear(gfx_rgb(0, 0, 0))

    I64 color = gfx_rgb(75, 80, 95)

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

## 07-circle.mc

```mc
head(custom)
head(graphics)
head(time)

fn main() {
    gfx_open(800, 500)
    gfx_clear(gfx_rgb(0, 0, 0))

    I64 radius = 80
    I64 y = 0 - radius

    while (y <= radius) {
        I64 x = 0 - radius

        while (x <= radius) {
            if (x * x + y * y <= radius * radius) {
                gfx_pixel(400 + x, 250 + y, gfx_rgb(255, 70, 20))
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

## 08-animation.mc

```mc
head(custom)
head(graphics)
head(time)

fn main() {
    gfx_open(800, 500)

    I64 x = 20
    I64 velocity = 5
    I64 running = 1

    while (running != 0) {
        gfx_clear(gfx_rgb(0, 0, 0))

        gfx_rect_fill(x, 225, 50, 50, gfx_rgb(255, 70, 20))

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

## 09-orbit.mc

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

        F64 xf = 400.0 + math_cos(angle) * 150.0
        F64 yf = 250.0 + math_sin(angle) * 150.0

        I64 x = cast(I64, xf)
        I64 y = cast(I64, yf)

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

## 10-gravity.mc

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

# 05 - 3D Rendering

MicroC currently renders 3D in software.

The 3D math converts `(x, y, z)` into screen coordinates and then draws the result using the normal graphics API.

## 01-perspective.mc

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

    gfx_rect_fill(sx - 4, sy - 4, 8, 8, gfx_rgb(255, 70, 20))

    gfx_present()
    sleep_ms(1500)

    gfx_close()
    return 0
}
```

## 02-perspective-grid.mc

```mc
head(custom)
head(graphics)
head(time)

fn main() {
    gfx_open(800, 500)
    gfx_clear(gfx_rgb(0, 0, 0))

    F64 z = 120.0

    while (z <= 800.0) {
        I64 x1 = cast(I64, 400.0 - 350.0 * 420.0 / z)
        I64 x2 = cast(I64, 400.0 + 350.0 * 420.0 / z)
        I64 y = cast(I64, 120.0 + 170.0 * 420.0 / z)

        gfx_line(x1, y, x2, y, gfx_rgb(100, 105, 120))

        z = z + 40.0
    }

    gfx_present()
    sleep_ms(1500)

    gfx_close()
    return 0
}
```

## 03-rotating-point.mc

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

        I64 sx = cast(I64, 400.0 + x * 420.0 / z)

        gfx_rect_fill(sx - 5, 245, 10, 10, gfx_rgb(255, 70, 20))

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

## 04-wireframe-cube.mc

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

        I64 sx0 = cast(I64, 400.0 + rx0 * 420.0 / rz0)
        I64 sx1 = cast(I64, 400.0 + rx1 * 420.0 / rz1)
        I64 sx2 = cast(I64, 400.0 + rx2 * 420.0 / rz2)
        I64 sx3 = cast(I64, 400.0 + rx3 * 420.0 / rz3)

        I64 y0 = cast(I64, 250.0 - 70.0 * 420.0 / rz0)
        I64 y1 = cast(I64, 250.0 - 70.0 * 420.0 / rz1)
        I64 y2 = cast(I64, 250.0 - 70.0 * 420.0 / rz2)
        I64 y3 = cast(I64, 250.0 - 70.0 * 420.0 / rz3)

        I64 color = gfx_rgb(225, 225, 235)

        gfx_line(sx0, y0, sx1, y1, color)
        gfx_line(sx1, y1, sx2, y2, color)
        gfx_line(sx2, y2, sx3, y3, color)
        gfx_line(sx3, y3, sx0, y0, color)

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

## 05-axis.mc

```mc
head(custom)
head(graphics)
head(time)

fn main() {
    gfx_open(800, 500)
    gfx_clear(gfx_rgb(0, 0, 0))

    gfx_line(400, 250, 550, 250, gfx_rgb(255, 60, 40))
    gfx_line(400, 250, 400, 100, gfx_rgb(60, 255, 100))
    gfx_line(400, 250, 330, 340, gfx_rgb(70, 140, 255))

    gfx_present()
    sleep_ms(1500)

    gfx_close()
    return 0
}
```

## 06-starfield.mc

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

## 07-orbit.mc

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

## 08-height-mesh.mc

```mc
head(custom)
head(graphics)
head(math)
head(time)

fn main() {
    gfx_open(800, 500)
    gfx_clear(gfx_rgb(0, 0, 0))

    F64 z = -220.0

    while (z <= 220.0) {
        F64 x = -320.0

        I64 have = 0
        I64 old_x = 0
        I64 old_y = 0

        while (x <= 320.0) {
            F64 y = math_sin(x * 0.02) * 25.0
            F64 depth = z + 620.0

            I64 sx = cast(I64, 400.0 + x * 460.0 / depth)
            I64 sy = cast(I64, 170.0 - y * 460.0 / depth + z * 0.45)

            if (have != 0) {
                gfx_line(old_x, old_y, sx, sy, gfx_rgb(130, 135, 150))
            }

            old_x = sx
            old_y = sy
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

## 09-gravity-mesh.mc

```mc
head(custom)
head(graphics)
head(math)
head(time)

fn main() {
    gfx_open(960, 720)

    F64 angle = 0.0
    F64 pitch = 0.75

    F64 pitch_cos = math_cos(pitch)
    F64 pitch_sin = math_sin(pitch)

    I64 running = 1

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
            I64 old_x = 0
            I64 old_y = 0

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
                    gfx_line(old_x, old_y, sx, sy, gfx_rgb(135, 138, 148))
                }

                old_x = sx
                old_y = sy
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

## 10-scene.mc

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

        I64 x = 80

        while (x <= 880) {
            gfx_line(x, 360, 480 + (x - 480) / 4, 250, gfx_rgb(60, 65, 80))
            x = x + 40
        }

        F64 orbit_x = math_cos(angle) * 150.0
        F64 orbit_z = 420.0 + math_sin(angle) * 120.0

        I64 sx = cast(I64, 480.0 + orbit_x * 420.0 / orbit_z)

        gfx_rect_fill(474, 274, 12, 12, gfx_rgb(255, 210, 40))
        gfx_rect_fill(sx - 6, 274, 12, 12, gfx_rgb(255, 70, 20))

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

# 06 - Networking

All network examples use localhost.

## 01-socket.mc

```mc
head(custom)
head(networking)
head(file)

fn main() {
    I64 fd = net_socket(2, 1, 0)

    pin("fd = %I64\n", fd)

    if (fd >= 0) {
        close(fd)
    }

    return 0
}
```

## 02-address.mc

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

    pin("127.0.0.1:8080 sockaddr created\n")

    safe_free(address)
    return 0
}
```

## 03-bind.mc

```mc
head(custom)
head(networking)
head(memory)
head(file)

fn make_address(I64 address) {
    safe_write8(address, 0, 2)
    safe_write8(address, 1, 0)
    safe_write8(address, 2, 31)
    safe_write8(address, 3, 144)
    safe_write8(address, 4, 127)
    safe_write8(address, 5, 0)
    safe_write8(address, 6, 0)
    safe_write8(address, 7, 1)
    return 0
}

fn main() {
    I64 fd = net_socket(2, 1, 0)
    I64 address = safe_alloc(16)

    make_address(address)

    pin("bind = %I64\n", net_bind(fd, address, 16))

    close(fd)
    safe_free(address)

    return 0
}
```

## 04-listen.mc

```mc
head(custom)
head(networking)
head(memory)
head(file)

fn make_address(I64 address) {
    safe_write8(address, 0, 2)
    safe_write8(address, 1, 0)
    safe_write8(address, 2, 31)
    safe_write8(address, 3, 144)
    safe_write8(address, 4, 127)
    safe_write8(address, 5, 0)
    safe_write8(address, 6, 0)
    safe_write8(address, 7, 1)
    return 0
}

fn main() {
    I64 fd = net_socket(2, 1, 0)
    I64 address = safe_alloc(16)

    make_address(address)

    if (net_bind(fd, address, 16) == 0) {
        pin("listen = %I64\n", net_listen(fd, 8))
    }

    close(fd)
    safe_free(address)

    return 0
}
```

## 05-connect.mc

```mc
head(custom)
head(networking)
head(memory)
head(file)

fn make_address(I64 address) {
    safe_write8(address, 0, 2)
    safe_write8(address, 1, 0)
    safe_write8(address, 2, 31)
    safe_write8(address, 3, 144)
    safe_write8(address, 4, 127)
    safe_write8(address, 5, 0)
    safe_write8(address, 6, 0)
    safe_write8(address, 7, 1)
    return 0
}

fn main() {
    I64 fd = net_socket(2, 1, 0)
    I64 address = safe_alloc(16)

    make_address(address)

    pin("connect = %I64\n", net_connect(fd, address, 16))

    close(fd)
    safe_free(address)

    return 0
}
```

## 06-send.mc

```mc
head(custom)
head(networking)
head(memory)
head(file)

fn make_address(I64 address) {
    safe_write8(address, 0, 2)
    safe_write8(address, 1, 0)
    safe_write8(address, 2, 31)
    safe_write8(address, 3, 144)
    safe_write8(address, 4, 127)
    safe_write8(address, 5, 0)
    safe_write8(address, 6, 0)
    safe_write8(address, 7, 1)
    return 0
}

fn main() {
    I64 fd = net_socket(2, 1, 0)
    I64 address = safe_alloc(16)

    make_address(address)

    if (net_connect(fd, address, 16) == 0) {
        I64 message = "hello\n"

        pin("sent = %I64\n", net_sendto(fd, message, strlen(message), 0, 0, 0))
    }

    close(fd)
    safe_free(address)

    return 0
}
```

## 07-receive.mc

```mc
head(custom)
head(networking)
head(memory)
head(file)

fn main() {
    I64 buffer = safe_alloc(129)
    I64 fd = net_socket(2, 1, 0)

    I64 count = net_recvfrom(fd, buffer, 128, 0, 0, 0)

    if (count > 0) {
        safe_write8(buffer, count, 0)
        pin("%s\n", buffer)
    }

    close(fd)
    safe_free(buffer)

    return 0
}
```

## 08-echo-server.mc

```mc
head(custom)
head(networking)
head(memory)
head(file)

fn make_address(I64 address) {
    safe_write8(address, 0, 2)
    safe_write8(address, 1, 0)
    safe_write8(address, 2, 31)
    safe_write8(address, 3, 144)
    safe_write8(address, 4, 127)
    safe_write8(address, 5, 0)
    safe_write8(address, 6, 0)
    safe_write8(address, 7, 1)
    return 0
}

fn main() {
    I64 server = net_socket(2, 1, 0)
    I64 address = safe_alloc(16)
    I64 buffer = safe_alloc(256)

    make_address(address)

    net_bind(server, address, 16)
    net_listen(server, 8)

    I64 client = net_accept(server, 0, 0)

    if (client >= 0) {
        I64 count = net_recvfrom(client, buffer, 255, 0, 0, 0)

        if (count > 0) {
            net_sendto(client, buffer, count, 0, 0, 0)
        }

        close(client)
    }

    close(server)

    safe_free(buffer)
    safe_free(address)

    return 0
}
```

## 09-udp.mc

```mc
head(custom)
head(networking)
head(memory)
head(file)

fn main() {
    I64 fd = net_socket(2, 2, 0)
    I64 address = safe_alloc(16)

    safe_write8(address, 0, 2)
    safe_write8(address, 1, 0)
    safe_write8(address, 2, 31)
    safe_write8(address, 3, 144)
    safe_write8(address, 4, 127)
    safe_write8(address, 5, 0)
    safe_write8(address, 6, 0)
    safe_write8(address, 7, 1)

    I64 message = "MicroC UDP"

    pin("sent = %I64\n", net_sendto(fd, message, strlen(message), 0, address, 16))

    close(fd)
    safe_free(address)

    return 0
}
```

## 10-poll.mc

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

    pin("ready = %I64\n", ready)

    close(fd)
    safe_free(pollfd)

    return 0
}
```

# 07 - Red Teaming

These examples are for your own lab or systems you have permission to test.

The active network examples stay on `127.0.0.1`.

## 50-scope-check.mc

```mc
head(custom)

fn in_scope(I64 target) {
    if (strcmp(target, "127.0.0.1") == 0) {
        return 1
    }

    if (strcmp(target, "localhost") == 0) {
        return 1
    }

    return 0
}

fn main() {
    I64 target = "127.0.0.1"

    if (in_scope(target) == 0) {
        pin("out of scope\n")
        return 1
    }

    pin("authorized target: %s\n", target)

    return 0
}
```

## 51-local-port-probe.mc

```mc
head(custom)
head(networking)
head(memory)
head(file)

fn make_address(I64 address, I64 port) {
    safe_write8(address, 0, 2)
    safe_write8(address, 1, 0)

    safe_write8(address, 2, port / 256)
    safe_write8(address, 3, port % 256)

    safe_write8(address, 4, 127)
    safe_write8(address, 5, 0)
    safe_write8(address, 6, 0)
    safe_write8(address, 7, 1)

    return 0
}

fn main() {
    I64 port = 8080

    I64 address = safe_alloc(16)
    I64 fd = net_socket(2, 1, 0)

    make_address(address, port)

    if (net_connect(fd, address, 16) == 0) {
        pin("127.0.0.1:%I64 open\n", port)
    }
    else {
        pin("closed\n")
    }

    close(fd)
    safe_free(address)

    return 0
}
```

## 52-local-port-inventory.mc

```mc
head(custom)
head(networking)
head(memory)
head(file)

fn make_address(I64 address, I64 port) {
    safe_write8(address, 0, 2)
    safe_write8(address, 1, 0)

    safe_write8(address, 2, port / 256)
    safe_write8(address, 3, port % 256)

    safe_write8(address, 4, 127)
    safe_write8(address, 5, 0)
    safe_write8(address, 6, 0)
    safe_write8(address, 7, 1)

    return 0
}

fn main() {
    I64 address = safe_alloc(16)

    I64 port = 8000

    while (port <= 8010) {
        I64 fd = net_socket(2, 1, 0)

        make_address(address, port)

        if (net_connect(fd, address, 16) == 0) {
            pin("open: %I64\n", port)
        }

        close(fd)

        port = port + 1
    }

    safe_free(address)

    return 0
}
```

## 53-local-banner-reader.mc

```mc
head(custom)
head(networking)
head(memory)
head(file)

fn make_address(I64 address) {
    safe_write8(address, 0, 2)
    safe_write8(address, 1, 0)
    safe_write8(address, 2, 31)
    safe_write8(address, 3, 144)
    safe_write8(address, 4, 127)
    safe_write8(address, 5, 0)
    safe_write8(address, 6, 0)
    safe_write8(address, 7, 1)
    return 0
}

fn main() {
    I64 fd = net_socket(2, 1, 0)

    I64 address = safe_alloc(16)
    I64 buffer = safe_alloc(129)

    make_address(address)

    if (net_connect(fd, address, 16) != 0) {
        pin("local service unavailable\n")
        return 1
    }

    I64 count = net_recvfrom(fd, buffer, 128, 0, 0, 0)

    if (count > 0) {
        safe_write8(buffer, count, 0)
        pin("banner: %s\n", buffer)
    }

    close(fd)

    safe_free(buffer)
    safe_free(address)

    return 0
}
```

## 54-http-request-builder.mc

```mc
head(custom)

fn main() {
    I64 request = "GET / HTTP/1.1\r\nHost: 127.0.0.1\r\nConnection: close\r\n\r\n"

    pin("%s", request)
    pin("bytes = %I64\n", strlen(request))

    return 0
}
```

## 55-http-status-parser.mc

```mc
head(custom)
head(memory)

fn main() {
    I64 response = "HTTP/1.1 404 Not Found\r\n"

    I64 a = mem_read8(response + 9) - 48
    I64 b = mem_read8(response + 10) - 48
    I64 c = mem_read8(response + 11) - 48

    I64 status = a * 100 + b * 10 + c

    pin("status = %I64\n", status)

    return 0
}
```

## 56-http-header-counter.mc

```mc
head(custom)
head(memory)

fn main() {
    I64 response = "HTTP/1.1 200 OK\r\nServer: lab\r\nContent-Type: text/plain\r\n\r\n"

    I64 length = strlen(response)

    I64 i = 0
    I64 lines = 0

    while (i + 1 < length) {
        if (mem_read8(response + i) == 13) {
            if (mem_read8(response + i + 1) == 10) {
                lines = lines + 1
                i = i + 1
            }
        }

        i = i + 1
    }

    pin("lines = %I64\n", lines)

    return 0
}
```

## 57-file-magic.mc

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
        return 1
    }

    I64 a = file_read8(fd)
    I64 b = file_read8(fd)
    I64 c = file_read8(fd)
    I64 d = file_read8(fd)

    if ((a == 0x7F) && (b == 0x45) && (c == 0x4C) && (d == 0x46)) {
        pin("ELF\n")
    }
    else {
        if ((a == 0x89) && (b == 0x50) && (c == 0x4E) && (d == 0x47)) {
            pin("PNG\n")
        }
        else {
            pin("unknown\n")
        }
    }

    close(fd)
    return 0
}
```

## 58-hexdump.mc

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
        return 1
    }

    I64 size = file_size(fd)

    if (size > 64) {
        size = 64
    }

    I64 i = 0

    while (i < size) {
        pin("%X64 ", file_read8(fd))

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

## 59-string-extractor.mc

```mc
head(custom)
head(memory)

fn main() {
    I64 buffer = safe_alloc(16)

    safe_write8(buffer, 0, 1)
    safe_write8(buffer, 1, 72)
    safe_write8(buffer, 2, 69)
    safe_write8(buffer, 3, 76)
    safe_write8(buffer, 4, 76)
    safe_write8(buffer, 5, 79)
    safe_write8(buffer, 6, 0)

    I64 i = 0

    while (i < 7) {
        I64 c = safe_read8(buffer, i)

        if ((c >= 32) && (c <= 126)) {
            pin("%c", c)
        }

        i = i + 1
    }

    pin("\n")

    safe_free(buffer)
    return 0
}
```

## 60-fnv-fingerprint.mc

```mc
head(custom)
head(memory)

fn main() {
    I64 text = "authorized-lab"

    I64 hash = fnv1a64(text, strlen(text))

    pin("%X64\n", hash)

    return 0
}
```

## 61-integrity-check.mc

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

    I64 before = fnv1a64(buffer, 8)

    safe_write8(buffer, 3, 99)

    I64 after = fnv1a64(buffer, 8)

    if (before != after) {
        pin("change detected\n")
    }

    safe_free(buffer)

    return 0
}
```

## 62-input-boundary-test.mc

```mc
head(custom)

fn valid_name(I64 text) {
    I64 length = strlen(text)

    if (length == 0) {
        return 0
    }

    if (length > 16) {
        return 0
    }

    return 1
}

fn main() {
    pin("%I64\n", valid_name(""))
    pin("%I64\n", valid_name("hello"))
    pin("%I64\n", valid_name("this_name_is_too_long"))

    return 0
}
```

## 63-toy-parser-fuzzer.mc

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
    pin("%s -> %I64\n", text, parse_number(text))
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

## 64-canary-check.mc

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

## 65-failed-login-counter.mc

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

    pin("failures = %I64\n", failures)

    safe_free(events)
    return 0
}
```

## 66-rate-limit-simulator.mc

```mc
head(custom)

fn main() {
    I64 attempts = 0
    I64 request = 1

    while (request <= 8) {
        attempts = attempts + 1

        if (attempts > 5) {
            pin("%I64 blocked\n", request)
        }
        else {
            pin("%I64 allowed\n", request)
        }

        request = request + 1
    }

    return 0
}
```

## 67-path-traversal-detector.mc

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
    pin("%I64\n", suspicious_path("assets/image.bmp"))
    pin("%I64\n", suspicious_path("../../secret"))

    return 0
}
```

## 68-protocol-be-parser.mc

```mc
head(custom)
head(memory)

fn main() {
    I64 packet = safe_alloc(16)

    safe_write_be16(packet, 0, 0x1234)
    safe_write_be16(packet, 2, 80)
    safe_write_be32(packet, 4, 0x7F000001)

    pin("type = %X64\n", safe_read_be16(packet, 0))
    pin("port = %I64\n", safe_read_be16(packet, 2))
    pin("address = %X64\n", safe_read_be32(packet, 4))

    safe_free(packet)

    return 0
}
```

## 69-finding-score.mc

```mc
head(custom)

fn severity(I64 impact, I64 confidence) {
    I64 score = impact * confidence

    if (score >= 20) {
        return 4
    }

    if (score >= 12) {
        return 3
    }

    if (score >= 6) {
        return 2
    }

    return 1
}

fn main() {
    I64 level = severity(5, 4)

    pin("severity = %I64\n", level)

    return 0
}
```

## 70-report-summary.mc

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

# 08 - Build Your Own Compiler

This folder builds a tiny compiler step by step.

# 01-source.mc

```mc
head(custom)
head(memory)

fn main() {
    I64 source = "return 42"

    I64 i = 0

    while (i < strlen(source)) {
        pin("%c\n", mem_read8(source + i))
        i = i + 1
    }

    return 0
}
```

# 02-next-char.mc

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

# 03-peek-char.mc

```mc
head(custom)
head(memory)

fn peek_char(I64 source, I64 position) {
    return mem_read8(source + position)
}

fn main() {
    I64 source = "abc"

    pin("%c\n", peek_char(source, 1))

    return 0
}
```

# 04-char-classes.mc

```mc
head(custom)

fn is_digit(I64 c) {
    if ((c >= 48) && (c <= 57)) {
        return 1
    }

    return 0
}

fn is_letter(I64 c) {
    if ((c >= 65) && (c <= 90)) {
        return 1
    }

    if ((c >= 97) && (c <= 122)) {
        return 1
    }

    return 0
}

fn main() {
    pin("%I64\n", is_digit(53))
    pin("%I64\n", is_letter(65))

    return 0
}
```

# 05-skip-whitespace.mc

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

fn skip(I64 source, I64 position) {
    I64 length = strlen(source)

    while (position < length) {
        if (is_space(mem_read8(source + position)) == 0) {
            return position
        }

        position = position + 1
    }

    return position
}

fn main() {
    pin("%I64\n", skip("    return 42", 0))
    return 0
}
```

# 06-read-number.mc

```mc
head(custom)
head(memory)

fn read_number(I64 source, I64 position) {
    I64 value = 0
    I64 reading = 1

    while (reading != 0) {
        I64 c = mem_read8(source + position)

        if ((c < 48) || (c > 57)) {
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
    pin("%I64\n", read_number("583+", 0))

    return 0
}
```

# 07-read-identifier.mc

```mc
head(custom)
head(memory)

fn valid(I64 c) {
    if ((c >= 65) && (c <= 90)) { return 1 }
    if ((c >= 97) && (c <= 122)) { return 1 }
    if ((c >= 48) && (c <= 57)) { return 1 }
    if (c == 95) { return 1 }

    return 0
}

fn main() {
    I64 source = "kernel_main("
    I64 output = safe_alloc(64)

    I64 i = 0

    while (valid(mem_read8(source + i)) != 0) {
        safe_write8(output, i, mem_read8(source + i))
        i = i + 1
    }

    safe_write8(output, i, 0)

    pin("%s\n", output)

    safe_free(output)

    return 0
}
```

# 08-token-kinds.mc

```mc
head(custom)

fn token_kind(I64 c) {
    if ((c >= 48) && (c <= 57)) {
        return 2
    }

    if ((c >= 65) && (c <= 90)) {
        return 1
    }

    if ((c >= 97) && (c <= 122)) {
        return 1
    }

    if (c == 43) {
        return 3
    }

    return 0
}

fn main() {
    pin("A = %I64\n", token_kind(65))
    pin("7 = %I64\n", token_kind(55))
    pin("+ = %I64\n", token_kind(43))

    return 0
}
```

# 09-next-token.mc

```mc
head(custom)
head(memory)

fn main() {
    I64 source = "x + 42"

    I64 i = 0
    I64 length = strlen(source)

    while (i < length) {
        I64 c = mem_read8(source + i)

        if (c != 32) {
            pin("token char = %c\n", c)
        }

        i = i + 1
    }

    return 0
}
```

# 10-keywords.mc

```mc
head(custom)

fn keyword(I64 text) {
    if (strcmp(text, "fn") == 0) { return 1 }
    if (strcmp(text, "return") == 0) { return 2 }
    if (strcmp(text, "if") == 0) { return 3 }
    if (strcmp(text, "else") == 0) { return 4 }
    if (strcmp(text, "while") == 0) { return 5 }

    return 0
}

fn main() {
    pin("%I64\n", keyword("return"))
    return 0
}
```

# 11-token-structure.mc

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

# 12-parser-cursor.mc

```mc
head(custom)
head(memory)

fn current(I64 tokens, I64 position) {
    return safe_read64(tokens, position * 8)
}

fn main() {
    I64 tokens = safe_alloc(32)

    safe_write64(tokens, 0, 10)
    safe_write64(tokens, 8, 20)
    safe_write64(tokens, 16, 30)
    safe_write64(tokens, 24, 0)

    I64 position = 0

    while (current(tokens, position) != 0) {
        pin("%I64\n", current(tokens, position))
        position = position + 1
    }

    safe_free(tokens)

    return 0
}
```

# 13-parse-primary.mc

```mc
head(custom)
head(memory)

fn parse_primary(I64 source) {
    I64 value = 0
    I64 i = 0

    while (i < strlen(source)) {
        I64 c = mem_read8(source + i)

        if ((c < 48) || (c > 57)) {
            return value
        }

        value = value * 10 + c - 48
        i = i + 1
    }

    return value
}

fn main() {
    pin("%I64\n", parse_primary("123"))

    return 0
}
```

# 14-parse-addition.mc

```mc
head(custom)
head(memory)

fn read_number(I64 source, I64 start) {
    I64 value = 0
    I64 i = start

    while (i < strlen(source)) {
        I64 c = mem_read8(source + i)

        if ((c < 48) || (c > 57)) {
            return value
        }

        value = value * 10 + c - 48
        i = i + 1
    }

    return value
}

fn main() {
    I64 source = "12+30"

    I64 left = read_number(source, 0)
    I64 right = read_number(source, 3)

    pin("%I64\n", left + right)

    return 0
}
```

# 15-expression-precedence.mc

```mc
head(custom)

fn main() {
    I64 left = 2
    I64 middle = 3
    I64 right = 4

    I64 multiplied = middle * right
    I64 result = left + multiplied

    pin("%I64\n", result)

    return 0
}
```

# 16-symbol-table.mc

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

    pin("%I64\n", find_symbol(table, 2, 1002))

    safe_free(table)

    return 0
}
```

# 17-emitter-buffer.mc

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

# 18-emit-mov-return.mc

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

# 19-compile-return.mc

```mc
head(custom)
head(memory)

fn parse_return_value(I64 source) {
    I64 position = 7
    I64 value = 0

    while (position < strlen(source)) {
        I64 c = mem_read8(source + position)

        if ((c < 48) || (c > 57)) {
            return value
        }

        value = value * 10 + c - 48
        position = position + 1
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

    pin("compiled %I64\n", value)

    safe_free(output)

    return 0
}
```

# 20-mini-compiler.mc

```mc
head(custom)
head(memory)
head(file)

fn parse_return_value(I64 source) {
    I64 position = 7
    I64 value = 0

    while (position < strlen(source)) {
        I64 c = mem_read8(source + position)

        if ((c < 48) || (c > 57)) {
            return value
        }

        value = value * 10 + c - 48
        position = position + 1
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
        pin("write failed\n")
        return 1
    }

    pin("source: %s\n", source)
    pin("output: mini.bin\n")
    pin("bytes: %I64\n", size)

    safe_free(output)

    return 0
}
```

# Final learning path

```text
MicroC syntax
     ↓
math + time
     ↓
memory
     ↓
2D rendering
     ↓
3D rendering
     ↓
networking
     ↓
authorized red-team lab skills
     ↓
lexer
     ↓
parser
     ↓
symbol table
     ↓
x86 emitter
     ↓
your own compiler
     ↓
reverse engineer compiler.mc
```