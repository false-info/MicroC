head(custom) {
    fn vga_entry(I64 character, I64 color) {
        return character | (color << 8)
    }

    fn vga_cell(I64 row, I64 column) {
        return row * 80 + column
    }

    fn vga_write_at(I64 row, I64 column, I64 character, I64 color) {
        I64 cell = vga_cell(row, column)
        I64 address = 0xB8000 + cell * 2
        I64 value = vga_entry(character, color)

        mem_write16(address, value)

        return 0
    }

    fn vga_clear(I64 color) {
        I64 i = 0

        while (i < 2000) {
            mem_write16(0xB8000 + i * 2, vga_entry(32, color))
            i = i + 1
        }

        return 0
    }

    fn draw_text(I64 text, I64 row, I64 column, I64 color) {
        I64 i = 0
        I64 character = mem_read8(text)

        while (character != 0) {
            vga_write_at(row, column + i, character, color)

            i = i + 1
            character = mem_read8(text + i)
        }

        return i
    }

    fn hex_character(I64 value) {
        if (value < 10) {
            return 48 + value
        }

        return 55 + value
    }

    fn draw_hex64(I64 value, I64 row, I64 column, I64 color) {
        vga_write_at(row, column, 48, color)
        vga_write_at(row, column + 1, 120, color)

        I64 shift = 60
        I64 index = 0

        while (index < 16) {
            I64 nibble = (value >> shift) & 15

            vga_write_at(
                row,
                column + 2 + index,
                hex_character(nibble),
                color
            )

            shift = shift - 4
            index = index + 1
        }

        return 0
    }

    fn draw_decimal(I64 value, I64 row, I64 column, I64 color) {
        if (value == 0) {
            vga_write_at(row, column, 48, color)
            return 1
        }

        I64 divisor = 1000000000
        I64 started = 0
        I64 written = 0

        while (divisor > 0) {
            I64 digit = value / divisor

            if (digit != 0) {
                started = 1
            }

            if (started != 0) {
                vga_write_at(
                    row,
                    column + written,
                    48 + digit,
                    color
                )

                written = written + 1
            }

            value = value % divisor
            divisor = divisor / 10
        }

        return written
    }

    fn memory_set8(I64 address, I64 value, I64 count) {
        I64 i = 0

        while (i < count) {
            mem_write8(address + i, value)
            i = i + 1
        }

        return address
    }

    fn memory_set16(I64 address, I64 value, I64 count) {
        I64 i = 0

        while (i < count) {
            mem_write16(address + i * 2, value)
            i = i + 1
        }

        return address
    }

    fn memory_set32(I64 address, I64 value, I64 count) {
        I64 i = 0

        while (i < count) {
            mem_write32(address + i * 4, value)
            i = i + 1
        }

        return address
    }

    fn memory_set64(I64 address, I64 value, I64 count) {
        I64 i = 0

        while (i < count) {
            mem_write64(address + i * 8, value)
            i = i + 1
        }

        return address
    }

    fn memory_copy(I64 destination, I64 source, I64 count) {
        I64 i = 0

        while (i < count) {
            mem_write8(destination + i, mem_read8(source + i))
            i = i + 1
        }

        return destination
    }

    fn memory_compare(I64 a, I64 b, I64 count) {
        I64 i = 0

        while (i < count) {
            I64 av = mem_read8(a + i)
            I64 bv = mem_read8(b + i)

            if (av != bv) {
                return av - bv
            }

            i = i + 1
        }

        return 0
    }

    fn serial_init() {
        port_out8(0x3F9, 0x00)
        port_out8(0x3FB, 0x80)
        port_out8(0x3F8, 0x03)
        port_out8(0x3F9, 0x00)
        port_out8(0x3FB, 0x03)
        port_out8(0x3FA, 0xC7)
        port_out8(0x3FC, 0x0B)

        return 0
    }

    fn serial_ready() {
        return port_in8(0x3FD) & 0x20
    }

    fn serial_write(I64 character) {
        I64 ready = serial_ready()

        while (ready == 0) {
            cpu_pause()
            ready = serial_ready()
        }

        port_out8(0x3F8, character)

        return character
    }

    fn serial_text(I64 text) {
        I64 i = 0
        I64 character = mem_read8(text)

        while (character != 0) {
            serial_write(character)

            i = i + 1
            character = mem_read8(text + i)
        }

        return i
    }

    fn io_wait() {
        port_out8(0x80, 0)
        return 0
    }

    fn pic_remap() {
        port_out8(0x20, 0x11)
        io_wait()

        port_out8(0xA0, 0x11)
        io_wait()

        port_out8(0x21, 0x20)
        io_wait()

        port_out8(0xA1, 0x28)
        io_wait()

        port_out8(0x21, 0x04)
        io_wait()

        port_out8(0xA1, 0x02)
        io_wait()

        port_out8(0x21, 0x01)
        io_wait()

        port_out8(0xA1, 0x01)
        io_wait()

        port_out8(0x21, 0xFF)
        port_out8(0xA1, 0xFF)

        return 0
    }

    fn pic_mask_all() {
        port_out8(0x21, 0xFF)
        port_out8(0xA1, 0xFF)

        return 0
    }

    fn pic_enable_keyboard() {
        port_out8(0x21, 0xFD)
        return 0
    }

    fn pic_eoi_master() {
        port_out8(0x20, 0x20)
        return 0
    }

    fn pic_eoi_slave() {
        port_out8(0xA0, 0x20)
        port_out8(0x20, 0x20)

        return 0
    }

    fn pit_set_frequency(I64 frequency) {
        if (frequency == 0) {
            return 0
        }

        I64 divisor = 1193182 / frequency

        port_out8(0x43, 0x36)
        port_out8(0x40, divisor & 0xFF)
        port_out8(0x40, (divisor >> 8) & 0xFF)

        return divisor
    }

    fn keyboard_has_data() {
        return port_in8(0x64) & 1
    }

    fn keyboard_read_scancode() {
        I64 ready = keyboard_has_data()

        if (ready == 0) {
            return 0
        }

        return port_in8(0x60)
    }

    fn show_control_registers() {
        I64 cr0 = cpu_read_cr0()
        I64 cr2 = cpu_read_cr2()
        I64 cr3 = cpu_read_cr3()
        I64 cr4 = cpu_read_cr4()

        draw_text("CR0:", 7, 2, 0x0B)
        draw_hex64(cr0, 7, 8, 0x0F)

        draw_text("CR2:", 8, 2, 0x0B)
        draw_hex64(cr2, 8, 8, 0x0F)

        draw_text("CR3:", 9, 2, 0x0B)
        draw_hex64(cr3, 9, 8, 0x0F)

        draw_text("CR4:", 10, 2, 0x0B)
        draw_hex64(cr4, 10, 8, 0x0F)

        return 0
    }

    fn show_stack() {
        I64 rsp = cpu_read_rsp()
        I64 rbp = cpu_read_rbp()

        draw_text("RSP:", 12, 2, 0x0A)
        draw_hex64(rsp, 12, 8, 0x0F)

        draw_text("RBP:", 13, 2, 0x0A)
        draw_hex64(rbp, 13, 8, 0x0F)

        return 0
    }

    fn show_clock() {
        I64 cycles = cpu_rdtsc()

        draw_text("TSC:", 15, 2, 0x0D)
        draw_hex64(cycles, 15, 8, 0x0F)

        return cycles
    }

    fn panic(I64 message) {
        cpu_cli()

        vga_clear(0x4F)

        draw_text("SUPERNOVA KERNEL PANIC", 8, 27, 0x4F)
        draw_text(message, 11, 4, 0x4F)

        serial_text("KERNEL PANIC: ")
        serial_text(message)
        serial_text("\n")

        while (1 == 1) {
            cpu_hlt()
        }

        return 0
    }

    fn draw_banner() {
        draw_text("SuperNovaOS", 1, 2, 0x0F)
        draw_text("MicroC x86-64 kernel", 2, 2, 0x08)
        draw_text("stage1 -> stage2 -> long mode -> kernel", 3, 2, 0x07)

        I64 column = 0

        while (column < 80) {
            vga_write_at(4, column, 45, 0x08)
            column = column + 1
        }

        return 0
    }

    fn main() {
        cpu_cli()

        vga_clear(0x07)

        draw_banner()

        serial_init()

        serial_text("\n")
        serial_text("SuperNovaOS kernel entered\n")
        serial_text("MicroC raw x86-64 code is running\n")

        pic_remap()
        pic_mask_all()

        pit_set_frequency(100)

        show_control_registers()
        show_stack()
        show_clock()

        draw_text("Kernel loaded at:", 17, 2, 0x0E)
        draw_hex64(0x100000, 17, 22, 0x0F)

        draw_text("VGA buffer:", 18, 2, 0x0E)
        draw_hex64(0xB8000, 18, 22, 0x0F)

        draw_text("Paging tables:", 19, 2, 0x0E)
        draw_hex64(cpu_read_cr3(), 19, 22, 0x0F)

        draw_text("SuperNovaOS is alive.", 22, 2, 0x0A)

        serial_text("Kernel initialization complete\n")

        while (1 == 1) {
            cpu_hlt()
        }
    }
}