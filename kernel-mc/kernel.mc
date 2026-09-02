head(custom) {
    fn gc_write(I64 index, I64 value) {
        port_out8(0x3CE, index)
        port_out8(0x3CF, value)
        return 0
    }

    fn dac_color(I64 index, I64 r, I64 g, I64 b) {
        port_out8(0x3C8, index)
        port_out8(0x3C9, r)
        port_out8(0x3C9, g)
        port_out8(0x3C9, b)
        return 0
    }

    fn vga_init() {
        gc_write(1, 0x0F)
        gc_write(3, 0x00)
        gc_write(5, 0x00)
        gc_write(8, 0xFF)

        dac_color(0, 0, 0, 0)
        dac_color(5, 34, 10, 52)
        dac_color(7, 31, 31, 35)
        dac_color(8, 14, 14, 18)
        dac_color(15, 63, 63, 63)

        return 0
    }

    fn set_color(I64 color) {
        gc_write(0, color & 15)
        gc_write(1, 0x0F)
        return 0
    }

    fn clear_screen(I64 color) {
        set_color(color)
        gc_write(8, 0xFF)

        I64 i = 0

        while (i < 38400) {
            mem_write8(0xA0000 + i, 0xFF)
            i = i + 1
        }

        return 0
    }

    fn plot(I64 x, I64 y) {
        if (x < 0) { return 0 }
        if (y < 0) { return 0 }
        if (x >= 640) { return 0 }
        if (y >= 480) { return 0 }

        I64 address = 0xA0000 + y * 80 + (x >> 3)
        I64 mask = 0x80 >> (x & 7)

        gc_write(8, mask)

        mem_read8(address)
        mem_write8(address, 0xFF)

        return 0
    }

    fn fill_rect8(I64 x, I64 y, I64 width, I64 height, I64 color) {
        set_color(color)
        gc_write(8, 0xFF)

        I64 row = 0
        I64 start_byte = x >> 3
        I64 byte_count = width >> 3

        while (row < height) {
            I64 i = 0
            I64 base = 0xA0000 + (y + row) * 80 + start_byte

            while (i < byte_count) {
                mem_write8(base + i, 0xFF)
                i = i + 1
            }

            row = row + 1
        }

        return 0
    }

    fn hline(I64 x, I64 y, I64 width, I64 color) {
        set_color(color)

        I64 i = 0
        while (i < width) {
            plot(x + i, y)
            i = i + 1
        }

        return 0
    }

    fn vline(I64 x, I64 y, I64 height, I64 color) {
        set_color(color)

        I64 i = 0
        while (i < height) {
            plot(x, y + i)
            i = i + 1
        }

        return 0
    }

    fn box(I64 x, I64 y, I64 width, I64 height, I64 color) {
        hline(x, y, width, color)
        hline(x, y + height - 1, width, color)
        vline(x, y, height, color)
        vline(x + width - 1, y, height, color)
        return 0
    }

    fn glyph(I64 ch) {
        if (ch > 96) {
            if (ch < 123) {
                ch = ch - 32
            }
        }

        if (ch == 65) { return 0x1111111F11110E }
        if (ch == 66) { return 0x1E11111E11111E }
        if (ch == 67) { return 0x0F10101010100F }
        if (ch == 68) { return 0x1E11111111111E }
        if (ch == 69) { return 0x1F10101E10101F }
        if (ch == 70) { return 0x1010101E10101F }
        if (ch == 71) { return 0x0F11111710100F }
        if (ch == 72) { return 0x1111111F111111 }
        if (ch == 73) { return 0x1F04040404041F }
        if (ch == 74) { return 0x0C121202020207 }
        if (ch == 75) { return 0x11121418141211 }
        if (ch == 76) { return 0x1F101010101010 }
        if (ch == 77) { return 0x11111115151B11 }
        if (ch == 78) { return 0x11111113151911 }
        if (ch == 79) { return 0x0E11111111110E }
        if (ch == 80) { return 0x1010101E11111E }
        if (ch == 81) { return 0x0D12151111110E }
        if (ch == 82) { return 0x1112141E11111E }
        if (ch == 83) { return 0x1E01010E10100F }
        if (ch == 84) { return 0x0404040404041F }
        if (ch == 85) { return 0x0E111111111111 }
        if (ch == 86) { return 0x040A1111111111 }
        if (ch == 87) { return 0x0A151515111111 }
        if (ch == 88) { return 0x11110A040A1111 }
        if (ch == 89) { return 0x040404040A1111 }
        if (ch == 90) { return 0x1F10080402011F }
        if (ch == 48) { return 0x0E11191513110E }
        if (ch == 49) { return 0x0E040404040C04 }
        if (ch == 50) { return 0x1F08040201110E }
        if (ch == 51) { return 0x1E01010E01011E }
        if (ch == 52) { return 0x02021F120A0602 }
        if (ch == 53) { return 0x1E01011E10101F }
        if (ch == 54) { return 0x0E11111E10100E }
        if (ch == 55) { return 0x0808080402011F }
        if (ch == 56) { return 0x0E11110E11110E }
        if (ch == 57) { return 0x0E01010F11110E }
        if (ch == 32) { return 0x00000000000000 }
        if (ch == 46) { return 0x06060000000000 }
        if (ch == 58) { return 0x00060600060600 }
        if (ch == 45) { return 0x0000001F000000 }
        if (ch == 95) { return 0x1F000000000000 }
        if (ch == 47) { return 0x10080804020201 }
        if (ch == 62) { return 0x10080402040810 }
        if (ch == 60) { return 0x01020408040201 }
        if (ch == 61) { return 0x0000001F001F00 }
        if (ch == 43) { return 0x0004041F040400 }
        if (ch == 33) { return 0x04000404040404 }
        if (ch == 63) { return 0x0400040201110E }
        if (ch == 35) { return 0x000A1F0A0A1F0A }
        if (ch == 34) { return 0x000000000A0A0A }
        if (ch == 39) { return 0x00000000000404 }
        if (ch == 40) { return 0x02040808080402 }
        if (ch == 41) { return 0x08040202020408 }
        if (ch == 123) { return 0x02040408040402 }
        if (ch == 125) { return 0x08040402040408 }
        if (ch == 91) { return 0x0E08080808080E }
        if (ch == 93) { return 0x0E02020202020E }
        if (ch == 44) { return 0x08040600000000 }

        return 0
    }

    fn draw_char_raw(I64 x, I64 y, I64 ch, I64 scale) {
        I64 font = glyph(ch)
        I64 row = 0

        while (row < 7) {
            I64 bits = (font >> (row * 8)) & 31
            I64 col = 0

            while (col < 5) {
                if ((bits & (16 >> col)) != 0) {
                    I64 sy = 0

                    while (sy < scale) {
                        I64 sx = 0

                        while (sx < scale) {
                            plot(x + col * scale + sx, y + row * scale + sy)
                            sx = sx + 1
                        }

                        sy = sy + 1
                    }
                }

                col = col + 1
            }

            row = row + 1
        }

        return 0
    }

    fn draw_text(I64 x, I64 y, I64 text, I64 color, I64 scale) {
        set_color(color)

        I64 i = 0
        I64 ch = mem_read8(text)

        while (ch != 0) {
            draw_char_raw(x + i * 6 * scale, y, ch, scale)
            i = i + 1
            ch = mem_read8(text + i)
        }

        return i
    }

    fn star(I64 x, I64 y) {
        set_color(15)

        plot(x + 4, y)
        plot(x + 4, y + 1)
        plot(x + 4, y + 2)

        plot(x, y + 4)
        plot(x + 1, y + 4)
        plot(x + 2, y + 4)
        plot(x + 3, y + 4)
        plot(x + 4, y + 4)
        plot(x + 5, y + 4)
        plot(x + 6, y + 4)
        plot(x + 7, y + 4)
        plot(x + 8, y + 4)

        plot(x + 4, y + 5)
        plot(x + 4, y + 6)
        plot(x + 4, y + 7)
        plot(x + 4, y + 8)

        set_color(5)
        plot(x + 2, y + 2)
        plot(x + 6, y + 2)
        plot(x + 2, y + 6)
        plot(x + 6, y + 6)

        return 0
    }

    fn demo_ui() {
        clear_screen(0)

        fill_rect8(0, 0, 640, 24, 5)
        fill_rect8(0, 464, 640, 16, 5)

        star(12, 7)
        draw_text(30, 5, "SUPERNOVA OS", 15, 2)
        draw_text(482, 8, "MICROC / X86-64", 15, 1)

        draw_text(12, 34, "SYSTEM", 5, 1)
        draw_text(66, 34, "EDIT", 15, 1)
        draw_text(108, 34, "DEBUG", 15, 1)
        draw_text(156, 34, "HELP", 15, 1)

        hline(8, 48, 624, 5)

        box(8, 58, 128, 302, 5)
        box(144, 58, 488, 302, 5)

        draw_text(18, 68, "FILES", 5, 1)
        hline(16, 82, 112, 5)

        fill_rect8(16, 92, 112, 16, 8)
        draw_text(22, 97, "KERNEL.MC", 15, 1)

        draw_text(22, 118, "VGA.MC", 15, 1)
        draw_text(22, 136, "SHELL.MC", 15, 1)
        draw_text(22, 154, "FS.MC", 15, 1)
        draw_text(22, 172, "EDITOR.MC", 15, 1)

        draw_text(154, 68, "KERNEL.MC", 5, 1)
        draw_text(544, 68, "1:1", 7, 1)
        hline(152, 82, 472, 5)

        draw_text(158, 96, "HEAD(CUSTOM) {", 15, 1)
        draw_text(174, 114, "FN MAIN() {", 5, 1)
        draw_text(190, 132, "VGA_INIT()", 15, 1)
        draw_text(190, 150, "TERMINAL_START()", 15, 1)
        draw_text(190, 168, "SHELL_RUN()", 15, 1)
        draw_text(174, 186, "}", 5, 1)
        draw_text(158, 204, "}", 15, 1)

        hline(152, 224, 472, 8)

        draw_text(158, 240, "SAME VGA GRAPHICS MODEL:", 7, 1)
        draw_text(158, 256, "640X480 / 16 COLORS / PLANAR", 15, 1)
        draw_text(158, 272, "TEXT IS DRAWN BY THE KERNEL.", 15, 1)

        draw_text(158, 306, "BLACK", 15, 1)
        draw_text(206, 306, "WHITE", 15, 1)
        draw_text(254, 306, "PURPLE", 5, 1)

        box(8, 370, 624, 82, 5)
        draw_text(18, 380, "TERMINAL", 5, 1)
        hline(16, 394, 608, 5)

        draw_text(18, 406, "BOOT", 5, 1)
        draw_text(54, 406, "OK", 15, 1)

        draw_text(90, 406, "VIDEO", 5, 1)
        draw_text(132, 406, "VGA 640X480X16", 15, 1)

        draw_text(18, 424, "SN>", 5, 1)
        draw_text(42, 424, "WELCOME TO SUPERNOVA.", 15, 1)

        draw_text(10, 468, "READY", 15, 1)
        draw_text(530, 468, "640X480X16", 15, 1)

        return 0
    }

    fn main() {
        cpu_cli()

        vga_init()
        demo_ui()

        while (1 == 1) {
            cpu_hlt()
        }
    }
}
