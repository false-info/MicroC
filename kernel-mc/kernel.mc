head(custom) {

    fn TERM_COL_ADDR() {
        return 0x180000
    }
    fn TERM_ROW_ADDR() {
        return 0x180008
    }
    fn TERM_COLOR_ADDR() {
        return 0x180010
    }
    fn SHIFT_ADDR() {
        return 0x180018
    }
    fn HEAP_READY_ADDR() {
        return 0x180020
    }

    fn HEAP_START() {
        return 0x120000
    }
    fn HEAP_END() {
        return 0x180000
    }
    fn HEAP_BITMAP() {
        return 0x182000
    }
    fn HEAP_BLOCK_SIZE() {
        return 256
    }
    fn HEAP_BLOCKS() {
        return 1536
    }

    fn TERM_BUFFER() {
        return 0x183000
    }
    fn SHELL_BUFFER() {
        return 0x186000
    }
    fn NUMBER_BUFFER() {
        return 0x187000
    }
    fn SECTOR_BUFFER() {
        return 0x188000
    }
    fn DIR_BUFFER() {
        return 0x190000
    }
    fn FILE_BUFFER() {
        return 0x192000
    }

    fn TERM_COLS() {
        return 100
    }
    fn TERM_ROWS() {
        return 54
    }

    fn TERM_X() {
        return 8
    }
    fn TERM_Y() {
        return 24
    }

    fn FS_SUPER_LBA() {
        return 209
    }

    fn FS_DIR_LBA() {
        return 210
    }

    fn FS_DIR_SECTORS() {
        return 8
    }
    fn FS_DATA_LBA() {
        return 218
    }

    fn FS_MAX_FILES() {
        return 32
    }

    fn FS_ENTRY_SIZE() {
        return 64
    }
    fn FS_SLOT_SECTORS() {
        return 512
    }

    fn FS_MAX_SIZE() {
        return 262144
    }

    fn FS_MAGIC() {
        return 0x53464E53
    }


    fn FS_VERSION() {
        return 2
    }

    fn EXTENDED_ADDR() {
        return 0x180028
    }

    fn KEY_LAYOUT_ADDR() {
        return 0x180030
    }

    fn ALTGR_ADDR() {
        return 0x180038
    }

    fn CAPS_ADDR() {
        return 0x180040
    }

    fn ABI_BASE() {
        return 0x1FF000
    }

    fn ABI_MAGIC() {
        return 0x534E414249303031
    }

    fn ABI_HANDLE_BASE() {
        return 0x1F0000
    }

    fn ABI_HANDLE_COUNT() {
        return 4
    }

    fn ABI_HANDLE_SIZE() {
        return 64
    }

    fn ABI_FILE_BUFFER_BASE() {
        return 0xA00000
    }

    fn ABI_FILE_BUFFER_SIZE() {
        return 0x40000
    }

    fn PROGRAM_ARGC_ADDR() {
        return 0x1F1000
    }

    fn PROGRAM_ARGV_BASE() {
        return 0x4F0000
    }

    fn PROGRAM_ARG_TEXT_BASE() {
        return 0x4F1000
    }

    fn PROGRAM_ARG_MAX() {
        return 16
    }

    fn PROGRAM_ARG_SIZE() {
        return 128
    }

    fn PROGRAM_BASE() {
        return 0x400000
    }

    fn PROGRAM_LIMIT() {
        return 0x80000
    }

    fn PROGRAM_GUARD_MAGIC() {
        return 0x534E50524F474D31
    }

    fn COMPILER_META_LBA() {
        return 16999
    }

    fn COMPILER_BOOT_LBA() {
        return 17000
    }

    fn COMPILER_BOOT_SECTORS() {
        return 512
    }

    fn COMPILER_BOOT_SIZE() {
        return 262144
    }

    fn COMPILER_SOURCE_LBA() {
        return 17512
    }

    fn KERNEL_SOURCE_LBA() {
        return 18024
    }

    fn CORE_SOURCE_SECTORS() {
        return 512
    }

    fn EDITOR_BUFFER() {
        return 0x500000
    }

    fn EDITOR_PATH() {
        return 0x540000
    }

    fn EDITOR_MAX_SIZE() {
        return 262144
    }

    fn EDITOR_CACHE() {
        return 0x550000
    }

    fn EDITOR_CACHE_VALID_ADDR() {
        return 0x180048
    }

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

    fn min64(I64 a, I64 b) {
        if (a < b) {
            return a
        }
        return b
    }

    fn abs64(I64 v) {
        if (v < 0) {
            return 0 - v
        }
        return v
    }

    fn mem_set(I64 dest, I64 value, I64 size) {
        I64 i = 0
        while (i < size) {
            mem_write8(dest + i, value & 255)
            i = i + 1
        }
        return dest
    }

    fn mem_copy(I64 dest, I64 src, I64 size) {
        I64 i = 0
        while (i < size) {
            mem_write8(dest + i, mem_read8(src + i))
            i = i + 1
        }
        return dest
    }

    fn mem_move(I64 dest, I64 src, I64 size) {
        if (dest <= src) {
            return mem_copy(dest, src, size)
        }

        I64 i = size
        while (i > 0) {
            i = i - 1
            mem_write8(dest + i, mem_read8(src + i))
        }
        return dest
    }

    fn mem_compare(I64 a, I64 b, I64 size) {
        I64 i = 0
        while (i < size) {
            I64 av = mem_read8(a + i)
            I64 bv = mem_read8(b + i)
            if (av < bv) {
                return 0 - 1
            }
            if (av > bv) {
                return 1
            }
            i = i + 1
        }
        return 0
    }

    fn str_len(I64 text) {
        I64 n = 0
        while (mem_read8(text + n) != 0) {
            n = n + 1
        }
        return n
    }

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

    fn ascii_lower(I64 ch) {
        if (ch >= 65) {
            if (ch <= 90) {
                return ch + 32
            }
        }

        return ch
    }

    fn str_eq_ci(I64 a, I64 b) {
        I64 i = 0

        while (1 == 1) {
            I64 ac = ascii_lower(mem_read8(a + i))
            I64 bc = ascii_lower(mem_read8(b + i))

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

    fn str_copy(I64 dest, I64 src) {
        I64 i = 0
        while (mem_read8(src + i) != 0) {
            mem_write8(dest + i, mem_read8(src + i))
            i = i + 1
        }
        mem_write8(dest + i, 0)
        return i
    }

    fn str_copy_limit(I64 dest, I64 src, I64 max) {
        I64 i = 0
        while (i + 1 < max) {
            I64 ch = mem_read8(src + i)
            if (ch == 0) {
                mem_write8(dest + i, 0)
                return i
            }
            mem_write8(dest + i, ch)
            i = i + 1
        }
        mem_write8(dest + i, 0)
        return i
    }

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

    fn palette_init() {
        dac_color(0,0,0,0)
        dac_color(1,0,0,42)
        dac_color(2,0,35,0)
        dac_color(3,0,38,42)
        dac_color(4,42,0,0)
        dac_color(5,36,9,54)
        dac_color(6,42,24,0)
        dac_color(7,38,38,40)
        dac_color(8,17,17,21)
        dac_color(9,10,20,63)
        dac_color(10,10,58,16)
        dac_color(11,20,58,63)
        dac_color(12,63,12,12)
        dac_color(13,58,18,63)
        dac_color(14,63,58,0)
        dac_color(15,63,63,63)
        return 0
    }

    fn vga_init() {
        gc_write(1,0x0F)
        gc_write(3,0)
        gc_write(5,0)
        gc_write(8,0xFF)
        palette_init()
        return 0
    }

    fn set_color(I64 color) {
        gc_write(0, color & 15)
        gc_write(1, 0x0F)
        return 0
    }

    fn set_mask(I64 mask) {
        gc_write(8, mask & 255)
        return 0
    }

    fn clear_screen(I64 color) {
        set_color(color)
        set_mask(0xFF)
        I64 i = 0
        while (i < 38400) {
            mem_write8(0xA0000 + i, 0xFF)
            i = i + 1
        }
        return 0
    }

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

    fn plot(I64 x, I64 y, I64 color) {
        set_color(color)
        return plot_current(x,y)
    }

    fn hline(I64 x, I64 y, I64 width, I64 color) {
        set_color(color)
        I64 i = 0
        while (i < width) {
            plot_current(x+i,y)
            i = i + 1
        }
        return 0
    }

    fn vline(I64 x, I64 y, I64 height, I64 color) {
        set_color(color)
        I64 i = 0
        while (i < height) {
            plot_current(x,y+i)
            i = i + 1
        }
        return 0
    }

    fn line(I64 x0, I64 y0, I64 x1, I64 y1, I64 color) {
        I64 dx = abs64(x1-x0)
        I64 sx = 1
        if (x0 > x1) {
            sx = 0 - 1
        }

        I64 dy = 0 - abs64(y1-y0)
        I64 sy = 1
        if (y0 > y1) {
            sy = 0 - 1
        }

        I64 err = dx + dy
        set_color(color)

        while (1 == 1) {
            plot_current(x0,y0)
            if (x0 == x1) {
                if (y0 == y1) {
                    return 0
                }
            }

            I64 e2 = err + err
            if (e2 >= dy) {
                err = err + dy
                x0 = x0 + sx
            }
            if (e2 <= dx) {
                err = err + dx
                y0 = y0 + sy
            }
        }
        return 0
    }

    fn fill_rect(I64 x, I64 y, I64 width, I64 height, I64 color) {
        if (width <= 0) {
            return 0
        }

        if (height <= 0) {
            return 0
        }

        set_color(color)

        I64 yy = 0

        while (yy < height) {
            I64 start = x
            I64 end = x + width
            I64 left = 1

            while (left != 0) {
                if (start >= end) {
                    left = 0
                } else {
                    if ((start & 7) == 0) {
                        left = 0
                    } else {
                        plot_current(
                            start,
                            y + yy
                        )

                        start = start + 1
                    }
                }
            }

            I64 byte_end = end & 0xFFFFFFFFFFFFFFF8

            if (byte_end > start) {
                set_mask(0xFF)

                I64 address = 0xA0000 + (y + yy) * 80 + (start >> 3)
                I64 bytes = (byte_end - start) >> 3
                I64 b = 0

                while (b < bytes) {
                    mem_write8(
                        address + b,
                        0xFF
                    )

                    b = b + 1
                }

                start = byte_end
            }

            while (start < end) {
                plot_current(
                    start,
                    y + yy
                )

                start = start + 1
            }

            yy = yy + 1
        }

        return 0
    }

    fn rect(I64 x, I64 y, I64 width, I64 height, I64 color) {
        hline(x,y,width,color)
        hline(x,y+height-1,width,color)
        vline(x,y,height,color)
        vline(x+width-1,y,height,color)
        return 0
    }

    fn circle_points(I64 cx, I64 cy, I64 x, I64 y, I64 color) {
        plot(cx+x,cy+y,color)
        plot(cx-x,cy+y,color)
        plot(cx+x,cy-y,color)
        plot(cx-x,cy-y,color)
        plot(cx+y,cy+x,color)
        plot(cx-y,cy+x,color)
        plot(cx+y,cy-x,color)
        plot(cx-y,cy-x,color)
        return 0
    }

    fn circle(I64 cx, I64 cy, I64 radius, I64 color) {
        I64 x = radius
        I64 y = 0
        I64 err = 1-radius

        while (x >= y) {
            circle_points(cx,cy,x,y,color)
            y = y + 1
            if (err < 0) {
                err = err + y + y + 1
            } else {
                x = x - 1
                err = err + (y-x)*2 + 1
            }
        }
        return 0
    }
    
    fn glyph(I64 ch) {
        if (ch == 32) {
            return 0x00000000000000
        }

        if (ch == 33) {
            return 0x04000404040404
        }

        if (ch == 34) {
            return 0x000000000A0A0A
        }

        if (ch == 35) {
            return 0x000A1F0A0A1F0A
        }

        if (ch == 36) {
            return 0x041E050E140F04
        }

        if (ch == 37) {
            return 0x00061608041A19
        }

        if (ch == 38) {
            return 0x0D12150814120C
        }

        if (ch == 39) {
            return 0x00000000080404
        }

        if (ch == 40) {
            return 0x02040808080402
        }

        if (ch == 41) {
            return 0x08040202020408
        }

        if (ch == 42) {
            return 0x00150E1F0E1500
        }

        if (ch == 43) {
            return 0x0004041F040400
        }

        if (ch == 44) {
            return 0x08040600000000
        }

        if (ch == 45) {
            return 0x0000001F000000
        }

        if (ch == 46) {
            return 0x06060000000000
        }

        if (ch == 47) {
            return 0x00001008040201
        }

        if (ch == 48) {
            return 0x0E11191513110E
        }

        if (ch == 49) {
            return 0x0E040404040C04
        }

        if (ch == 50) {
            return 0x1F08040201110E
        }

        if (ch == 51) {
            return 0x1E01010E01011E
        }

        if (ch == 52) {
            return 0x02021F120A0602
        }

        if (ch == 53) {
            return 0x1E01011E10101F
        }

        if (ch == 54) {
            return 0x0E11111E10100E
        }

        if (ch == 55) {
            return 0x0808080402011F
        }

        if (ch == 56) {
            return 0x0E11110E11110E
        }

        if (ch == 57) {
            return 0x0E01010F11110E
        }

        if (ch == 58) {
            return 0x00060600060600
        }

        if (ch == 59) {
            return 0x08040600060600
        }

        if (ch == 60) {
            return 0x02040810080402
        }

        if (ch == 61) {
            return 0x00001F001F0000
        }

        if (ch == 62) {
            return 0x08040201020408
        }

        if (ch == 63) {
            return 0x0400040201110E
        }

        if (ch == 64) {
            return 0x0E10171517110E
        }

        if (ch == 65) {
            return 0x1111111F11110E
        }

        if (ch == 66) {
            return 0x1E11111E11111E
        }

        if (ch == 67) {
            return 0x0F10101010100F
        }

        if (ch == 68) {
            return 0x1E11111111111E
        }

        if (ch == 69) {
            return 0x1F10101E10101F
        }

        if (ch == 70) {
            return 0x1010101E10101F
        }

        if (ch == 71) {
            return 0x0E11111710110E
        }

        if (ch == 72) {
            return 0x1111111F111111
        }

        if (ch == 73) {
            return 0x1F04040404041F
        }

        if (ch == 74) {
            return 0x0C120202020207
        }

        if (ch == 75) {
            return 0x11121418141211
        }

        if (ch == 76) {
            return 0x1F101010101010
        }

        if (ch == 77) {
            return 0x11111115151B11
        }

        if (ch == 78) {
            return 0x11111113151911
        }

        if (ch == 79) {
            return 0x0E11111111110E
        }

        if (ch == 80) {
            return 0x1010101E11111E
        }

        if (ch == 81) {
            return 0x0D12151111110E
        }

        if (ch == 82) {
            return 0x1112141E11111E
        }

        if (ch == 83) {
            return 0x1E01010E10100F
        }

        if (ch == 84) {
            return 0x0404040404041F
        }

        if (ch == 85) {
            return 0x0E111111111111
        }

        if (ch == 86) {
            return 0x040A1111111111
        }

        if (ch == 87) {
            return 0x0A151515111111
        }

        if (ch == 88) {
            return 0x11110A040A1111
        }

        if (ch == 89) {
            return 0x040404040A1111
        }

        if (ch == 90) {
            return 0x1F10080402011F
        }

        if (ch == 91) {
            return 0x0E08080808080E
        }

        if (ch == 92) {
            return 0x00000102040810
        }

        if (ch == 93) {
            return 0x0E02020202020E
        }

        if (ch == 94) {
            return 0x00000000110A04
        }

        if (ch == 95) {
            return 0x1F000000000000
        }

        if (ch == 96) {
            return 0x00000000020408
        }

        if (ch == 97) {
            return 0x0F110F010E0000
        }

        if (ch == 98) {
            return 0x1E111119161010
        }

        if (ch == 99) {
            return 0x0F1010100F0000
        }

        if (ch == 100) {
            return 0x0F1111130D0101
        }

        if (ch == 101) {
            return 0x0F101F110E0000
        }

        if (ch == 102) {
            return 0x0808081C080906
        }

        if (ch == 103) {
            return 0x0E010F110F0000
        }

        if (ch == 104) {
            return 0x11111119161010
        }

        if (ch == 105) {
            return 0x0E0404040C0004
        }

        if (ch == 106) {
            return 0x0C120202060002
        }

        if (ch == 107) {
            return 0x12141814121010
        }

        if (ch == 108) {
            return 0x0E04040404040C
        }

        if (ch == 109) {
            return 0x151515151A0000
        }

        if (ch == 110) {
            return 0x11111119160000
        }

        if (ch == 111) {
            return 0x0E1111110E0000
        }

        if (ch == 112) {
            return 0x10101E111E0000
        }

        if (ch == 113) {
            return 0x01010F130D0000
        }

        if (ch == 114) {
            return 0x10101019160000
        }

        if (ch == 115) {
            return 0x1E010E100F0000
        }

        if (ch == 116) {
            return 0x060908081C0808
        }

        if (ch == 117) {
            return 0x0D131111110000
        }

        if (ch == 118) {
            return 0x040A1111110000
        }

        if (ch == 119) {
            return 0x0A151515110000
        }

        if (ch == 120) {
            return 0x110A040A110000
        }

        if (ch == 121) {
            return 0x0E010F11110000
        }

        if (ch == 122) {
            return 0x1F0804021F0000
        }

        if (ch == 123) {
            return 0x02040408040402
        }

        if (ch == 124) {
            return 0x04040404040404
        }

        if (ch == 125) {
            return 0x08040402040408
        }

        if (ch == 126) {
            return 0x00000016090000
        }

        if (ch == 196) {
            return 0x11111F110E000A
        }

        if (ch == 197) {
            return 0x1111111F110E04
        }

        if (ch == 214) {
            return 0x0E1111110E000A
        }

        if (ch == 228) {
            return 0x0F110F010E000A
        }

        if (ch == 229) {
            return 0x0F11110F010E04
        }

        if (ch == 246) {
            return 0x0E1111110E000A
        }

        return 0x0400040201110E
    }

    fn draw_char(I64 x, I64 y, I64 ch, I64 color, I64 scale) {
        I64 data = glyph(ch)
        I64 row = 0
        set_color(color)

        if (scale == 1) {
            I64 first_byte = x >> 3

            while (row < 7) {
                I64 bits = (data >> (row * 8)) & 31
                I64 mask0 = 0
                I64 mask1 = 0
                I64 col = 0

                while (col < 5) {
                    if ((bits & (16 >> col)) != 0) {
                        I64 px = x + col
                        I64 bit = 0x80 >> (px & 7)

                        if ((px >> 3) == first_byte) {
                            mask0 = mask0 | bit
                        } else {
                            mask1 = mask1 | bit
                        }
                    }

                    col = col + 1
                }

                if (mask0 != 0) {
                    I64 address0 = 0xA0000 + (y + row) * 80 + first_byte

                    set_mask(mask0)
                    mem_read8(address0)
                    mem_write8(address0, 0xFF)
                }

                if (mask1 != 0) {
                    I64 address1 = 0xA0000 + (y + row) * 80 + first_byte + 1

                    set_mask(mask1)
                    mem_read8(address1)
                    mem_write8(address1, 0xFF)
                }

                row = row + 1
            }

            return 0
        }

        while (row < 7) {
            I64 bits2 = (data >> (row * 8)) & 31
            I64 col2 = 0

            while (col2 < 5) {
                if ((bits2 & (16 >> col2)) != 0) {
                    I64 sy = 0

                    while (sy < scale) {
                        I64 sx = 0

                        while (sx < scale) {
                            plot_current(
                                x + col2 * scale + sx,
                                y + row * scale + sy
                            )

                            sx = sx + 1
                        }

                        sy = sy + 1
                    }
                }

                col2 = col2 + 1
            }

            row = row + 1
        }

        return 0
    }

    fn draw_text(I64 x, I64 y, I64 text, I64 color, I64 scale) {
        I64 i = 0
        while (mem_read8(text+i) != 0) {
            draw_char(x+i*6*scale,y,mem_read8(text+i),color,scale)
            i = i + 1
        }
        return i
    }

    fn terminal_cell(I64 row, I64 col) {
        return TERM_BUFFER() + (row*TERM_COLS()+col)*2
    }

    fn terminal_store(I64 row, I64 col, I64 ch, I64 color) {
        I64 a = terminal_cell(row,col)
        mem_write8(a,ch)
        mem_write8(a+1,color)
        return 0
    }

    fn terminal_col() {
        return mem_read64(TERM_COL_ADDR())
    }
    fn terminal_row() {
        return mem_read64(TERM_ROW_ADDR())
    }
    fn terminal_color() {
        return mem_read64(TERM_COLOR_ADDR())
    }

    fn terminal_set_cursor(I64 col, I64 row) {
        mem_write64(TERM_COL_ADDR(),col)
        mem_write64(TERM_ROW_ADDR(),row)
        return 0
    }

    fn terminal_set_color(I64 color) {
        mem_write64(TERM_COLOR_ADDR(),color & 15)
        return 0
    }

    fn terminal_chrome() {
        fill_rect(0, 0, 640, 20, 5)
        fill_rect(0, 20, 640, 2, 13)

        draw_text(8, 6, "SuperNovaOS", 15, 1)

        if (keyboard_layout() == 1) {
            draw_text(584, 6, "SWE", 15, 1)
        } else {
            draw_text(584, 6, "ENG", 15, 1)
        }

        fill_rect(0, 460, 640, 2, 13)
        fill_rect(0, 462, 640, 18, 5)

        draw_text(
            8,
            467,
            "help   edit FILE   mcc   ls   keylayout eng|swe",
            15,
            1
        )

        return 0
    }

    fn terminal_draw_cell(I64 row, I64 col) {
        I64 a = terminal_cell(row,col)
        I64 ch = mem_read8(a)
        I64 color = mem_read8(a+1)

        fill_rect(TERM_X()+col*6,TERM_Y()+row*8,6,8,0)
        if (ch != 32) {
            draw_char(TERM_X()+col*6,TERM_Y()+row*8,ch,color,1)
        }
        return 0
    }

    fn terminal_clear_buffer() {
        I64 r = 0
        while (r < TERM_ROWS()) {
            I64 c = 0
            while (c < TERM_COLS()) {
                terminal_store(r,c,32,15)
                c = c + 1
            }
            r = r + 1
        }
        return 0
    }

    fn terminal_redraw() {
        terminal_chrome()

        I64 r = 0
        while (r < TERM_ROWS()) {
            I64 c = 0

            while (c < TERM_COLS()) {
                terminal_draw_cell(
                    r,
                    c
                )

                c = c + 1
            }

            r = r + 1
        }

        return 0
    }

    fn terminal_scroll() {
        I64 r = 1

        while (r < TERM_ROWS()) {
            I64 c = 0

            while (c < TERM_COLS()) {
                I64 src = terminal_cell(
                    r,
                    c
                )

                terminal_store(
                    r - 1,
                    c,
                    mem_read8(src),
                    mem_read8(src + 1)
                )

                c = c + 1
            }

            r = r + 1
        }

        gc_write(
            5,
            1
        )

        I64 py = 0

        while (py < (TERM_ROWS() - 1) * 8) {
            I64 source = 0xA0000 + (TERM_Y() + 8 + py) * 80 + (TERM_X() >> 3)
            I64 dest = 0xA0000 + (TERM_Y() + py) * 80 + (TERM_X() >> 3)
            I64 b = 0

            while (b < 75) {
                mem_read8(
                    source + b
                )

                mem_write8(
                    dest + b,
                    0
                )

                b = b + 1
            }

            py = py + 1
        }

        gc_write(
            5,
            0
        )

        I64 c2 = 0

        while (c2 < TERM_COLS()) {
            terminal_store(
                TERM_ROWS() - 1,
                c2,
                32,
                terminal_color()
            )

            c2 = c2 + 1
        }

        fill_rect(
            TERM_X(),
            TERM_Y() + (TERM_ROWS() - 1) * 8,
            600,
            8,
            0
        )

        terminal_set_cursor(
            0,
            TERM_ROWS() - 1
        )

        return 0
    }

    fn terminal_newline() {
        I64 r = terminal_row()+1
        if (r >= TERM_ROWS()) {
            return terminal_scroll()
        }
        terminal_set_cursor(0,r)
        return 0
    }

    fn terminal_backspace() {
        I64 c = terminal_col()
        I64 r = terminal_row()
        if (c > 0) {
            c = c - 1
            terminal_set_cursor(c,r)
            terminal_store(r,c,32,terminal_color())
            terminal_draw_cell(r,c)
        }
        return 0
    }

    fn terminal_putchar(I64 ch) {
        if (ch == 10) {
            return terminal_newline()
        }
        if (ch == 8) {
            return terminal_backspace()
        }

        I64 c = terminal_col()
        I64 r = terminal_row()

        terminal_store(r,c,ch,terminal_color())
        terminal_draw_cell(r,c)

        c = c + 1
        if (c >= TERM_COLS()) {
            terminal_newline()
        } else {
            terminal_set_cursor(c,r)
        }
        return 0
    }

    fn terminal_write(I64 text) {
        I64 i = 0
        while (mem_read8(text+i) != 0) {
            terminal_putchar(mem_read8(text+i))
            i = i + 1
        }
        return i
    }

    fn terminal_writeln(I64 text) {
        terminal_write(text)
        terminal_putchar(10)
        return 0
    }

    fn terminal_write_u64(I64 value) {
        if (value == 0) {
            terminal_putchar(48)
            return 0
        }

        I64 p = NUMBER_BUFFER()
        I64 n = 0

        while (value > 0) {
            mem_write8(p+n,48+(value%10))
            n = n + 1
            value = value / 10
        }

        while (n > 0) {
            n = n - 1
            terminal_putchar(mem_read8(p+n))
        }
        return 0
    }

    fn terminal_write_hex(I64 value) {
        terminal_write("0x")
        I64 shift = 60
        while (shift >= 0) {
            I64 d = (value >> shift) & 15
            if (d < 10) {
                terminal_putchar(48+d)
            } else {
                terminal_putchar(55+d)
            }
            shift = shift - 4
        }
        return 0
    }

    fn terminal_clear() {
        clear_screen(0)
        terminal_clear_buffer()
        terminal_set_cursor(0,0)
        terminal_set_color(15)
        terminal_chrome()
        return 0
    }

    fn terminal_init() {
        return terminal_clear()
    }

    fn keyboard_shift() {
        return mem_read64(SHIFT_ADDR())
    }

    fn keyboard_set_shift(I64 value) {
        mem_write64(SHIFT_ADDR(), value)
        return 0
    }

    fn keyboard_has_data() {
        return port_in8(0x64) & 1
    }

    fn keyboard_read_scancode() {
        if (keyboard_has_data() == 0) {
            return 0
        }

        return port_in8(0x60)
    }

    fn keyboard_init() {
        keyboard_set_shift(0)
        mem_write64(EXTENDED_ADDR(), 0)
        mem_write64(ALTGR_ADDR(), 0)
        mem_write64(CAPS_ADDR(), 0)

        // Swedish is the default because SuperNovaOS is being developed
        // on a Swedish keyboard. Use: keylayout eng
        mem_write64(KEY_LAYOUT_ADDR(), 1)

        while ((port_in8(0x64) & 1) != 0) {
            port_in8(0x60)
        }

        return 0
    }

    fn keyboard_altgr() {
        return mem_read64(ALTGR_ADDR())
    }

    fn keyboard_set_altgr(I64 value) {
        mem_write64(ALTGR_ADDR(), value)
        return 0
    }

    fn keyboard_caps() {
        return mem_read64(CAPS_ADDR())
    }

    fn keyboard_toggle_caps() {
        if (keyboard_caps() == 0) {
            mem_write64(CAPS_ADDR(), 1)
        } else {
            mem_write64(CAPS_ADDR(), 0)
        }

        return 0
    }

    fn keyboard_layout() {
        return mem_read64(KEY_LAYOUT_ADDR())
    }

    fn keyboard_set_layout(I64 layout) {
        mem_write64(KEY_LAYOUT_ADDR(), layout)
        return 0
    }

    fn keyboard_letter(I64 code) {
        if (code == 16) { return 113 }
        if (code == 17) { return 119 }
        if (code == 18) { return 101 }
        if (code == 19) { return 114 }
        if (code == 20) { return 116 }
        if (code == 21) { return 121 }
        if (code == 22) { return 117 }
        if (code == 23) { return 105 }
        if (code == 24) { return 111 }
        if (code == 25) { return 112 }

        if (code == 30) { return 97 }
        if (code == 31) { return 115 }
        if (code == 32) { return 100 }
        if (code == 33) { return 102 }
        if (code == 34) { return 103 }
        if (code == 35) { return 104 }
        if (code == 36) { return 106 }
        if (code == 37) { return 107 }
        if (code == 38) { return 108 }

        if (code == 44) { return 122 }
        if (code == 45) { return 120 }
        if (code == 46) { return 99 }
        if (code == 47) { return 118 }
        if (code == 48) { return 98 }
        if (code == 49) { return 110 }
        if (code == 50) { return 109 }

        return 0
    }

    fn keyboard_case_letter(I64 ch) {
        I64 upper = keyboard_shift()

        if (keyboard_caps() != 0) {
            if (upper == 0) {
                upper = 1
            } else {
                upper = 0
            }
        }

        if (upper != 0) {
            if (ch >= 97) {
                if (ch <= 122) {
                    return ch - 32
                }
            }

            if (ch == 229) { return 197 }
            if (ch == 228) { return 196 }
            if (ch == 246) { return 214 }
        }

        return ch
    }

    fn scancode_eng(I64 code) {
        I64 letter = keyboard_letter(code)

        if (letter != 0) {
            return keyboard_case_letter(letter)
        }

        I64 shift = keyboard_shift()

        if (code == 2) {
            if (shift != 0) { return 33 }
            return 49
        }
        if (code == 3) {
            if (shift != 0) { return 64 }
            return 50
        }
        if (code == 4) {
            if (shift != 0) { return 35 }
            return 51
        }
        if (code == 5) {
            if (shift != 0) { return 36 }
            return 52
        }
        if (code == 6) {
            if (shift != 0) { return 37 }
            return 53
        }
        if (code == 7) {
            if (shift != 0) { return 94 }
            return 54
        }
        if (code == 8) {
            if (shift != 0) { return 38 }
            return 55
        }
        if (code == 9) {
            if (shift != 0) { return 42 }
            return 56
        }
        if (code == 10) {
            if (shift != 0) { return 40 }
            return 57
        }
        if (code == 11) {
            if (shift != 0) { return 41 }
            return 48
        }
        if (code == 12) {
            if (shift != 0) { return 95 }
            return 45
        }
        if (code == 13) {
            if (shift != 0) { return 43 }
            return 61
        }
        if (code == 26) {
            if (shift != 0) { return 123 }
            return 91
        }
        if (code == 27) {
            if (shift != 0) { return 125 }
            return 93
        }
        if (code == 39) {
            if (shift != 0) { return 58 }
            return 59
        }
        if (code == 40) {
            if (shift != 0) { return 34 }
            return 39
        }
        if (code == 41) {
            if (shift != 0) { return 126 }
            return 96
        }
        if (code == 43) {
            if (shift != 0) { return 124 }
            return 92
        }
        if (code == 51) {
            if (shift != 0) { return 60 }
            return 44
        }
        if (code == 52) {
            if (shift != 0) { return 62 }
            return 46
        }
        if (code == 53) {
            if (shift != 0) { return 63 }
            return 47
        }
        if (code == 57) {
            return 32
        }

        return 0
    }

    fn scancode_swe(I64 code) {
        I64 letter = keyboard_letter(code)

        if (letter != 0) {
            return keyboard_case_letter(letter)
        }

        I64 shift = keyboard_shift()
        I64 altgr = keyboard_altgr()

        if (code == 2) {
            if (shift != 0) { return 33 }
            return 49
        }
        if (code == 3) {
            if (altgr != 0) { return 64 }
            if (shift != 0) { return 34 }
            return 50
        }
        if (code == 4) {
            if (shift != 0) { return 35 }
            return 51
        }
        if (code == 5) {
            if (altgr != 0) { return 36 }
            if (shift != 0) { return 36 }
            return 52
        }
        if (code == 6) {
            if (shift != 0) { return 37 }
            return 53
        }
        if (code == 7) {
            if (shift != 0) { return 38 }
            return 54
        }
        if (code == 8) {
            if (altgr != 0) { return 123 }
            if (shift != 0) { return 47 }
            return 55
        }
        if (code == 9) {
            if (altgr != 0) { return 91 }
            if (shift != 0) { return 40 }
            return 56
        }
        if (code == 10) {
            if (altgr != 0) { return 93 }
            if (shift != 0) { return 41 }
            return 57
        }
        if (code == 11) {
            if (altgr != 0) { return 125 }
            if (shift != 0) { return 61 }
            return 48
        }
        if (code == 12) {
            if (altgr != 0) { return 92 }
            if (shift != 0) { return 63 }
            return 43
        }
        if (code == 13) {
            if (shift != 0) { return 94 }
            return 96
        }
        if (code == 26) {
            return keyboard_case_letter(229)
        }
        if (code == 27) {
            if (altgr != 0) { return 126 }
            if (shift != 0) { return 94 }
            return 126
        }
        if (code == 39) {
            return keyboard_case_letter(246)
        }
        if (code == 40) {
            return keyboard_case_letter(228)
        }
        if (code == 41) {
            if (shift != 0) { return 126 }
            return 96
        }
        if (code == 43) {
            if (shift != 0) { return 42 }
            return 39
        }
        if (code == 51) {
            if (shift != 0) { return 59 }
            return 44
        }
        if (code == 52) {
            if (shift != 0) { return 58 }
            return 46
        }
        if (code == 53) {
            if (shift != 0) { return 95 }
            return 45
        }
        if (code == 86) {
            if (altgr != 0) { return 124 }
            if (shift != 0) { return 62 }
            return 60
        }
        if (code == 57) {
            return 32
        }

        return 0
    }

    fn scancode_to_ascii(I64 code) {
        if (keyboard_layout() == 1) {
            return scancode_swe(code)
        }

        return scancode_eng(code)
    }

    fn keyboard_getkey() {
        while (1 == 1) {
            I64 code = keyboard_read_scancode()

            if (code == 0xE0) {
                mem_write64(EXTENDED_ADDR(), 1)
                code = 0
            }

            if (code != 0) {
                if (mem_read64(EXTENDED_ADDR()) != 0) {
                    mem_write64(EXTENDED_ADDR(), 0)

                    if (code == 56) {
                        keyboard_set_altgr(1)
                    }

                    if (code == 184) {
                        keyboard_set_altgr(0)
                    }

                    if (code == 75) { return 256 }
                    if (code == 77) { return 257 }
                    if (code == 72) { return 258 }
                    if (code == 80) { return 259 }
                    if (code == 83) { return 263 }
                    if (code == 71) { return 264 }
                    if (code == 79) { return 265 }
                } else {
                    if (code == 42) {
                        keyboard_set_shift(1)
                    }

                    if (code == 54) {
                        keyboard_set_shift(1)
                    }

                    if (code == 170) {
                        keyboard_set_shift(0)
                    }

                    if (code == 182) {
                        keyboard_set_shift(0)
                    }

                    if (code == 58) {
                        keyboard_toggle_caps()
                    }

                    if (code == 1) { return 27 }
                    if (code == 15) { return 9 }
                    if (code == 28) { return 10 }
                    if (code == 14) { return 8 }

                    if (code == 60) { return 260 }
                    if (code == 63) { return 261 }
                    if (code == 64) { return 262 }

                    if (code < 128) {
                        I64 ch = scancode_to_ascii(code)

                        if (ch != 0) {
                            return ch
                        }
                    }
                }
            }

            cpu_pause()
        }

        return 0
    }

    fn keyboard_getchar() {
        while (1 == 1) {
            I64 key = keyboard_getkey()

            if (key < 256) {
                return key
            }
        }

        return 0
    }

    fn keyboard_read_line(I64 buffer, I64 max) {
        I64 n = 0
        mem_write8(buffer, 0)

        while (1 == 1) {
            I64 ch = keyboard_getchar()

            if (ch == 10) {
                terminal_putchar(10)
                mem_write8(buffer + n, 0)
                return n
            }

            if (ch == 8) {
                if (n > 0) {
                    n = n - 1
                    mem_write8(buffer + n, 0)
                    terminal_backspace()
                }
            } else {
                if (ch == 9) {
                    I64 spaces = 0

                    while (spaces < 4) {
                        if (n + 1 < max) {
                            mem_write8(buffer + n, 32)
                            n = n + 1
                            mem_write8(buffer + n, 0)
                            terminal_putchar(32)
                        }

                        spaces = spaces + 1
                    }
                } else {
                    if (n + 1 < max) {
                        mem_write8(buffer + n, ch)
                        n = n + 1
                        mem_write8(buffer + n, 0)
                        terminal_putchar(ch)
                    }
                }
            }
        }

        return n
    }

    fn heap_init() {
        mem_set(HEAP_BITMAP(),0,HEAP_BLOCKS())
        mem_write64(HEAP_READY_ADDR(),1)
        return 0
    }

    fn heap_blocks_for(I64 size) {
        I64 total = size + 8
        I64 blocks = total / HEAP_BLOCK_SIZE()
        if ((total % HEAP_BLOCK_SIZE()) != 0) {
            blocks = blocks + 1
        }
        return blocks
    }

    fn heap_run_free(I64 start, I64 count) {
        I64 i = 0
        while (i < count) {
            if (mem_read8(HEAP_BITMAP()+start+i) != 0) {
                return 0
            }
            i = i + 1
        }
        return 1
    }

    fn heap_mark(I64 start, I64 count, I64 value) {
        I64 i = 0
        while (i < count) {
            mem_write8(HEAP_BITMAP()+start+i,value)
            i = i + 1
        }
        return 0
    }

    fn kmalloc(I64 size) {
        if (size <= 0) {
            return 0
        }
        if (mem_read64(HEAP_READY_ADDR()) == 0) {
            heap_init()
        }

        I64 need = heap_blocks_for(size)
        I64 i = 0

        while (i+need <= HEAP_BLOCKS()) {
            if (heap_run_free(i,need) != 0) {
                heap_mark(i,need,1)
                I64 base = HEAP_START()+i*HEAP_BLOCK_SIZE()
                mem_write64(base,need)
                return base+8
            }
            i = i + 1
        }
        return 0
    }

    fn kcalloc(I64 count, I64 size) {
        I64 total = count*size
        I64 p = kmalloc(total)
        if (p != 0) {
            mem_set(p,0,total)
        }
        return p
    }

    fn kfree(I64 ptr) {
        if (ptr == 0) {
            return 0
        }

        I64 base = ptr-8
        if (base < HEAP_START()) {
            return 0
        }
        if (base >= HEAP_END()) {
            return 0
        }

        I64 blocks = mem_read64(base)
        I64 index = (base-HEAP_START())/HEAP_BLOCK_SIZE()

        if (blocks <= 0) {
            return 0
        }
        if (index+blocks > HEAP_BLOCKS()) {
            return 0
        }

        heap_mark(index,blocks,0)
        mem_write64(base,0)
        return 1
    }

    fn krealloc(I64 ptr, I64 size) {
        if (ptr == 0) {
            return kmalloc(size)
        }
        if (size == 0) {
            kfree(ptr)
            return 0
        }

        I64 old_blocks = mem_read64(ptr-8)
        I64 old_size = old_blocks*HEAP_BLOCK_SIZE()-8
        I64 np = kmalloc(size)
        if (np == 0) {
            return 0
        }

        mem_copy(np,ptr,min64(old_size,size))
        kfree(ptr)
        return np
    }

    fn heap_free_bytes() {
        I64 free = 0
        I64 i = 0
        while (i < HEAP_BLOCKS()) {
            if (mem_read8(HEAP_BITMAP()+i) == 0) {
                free = free + HEAP_BLOCK_SIZE()
            }
            i = i + 1
        }
        return free
    }

    fn ata_status() {
        return port_in8(0x1F7)
    }

    fn ata_wait_not_busy() {
        I64 timeout = 1000000
        while (timeout > 0) {
            if ((ata_status() & 0x80) == 0) {
                return 1
            }
            timeout = timeout - 1
            cpu_pause()
        }
        return 0
    }

    fn ata_wait_drq() {
        I64 timeout = 1000000
        while (timeout > 0) {
            I64 s = ata_status()
            if ((s & 1) != 0) {
                return 0
            }
            if ((s & 0x20) != 0) {
                return 0
            }
            if ((s & 0x08) != 0) {
                return 1
            }
            timeout = timeout - 1
            cpu_pause()
        }
        return 0
    }

    fn ata_select_lba(I64 lba) {
        port_out8(0x1F6,0xE0|((lba>>24)&15))
        port_out8(0x1F2,1)
        port_out8(0x1F3,lba&255)
        port_out8(0x1F4,(lba>>8)&255)
        port_out8(0x1F5,(lba>>16)&255)
        return 0
    }

    fn ata_read_sector(I64 lba, I64 buffer) {
        if (ata_wait_not_busy() == 0) {
            return 0
        }

        ata_select_lba(lba)
        port_out8(0x1F7,0x20)
        if (ata_wait_drq() == 0) {
            return 0
        }

        I64 i = 0
        while (i < 256) {
            mem_write16(buffer+i*2,port_in16(0x1F0))
            i = i + 1
        }
        return 1
    }

    fn ata_write_sector(I64 lba, I64 buffer) {
        if (ata_wait_not_busy() == 0) {
            return 0
        }

        ata_select_lba(lba)
        port_out8(0x1F7,0x30)
        if (ata_wait_drq() == 0) {
            return 0
        }

        I64 i = 0
        while (i < 256) {
            port_out16(0x1F0,mem_read16(buffer+i*2))
            i = i + 1
        }

        port_out8(0x1F7,0xE7)
        return ata_wait_not_busy()
    }

    fn ata_read(I64 lba, I64 sectors, I64 buffer) {
        I64 i = 0
        while (i < sectors) {
            if (ata_read_sector(lba+i,buffer+i*512) == 0) {
                return 0
            }
            i = i + 1
        }
        return 1
    }

    fn ata_write(I64 lba, I64 sectors, I64 buffer) {
        I64 i = 0
        while (i < sectors) {
            if (ata_write_sector(lba+i,buffer+i*512) == 0) {
                return 0
            }
            i = i + 1
        }
        return 1
    }

    fn fs_load_dir() {
        return ata_read(FS_DIR_LBA(),FS_DIR_SECTORS(),DIR_BUFFER())
    }

    fn fs_save_dir() {
        return ata_write(FS_DIR_LBA(),FS_DIR_SECTORS(),DIR_BUFFER())
    }

    fn fs_formatted() {
        if (ata_read_sector(
            FS_SUPER_LBA(),
            SECTOR_BUFFER()
        ) == 0) {
            return 0
        }

        if (mem_read32(SECTOR_BUFFER()) != FS_MAGIC()) {
            return 0
        }

        if (mem_read32(SECTOR_BUFFER() + 4) != FS_VERSION()) {
            return 0
        }

        return 1
    }

    fn fs_format() {
        mem_set(
            SECTOR_BUFFER(),
            0,
            512
        )

        mem_write32(
            SECTOR_BUFFER(),
            FS_MAGIC()
        )

        mem_write32(
            SECTOR_BUFFER() + 4,
            FS_VERSION()
        )

        mem_write32(
            SECTOR_BUFFER() + 8,
            FS_MAX_FILES()
        )

        mem_write32(
            SECTOR_BUFFER() + 12,
            FS_SLOT_SECTORS()
        )

        if (ata_write_sector(
            FS_SUPER_LBA(),
            SECTOR_BUFFER()
        ) == 0) {
            return 0
        }

        mem_set(
            DIR_BUFFER(),
            0,
            FS_DIR_SECTORS() * 512
        )

        if (fs_save_dir() == 0) {
            return 0
        }

        if (fs_formatted() == 0) {
            return 0
        }

        if (fs_load_dir() == 0) {
            return 0
        }

        if (mem_read8(DIR_BUFFER()) != 0) {
            return 0
        }

        return 1
    }

    fn fs_entry(I64 index) {
        return DIR_BUFFER()+index*FS_ENTRY_SIZE()
    }

    fn fs_entry_used(I64 index) {
        return mem_read8(fs_entry(index))
    }

    fn fs_entry_name(I64 index) {
        return fs_entry(index)+1
    }

    fn fs_entry_file_size(I64 index) {
        return mem_read32(fs_entry(index)+32)
    }

    fn fs_size_path(I64 path) {
        if (fs_formatted() == 0) {
            return 0 - 1
        }

        I64 index = fs_find(path)

        if (index < 0) {
            return 0 - 1
        }

        return fs_entry_file_size(index)
    }

    fn fs_entry_lba(I64 index) {
        return FS_DATA_LBA()+index*FS_SLOT_SECTORS()
    }

    fn fs_find(I64 path) {
        if (fs_load_dir() == 0) {
            return 0-1
        }

        I64 i = 0
        while (i < FS_MAX_FILES()) {
            if (fs_entry_used(i) != 0) {
                if (str_eq(fs_entry_name(i),path) != 0) {
                    return i
                }
            }
            i = i + 1
        }
        return 0-1
    }

    fn fs_find_free() {
        I64 i = 0
        while (i < FS_MAX_FILES()) {
            if (fs_entry_used(i) == 0) {
                return i
            }
            i = i + 1
        }
        return 0-1
    }

    fn fs_create(I64 path) {
        if (fs_formatted() == 0) {
            return 0
        }
        if (fs_find(path) >= 0) {
            return 0
        }

        I64 index = fs_find_free()
        if (index < 0) {
            return 0
        }

        I64 e = fs_entry(index)
        mem_set(e,0,FS_ENTRY_SIZE())
        mem_write8(e,1)
        str_copy_limit(e+1,path,31)
        mem_write32(e+32,0)

        return fs_save_dir()
    }

    fn fs_delete(I64 path) {
        if (fs_formatted() == 0) {
            return 0
        }

        I64 index = fs_find(path)
        if (index < 0) {
            return 0
        }

        mem_set(fs_entry(index),0,FS_ENTRY_SIZE())
        return fs_save_dir()
    }

    fn fs_write_file(I64 path, I64 buffer, I64 size) {
        if (size > FS_MAX_SIZE()) {
            return 0
        }
        if (fs_formatted() == 0) {
            return 0
        }

        I64 index = fs_find(path)
        if (index < 0) {
            if (fs_create(path) == 0) {
                return 0
            }
            index = fs_find(path)
            if (index < 0) {
                return 0
            }
        }

        I64 sectors = size/512
        if ((size%512) != 0) {
            sectors = sectors + 1
        }

        I64 i = 0
        while (i < sectors) {
            mem_set(SECTOR_BUFFER(),0,512)
            I64 off = i*512
            I64 take = min64(size-off,512)
            mem_copy(SECTOR_BUFFER(),buffer+off,take)

            if (ata_write_sector(fs_entry_lba(index)+i,SECTOR_BUFFER()) == 0) {
                return 0
            }
            i = i + 1
        }

        fs_load_dir()
        mem_write32(fs_entry(index)+32,size)
        return fs_save_dir()
    }

    fn fs_read_file(I64 path, I64 buffer, I64 max) {
        if (fs_formatted() == 0) {
            return 0-1
        }

        I64 index = fs_find(path)
        if (index < 0) {
            return 0-1
        }

        I64 size = min64(fs_entry_file_size(index),max)
        I64 sectors = size/512
        if ((size%512) != 0) {
            sectors = sectors + 1
        }

        I64 i = 0
        while (i < sectors) {
            if (ata_read_sector(fs_entry_lba(index)+i,SECTOR_BUFFER()) == 0) {
                return 0-1
            }

            I64 off = i*512
            I64 take = min64(size-off,512)
            mem_copy(buffer+off,SECTOR_BUFFER(),take)
            i = i + 1
        }
        return size
    }

    fn fs_write_text(I64 path, I64 text) {
        return fs_write_file(path,text,str_len(text))
    }

    fn fs_list() {
        if (fs_formatted() == 0) {
            terminal_writeln("filesystem not formatted")
            return 0
        }

        fs_load_dir()
        I64 found = 0
        I64 i = 0

        while (i < FS_MAX_FILES()) {
            if (fs_entry_used(i) != 0) {
                terminal_set_color(13)
                terminal_write(fs_entry_name(i))
                terminal_set_color(7)
                terminal_write("  ")
                terminal_write_u64(fs_entry_file_size(i))
                terminal_writeln(" bytes")
                found = found + 1
            }
            i = i + 1
        }

        if (found == 0) {
            terminal_writeln("(empty)")
        }
        terminal_set_color(15)
        return found
    }

    fn fs_cat(I64 path) {
        I64 n = fs_read_file(path,FILE_BUFFER(),FS_MAX_SIZE()-1)
        if (n < 0) {
            terminal_writeln("file not found")
            return 0
        }

        mem_write8(FILE_BUFFER()+n,0)
        terminal_write(FILE_BUFFER())
        terminal_putchar(10)
        return 1
    }

    fn fs_copy(I64 source, I64 destination) {
        I64 size = fs_read_file(
            source,
            FILE_BUFFER(),
            FS_MAX_SIZE()
        )

        if (size < 0) {
            return 0
        }

        return fs_write_file(
            destination,
            FILE_BUFFER(),
            size
        )
    }

    fn cpu_reboot() {
        cpu_cli()
        I64 timeout = 1000000

        while (timeout > 0) {
            if ((port_in8(0x64)&2) == 0) {
                port_out8(0x64,0xFE)
                timeout = 0
            } else {
                timeout = timeout - 1
            }
        }

        while (1 == 1) {
            cpu_hlt()
        }
        return 0
    }

    fn boot_text_size(I64 buffer, I64 max) {
        I64 size = 0

        while (size < max) {
            if (mem_read8(buffer + size) == 0) {
                return size
            }

            size = size + 1
        }

        return max
    }

    fn boot_install_text(I64 lba, I64 path) {
        if (fs_size_path(path) >= 0) {
            return 1
        }

        if (ata_read(
            lba,
            CORE_SOURCE_SECTORS(),
            FILE_BUFFER()
        ) == 0) {
            return 0
        }

        I64 size = boot_text_size(
            FILE_BUFFER(),
            FS_MAX_SIZE()
        )

        if (size == 0) {
            return 0
        }

        return fs_write_file(
            path,
            FILE_BUFFER(),
            size
        )
    }

    fn compiler_install_from_boot_area() {
        if (fs_formatted() == 0) {
            return 0
        }

        if (fs_size_path("mcc.bin") >= 0) {
            return 1
        }

        if (ata_read_sector(
            COMPILER_META_LBA(),
            SECTOR_BUFFER()
        ) == 0) {
            terminal_writeln("compiler metadata could not be read")
            return 0
        }

        I64 size = mem_read64(SECTOR_BUFFER())

        if (size <= 0) {
            terminal_writeln("mcc bootstrap area is empty")
            return 0
        }

        if (size > COMPILER_BOOT_SIZE()) {
            terminal_writeln("compiler image is too large")
            return 0
        }

        I64 sectors = size / 512
        if ((size % 512) != 0) {
            sectors = sectors + 1
        }

        terminal_set_color(7)
        terminal_writeln("installing integrated MicroC compiler...")
        terminal_set_color(15)

        if (ata_read(
            COMPILER_BOOT_LBA(),
            sectors,
            FILE_BUFFER()
        ) == 0) {
            terminal_writeln("compiler boot area could not be read")
            return 0
        }

        if (mem_read8(FILE_BUFFER()) != 0xE9) {
            terminal_writeln("compiler boot image is invalid")
            return 0
        }

        if (fs_write_file(
            "mcc.bin",
            FILE_BUFFER(),
            size
        ) == 0) {
            terminal_writeln("could not install mcc.bin")
            return 0
        }

        terminal_set_color(10)
        terminal_writeln("MicroC compiler ready")
        terminal_set_color(15)

        return 1
    }

    fn core_sources_install_from_boot_area() {
        if (fs_formatted() == 0) {
            return 0
        }

        I64 compiler_ok = boot_install_text(
            COMPILER_SOURCE_LBA(),
            "compiler.mc"
        )

        I64 kernel_ok = boot_install_text(
            KERNEL_SOURCE_LBA(),
            "kernel.mc"
        )

        if (compiler_ok == 0) {
            terminal_writeln("compiler.mc is missing from bootstrap area")
        }

        if (kernel_ok == 0) {
            terminal_writeln("kernel.mc is missing from bootstrap area")
        }

        if (compiler_ok == 0) {
            return 0
        }

        if (kernel_ok == 0) {
            return 0
        }

        return 1
    }

    fn bootstrap_install_core() {
        if (fs_formatted() == 0) {
            return 0
        }

        I64 compiler_ok = compiler_install_from_boot_area()
        I64 sources_ok = core_sources_install_from_boot_area()

        if (compiler_ok == 0) {
            return 0
        }

        if (sources_ok == 0) {
            return 0
        }

        return 1
    }


    fn panic(I64 text) {
        cpu_cli()
        terminal_set_color(12)
        terminal_writeln("")
        terminal_writeln("KERNEL PANIC")
        terminal_set_color(15)
        terminal_writeln(text)

        while (1 == 1) {
            cpu_hlt()
        }
        return 0
    }


    fn terminal_write_n(I64 text, I64 length) {
        I64 index = 0

        while (index < length) {
            terminal_putchar(
                mem_read8(text + index)
            )

            index = index + 1
        }

        return length
    }

    fn terminal_write_i64(I64 value) {
        if (value < 0) {
            terminal_putchar(45)
            value = 0 - value
        }

        return terminal_write_u64(value)
    }

    fn terminal_write_hex_digits(I64 value) {
        I64 shift = 60

        while (shift >= 0) {
            I64 digit = (value >> shift) & 15

            if (digit < 10) {
                terminal_putchar(48 + digit)
            } else {
                terminal_putchar(55 + digit)
            }

            shift = shift - 4
        }

        return 0
    }

    fn terminal_write_bool(I64 value) {
        if (value == 0) {
            terminal_write("false")
            return 0
        }

        terminal_write("true")
        return 1
    }

    fn abi_handle_meta(I64 handle) {
        return ABI_HANDLE_BASE() + (handle - 1) * ABI_HANDLE_SIZE()
    }

    fn abi_handle_buffer(I64 handle) {
        return ABI_FILE_BUFFER_BASE() + (handle - 1) * ABI_FILE_BUFFER_SIZE()
    }

    fn abi_handle_valid(I64 handle) {
        if (handle < 1) {
            return 0
        }

        if (handle > ABI_HANDLE_COUNT()) {
            return 0
        }

        if (mem_read64(abi_handle_meta(handle)) == 0) {
            return 0
        }

        return 1
    }

    fn abi_find_free_handle() {
        I64 handle = 1

        while (handle <= ABI_HANDLE_COUNT()) {
            if (mem_read64(abi_handle_meta(handle)) == 0) {
                return handle
            }

            handle = handle + 1
        }

        return 0 - 1
    }

    fn abi_open(I64 path, I64 flags) {
        I64 handle = abi_find_free_handle()

        if (handle < 0) {
            return 0 - 1
        }

        I64 meta = abi_handle_meta(handle)
        I64 buffer = abi_handle_buffer(handle)

        mem_set(
            meta,
            0,
            ABI_HANDLE_SIZE()
        )

        mem_write64(meta, 1)
        mem_write64(meta + 8, flags)
        mem_write64(meta + 16, 0)
        mem_write64(meta + 24, 0)

        str_copy_limit(
            meta + 32,
            path,
            31
        )

        if (flags == 0) {
            I64 size = fs_read_file(
                path,
                buffer,
                ABI_FILE_BUFFER_SIZE()
            )

            if (size < 0) {
                mem_write64(meta, 0)
                return 0 - 1
            }

            mem_write64(meta + 24, size)
        }

        return handle
    }

    fn abi_close(I64 handle) {
        if (abi_handle_valid(handle) == 0) {
            return 0 - 1
        }

        I64 meta = abi_handle_meta(handle)
        I64 flags = mem_read64(meta + 8)
        I64 result = 1

        if (flags != 0) {
            result = fs_write_file(
                meta + 32,
                abi_handle_buffer(handle),
                mem_read64(meta + 24)
            )
        }

        mem_write64(meta, 0)
        return result
    }

    fn abi_read8(I64 handle) {
        if (abi_handle_valid(handle) == 0) {
            return 0
        }

        I64 meta = abi_handle_meta(handle)
        I64 position = mem_read64(meta + 16)
        I64 size = mem_read64(meta + 24)

        if (position >= size) {
            return 0
        }

        I64 value = mem_read8(
            abi_handle_buffer(handle) + position
        )

        mem_write64(
            meta + 16,
            position + 1
        )

        return value
    }

    fn abi_write8(I64 handle, I64 value) {
        if (abi_handle_valid(handle) == 0) {
            return 0 - 1
        }

        I64 meta = abi_handle_meta(handle)
        I64 position = mem_read64(meta + 16)

        if (position >= ABI_FILE_BUFFER_SIZE()) {
            return 0 - 1
        }

        mem_write8(
            abi_handle_buffer(handle) + position,
            value & 255
        )

        position = position + 1

        mem_write64(
            meta + 16,
            position
        )

        if (position > mem_read64(meta + 24)) {
            mem_write64(
                meta + 24,
                position
            )
        }

        return value
    }

    fn abi_file_size(I64 handle) {
        if (abi_handle_valid(handle) == 0) {
            return 0 - 1
        }

        return mem_read64(
            abi_handle_meta(handle) + 24
        )
    }

    fn abi_seek(I64 handle, I64 position) {
        if (abi_handle_valid(handle) == 0) {
            return 0 - 1
        }

        if (position < 0) {
            return 0 - 1
        }

        if (position > ABI_FILE_BUFFER_SIZE()) {
            return 0 - 1
        }

        I64 meta = abi_handle_meta(handle)
        I64 flags = mem_read64(meta + 8)

        if (flags == 0) {
            if (position > mem_read64(meta + 24)) {
                return 0 - 1
            }
        }

        mem_write64(
            meta + 16,
            position
        )

        return position
    }

    fn abi_argc() {
        return mem_read64(
            PROGRAM_ARGC_ADDR()
        )
    }

    fn abi_argv(I64 index) {
        I64 count = abi_argc()

        if (index < 0) {
            return 0
        }

        if (index >= count) {
            return 0
        }

        return mem_read64(
            PROGRAM_ARGV_BASE() + index * 8
        )
    }

    fn abi_putchar(I64 ch) {
        return terminal_putchar(ch)
    }

    fn abi_write(I64 text) {
        return terminal_write(text)
    }

    fn abi_write_n(I64 text, I64 length) {
        return terminal_write_n(
            text,
            length
        )
    }

    fn abi_debug_char(I64 ch) {
        return terminal_putchar(ch)
    }

    fn abi_write_u64(I64 value) {
        return terminal_write_u64(value)
    }

    fn abi_write_i64(I64 value) {
        return terminal_write_i64(value)
    }

    fn abi_write_hex(I64 value) {
        return terminal_write_hex_digits(value)
    }

    fn abi_write_bool(I64 value) {
        return terminal_write_bool(value)
    }

    fn abi_write_file(I64 path, I64 buffer, I64 size) {
        return fs_write_file(
            path,
            buffer,
            size
        )
    }

    fn abi_reset_handles() {
        I64 handle = 1

        while (handle <= ABI_HANDLE_COUNT()) {
            mem_set(
                abi_handle_meta(handle),
                0,
                ABI_HANDLE_SIZE()
            )

            handle = handle + 1
        }

        return 0
    }

    fn abi_init() {
        mem_write64(
            ABI_BASE(),
            ABI_MAGIC()
        )

        mem_write64(
            ABI_BASE() + 8,
            0x100000 + fn_offset(abi_putchar)
        )

        mem_write64(
            ABI_BASE() + 16,
            0x100000 + fn_offset(abi_write)
        )

        mem_write64(
            ABI_BASE() + 24,
            0x100000 + fn_offset(abi_write_n)
        )

        mem_write64(
            ABI_BASE() + 32,
            0x100000 + fn_offset(abi_open)
        )

        mem_write64(
            ABI_BASE() + 40,
            0x100000 + fn_offset(abi_close)
        )

        mem_write64(
            ABI_BASE() + 48,
            0x100000 + fn_offset(abi_read8)
        )

        mem_write64(
            ABI_BASE() + 56,
            0x100000 + fn_offset(abi_write8)
        )

        mem_write64(
            ABI_BASE() + 64,
            0x100000 + fn_offset(abi_file_size)
        )

        mem_write64(
            ABI_BASE() + 72,
            0x100000 + fn_offset(abi_seek)
        )

        mem_write64(
            ABI_BASE() + 80,
            0x100000 + fn_offset(abi_argc)
        )

        mem_write64(
            ABI_BASE() + 88,
            0x100000 + fn_offset(abi_argv)
        )

        mem_write64(
            ABI_BASE() + 96,
            0x100000 + fn_offset(abi_debug_char)
        )

        mem_write64(
            ABI_BASE() + 104,
            0x100000 + fn_offset(abi_write_u64)
        )

        mem_write64(
            ABI_BASE() + 112,
            0x100000 + fn_offset(abi_write_i64)
        )

        mem_write64(
            ABI_BASE() + 120,
            0x100000 + fn_offset(abi_write_hex)
        )

        mem_write64(
            ABI_BASE() + 128,
            0x100000 + fn_offset(abi_write_bool)
        )

        mem_write64(
            ABI_BASE() + 136,
            0x100000 + fn_offset(abi_write_file)
        )

        abi_reset_handles()
        return 0
    }

    fn program_clear_args() {
        mem_write64(
            PROGRAM_ARGC_ADDR(),
            0
        )

        mem_set(
            PROGRAM_ARGV_BASE(),
            0,
            PROGRAM_ARG_MAX() * 8
        )

        mem_set(
            PROGRAM_ARG_TEXT_BASE(),
            0,
            PROGRAM_ARG_MAX() * PROGRAM_ARG_SIZE()
        )

        return 0
    }

    fn program_store_arg(I64 index, I64 text, I64 length) {
        if (index >= PROGRAM_ARG_MAX()) {
            return 0
        }

        I64 dest = PROGRAM_ARG_TEXT_BASE() + index * PROGRAM_ARG_SIZE()
        I64 take = min64(
            length,
            PROGRAM_ARG_SIZE() - 1
        )

        mem_copy(
            dest,
            text,
            take
        )

        mem_write8(
            dest + take,
            0
        )

        mem_write64(
            PROGRAM_ARGV_BASE() + index * 8,
            dest
        )

        return 1
    }

    fn program_prepare_args(I64 path, I64 args) {
        program_clear_args()

        I64 count = 0

        program_store_arg(
            count,
            path,
            str_len(path)
        )

        count = count + 1

        if (args == 0) {
            mem_write64(
                PROGRAM_ARGC_ADDR(),
                count
            )

            return count
        }

        I64 position = 0
        I64 done = 0

        while (done == 0) {
            while (mem_read8(args + position) == 32) {
                position = position + 1
            }

            if (mem_read8(args + position) == 0) {
                done = 1
            } else {
                I64 start = position
                I64 token_done = 0

                while (token_done == 0) {
                    I64 ch = mem_read8(args + position)

                    if (ch == 0) {
                        token_done = 1
                    } else {
                        if (ch == 32) {
                            token_done = 1
                        } else {
                            position = position + 1
                        }
                    }
                }

                if (count < PROGRAM_ARG_MAX()) {
                    program_store_arg(
                        count,
                        args + start,
                        position - start
                    )

                    count = count + 1
                }

                while (mem_read8(args + position) == 32) {
                    position = position + 1
                }

                if (mem_read8(args + position) == 0) {
                    done = 1
                }
            }
        }

        mem_write64(
            PROGRAM_ARGC_ADDR(),
            count
        )

        return count
    }

    fn str_ends_bin(I64 path) {
        I64 length = str_len(path)

        if (length < 4) {
            return 0
        }

        if (mem_read8(path + length - 4) != 46) {
            return 0
        }

        if (mem_read8(path + length - 3) != 98) {
            return 0
        }

        if (mem_read8(path + length - 2) != 105) {
            return 0
        }

        if (mem_read8(path + length - 1) != 110) {
            return 0
        }

        return 1
    }

    fn program_run(I64 path, I64 args) {
        if (str_ends_bin(path) == 0) {
            terminal_writeln("run: program must end in .bin")
            return 0 - 1
        }

        I64 size = fs_size_path(path)

        if (size < 0) {
            terminal_writeln("run: file not found")
            return 0 - 1
        }

        if (size > PROGRAM_LIMIT()) {
            terminal_writeln("run: program is too large")
            return 0 - 1
        }

        mem_write64(
            PROGRAM_BASE() - 8,
            PROGRAM_GUARD_MAGIC()
        )

        mem_write64(
            PROGRAM_BASE() + PROGRAM_LIMIT(),
            PROGRAM_GUARD_MAGIC()
        )

        I64 loaded = fs_read_file(
            path,
            PROGRAM_BASE(),
            PROGRAM_LIMIT()
        )

        if (loaded != size) {
            terminal_writeln("run: load failed")
            return 0 - 1
        }

        if (mem_read8(PROGRAM_BASE()) != 0xE9) {
            terminal_writeln("run: invalid .bin header")
            return 0 - 1
        }

        abi_reset_handles()

        program_prepare_args(
            path,
            args
        )

        I64 old_rsp = cpu_read_rsp()

        mem_write64(
            0xE00000,
            0x53544B4755415244
        )

        cpu_write_rsp(
            0xFF0000
        )

        I64 result = cpu_call(
            PROGRAM_BASE()
        )

        cpu_write_rsp(
            old_rsp
        )

        if (mem_read64(0xE00000) != 0x53544B4755415244) {
            panic("program stack overflow")
            return 0 - 1
        }

        if (mem_read64(PROGRAM_BASE() - 8) != PROGRAM_GUARD_MAGIC()) {
            panic("program damaged lower arena guard")
            return 0 - 1
        }

        if (mem_read64(PROGRAM_BASE() + PROGRAM_LIMIT()) != PROGRAM_GUARD_MAGIC()) {
            panic("program damaged upper arena guard")
            return 0 - 1
        }

        return result
    }

    fn draw_u64_at(I64 x, I64 y, I64 value, I64 color) {
        I64 buffer = NUMBER_BUFFER()
        I64 count = 0

        if (value == 0) {
            draw_char(x, y, 48, color, 1)
            return 1
        }

        while (value > 0) {
            mem_write8(
                buffer + count,
                48 + (value % 10)
            )

            count = count + 1
            value = value / 10
        }

        I64 index = count

        while (index > 0) {
            index = index - 1
            draw_char(
                x + (count - index - 1) * 6,
                y,
                mem_read8(buffer + index),
                color,
                1
            )
        }

        return count
    }

    fn editor_line_end(I64 buffer, I64 size, I64 cursor) {
        I64 index = cursor

        while (index < size) {
            if (mem_read8(buffer + index) == 10) {
                return index
            }

            index = index + 1
        }

        return size
    }

    fn editor_delete_at(I64 buffer, I64 size, I64 cursor) {
        if (cursor >= size) {
            return size
        }

        mem_move(
            buffer + cursor,
            buffer + cursor + 1,
            size - cursor - 1
        )

        size = size - 1
        mem_write8(buffer + size, 0)
        return size
    }

    fn editor_line_number(I64 buffer, I64 cursor) {
        I64 line = 0
        I64 index = 0

        while (index < cursor) {
            if (mem_read8(buffer + index) == 10) {
                line = line + 1
            }

            index = index + 1
        }

        return line
    }

    fn editor_line_start(I64 buffer, I64 size, I64 wanted_line) {
        I64 line = 0
        I64 index = 0

        if (wanted_line == 0) {
            return 0
        }

        while (index < size) {
            if (mem_read8(buffer + index) == 10) {
                line = line + 1

                if (line == wanted_line) {
                    return index + 1
                }
            }

            index = index + 1
        }

        return size
    }

    fn editor_column(I64 buffer, I64 cursor) {
        I64 index = cursor

        while (index > 0) {
            if (mem_read8(buffer + index - 1) == 10) {
                return cursor - index
            }

            index = index - 1
        }

        return cursor
    }

    fn editor_move_up(I64 buffer, I64 size, I64 cursor) {
        I64 line = editor_line_number(
            buffer,
            cursor
        )

        if (line == 0) {
            return cursor
        }

        I64 column = editor_column(
            buffer,
            cursor
        )

        I64 start = editor_line_start(
            buffer,
            size,
            line - 1
        )

        I64 end = start
        I64 done = 0

        while (done == 0) {
            if (end >= size) {
                done = 1
            } else {
                if (mem_read8(buffer + end) == 10) {
                    done = 1
                } else {
                    end = end + 1
                }
            }
        }

        return min64(
            start + column,
            end
        )
    }

    fn editor_move_down(I64 buffer, I64 size, I64 cursor) {
        I64 line = editor_line_number(
            buffer,
            cursor
        )

        I64 column = editor_column(
            buffer,
            cursor
        )

        I64 start = editor_line_start(
            buffer,
            size,
            line + 1
        )

        if (start >= size) {
            return cursor
        }

        I64 end = start
        I64 done = 0

        while (done == 0) {
            if (end >= size) {
                done = 1
            } else {
                if (mem_read8(buffer + end) == 10) {
                    done = 1
                } else {
                    end = end + 1
                }
            }
        }

        return min64(
            start + column,
            end
        )
    }

    fn editor_view_start(I64 buffer, I64 size, I64 cursor) {
        I64 line = editor_line_number(
            buffer,
            cursor
        )

        if (line > 45) {
            return editor_line_start(
                buffer,
                size,
                line - 45
            )
        }

        return 0
    }

    fn editor_cache_reset() {
        mem_set(
            EDITOR_CACHE(),
            0xFF,
            54 * 99 * 2
        )

        mem_write64(
            EDITOR_CACHE_VALID_ADDR(),
            0
        )

        mem_write64(
            0x180050,
            0 - 1
        )

        mem_write64(
            0x180058,
            0 - 1
        )

        return 0
    }

    fn editor_cache_cell(I64 row, I64 col) {
        return EDITOR_CACHE() + (row * 99 + col) * 2
    }

    fn editor_draw_cell(I64 row, I64 col, I64 ch, I64 color) {
        if (row < 0) {
            return 0
        }

        if (row >= 54) {
            return 0
        }

        if (col < 0) {
            return 0
        }

        if (col >= 99) {
            return 0
        }

        I64 cache = editor_cache_cell(
            row,
            col
        )

        if (mem_read8(cache) == ch) {
            if (mem_read8(cache + 1) == color) {
                return 0
            }
        }

        I64 x = 42 + col * 6
        I64 y = 26 + row * 8

        fill_rect(
            x,
            y,
            6,
            8,
            0
        )

        if (ch != 32) {
            draw_char(
                x,
                y,
                ch,
                color,
                1
            )
        }

        mem_write8(
            cache,
            ch
        )

        mem_write8(
            cache + 1,
            color
        )

        return 1
    }

    fn editor_clear_tail(I64 row, I64 start_col) {
        I64 col = start_col

        if (col < 0) {
            col = 0
        }

        while (col < 99) {
            editor_draw_cell(
                row,
                col,
                32,
                15
            )

            col = col + 1
        }

        return 0
    }

    fn editor_redraw(I64 buffer, I64 size, I64 cursor, I64 path, I64 dirty) {
        I64 first = mem_read64(
            EDITOR_CACHE_VALID_ADDR()
        )

        if (first == 0) {
            clear_screen(0)

            fill_rect(0, 0, 640, 20, 5)
            fill_rect(0, 20, 640, 2, 13)
            fill_rect(0, 22, 36, 438, 8)
            vline(36, 22, 438, 13)
            fill_rect(0, 460, 640, 2, 13)
            fill_rect(0, 462, 640, 18, 5)

            draw_text(
                8,
                6,
                "SuperNova Edit 0.7",
                15,
                1
            )

            draw_text(
                8,
                467,
                "F2 Save  F5 Run  F6 Build  Home/End  Del  Esc Save+Exit",
                15,
                1
            )

            mem_write64(
                EDITOR_CACHE_VALID_ADDR(),
                1
            )
        }

        fill_rect(
            120,
            1,
            344,
            18,
            5
        )

        draw_text(
            120,
            6,
            path,
            15,
            1
        )

        I64 cursor_line = editor_line_number(
            buffer,
            cursor
        )

        I64 cursor_col = editor_column(
            buffer,
            cursor
        )

        fill_rect(
            466,
            1,
            174,
            18,
            5
        )

        draw_text(470, 6, "Ln", 7, 1)
        draw_u64_at(
            488,
            6,
            cursor_line + 1,
            15
        )

        draw_text(535, 6, "Col", 7, 1)
        draw_u64_at(
            559,
            6,
            cursor_col + 1,
            15
        )

        if (dirty != 0) {
            draw_text(620, 6, "*", 14, 1)
        }

        I64 top_line = 0

        if (cursor_line > 48) {
            top_line = cursor_line - 48
        }

        I64 start = editor_line_start(
            buffer,
            size,
            top_line
        )

        I64 horizontal = 0

        if (cursor_col > 92) {
            horizontal = cursor_col - 92
        }

        I64 old_cursor_row = mem_read64(0x180050)
        I64 old_cursor_col = mem_read64(0x180058)

        if (old_cursor_row >= 0) {
            if (old_cursor_row < 54) {
                if (old_cursor_col >= 0) {
                    if (old_cursor_col < 99) {
                        I64 old_cache = editor_cache_cell(
                            old_cursor_row,
                            old_cursor_col
                        )

                        mem_write8(
                            old_cache,
                            0xFE
                        )
                    }
                }
            }
        }

        mem_write64(0x180050, 0 - 1)
        mem_write64(0x180058, 0 - 1)

        I64 index = start
        I64 screen_row = 0
        I64 logical_col = 0
        I64 line_number = top_line + 1
        I64 need_number = 1
        I64 in_string = 0
        I64 in_comment = 0
        I64 visible_used = 0

        while (index < size) {
            if (screen_row >= 54) {
                index = size
            } else {
                if (need_number != 0) {
                    fill_rect(
                        0,
                        26 + screen_row * 8,
                        35,
                        8,
                        8
                    )

                    draw_u64_at(
                        2,
                        26 + screen_row * 8,
                        line_number,
                        7
                    )

                    need_number = 0
                    visible_used = 0
                }

                I64 ch = mem_read8(
                    buffer + index
                )

                if (ch == 10) {
                    editor_clear_tail(
                        screen_row,
                        visible_used
                    )

                    screen_row = screen_row + 1
                    logical_col = 0
                    line_number = line_number + 1
                    need_number = 1
                    in_string = 0
                    in_comment = 0
                } else {
                    if (in_string == 0) {
                        if (in_comment == 0) {
                            if (ch == 47) {
                                if (index + 1 < size) {
                                    if (mem_read8(buffer + index + 1) == 47) {
                                        in_comment = 1
                                    }
                                }
                            }
                        }
                    }

                    if (logical_col >= horizontal) {
                        I64 visible_col = logical_col - horizontal

                        if (visible_col < 99) {
                            I64 color = 15

                            if (in_comment != 0) {
                                color = 7
                            } else {
                                if (in_string != 0) {
                                    color = 13
                                } else {
                                    if (ch == 34) {
                                        color = 13
                                    } else {
                                        if (ch >= 48) {
                                            if (ch <= 57) {
                                                color = 7
                                            }
                                        }

                                        if (ch == 123) { color = 13 }
                                        if (ch == 125) { color = 13 }
                                        if (ch == 40) { color = 13 }
                                        if (ch == 41) { color = 13 }
                                        if (ch == 91) { color = 13 }
                                        if (ch == 93) { color = 13 }
                                        if (ch == 61) { color = 13 }
                                        if (ch == 43) { color = 13 }
                                        if (ch == 45) { color = 13 }
                                        if (ch == 42) { color = 13 }
                                        if (ch == 47) { color = 13 }
                                    }
                                }
                            }

                            editor_draw_cell(
                                screen_row,
                                visible_col,
                                ch,
                                color
                            )

                            if (visible_col + 1 > visible_used) {
                                visible_used = visible_col + 1
                            }
                        }
                    }

                    if (in_comment == 0) {
                        if (ch == 34) {
                            if (in_string == 0) {
                                in_string = 1
                            } else {
                                in_string = 0
                            }
                        }
                    }

                    logical_col = logical_col + 1
                }

                index = index + 1
            }
        }

        if (need_number == 0) {
            editor_clear_tail(
                screen_row,
                visible_used
            )

            screen_row = screen_row + 1
        }

        while (screen_row < 54) {
            fill_rect(
                0,
                26 + screen_row * 8,
                35,
                8,
                8
            )

            editor_clear_tail(
                screen_row,
                0
            )

            screen_row = screen_row + 1
        }

        if (size == 0) {
            fill_rect(
                0,
                26,
                35,
                8,
                8
            )

            draw_u64_at(
                2,
                26,
                1,
                7
            )
        }

        if (cursor_line >= top_line) {
            if (cursor_line < top_line + 54) {
                I64 cursor_visible_col = cursor_col - horizontal

                if (cursor_visible_col >= 0) {
                    if (cursor_visible_col < 99) {
                        I64 cursor_char = 32

                        if (cursor < size) {
                            cursor_char = mem_read8(
                                buffer + cursor
                            )

                            if (cursor_char == 10) {
                                cursor_char = 32
                            }
                        }

                        I64 cache = editor_cache_cell(
                            cursor_line - top_line,
                            cursor_visible_col
                        )

                        I64 old_ch = mem_read8(cache)
                        I64 old_color = mem_read8(cache + 1)

                        fill_rect(
                            42 + cursor_visible_col * 6,
                            26 + (cursor_line - top_line) * 8,
                            6,
                            8,
                            13
                        )

                        if (cursor_char != 32) {
                            draw_char(
                                42 + cursor_visible_col * 6,
                                26 + (cursor_line - top_line) * 8,
                                cursor_char,
                                15,
                                1
                            )
                        }

                        mem_write8(cache, old_ch)
                        mem_write8(cache + 1, old_color)

                        mem_write64(
                            0x180050,
                            cursor_line - top_line
                        )

                        mem_write64(
                            0x180058,
                            cursor_visible_col
                        )
                    }
                }
            }
        }

        return 0
    }

    fn editor_insert(I64 buffer, I64 size, I64 cursor, I64 ch) {
        if (size + 1 >= EDITOR_MAX_SIZE()) {
            return size
        }

        mem_move(
            buffer + cursor + 1,
            buffer + cursor,
            size - cursor
        )

        mem_write8(
            buffer + cursor,
            ch
        )

        size = size + 1

        mem_write8(
            buffer + size,
            0
        )

        return size
    }

    fn editor_delete_before(I64 buffer, I64 size, I64 cursor) {
        if (cursor == 0) {
            return size
        }

        mem_move(
            buffer + cursor - 1,
            buffer + cursor,
            size - cursor
        )

        size = size - 1

        mem_write8(
            buffer + size,
            0
        )

        return size
    }

    fn editor_save(I64 buffer, I64 size, I64 path) {
        if (fs_write_file(
            path,
            buffer,
            size
        ) == 0) {
            return 0
        }

        return 1
    }

    fn editor_wait_after_compile() {
        terminal_set_color(7)
        terminal_writeln("")
        terminal_writeln("press any key to return to editor")
        terminal_set_color(15)
        keyboard_getkey()
        return 0
    }

    fn editor_run_compiler(I64 path, I64 build_mode) {
        if (fs_size_path("mcc.bin") < 0) {
            terminal_clear()
            terminal_writeln("mcc.bin is not installed")
            editor_wait_after_compile()
            return 0
        }

        mem_set(
            SHELL_BUFFER(),
            0,
            256
        )

        if (build_mode == 0) {
            if (str_eq(path, "kernel.mc") != 0) {
                str_copy_limit(
                    SHELL_BUFFER(),
                    "-kernel kernel.mc -o kernel-new.bin",
                    256
                )
            } else {
                if (str_eq(path, "compiler.mc") != 0) {
                    str_copy_limit(
                        SHELL_BUFFER(),
                        "-compiler compiler.mc -o mcc-new.bin",
                        256
                    )
                } else {
                    str_copy_limit(
                        SHELL_BUFFER(),
                        "-jit ",
                        256
                    )

                    I64 end = str_len(SHELL_BUFFER())
                    str_copy_limit(
                        SHELL_BUFFER() + end,
                        path,
                        256 - end
                    )
                }
            }
        } else {
            if (str_eq(path, "kernel.mc") != 0) {
                str_copy_limit(
                    SHELL_BUFFER(),
                    "-kernel kernel.mc -o kernel-new.bin",
                    256
                )
            } else {
                if (str_eq(path, "compiler.mc") != 0) {
                    str_copy_limit(
                        SHELL_BUFFER(),
                        "-compiler compiler.mc -o mcc-new.bin",
                        256
                    )
                } else {
                    str_copy_limit(
                        SHELL_BUFFER(),
                        "-aot ",
                        256
                    )

                    I64 end2 = str_len(SHELL_BUFFER())
                    str_copy_limit(
                        SHELL_BUFFER() + end2,
                        path,
                        256 - end2
                    )

                    I64 end3 = str_len(SHELL_BUFFER())
                    str_copy_limit(
                        SHELL_BUFFER() + end3,
                        " -o program.bin",
                        256 - end3
                    )
                }
            }
        }

        terminal_clear()
        terminal_set_color(13)
        terminal_writeln("MicroC")
        terminal_set_color(15)

        program_run(
            "mcc.bin",
            SHELL_BUFFER()
        )

        editor_wait_after_compile()
        return 1
    }

    fn editor_open(I64 path) {
        I64 size = fs_read_file(
            path,
            EDITOR_BUFFER(),
            EDITOR_MAX_SIZE() - 1
        )

        if (size < 0) {
            size = 0
        }

        if (size >= EDITOR_MAX_SIZE() - 1) {
            terminal_writeln("edit: file is too large")
            return 0
        }

        str_copy_limit(
            EDITOR_PATH(),
            path,
            31
        )

        mem_write8(
            EDITOR_BUFFER() + size,
            0
        )

        I64 cursor = 0
        I64 running = 1
        I64 dirty = 0

        editor_cache_reset()

        while (running != 0) {
            editor_redraw(
                EDITOR_BUFFER(),
                size,
                cursor,
                EDITOR_PATH(),
                dirty
            )

            I64 key = keyboard_getkey()

            if (key == 27) {
                running = 0
            } else {
                if (key == 260) {
                    if (editor_save(
                        EDITOR_BUFFER(),
                        size,
                        EDITOR_PATH()
                    ) != 0) {
                        dirty = 0
                    }
                } else {
                    if (key == 261) {
                        if (editor_save(
                            EDITOR_BUFFER(),
                            size,
                            EDITOR_PATH()
                        ) != 0) {
                            dirty = 0

                            editor_run_compiler(
                                EDITOR_PATH(),
                                0
                            )

                            editor_cache_reset()
                        }
                    } else {
                        if (key == 262) {
                            if (editor_save(
                                EDITOR_BUFFER(),
                                size,
                                EDITOR_PATH()
                            ) != 0) {
                                dirty = 0

                                editor_run_compiler(
                                    EDITOR_PATH(),
                                    1
                                )

                                editor_cache_reset()
                            }
                        } else {
                            if (key == 256) {
                                if (cursor > 0) {
                                    cursor = cursor - 1
                                }
                            } else {
                                if (key == 257) {
                                    if (cursor < size) {
                                        cursor = cursor + 1
                                    }
                                } else {
                                    if (key == 258) {
                                        cursor = editor_move_up(
                                            EDITOR_BUFFER(),
                                            size,
                                            cursor
                                        )
                                    } else {
                                        if (key == 259) {
                                            cursor = editor_move_down(
                                                EDITOR_BUFFER(),
                                                size,
                                                cursor
                                            )
                                        } else {
                                            if (key == 263) {
                                                if (cursor < size) {
                                                    size = editor_delete_at(
                                                        EDITOR_BUFFER(),
                                                        size,
                                                        cursor
                                                    )

                                                    dirty = 1
                                                }
                                            } else {
                                                if (key == 264) {
                                                    I64 line = editor_line_number(
                                                        EDITOR_BUFFER(),
                                                        cursor
                                                    )

                                                    cursor = editor_line_start(
                                                        EDITOR_BUFFER(),
                                                        size,
                                                        line
                                                    )
                                                } else {
                                                    if (key == 265) {
                                                        cursor = editor_line_end(
                                                            EDITOR_BUFFER(),
                                                            size,
                                                            cursor
                                                        )
                                                    } else {
                                                        if (key == 8) {
                                                            if (cursor > 0) {
                                                                size = editor_delete_before(
                                                                    EDITOR_BUFFER(),
                                                                    size,
                                                                    cursor
                                                                )

                                                                cursor = cursor - 1
                                                                dirty = 1
                                                            }
                                                        } else {
                                                            if (key == 9) {
                                                                I64 spaces = 0

                                                                while (spaces < 4) {
                                                                    size = editor_insert(
                                                                        EDITOR_BUFFER(),
                                                                        size,
                                                                        cursor,
                                                                        32
                                                                    )

                                                                    cursor = cursor + 1
                                                                    spaces = spaces + 1
                                                                }

                                                                dirty = 1
                                                            } else {
                                                                if (key == 10) {
                                                                    size = editor_insert(
                                                                        EDITOR_BUFFER(),
                                                                        size,
                                                                        cursor,
                                                                        10
                                                                    )

                                                                    cursor = cursor + 1
                                                                    dirty = 1
                                                                } else {
                                                                    if (key >= 32) {
                                                                        if (key <= 255) {
                                                                            size = editor_insert(
                                                                                EDITOR_BUFFER(),
                                                                                size,
                                                                                cursor,
                                                                                key
                                                                            )

                                                                            cursor = cursor + 1
                                                                            dirty = 1
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        if (editor_save(
            EDITOR_BUFFER(),
            size,
            EDITOR_PATH()
        ) == 0) {
            terminal_clear()
            terminal_writeln("edit: save failed")
            return 0
        }

        terminal_clear()
        terminal_set_color(13)
        terminal_write("saved ")
        terminal_set_color(15)
        terminal_writeln(EDITOR_PATH())

        return 1
    }

    fn shell_split(I64 line) {
        I64 i = 0
        while (mem_read8(line+i) != 0) {
            if (mem_read8(line+i) == 32) {
                mem_write8(line+i,0)
                return line+i+1
            }
            i = i + 1
        }
        return 0
    }

    fn shell_keylayout(I64 args) {
        if (args == 0) {
            terminal_write("keyboard layout: ")

            if (keyboard_layout() == 1) {
                terminal_writeln("SWE")
            } else {
                terminal_writeln("ENG")
            }

            return 0
        }

        if (str_eq_ci(args, "swe") != 0) {
            keyboard_set_layout(1)
            terminal_redraw()
            terminal_writeln("keyboard layout: SWE")
            return 1
        }

        if (str_eq_ci(args, "eng") != 0) {
            keyboard_set_layout(0)
            terminal_redraw()
            terminal_writeln("keyboard layout: ENG")
            return 1
        }

        terminal_writeln("usage: keylayout eng | swe")
        return 0
    }

    fn shell_help() {
        terminal_set_color(13)
        terminal_writeln("SuperNovaOS Help")
        terminal_set_color(7)
        terminal_writeln("============================================================")
        terminal_set_color(15)

        terminal_writeln("Files")
        terminal_set_color(7)
        terminal_writeln("  ls                    List files")
        terminal_writeln("  cat FILE              Show a text file")
        terminal_writeln("  touch FILE            Create an empty file")
        terminal_writeln("  write FILE TEXT       Replace file contents")
        terminal_writeln("  cp SOURCE DEST        Copy a file")
        terminal_writeln("  rm FILE               Delete a file")
        terminal_writeln("")
        terminal_set_color(15)

        terminal_writeln("MicroC")
        terminal_set_color(7)
        terminal_writeln("  edit FILE.mc          Open the source editor")
        terminal_writeln("  mcc FILE.mc           JIT compile and run")
        terminal_writeln("  mcc -jit FILE.mc      Explicit JIT compile and run")
        terminal_writeln("  mcc -aot FILE.mc -o FILE.bin")
        terminal_writeln("                        Compile and save native code")
        terminal_writeln("  run FILE.bin          Run compiled native code")
        terminal_writeln("")
        terminal_set_color(15)

        terminal_writeln("Development")
        terminal_set_color(7)
        terminal_writeln("  edit kernel.mc        Edit the SuperNovaOS kernel")
        terminal_writeln("  edit compiler.mc      Edit the MicroC compiler")
        terminal_writeln("  F2 Save   F5 Run/Build   F6 Build   Esc Exit")
        terminal_writeln("")
        terminal_set_color(15)

        terminal_writeln("System")
        terminal_set_color(7)
        terminal_writeln("  keylayout swe         Swedish keyboard layout")
        terminal_writeln("  keylayout eng         English/US keyboard layout")
        terminal_writeln("  format yes            Create a fresh SuperNovaFS")
        terminal_writeln("  mem                   Show free kernel heap")
        terminal_writeln("  clear                 Clear the terminal")
        terminal_writeln("  about                 Show system information")
        terminal_writeln("  reboot                Reboot")
        terminal_writeln("")

        terminal_set_color(13)
        terminal_writeln("Typing")
        terminal_set_color(7)
        terminal_writeln("  Lowercase, uppercase, Shift, Caps Lock and AltGr work.")
        terminal_writeln("  MicroC symbols include: { } [ ] ( ) < > + - * / % = !")
        terminal_writeln("  Also available: & | ^ _ @ ~ \\ \" ' , . : ; # ?")
        terminal_set_color(15)

        return 0
    }

    fn shell_about() {
        terminal_set_color(13)
        terminal_writeln("SuperNovaOS 0.7")
        terminal_set_color(15)
        terminal_writeln("x86-64 operating system written for MicroC")
        terminal_writeln("640x480 16-color planar VGA")
        terminal_writeln("Temple-inspired native editor")
        terminal_writeln("PS/2 keyboard with SWE and ENG layouts")
        terminal_writeln("ATA PIO + SuperNovaFS v2")
        terminal_writeln("MicroC AOT + guarded JIT development environment")
        terminal_writeln("")

        terminal_write("keyboard: ")

        if (keyboard_layout() == 1) {
            terminal_writeln("SWE")
        } else {
            terminal_writeln("ENG")
        }

        return 0
    }

    fn shell_write_cmd(I64 args) {
        if (args == 0) {
            terminal_writeln("usage: write FILE TEXT")
            return 0
        }

        I64 text = shell_split(args)
        if (text == 0) {
            terminal_writeln("usage: write FILE TEXT")
            return 0
        }

        if (fs_write_text(args,text) != 0) {
            terminal_writeln("written")
            return 1
        }

        terminal_writeln("write failed")
        return 0
    }

    fn shell_execute(I64 line) {
        if (mem_read8(line) == 0) {
            return 0
        }

        I64 args = shell_split(line)

        if (str_eq_ci(line, "help") != 0) {
            shell_help()
            return 0
        }

        if (str_eq_ci(line, "clear") != 0) {
            terminal_clear()
            return 0
        }

        if (str_eq_ci(line, "about") != 0) {
            shell_about()
            return 0
        }

        if (str_eq_ci(line, "mem") != 0) {
            terminal_write("heap free: ")
            terminal_write_u64(
                heap_free_bytes()
            )
            terminal_writeln(" bytes")
            return 0
        }

        if (str_eq_ci(line, "keylayout") != 0) {
            shell_keylayout(args)
            return 0
        }

        if (str_eq_ci(line, "format") != 0) {
            if (args == 0) {
                terminal_writeln("format erases SuperNovaFS")
                terminal_writeln("use: format YES")
                return 0
            }

            I64 confirmed = str_eq_ci(args, "yes")

            if (confirmed == 0) {
                confirmed = str_eq_ci(args, "y")
            }

            if (confirmed == 0) {
                terminal_writeln("format cancelled")
                return 0
            }

            terminal_write("Creating SuperNovaFS... ")

            if (fs_format() != 0) {
                terminal_writeln("done")

                if (bootstrap_install_core() != 0) {
                    terminal_writeln("Core files installed: mcc.bin, compiler.mc, kernel.mc")
                } else {
                    terminal_set_color(14)
                    terminal_writeln("Filesystem created, but core bootstrap files are missing.")
                    terminal_writeln("Rebuild/seed supernova.img, then boot and run format yes again.")
                    terminal_set_color(15)
                }
            } else {
                terminal_set_color(12)
                terminal_writeln("format failed: ATA write/readback error")
                terminal_set_color(15)
            }

            return 0
        }

        if (str_eq_ci(line, "ls") != 0) {
            fs_list()
            return 0
        }

        if (str_eq_ci(line, "cat") != 0) {
            if (args == 0) {
                terminal_writeln("usage: cat FILE")
            } else {
                fs_cat(args)
            }

            return 0
        }

        if (str_eq_ci(line, "touch") != 0) {
            if (args == 0) {
                terminal_writeln("usage: touch FILE")
            } else {
                if (fs_create(args) != 0) {
                    terminal_writeln("created")
                } else {
                    terminal_writeln("create failed")
                }
            }

            return 0
        }

        if (str_eq_ci(line, "rm") != 0) {
            if (args == 0) {
                terminal_writeln("usage: rm FILE")
            } else {
                if (fs_delete(args) != 0) {
                    terminal_writeln("deleted")
                } else {
                    terminal_writeln("delete failed")
                }
            }

            return 0
        }

        if (str_eq_ci(line, "cp") != 0) {
            if (args == 0) {
                terminal_writeln("usage: cp SOURCE DEST")
                return 0
            }

            I64 destination = shell_split(args)

            if (destination == 0) {
                terminal_writeln("usage: cp SOURCE DEST")
                return 0
            }

            if (fs_copy(args, destination) != 0) {
                terminal_writeln("copied")
            } else {
                terminal_writeln("copy failed")
            }

            return 0
        }

        if (str_eq_ci(line, "write") != 0) {
            shell_write_cmd(args)
            return 0
        }

        if (str_eq_ci(line, "edit") != 0) {
            if (args == 0) {
                terminal_writeln("usage: edit FILE")
                return 0
            }

            editor_open(args)
            return 0
        }

        if (str_eq_ci(line, "run") != 0) {
            if (args == 0) {
                terminal_writeln("usage: run PROGRAM.bin [args]")
                return 0
            }

            I64 program_args = shell_split(args)

            I64 result = program_run(
                args,
                program_args
            )

            if (result >= 0) {
                terminal_set_color(7)
                terminal_write("program returned ")
                terminal_write_i64(result)
                terminal_writeln("")
                terminal_set_color(15)
            }

            return 0
        }

        if (str_eq_ci(line, "mcc") != 0) {
            if (fs_size_path("mcc.bin") < 0) {
                terminal_writeln("mcc.bin is not installed")
                return 0
            }

            program_run(
                "mcc.bin",
                args
            )

            return 0
        }

        if (str_eq_ci(line, "reboot") != 0) {
            terminal_writeln("rebooting")
            cpu_reboot()
            return 0
        }

        terminal_set_color(12)
        terminal_writeln("unknown command")
        terminal_set_color(15)

        return 0
    }

    fn shell_prompt() {
        terminal_set_color(13)
        terminal_write("SuperNova")
        terminal_set_color(7)

        if (keyboard_layout() == 1) {
            terminal_write("[swe]")
        } else {
            terminal_write("[eng]")
        }

        terminal_set_color(15)
        terminal_write(" > ")
        return 0
    }

    fn shell_banner() {
        terminal_set_color(13)
        terminal_writeln("SuperNovaOS 0.7")
        terminal_set_color(15)
        terminal_writeln("MicroC native development environment")
        terminal_set_color(7)
        terminal_writeln("Type help for commands. Keyboard layout: swe")
        terminal_set_color(15)
        terminal_writeln("")
        return 0
    }

    fn shell_loop() {
        I64 buffer = SHELL_BUFFER()

        while (1 == 1) {
            shell_prompt()
            keyboard_read_line(buffer,256)
            shell_execute(buffer)
        }
        return 0
    }

    fn kernel_init() {
        cpu_cli()

        map_low_16mb()

        vga_init()
        terminal_init()
        heap_init()
        keyboard_init()

        program_clear_args()
        abi_init()

        return 0
    }

    fn main() {
        kernel_init()
        shell_banner()

        if (fs_formatted() == 0) {
            terminal_set_color(14)
            terminal_writeln("SuperNovaFS v2 is not ready.")
            terminal_writeln("Run: format yes")
            terminal_set_color(15)
            terminal_writeln("")
        } else {
            bootstrap_install_core()

            if (fs_size_path("mcc.bin") >= 0) {
                terminal_set_color(10)
                terminal_writeln("MicroC compiler: ready")
                terminal_set_color(15)

                if (fs_size_path("compiler.mc") >= 0) {
                    terminal_writeln("edit compiler.mc")
                }

                if (fs_size_path("kernel.mc") >= 0) {
                    terminal_writeln("edit kernel.mc")
                }

                terminal_writeln("")
            } else {
                terminal_set_color(14)
                terminal_writeln("MicroC compiler: mcc.bin not installed")
                terminal_set_color(15)
                terminal_writeln("")
            }
        }

        shell_loop()

        while (1 == 1) {
            cpu_hlt()
        }
    }
}