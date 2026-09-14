head(custom)
head(memory)
head(file)
head(process)

fn os_putchar(I64 ch) {
    pin("%c", ch)
    return ch
}

fn compiler_write(I64 text) {
    pin("%s", text)
    return 0
}

fn os_kernel_open(I64 path, I64 flags) {
    return open(path, flags)
}

fn os_kernel_close(I64 fd) {
    return close(fd)
}

fn os_kernel_read8(I64 fd) {
    return file_read8(fd)
}

fn os_kernel_write8(I64 fd, I64 value) {
    return file_write8(fd, value)
}

fn os_kernel_size(I64 fd) {
    return file_size(fd)
}

fn os_kernel_seek(I64 fd, I64 position) {
    return file_seek(fd, position)
}

fn os_argc() {
    return argc()
}

fn os_argv(I64 index) {
    return argv(index)
}

fn os_write_u64(I64 value) {
    pin("%U64", value)
    return 0
}

fn os_write_i64(I64 value) {
    pin("%I64", value)
    return 0
}

fn os_write_hex(I64 value) {
    pin("%X64", value)
    return 0
}

fn os_write_file(I64 path, I64 buffer, I64 size) {
    I64 fd = open(path, 577)
    if (fd < 0) {
        return 0
    }

    I64 i = 0
    while (i < size) {
        file_write8(fd, mem_read8(buffer + i))
        i = i + 1
    }

    close(fd)
    return 1
}

fn os_aot_handle() {
    return 0 - 100
}

fn os_aot_base() {
    return 0x600000
}

fn os_aot_limit() {
    return 0x100000
}

fn os_sink_pos_addr() {
    return 0x800578
}

fn os_sink_size_addr() {
    return 0x800580
}

fn os_safe_mode_addr() {
    return 0x800590
}

fn detect_host_abi() {
    I64 fd = os_open("/bin/sh", 0)

    if (fd >= 0) {
        os_file_seek(fd, 7)
        I64 osabi = os_file_read8(fd)
        os_close(fd)

        if (osabi == 9) {
            mem_write64(0x800598, 2)
            return 2
        }
    }

    I64 freebsd = os_open("/bin/freebsd-version", 0)

    if (freebsd >= 0) {
        os_close(freebsd)
        mem_write64(0x800598, 2)
        return 2
    }

    mem_write64(0x800598, 1)
    return 1
}

fn token_line_addr(I64 slot) {
    if (slot == 0) {
        return 0x8005A0
    }

    return 0x8005B0
}

fn token_column_addr(I64 slot) {
    if (slot == 0) {
        return 0x8005A8
    }

    return 0x8005B8
}

fn token_line(I64 slot) {
    if (slot == 0) { return mem_read64(0x8005A0) }
    return mem_read64(0x8005B0)
}

fn token_column(I64 slot) {
    if (slot == 0) { return mem_read64(0x8005A8) }
    return mem_read64(0x8005B8)
}

fn set_token_location(I64 slot, I64 line, I64 column) {
    if (slot == 0) {
        mem_write64(0x8005A0, line)
        mem_write64(0x8005A8, column)
        return 0
    }
    mem_write64(0x8005B0, line)
    mem_write64(0x8005B8, column)
    return 0
}

fn print_source_context(I64 path, I64 wanted_line, I64 wanted_column) {
    if (path == 0) {
        return 0
    }

    if (wanted_line <= 0) {
        return 0
    }

    if (wanted_column <= 0) {
        wanted_column = 1
    }

    I64 fd = os_open(path, 0)

    if (fd < 0) {
        return 0
    }

    I64 size = os_file_size(fd)

    if (size < 0) {
        os_close(fd)
        return 0
    }

    os_file_seek(fd, 0)

    I64 position = 0
    I64 line = 1
    I64 line_start = 0
    I64 found = 0

    while (position < size) {
        if (found != 0) {
            position = size
        }
        else {
            if (line == wanted_line) {
                line_start = position
                found = 1
                position = size
            }
            else {
                I64 c = os_file_read8(fd)
                position = position + 1

                if (c == 10) {
                    line = line + 1
                }
            }
        }
    }

    if (found == 0) {
        os_close(fd)
        return 0
    }

    os_file_seek(fd, line_start)
    compiler_write("    | ")

    I64 source_column = 1
    I64 caret_width = 0
    I64 done = 0
    position = line_start

    while (position < size) {
        if (done != 0) {
            position = size
        }
        else {
            I64 c2 = os_file_read8(fd)
            position = position + 1

            if (c2 == 10) {
                done = 1
            }
            else {
                if (c2 == 13) {
                    done = 1
                }
                else {
                    if (c2 == 9) {
                        compiler_write("    ")

                        if (source_column < wanted_column) {
                            caret_width = caret_width + 4
                        }
                    }
                    else {
                        os_putchar(c2)

                        if (source_column < wanted_column) {
                            caret_width = caret_width + 1
                        }
                    }

                    source_column = source_column + 1
                }
            }
        }
    }

    compiler_write("\n")
    compiler_write("    | ")

    I64 i = 0
    while (i < caret_width) {
        os_putchar(32)
        i = i + 1
    }

    compiler_write("^\n")
    os_close(fd)
    return 0
}

fn print_error_message(I64 code) {
    if (code == 1) { compiler_write("unexpected token or invalid syntax") return 0 }
    if (code == 2) { compiler_write("custom syntax requires custom in head()") return 0 }
    if (code == 3) { compiler_write("inline x86 assembly requires an asm-x86-* mode in head()") return 0 }
    if (code == 4) { compiler_write("assignment to undeclared variable") return 0 }
    if (code == 5) { compiler_write("duplicate variable declaration") return 0 }
    if (code == 6) { compiler_write("identifier too long") return 0 }
    if (code == 7) { compiler_write("string literal too long") return 0 }
    if (code == 8) { compiler_write("wrong number of function arguments") return 0 }
    if (code == 9) { compiler_write("duplicate function declaration") return 0 }
    if (code == 10) { compiler_write("unterminated string literal") return 0 }
    if (code == 11) { compiler_write("compiler string pool exhausted") return 0 }
    if (code == 12) { compiler_write("hosted builtin is unavailable in raw .bin output") return 0 }
    if (code == 13) { compiler_write("kernel-only builtin cannot be used in an ELF program") return 0 }
    if (code == 14) { compiler_write("unknown function for fn_offset") return 0 }
    if (code == 15) { compiler_write("x86-16/x86-32 assembly requires raw .bin output") return 0 }
    if (code == 16) { compiler_write("custom x86-64 codegen cannot share x86-16/x86-32 head mode") return 0 }
    if (code == 17) { compiler_write("assembly mode is not enabled in head()") return 0 }
    if (code == 18) { compiler_write("invalid assembly register or operands") return 0 }
    if (code == 19) { compiler_write("unknown assembly label") return 0 }
    if (code == 20) { compiler_write("duplicate assembly label") return 0 }
    if (code == 21) { compiler_write("assembly value or branch is out of range") return 0 }
    if (code == 22) { compiler_write("unsafe operation requires unsafe { } in safe mode") return 0 }
    if (code == 30) { compiler_write("assignment to const variable") return 0 }
    if (code == 31) { compiler_write("could not import module") return 0 }
    if (code == 32) { compiler_write("import limit or import nesting limit exceeded") return 0 }
    if (code == 33) { compiler_write("break or continue used outside a loop") return 0 }
    if (code == 34) { compiler_write("expected a type name") return 0 }
    if (code == 35) { compiler_write("expected a head name") return 0 }
    if (code == 36) { compiler_write("could not open head.h") return 0 }
    if (code == 37) { compiler_write("unknown custom head") return 0 }
    if (code == 38) { compiler_write("custom head cycle or nesting limit exceeded") return 0 }
    if (code == 39) { compiler_write("invalid MicroC header or fhf target") return 0 }
    if (code == 40) { compiler_write("unknown or duplicate built-in head") return 0 }
    if (code == 41) { compiler_write("builtin requires its matching head()") return 0 }
    compiler_write("compilation failed")
    return 0
}

fn print_warning_message(I64 code) {
    if (code == 1) { compiler_write("custom enabled in head() but never used") return 0 }
    if (code == 2) { compiler_write("x86 assembly enabled in head() but never used") return 0 }
    compiler_write("compiler warning")
    return 0
}

fn driver_error(I64 code, I64 path) {
    if (path != 0) {
        compiler_write(path)
        compiler_write(": ")
    }

    compiler_write("[error ")
    os_write_u64(code)
    compiler_write("] ")

    if (code == 23) { compiler_write("could not open input file\n") return 1 }
    if (code == 24) { compiler_write("could not read input size\n") return 1 }
    if (code == 25) { compiler_write("source file is too large\n") return 1 }
    if (code == 26) { compiler_write("output arena guard was damaged\n") return 1 }
    if (code == 27) { compiler_write("output exceeded compiler arena\n") return 1 }
    if (code == 28) { compiler_write("could not write output file\n") return 1 }
    if (code == 29) { compiler_write("invalid command line\n") return 1 }

    compiler_write("compiler driver failure\n")
    return 1
}

fn os_guard_magic() {
    return 0x534E475541524431
}

fn os_is_sink(I64 fd) {
    if (fd == os_aot_handle()) {
        return 1
    }

    return 0
}

fn os_sink_base(I64 fd) {
    return os_aot_base()
}

fn os_sink_limit(I64 fd) {
    return os_aot_limit()
}

fn os_sink_reset(I64 fd) {
    I64 base = os_sink_base(fd)
    I64 limit = os_sink_limit(fd)

    mem_write64(os_sink_pos_addr(), 0)
    mem_write64(os_sink_size_addr(), 0)

    mem_write64(base - 8, os_guard_magic())
    mem_write64(base + limit, os_guard_magic())

    return 0
}

fn os_sink_guard_ok(I64 fd) {
    I64 base = os_sink_base(fd)
    I64 limit = os_sink_limit(fd)

    if (mem_read64(base - 8) != os_guard_magic()) {
        return 0
    }

    if (mem_read64(base + limit) != os_guard_magic()) {
        return 0
    }

    return 1
}

fn os_open(I64 path, I64 flags) {
    return os_kernel_open(path, flags)
}

fn os_close(I64 fd) {
    if (os_is_sink(fd) != 0) {
        return 0
    }

    return os_kernel_close(fd)
}

fn os_file_read8(I64 fd) {
    return os_kernel_read8(fd)
}

fn os_file_write8(I64 fd, I64 value) {
    if (os_is_sink(fd) != 0) {
        I64 position = mem_read64(os_sink_pos_addr())
        I64 limit = os_sink_limit(fd)

        if (position >= limit) {
            mem_write64(0x800078, 1)
            return 0
        }

        mem_write8(
        os_sink_base(fd) + position,
        value & 255
        )

        position = position + 1
        mem_write64(os_sink_pos_addr(), position)

        if (position > mem_read64(os_sink_size_addr())) {
            mem_write64(os_sink_size_addr(), position)
        }

        return value
    }

    return os_kernel_write8(fd, value)
}

fn os_file_seek(I64 fd, I64 position) {
    if (os_is_sink(fd) != 0) {
        if (position < 0) {
            return 0 - 1
        }

        if (position > os_sink_limit(fd)) {
            return 0 - 1
        }

        mem_write64(os_sink_pos_addr(), position)
        return position
    }

    return os_kernel_seek(fd, position)
}

fn os_file_size(I64 fd) {
    if (os_is_sink(fd) != 0) {
        return mem_read64(os_sink_size_addr())
    }

    return os_kernel_size(fd)
}

fn sget(I64 address) {
    return mem_read64(address)
}

fn sset(I64 address, I64 value) {
    mem_write64(address, value)
    return value
}

fn in_fd() {
    return mem_read64(0x800000)
}

fn out_fd() {
    return mem_read64(0x800008)
}

fn out_raw() {
    return mem_read64(0x800030)
}

fn out8(I64 value) {
    if (mem_read64(0x800088) != 0) {
        return value
    }
    I64 fd = out_fd()
    os_file_write8(fd, value & 255)
    I64 position = mem_read64(0x800090)
    mem_write64(0x800090, position + 1)
    return value
}

fn out32(I64 value) {
    if (mem_read64(0x800088) != 0) {
        return value
    }
    I64 fd = mem_read64(0x800008)
    I64 position = mem_read64(0x800090)
    os_file_write8(fd, value & 255)
    os_file_write8(fd, (value >> 8) & 255)
    os_file_write8(fd, (value >> 16) & 255)
    os_file_write8(fd, (value >> 24) & 255)
    mem_write64(0x800090, position + 4)
    return value
}

fn print_diagnostic_summary() {
    I64 errors = mem_read64(0x8000D0)
    I64 warnings = mem_read64(0x8000D8)

    if (errors == 0) {
        if (warnings == 0) {
            return 0
        }
    }

    compiler_write("mcc: ")
    os_write_u64(errors)

    if (errors == 1) {
        compiler_write(" error, ")
    }
    else {
        compiler_write(" errors, ")
    }

    os_write_u64(warnings)

    if (warnings == 1) {
        compiler_write(" warning\n")
    }
    else {
        compiler_write(" warnings\n")
    }

    return 0
}

fn print_output_info(I64 path, I64 size) {
    compiler_write("mcc: created ")
    compiler_write(path)
    compiler_write(" (")
    os_write_u64(size)
    compiler_write(" bytes)\n")
    return 0
}

fn compiler_error(I64 code) {
    if (failed() != 0) {
        return 0
    }

    I64 errors = mem_read64(0x8000D0)
    mem_write64(0x8000D0, errors + 1)
    mem_write64(0x800078, 1)

    I64 path = mem_read64(0x8000E0)
    I64 line = mem_read64(0x8000E8)
    I64 column = mem_read64(0x8000F0)

    if (token_line(0) > 0) {
        line = token_line(0)
        column = token_column(0)
    }

    if (column <= 0) {
        column = 1
    }

    if (path != 0) {
        compiler_write(path)
    }
    else {
        compiler_write("<source>")
    }

    compiler_write(":")
    os_write_u64(line)
    compiler_write(":")
    os_write_u64(column)
    compiler_write(": [error ")
    os_write_u64(code)
    compiler_write("] ")
    print_error_message(code)
    compiler_write("\n")

    print_source_context(path, line, column)
    return 0
}

fn compiler_warning(I64 code) {
    I64 warnings = mem_read64(0x8000D8)
    mem_write64(0x8000D8, warnings + 1)

    I64 path = mem_read64(0x8000E0)
    I64 line = mem_read64(0x8000E8)
    I64 column = mem_read64(0x8000F0)

    if (token_line(0) > 0) {
        line = token_line(0)
        column = token_column(0)
    }

    if (column <= 0) {
        column = 1
    }

    if (path != 0) {
        compiler_write(path)
    }
    else {
        compiler_write("<source>")
    }

    compiler_write(":")
    os_write_u64(line)
    compiler_write(":")
    os_write_u64(column)
    compiler_write(": [warning ")
    os_write_u64(code)
    compiler_write("] ")
    print_warning_message(code)
    compiler_write("\n")

    print_source_context(path, line, column)
    return 0
}

fn out64(I64 value) {
    if (mem_read64(0x800088) != 0) {
        return value
    }
    I64 fd = mem_read64(0x800008)
    I64 position = mem_read64(0x800090)
    os_file_write8(fd, value & 255)
    os_file_write8(fd, (value >> 8) & 255)
    os_file_write8(fd, (value >> 16) & 255)
    os_file_write8(fd, (value >> 24) & 255)
    os_file_write8(fd, (value >> 32) & 255)
    os_file_write8(fd, (value >> 40) & 255)
    os_file_write8(fd, (value >> 48) & 255)
    os_file_write8(fd, (value >> 56) & 255)
    mem_write64(0x800090, position + 8)
    return value
}

fn tell() {
    return mem_read64(0x800090)
}

fn seek_out(I64 position) {
    I64 fd = out_fd()
    os_file_seek(fd, position)
    mem_write64(0x800090, position)
    return position
}

fn patch32_at(I64 position, I64 value) {
    I64 end = tell()
    I64 fd = out_fd()
    seek_out(position)
    os_file_write8(fd, value & 255)
    os_file_write8(fd, (value >> 8) & 255)
    os_file_write8(fd, (value >> 16) & 255)
    os_file_write8(fd, (value >> 24) & 255)
    seek_out(end)
    return value
}

fn patch16_at(I64 position, I64 value) {
    I64 end = mem_read64(0x800090)
    I64 fd = mem_read64(0x800008)
    os_file_seek(fd, position)
    os_file_write8(fd, value & 255)
    os_file_write8(fd, (value >> 8) & 255)
    os_file_seek(fd, end)
    return value
}

fn patch64_at(I64 position, I64 value) {
    I64 end = tell()
    I64 fd = out_fd()
    seek_out(position)
    os_file_write8(fd, value & 255)
    os_file_write8(fd, (value >> 8) & 255)
    os_file_write8(fd, (value >> 16) & 255)
    os_file_write8(fd, (value >> 24) & 255)
    os_file_write8(fd, (value >> 32) & 255)
    os_file_write8(fd, (value >> 40) & 255)
    os_file_write8(fd, (value >> 48) & 255)
    os_file_write8(fd, (value >> 56) & 255)
    seek_out(end)
    return value
}

fn use_custom_feature() {
    if (mem_read64(0x800098) == 0) {
        compiler_error(2)
        return 0
    }
    mem_write64(0x8000A8, 1)
    return 1
}

fn use_asm_feature() {
    if (mem_read64(0x8000A0) == 0) {
        compiler_error(3)
        return 0
    }
    mem_write64(0x8000B0, 1)
    return 1
}

fn warn_unused_features() {
    if (mem_read64(0x800098) != 0) {
        if (mem_read64(0x8000A8) == 0) {
            compiler_warning(1)
        }
    }
    if (mem_read64(0x8000A0) != 0) {
        if (mem_read64(0x8000B0) == 0) {
            compiler_warning(2)
        }
    }
    return 0
}

fn fail() {
    compiler_error(1)
    return 0
}

fn failed() {
    return mem_read64(0x800078)
}

fn is_space(I64 c) {
    if (c == 32) {
        return 1
    }
    if (c == 9) {
        return 1
    }
    if (c == 10) {
        return 1
    }
    if (c == 13) {
        return 1
    }
    return 0
}

fn is_digit(I64 c) {
    if (c < 48) {
        return 0
    }
    if (c > 57) {
        return 0
    }
    return 1
}

fn is_alpha(I64 c) {
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
    if (c == 95) {
        return 1
    }
    return 0
}

fn is_ident_more(I64 c) {
    I64 a = is_alpha(c)
    if (a != 0) {
        return 1
    }
    I64 d = is_digit(c)
    if (d != 0) {
        return 1
    }
    return 0
}

fn hex_value(I64 c) {
    if (c >= 48) {
        if (c <= 57) {
            return c - 48
        }
    }
    if (c >= 65) {
        if (c <= 70) {
            return c - 55
        }
    }
    if (c >= 97) {
        if (c <= 102) {
            return c - 87
        }
    }
    return 0 - 1
}

fn read_char() {
    I64 position = mem_read64(0x800010)
    I64 size = mem_read64(0x800018)

    if (position >= size) {
        mem_write64(0x800020, 0)
        return 0
    }

    I64 fd = in_fd()
    I64 c = os_file_read8(fd)

    mem_write64(0x800010, position + 1)
    mem_write64(0x800020, c)

    I64 line = mem_read64(0x8000C0)
    I64 column = mem_read64(0x8000C8)

    if (c == 10) {
        mem_write64(0x8000C0, line + 1)
        mem_write64(0x8000C8, 0)
        return c
    }

    mem_write64(0x8000C8, column + 1)
    return c
}

fn current_char() {
    return mem_read64(0x800020)
}

fn token_base(I64 slot) {
    return 0x800100 + slot * 32
}

fn token_text(I64 slot) {
    if (slot == 0) {
        return 0x801000
    }
    return 0x801200
}

fn token_type(I64 slot) {
    return mem_read64(token_base(slot))
}

fn token_value(I64 slot) {
    return mem_read64(token_base(slot) + 8)
}

fn token_length(I64 slot) {
    return mem_read64(token_base(slot) + 16)
}

fn token_hash(I64 slot) {
    return mem_read64(token_base(slot) + 24)
}

fn set_token(I64 slot, I64 type) {
    I64 base = token_base(slot)
    mem_write64(base, type)
    mem_write64(base + 8, 0)
    mem_write64(base + 16, 0)
    mem_write64(base + 24, 0)
    I64 text = token_text(slot)
    mem_write8(text, 0)
    return type
}

fn hash_text(I64 text) {
    I64 h = 1469598103934665603
    I64 i = 0
    I64 c = mem_read8(text)

    while (c != 0) {
        h = h ^ c
        h = h * 1099511628211
        i = i + 1
        c = mem_read8(text + i)
    }

    return h
}

fn lex_token(I64 slot) {
    I64 base = token_base(slot)
    I64 text = token_text(slot)
    I64 c = current_char()
    I64 again = 1

    while (again != 0) {
        again = 0
        I64 sp = is_space(c)
        while (sp != 0) {
            read_char()
            c = current_char()
            sp = is_space(c)
        }

        I64 start_line = mem_read64(0x8000C0)
        I64 start_column = mem_read64(0x8000C8)

        if (start_column <= 0) {
            start_column = 1
        }

        set_token_location(slot, start_line, start_column)
        mem_write64(0x8000E8, start_line)
        mem_write64(0x8000F0, start_column)

        if (c == 47) {
            read_char()
            I64 next = current_char()
            if (next == 47) {
                while (next != 0) {
                    if (next == 10) {
                        next = 0
                    }
                    if (next != 0) {
                        read_char()
                        next = current_char()
                    }
                }
                c = current_char()
                if (c == 10) {
                    read_char()
                    c = current_char()
                }
                again = 1
            }
            if (again == 0) {
                set_token(slot, 4)
                mem_write64(base + 8, 47)
                return 4
            }
        }
    }

    if (c == 0) {
        set_token(slot, 0)
        return 0
    }

    if (c == 34) {
        set_token(slot, 3)
        read_char()
        c = current_char()

        I64 length = 0
        I64 closed = 0

        while (c != 0) {
            if (c == 34) {
                closed = 1
                c = 0
            }

            if (c != 0) {
                if (c == 92) {
                    read_char()
                    c = current_char()

                    if (c == 0) {
                        compiler_error(10)
                        return 0
                    }

                    if (c == 110) {
                        c = 10
                    }
                    if (c == 114) {
                        c = 13
                    }
                    if (c == 116) {
                        c = 9
                    }
                }

                if (length >= 255) {
                    compiler_error(7)
                    return 0
                }

                mem_write8(text + length, c)
                length = length + 1
                read_char()
                c = current_char()
            }
        }

        if (closed == 0) {
            compiler_error(10)
            return 0
        }

        mem_write8(text + length, 0)
        mem_write64(base + 16, length)

        if (current_char() == 34) {
            read_char()
        }

        return 3
    }

    I64 digit = is_digit(c)
    if (digit != 0) {
        set_token(slot, 2)
        I64 value = 0

        if (c == 48) {
            read_char()
            c = current_char()

            if (c == 120) {
                read_char()
                c = current_char()
                I64 hv = hex_value(c)
                while (hv >= 0) {
                    value = value * 16 + hv
                    read_char()
                    c = current_char()
                    hv = hex_value(c)
                }
                mem_write64(base + 8, value)
                return 2
            }

            if (c == 88) {
                read_char()
                c = current_char()
                I64 hv2 = hex_value(c)
                while (hv2 >= 0) {
                    value = value * 16 + hv2
                    read_char()
                    c = current_char()
                    hv2 = hex_value(c)
                }
                mem_write64(base + 8, value)
                return 2
            }
        }

        digit = is_digit(c)
        while (digit != 0) {
            value = value * 10 + c - 48
            read_char()
            c = current_char()
            digit = is_digit(c)
        }

        if (c == 46) {
            set_token(slot, 5)
            read_char()
            c = current_char()
            I64 scale = 1
            I64 fdigit = is_digit(c)
            while (fdigit != 0) {
                value = value * 10 + c - 48
                scale = scale * 10
                read_char()
                c = current_char()
                fdigit = is_digit(c)
            }
            mem_write64(base + 8, value)
            mem_write64(base + 16, scale)
            return 5
        }

        mem_write64(base + 8, value)
        return 2
    }

    I64 alpha = is_alpha(c)
    if (alpha != 0) {
        set_token(slot, 1)
        I64 length2 = 0
        I64 h = 5381
        I64 more = is_ident_more(c)
        while (more != 0) {
            if (length2 >= 255) {
                compiler_error(6)
                return 0
            }
            mem_write8(text + length2, c)
            length2 = length2 + 1
            h = h * 33 + c
            read_char()
            c = current_char()
            more = is_ident_more(c)
        }
        mem_write8(text + length2, 0)
        mem_write64(base + 16, length2)
        mem_write64(base + 24, h)
        return 1
    }

    set_token(slot, 4)
    I64 symbol = c
    read_char()
    I64 c2 = current_char()

    if (symbol == 61) {
        if (c2 == 61) {
            read_char()
            symbol = 1001
        }
    }
    if (symbol == 33) {
        if (c2 == 61) {
            read_char()
            symbol = 1002
        }
    }
    if (symbol == 60) {
        if (c2 == 61) {
            read_char()
            symbol = 1003
        }
        if (c2 == 60) {
            read_char()
            symbol = 1005
        }
    }
    if (symbol == 62) {
        if (c2 == 61) {
            read_char()
            symbol = 1004
        }
        if (c2 == 62) {
            read_char()
            symbol = 1006
        }
    }
    if (symbol == 38) {
        if (c2 == 38) {
            read_char()
            symbol = 1007
        }
    }
    if (symbol == 124) {
        if (c2 == 124) {
            read_char()
            symbol = 1008
        }
    }

    mem_write64(base + 8, symbol)
    return 4
}

fn copy_token(I64 from_slot, I64 to_slot) {
    I64 from_base = token_base(from_slot)
    I64 to_base = token_base(to_slot)
    mem_write64(to_base, mem_read64(from_base))
    mem_write64(to_base + 8, mem_read64(from_base + 8))
    mem_write64(to_base + 16, mem_read64(from_base + 16))
    mem_write64(to_base + 24, mem_read64(from_base + 24))
    set_token_location(
        to_slot,
        token_line(from_slot),
        token_column(from_slot)
    )
    I64 src = token_text(from_slot)
    I64 dst = token_text(to_slot)
    I64 length = mem_read64(from_base + 16)
    I64 i = 0
    while (i <= length) {
        mem_write8(dst + i, mem_read8(src + i))
        i = i + 1
    }
    return mem_read64(to_base)
}

fn peek() {
    I64 has = mem_read64(0x800070)
    if (has == 0) {
        lex_token(1)
        mem_write64(0x800070, 1)
    }
    return token_type(1)
}

fn take() {
    I64 has = mem_read64(0x800070)
    if (has != 0) {
        copy_token(1, 0)
        mem_write64(0x800070, 0)
        mem_write64(0x8000E8, token_line(0))
        mem_write64(0x8000F0, token_column(0))
        return token_type(0)
    }
    return lex_token(0)
}

fn ct() {
    return token_type(0)
}
fn cv() {
    return token_value(0)
}
fn cp() {
    return token_text(0)
}
fn clen() {
    return token_length(0)
}
fn chash() {
    return token_hash(0)
}
fn lp() {
    return token_text(1)
}
fn lv() {
    return token_value(1)
}

fn tok_is(I64 text) {
    I64 p = cp()
    return strcmp(p, text) == 0
}

fn look_is(I64 text) {
    peek()
    I64 p = lp()
    return strcmp(p, text) == 0
}

fn look_sym(I64 value) {
    I64 type = peek()
    if (type != 4) {
        return 0
    }
    return lv() == value
}

fn expect_sym(I64 value) {
    take()
    if (ct() != 4) {
        fail() return 0
    }
    if (cv() != value) {
        fail() return 0
    }
    return 1
}

fn expect_word(I64 word) {
    take()
    if (ct() != 1) {
        fail() return 0
    }
    I64 p = cp()
    if (strcmp(p, word) != 0) {
        fail() return 0
    }
    return 1
}

fn type_id(I64 name) {
    if (strcmp(name, "I8") == 0) {
        return 1
    }
    if (strcmp(name, "I16") == 0) {
        return 2
    }
    if (strcmp(name, "I32") == 0) {
        return 3
    }
    if (strcmp(name, "I64") == 0) {
        return 4
    }
    if (strcmp(name, "U8") == 0) {
        return 5
    }
    if (strcmp(name, "U16") == 0) {
        return 6
    }
    if (strcmp(name, "U32") == 0) {
        return 7
    }
    if (strcmp(name, "U64") == 0) {
        return 8
    }
    if (strcmp(name, "F64") == 0) {
        return 9
    }
    if (strcmp(name, "Bool") == 0) {
        return 10
    }

    if (strcmp(name, "i8") == 0) { return 1 }
    if (strcmp(name, "i16") == 0) { return 2 }
    if (strcmp(name, "i32") == 0) { return 3 }
    if (strcmp(name, "i64") == 0) { return 4 }
    if (strcmp(name, "u8") == 0) { return 5 }
    if (strcmp(name, "u16") == 0) { return 6 }
    if (strcmp(name, "u32") == 0) { return 7 }
    if (strcmp(name, "u64") == 0) { return 8 }
    if (strcmp(name, "bool") == 0) { return 10 }
    if (strcmp(name, "usize") == 0) { return 8 }
    if (strcmp(name, "Ptr") == 0) { return 8 }
    return 0
}

fn type_bits(I64 type) {
    if (type == 1) {
        return 8
    }
    if (type == 2) {
        return 16
    }
    if (type == 3) {
        return 32
    }
    if (type == 4) {
        return 64
    }
    if (type == 5) {
        return 8
    }
    if (type == 6) {
        return 16
    }
    if (type == 7) {
        return 32
    }
    if (type == 8) {
        return 64
    }
    if (type == 9) {
        return 64
    }
    if (type == 10) {
        return 1
    }
    return 64
}

fn type_unsigned(I64 type) {
    if (type == 5) {
        return 1
    }
    if (type == 6) {
        return 1
    }
    if (type == 7) {
        return 1
    }
    if (type == 8) {
        return 1
    }
    if (type == 10) {
        return 1
    }
    return 0
}

fn common_integer_type(I64 left, I64 right) {
    if (left == 10) {
        left = 4
    }
    if (right == 10) {
        right = 4
    }

    I64 lw = type_bits(left)
    I64 rw = type_bits(right)
    I64 width = lw
    if (rw > width) {
        width = rw
    }

    I64 unsigned_result = 0
    if (type_unsigned(left) != 0) {
        if (lw >= rw) {
            unsigned_result = 1
        }
    }
    if (type_unsigned(right) != 0) {
        if (rw >= lw) {
            unsigned_result = 1
        }
    }

    if (unsigned_result != 0) {
        if (width == 8) {
            return 5
        }
        if (width == 16) {
            return 6
        }
        if (width == 32) {
            return 7
        }
        return 8
    }

    if (width == 8) {
        return 1
    }
    if (width == 16) {
        return 2
    }
    if (width == 32) {
        return 3
    }
    return 4
}

fn builtin_id(I64 name) {
    if (strcmp(name, "open") == 0) {
        return 1
    }
    if (strcmp(name, "close") == 0) {
        return 2
    }
    if (strcmp(name, "file_read8") == 0) {
        return 3
    }
    if (strcmp(name, "file_write8") == 0) {
        return 4
    }
    if (strcmp(name, "file_size") == 0) {
        return 5
    }
    if (strcmp(name, "file_seek") == 0) {
        return 6
    }
    if (strcmp(name, "mem_read8") == 0) {
        return 7
    }
    if (strcmp(name, "mem_write8") == 0) {
        return 8
    }
    if (strcmp(name, "mem_read64") == 0) {
        return 9
    }
    if (strcmp(name, "mem_write64") == 0) {
        return 10
    }
    if (strcmp(name, "strlen") == 0) {
        return 11
    }
    if (strcmp(name, "strcmp") == 0) {
        return 12
    }
    if (strcmp(name, "argc") == 0) {
        return 13
    }
    if (strcmp(name, "argv") == 0) {
        return 14
    }
    if (strcmp(name, "debug_char") == 0) {
        return 15
    }
    if (strcmp(name, "mem_read16") == 0) {
        return 16
    }
    if (strcmp(name, "mem_write16") == 0) {
        return 17
    }
    if (strcmp(name, "mem_read32") == 0) {
        return 18
    }
    if (strcmp(name, "mem_write32") == 0) {
        return 19
    }
    if (strcmp(name, "port_in8") == 0) {
        return 20
    }
    if (strcmp(name, "port_in16") == 0) {
        return 21
    }
    if (strcmp(name, "port_in32") == 0) {
        return 22
    }
    if (strcmp(name, "port_out8") == 0) {
        return 23
    }
    if (strcmp(name, "port_out16") == 0) {
        return 24
    }
    if (strcmp(name, "port_out32") == 0) {
        return 25
    }
    if (strcmp(name, "addr") == 0) {
        return 26
    }
    if (strcmp(name, "cpu_read_cr0") == 0) {
        return 27
    }
    if (strcmp(name, "cpu_write_cr0") == 0) {
        return 28
    }
    if (strcmp(name, "cpu_read_cr2") == 0) {
        return 29
    }
    if (strcmp(name, "cpu_read_cr3") == 0) {
        return 30
    }
    if (strcmp(name, "cpu_write_cr3") == 0) {
        return 31
    }
    if (strcmp(name, "cpu_read_cr4") == 0) {
        return 32
    }
    if (strcmp(name, "cpu_write_cr4") == 0) {
        return 33
    }
    if (strcmp(name, "cpu_invlpg") == 0) {
        return 34
    }
    if (strcmp(name, "cpu_lgdt") == 0) {
        return 35
    }
    if (strcmp(name, "cpu_lidt") == 0) {
        return 36
    }
    if (strcmp(name, "cpu_ltr") == 0) {
        return 37
    }
    if (strcmp(name, "cpu_rdmsr") == 0) {
        return 38
    }
    if (strcmp(name, "cpu_wrmsr") == 0) {
        return 39
    }
    if (strcmp(name, "cpu_rdtsc") == 0) {
        return 40
    }
    if (strcmp(name, "cpuid_eax") == 0) {
        return 41
    }
    if (strcmp(name, "cpuid_ebx") == 0) {
        return 42
    }
    if (strcmp(name, "cpuid_ecx") == 0) {
        return 43
    }
    if (strcmp(name, "cpuid_edx") == 0) {
        return 44
    }
    if (strcmp(name, "cpu_read_rflags") == 0) {
        return 45
    }
    if (strcmp(name, "cpu_write_rflags") == 0) {
        return 46
    }
    if (strcmp(name, "cpu_swapgs") == 0) {
        return 47
    }
    if (strcmp(name, "cpu_iretq") == 0) {
        return 48
    }
    if (strcmp(name, "cpu_int3") == 0) {
        return 49
    }
    if (strcmp(name, "cpu_pause") == 0) {
        return 50
    }
    if (strcmp(name, "cpu_cli") == 0) {
        return 51
    }
    if (strcmp(name, "cpu_sti") == 0) {
        return 52
    }
    if (strcmp(name, "cpu_hlt") == 0) {
        return 53
    }
    if (strcmp(name, "cpu_read_rsp") == 0) {
        return 54
    }
    if (strcmp(name, "cpu_write_rsp") == 0) {
        return 55
    }
    if (strcmp(name, "cpu_read_rbp") == 0) {
        return 56
    }
    if (strcmp(name, "cpu_write_rbp") == 0) {
        return 57
    }
    if (strcmp(name, "cpu_jump") == 0) {
        return 58
    }
    if (strcmp(name, "cpu_call") == 0) {
        return 59
    }
    if (strcmp(name, "fn_offset") == 0) {
        return 60
    }
    if (strcmp(name, "code_offset") == 0) {
        return 61
    }
    if (strcmp(name, "os_read") == 0) { return 62 }
    if (strcmp(name, "os_write") == 0) { return 63 }
    if (strcmp(name, "os_seek") == 0) { return 64 }
    if (strcmp(name, "map") == 0) { return 65 }
    if (strcmp(name, "unmap") == 0) { return 66 }
    if (strcmp(name, "getpid") == 0) { return 67 }
    if (strcmp(name, "net_socket") == 0) { return 68 }
    if (strcmp(name, "net_connect") == 0) { return 69 }
    if (strcmp(name, "net_accept") == 0) { return 70 }
    if (strcmp(name, "net_sendto") == 0) { return 71 }
    if (strcmp(name, "net_recvfrom") == 0) { return 72 }
    if (strcmp(name, "net_shutdown") == 0) { return 73 }
    if (strcmp(name, "net_bind") == 0) { return 74 }
    if (strcmp(name, "net_listen") == 0) { return 75 }
    if (strcmp(name, "net_setsockopt") == 0) { return 76 }
    if (strcmp(name, "net_poll") == 0) { return 77 }
    if (strcmp(name, "fork") == 0) { return 78 }
    if (strcmp(name, "execve") == 0) { return 79 }
    if (strcmp(name, "wait4") == 0) { return 80 }
    if (strcmp(name, "os_abi") == 0) { return 81 }
    if (strcmp(name, "exit") == 0) { return 82 }
    if (strcmp(name, "syscall0") == 0) { return 83 }
    if (strcmp(name, "syscall1") == 0) { return 84 }
    if (strcmp(name, "syscall2") == 0) { return 85 }
    if (strcmp(name, "syscall3") == 0) { return 86 }
    if (strcmp(name, "syscall4") == 0) { return 87 }
    if (strcmp(name, "syscall5") == 0) { return 88 }
    if (strcmp(name, "syscall6") == 0) { return 89 }
    if (strcmp(name, "sizeof") == 0) { return 90 }
    if (strcmp(name, "cast") == 0) { return 91 }
    if (strcmp(name, "gfx_open") == 0) { return 114 }
    if (strcmp(name, "gfx_close") == 0) { return 115 }
    if (strcmp(name, "gfx_buffer") == 0) { return 116 }
    if (strcmp(name, "gfx_width") == 0) { return 117 }
    if (strcmp(name, "gfx_height") == 0) { return 118 }
    if (strcmp(name, "gfx_pitch") == 0) { return 119 }
    if (strcmp(name, "gfx_clear") == 0) { return 120 }
    if (strcmp(name, "gfx_pixel") == 0) { return 121 }
    if (strcmp(name, "gfx_line") == 0) { return 122 }
    if (strcmp(name, "gfx_rect_fill") == 0) { return 123 }
    if (strcmp(name, "gfx_bind_target") == 0) { return 124 }
    if (strcmp(name, "gfx_present") == 0) { return 125 }
    if (strcmp(name, "gfx_rgb") == 0) { return 126 }
    if (strcmp(name, "gfx_rgba") == 0) { return 127 }
    if (strcmp(name, "gfx_save_bmp") == 0) { return 128 }
    if (strcmp(name, "safe_alloc") == 0) { return 92 }
    if (strcmp(name, "safe_free") == 0) { return 93 }
    if (strcmp(name, "safe_len") == 0) { return 94 }
    if (strcmp(name, "safe_read8") == 0) { return 95 }
    if (strcmp(name, "safe_write8") == 0) { return 96 }
    if (strcmp(name, "safe_read16") == 0) { return 97 }
    if (strcmp(name, "safe_write16") == 0) { return 98 }
    if (strcmp(name, "safe_read32") == 0) { return 99 }
    if (strcmp(name, "safe_write32") == 0) { return 100 }
    if (strcmp(name, "safe_read64") == 0) { return 101 }
    if (strcmp(name, "safe_write64") == 0) { return 102 }
    if (strcmp(name, "safe_calloc") == 0) { return 103 }
    if (strcmp(name, "safe_realloc") == 0) { return 104 }
    if (strcmp(name, "mem_find8") == 0) { return 105 }
    if (strcmp(name, "fnv1a64") == 0) { return 106 }
    if (strcmp(name, "safe_read_be16") == 0) { return 107 }
    if (strcmp(name, "safe_read_be32") == 0) { return 108 }
    if (strcmp(name, "safe_write_be16") == 0) { return 109 }
    if (strcmp(name, "safe_write_be32") == 0) { return 110 }
    if (strcmp(name, "safe_find8") == 0) { return 111 }
    if (strcmp(name, "input_char") == 0) { return 112 }
    if (strcmp(name, "input_line") == 0) { return 113 }
    if (strcmp(name, "math_abs") == 0) { return 129 }
    if (strcmp(name, "math_sqrt") == 0) { return 130 }
    if (strcmp(name, "math_min") == 0) { return 131 }
    if (strcmp(name, "math_max") == 0) { return 132 }
    if (strcmp(name, "math_clamp") == 0) { return 133 }
    if (strcmp(name, "math_lerp") == 0) { return 134 }
    if (strcmp(name, "math_hypot") == 0) { return 135 }
    if (strcmp(name, "math_inv_sqrt") == 0) { return 136 }
    if (strcmp(name, "math_pi") == 0) { return 137 }
    if (strcmp(name, "math_tau") == 0) { return 138 }
    if (strcmp(name, "math_e") == 0) { return 139 }
    if (strcmp(name, "math_sin") == 0) { return 140 }
    if (strcmp(name, "math_cos") == 0) { return 141 }
    if (strcmp(name, "math_atan2") == 0) { return 142 }
    if (strcmp(name, "math_deg_to_rad") == 0) { return 143 }
    if (strcmp(name, "math_rad_to_deg") == 0) { return 144 }
    if (strcmp(name, "time_unix_s") == 0) { return 145 }
    if (strcmp(name, "time_monotonic_ns") == 0) { return 146 }
    if (strcmp(name, "time_monotonic_us") == 0) { return 147 }
    if (strcmp(name, "time_monotonic_ms") == 0) { return 148 }
    if (strcmp(name, "time_monotonic_s") == 0) { return 149 }
    if (strcmp(name, "sleep_ms") == 0) { return 150 }
    return 0
}

fn parse_host_syscall_call(I64 arguments, I64 linux_number, I64 freebsd_number) {
    I64 count = 0
    I64 more = 1
    if (look_sym(41) != 0) { more = 0 }

    while (more != 0) {
        parse_expression(0)
        emit_push()
        count = count + 1
        if (count > arguments) {
            compiler_error(8)
            return 4
        }

        if (look_sym(44) != 0) {
            take()
        }
        if (look_sym(41) != 0) {
            more = 0
        }
    }

    expect_sym(41)
    if (count != arguments) {
        compiler_error(8)
        return 4
    }

    I64 i = count
    while (i > 0) {
        i = i - 1
        emit_pop_arg(i)
    }

    if (arguments >= 4) {
        out8(0x49) out8(0x89) out8(0xCA)
    }

    emit_host_syscall(linux_number, freebsd_number)
    return 4
}

fn emit_host_map_call() {

    out8(0x48) out8(0x89) out8(0xC6)

    out8(0x48) out8(0x31) out8(0xFF)

    out8(0x48) out8(0xC7) out8(0xC2) out32(3)

    out8(0x49) out8(0xC7) out8(0xC2)
    if (mem_read64(0x800598) == 2) {
        out32(0x1002)
    }
    else {
        out32(0x22)
    }

    out8(0x49) out8(0xC7) out8(0xC0) out32(0xFFFFFFFF)
    out8(0x4D) out8(0x31) out8(0xC9)
    emit_host_syscall(9, 477)
    return 4
}

fn emit_dynamic_syscall() {
    out8(0x0F)
    out8(0x05)
    emit_freebsd_syscall_error_fix()
    return 0
}

fn parse_dynamic_syscall_call(I64 arguments) {
    I64 total = arguments + 1
    I64 count = 0
    I64 more = 1
    if (look_sym(41) != 0) { more = 0 }

    while (more != 0) {
        parse_expression(0)
        emit_push()
        count = count + 1
        if (count > total) {
            compiler_error(8)
            return 4
        }
        if (look_sym(44) != 0) { take() }
        if (look_sym(41) != 0) { more = 0 }
    }

    expect_sym(41)
    if (count != total) {
        compiler_error(8)
        return 4
    }

    I64 i = arguments
    while (i > 0) {
        i = i - 1
        emit_pop_arg(i)
    }

    out8(0x58)
    if (arguments >= 4) {

        out8(0x49) out8(0x89) out8(0xCA)
    }
    emit_dynamic_syscall()
    return 4
}

fn emit_value_to_bool(I64 type) {
    if (type == 9) {
        return emit_convert_type(9, 10)
    }
    return emit_normalize_type(10)
}

fn emit_jnz() {
    out8(0x48) out8(0x85) out8(0xC0) out8(0x0F) out8(0x85)
    I64 patch = tell()
    out32(0)
    return patch
}

fn emit_bit_not(I64 type) {
    out8(0x48) out8(0xF7) out8(0xD0)
    emit_normalize_type(type)
    return type
}

fn unsafe_depth_addr() { return 0x800600 }

fn unsafe_depth() { return mem_read64(unsafe_depth_addr()) }

fn unsafe_enter() {
    mem_write64(unsafe_depth_addr(), unsafe_depth() + 1)
    return unsafe_depth()
}

fn unsafe_leave() {
    I64 depth = unsafe_depth()
    if (depth > 0) { mem_write64(unsafe_depth_addr(), depth - 1) }
    return unsafe_depth()
}

fn require_unsafe_memory() {
    if (mem_read64(os_safe_mode_addr()) == 0) { return 1 }
    if (unsafe_depth() > 0) { return 1 }
    compiler_error(22)
    return 0
}

fn parse_runtime_args(I64 arguments) {
    I64 count = 0
    I64 more = 1
    if (look_sym(41) != 0) { more = 0 }

    while (more != 0) {
        parse_expression(0)
        emit_push()
        count = count + 1
        if (count > arguments) {
            compiler_error(8)
            return 0
        }
        if (look_sym(44) != 0) { take() }
        if (look_sym(41) != 0) { more = 0 }
    }

    expect_sym(41)
    if (count != arguments) {
        compiler_error(8)
        return 0
    }

    I64 i = count
    while (i > 0) {
        i = i - 1
        emit_pop_arg(i)
    }
    return 1
}

fn parse_runtime_f64_args(I64 arguments) {
    I64 count = 0
    I64 more = 1
    if (look_sym(41) != 0) { more = 0 }

    while (more != 0) {
        I64 type = parse_expression(0)
        emit_convert_type(type, 9)
        emit_push()
        count = count + 1
        if (count > arguments) {
            compiler_error(8)
            return 0
        }
        if (look_sym(44) != 0) { take() }
        if (look_sym(41) != 0) { more = 0 }
    }

    expect_sym(41)
    if (count != arguments) {
        compiler_error(8)
        return 0
    }

    I64 i = count
    while (i > 0) {
        i = i - 1
        emit_pop_arg(i)
    }
    return 1
}

fn emit_safe_trap() {

    out8(0x48) out8(0xC7) out8(0xC7) out32(101)
    emit_host_syscall(60, 1)
    out8(0x0F) out8(0x0B)
    return 0
}

fn emit_jcc32(I64 opcode) {
    out8(0x0F) out8(opcode)
    I64 patch = tell()
    out32(0)
    return patch
}

fn emit_safe_validate() {
    I64 fail_null = 0
    I64 fail_magic = 0
    I64 fail_guard = 0
    I64 fail_tail = 0

    out8(0x48) out8(0x89) out8(0xC7)
    out8(0x48) out8(0x85) out8(0xC0)
    fail_null = emit_jcc32(0x84)
    out8(0x48) out8(0x83) out8(0xE8) out8(32)

    out8(0x48) out8(0x81) out8(0x38) out32(0x4D434D31)
    fail_magic = emit_jcc32(0x85)
    out8(0x48) out8(0x81) out8(0x78) out8(24) out32(0x4D434D32)
    fail_guard = emit_jcc32(0x85)

    out8(0x48) out8(0x8B) out8(0x48) out8(8)
    out8(0x48) out8(0x8D) out8(0x14) out8(0x0F)
    out8(0x48) out8(0x81) out8(0x3A) out32(0x4D434D33)
    fail_tail = emit_jcc32(0x85)

    I64 ok_jump = emit_jmp()
    I64 fail_target = tell()
    patch_rel(fail_null, fail_target)
    patch_rel(fail_magic, fail_target)
    patch_rel(fail_guard, fail_target)
    patch_rel(fail_tail, fail_target)
    emit_safe_trap()
    patch_rel(ok_jump, tell())
    return 0
}

fn emit_safe_alloc_call() {
    out8(0x48) out8(0x85) out8(0xC0)
    I64 nonzero = emit_jcc32(0x85)
    emit_imm(1)
    patch_rel(nonzero, tell())

    out8(0x48) out8(0x89) out8(0xC1)
    out8(0x48) out8(0x83) out8(0xC1) out8(40)
    I64 overflow = emit_jcc32(0x82)
    out8(0x50)
    out8(0x48) out8(0x89) out8(0xCE)
    out8(0x48) out8(0x31) out8(0xFF)
    out8(0x48) out8(0xC7) out8(0xC2) out32(3)
    out8(0x49) out8(0xC7) out8(0xC2)
    if (mem_read64(0x800598) == 2) { out32(0x1002) }
    else { out32(0x22) }
    out8(0x49) out8(0xC7) out8(0xC0) out32(0xFFFFFFFF)
    out8(0x4D) out8(0x31) out8(0xC9)
    emit_host_syscall(9, 477)
    out8(0x5A)
    out8(0x48) out8(0x85) out8(0xC0)
    I64 map_failed = emit_jcc32(0x88)

    out8(0x48) out8(0xC7) out8(0x00) out32(0x4D434D31)
    out8(0x48) out8(0x89) out8(0x50) out8(8)
    out8(0x48) out8(0x89) out8(0xD1)
    out8(0x48) out8(0x83) out8(0xC1) out8(40)
    out8(0x48) out8(0x89) out8(0x48) out8(16)
    out8(0x48) out8(0xC7) out8(0x40) out8(24) out32(0x4D434D32)
    out8(0x48) out8(0x8D) out8(0x4C) out8(0x10) out8(32)
    out8(0x48) out8(0xC7) out8(0x01) out32(0x4D434D33)
    out8(0x48) out8(0x83) out8(0xC0) out8(32)
    I64 done = emit_jmp()

    I64 fail_target = tell()
    patch_rel(overflow, fail_target)
    patch_rel(map_failed, fail_target)
    emit_imm(0)
    patch_rel(done, tell())
    return 8
}

fn emit_safe_bounds(I64 width) {

    out8(0x48) out8(0x85) out8(0xF6)
    I64 negative = emit_jcc32(0x88)
    out8(0x48) out8(0x89) out8(0xCA)
    if (width > 1) {
        out8(0x48) out8(0x83) out8(0xEA) out8(width)
        I64 too_small = emit_jcc32(0x82)
        out8(0x48) out8(0x39) out8(0xD6)
        I64 too_large = emit_jcc32(0x87)
        I64 ok = emit_jmp()
        I64 fail_target = tell()
        patch_rel(negative, fail_target)
        patch_rel(too_small, fail_target)
        patch_rel(too_large, fail_target)
        emit_safe_trap()
        patch_rel(ok, tell())
        return 0
    }

    out8(0x48) out8(0x39) out8(0xCE)
    I64 out_of_range = emit_jcc32(0x83)
    I64 ok2 = emit_jmp()
    I64 fail_target2 = tell()
    patch_rel(negative, fail_target2)
    patch_rel(out_of_range, fail_target2)
    emit_safe_trap()
    patch_rel(ok2, tell())
    return 0
}

fn emit_safe_read(I64 width) {

    out8(0x48) out8(0x89) out8(0xF8)
    emit_safe_validate()
    emit_safe_bounds(width)
    if (width == 1) { out8(0x48) out8(0x0F) out8(0xB6) out8(0x04) out8(0x37) return 5 }
    if (width == 2) { out8(0x48) out8(0x0F) out8(0xB7) out8(0x04) out8(0x37) return 6 }
    if (width == 4) { out8(0x8B) out8(0x04) out8(0x37) return 7 }
    out8(0x48) out8(0x8B) out8(0x04) out8(0x37)
    return 8
}

fn emit_safe_write(I64 width) {

    out8(0x49) out8(0x89) out8(0xD0)
    out8(0x48) out8(0x89) out8(0xF8)
    emit_safe_validate()
    emit_safe_bounds(width)
    if (width == 1) { out8(0x44) out8(0x88) out8(0x04) out8(0x37) }
    if (width == 2) { out8(0x66) out8(0x44) out8(0x89) out8(0x04) out8(0x37) }
    if (width == 4) { out8(0x44) out8(0x89) out8(0x04) out8(0x37) }
    if (width == 8) { out8(0x4C) out8(0x89) out8(0x04) out8(0x37) }
    out8(0x4C) out8(0x89) out8(0xC0)
    return 8
}

fn emit_safe_free_call() {

    out8(0x48) out8(0x85) out8(0xC0)
    I64 nonnull = emit_jcc32(0x85)
    emit_imm(0)
    I64 done = emit_jmp()
    patch_rel(nonnull, tell())
    emit_safe_validate()
    out8(0x48) out8(0x8B) out8(0x70) out8(16)
    out8(0x48) out8(0x89) out8(0xC7)
    emit_host_syscall(11, 73)
    patch_rel(done, tell())
    return 4
}

fn emit_safe_calloc_call() {

    out8(0x48) out8(0x89) out8(0xF8)
    out8(0x48) out8(0xF7) out8(0xE6)
    out8(0x48) out8(0x85) out8(0xD2)
    I64 ok = emit_jcc32(0x84)
    emit_safe_trap()
    patch_rel(ok, tell())
    return emit_safe_alloc_call()
}

fn emit_safe_realloc_call() {

    out8(0x48) out8(0x85) out8(0xFF)
    I64 have_old = emit_jcc32(0x85)
    out8(0x48) out8(0x89) out8(0xF0)
    emit_safe_alloc_call()
    I64 done_from_null = emit_jmp()

    patch_rel(have_old, tell())
    out8(0x48) out8(0x85) out8(0xF6)
    I64 nonzero_size = emit_jcc32(0x85)
    out8(0x48) out8(0x89) out8(0xF8)
    emit_safe_free_call()
    emit_imm(0)
    I64 done_zero = emit_jmp()

    patch_rel(nonzero_size, tell())

    out8(0x57)
    out8(0x56)
    out8(0x48) out8(0x89) out8(0xF8)
    emit_safe_validate()
    out8(0x51)
    out8(0x5A)
    out8(0x5E)
    out8(0x5F)

    out8(0x57)
    out8(0x56)
    out8(0x52)
    out8(0x48) out8(0x89) out8(0xF0)
    emit_safe_alloc_call()
    out8(0x49) out8(0x89) out8(0xC1)
    out8(0x5A)
    out8(0x5E)
    out8(0x5F)

    out8(0x4D) out8(0x85) out8(0xC9)
    I64 allocation_failed = emit_jcc32(0x84)

    out8(0x48) out8(0x89) out8(0xD1)
    out8(0x48) out8(0x39) out8(0xF2)
    out8(0x48) out8(0x0F) out8(0x47) out8(0xCE)
    out8(0x49) out8(0x89) out8(0xF8)
    out8(0x4C) out8(0x89) out8(0xCF)
    out8(0x4C) out8(0x89) out8(0xC6)
    out8(0xFC)
    out8(0xF3) out8(0xA4)

    out8(0x4C) out8(0x89) out8(0xC7)
    out8(0x48) out8(0x83) out8(0xEF) out8(32)
    out8(0x48) out8(0x8B) out8(0x77) out8(16)
    emit_host_syscall(11, 73)
    out8(0x4C) out8(0x89) out8(0xC8)
    I64 done_success = emit_jmp()

    patch_rel(allocation_failed, tell())
    emit_imm(0)

    I64 final_target = tell()
    patch_rel(done_from_null, final_target)
    patch_rel(done_zero, final_target)
    patch_rel(done_success, final_target)
    return 8
}

fn emit_mem_find8_code() {

    out8(0x49) out8(0x89) out8(0xF0)
    out8(0x48) out8(0x85) out8(0xF6)
    I64 empty = emit_jcc32(0x84)
    out8(0x48) out8(0x89) out8(0xD0)
    out8(0x48) out8(0x89) out8(0xF1)
    out8(0xFC)
    out8(0xF2) out8(0xAE)
    I64 not_found = emit_jcc32(0x85)
    out8(0x4C) out8(0x89) out8(0xC0)
    out8(0x48) out8(0x29) out8(0xC8)
    out8(0x48) out8(0xFF) out8(0xC8)
    I64 done = emit_jmp()
    I64 miss = tell()
    patch_rel(empty, miss)
    patch_rel(not_found, miss)
    out8(0x48) out8(0xC7) out8(0xC0) out32(0xFFFFFFFF)
    patch_rel(done, tell())
    return 4
}

fn emit_fnv1a64_code() {

    out8(0x48) out8(0xB8) out64(0xCBF29CE484222325)
    out8(0x48) out8(0x31) out8(0xC9)
    I64 loop = tell()
    out8(0x48) out8(0x39) out8(0xF1)
    I64 done = emit_jcc32(0x83)
    out8(0x48) out8(0x0F) out8(0xB6) out8(0x14) out8(0x0F)
    out8(0x48) out8(0x31) out8(0xD0)
    out8(0x48) out8(0xBA) out64(1099511628211)
    out8(0x48) out8(0x0F) out8(0xAF) out8(0xC2)
    out8(0x48) out8(0xFF) out8(0xC1)
    I64 back = emit_jmp()
    patch_rel(back, loop)
    patch_rel(done, tell())
    return 8
}

fn emit_safe_read_be16() {
    emit_safe_read(2)
    out8(0x66) out8(0xC1) out8(0xC0) out8(8)
    out8(0x48) out8(0x0F) out8(0xB7) out8(0xC0)
    return 6
}

fn emit_safe_read_be32() {
    emit_safe_read(4)
    out8(0x0F) out8(0xC8)
    out8(0x89) out8(0xC0)
    return 7
}

fn emit_safe_write_be16() {
    out8(0x66) out8(0xC1) out8(0xC2) out8(8)
    return emit_safe_write(2)
}

fn emit_safe_write_be32() {
    out8(0x0F) out8(0xCA)
    return emit_safe_write(4)
}

fn emit_safe_find8() {

    out8(0x49) out8(0x89) out8(0xD0)
    out8(0x49) out8(0x89) out8(0xC9)
    out8(0x48) out8(0x89) out8(0xF8)
    emit_safe_validate()

    out8(0x48) out8(0x85) out8(0xF6)
    I64 bad_start = emit_jcc32(0x88)
    out8(0x4D) out8(0x85) out8(0xC0)
    I64 bad_count = emit_jcc32(0x88)
    out8(0x48) out8(0x39) out8(0xCE)
    I64 start_past_end = emit_jcc32(0x87)

    out8(0x4C) out8(0x89) out8(0xC2)
    out8(0x48) out8(0x01) out8(0xF2)
    I64 range_overflow = emit_jcc32(0x82)
    out8(0x48) out8(0x39) out8(0xCA)
    I64 range_past_end = emit_jcc32(0x87)
    I64 checked = emit_jmp()

    I64 fail_target = tell()
    patch_rel(bad_start, fail_target)
    patch_rel(bad_count, fail_target)
    patch_rel(start_past_end, fail_target)
    patch_rel(range_overflow, fail_target)
    patch_rel(range_past_end, fail_target)
    emit_safe_trap()
    patch_rel(checked, tell())

    out8(0x4D) out8(0x85) out8(0xC0)
    I64 have_data = emit_jcc32(0x85)
    emit_imm(0 - 1)
    I64 done_empty = emit_jmp()
    patch_rel(have_data, tell())

    out8(0x49) out8(0x89) out8(0xFA)
    out8(0x48) out8(0x01) out8(0xF7)
    out8(0x4C) out8(0x89) out8(0xC1)
    out8(0x4C) out8(0x89) out8(0xC8)
    out8(0xFC)
    out8(0xF2) out8(0xAE)
    I64 not_found = emit_jcc32(0x85)
    out8(0x48) out8(0x89) out8(0xF8)
    out8(0x4C) out8(0x29) out8(0xD0)
    out8(0x48) out8(0xFF) out8(0xC8)
    I64 done_found = emit_jmp()

    patch_rel(not_found, tell())
    emit_imm(0 - 1)
    I64 done = tell()
    patch_rel(done_empty, done)
    patch_rel(done_found, done)
    return 4
}

fn emit_prolog() {
    out8(0x55) out8(0x48) out8(0x89) out8(0xE5) out8(0x48) out8(0x81) out8(0xEC) out32(0x4000)
    return 0
}

fn emit_epilog() {
    out8(0xC9) out8(0xC3)
    return 0
}

fn emit_main_exit0() {
    out8(0x48)
    out8(0x31)
    out8(0xFF)

    out8(0x48)
    out8(0xC7)
    out8(0xC0)

    if (mem_read64(0x800598) == 2) {
        out32(1)
    }
    else {
        out32(60)
    }

    out8(0x0F)
    out8(0x05)
    return 0
}

fn emit_main_exit_rax() {
    out8(0x48)
    out8(0x89)
    out8(0xC7)

    out8(0x48)
    out8(0xC7)
    out8(0xC0)

    if (mem_read64(0x800598) == 2) {
        out32(1)
    }
    else {
        out32(60)
    }

    out8(0x0F)
    out8(0x05)
    return 0
}

fn emit_raw_halt() {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    os_file_write8(mem_read64(0x800008), 0xFA)
    os_file_write8(mem_read64(0x800008), 0xF4)
    os_file_write8(mem_read64(0x800008), 0xEB)
    os_file_write8(mem_read64(0x800008), 0xFD)
    mem_write64(0x800090, mem_read64(0x800090) + 4)
    return 0
}

fn emit_imm(I64 value) {
    out8(0x48) out8(0xB8) out64(value)
    return value
}

fn emit_push() {
    out8(0x50)
    return 0
}

fn emit_pop_arg(I64 index) {
    if (index == 0) {
        out8(0x5F) return 0
    }
    if (index == 1) {
        out8(0x5E) return 0
    }
    if (index == 2) {
        out8(0x5A) return 0
    }
    if (index == 3) {
        out8(0x59) return 0
    }
    if (index == 4) {
        out8(0x41) out8(0x58) return 0
    }
    if (index == 5) {
        out8(0x41) out8(0x59) return 0
    }
    fail()
    return 0
}

fn emit_normalize_type(I64 type) {
    if (type == 1) {
        out8(0x48) out8(0x0F) out8(0xBE) out8(0xC0)
        return type
    }
    if (type == 2) {
        out8(0x48) out8(0x0F) out8(0xBF) out8(0xC0)
        return type
    }
    if (type == 3) {
        out8(0x48) out8(0x63) out8(0xC0)
        return type
    }
    if (type == 5) {
        out8(0x0F) out8(0xB6) out8(0xC0)
        return type
    }
    if (type == 6) {
        out8(0x0F) out8(0xB7) out8(0xC0)
        return type
    }
    if (type == 7) {
        out8(0x89) out8(0xC0)
        return type
    }
    if (type == 10) {
        out8(0x48) out8(0x85) out8(0xC0) out8(0x0F) out8(0x95) out8(0xC0) out8(0x48) out8(0x0F) out8(0xB6) out8(0xC0)
        return type
    }
    return type
}

fn emit_u64_to_f64() {
    out8(0x48) out8(0x85) out8(0xC0) out8(0x0F) out8(0x89)
    I64 simple = tell()
    out32(0)

    out8(0x48) out8(0x89) out8(0xC1) out8(0x48) out8(0x83) out8(0xE0) out8(1) out8(0x48) out8(0xD1) out8(0xE9) out8(0x48) out8(0x09) out8(0xC1) out8(0xF2) out8(0x48) out8(0x0F) out8(0x2A) out8(0xC1) out8(0xF2) out8(0x0F) out8(0x58) out8(0xC0) out8(0x66) out8(0x48) out8(0x0F) out8(0x7E) out8(0xC0)
    I64 done = emit_jmp()

    patch_rel(simple, tell())
    out8(0xF2) out8(0x48) out8(0x0F) out8(0x2A) out8(0xC0) out8(0x66) out8(0x48) out8(0x0F) out8(0x7E) out8(0xC0)

    patch_rel(done, tell())
    return 9
}

fn emit_convert_type(I64 source, I64 target) {
    if (source == target) {
        return target
    }

    if (target == 9) {
        if (source == 8) {
            emit_u64_to_f64()
            return target
        }
        out8(0xF2) out8(0x48) out8(0x0F) out8(0x2A) out8(0xC0) out8(0x66) out8(0x48) out8(0x0F) out8(0x7E) out8(0xC0)
        return target
    }

    if (source == 9) {
        if (target == 10) {
            out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xC0) out8(0x66) out8(0x0F) out8(0xEF) out8(0xC9) out8(0x66) out8(0x0F) out8(0x2E) out8(0xC1) out8(0x0F) out8(0x95) out8(0xC0) out8(0x48) out8(0x0F) out8(0xB6) out8(0xC0)
            return target
        }
        out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xC0) out8(0xF2) out8(0x48) out8(0x0F) out8(0x2C) out8(0xC0)
        emit_normalize_type(target)
        return target
    }

    emit_normalize_type(target)
    return target
}

fn emit_load_var(I64 index) {
    I64 displacement = 0 - index * 8
    out8(0x48) out8(0x8B) out8(0x85) out32(displacement)
    return index
}

fn emit_store_var(I64 index) {
    I64 displacement = 0 - index * 8
    out8(0x48) out8(0x89) out8(0x85) out32(displacement)
    return index
}

fn emit_arg_to_rax(I64 argument) {
    if (argument == 0) {
        out8(0x48) out8(0x89) out8(0xF8) return 0
    }
    if (argument == 1) {
        out8(0x48) out8(0x89) out8(0xF0) return 0
    }
    if (argument == 2) {
        out8(0x48) out8(0x89) out8(0xD0) return 0
    }
    if (argument == 3) {
        out8(0x48) out8(0x89) out8(0xC8) return 0
    }
    if (argument == 4) {
        out8(0x4C) out8(0x89) out8(0xC0) return 0
    }
    if (argument == 5) {
        out8(0x4C) out8(0x89) out8(0xC8) return 0
    }
    fail()
    return 0
}

fn emit_store_arg_typed(I64 index, I64 argument, I64 type) {
    emit_arg_to_rax(argument)
    if (type != 9) {
        emit_normalize_type(type)
    }
    emit_store_var(index)
    return index
}

fn emit_jz() {
    out8(0x48) out8(0x85) out8(0xC0) out8(0x0F) out8(0x84)
    I64 patch = tell()
    out32(0)
    return patch
}

fn emit_jmp() {
    out8(0xE9)
    I64 patch = tell()
    out32(0)
    return patch
}

fn patch_rel(I64 patch, I64 target) {
    return patch32_at(patch, target - patch - 4)
}

fn emit_call_placeholder() {
    out8(0xE8)
    I64 patch = tell()
    out32(0)
    return patch
}

fn emit_float_literal(I64 numerator, I64 scale) {
    emit_imm(numerator)
    out8(0xF2) out8(0x48) out8(0x0F) out8(0x2A) out8(0xC0)

    if (scale != 1) {
        emit_imm(scale)
        out8(0xF2) out8(0x48) out8(0x0F) out8(0x2A) out8(0xC8) out8(0xF2) out8(0x0F) out8(0x5E) out8(0xC1)
    }

    out8(0x66) out8(0x48) out8(0x0F) out8(0x7E) out8(0xC0)
    return 9
}

fn emit_neg_value(I64 type) {
    if (type == 9) {
        out8(0x48) out8(0xB9) out64(0x8000000000000000)
        out8(0x48) out8(0x31) out8(0xC8)
        return type
    }
    out8(0x48) out8(0xF7) out8(0xD8)
    emit_normalize_type(type)
    return type
}

fn emit_float_binary(I64 op, I64 left_type, I64 right_type) {
    if (left_type == 9) {
        out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xC1)
    }
    if (left_type != 9) {
        out8(0xF2) out8(0x48) out8(0x0F) out8(0x2A) out8(0xC1)
    }

    if (right_type == 9) {
        out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xC8)
    }
    if (right_type != 9) {
        out8(0xF2) out8(0x48) out8(0x0F) out8(0x2A) out8(0xC8)
    }

    if (op == 43) {
        out8(0xF2) out8(0x0F) out8(0x58) out8(0xC1) out8(0x66) out8(0x48) out8(0x0F) out8(0x7E) out8(0xC0)
        return 9
    }
    if (op == 45) {
        out8(0xF2) out8(0x0F) out8(0x5C) out8(0xC1) out8(0x66) out8(0x48) out8(0x0F) out8(0x7E) out8(0xC0)
        return 9
    }
    if (op == 42) {
        out8(0xF2) out8(0x0F) out8(0x59) out8(0xC1) out8(0x66) out8(0x48) out8(0x0F) out8(0x7E) out8(0xC0)
        return 9
    }
    if (op == 47) {
        out8(0xF2) out8(0x0F) out8(0x5E) out8(0xC1) out8(0x66) out8(0x48) out8(0x0F) out8(0x7E) out8(0xC0)
        return 9
    }

    if (op == 37) {
        fail() emit_imm(0) return 9
    }
    if (op == 38) {
        fail() emit_imm(0) return 9
    }
    if (op == 124) {
        fail() emit_imm(0) return 9
    }
    if (op == 94) {
        fail() emit_imm(0) return 9
    }
    if (op == 1005) {
        fail() emit_imm(0) return 9
    }
    if (op == 1006) {
        fail() emit_imm(0) return 9
    }

    out8(0x66) out8(0x0F) out8(0x2E) out8(0xC1)
    if (op == 1001) {
        out8(0x0F) out8(0x94) out8(0xC0)
    }
    if (op == 1002) {
        out8(0x0F) out8(0x95) out8(0xC0)
    }
    if (op == 60) {
        out8(0x0F) out8(0x92) out8(0xC0)
    }
    if (op == 62) {
        out8(0x0F) out8(0x97) out8(0xC0)
    }
    if (op == 1003) {
        out8(0x0F) out8(0x96) out8(0xC0)
    }
    if (op == 1004) {
        out8(0x0F) out8(0x93) out8(0xC0)
    }
    out8(0x48) out8(0x0F) out8(0xB6) out8(0xC0)
    return 10
}

fn emit_binary_typed(I64 op, I64 left_type, I64 right_type) {
    out8(0x59)

    if (left_type == 9) {
        return emit_float_binary(op, left_type, right_type)
    }
    if (right_type == 9) {
        return emit_float_binary(op, left_type, right_type)
    }

    if (op == 1005) {
        I64 result_shift = left_type
        if (result_shift == 10) {
            result_shift = 4
        }

        out8(0x48) out8(0x89) out8(0xCA) out8(0x48) out8(0x89) out8(0xC1) out8(0x48) out8(0x89) out8(0xD0) out8(0x48) out8(0xD3) out8(0xE0)
        emit_normalize_type(result_shift)
        return result_shift
    }

    if (op == 1006) {
        I64 result_shift2 = left_type
        if (result_shift2 == 10) {
            result_shift2 = 4
        }

        out8(0x48) out8(0x89) out8(0xCA) out8(0x48) out8(0x89) out8(0xC1) out8(0x48) out8(0x89) out8(0xD0)

        if (type_unsigned(result_shift2) != 0) {
            out8(0x48) out8(0xD3) out8(0xE8)
        }
        if (type_unsigned(result_shift2) == 0) {
            out8(0x48) out8(0xD3) out8(0xF8)
        }

        emit_normalize_type(result_shift2)
        return result_shift2
    }

    I64 result_type = common_integer_type(left_type, right_type)

    out8(0x48) out8(0x87) out8(0xC8)
    emit_normalize_type(result_type)
    out8(0x48) out8(0x87) out8(0xC8)
    emit_normalize_type(result_type)

    if (op == 43) {
        out8(0x48) out8(0x01) out8(0xC1) out8(0x48) out8(0x89) out8(0xC8)
        emit_normalize_type(result_type)
        return result_type
    }

    if (op == 45) {
        out8(0x48) out8(0x29) out8(0xC1) out8(0x48) out8(0x89) out8(0xC8)
        emit_normalize_type(result_type)
        return result_type
    }

    if (op == 42) {
        out8(0x48) out8(0x0F) out8(0xAF) out8(0xC1)
        emit_normalize_type(result_type)
        return result_type
    }

    if (op == 47) {
        out8(0x48) out8(0x87) out8(0xC8)

        if (type_unsigned(result_type) != 0) {
            out8(0x48) out8(0x31) out8(0xD2) out8(0x48) out8(0xF7) out8(0xF1)
        }
        if (type_unsigned(result_type) == 0) {
            out8(0x48) out8(0x99) out8(0x48) out8(0xF7) out8(0xF9)
        }

        emit_normalize_type(result_type)
        return result_type
    }

    if (op == 37) {
        out8(0x48) out8(0x87) out8(0xC8)

        if (type_unsigned(result_type) != 0) {
            out8(0x48) out8(0x31) out8(0xD2) out8(0x48) out8(0xF7) out8(0xF1)
        }
        if (type_unsigned(result_type) == 0) {
            out8(0x48) out8(0x99) out8(0x48) out8(0xF7) out8(0xF9)
        }

        out8(0x48) out8(0x89) out8(0xD0)
        emit_normalize_type(result_type)
        return result_type
    }

    if (op == 38) {
        out8(0x48) out8(0x21) out8(0xC1) out8(0x48) out8(0x89) out8(0xC8)
        emit_normalize_type(result_type)
        return result_type
    }

    if (op == 124) {
        out8(0x48) out8(0x09) out8(0xC1) out8(0x48) out8(0x89) out8(0xC8)
        emit_normalize_type(result_type)
        return result_type
    }

    if (op == 94) {
        out8(0x48) out8(0x31) out8(0xC1) out8(0x48) out8(0x89) out8(0xC8)
        emit_normalize_type(result_type)
        return result_type
    }

    out8(0x48) out8(0x39) out8(0xC1)

    if (op == 1001) {
        out8(0x0F) out8(0x94) out8(0xC0)
    }
    if (op == 1002) {
        out8(0x0F) out8(0x95) out8(0xC0)
    }

    if (type_unsigned(result_type) != 0) {
        if (op == 60) {
            out8(0x0F) out8(0x92) out8(0xC0)
        }
        if (op == 62) {
            out8(0x0F) out8(0x97) out8(0xC0)
        }
        if (op == 1003) {
            out8(0x0F) out8(0x96) out8(0xC0)
        }
        if (op == 1004) {
            out8(0x0F) out8(0x93) out8(0xC0)
        }
    }

    if (type_unsigned(result_type) == 0) {
        if (op == 60) {
            out8(0x0F) out8(0x9C) out8(0xC0)
        }
        if (op == 62) {
            out8(0x0F) out8(0x9F) out8(0xC0)
        }
        if (op == 1003) {
            out8(0x0F) out8(0x9E) out8(0xC0)
        }
        if (op == 1004) {
            out8(0x0F) out8(0x9D) out8(0xC0)
        }
    }

    out8(0x48) out8(0x0F) out8(0xB6) out8(0xC0)
    return 10
}

fn precedence(I64 op) {
    if (op == 1008) { return 1 }
    if (op == 1007) { return 2 }
    if (op == 1001) { return 3 }
    if (op == 1002) { return 3 }
    if (op == 60) { return 3 }
    if (op == 62) { return 3 }
    if (op == 1003) { return 3 }
    if (op == 1004) { return 3 }
    if (op == 124) { return 4 }
    if (op == 94) { return 5 }
    if (op == 38) { return 6 }
    if (op == 1005) { return 7 }
    if (op == 1006) { return 7 }
    if (op == 43) { return 8 }
    if (op == 45) { return 8 }
    if (op == 42) { return 9 }
    if (op == 47) { return 9 }
    if (op == 37) { return 9 }
    return 0
}

fn reset_vars() {
    mem_write64(0x800048, 0)
    return 0
}

fn var_entry(I64 index) {
    return 0x828000 + (index - 1) * 24
}

fn var_type(I64 index) {
    if (index <= 0) { return 4 }
    return mem_read64(var_entry(index) + 8)
}

fn var_is_const(I64 index) {
    if (index <= 0) { return 0 }
    return mem_read64(var_entry(index) + 16)
}

fn var_set_const(I64 index, I64 value) {
    if (index <= 0) { return 0 }
    mem_write64(var_entry(index) + 16, value)
    return value
}

fn find_var(I64 hash) {
    I64 count = mem_read64(0x800048)
    I64 i = 0
    while (i < count) {
        I64 entry = 0x828000 + i * 24
        if (mem_read64(entry) == hash) { return i + 1 }
        i = i + 1
    }
    return 0
}

fn register_var(I64 hash, I64 type) {
    I64 found = find_var(hash)
    if (found != 0) {
        compiler_error(5)
        return 0
    }

    I64 count = mem_read64(0x800048)
    if (count >= 1024) {
        fail() return 0
    }

    I64 entry = 0x828000 + count * 24
    mem_write64(entry, hash)
    mem_write64(entry + 8, type)
    mem_write64(entry + 16, 0)
    mem_write64(0x800048, count + 1)
    return count + 1
}

fn register_function(I64 hash, I64 position, I64 params) {
    I64 duplicate = find_function(hash)
    if (duplicate != 0) {
        compiler_error(9)
        return 0
    }

    I64 count = mem_read64(0x800038)
    if (count >= 1024) {
        fail() return 0
    }

    I64 entry = 0x780000 + count * 24
    mem_write64(entry, hash)
    mem_write64(entry + 8, position)
    mem_write64(entry + 16, params)
    mem_write64(0x800038, count + 1)
    return position
}

fn find_function(I64 hash) {
    I64 count = mem_read64(0x800038)
    I64 i = 0
    while (i < count) {
        I64 entry = 0x780000 + i * 24
        if (mem_read64(entry) == hash) {
            return mem_read64(entry + 8)
        }
        i = i + 1
    }
    return 0
}

fn find_function_params(I64 hash) {
    I64 count = mem_read64(0x800038)
    I64 i = 0
    while (i < count) {
        I64 entry = 0x780000 + i * 24
        if (mem_read64(entry) == hash) {
            return mem_read64(entry + 16)
        }
        i = i + 1
    }
    return 0 - 1
}

fn register_call(I64 hash, I64 patch, I64 arguments) {
    I64 count = mem_read64(0x800040)
    if (count >= 8192) {
        fail() return 0
    }

    I64 entry = 0x740000 + count * 24
    mem_write64(entry, hash)
    mem_write64(entry + 8, patch)
    mem_write64(entry + 16, arguments)
    mem_write64(0x800040, count + 1)
    return patch
}

fn resolve_calls() {
    I64 count = mem_read64(0x800040)
    I64 i = 0

    while (i < count) {
        I64 entry = 0x740000 + i * 24
        I64 hash = mem_read64(entry)
        I64 patch = mem_read64(entry + 8)
        I64 arguments = mem_read64(entry + 16)

        if (arguments >= 0) {
            I64 target = find_function(hash)

            if (target == 0) {
                fail() return 0
            }

            I64 expected = find_function_params(hash)
            if (arguments != expected) {
                compiler_error(8)
                return 0
            }

            patch_rel(patch, target)
        }

        if (arguments < 0) {
            I64 packed = asm_find_label(hash)
            if (packed == 0) {
                compiler_error(19)
                return 0
            }

            I64 label_position = packed - 1
            I64 logical = mem_read64(0x800510) + label_position

            if (arguments == 0 - 1) {
                I64 relative16 = label_position - patch - 2
                if (relative16 < (0 - 32768)) {
                    compiler_error(21) return 0
                }
                if (relative16 > 32767) {
                    compiler_error(21) return 0
                }
                patch16_at(patch, relative16)
            }

            if (arguments == 0 - 2) {
                I64 relative32 = label_position - patch - 4
                if (relative32 < (0 - 2147483648)) {
                    compiler_error(21) return 0
                }
                if (relative32 > 2147483647) {
                    compiler_error(21) return 0
                }
                patch32_at(patch, relative32)
            }

            if (arguments == 0 - 3) {
                if (logical < 0) {
                    compiler_error(21) return 0
                }
                if (logical > 65535) {
                    compiler_error(21) return 0
                }
                patch16_at(patch, logical)
            }

            if (arguments == 0 - 4) {
                if (logical < 0) {
                    compiler_error(21) return 0
                }
                if (logical > 0xFFFFFFFF) {
                    compiler_error(21) return 0
                }
                patch32_at(patch, logical)
            }

            if (arguments == 0 - 5) {
                patch64_at(patch, logical)
            }
        }

        i = i + 1
    }

    return 0
}

fn copy_string_pool(I64 source, I64 length) {
    I64 dest = mem_read64(0x800068)
    I64 end = dest + length + 1
    if (end > 0x900000) {
        compiler_error(11)
        return 0
    }
    I64 i = 0
    while (i < length) {
        mem_write8(dest + i, mem_read8(source + i))
        i = i + 1
    }
    mem_write8(dest + length, 0)
    mem_write64(0x800068, dest + length + 1)
    return dest
}

fn record_string(I64 patch, I64 source, I64 length) {
    I64 count = mem_read64(0x800050)
    if (count >= 512) {
        fail() return 0
    }
    I64 saved = copy_string_pool(source, length)
    if (failed() != 0) {
        return 0
    }
    I64 entry = 0x830000 + count * 24
    mem_write64(entry, patch)
    mem_write64(entry + 8, saved)
    mem_write64(entry + 16, length)
    mem_write64(0x800050, count + 1)
    return saved
}

fn emit_string_ptr(I64 source, I64 length) {
    out8(0x48) out8(0x8D) out8(0x05)
    I64 patch = tell()
    out32(0)
    record_string(patch, source, length)
    return patch
}

fn finish_strings() {
    I64 count = mem_read64(0x800050)
    I64 i = 0
    while (i < count) {
        I64 entry = 0x830000 + i * 24
        I64 patch = mem_read64(entry)
        I64 source = mem_read64(entry + 8)
        I64 length = mem_read64(entry + 16)
        I64 data = tell()
        patch_rel(patch, data)
        I64 j = 0
        while (j <= length) {
            os_file_write8(mem_read64(0x800008), mem_read8(source + j)) mem_write64(0x800090, mem_read64(0x800090) + 1)
            j = j + 1
        }
        i = i + 1
    }
    return 0
}

fn emit_freebsd_syscall_error_fix() {
    if (mem_read64(0x800598) != 2) {
        return 0
    }

    out8(0x73)
    out8(0x03)
    out8(0x48)
    out8(0xF7)
    out8(0xD8)
    return 0
}

fn emit_host_syscall(I64 linux_number, I64 freebsd_number) {
    out8(0x48)
    out8(0xC7)
    out8(0xC0)

    if (mem_read64(0x800598) == 2) {
        out32(freebsd_number)
    }
    else {
        out32(linux_number)
    }

    out8(0x0F)
    out8(0x05)
    emit_freebsd_syscall_error_fix()
    return 0
}

fn emit_freebsd_open_flag_bit(I64 linux_bit, I64 freebsd_bit) {
    out8(0x48)
    out8(0xF7)
    out8(0xC6)
    out32(linux_bit)

    out8(0x74)
    out8(0x07)

    out8(0x49)
    out8(0x81)
    out8(0xC8)
    out32(freebsd_bit)
    return 0
}

fn emit_freebsd_open_flag_translation() {
    if (mem_read64(0x800598) != 2) {
        return 0
    }

    out8(0x49)
    out8(0x89)
    out8(0xF0)

    out8(0x49)
    out8(0x83)
    out8(0xE0)
    out8(3)

    emit_freebsd_open_flag_bit(0x40, 0x200)
    emit_freebsd_open_flag_bit(0x80, 0x800)
    emit_freebsd_open_flag_bit(0x100, 0x8000)
    emit_freebsd_open_flag_bit(0x200, 0x400)
    emit_freebsd_open_flag_bit(0x400, 0x8)
    emit_freebsd_open_flag_bit(0x800, 0x4)
    emit_freebsd_open_flag_bit(0x4000, 0x10000)
    emit_freebsd_open_flag_bit(0x10000, 0x20000)
    emit_freebsd_open_flag_bit(0x20000, 0x100)
    emit_freebsd_open_flag_bit(0x80000, 0x100000)

    out8(0x4C)
    out8(0x89)
    out8(0xC6)
    return 0
}

fn emit_math_f64_return_xmm0() {
    out8(0x66) out8(0x48) out8(0x0F) out8(0x7E) out8(0xC0)
    return 9
}

fn emit_math_abs_code() {
    out8(0x48) out8(0x89) out8(0xF8)
    out8(0x48) out8(0xB9) out64(0x7FFFFFFFFFFFFFFF)
    out8(0x48) out8(0x21) out8(0xC8)
    return 9
}

fn emit_math_sqrt_code() {
    out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xC7)
    out8(0xF2) out8(0x0F) out8(0x51) out8(0xC0)
    return emit_math_f64_return_xmm0()
}

fn emit_math_min_code() {
    out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xC7)
    out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xCE)
    out8(0xF2) out8(0x0F) out8(0x5D) out8(0xC1)
    return emit_math_f64_return_xmm0()
}

fn emit_math_max_code() {
    out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xC7)
    out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xCE)
    out8(0xF2) out8(0x0F) out8(0x5F) out8(0xC1)
    return emit_math_f64_return_xmm0()
}

fn emit_math_clamp_code() {
    out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xC7)
    out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xCE)
    out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xD2)
    out8(0xF2) out8(0x0F) out8(0x5F) out8(0xC1)
    out8(0xF2) out8(0x0F) out8(0x5D) out8(0xC2)
    return emit_math_f64_return_xmm0()
}

fn emit_math_lerp_code() {
    out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xC7)
    out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xCE)
    out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xD2)
    out8(0xF2) out8(0x0F) out8(0x5C) out8(0xC8)
    out8(0xF2) out8(0x0F) out8(0x59) out8(0xCA)
    out8(0xF2) out8(0x0F) out8(0x58) out8(0xC1)
    return emit_math_f64_return_xmm0()
}

fn emit_math_hypot_code() {
    out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xC7)
    out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xCE)
    out8(0xF2) out8(0x0F) out8(0x59) out8(0xC0)
    out8(0xF2) out8(0x0F) out8(0x59) out8(0xC9)
    out8(0xF2) out8(0x0F) out8(0x58) out8(0xC1)
    out8(0xF2) out8(0x0F) out8(0x51) out8(0xC0)
    return emit_math_f64_return_xmm0()
}

fn emit_math_inv_sqrt_code() {
    out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xC7)
    out8(0xF2) out8(0x0F) out8(0x51) out8(0xC0)
    out8(0x48) out8(0xB8) out64(0x3FF0000000000000)
    out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xC8)
    out8(0xF2) out8(0x0F) out8(0x5E) out8(0xC8)
    out8(0x66) out8(0x48) out8(0x0F) out8(0x7E) out8(0xC8)
    return 9
}

fn emit_math_x87_unary(I64 opcode) {
    out8(0x48) out8(0x83) out8(0xEC) out8(8)
    out8(0x48) out8(0x89) out8(0x3C) out8(0x24)
    out8(0xDD) out8(0x04) out8(0x24)
    out8(0xD9) out8(opcode)
    out8(0xDD) out8(0x1C) out8(0x24)
    out8(0x48) out8(0x8B) out8(0x04) out8(0x24)
    out8(0x48) out8(0x83) out8(0xC4) out8(8)
    return 9
}

fn emit_math_atan2_code() {
    out8(0x48) out8(0x83) out8(0xEC) out8(16)
    out8(0x48) out8(0x89) out8(0x3C) out8(0x24)
    out8(0x48) out8(0x89) out8(0x74) out8(0x24) out8(8)
    out8(0xDD) out8(0x04) out8(0x24)
    out8(0xDD) out8(0x44) out8(0x24) out8(8)
    out8(0xD9) out8(0xF3)
    out8(0xDD) out8(0x1C) out8(0x24)
    out8(0x48) out8(0x8B) out8(0x04) out8(0x24)
    out8(0x48) out8(0x83) out8(0xC4) out8(16)
    return 9
}

fn emit_math_scale_code(I64 bits) {
    out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xC7)
    out8(0x48) out8(0xB8) out64(bits)
    out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xC8)
    out8(0xF2) out8(0x0F) out8(0x59) out8(0xC1)
    return emit_math_f64_return_xmm0()
}

fn emit_time_clock_ns_code(I64 clock_id) {
    out8(0x48) out8(0x83) out8(0xEC) out8(16)
    out8(0xBF)
    if (mem_read64(0x800598) == 2) { out32(clock_id * 4) }
    else { out32(clock_id) }
    out8(0x48) out8(0x8D) out8(0x34) out8(0x24)
    emit_host_syscall(228, 232)
    out8(0x48) out8(0x8B) out8(0x04) out8(0x24)
    out8(0x48) out8(0x69) out8(0xC0) out32(1000000000)
    out8(0x48) out8(0x03) out8(0x44) out8(0x24) out8(8)
    out8(0x48) out8(0x83) out8(0xC4) out8(16)
    return 8
}

fn emit_time_div_code(I64 divisor) {
    out8(0x48) out8(0x31) out8(0xD2)
    out8(0x48) out8(0xB9) out64(divisor)
    out8(0x48) out8(0xF7) out8(0xF1)
    return 8
}

fn emit_time_unix_s_code() {
    out8(0x48) out8(0x83) out8(0xEC) out8(16)
    out8(0x31) out8(0xFF)
    out8(0x48) out8(0x8D) out8(0x34) out8(0x24)
    emit_host_syscall(228, 232)
    out8(0x48) out8(0x8B) out8(0x04) out8(0x24)
    out8(0x48) out8(0x83) out8(0xC4) out8(16)
    return 8
}

fn emit_time_monotonic_s_code() {
    emit_time_clock_ns_code(1)
    out8(0xF2) out8(0x48) out8(0x0F) out8(0x2A) out8(0xC0)
    out8(0x48) out8(0xB8) out64(0x41CDCD6500000000)
    out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xC8)
    out8(0xF2) out8(0x0F) out8(0x5E) out8(0xC1)
    return emit_math_f64_return_xmm0()
}

fn emit_sleep_ms_code() {
    out8(0x48) out8(0x83) out8(0xEC) out8(16)
    out8(0x48) out8(0x89) out8(0xF8)
    out8(0x48) out8(0x31) out8(0xD2)
    out8(0x48) out8(0xC7) out8(0xC1) out32(1000)
    out8(0x48) out8(0xF7) out8(0xF1)
    out8(0x48) out8(0x89) out8(0x04) out8(0x24)
    out8(0x48) out8(0x89) out8(0xD0)
    out8(0x48) out8(0x69) out8(0xC0) out32(1000000)
    out8(0x48) out8(0x89) out8(0x44) out8(0x24) out8(8)
    out8(0x48) out8(0x8D) out8(0x3C) out8(0x24)
    out8(0x48) out8(0x31) out8(0xF6)
    emit_host_syscall(35, 240)
    out8(0x48) out8(0x83) out8(0xC4) out8(16)
    return 8
}

fn emit_runtime_open() {
    emit_freebsd_open_flag_translation()

    out8(0x48)
    out8(0xC7)
    out8(0xC2)
    out32(493)

    emit_host_syscall(2, 5)
    return 0
}

fn emit_runtime_close() {
    out8(0x48)
    out8(0x89)
    out8(0xC7)
    emit_host_syscall(3, 6)
    return 0
}

fn emit_runtime_read8() {
    out8(0x48)
    out8(0x89)
    out8(0xC7)

    out8(0x48)
    out8(0x83)
    out8(0xEC)
    out8(8)

    out8(0xC6)
    out8(0x04)
    out8(0x24)
    out8(0)

    out8(0x48)
    out8(0x89)
    out8(0xE6)

    out8(0x48)
    out8(0xC7)
    out8(0xC2)
    out32(1)

    emit_host_syscall(0, 3)

    out8(0x48)
    out8(0x0F)
    out8(0xB6)
    out8(0x04)
    out8(0x24)

    out8(0x48)
    out8(0x83)
    out8(0xC4)
    out8(8)
    return 0
}

fn emit_input_char_code() {
    emit_imm(0)
    emit_runtime_read8()
    return 5
}

fn emit_input_line_code() {

    out8(0xC6) out8(0x07) out8(0)

    out8(0x48) out8(0x89) out8(0xF2)
    out8(0x48) out8(0x83) out8(0xEA) out8(1)

    out8(0x48) out8(0x89) out8(0xFE)
    out8(0x48) out8(0x31) out8(0xFF)

    emit_host_syscall(0, 3)

    out8(0x48) out8(0x85) out8(0xC0)
    I64 done = emit_jcc32(0x8E)

    out8(0x0F) out8(0xB6) out8(0x4C) out8(0x06) out8(0xFF)
    out8(0x80) out8(0xF9) out8(10)
    I64 keep = emit_jcc32(0x85)
    out8(0x48) out8(0xFF) out8(0xC8)
    patch_rel(keep, tell())

    out8(0xC6) out8(0x04) out8(0x06) out8(0)
    patch_rel(done, tell())
    return 4
}

fn emit_gfx_state_r10() {

    out8(0x49)
    out8(0xC7)
    out8(0xC2)
    out32(0x8FE000)
    return 0
}

fn emit_gfx_bmp_header_code() {
    emit_gfx_state_r10()

    out8(0x66) out8(0x41) out8(0xC7) out8(0x42) out8(0x40) out8(0x42) out8(0x4D)
    out8(0x41) out8(0x8B) out8(0x42) out8(0x20)
    out8(0x83) out8(0xC0) out8(54)
    out8(0x41) out8(0x89) out8(0x42) out8(0x42)
    out8(0x41) out8(0xC7) out8(0x42) out8(0x46) out32(0)
    out8(0x41) out8(0xC7) out8(0x42) out8(0x4A) out32(54)
    out8(0x41) out8(0xC7) out8(0x42) out8(0x4E) out32(40)
    out8(0x41) out8(0x8B) out8(0x42) out8(0x08)
    out8(0x41) out8(0x89) out8(0x42) out8(0x52)
    out8(0x41) out8(0x8B) out8(0x42) out8(0x10)
    out8(0xF7) out8(0xD8)
    out8(0x41) out8(0x89) out8(0x42) out8(0x56)
    out8(0x66) out8(0x41) out8(0xC7) out8(0x42) out8(0x5A) out8(1) out8(0)
    out8(0x66) out8(0x41) out8(0xC7) out8(0x42) out8(0x5C) out8(32) out8(0)
    out8(0x41) out8(0xC7) out8(0x42) out8(0x5E) out32(0)
    out8(0x41) out8(0x8B) out8(0x42) out8(0x20)
    out8(0x41) out8(0x89) out8(0x42) out8(0x62)
    out8(0x41) out8(0xC7) out8(0x42) out8(0x66) out32(0)
    out8(0x41) out8(0xC7) out8(0x42) out8(0x6A) out32(0)
    out8(0x41) out8(0xC7) out8(0x42) out8(0x6E) out32(0)
    out8(0x41) out8(0xC7) out8(0x42) out8(0x72) out32(0)
    return 0
}

fn emit_gfx_linux_window_start_code() {
    out8(0x48) out8(0x83) out8(0xEC) out8(32)
    out8(0x48) out8(0xC7) out8(0x04) out8(0x24) out32(1)
    out8(0x48) out8(0xC7) out8(0x44) out8(0x24) out8(8) out32(0)
    out8(0x48) out8(0xC7) out8(0x44) out8(0x24) out8(16) out32(0)
    out8(0x48) out8(0xC7) out8(0x44) out8(0x24) out8(24) out32(0)
    out8(0xBF) out32(13)
    out8(0x48) out8(0x89) out8(0xE6)
    out8(0x31) out8(0xD2)
    out8(0x41) out8(0xBA) out32(8)
    emit_host_syscall(13, 0)
    out8(0x48) out8(0x83) out8(0xC4) out8(32)

    emit_gfx_state_r10()
    out8(0x49) out8(0xC7) out8(0x82) out32(0x80) out32(0 - 1)
    out8(0x49) out8(0xC7) out8(0x82) out32(0x88) out32(0)
    out8(0x49) out8(0xC7) out8(0x82) out32(0x90) out32(0)

    out8(0x48) out8(0x83) out8(0xEC) out8(16)
    out8(0x48) out8(0x8D) out8(0x3C) out8(0x24)
    emit_host_syscall(22, 0)
    out8(0x48) out8(0x85) out8(0xC0)
    I64 pipe_failed = emit_jcc32(0x88)

    emit_host_syscall(57, 0)
    out8(0x48) out8(0x85) out8(0xC0)
    I64 fork_failed = emit_jcc32(0x88)
    I64 child = emit_jcc32(0x84)

    emit_gfx_state_r10()
    out8(0x49) out8(0x89) out8(0x82) out32(0x88)
    out8(0x8B) out8(0x3C) out8(0x24)
    emit_host_syscall(3, 0)
    out8(0x8B) out8(0x44) out8(0x24) out8(4)
    out8(0x48) out8(0x63) out8(0xC0)
    emit_gfx_state_r10()
    out8(0x49) out8(0x89) out8(0x82) out32(0x80)
    out8(0x49) out8(0xC7) out8(0x82) out32(0x90) out32(1)
    out8(0x48) out8(0x83) out8(0xC4) out8(16)
    I64 parent_done = emit_jmp()

    I64 child_target = tell()
    patch_rel(child, child_target)

    out8(0x8B) out8(0x7C) out8(0x24) out8(4)
    emit_host_syscall(3, 0)
    out8(0x8B) out8(0x3C) out8(0x24)
    out8(0x31) out8(0xF6)
    emit_host_syscall(33, 0)
    out8(0x8B) out8(0x3C) out8(0x24)
    emit_host_syscall(3, 0)
    out8(0x48) out8(0x83) out8(0xC4) out8(16)

    out8(0x48) out8(0x83) out8(0xEC) out8(32)
    emit_string_ptr("/bin/sh", 7)
    out8(0x48) out8(0x89) out8(0x04) out8(0x24)
    emit_string_ptr("-c", 2)
    out8(0x48) out8(0x89) out8(0x44) out8(0x24) out8(8)
    emit_string_ptr("exec ffplay -loglevel quiet -f image2pipe -framerate 60 -vcodec bmp -i - -window_title 'MicroC Graphics' -autoexit", 114)
    out8(0x48) out8(0x89) out8(0x44) out8(0x24) out8(16)
    out8(0x48) out8(0x31) out8(0xC0)
    out8(0x48) out8(0x89) out8(0x44) out8(0x24) out8(24)
    out8(0x48) out8(0x8B) out8(0x45) out8(8)
    out8(0x48) out8(0x8D) out8(0x54) out8(0xC5) out8(24)
    out8(0x48) out8(0x8B) out8(0x3C) out8(0x24)
    out8(0x48) out8(0x89) out8(0xE6)
    emit_host_syscall(59, 0)
    out8(0xBF) out32(127)
    emit_host_syscall(60, 0)

    I64 fork_failure_target = tell()
    patch_rel(fork_failed, fork_failure_target)
    out8(0x8B) out8(0x3C) out8(0x24)
    emit_host_syscall(3, 0)
    out8(0x8B) out8(0x7C) out8(0x24) out8(4)
    emit_host_syscall(3, 0)
    I64 fork_to_failure = emit_jmp()

    I64 failure_target = tell()
    patch_rel(pipe_failed, failure_target)
    patch_rel(fork_to_failure, failure_target)
    out8(0x48) out8(0x83) out8(0xC4) out8(16)
    emit_gfx_state_r10()
    out8(0x49) out8(0xC7) out8(0x82) out32(0x80) out32(0 - 1)
    out8(0x49) out8(0xC7) out8(0x82) out32(0x88) out32(0)
    out8(0x49) out8(0xC7) out8(0x82) out32(0x90) out32(0)

    patch_rel(parent_done, tell())
    return 0
}

fn emit_gfx_open_code() {
    out8(0x48) out8(0x85) out8(0xFF)
    I64 bad_width = emit_jcc32(0x8E)
    out8(0x48) out8(0x85) out8(0xF6)
    I64 bad_height = emit_jcc32(0x8E)
    out8(0x48) out8(0x81) out8(0xFF) out32(16384)
    I64 width_too_large = emit_jcc32(0x8F)
    out8(0x48) out8(0x81) out8(0xFE) out32(16384)
    I64 height_too_large = emit_jcc32(0x8F)

    emit_gfx_state_r10()
    out8(0x49) out8(0x89) out8(0x7A) out8(0x08)
    out8(0x49) out8(0x89) out8(0x72) out8(0x10)
    out8(0x48) out8(0x89) out8(0xF8)
    out8(0x48) out8(0xC1) out8(0xE0) out8(2)
    out8(0x49) out8(0x89) out8(0x42) out8(0x18)
    out8(0x48) out8(0x0F) out8(0xAF) out8(0xC6)
    out8(0x49) out8(0x89) out8(0x42) out8(0x20)

    emit_host_map_call()
    out8(0x48) out8(0x85) out8(0xC0)
    I64 map_failed = emit_jcc32(0x88)

    emit_gfx_state_r10()
    out8(0x49) out8(0x89) out8(0x02)
    out8(0x49) out8(0xC7) out8(0x42) out8(0x28) out32(0)
    out8(0x49) out8(0xC7) out8(0x42) out8(0x30) out32(0)

    if (mem_read64(0x800598) == 1) {
        emit_gfx_linux_window_start_code()
        emit_gfx_present_code()
    }

    emit_gfx_state_r10()
    out8(0x49) out8(0x8B) out8(0x02)
    I64 success = emit_jmp()

    I64 fail_target = tell()
    patch_rel(bad_width, fail_target)
    patch_rel(bad_height, fail_target)
    patch_rel(width_too_large, fail_target)
    patch_rel(height_too_large, fail_target)
    patch_rel(map_failed, fail_target)

    emit_gfx_state_r10()
    out8(0x48) out8(0x31) out8(0xC0)
    out8(0x49) out8(0x89) out8(0x02)
    out8(0x49) out8(0x89) out8(0x42) out8(0x08)
    out8(0x49) out8(0x89) out8(0x42) out8(0x10)
    out8(0x49) out8(0x89) out8(0x42) out8(0x18)
    out8(0x49) out8(0x89) out8(0x42) out8(0x20)
    out8(0x49) out8(0x89) out8(0x42) out8(0x28)
    out8(0x49) out8(0x89) out8(0x42) out8(0x30)
    out8(0x49) out8(0xC7) out8(0x82) out32(0x80) out32(0 - 1)
    out8(0x49) out8(0xC7) out8(0x82) out32(0x88) out32(0)
    out8(0x49) out8(0xC7) out8(0x82) out32(0x90) out32(0)

    patch_rel(success, tell())
    return 8
}

fn emit_gfx_close_code() {
    emit_gfx_state_r10()

    if (mem_read64(0x800598) == 1) {
        out8(0x49) out8(0x8B) out8(0xBA) out32(0x80)
        out8(0x48) out8(0x85) out8(0xFF)
        I64 no_window_fd = emit_jcc32(0x88)
        emit_host_syscall(3, 0)
        patch_rel(no_window_fd, tell())

        emit_gfx_state_r10()
        out8(0x49) out8(0x8B) out8(0xBA) out32(0x88)
        out8(0x48) out8(0x85) out8(0xFF)
        I64 no_child = emit_jcc32(0x8E)
        out8(0x48) out8(0x31) out8(0xF6)
        out8(0x48) out8(0xC7) out8(0xC2) out32(1)
        out8(0x4D) out8(0x31) out8(0xD2)
        emit_host_syscall(61, 0)
        patch_rel(no_child, tell())
    }

    emit_gfx_state_r10()
    out8(0x49) out8(0x8B) out8(0x3A)
    out8(0x49) out8(0x8B) out8(0x72) out8(0x20)
    out8(0x48) out8(0x85) out8(0xFF)
    I64 no_buffer = emit_jcc32(0x84)
    emit_host_syscall(11, 73)
    patch_rel(no_buffer, tell())

    emit_gfx_state_r10()
    out8(0x48) out8(0x31) out8(0xC0)
    out8(0x49) out8(0x89) out8(0x02)
    out8(0x49) out8(0x89) out8(0x42) out8(0x08)
    out8(0x49) out8(0x89) out8(0x42) out8(0x10)
    out8(0x49) out8(0x89) out8(0x42) out8(0x18)
    out8(0x49) out8(0x89) out8(0x42) out8(0x20)
    out8(0x49) out8(0x89) out8(0x42) out8(0x28)
    out8(0x49) out8(0x89) out8(0x42) out8(0x30)
    out8(0x49) out8(0xC7) out8(0x82) out32(0x80) out32(0 - 1)
    out8(0x49) out8(0x89) out8(0x82) out32(0x88)
    out8(0x49) out8(0x89) out8(0x82) out32(0x90)
    return 4
}

fn emit_gfx_buffer_code() {
    emit_gfx_state_r10()

    out8(0x49)
    out8(0x8B)
    out8(0x02)

    return 8
}

fn emit_gfx_width_code() {
    emit_gfx_state_r10()

    out8(0x49)
    out8(0x8B)
    out8(0x42)
    out8(0x08)

    return 4
}

fn emit_gfx_height_code() {
    emit_gfx_state_r10()

    out8(0x49)
    out8(0x8B)
    out8(0x42)
    out8(0x10)

    return 4
}

fn emit_gfx_pitch_code() {
    emit_gfx_state_r10()

    out8(0x49)
    out8(0x8B)
    out8(0x42)
    out8(0x18)

    return 4
}

fn emit_gfx_clear_code() {

    out8(0x89)
    out8(0xF8)

    emit_gfx_state_r10()

    out8(0x49)
    out8(0x8B)
    out8(0x3A)

    out8(0x48)
    out8(0x85)
    out8(0xFF)

    I64 done = emit_jcc32(0x84)

    out8(0x49)
    out8(0x8B)
    out8(0x4A)
    out8(0x20)

    out8(0x48)
    out8(0xC1)
    out8(0xE9)
    out8(2)

    out8(0xFC)

    out8(0xF3)
    out8(0xAB)

    patch_rel(done, tell())

    out8(0x31)
    out8(0xC0)

    return 4
}

fn emit_gfx_pixel_code() {

    out8(0x48)
    out8(0x85)
    out8(0xFF)

    I64 negative_x = emit_jcc32(0x88)

    out8(0x48)
    out8(0x85)
    out8(0xF6)

    I64 negative_y = emit_jcc32(0x88)

    emit_gfx_state_r10()

    out8(0x49)
    out8(0x3B)
    out8(0x7A)
    out8(0x08)

    I64 outside_x = emit_jcc32(0x83)

    out8(0x49)
    out8(0x3B)
    out8(0x72)
    out8(0x10)

    I64 outside_y = emit_jcc32(0x83)

    out8(0x4D)
    out8(0x8B)
    out8(0x1A)

    out8(0x4D)
    out8(0x85)
    out8(0xDB)

    I64 no_buffer = emit_jcc32(0x84)

    out8(0x49)
    out8(0x8B)
    out8(0x42)
    out8(0x18)

    out8(0x48)
    out8(0x0F)
    out8(0xAF)
    out8(0xF0)

    out8(0x49)
    out8(0x01)
    out8(0xF3)

    out8(0x4D)
    out8(0x8D)
    out8(0x1C)
    out8(0xBB)

    out8(0x41)
    out8(0x89)
    out8(0x13)

    I64 done = tell()

    patch_rel(negative_x, done)
    patch_rel(negative_y, done)
    patch_rel(outside_x, done)
    patch_rel(outside_y, done)
    patch_rel(no_buffer, done)

    out8(0x31)
    out8(0xC0)

    return 4
}

fn emit_gfx_line_code() {

    out8(0x53)

    out8(0x41)
    out8(0x54)

    out8(0x41)
    out8(0x55)

    out8(0x41)
    out8(0x56)

    out8(0x41)
    out8(0x57)

    out8(0x49)
    out8(0x89)
    out8(0xF9)

    out8(0x49)
    out8(0x89)
    out8(0xF3)

    out8(0x49)
    out8(0x89)
    out8(0xD4)

    out8(0x49)
    out8(0x89)
    out8(0xCD)

    out8(0x4D)
    out8(0x89)
    out8(0xC6)

    out8(0x4D)
    out8(0x89)
    out8(0xE7)

    out8(0x4D)
    out8(0x29)
    out8(0xCF)

    I64 dx_positive = emit_jcc32(0x89)

    out8(0x49)
    out8(0xF7)
    out8(0xDF)

    patch_rel(dx_positive, tell())

    out8(0x48)
    out8(0xC7)
    out8(0xC3)
    out32(1)

    out8(0x4D)
    out8(0x39)
    out8(0xE1)

    I64 sx_positive = emit_jcc32(0x8C)

    out8(0x48)
    out8(0xC7)
    out8(0xC3)
    out32(0xFFFFFFFF)

    patch_rel(sx_positive, tell())

    out8(0x4D)
    out8(0x89)
    out8(0xEA)

    out8(0x4D)
    out8(0x29)
    out8(0xDA)

    I64 dy_positive = emit_jcc32(0x89)

    out8(0x49)
    out8(0xF7)
    out8(0xDA)

    patch_rel(dy_positive, tell())

    out8(0x49)
    out8(0xF7)
    out8(0xDA)

    out8(0x49)
    out8(0xC7)
    out8(0xC0)
    out32(1)

    out8(0x4D)
    out8(0x39)
    out8(0xEB)

    I64 sy_positive = emit_jcc32(0x8C)

    out8(0x49)
    out8(0xC7)
    out8(0xC0)
    out32(0xFFFFFFFF)

    patch_rel(sy_positive, tell())

    out8(0x4C)
    out8(0x89)
    out8(0xF9)

    out8(0x4C)
    out8(0x01)
    out8(0xD1)

    I64 loop = tell()

    out8(0x4D)
    out8(0x85)
    out8(0xC9)

    I64 skip_negative_x = emit_jcc32(0x88)

    out8(0x4D)
    out8(0x85)
    out8(0xDB)

    I64 skip_negative_y = emit_jcc32(0x88)

    out8(0x48)
    out8(0xC7)
    out8(0xC0)
    out32(0x8FE000)

    out8(0x4C)
    out8(0x3B)
    out8(0x48)
    out8(0x08)

    I64 skip_outside_x = emit_jcc32(0x83)

    out8(0x4C)
    out8(0x3B)
    out8(0x58)
    out8(0x10)

    I64 skip_outside_y = emit_jcc32(0x83)

    out8(0x48)
    out8(0x8B)
    out8(0x10)

    out8(0x48)
    out8(0x85)
    out8(0xD2)

    I64 skip_no_buffer = emit_jcc32(0x84)

    out8(0x48)
    out8(0x8B)
    out8(0x78)
    out8(0x18)

    out8(0x49)
    out8(0x0F)
    out8(0xAF)
    out8(0xFB)

    out8(0x48)
    out8(0x01)
    out8(0xFA)

    out8(0x4A)
    out8(0x8D)
    out8(0x14)
    out8(0x8A)

    out8(0x44)
    out8(0x89)
    out8(0x32)

    I64 after_plot = tell()

    patch_rel(skip_negative_x, after_plot)
    patch_rel(skip_negative_y, after_plot)
    patch_rel(skip_outside_x, after_plot)
    patch_rel(skip_outside_y, after_plot)
    patch_rel(skip_no_buffer, after_plot)

    out8(0x4D)
    out8(0x39)
    out8(0xE1)

    I64 not_finished = emit_jcc32(0x85)

    out8(0x4D)
    out8(0x39)
    out8(0xEB)

    I64 finished = emit_jcc32(0x84)

    I64 update = tell()
    patch_rel(not_finished, update)

    out8(0x48)
    out8(0x89)
    out8(0xCA)

    out8(0x48)
    out8(0xD1)
    out8(0xE2)

    out8(0x4C)
    out8(0x39)
    out8(0xD2)

    I64 skip_x = emit_jcc32(0x8C)

    out8(0x4C)
    out8(0x01)
    out8(0xD1)

    out8(0x49)
    out8(0x01)
    out8(0xD9)

    patch_rel(skip_x, tell())

    out8(0x4C)
    out8(0x39)
    out8(0xFA)

    I64 skip_y = emit_jcc32(0x8F)

    out8(0x4C)
    out8(0x01)
    out8(0xF9)

    out8(0x4D)
    out8(0x01)
    out8(0xC3)

    patch_rel(skip_y, tell())

    I64 back = emit_jmp()
    patch_rel(back, loop)

    I64 cleanup = tell()

    patch_rel(finished, cleanup)

    out8(0x41)
    out8(0x5F)

    out8(0x41)
    out8(0x5E)

    out8(0x41)
    out8(0x5D)

    out8(0x41)
    out8(0x5C)

    out8(0x5B)

    out8(0x31)
    out8(0xC0)

    return 4
}

fn emit_gfx_rect_fill_code() {

    out8(0x53)

    out8(0x41)
    out8(0x54)

    out8(0x41)
    out8(0x55)

    out8(0x41)
    out8(0x56)

    out8(0x41)
    out8(0x57)

    out8(0x49)
    out8(0x89)
    out8(0xF9)

    out8(0x49)
    out8(0x89)
    out8(0xF3)

    out8(0x49)
    out8(0x89)
    out8(0xD4)

    out8(0x49)
    out8(0x89)
    out8(0xCD)

    out8(0x4D)
    out8(0x89)
    out8(0xC6)

    out8(0x4D)
    out8(0x85)
    out8(0xE4)

    I64 bad_width = emit_jcc32(0x8E)

    out8(0x4D)
    out8(0x85)
    out8(0xED)

    I64 bad_height = emit_jcc32(0x8E)

    emit_gfx_state_r10()

    out8(0x4D)
    out8(0x89)
    out8(0xCF)

    out8(0x4D)
    out8(0x01)
    out8(0xE7)

    out8(0x4C)
    out8(0x89)
    out8(0xDB)

    out8(0x4C)
    out8(0x01)
    out8(0xEB)

    out8(0x4D)
    out8(0x85)
    out8(0xC9)

    I64 x0_ok = emit_jcc32(0x89)

    out8(0x4D)
    out8(0x31)
    out8(0xC9)

    patch_rel(x0_ok, tell())

    out8(0x4D)
    out8(0x85)
    out8(0xDB)

    I64 y0_ok = emit_jcc32(0x89)

    out8(0x4D)
    out8(0x31)
    out8(0xDB)

    patch_rel(y0_ok, tell())

    out8(0x4D)
    out8(0x3B)
    out8(0x7A)
    out8(0x08)

    I64 x1_ok = emit_jcc32(0x8E)

    out8(0x4D)
    out8(0x8B)
    out8(0x7A)
    out8(0x08)

    patch_rel(x1_ok, tell())

    out8(0x49)
    out8(0x3B)
    out8(0x5A)
    out8(0x10)

    I64 y1_ok = emit_jcc32(0x8E)

    out8(0x49)
    out8(0x8B)
    out8(0x5A)
    out8(0x10)

    patch_rel(y1_ok, tell())

    out8(0x4D)
    out8(0x39)
    out8(0xF9)

    I64 empty_x = emit_jcc32(0x8D)

    out8(0x49)
    out8(0x39)
    out8(0xDB)

    I64 empty_y = emit_jcc32(0x8D)

    out8(0x4D)
    out8(0x89)
    out8(0xFC)

    out8(0x4D)
    out8(0x29)
    out8(0xCC)

    out8(0x4D)
    out8(0x8B)
    out8(0x6A)
    out8(0x18)

    out8(0x4D)
    out8(0x8B)
    out8(0x3A)

    out8(0x4D)
    out8(0x85)
    out8(0xFF)

    I64 no_buffer = emit_jcc32(0x84)

    I64 row_loop = tell()

    out8(0x49)
    out8(0x39)
    out8(0xDB)

    I64 rows_done = emit_jcc32(0x8D)

    out8(0x4C)
    out8(0x89)
    out8(0xDF)

    out8(0x49)
    out8(0x0F)
    out8(0xAF)
    out8(0xFD)

    out8(0x4C)
    out8(0x01)
    out8(0xFF)

    out8(0x4A)
    out8(0x8D)
    out8(0x3C)
    out8(0x8F)

    out8(0x4C)
    out8(0x89)
    out8(0xF0)

    out8(0x4C)
    out8(0x89)
    out8(0xE1)

    out8(0xFC)

    out8(0xF3)
    out8(0xAB)

    out8(0x49)
    out8(0xFF)
    out8(0xC3)

    I64 next_row = emit_jmp()
    patch_rel(next_row, row_loop)

    I64 cleanup = tell()

    patch_rel(bad_width, cleanup)
    patch_rel(bad_height, cleanup)
    patch_rel(empty_x, cleanup)
    patch_rel(empty_y, cleanup)
    patch_rel(no_buffer, cleanup)
    patch_rel(rows_done, cleanup)

    out8(0x41)
    out8(0x5F)

    out8(0x41)
    out8(0x5E)

    out8(0x41)
    out8(0x5D)

    out8(0x41)
    out8(0x5C)

    out8(0x5B)

    out8(0x31)
    out8(0xC0)

    return 4
}

fn emit_gfx_bind_target_code() {
    emit_gfx_state_r10()

    out8(0x49)
    out8(0x89)
    out8(0x7A)
    out8(0x28)

    out8(0x49)
    out8(0x89)
    out8(0x72)
    out8(0x30)

    out8(0x31)
    out8(0xC0)

    return 4
}

fn emit_gfx_present_code() {
    out8(0x48) out8(0xC7) out8(0xC0) out32(0x8FE000)
    out8(0x4C) out8(0x8B) out8(0x00)
    out8(0x4C) out8(0x8B) out8(0x48) out8(0x28)
    out8(0x4D) out8(0x85) out8(0xC0)
    I64 missing_source = emit_jcc32(0x84)
    out8(0x4D) out8(0x85) out8(0xC9)
    I64 window_fallback = emit_jcc32(0x84)

    out8(0x4C) out8(0x8B) out8(0x50) out8(0x08)
    out8(0x4C) out8(0x8B) out8(0x58) out8(0x10)
    out8(0x48) out8(0x8B) out8(0x50) out8(0x18)
    out8(0x48) out8(0x8B) out8(0x40) out8(0x30)
    out8(0x48) out8(0x85) out8(0xC0)
    I64 bad_pitch = emit_jcc32(0x8E)
    out8(0x48) out8(0x39) out8(0xD0)
    I64 small_pitch = emit_jcc32(0x82)

    I64 row_loop = tell()
    out8(0x4D) out8(0x85) out8(0xDB)
    I64 finished = emit_jcc32(0x84)
    out8(0x4C) out8(0x89) out8(0xC6)
    out8(0x4C) out8(0x89) out8(0xCF)
    out8(0x4C) out8(0x89) out8(0xD1)
    out8(0xFC) out8(0xF3) out8(0xA5)
    out8(0x49) out8(0x01) out8(0xD0)
    out8(0x49) out8(0x01) out8(0xC1)
    out8(0x49) out8(0xFF) out8(0xCB)
    I64 next_row = emit_jmp()
    patch_rel(next_row, row_loop)

    I64 target_success = tell()
    patch_rel(finished, target_success)
    out8(0x31) out8(0xC0)
    I64 target_done = emit_jmp()

    I64 window_target = tell()
    patch_rel(window_fallback, window_target)

    if (mem_read64(0x800598) == 1) {
        emit_gfx_state_r10()
        out8(0x49) out8(0x83) out8(0xBA) out32(0x90) out8(0)
        I64 no_window = emit_jcc32(0x84)
        out8(0x49) out8(0x8B) out8(0xBA) out32(0x80)
        out8(0x48) out8(0x85) out8(0xFF)
        I64 bad_window_fd = emit_jcc32(0x88)

        emit_gfx_bmp_header_code()
        emit_gfx_state_r10()
        out8(0x49) out8(0x8B) out8(0xBA) out32(0x80)
        out8(0x49) out8(0x8D) out8(0x72) out8(0x40)
        out8(0x48) out8(0xC7) out8(0xC2) out32(54)
        emit_gfx_write_all()
        out8(0x48) out8(0x85) out8(0xC0)
        I64 header_failed = emit_jcc32(0x84)

        emit_gfx_state_r10()
        out8(0x49) out8(0x8B) out8(0xBA) out32(0x80)
        out8(0x49) out8(0x8B) out8(0x32)
        out8(0x49) out8(0x8B) out8(0x52) out8(0x20)
        emit_gfx_write_all()
        out8(0x48) out8(0x85) out8(0xC0)
        I64 pixels_failed = emit_jcc32(0x84)

        out8(0x31) out8(0xC0)
        I64 window_done = emit_jmp()

        I64 window_failure = tell()
        patch_rel(no_window, window_failure)
        patch_rel(bad_window_fd, window_failure)
        patch_rel(header_failed, window_failure)
        patch_rel(pixels_failed, window_failure)

        emit_gfx_state_r10()
        out8(0x49) out8(0x8B) out8(0xBA) out32(0x80)
        out8(0x48) out8(0x85) out8(0xFF)
        I64 skip_close = emit_jcc32(0x88)
        emit_host_syscall(3, 0)
        patch_rel(skip_close, tell())
        emit_gfx_state_r10()
        out8(0x49) out8(0xC7) out8(0x82) out32(0x80) out32(0 - 1)
        out8(0x49) out8(0xC7) out8(0x82) out32(0x90) out32(0)
        emit_imm(0 - 1)

        patch_rel(window_done, tell())
    }
    else {
        emit_imm(0 - 1)
    }

    I64 done = emit_jmp()

    I64 failure = tell()
    patch_rel(missing_source, failure)
    patch_rel(bad_pitch, failure)
    patch_rel(small_pitch, failure)
    emit_imm(0 - 1)

    I64 end = tell()
    patch_rel(target_done, end)
    patch_rel(done, end)
    return 4
}

fn emit_gfx_rgb_code() {

    out8(0x48)
    out8(0x89)
    out8(0xF8)

    out8(0x25)
    out32(255)

    out8(0x48)
    out8(0xC1)
    out8(0xE0)
    out8(16)

    out8(0x48)
    out8(0x89)
    out8(0xF1)

    out8(0x81)
    out8(0xE1)
    out32(255)

    out8(0x48)
    out8(0xC1)
    out8(0xE1)
    out8(8)

    out8(0x48)
    out8(0x09)
    out8(0xC8)

    out8(0x81)
    out8(0xE2)
    out32(255)

    out8(0x48)
    out8(0x09)
    out8(0xD0)

    out8(0x0D)
    out32(0xFF000000)

    return 8
}

fn emit_gfx_rgba_code() {

    out8(0x49)
    out8(0x89)
    out8(0xC8)

    out8(0x41)
    out8(0x81)
    out8(0xE0)
    out32(255)

    out8(0x49)
    out8(0xC1)
    out8(0xE0)
    out8(24)

    out8(0x48)
    out8(0x89)
    out8(0xF8)

    out8(0x25)
    out32(255)

    out8(0x48)
    out8(0xC1)
    out8(0xE0)
    out8(16)

    out8(0x4C)
    out8(0x09)
    out8(0xC0)

    out8(0x48)
    out8(0x89)
    out8(0xF1)

    out8(0x81)
    out8(0xE1)
    out32(255)

    out8(0x48)
    out8(0xC1)
    out8(0xE1)
    out8(8)

    out8(0x48)
    out8(0x09)
    out8(0xC8)

    out8(0x81)
    out8(0xE2)
    out32(255)

    out8(0x48)
    out8(0x09)
    out8(0xD0)

    return 8
}

fn emit_gfx_write_all() {
    I64 write_loop = tell()

    emit_host_syscall(1, 4)

    out8(0x48)
    out8(0x85)
    out8(0xC0)

    I64 write_failed = emit_jcc32(0x8E)

    out8(0x48)
    out8(0x01)
    out8(0xC6)

    out8(0x48)
    out8(0x29)
    out8(0xC2)

    out8(0x48)
    out8(0x85)
    out8(0xD2)

    I64 more = emit_jcc32(0x85)
    patch_rel(more, write_loop)

    emit_imm(1)

    I64 done = emit_jmp()

    I64 failure = tell()
    patch_rel(write_failed, failure)

    emit_imm(0)

    patch_rel(done, tell())

    return 4
}

fn emit_gfx_save_bmp_code() {

    out8(0x41)
    out8(0x54)

    emit_gfx_state_r10()

    out8(0x49)
    out8(0x8B)
    out8(0x02)

    out8(0x48)
    out8(0x85)
    out8(0xC0)

    I64 no_buffer = emit_jcc32(0x84)

    out8(0x66)
    out8(0x41)
    out8(0xC7)
    out8(0x42)
    out8(0x40)
    out8(0x42)
    out8(0x4D)
    out8(0x41)
    out8(0x8B)
    out8(0x42)
    out8(0x20)
    out8(0x83)
    out8(0xC0)
    out8(54)
    out8(0x41)
    out8(0x89)
    out8(0x42)
    out8(0x42)
    out8(0x41)
    out8(0xC7)
    out8(0x42)
    out8(0x46)
    out32(0)

    out8(0x41)
    out8(0xC7)
    out8(0x42)
    out8(0x4A)
    out32(54)

    out8(0x41)
    out8(0xC7)
    out8(0x42)
    out8(0x4E)
    out32(40)

    out8(0x41)
    out8(0x8B)
    out8(0x42)
    out8(0x08)

    out8(0x41)
    out8(0x89)
    out8(0x42)
    out8(0x52)

    out8(0x41)
    out8(0x8B)
    out8(0x42)
    out8(0x10)

    out8(0xF7)
    out8(0xD8)

    out8(0x41)
    out8(0x89)
    out8(0x42)
    out8(0x56)

    out8(0x66)
    out8(0x41)
    out8(0xC7)
    out8(0x42)
    out8(0x5A)
    out8(1)
    out8(0)

    out8(0x66)
    out8(0x41)
    out8(0xC7)
    out8(0x42)
    out8(0x5C)
    out8(32)
    out8(0)

    out8(0x41)
    out8(0xC7)
    out8(0x42)
    out8(0x5E)
    out32(0)

    out8(0x41)
    out8(0x8B)
    out8(0x42)
    out8(0x20)

    out8(0x41)
    out8(0x89)
    out8(0x42)
    out8(0x62)

    out8(0x41)
    out8(0xC7)
    out8(0x42)
    out8(0x66)
    out32(0)

    out8(0x41)
    out8(0xC7)
    out8(0x42)
    out8(0x6A)
    out32(0)

    out8(0x41)
    out8(0xC7)
    out8(0x42)
    out8(0x6E)
    out32(0)

    out8(0x41)
    out8(0xC7)
    out8(0x42)
    out8(0x72)
    out32(0)

    out8(0x48)
    out8(0xC7)
    out8(0xC6)
    out32(577)

    emit_freebsd_open_flag_translation()

    out8(0x48)
    out8(0xC7)
    out8(0xC2)
    out32(420)

    emit_host_syscall(2, 5)

    out8(0x48)
    out8(0x85)
    out8(0xC0)

    I64 open_failed = emit_jcc32(0x88)

    out8(0x49)
    out8(0x89)
    out8(0xC4)

    out8(0x4C)
    out8(0x89)
    out8(0xE7)

    emit_gfx_state_r10()

    out8(0x49)
    out8(0x8D)
    out8(0x72)
    out8(0x40)

    out8(0x48)
    out8(0xC7)
    out8(0xC2)
    out32(54)

    emit_gfx_write_all()

    out8(0x48)
    out8(0x85)
    out8(0xC0)

    I64 header_failed = emit_jcc32(0x84)

    out8(0x4C)
    out8(0x89)
    out8(0xE7)

    emit_gfx_state_r10()

    out8(0x49)
    out8(0x8B)
    out8(0x32)

    out8(0x49)
    out8(0x8B)
    out8(0x52)
    out8(0x20)

    emit_gfx_write_all()

    out8(0x48)
    out8(0x85)
    out8(0xC0)

    I64 pixels_failed = emit_jcc32(0x84)

    out8(0x4C)
    out8(0x89)
    out8(0xE0)

    emit_runtime_close()

    emit_imm(0)

    I64 success_done = emit_jmp()

    I64 close_failure = tell()

    patch_rel(header_failed, close_failure)
    patch_rel(pixels_failed, close_failure)

    out8(0x4C)
    out8(0x89)
    out8(0xE0)

    emit_runtime_close()

    emit_imm(0 - 1)

    I64 close_failure_done = emit_jmp()

    I64 no_fd_failure = tell()

    patch_rel(no_buffer, no_fd_failure)
    patch_rel(open_failed, no_fd_failure)

    emit_imm(0 - 1)

    I64 epilogue = tell()

    patch_rel(success_done, epilogue)
    patch_rel(close_failure_done, epilogue)

    out8(0x41)
    out8(0x5C)

    return 4
}

fn emit_runtime_write8() {
    out8(0x48)
    out8(0x83)
    out8(0xEC)
    out8(8)

    out8(0x88)
    out8(0x04)
    out8(0x24)

    out8(0x48)
    out8(0x89)
    out8(0xE6)

    out8(0x48)
    out8(0xC7)
    out8(0xC2)
    out32(1)

    emit_host_syscall(1, 4)

    out8(0x48)
    out8(0x83)
    out8(0xC4)
    out8(8)
    return 0
}

fn emit_runtime_size() {
    out8(0x48)
    out8(0x89)
    out8(0xC7)

    out8(0x48)
    out8(0x31)
    out8(0xF6)

    out8(0x48)
    out8(0xC7)
    out8(0xC2)
    out32(2)

    emit_host_syscall(8, 478)
    return 0
}

fn emit_runtime_seek() {
    out8(0x48)
    out8(0x89)
    out8(0xC6)

    out8(0x48)
    out8(0x31)
    out8(0xD2)

    emit_host_syscall(8, 478)
    return 0
}

fn emit_runtime_strlen() {
    out8(0x48) out8(0x89) out8(0xC7) out8(0x48) out8(0x31) out8(0xC0)
    I64 loop = tell()
    out8(0x80) out8(0x3C) out8(0x07) out8(0) out8(0x0F) out8(0x84)
    I64 done = tell()
    out32(0)
    out8(0x48) out8(0xFF) out8(0xC0)
    I64 back = emit_jmp()
    patch_rel(back, loop)
    patch_rel(done, tell())
    return 0
}

fn emit_runtime_strcmp() {
    I64 loop = tell()
    out8(0x0F) out8(0xB6) out8(0x07) out8(0x0F) out8(0xB6) out8(0x16) out8(0x38) out8(0xD0) out8(0x0F) out8(0x85)
    I64 different = tell()
    out32(0)
    out8(0x84) out8(0xC0) out8(0x0F) out8(0x84)
    I64 equal = tell()
    out32(0)
    out8(0x48) out8(0xFF) out8(0xC7) out8(0x48) out8(0xFF) out8(0xC6)
    I64 back = emit_jmp()
    patch_rel(back, loop)

    I64 diff_target = tell()
    patch_rel(different, diff_target)
    out8(0x48) out8(0x0F) out8(0xB6) out8(0xC0) out8(0x48) out8(0x0F) out8(0xB6) out8(0xD2) out8(0x48) out8(0x29) out8(0xD0)
    I64 done_jump = emit_jmp()

    I64 equal_target = tell()
    patch_rel(equal, equal_target)
    out8(0x48) out8(0x31) out8(0xC0)
    patch_rel(done_jump, tell())
    return 0
}

fn emit_runtime_argc() {
    out8(0x48)
    out8(0x8B)
    out8(0x45)
    out8(0x08)
    return 0
}

fn emit_runtime_argv() {
    out8(0x48)
    out8(0x8B)
    out8(0x44)
    out8(0xC5)
    out8(0x10)
    return 0
}

fn emit_runtime_debug_char() {
    out8(0x48)
    out8(0x83)
    out8(0xEC)
    out8(8)

    out8(0x88)
    out8(0x04)
    out8(0x24)

    out8(0x48)
    out8(0xC7)
    out8(0xC7)
    out32(1)

    out8(0x48)
    out8(0x89)
    out8(0xE6)

    out8(0x48)
    out8(0xC7)
    out8(0xC2)
    out32(1)

    emit_host_syscall(1, 4)

    out8(0x48)
    out8(0x83)
    out8(0xC4)
    out8(8)
    return 0
}

fn emit_mem_read8_code() {
    out8(0x48) out8(0x0F) out8(0xB6) out8(0x00)
    return 0
}

fn emit_mem_read64_code() {
    out8(0x48) out8(0x8B) out8(0x00)
    return 0
}

fn emit_mem_write8_code() {
    out8(0x88) out8(0x07)
    return 0
}

fn emit_mem_write64_code() {
    out8(0x48) out8(0x89) out8(0x07)
    return 0
}

fn emit_mem_read16_code() {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    os_file_write8(mem_read64(0x800008), (0x48) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x0F) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xB7) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x00) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) return 0
}
fn emit_mem_read32_code() {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    os_file_write8(mem_read64(0x800008), (0x8B) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x00) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) return 0
}
fn emit_mem_write16_code() {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    os_file_write8(mem_read64(0x800008), (0x66) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x89) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x07) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) return 0
}
fn emit_mem_write32_code() {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    os_file_write8(mem_read64(0x800008), (0x89) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x07) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) return 0
}

fn emit_addr_var(I64 index) {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    I64 displacement = 0 - index * 8
    os_file_write8(mem_read64(0x800008), (0x48) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x8D) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x85) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (displacement) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1)
    os_file_write8(mem_read64(0x800008), (displacement >> 8) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1)
    os_file_write8(mem_read64(0x800008), (displacement >> 16) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1)
    os_file_write8(mem_read64(0x800008), (displacement >> 24) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1)
    return 0
}

fn emit_port_in8_code() {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    os_file_write8(mem_read64(0x800008), (0x89) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xC2) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x31) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xC0) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xEC) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) return 0
}
fn emit_port_in16_code() {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    os_file_write8(mem_read64(0x800008), (0x89) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xC2) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x31) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xC0) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x66) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xED) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) return 0
}
fn emit_port_in32_code() {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    os_file_write8(mem_read64(0x800008), (0x89) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xC2) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xED) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) return 0
}
fn emit_port_out8_code() {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    os_file_write8(mem_read64(0x800008), (0xEE) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) return 0
}
fn emit_port_out16_code() {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    os_file_write8(mem_read64(0x800008), (0x66) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xEF) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) return 0
}
fn emit_port_out32_code() {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    os_file_write8(mem_read64(0x800008), (0xEF) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) return 0
}

fn emit_cpu_read_cr0_code() {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    os_file_write8(mem_read64(0x800008), (0x0F) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x20) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xC0) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) return 0
}
fn emit_cpu_write_cr0_code() {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    os_file_write8(mem_read64(0x800008), (0x0F) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x22) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xC0) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) return 0
}
fn emit_cpu_read_cr2_code() {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    os_file_write8(mem_read64(0x800008), (0x0F) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x20) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xD0) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) return 0
}
fn emit_cpu_read_cr3_code() {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    os_file_write8(mem_read64(0x800008), (0x0F) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x20) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xD8) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) return 0
}
fn emit_cpu_write_cr3_code() {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    os_file_write8(mem_read64(0x800008), (0x0F) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x22) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xD8) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) return 0
}
fn emit_cpu_read_cr4_code() {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    os_file_write8(mem_read64(0x800008), (0x0F) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x20) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xE0) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) return 0
}
fn emit_cpu_write_cr4_code() {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    os_file_write8(mem_read64(0x800008), (0x0F) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x22) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xE0) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) return 0
}
fn emit_cpu_invlpg_code() {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    os_file_write8(mem_read64(0x800008), (0x0F) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x01) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x38) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) return 0
}
fn emit_cpu_lgdt_code() {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    os_file_write8(mem_read64(0x800008), (0x0F) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x01) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x10) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) return 0
}
fn emit_cpu_lidt_code() {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    os_file_write8(mem_read64(0x800008), (0x0F) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x01) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x18) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) return 0
}
fn emit_cpu_ltr_code() {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    os_file_write8(mem_read64(0x800008), (0x0F) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x00) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xD8) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) return 0
}

fn emit_cpu_rdmsr_code() {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    os_file_write8(mem_read64(0x800008), (0x89) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xC1) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1)
    os_file_write8(mem_read64(0x800008), (0x0F) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x32) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1)
    os_file_write8(mem_read64(0x800008), (0x48) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xC1) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xE2) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (32) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1)
    os_file_write8(mem_read64(0x800008), (0x48) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x09) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xD0) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1)
    return 0
}

fn emit_cpu_wrmsr_code() {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    os_file_write8(mem_read64(0x800008), (0x48) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x89) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xC2) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1)
    os_file_write8(mem_read64(0x800008), (0x48) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xC1) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xEA) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (32) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1)
    os_file_write8(mem_read64(0x800008), (0x0F) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x30) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1)
    return 0
}

fn emit_cpu_rdtsc_code() {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    os_file_write8(mem_read64(0x800008), (0x0F) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x31) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1)
    os_file_write8(mem_read64(0x800008), (0x48) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xC1) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xE2) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (32) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1)
    os_file_write8(mem_read64(0x800008), (0x48) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x09) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xD0) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1)
    return 0
}

fn emit_cpuid_result_code(I64 which) {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    os_file_write8(mem_read64(0x800008), (0x53) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1)
    os_file_write8(mem_read64(0x800008), (0x0F) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xA2) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1)
    if (which == 1) {
        os_file_write8(mem_read64(0x800008), (0x89) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xD8) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1)
    }
    if (which == 2) {
        os_file_write8(mem_read64(0x800008), (0x89) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xC8) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1)
    }
    if (which == 3) {
        os_file_write8(mem_read64(0x800008), (0x89) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xD0) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1)
    }
    os_file_write8(mem_read64(0x800008), (0x5B) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1)
    return 0
}

fn emit_zero_rax_code() {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    os_file_write8(mem_read64(0x800008), (0x48) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0x31) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) os_file_write8(mem_read64(0x800008), (0xC0) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1) return 0
}

fn parse_expression(I64 min_precedence) {
    I64 current_type = parse_primary()
    I64 running = 1

    while (running != 0) {
        I64 type = peek()
        if (type != 4) { running = 0 }

        if (running != 0) {
            I64 op = lv()
            I64 prec = precedence(op)
            if (prec == 0) { running = 0 }
            if (prec < min_precedence) { running = 0 }

            if (running != 0) {
                take()

                if (op == 1007) {
                    emit_value_to_bool(current_type)
                    I64 false_jump = emit_jz()
                    I64 right_and = parse_expression(prec + 1)
                    emit_value_to_bool(right_and)
                    I64 and_done = emit_jmp()
                    patch_rel(false_jump, tell())
                    emit_imm(0)
                    patch_rel(and_done, tell())
                    current_type = 10
                }
                else {
                    if (op == 1008) {
                        emit_value_to_bool(current_type)
                        I64 true_jump = emit_jnz()
                        I64 right_or = parse_expression(prec + 1)
                        emit_value_to_bool(right_or)
                        I64 or_done = emit_jmp()
                        patch_rel(true_jump, tell())
                        emit_imm(1)
                        patch_rel(or_done, tell())
                        current_type = 10
                    }
                    else {
                        emit_push()
                        I64 right_type = parse_expression(prec + 1)
                        current_type = emit_binary_typed(op, current_type, right_type)
                    }
                }
            }
        }
    }

    return current_type
}

fn builtin_required_head(I64 id) {
    if (id >= 1) {
        if (id <= 6) { return 8 }
    }

    if (id >= 7) {
        if (id <= 10) { return 2 }
    }
    if (id >= 16) {
        if (id <= 19) { return 2 }
    }
    if (id == 26) { return 2 }

    if (id >= 20) {
        if (id <= 25) { return 16384 }
    }
    if (id >= 27) {
        if (id <= 61) { return 16384 }
    }

    if (id == 13) { return 2048 }
    if (id == 14) { return 2048 }

    if (id >= 62) {
        if (id <= 64) { return 8 }
    }
    if (id == 65) { return 2 }
    if (id == 66) { return 2 }
    if (id == 67) { return 2048 }

    if (id >= 68) {
        if (id <= 77) { return 16 }
    }

    if (id >= 78) {
        if (id <= 82) { return 2048 }
    }

    if (id >= 83) {
        if (id <= 89) { return 16384 }
    }

    if (id >= 114) {
        if (id <= 128) {
            return 128
        }
    }

    if (id >= 92) {
        if (id <= 105) { return 2 }
    }
    if (id >= 107) {
        if (id <= 111) { return 2 }
    }

    if (id == 112) { return 4 }
    if (id == 113) { return 4 }

    return 0
}

fn require_builtin_head(I64 id) {
    if (id >= 129) {
        if (id <= 144) {
            if (official_head_enabled(1) != 0) { return 1 }
            if (official_head_enabled(64) != 0) { return 1 }
            compiler_error(41)
            return 0
        }
    }
    if (id >= 145) {
        if (id <= 150) {
            if (official_head_enabled(1) != 0) { return 1 }
            if (official_head_enabled(32) != 0) { return 1 }
            compiler_error(41)
            return 0
        }
    }

    I64 bit = builtin_required_head(id)
    if (bit == 0) { return 1 }
    if (official_head_enabled(bit) != 0) { return 1 }
    compiler_error(41)
    return 0
}

fn parse_builtin_call(I64 id) {
    if (require_builtin_head(id) == 0) { return 4 }

    expect_sym(40)

    if (out_raw() != 0) {
        I64 hosted = 0

        if (id >= 1) {
            if (id <= 6) {
                hosted = 1
            }
        }

        if (id >= 13) {
            if (id <= 15) {
                hosted = 1
            }
        }

        if (id == 112) { hosted = 1 }
        if (id == 113) { hosted = 1 }
        if (id >= 114) {
            if (id <= 128) {
                hosted = 1
            }
        }

        if (id >= 145) {
            if (id <= 150) {
                hosted = 1
            }
        }

        if (hosted != 0) {
            compiler_error(12)
            return 4
        }
    }

    if (mem_read64(os_safe_mode_addr()) != 0) {
        if (unsafe_depth() == 0) {
            I64 raw_unsafe = 0
            if (id >= 7) { if (id <= 10) { raw_unsafe = 1 } }
            if (id >= 16) { if (id <= 61) { raw_unsafe = 1 } }
            if (id == 62) { raw_unsafe = 1 }
            if (id == 63) { raw_unsafe = 1 }
            if (id == 65) { raw_unsafe = 1 }
            if (id == 66) { raw_unsafe = 1 }
            if (id == 69) { raw_unsafe = 1 }
            if (id == 70) { raw_unsafe = 1 }
            if (id == 71) { raw_unsafe = 1 }
            if (id == 72) { raw_unsafe = 1 }
            if (id == 74) { raw_unsafe = 1 }
            if (id == 76) { raw_unsafe = 1 }
            if (id == 77) { raw_unsafe = 1 }
            if (id == 79) { raw_unsafe = 1 }
            if (id == 80) { raw_unsafe = 1 }
            if (id >= 83) { if (id <= 89) { raw_unsafe = 1 } }
            if (id == 105) { raw_unsafe = 1 }
            if (id == 106) { raw_unsafe = 1 }
            if (id == 124) { raw_unsafe = 1 }
            if (id == 125) { raw_unsafe = 1 }
            if (raw_unsafe != 0) {
                compiler_error(22)
                return 4
            }
        }
    }

    if (out_raw() == 0) {
        I64 kernel_only = 0
        if (id >= 20) {
            if (id <= 61) {
                kernel_only = 1
            }
        }
        if (id == 26) {
            kernel_only = 0
        }
        if (id == 59) {
            kernel_only = 0
        }
        if (kernel_only != 0) {
            compiler_error(13) return 4
        }
    }

    if (id == 114) {
        if (parse_runtime_args(2) == 0) { return 4 }
        return emit_gfx_open_code()
    }
    if (id == 115) {
        expect_sym(41)
        return emit_gfx_close_code()
    }
    if (id == 116) {
        expect_sym(41)
        return emit_gfx_buffer_code()
    }
    if (id == 117) {
        expect_sym(41)
        return emit_gfx_width_code()
    }
    if (id == 118) {
        expect_sym(41)
        return emit_gfx_height_code()
    }
    if (id == 119) {
        expect_sym(41)
        return emit_gfx_pitch_code()
    }
    if (id == 120) {
        if (parse_runtime_args(1) == 0) { return 4 }
        return emit_gfx_clear_code()
    }
    if (id == 121) {
        if (parse_runtime_args(3) == 0) { return 4 }
        return emit_gfx_pixel_code()
    }
    if (id == 122) {
        if (parse_runtime_args(5) == 0) { return 4 }
        return emit_gfx_line_code()
    }
    if (id == 123) {
        if (parse_runtime_args(5) == 0) { return 4 }
        return emit_gfx_rect_fill_code()
    }
    if (id == 124) {
        if (parse_runtime_args(2) == 0) { return 4 }
        return emit_gfx_bind_target_code()
    }
    if (id == 125) {
        expect_sym(41)
        return emit_gfx_present_code()
    }
    if (id == 126) {
        if (parse_runtime_args(3) == 0) { return 4 }
        return emit_gfx_rgb_code()
    }
    if (id == 127) {
        if (parse_runtime_args(4) == 0) { return 4 }
        return emit_gfx_rgba_code()
    }
    if (id == 128) {
        if (parse_runtime_args(1) == 0) { return 4 }
        return emit_gfx_save_bmp_code()
    }

    if (id == 1) {
        parse_expression(0)
        emit_push()
        I64 flags = 0
        if (look_sym(44) != 0) {
            take()
            parse_expression(0)
            flags = 1
        }
        if (flags == 0) {
            emit_imm(0)
        }
        out8(0x48) out8(0x89) out8(0xC6)
        emit_pop_arg(0)
        expect_sym(41)
        emit_runtime_open()
        return 4
    }

    if (id == 2) {
        parse_expression(0)
        expect_sym(41)
        emit_runtime_close()
        return 4
    }

    if (id == 3) {
        parse_expression(0)
        expect_sym(41)
        emit_runtime_read8()
        return 5
    }

    if (id == 4) {
        parse_expression(0)
        emit_push()
        expect_sym(44)
        parse_expression(0)
        emit_pop_arg(0)
        expect_sym(41)
        emit_runtime_write8()
        return 5
    }

    if (id == 5) {
        parse_expression(0)
        expect_sym(41)
        emit_runtime_size()
        return 4
    }

    if (id == 6) {
        parse_expression(0)
        emit_push()
        expect_sym(44)
        parse_expression(0)
        emit_pop_arg(0)
        expect_sym(41)
        emit_runtime_seek()
        return 4
    }

    if (id == 7) {
        parse_expression(0)
        expect_sym(41)
        emit_mem_read8_code()
        return 5
    }

    if (id == 8) {
        parse_expression(0)
        emit_push()
        expect_sym(44)
        parse_expression(0)
        emit_pop_arg(0)
        expect_sym(41)
        emit_mem_write8_code()
        return 5
    }

    if (id == 9) {
        parse_expression(0)
        expect_sym(41)
        emit_mem_read64_code()
        return 8
    }

    if (id == 10) {
        parse_expression(0)
        emit_push()
        expect_sym(44)
        parse_expression(0)
        emit_pop_arg(0)
        expect_sym(41)
        emit_mem_write64_code()
        return 8
    }

    if (id == 11) {
        parse_expression(0)
        expect_sym(41)
        emit_runtime_strlen()
        return 8
    }

    if (id == 12) {
        parse_expression(0)
        emit_push()
        expect_sym(44)
        parse_expression(0)
        out8(0x48) out8(0x89) out8(0xC6)
        emit_pop_arg(0)
        expect_sym(41)
        emit_runtime_strcmp()
        return 4
    }

    if (id == 13) {
        expect_sym(41)
        emit_runtime_argc()
        return 4
    }

    if (id == 14) {
        parse_expression(0)
        expect_sym(41)
        emit_runtime_argv()
        return 8
    }

    if (id == 15) {
        parse_expression(0)
        expect_sym(41)
        emit_runtime_debug_char()
        return 5
    }

    if (id == 16) {
        parse_expression(0) expect_sym(41) emit_mem_read16_code() return 6
    }
    if (id == 17) {
        parse_expression(0) emit_push() expect_sym(44) parse_expression(0) emit_pop_arg(0) expect_sym(41) emit_mem_write16_code() return 6
    }
    if (id == 18) {
        parse_expression(0) expect_sym(41) emit_mem_read32_code() return 7
    }
    if (id == 19) {
        parse_expression(0) emit_push() expect_sym(44) parse_expression(0) emit_pop_arg(0) expect_sym(41) emit_mem_write32_code() return 7
    }

    if (id == 20) {
        parse_expression(0) expect_sym(41) emit_port_in8_code() return 5
    }
    if (id == 21) {
        parse_expression(0) expect_sym(41) emit_port_in16_code() return 6
    }
    if (id == 22) {
        parse_expression(0) expect_sym(41) emit_port_in32_code() return 7
    }
    if (id == 23) {
        parse_expression(0) emit_push() expect_sym(44) parse_expression(0) emit_pop_arg(2) expect_sym(41) emit_port_out8_code() return 5
    }
    if (id == 24) {
        parse_expression(0) emit_push() expect_sym(44) parse_expression(0) emit_pop_arg(2) expect_sym(41) emit_port_out16_code() return 6
    }
    if (id == 25) {
        parse_expression(0) emit_push() expect_sym(44) parse_expression(0) emit_pop_arg(2) expect_sym(41) emit_port_out32_code() return 7
    }

    if (id == 26) {
        take()
        if (ct() != 1) {
            fail() return 4
        }
        I64 index = find_var(chash())
        if (index == 0) {
            compiler_error(4) return 4
        }
        expect_sym(41)
        emit_addr_var(index)
        return 8
    }

    if (id == 27) {
        expect_sym(41) emit_cpu_read_cr0_code() return 8
    }
    if (id == 28) {
        parse_expression(0) expect_sym(41) emit_cpu_write_cr0_code() return 8
    }
    if (id == 29) {
        expect_sym(41) emit_cpu_read_cr2_code() return 8
    }
    if (id == 30) {
        expect_sym(41) emit_cpu_read_cr3_code() return 8
    }
    if (id == 31) {
        parse_expression(0) expect_sym(41) emit_cpu_write_cr3_code() return 8
    }
    if (id == 32) {
        expect_sym(41) emit_cpu_read_cr4_code() return 8
    }
    if (id == 33) {
        parse_expression(0) expect_sym(41) emit_cpu_write_cr4_code() return 8
    }
    if (id == 34) {
        parse_expression(0) expect_sym(41) emit_cpu_invlpg_code() return 8
    }
    if (id == 35) {
        parse_expression(0) expect_sym(41) emit_cpu_lgdt_code() return 8
    }
    if (id == 36) {
        parse_expression(0) expect_sym(41) emit_cpu_lidt_code() return 8
    }
    if (id == 37) {
        parse_expression(0) expect_sym(41) emit_cpu_ltr_code() return 8
    }
    if (id == 38) {
        parse_expression(0) expect_sym(41) emit_cpu_rdmsr_code() return 8
    }
    if (id == 39) {
        parse_expression(0) emit_push() expect_sym(44) parse_expression(0) emit_pop_arg(3) expect_sym(41) emit_cpu_wrmsr_code() return 8
    }
    if (id == 40) {
        expect_sym(41) emit_cpu_rdtsc_code() return 8
    }

    if (id >= 41) {
        if (id <= 44) {
            parse_expression(0)
            emit_push()
            expect_sym(44)
            parse_expression(0)
            out8(0x89) out8(0xC1) out8(0x58)
            expect_sym(41)
            emit_cpuid_result_code(id - 41)
            return 7
        }
    }

    if (id == 45) {
        expect_sym(41) out8(0x9C) out8(0x58) return 8
    }
    if (id == 46) {
        parse_expression(0) expect_sym(41) out8(0x50) out8(0x9D) return 8
    }
    if (id == 47) {
        expect_sym(41) out8(0x0F) out8(0x01) out8(0xF8) emit_zero_rax_code() return 8
    }
    if (id == 48) {
        expect_sym(41) out8(0x48) out8(0xCF) return 8
    }
    if (id == 49) {
        expect_sym(41) out8(0xCC) emit_zero_rax_code() return 8
    }
    if (id == 50) {
        expect_sym(41) out8(0xF3) out8(0x90) emit_zero_rax_code() return 8
    }
    if (id == 51) {
        expect_sym(41) out8(0xFA) emit_zero_rax_code() return 8
    }
    if (id == 52) {
        expect_sym(41) out8(0xFB) emit_zero_rax_code() return 8
    }
    if (id == 53) {
        expect_sym(41) out8(0xF4) emit_zero_rax_code() return 8
    }
    if (id == 54) {
        expect_sym(41) out8(0x48) out8(0x89) out8(0xE0) return 8
    }
    if (id == 55) {
        parse_expression(0) expect_sym(41) out8(0x48) out8(0x89) out8(0xC4) return 8
    }
    if (id == 56) {
        expect_sym(41) out8(0x48) out8(0x89) out8(0xE8) return 8
    }
    if (id == 57) {
        parse_expression(0) expect_sym(41) out8(0x48) out8(0x89) out8(0xC5) return 8
    }
    if (id == 58) {
        parse_expression(0) expect_sym(41) out8(0xFF) out8(0xE0) return 8
    }
    if (id == 59) {
        parse_expression(0) expect_sym(41) out8(0xFF) out8(0xD0) return 8
    }

    if (id == 60) {
        take()
        if (ct() != 1) {
            fail() return 4
        }
        I64 target = find_function(chash())
        if (target == 0) {
            compiler_error(14) return 4
        }
        expect_sym(41)
        emit_imm(target)
        return 8
    }

    if (id == 61) {
        expect_sym(41) emit_imm(tell()) return 8
    }

    if (id >= 62) {
        if (id <= 89) {
            if (out_raw() != 0) {
                compiler_error(12)
                return 4
            }
        }
    }

    if (out_raw() != 0) {
        if (id >= 92) {
            if (id <= 104) {
                compiler_error(12)
                return 4
            }
        }
        if (id >= 107) {
            if (id <= 111) {
                compiler_error(12)
                return 4
            }
        }
    }

    if (id == 62) { return parse_host_syscall_call(3, 0, 3) }
    if (id == 63) { return parse_host_syscall_call(3, 1, 4) }
    if (id == 64) { return parse_host_syscall_call(3, 8, 478) }

    if (id == 65) {
        parse_expression(0)
        expect_sym(41)
        return emit_host_map_call()
    }
    if (id == 66) { return parse_host_syscall_call(2, 11, 73) }
    if (id == 67) { return parse_host_syscall_call(0, 39, 20) }

    if (id == 68) { return parse_host_syscall_call(3, 41, 97) }
    if (id == 69) { return parse_host_syscall_call(3, 42, 98) }
    if (id == 70) { return parse_host_syscall_call(3, 43, 30) }
    if (id == 71) { return parse_host_syscall_call(6, 44, 133) }
    if (id == 72) { return parse_host_syscall_call(6, 45, 29) }
    if (id == 73) { return parse_host_syscall_call(2, 48, 134) }
    if (id == 74) { return parse_host_syscall_call(3, 49, 104) }
    if (id == 75) { return parse_host_syscall_call(2, 50, 106) }
    if (id == 76) { return parse_host_syscall_call(5, 54, 105) }
    if (id == 77) { return parse_host_syscall_call(3, 7, 209) }

    if (id == 78) { return parse_host_syscall_call(0, 57, 2) }
    if (id == 79) { return parse_host_syscall_call(3, 59, 59) }
    if (id == 80) { return parse_host_syscall_call(4, 61, 7) }

    if (id == 81) {
        expect_sym(41)
        emit_imm(mem_read64(0x800598))
        return 4
    }

    if (id == 82) { return parse_host_syscall_call(1, 60, 1) }

    if (id == 83) { return parse_dynamic_syscall_call(0) }
    if (id == 84) { return parse_dynamic_syscall_call(1) }
    if (id == 85) { return parse_dynamic_syscall_call(2) }
    if (id == 86) { return parse_dynamic_syscall_call(3) }
    if (id == 87) { return parse_dynamic_syscall_call(4) }
    if (id == 88) { return parse_dynamic_syscall_call(5) }
    if (id == 89) { return parse_dynamic_syscall_call(6) }

    if (id == 90) {
        take()
        if (ct() != 1) { compiler_error(34) return 4 }
        I64 size_type = type_id(cp())
        if (size_type == 0) { compiler_error(34) return 4 }
        expect_sym(41)
        I64 bits = type_bits(size_type)
        I64 bytes = (bits + 7) / 8
        emit_imm(bytes)
        return 8
    }

    if (id == 91) {
        take()
        if (ct() != 1) { compiler_error(34) return 4 }
        I64 cast_type = type_id(cp())
        if (cast_type == 0) { compiler_error(34) return 4 }
        expect_sym(44)
        I64 from_type = parse_expression(0)
        expect_sym(41)
        emit_convert_type(from_type, cast_type)
        return cast_type
    }

    if (id == 92) {
        parse_expression(0)
        expect_sym(41)
        return emit_safe_alloc_call()
    }
    if (id == 93) {
        parse_expression(0)
        expect_sym(41)
        return emit_safe_free_call()
    }
    if (id == 94) {
        parse_expression(0)
        expect_sym(41)
        emit_safe_validate()
        out8(0x48) out8(0x89) out8(0xC8)
        return 8
    }
    if (id == 95) { if (parse_runtime_args(2) == 0) { return 4 } return emit_safe_read(1) }
    if (id == 96) { if (parse_runtime_args(3) == 0) { return 4 } return emit_safe_write(1) }
    if (id == 97) { if (parse_runtime_args(2) == 0) { return 4 } return emit_safe_read(2) }
    if (id == 98) { if (parse_runtime_args(3) == 0) { return 4 } return emit_safe_write(2) }
    if (id == 99) { if (parse_runtime_args(2) == 0) { return 4 } return emit_safe_read(4) }
    if (id == 100) { if (parse_runtime_args(3) == 0) { return 4 } return emit_safe_write(4) }
    if (id == 101) { if (parse_runtime_args(2) == 0) { return 4 } return emit_safe_read(8) }
    if (id == 102) { if (parse_runtime_args(3) == 0) { return 4 } return emit_safe_write(8) }
    if (id == 103) { if (parse_runtime_args(2) == 0) { return 4 } return emit_safe_calloc_call() }
    if (id == 104) { if (parse_runtime_args(2) == 0) { return 4 } return emit_safe_realloc_call() }
    if (id == 105) { if (parse_runtime_args(3) == 0) { return 4 } return emit_mem_find8_code() }
    if (id == 106) { if (parse_runtime_args(2) == 0) { return 4 } return emit_fnv1a64_code() }
    if (id == 107) { if (parse_runtime_args(2) == 0) { return 4 } return emit_safe_read_be16() }
    if (id == 108) { if (parse_runtime_args(2) == 0) { return 4 } return emit_safe_read_be32() }
    if (id == 109) { if (parse_runtime_args(3) == 0) { return 4 } return emit_safe_write_be16() }
    if (id == 110) { if (parse_runtime_args(3) == 0) { return 4 } return emit_safe_write_be32() }
    if (id == 111) { if (parse_runtime_args(4) == 0) { return 4 } return emit_safe_find8() }

    if (id == 112) {
        expect_sym(41)
        return emit_input_char_code()
    }

    if (id == 113) {
        if (parse_runtime_args(2) == 0) { return 4 }
        return emit_input_line_code()
    }

    if (id == 129) { if (parse_runtime_f64_args(1) == 0) { return 4 } return emit_math_abs_code() }
    if (id == 130) { if (parse_runtime_f64_args(1) == 0) { return 4 } return emit_math_sqrt_code() }
    if (id == 131) { if (parse_runtime_f64_args(2) == 0) { return 4 } return emit_math_min_code() }
    if (id == 132) { if (parse_runtime_f64_args(2) == 0) { return 4 } return emit_math_max_code() }
    if (id == 133) { if (parse_runtime_f64_args(3) == 0) { return 4 } return emit_math_clamp_code() }
    if (id == 134) { if (parse_runtime_f64_args(3) == 0) { return 4 } return emit_math_lerp_code() }
    if (id == 135) { if (parse_runtime_f64_args(2) == 0) { return 4 } return emit_math_hypot_code() }
    if (id == 136) { if (parse_runtime_f64_args(1) == 0) { return 4 } return emit_math_inv_sqrt_code() }
    if (id == 137) { expect_sym(41) emit_imm(0x400921FB54442D18) return 9 }
    if (id == 138) { expect_sym(41) emit_imm(0x401921FB54442D18) return 9 }
    if (id == 139) { expect_sym(41) emit_imm(0x4005BF0A8B145769) return 9 }
    if (id == 140) { if (parse_runtime_f64_args(1) == 0) { return 4 } return emit_math_x87_unary(0xFE) }
    if (id == 141) { if (parse_runtime_f64_args(1) == 0) { return 4 } return emit_math_x87_unary(0xFF) }
    if (id == 142) { if (parse_runtime_f64_args(2) == 0) { return 4 } return emit_math_atan2_code() }
    if (id == 143) { if (parse_runtime_f64_args(1) == 0) { return 4 } return emit_math_scale_code(0x3F91DF46A2529D39) }
    if (id == 144) { if (parse_runtime_f64_args(1) == 0) { return 4 } return emit_math_scale_code(0x404CA5DC1A63C1F8) }
    if (id == 145) { expect_sym(41) return emit_time_unix_s_code() }
    if (id == 146) { expect_sym(41) return emit_time_clock_ns_code(1) }
    if (id == 147) { expect_sym(41) emit_time_clock_ns_code(1) return emit_time_div_code(1000) }
    if (id == 148) { expect_sym(41) emit_time_clock_ns_code(1) return emit_time_div_code(1000000) }
    if (id == 149) { expect_sym(41) return emit_time_monotonic_s_code() }
    if (id == 150) { if (parse_runtime_args(1) == 0) { return 4 } return emit_sleep_ms_code() }

    fail()
    return 4
}

fn parse_generic_call(I64 hash) {
    expect_sym(40)
    I64 count = 0
    I64 more = 1
    if (look_sym(41) != 0) {
        more = 0
    }

    while (more != 0) {
        parse_expression(0)
        emit_push()
        count = count + 1
        if (count > 6) {
            fail() return 4
        }

        if (look_sym(44) != 0) {
            take()
        }
        if (look_sym(41) != 0) {
            more = 0
        }
    }

    expect_sym(41)

    I64 i = count
    while (i > 0) {
        i = i - 1
        emit_pop_arg(i)
    }

    I64 patch = emit_call_placeholder()
    register_call(hash, patch, count)
    return 4
}

fn parse_primary() {
    take()
    I64 type = ct()

    if (type == 2) {
        emit_imm(cv())
        return 4
    }

    if (type == 5) {
        return emit_float_literal(cv(), clen())
    }

    if (type == 3) {
        I64 text = cp()
        I64 length = clen()
        emit_string_ptr(text, length)
        return 8
    }

    if (type == 1) {
        if (tok_is("true") != 0) {
            emit_imm(1)
            return 10
        }

        if (tok_is("false") != 0) {
            emit_imm(0)
            return 10
        }
        if (tok_is("null") != 0) {
            emit_imm(0)
            return 8
        }

        I64 hash = chash()
        I64 name = cp()
        I64 builtin = builtin_id(name)

        if (look_sym(40) != 0) {
            if (builtin != 0) {
                return parse_builtin_call(builtin)
            }
            return parse_generic_call(hash)
        }

        I64 index = find_var(hash)
        if (index == 0) {
            fail() emit_imm(0) return 4
        }
        emit_load_var(index)
        return var_type(index)
    }

    if (type == 4) {
        if (cv() == 40) {
            I64 inside_type = parse_expression(0)
            expect_sym(41)
            return inside_type
        }

        if (cv() == 45) {
            I64 neg_type = parse_primary()
            emit_neg_value(neg_type)
            return neg_type
        }

        if (cv() == 43) {
            return parse_primary()
        }

        if (cv() == 33) {
            I64 not_type = parse_primary()
            emit_value_to_bool(not_type)
            out8(0x48) out8(0x85) out8(0xC0)
            out8(0x0F) out8(0x94) out8(0xC0)
            out8(0x48) out8(0x0F) out8(0xB6) out8(0xC0)
            return 10
        }

        if (cv() == 126) {
            I64 bit_type = parse_primary()
            return emit_bit_not(bit_type)
        }

        if (cv() == 38) {
            take()
            if (ct() != 1) { fail() emit_imm(0) return 8 }
            I64 address_index = find_var(chash())
            if (address_index == 0) { compiler_error(4) emit_imm(0) return 8 }
            emit_addr_var(address_index)
            return 8
        }

        if (cv() == 42) {
            if (require_unsafe_memory() == 0) { emit_imm(0) return 4 }
            parse_primary()
            emit_mem_read64_code()
            return 4
        }
    }

    fail()
    emit_imm(0)
    return 4
}

fn parse_assignment_hash(I64 hash) {
    I64 index = find_var(hash)
    if (index == 0) {
        compiler_error(4)
        return 0
    }

    if (var_is_const(index) != 0) {
        compiler_error(30)
        return 0
    }

    I64 target_type = var_type(index)
    expect_sym(61)
    I64 source_type = parse_expression(0)
    emit_convert_type(source_type, target_type)
    emit_store_var(index)
    return target_type
}

fn loop_depth() { return mem_read64(0x8005D8) }

fn loop_push(I64 start) {
    I64 depth = loop_depth() + 1
    if (depth > 32) { fail() return 0 }
    mem_write64(0x8005D8, depth)
    mem_write64(0x7B4000 + (depth - 1) * 8, start)
    return depth
}

fn loop_start() {
    I64 depth = loop_depth()
    if (depth <= 0) { return 0 }
    return mem_read64(0x7B4000 + (depth - 1) * 8)
}

fn loop_add_break(I64 patch) {
    I64 depth = loop_depth()
    if (depth <= 0) { compiler_error(33) return 0 }
    I64 count = mem_read64(0x8005E0)
    if (count >= 1024) { fail() return 0 }
    I64 entry = 0x7B5000 + count * 16
    mem_write64(entry, depth)
    mem_write64(entry + 8, patch)
    mem_write64(0x8005E0, count + 1)
    return patch
}

fn loop_patch_breaks(I64 depth, I64 target) {
    I64 count = mem_read64(0x8005E0)
    I64 i = 0
    while (i < count) {
        I64 entry = 0x7B5000 + i * 16
        if (mem_read64(entry) == depth) {
            patch_rel(mem_read64(entry + 8), target)
            mem_write64(entry, 0)
        }
        i = i + 1
    }
    return 0
}

fn loop_pop() {
    I64 depth = loop_depth()
    if (depth > 0) { mem_write64(0x8005D8, depth - 1) }
    return 0
}

fn parse_if_statement() {
    expect_sym(40)
    I64 condition_type = parse_expression(0)
    if (condition_type == 9) {
        emit_convert_type(9, 10)
    }
    expect_sym(41)
    I64 jump = emit_jz()
    expect_sym(123)
    parse_block()

    if (look_is("else") != 0) {
        I64 end_jmp = emit_jmp()
        patch_rel(jump, tell())
        take()
        expect_sym(123)
        parse_block()
        patch_rel(end_jmp, tell())
        return 0
    }

    patch_rel(jump, tell())
    return 0
}

fn parse_while_statement() {
    I64 start = tell()
    expect_sym(40)
    I64 condition_type = parse_expression(0)
    if (condition_type == 9) { emit_convert_type(9, 10) }
    expect_sym(41)
    I64 done = emit_jz()
    expect_sym(123)
    I64 depth = loop_push(start)
    parse_block()
    I64 back = emit_jmp()
    patch_rel(back, start)
    I64 target = tell()
    patch_rel(done, target)
    loop_patch_breaks(depth, target)
    loop_pop()
    return 0
}

fn parse_return_statement() {
    if (look_sym(125) != 0) {
        if (mem_read64(0x800058) != 0) {
            if (out_raw() != 0) {
                if (mem_read64(0x800568) != 0) {
                    emit_imm(0)
                    emit_epilog()
                    return 0
                }

                emit_raw_halt()
                return 0
            }

            emit_main_exit0()
            return 0
        }

        emit_epilog()
        return 0
    }

    parse_expression(0)

    if (mem_read64(0x800058) != 0) {
        if (out_raw() != 0) {
            if (mem_read64(0x800568) != 0) {
                emit_epilog()
                return 0
            }

            emit_raw_halt()
            return 0
        }

        emit_main_exit_rax()
        return 0
    }

    emit_epilog()
    return 0
}

fn emit_pin_char_code() {

    out8(0x48) out8(0x83) out8(0xEC) out8(8)
    out8(0x88) out8(0x04) out8(0x24)
    out8(0x48) out8(0xC7) out8(0xC7) out32(1)
    out8(0x48) out8(0x89) out8(0xE6)
    out8(0x48) out8(0xC7) out8(0xC2) out32(1)
    emit_host_syscall(1, 4)
    out8(0x48) out8(0x83) out8(0xC4) out8(8)
    return 0
}

fn emit_pin_text_code(I64 text, I64 length) {
    if (length == 0) {
        return 0
    }

    emit_string_ptr(text, length)

    out8(0x48) out8(0x89) out8(0xC6)
    out8(0x48) out8(0xC7) out8(0xC7) out32(1)
    out8(0x48) out8(0xC7) out8(0xC2) out32(length)
    emit_host_syscall(1, 4)
    return 0
}

fn emit_pin_i64_code() {

    out8(0x48) out8(0x83) out8(0xEC) out8(64)
    out8(0x49) out8(0x89) out8(0xE0)
    out8(0x49) out8(0x83) out8(0xC0) out8(63)
    out8(0x48) out8(0x31) out8(0xC9)
    out8(0x45) out8(0x31) out8(0xC9)

    out8(0x48) out8(0x85) out8(0xC0)
    out8(0x0F) out8(0x89)
    I64 non_negative = tell()
    out32(0)
    out8(0x48) out8(0xF7) out8(0xD8)
    out8(0x41) out8(0xB9) out32(1)
    patch_rel(non_negative, tell())

    out8(0x49) out8(0xC7) out8(0xC2) out32(10)

    I64 loop = tell()
    out8(0x48) out8(0x31) out8(0xD2)
    out8(0x49) out8(0xF7) out8(0xF2)
    out8(0x80) out8(0xC2) out8(48)
    out8(0x49) out8(0xFF) out8(0xC8)
    out8(0x41) out8(0x88) out8(0x10)
    out8(0x48) out8(0xFF) out8(0xC1)
    out8(0x48) out8(0x85) out8(0xC0)
    out8(0x0F) out8(0x85)
    I64 loop_back = tell()
    out32(0)
    patch_rel(loop_back, loop)

    out8(0x4D) out8(0x85) out8(0xC9)
    out8(0x0F) out8(0x84)
    I64 no_sign = tell()
    out32(0)
    out8(0x49) out8(0xFF) out8(0xC8)
    out8(0x41) out8(0xC6) out8(0x00) out8(45)
    out8(0x48) out8(0xFF) out8(0xC1)
    patch_rel(no_sign, tell())

    out8(0x4C) out8(0x89) out8(0xC6)
    out8(0x48) out8(0x89) out8(0xCA)
    out8(0x48) out8(0xC7) out8(0xC7) out32(1)
    emit_host_syscall(1, 4)
    out8(0x48) out8(0x83) out8(0xC4) out8(64)
    return 0
}

fn emit_pin_u64_code() {

    out8(0x48) out8(0x83) out8(0xEC) out8(64)
    out8(0x49) out8(0x89) out8(0xE0)
    out8(0x49) out8(0x83) out8(0xC0) out8(63)
    out8(0x48) out8(0x31) out8(0xC9)
    out8(0x49) out8(0xC7) out8(0xC2) out32(10)

    I64 loop = tell()
    out8(0x48) out8(0x31) out8(0xD2)
    out8(0x49) out8(0xF7) out8(0xF2)
    out8(0x80) out8(0xC2) out8(48)
    out8(0x49) out8(0xFF) out8(0xC8)
    out8(0x41) out8(0x88) out8(0x10)
    out8(0x48) out8(0xFF) out8(0xC1)
    out8(0x48) out8(0x85) out8(0xC0)
    out8(0x0F) out8(0x85)
    I64 loop_back = tell()
    out32(0)
    patch_rel(loop_back, loop)

    out8(0x4C) out8(0x89) out8(0xC6)
    out8(0x48) out8(0x89) out8(0xCA)
    out8(0x48) out8(0xC7) out8(0xC7) out32(1)
    emit_host_syscall(1, 4)
    out8(0x48) out8(0x83) out8(0xC4) out8(64)
    return 0
}

fn emit_pin_hex_code() {

    out8(0x48) out8(0x83) out8(0xEC) out8(32)
    out8(0x49) out8(0x89) out8(0xE0)
    out8(0x49) out8(0x83) out8(0xC0) out8(31)
    out8(0x48) out8(0x31) out8(0xC9)

    I64 loop = tell()
    out8(0x48) out8(0x89) out8(0xC2)
    out8(0x83) out8(0xE2) out8(15)
    out8(0x80) out8(0xFA) out8(9)
    out8(0x0F) out8(0x86)
    I64 number = tell()
    out32(0)
    out8(0x80) out8(0xC2) out8(55)
    I64 store_jump = emit_jmp()

    patch_rel(number, tell())
    out8(0x80) out8(0xC2) out8(48)

    patch_rel(store_jump, tell())
    out8(0x49) out8(0xFF) out8(0xC8)
    out8(0x41) out8(0x88) out8(0x10)
    out8(0x48) out8(0xFF) out8(0xC1)
    out8(0x48) out8(0xC1) out8(0xE8) out8(4)
    out8(0x48) out8(0x85) out8(0xC0)
    out8(0x0F) out8(0x85)
    I64 loop_back = tell()
    out32(0)
    patch_rel(loop_back, loop)

    out8(0x4C) out8(0x89) out8(0xC6)
    out8(0x48) out8(0x89) out8(0xCA)
    out8(0x48) out8(0xC7) out8(0xC7) out32(1)
    emit_host_syscall(1, 4)
    out8(0x48) out8(0x83) out8(0xC4) out8(32)
    return 0
}

fn emit_pin_pointer_code() {
    emit_push()
    emit_pin_text_code("0x", 2)
    out8(0x58)
    emit_pin_hex_code()
    return 0
}

fn emit_pin_bool_code() {

    out8(0x48) out8(0x85) out8(0xC0)
    out8(0x0F) out8(0x84)
    I64 is_false = tell()
    out32(0)

    emit_pin_text_code("true", 4)
    I64 done = emit_jmp()

    patch_rel(is_false, tell())
    emit_pin_text_code("false", 5)

    patch_rel(done, tell())
    return 0
}

fn emit_pin_string_code() {

    emit_push()
    emit_runtime_strlen()
    out8(0x48) out8(0x89) out8(0xC2)
    out8(0x5E)
    out8(0x48) out8(0xC7) out8(0xC7) out32(1)
    emit_host_syscall(1, 4)
    return 0
}

fn emit_pin_fixed6_code() {

    out8(0x48) out8(0x83) out8(0xEC) out8(8)
    out8(0x49) out8(0x89) out8(0xE0)
    out8(0x49) out8(0x83) out8(0xC0) out8(6)
    out8(0x48) out8(0x31) out8(0xC9)
    out8(0x49) out8(0xC7) out8(0xC2) out32(10)

    I64 loop = tell()
    out8(0x48) out8(0x31) out8(0xD2)
    out8(0x49) out8(0xF7) out8(0xF2)
    out8(0x80) out8(0xC2) out8(48)
    out8(0x49) out8(0xFF) out8(0xC8)
    out8(0x41) out8(0x88) out8(0x10)
    out8(0x48) out8(0xFF) out8(0xC1)
    out8(0x48) out8(0x83) out8(0xF9) out8(6)
    out8(0x0F) out8(0x85)
    I64 loop_back = tell()
    out32(0)
    patch_rel(loop_back, loop)

    out8(0x4C) out8(0x89) out8(0xC6)
    out8(0x48) out8(0xC7) out8(0xC2) out32(6)
    out8(0x48) out8(0xC7) out8(0xC7) out32(1)
    emit_host_syscall(1, 4)
    out8(0x48) out8(0x83) out8(0xC4) out8(8)
    return 0
}

fn emit_pin_f64_code() {

    out8(0x48) out8(0x85) out8(0xC0)
    out8(0x0F) out8(0x89)
    I64 positive = tell()
    out32(0)

    emit_push()
    emit_imm(45)
    emit_pin_char_code()
    out8(0x58)

    patch_rel(positive, tell())
    out8(0x48) out8(0xD1) out8(0xE0)
    out8(0x48) out8(0xD1) out8(0xE8)

    emit_push()

    out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xC0)
    out8(0xF2) out8(0x48) out8(0x0F) out8(0x2C) out8(0xC0)
    emit_pin_u64_code()

    emit_imm(46)
    emit_pin_char_code()

    out8(0x58)
    out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xC0)
    out8(0xF2) out8(0x4C) out8(0x0F) out8(0x2C) out8(0xC0)
    out8(0xF2) out8(0x49) out8(0x0F) out8(0x2A) out8(0xC8)
    out8(0xF2) out8(0x0F) out8(0x5C) out8(0xC1)

    out8(0x66) out8(0x48) out8(0x0F) out8(0x7E) out8(0xC0)
    out8(0x48) out8(0xD1) out8(0xE0)
    out8(0x48) out8(0xD1) out8(0xE8)
    out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xC0)

    emit_imm(1000000)
    out8(0xF2) out8(0x48) out8(0x0F) out8(0x2A) out8(0xC8)
    out8(0xF2) out8(0x0F) out8(0x59) out8(0xC1)

    emit_imm(1)
    out8(0xF2) out8(0x48) out8(0x0F) out8(0x2A) out8(0xC8)
    emit_imm(2)
    out8(0xF2) out8(0x48) out8(0x0F) out8(0x2A) out8(0xD0)
    out8(0xF2) out8(0x0F) out8(0x5E) out8(0xCA)
    out8(0xF2) out8(0x0F) out8(0x58) out8(0xC1)

    out8(0xF2) out8(0x48) out8(0x0F) out8(0x2C) out8(0xC0)
    emit_pin_fixed6_code()
    return 0
}

fn pin_format_id(I64 text, I64 position, I64 length) {
    if (position + 1 >= length) {
        return 0
    }
    if (mem_read8(text + position) != 37) {
        return 0
    }

    I64 a = mem_read8(text + position + 1)

    if (a == 99) {
        return 1
    }
    if (a == 115) {
        return 2
    }
    if (a == 112) {
        return 3
    }
    if (a == 37) {
        return 5
    }
    if (a == 66) {
        return 19
    }

    if (a == 73) {
        if (position + 2 < length) {
            if (mem_read8(text + position + 2) == 56) {
                return 10
            }
        }
        if (position + 3 < length) {
            if (mem_read8(text + position + 2) == 49) {
                if (mem_read8(text + position + 3) == 54) {
                    return 11
                }
            }
            if (mem_read8(text + position + 2) == 51) {
                if (mem_read8(text + position + 3) == 50) {
                    return 12
                }
            }
            if (mem_read8(text + position + 2) == 54) {
                if (mem_read8(text + position + 3) == 52) {
                    return 13
                }
            }
        }
    }

    if (a == 85) {
        if (position + 2 < length) {
            if (mem_read8(text + position + 2) == 56) {
                return 14
            }
        }
        if (position + 3 < length) {
            if (mem_read8(text + position + 2) == 49) {
                if (mem_read8(text + position + 3) == 54) {
                    return 15
                }
            }
            if (mem_read8(text + position + 2) == 51) {
                if (mem_read8(text + position + 3) == 50) {
                    return 16
                }
            }
            if (mem_read8(text + position + 2) == 54) {
                if (mem_read8(text + position + 3) == 52) {
                    return 17
                }
            }
        }
    }

    if (a == 70) {
        if (position + 3 < length) {
            if (mem_read8(text + position + 2) == 54) {
                if (mem_read8(text + position + 3) == 52) {
                    return 18
                }
            }
        }
    }

    if (a == 88) {
        if (position + 3 < length) {
            if (mem_read8(text + position + 2) == 54) {
                if (mem_read8(text + position + 3) == 52) {
                    return 4
                }
            }
        }
    }

    return 0
}

fn pin_format_length(I64 id) {
    if (id == 1) {
        return 2
    }
    if (id == 2) {
        return 2
    }
    if (id == 3) {
        return 2
    }
    if (id == 5) {
        return 2
    }
    if (id == 19) {
        return 2
    }
    if (id == 10) {
        return 3
    }
    if (id == 14) {
        return 3
    }
    return 4
}

fn pin_format_target_type(I64 id) {
    if (id == 10) {
        return 1
    }
    if (id == 11) {
        return 2
    }
    if (id == 12) {
        return 3
    }
    if (id == 13) {
        return 4
    }
    if (id == 14) {
        return 5
    }
    if (id == 15) {
        return 6
    }
    if (id == 16) {
        return 7
    }
    if (id == 17) {
        return 8
    }
    if (id == 18) {
        return 9
    }
    if (id == 19) {
        return 10
    }
    return 0
}

fn emit_pin_format_value(I64 id, I64 source_type) {
    if (id == 1) {
        emit_pin_char_code()
        return 0
    }

    if (id == 2) {
        emit_pin_string_code()
        return 0
    }

    if (id == 3) {
        emit_pin_pointer_code()
        return 0
    }

    if (id == 4) {
        emit_convert_type(source_type, 8)
        emit_pin_hex_code()
        return 0
    }

    if (id == 19) {
        emit_convert_type(source_type, 10)
        emit_pin_bool_code()
        return 0
    }

    I64 target = pin_format_target_type(id)
    emit_convert_type(source_type, target)

    if (target == 1) {
        emit_pin_i64_code() return 0
    }
    if (target == 2) {
        emit_pin_i64_code() return 0
    }
    if (target == 3) {
        emit_pin_i64_code() return 0
    }
    if (target == 4) {
        emit_pin_i64_code() return 0
    }

    if (target == 5) {
        emit_pin_u64_code() return 0
    }
    if (target == 6) {
        emit_pin_u64_code() return 0
    }
    if (target == 7) {
        emit_pin_u64_code() return 0
    }
    if (target == 8) {
        emit_pin_u64_code() return 0
    }

    if (target == 9) {
        emit_pin_f64_code() return 0
    }
    if (target == 10) {
        emit_pin_bool_code() return 0
    }

    fail()
    return 0
}

fn parse_pin_statement() {
    if (out_raw() != 0) {
        if (mem_read64(0x800568) == 0) {
            compiler_error(12)
            return 0
        }
    }

    expect_sym(40)
    take()

    if (ct() != 3) {
        fail()
        return 0
    }

    I64 original = cp()
    I64 length = clen()
    I64 text = copy_string_pool(original, length)
    if (failed() != 0) {
        return 0
    }

    I64 i = 0
    I64 literal_start = 0
    I64 argument_count = 0

    while (i < length) {
        I64 id = pin_format_id(text, i, length)

        if (id == 0) {
            if (mem_read8(text + i) == 37) {
                fail()
                return 0
            }
            i = i + 1
        }

        if (id != 0) {
            I64 literal_length = i - literal_start
            if (literal_length > 0) {
                emit_pin_text_code(text + literal_start, literal_length)
            }

            I64 spec_length = pin_format_length(id)

            if (id == 5) {
                emit_imm(37)
                emit_pin_char_code()
            }

            if (id != 5) {
                expect_sym(44)
                I64 source_type = parse_expression(0)
                argument_count = argument_count + 1
                emit_pin_format_value(id, source_type)
            }

            i = i + spec_length
            literal_start = i
        }
    }

    I64 tail = length - literal_start
    if (tail > 0) {
        emit_pin_text_code(text + literal_start, tail)
    }

    expect_sym(41)
    return argument_count
}

fn asm_put8(I64 value) {
    if (mem_read64(0x800088) != 0) {
        return value
    }
    I64 fd = mem_read64(0x800008)
    os_file_write8(fd, value & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 1)
    return value
}

fn asm_put2(I64 a, I64 b) {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    I64 fd = mem_read64(0x800008)
    os_file_write8(fd, a & 255)
    os_file_write8(fd, b & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 2)
    return 0
}
fn asm_put3(I64 a, I64 b, I64 c) {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    I64 fd = mem_read64(0x800008)
    os_file_write8(fd, a & 255)
    os_file_write8(fd, b & 255)
    os_file_write8(fd, c & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 3)
    return 0
}
fn asm_put4(I64 a, I64 b, I64 c, I64 d) {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    I64 fd = mem_read64(0x800008)
    os_file_write8(fd, a & 255)
    os_file_write8(fd, b & 255)
    os_file_write8(fd, c & 255)
    os_file_write8(fd, d & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 4)
    return 0
}
fn asm_put5(I64 a, I64 b, I64 c, I64 d, I64 e) {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    I64 fd = mem_read64(0x800008)
    os_file_write8(fd, a & 255)
    os_file_write8(fd, b & 255)
    os_file_write8(fd, c & 255)
    os_file_write8(fd, d & 255)
    os_file_write8(fd, e & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 5)
    return 0
}
fn asm_put6(I64 a, I64 b, I64 c, I64 d, I64 e, I64 f) {
    if (mem_read64(0x800088) != 0) {
        return 0
    }
    I64 fd = mem_read64(0x800008)
    os_file_write8(fd, a & 255)
    os_file_write8(fd, b & 255)
    os_file_write8(fd, c & 255)
    os_file_write8(fd, d & 255)
    os_file_write8(fd, e & 255)
    os_file_write8(fd, f & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 6)
    return 0
}

fn asm_put16(I64 value) {
    if (mem_read64(0x800088) != 0) {
        return value
    }
    I64 fd = mem_read64(0x800008)
    os_file_write8(fd, value & 255)
    os_file_write8(fd, (value >> 8) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 2)
    return value
}

fn asm_put32(I64 value) {
    if (mem_read64(0x800088) != 0) {
        return value
    }
    I64 fd = mem_read64(0x800008)
    os_file_write8(fd, value & 255)
    os_file_write8(fd, (value >> 8) & 255)
    os_file_write8(fd, (value >> 16) & 255)
    os_file_write8(fd, (value >> 24) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 4)
    return value
}

fn asm_put64(I64 value) {
    if (mem_read64(0x800088) != 0) {
        return value
    }
    I64 fd = mem_read64(0x800008)
    os_file_write8(fd, value & 255)
    os_file_write8(fd, (value >> 8) & 255)
    os_file_write8(fd, (value >> 16) & 255)
    os_file_write8(fd, (value >> 24) & 255)
    os_file_write8(fd, (value >> 32) & 255)
    os_file_write8(fd, (value >> 40) & 255)
    os_file_write8(fd, (value >> 48) & 255)
    os_file_write8(fd, (value >> 56) & 255)
    mem_write64(0x800090, mem_read64(0x800090) + 8)
    return value
}

fn asm_reg_info(I64 hash) {
    if (hash == 0x597732) {
        return 0x120
    }
    if (hash == 0x597774) {
        return 0x121
    }
    if (hash == 0x597795) {
        return 0x122
    }
    if (hash == 0x597753) {
        return 0x123
    }
    if (hash == 0xB88AAF4) {
        return 0x124
    }
    if (hash == 0xB8862A3) {
        return 0x125
    }
    if (hash == 0xB88AA0D) {
        return 0x126
    }
    if (hash == 0xB886A3E) {
        return 0x127
    }
    if (hash == 0xB889F71) {
        return 0x128
    }
    if (hash == 0xB889F92) {
        return 0x129
    }
    if (hash == 0x17C9C69BA) {
        return 0x12A
    }
    if (hash == 0x17C9C69DB) {
        return 0x12B
    }
    if (hash == 0x17C9C69FC) {
        return 0x12C
    }
    if (hash == 0x17C9C6A1D) {
        return 0x12D
    }
    if (hash == 0x17C9C6A3E) {
        return 0x12E
    }
    if (hash == 0x17C9C6A5F) {
        return 0x12F
    }
    if (hash == 0x59772E) {
        return 0x224
    }
    if (hash == 0x597770) {
        return 0x225
    }
    if (hash == 0x597791) {
        return 0x226
    }
    if (hash == 0x59774F) {
        return 0x227
    }
    if (hash == 0x59773E) {
        return 0x140
    }
    if (hash == 0x597780) {
        return 0x141
    }
    if (hash == 0x5977A1) {
        return 0x142
    }
    if (hash == 0x59775F) {
        return 0x143
    }
    if (hash == 0x597988) {
        return 0x144
    }
    if (hash == 0x597757) {
        return 0x145
    }
    if (hash == 0x597981) {
        return 0x146
    }
    if (hash == 0x597792) {
        return 0x147
    }
    if (hash == 0xB889F86) {
        return 0x148
    }
    if (hash == 0xB889FA7) {
        return 0x149
    }
    if (hash == 0x17C9C69CF) {
        return 0x14A
    }
    if (hash == 0x17C9C69F0) {
        return 0x14B
    }
    if (hash == 0x17C9C6A11) {
        return 0x14C
    }
    if (hash == 0x17C9C6A32) {
        return 0x14D
    }
    if (hash == 0x17C9C6A53) {
        return 0x14E
    }
    if (hash == 0x17C9C6A74) {
        return 0x14F
    }
    if (hash == 0xB886D83) {
        return 0x160
    }
    if (hash == 0xB886DC5) {
        return 0x161
    }
    if (hash == 0xB886DE6) {
        return 0x162
    }
    if (hash == 0xB886DA4) {
        return 0x163
    }
    if (hash == 0xB886FCD) {
        return 0x164
    }
    if (hash == 0xB886D9C) {
        return 0x165
    }
    if (hash == 0xB886FC6) {
        return 0x166
    }
    if (hash == 0xB886DD7) {
        return 0x167
    }
    if (hash == 0xB889F73) {
        return 0x168
    }
    if (hash == 0xB889F94) {
        return 0x169
    }
    if (hash == 0x17C9C69BC) {
        return 0x16A
    }
    if (hash == 0x17C9C69DD) {
        return 0x16B
    }
    if (hash == 0x17C9C69FE) {
        return 0x16C
    }
    if (hash == 0x17C9C6A1F) {
        return 0x16D
    }
    if (hash == 0x17C9C6A40) {
        return 0x16E
    }
    if (hash == 0x17C9C6A61) {
        return 0x16F
    }
    if (hash == 0xB88A4D0) {
        return 0x180
    }
    if (hash == 0xB88A512) {
        return 0x181
    }
    if (hash == 0xB88A533) {
        return 0x182
    }
    if (hash == 0xB88A4F1) {
        return 0x183
    }
    if (hash == 0xB88A71A) {
        return 0x184
    }
    if (hash == 0xB88A4E9) {
        return 0x185
    }
    if (hash == 0xB88A713) {
        return 0x186
    }
    if (hash == 0xB88A524) {
        return 0x187
    }
    if (hash == 0x59792F) {
        return 0x188
    }
    if (hash == 0x597930) {
        return 0x189
    }
    if (hash == 0xB889E58) {
        return 0x18A
    }
    if (hash == 0xB889E59) {
        return 0x18B
    }
    if (hash == 0xB889E5A) {
        return 0x18C
    }
    if (hash == 0xB889E5B) {
        return 0x18D
    }
    if (hash == 0xB889E5C) {
        return 0x18E
    }
    if (hash == 0xB889E5D) {
        return 0x18F
    }
    if (hash == 0x5977BD) {
        return 0x340
    }
    if (hash == 0x59777B) {
        return 0x341
    }
    if (hash == 0x59798B) {
        return 0x342
    }
    if (hash == 0x59779C) {
        return 0x343
    }
    if (hash == 0x5977DE) {
        return 0x344
    }
    if (hash == 0x5977FF) {
        return 0x345
    }
    if (hash == 0xB8866EA) {
        return 0x480
    }
    if (hash == 0xB8866EC) {
        return 0x482
    }
    if (hash == 0xB8866ED) {
        return 0x483
    }
    if (hash == 0xB8866EE) {
        return 0x484
    }
    if (hash == 0xB8866F2) {
        return 0x488
    }
    if (hash == 0xB886B2B) {
        return 0x580
    }
    if (hash == 0xB886B2C) {
        return 0x581
    }
    if (hash == 0xB886B2D) {
        return 0x582
    }
    if (hash == 0xB886B2E) {
        return 0x583
    }
    if (hash == 0xB886B31) {
        return 0x586
    }
    if (hash == 0xB886B32) {
        return 0x587
    }
    return 0
}

fn asm_reg_width(I64 info) {
    I64 code = (info >> 5) & 7
    if (code == 1) {
        return 8
    }
    if (code == 2) {
        return 16
    }
    if (code == 3) {
        return 32
    }
    if (code == 4) {
        return 64
    }
    return 0
}

fn asm_parse_operand() {
    take()

    if (ct() == 2) {
        mem_write64(0x800550, 2)
        mem_write64(0x800558, cv())
        mem_write64(0x800560, 0)
        return 2
    }

    if (ct() == 4) {
        if (cv() == 45) {
            take()
            if (ct() != 2) {
                compiler_error(18) return 0
            }
            mem_write64(0x800550, 2)
            mem_write64(0x800558, 0 - cv())
            mem_write64(0x800560, 0)
            return 2
        }
    }

    if (ct() == 1) {
        I64 info = asm_reg_info(chash())
        if (info != 0) {
            mem_write64(0x800550, 1)
            mem_write64(0x800558, 0)
            mem_write64(0x800560, info)
            return 1
        }

        mem_write64(0x800550, 3)
        mem_write64(0x800558, chash())
        mem_write64(0x800560, 0)
        return 3
    }

    compiler_error(18)
    return 0
}

fn asm_register_label(I64 hash, I64 position) {
    I64 count = mem_read64(0x800540)
    I64 i = 0
    while (i < count) {
        I64 entry = 0x826820 + i * 16
        if (mem_read64(entry) == hash) {
            compiler_error(20)
            return 0
        }
        i = i + 1
    }

    if (count >= 382) {
        fail() return 0
    }

    I64 entry2 = 0x826820 + count * 16
    mem_write64(entry2, hash)
    mem_write64(entry2 + 8, position)
    mem_write64(0x800540, count + 1)
    return position
}

fn asm_find_label(I64 hash) {
    I64 count = mem_read64(0x800540)
    I64 i = 0
    while (i < count) {
        I64 entry = 0x826820 + i * 16
        if (mem_read64(entry) == hash) {
            return mem_read64(entry + 8) + 1
        }
        i = i + 1
    }
    return 0
}

fn asm_add_fixup(I64 hash, I64 patch, I64 kind) {
    I64 count = mem_read64(0x800040)
    if (count >= 8192) {
        fail() return 0
    }

    I64 entry = 0x740000 + count * 24
    mem_write64(entry, hash)
    mem_write64(entry + 8, patch)
    mem_write64(entry + 16, kind)
    mem_write64(0x800040, count + 1)
    return patch
}

fn asm_rex(I64 width, I64 regcode, I64 rmcode, I64 force) {
    if (mem_read64(0x800508) != 64) {
        return 0
    }

    I64 rex = 0x40
    if (width == 64) {
        rex = rex | 8
    }
    if (regcode >= 8) {
        rex = rex | 4
    }
    if (rmcode >= 8) {
        rex = rex | 1
    }

    if (rex != 0x40) {
        asm_put8(rex)
        return rex
    }

    if (force != 0) {
        asm_put8(rex)
        return rex
    }

    return 0
}

fn asm_opsize(I64 width) {
    I64 bits = mem_read64(0x800508)

    if (width == 16) {
        if (bits != 16) {
            asm_put8(0x66)
        }
        return 0
    }

    if (width == 32) {
        if (bits == 16) {
            asm_put8(0x66)
        }
        return 0
    }

    if (width == 64) {
        if (bits != 64) {
            compiler_error(18) return 0
        }
        return 0
    }

    return 0
}

fn asm_emit_reg_reg(I64 opcode8, I64 opcodewide, I64 dest, I64 source) {
    I64 dkind = (dest >> 8) & 15
    I64 skind = (source >> 8) & 15
    I64 dw = asm_reg_width(dest)
    I64 sw = asm_reg_width(source)
    I64 dc = dest & 31
    I64 sc = source & 31

    if (dw != sw) {
        compiler_error(18) return 0
    }
    if (dkind > 2) {
        compiler_error(18) return 0
    }
    if (skind > 2) {
        compiler_error(18) return 0
    }

    I64 bits = mem_read64(0x800508)

    if (dc >= 8) {
        if (bits != 64) {
            compiler_error(18) return 0
        }
    }
    if (sc >= 8) {
        if (bits != 64) {
            compiler_error(18) return 0
        }
    }

    if (dw == 8) {
        if (dkind == 1) {
            if (dc >= 4) {
                if (bits != 64) {
                    compiler_error(18) return 0
                }
            }
        }
        if (skind == 1) {
            if (sc >= 4) {
                if (bits != 64) {
                    compiler_error(18) return 0
                }
            }
        }
    }

    if (dkind == 2) {
        if (skind == 1) {
            if (sc >= 4) {
                compiler_error(18) return 0
            }
        }
    }
    if (skind == 2) {
        if (dkind == 1) {
            if (dc >= 4) {
                compiler_error(18) return 0
            }
        }
    }

    if (dw != 8) {
        asm_opsize(dw)
    }

    I64 force = 0
    if (dw == 8) {
        if (dkind == 1) {
            if (dc >= 4) {
                force = 1
            }
        }
        if (skind == 1) {
            if (sc >= 4) {
                force = 1
            }
        }
        if (dkind == 2) {
            force = 0
        }
        if (skind == 2) {
            force = 0
        }
    }

    asm_rex(dw, sc, dc, force)

    if (dw == 8) {
        asm_put8(opcode8)
    }
    if (dw != 8) {
        asm_put8(opcodewide)
    }

    asm_put8(0xC0 + ((sc & 7) * 8) + (dc & 7))
    return 1
}

fn asm_emit_mov_imm(I64 dest, I64 kind, I64 value) {
    I64 dkind = (dest >> 8) & 15
    I64 width = asm_reg_width(dest)
    I64 code = dest & 31

    if (dkind > 2) {
        compiler_error(18) return 0
    }
    I64 bits = mem_read64(0x800508)

    if (code >= 8) {
        if (bits != 64) {
            compiler_error(18) return 0
        }
    }

    if (width == 8) {
        if (kind == 3) {
            compiler_error(18) return 0
        }
        if (value > 255) {
            compiler_error(21) return 0
        }

        I64 force = 0

        if (dkind == 1) {
            if (code >= 4) {
                if (bits != 64) {
                    compiler_error(18) return 0
                }
                force = 1
            }
        }

        if (dkind == 2) {
            force = 0
        }

        asm_rex(8, 0, code, force)
        asm_put2(0xB0 + (code & 7), value)
        return 1
    }

    asm_opsize(width)
    asm_rex(width, 0, code, 0)
    asm_put8(0xB8 + (code & 7))

    I64 patch = mem_read64(0x800090)

    if (width == 16) {
        if (kind == 2) {
            if (value > 65535) {
                compiler_error(21) return 0
            }
        }
        if (kind == 3) {
            asm_add_fixup(value, patch, 0 - 3)
        }
        asm_put16(0)
        if (kind == 2) {
            patch16_at(patch, value)
        }
        return 1
    }

    if (width == 32) {
        if (kind == 2) {
            if (value > 0xFFFFFFFF) {
                compiler_error(21) return 0
            }
        }
        if (kind == 3) {
            asm_add_fixup(value, patch, 0 - 4)
        }
        asm_put32(0)
        if (kind == 2) {
            patch32_at(patch, value)
        }
        return 1
    }

    if (width == 64) {
        if (kind == 3) {
            asm_add_fixup(value, patch, 0 - 5)
        }
        asm_put64(0)
        if (kind == 2) {
            patch64_at(patch, value)
        }
        return 1
    }

    compiler_error(18)
    return 0
}

fn asm_emit_mov(I64 dest_kind, I64 dest_value, I64 source_kind, I64 source_value) {
    if (dest_kind != 1) {
        compiler_error(18) return 0
    }

    I64 dest = dest_value
    I64 dkind = (dest >> 8) & 15

    if (source_kind == 2) {
        return asm_emit_mov_imm(dest, 2, source_value)
    }

    if (source_kind == 3) {
        return asm_emit_mov_imm(dest, 3, source_value)
    }

    if (source_kind != 1) {
        compiler_error(18) return 0
    }

    I64 source = source_value
    I64 skind = (source >> 8) & 15

    if (dkind <= 2) {
        if (skind <= 2) {
            return asm_emit_reg_reg(0x88, 0x89, dest, source)
        }
    }

    if (dkind == 3) {
        if (skind == 1) {
            I64 sw = asm_reg_width(source)
            if (sw != 16) {
                compiler_error(18) return 0
            }
            I64 seg = dest & 7
            I64 scode = source & 31
            if (seg == 1) {
                compiler_error(18) return 0
            }
            if (scode >= 8) {
                if (mem_read64(0x800508) != 64) {
                    compiler_error(18) return 0
                }
            }
            asm_rex(0, 0, scode, 0)
            asm_put2(0x8E, 0xC0 + seg * 8 + (scode & 7))
            return 1
        }
    }

    if (dkind == 1) {
        if (skind == 3) {
            I64 dw = asm_reg_width(dest)
            if (dw != 16) {
                compiler_error(18) return 0
            }
            I64 dcode = dest & 31
            if (dcode >= 8) {
                if (mem_read64(0x800508) != 64) {
                    compiler_error(18) return 0
                }
            }
            asm_rex(0, 0, dcode, 0)
            asm_put2(0x8C, 0xC0 + (source & 7) * 8 + (dcode & 7))
            return 1
        }
    }

    if (dkind == 4) {
        if (skind == 1) {
            I64 bits = mem_read64(0x800508)
            if ((dest & 31) == 8) {
                if (bits != 64) {
                    compiler_error(18) return 0
                }
            }
            I64 sw2 = asm_reg_width(source)
            if ((source & 31) >= 8) {
                if (bits != 64) {
                    compiler_error(18) return 0
                }
            }
            if (bits == 64) {
                if (sw2 != 64) {
                    compiler_error(18) return 0
                }
            }
            if (bits != 64) {
                if (sw2 != 32) {
                    compiler_error(18) return 0
                }
            }
            asm_rex(0, dest & 31, source & 31, 0)
            asm_put3(0x0F, 0x22, 0xC0 + ((dest & 7) * 8) + (source & 7))
            return 1
        }
    }

    if (dkind == 1) {
        if (skind == 4) {
            I64 bits2 = mem_read64(0x800508)
            if ((source & 31) == 8) {
                if (bits2 != 64) {
                    compiler_error(18) return 0
                }
            }
            I64 dw2 = asm_reg_width(dest)
            if ((dest & 31) >= 8) {
                if (bits2 != 64) {
                    compiler_error(18) return 0
                }
            }
            if (bits2 == 64) {
                if (dw2 != 64) {
                    compiler_error(18) return 0
                }
            }
            if (bits2 != 64) {
                if (dw2 != 32) {
                    compiler_error(18) return 0
                }
            }
            asm_rex(0, source & 31, dest & 31, 0)
            asm_put3(0x0F, 0x20, 0xC0 + ((source & 7) * 8) + (dest & 7))
            return 1
        }
    }

    if (dkind == 5) {
        if (skind == 1) {
            I64 bits3 = mem_read64(0x800508)
            if (bits3 == 16) {
                compiler_error(18) return 0
            }
            I64 sw3 = asm_reg_width(source)
            if (bits3 == 32) {
                if (sw3 != 32) {
                    compiler_error(18) return 0
                }
            }
            if (bits3 == 64) {
                if (sw3 != 64) {
                    compiler_error(18) return 0
                }
            }
            if ((source & 31) >= 8) {
                if (bits3 != 64) {
                    compiler_error(18) return 0
                }
            }
            asm_rex(0, dest & 31, source & 31, 0)
            asm_put3(0x0F, 0x23, 0xC0 + ((dest & 7) * 8) + (source & 7))
            return 1
        }
    }

    if (dkind == 1) {
        if (skind == 5) {
            I64 bits4 = mem_read64(0x800508)
            if (bits4 == 16) {
                compiler_error(18) return 0
            }
            I64 dw4 = asm_reg_width(dest)
            if (bits4 == 32) {
                if (dw4 != 32) {
                    compiler_error(18) return 0
                }
            }
            if (bits4 == 64) {
                if (dw4 != 64) {
                    compiler_error(18) return 0
                }
            }
            if ((dest & 31) >= 8) {
                if (bits4 != 64) {
                    compiler_error(18) return 0
                }
            }
            asm_rex(0, source & 31, dest & 31, 0)
            asm_put3(0x0F, 0x21, 0xC0 + ((source & 7) * 8) + (dest & 7))
            return 1
        }
    }

    compiler_error(18)
    return 0
}

fn asm_emit_binop(I64 opcode8, I64 opcodewide, I64 group, I64 dest, I64 source_kind, I64 source_value) {
    I64 dkind = (dest >> 8) & 15
    I64 width = asm_reg_width(dest)
    I64 dc = dest & 31

    if (dkind > 2) {
        compiler_error(18) return 0
    }
    if (dc >= 8) {
        if (mem_read64(0x800508) != 64) {
            compiler_error(18) return 0
        }
    }
    if (dkind == 2) {
        if (width != 8) {
            compiler_error(18) return 0
        }
    }
    if (width == 8) {
        if (dkind == 1) {
            if (dc >= 4) {
                if (mem_read64(0x800508) != 64) {
                    compiler_error(18) return 0
                }
            }
        }
    }

    if (source_kind == 1) {
        return asm_emit_reg_reg(opcode8, opcodewide, dest, source_value)
    }

    if (source_kind != 2) {
        compiler_error(18) return 0
    }

    if (width != 8) {
        asm_opsize(width)
    }

    I64 force = 0
    if (width == 8) {
        if (dkind == 1) {
            if (dc >= 4) {
                force = 1
            }
        }
    }

    asm_rex(width, group, dc, force)

    if (width == 8) {
        asm_put3(0x80, 0xC0 + group * 8 + (dc & 7), source_value)
        return 1
    }

    asm_put2(0x81, 0xC0 + group * 8 + (dc & 7))

    if (width == 16) {
        asm_put16(source_value) return 1
    }
    asm_put32(source_value)
    return 1
}

fn asm_emit_shift(I64 group, I64 reg, I64 amount) {
    I64 kind = (reg >> 8) & 15
    I64 width = asm_reg_width(reg)
    I64 code = reg & 31
    if (kind > 2) {
        compiler_error(18) return 0
    }
    if (code >= 8) {
        if (mem_read64(0x800508) != 64) {
            compiler_error(18) return 0
        }
    }
    if (kind == 2) {
        if (width != 8) {
            compiler_error(18) return 0
        }
    }
    if (width == 8) {
        if (kind == 1) {
            if (code >= 4) {
                if (mem_read64(0x800508) != 64) {
                    compiler_error(18) return 0
                }
            }
        }
    }

    if (width != 8) {
        asm_opsize(width)
    }

    I64 force = 0
    if (width == 8) {
        if (kind == 1) {
            if (code >= 4) {
                force = 1
            }
        }
    }

    asm_rex(width, group, code, force)

    if (width == 8) {
        asm_put8(0xC0)
    }
    if (width != 8) {
        asm_put8(0xC1)
    }

    asm_put2(0xC0 + group * 8 + (code & 7), amount)
    return 1
}

fn asm_emit_pushpop(I64 reg, I64 pop) {
    I64 kind = (reg >> 8) & 15
    I64 width = asm_reg_width(reg)
    I64 code = reg & 31
    I64 bits = mem_read64(0x800508)

    if (kind != 1) {
        compiler_error(18) return 0
    }
    if (width == 8) {
        compiler_error(18) return 0
    }
    if (code >= 8) {
        if (bits != 64) {
            compiler_error(18) return 0
        }
    }

    if (bits == 16) {
        if (width == 32) {
            asm_put8(0x66)
        }
        if (width == 64) {
            compiler_error(18) return 0
        }
    }

    if (bits == 32) {
        if (width == 16) {
            asm_put8(0x66)
        }
        if (width == 64) {
            compiler_error(18) return 0
        }
    }

    if (bits == 64) {
        if (width == 16) {
            asm_put8(0x66)
        }
        if (width == 32) {
            compiler_error(18) return 0
        }
        asm_rex(0, 0, code, 0)
    }

    if (pop == 0) {
        asm_put8(0x50 + (code & 7))
    }
    if (pop != 0) {
        asm_put8(0x58 + (code & 7))
    }

    return 1
}

fn asm_emit_incdec(I64 reg, I64 dec) {
    I64 kind = (reg >> 8) & 15
    I64 width = asm_reg_width(reg)
    I64 code = reg & 31
    if (kind > 2) {
        compiler_error(18) return 0
    }
    if (code >= 8) {
        if (mem_read64(0x800508) != 64) {
            compiler_error(18) return 0
        }
    }
    if (kind == 2) {
        if (width != 8) {
            compiler_error(18) return 0
        }
    }
    if (width == 8) {
        if (kind == 1) {
            if (code >= 4) {
                if (mem_read64(0x800508) != 64) {
                    compiler_error(18) return 0
                }
            }
        }
    }

    if (width != 8) {
        asm_opsize(width)
    }

    I64 force = 0
    if (width == 8) {
        if (kind == 1) {
            if (code >= 4) {
                force = 1
            }
        }
    }

    asm_rex(width, dec, code, force)

    if (width == 8) {
        asm_put8(0xFE)
    }
    if (width != 8) {
        asm_put8(0xFF)
    }

    asm_put8(0xC0 + dec * 8 + (code & 7))
    return 1
}

fn asm_emit_branch(I64 opcode, I64 hash) {
    I64 bits = mem_read64(0x800508)

    if (bits == 16) {
        if (opcode >= 0x80) {
            asm_put2(0x0F, opcode)
        }
        if (opcode == 0xE8) {
            asm_put8(0xE8)
        }
        if (opcode == 0xE9) {
            asm_put8(0xE9)
        }

        I64 patch = mem_read64(0x800090)
        asm_put16(0)
        asm_add_fixup(hash, patch, 0 - 1)
        return 1
    }

    if (bits == 32) {
        if (opcode >= 0x80) {
            asm_put2(0x0F, opcode)
        }
        if (opcode == 0xE8) {
            asm_put8(0xE8)
        }
        if (opcode == 0xE9) {
            asm_put8(0xE9)
        }

        I64 patch2 = mem_read64(0x800090)
        asm_put32(0)
        asm_add_fixup(hash, patch2, 0 - 2)
        return 1
    }

    if (bits == 64) {
        if (opcode >= 0x80) {
            asm_put2(0x0F, opcode)
        }
        if (opcode == 0xE8) {
            asm_put8(0xE8)
        }
        if (opcode == 0xE9) {
            asm_put8(0xE9)
        }

        I64 patch3 = mem_read64(0x800090)
        asm_put32(0)
        asm_add_fixup(hash, patch3, 0 - 2)
        return 1
    }

    compiler_error(17)
    return 0
}

fn asm_emit_far_jump(I64 selector, I64 target_kind, I64 target) {
    I64 bits = mem_read64(0x800508)

    if (bits == 16) {
        if (target_kind == 2) {
            if (target > 65535) {
                compiler_error(21) return 0
            }
        }
        asm_put8(0xEA)
        I64 patch = mem_read64(0x800090)
        asm_put16(0)
        if (target_kind == 2) {
            patch16_at(patch, target)
        }
        if (target_kind == 3) {
            asm_add_fixup(target, patch, 0 - 3)
        }
        asm_put16(selector)
        return 1
    }

    if (bits == 32) {
        if (target_kind == 2) {
            if (target > 0xFFFFFFFF) {
                compiler_error(21) return 0
            }
        }
        asm_put8(0xEA)
        I64 patch2 = mem_read64(0x800090)
        asm_put32(0)
        if (target_kind == 2) {
            patch32_at(patch2, target)
        }
        if (target_kind == 3) {
            asm_add_fixup(target, patch2, 0 - 4)
        }
        asm_put16(selector)
        return 1
    }

    compiler_error(18)
    return 0
}

fn asm_emit_abs_memory(I64 op, I64 reg, I64 address_kind, I64 address) {
    I64 bits = mem_read64(0x800508)
    I64 kind = (reg >> 8) & 15
    I64 width = asm_reg_width(reg)
    I64 code = reg & 31

    if (kind > 2) {
        compiler_error(18) return 0
    }
    if (code >= 8) {
        if (bits != 64) {
            compiler_error(18) return 0
        }
    }
    if (width == 8) {
        if (kind == 1) {
            if (code >= 4) {
                if (bits != 64) {
                    compiler_error(18) return 0
                }
            }
        }
    }

    I64 wanted = op
    if (wanted == 1) {
        wanted = 8
    }
    if (wanted == 2) {
        wanted = 16
    }
    if (wanted == 3) {
        wanted = 32
    }
    if (wanted == 4) {
        wanted = 64
    }

    if (width != wanted) {
        compiler_error(18) return 0
    }

    if (width != 8) {
        asm_opsize(width)
    }
    I64 force = 0
    if (width == 8) {
        if (kind == 1) {
            if (code >= 4) {
                force = 1
            }
        }
    }
    asm_rex(width, code, 0, force)

    if (width == 8) {
        asm_put8(0x8A)
    }
    if (width != 8) {
        asm_put8(0x8B)
    }

    if (bits == 16) {
        asm_put8(((code & 7) * 8) + 6)
        I64 patch = mem_read64(0x800090)
        asm_put16(0)
        if (address_kind == 2) {
            patch16_at(patch, address)
        }
        if (address_kind == 3) {
            asm_add_fixup(address, patch, 0 - 3)
        }
        return 1
    }

    if (bits == 32) {
        asm_put8(((code & 7) * 8) + 5)
        I64 patch2 = mem_read64(0x800090)
        asm_put32(0)
        if (address_kind == 2) {
            patch32_at(patch2, address)
        }
        if (address_kind == 3) {
            asm_add_fixup(address, patch2, 0 - 4)
        }
        return 1
    }

    if (bits == 64) {
        asm_put2(((code & 7) * 8) + 4, 0x25)
        I64 patch3 = mem_read64(0x800090)
        asm_put32(0)
        if (address_kind == 2) {
            patch32_at(patch3, address)
        }
        if (address_kind == 3) {
            asm_add_fixup(address, patch3, 0 - 4)
        }
        return 1
    }

    compiler_error(17)
    return 0
}

fn asm_emit_store_imm(I64 size_id, I64 address_kind, I64 address, I64 value) {
    I64 bits = mem_read64(0x800508)
    I64 width = 8
    if (size_id == 2) {
        width = 16
    }
    if (size_id == 3) {
        width = 32
    }

    if (width == 8) {
        if (value > 255) {
            compiler_error(21) return 0
        }
    }
    if (width == 16) {
        if (value > 65535) {
            compiler_error(21) return 0
        }
    }
    if (width == 32) {
        if (value > 0xFFFFFFFF) {
            compiler_error(21) return 0
        }
    }

    if (width != 8) {
        asm_opsize(width)
    }

    if (width == 8) {
        asm_put8(0xC6)
    }
    if (width != 8) {
        asm_put8(0xC7)
    }

    if (bits == 16) {
        asm_put8(0x06)
        I64 patch = mem_read64(0x800090)
        asm_put16(0)
        if (address_kind == 2) {
            patch16_at(patch, address)
        }
        if (address_kind == 3) {
            asm_add_fixup(address, patch, 0 - 3)
        }
    }

    if (bits == 32) {
        asm_put8(0x05)
        I64 patch2 = mem_read64(0x800090)
        asm_put32(0)
        if (address_kind == 2) {
            patch32_at(patch2, address)
        }
        if (address_kind == 3) {
            asm_add_fixup(address, patch2, 0 - 4)
        }
    }

    if (bits == 64) {
        asm_put2(0x04, 0x25)
        I64 patch3 = mem_read64(0x800090)
        asm_put32(0)
        if (address_kind == 2) {
            patch32_at(patch3, address)
        }
        if (address_kind == 3) {
            asm_add_fixup(address, patch3, 0 - 4)
        }
    }

    if (bits == 0) {
        compiler_error(17) return 0
    }

    if (width == 8) {
        asm_put8(value)
    }
    if (width == 16) {
        asm_put16(value)
    }
    if (width == 32) {
        asm_put32(value)
    }

    return 1
}

fn asm_emit_store_reg(I64 size_id, I64 address_kind, I64 address, I64 reg) {
    I64 bits = mem_read64(0x800508)
    I64 kind = (reg >> 8) & 15
    I64 width = asm_reg_width(reg)
    I64 code = reg & 31
    I64 wanted = 8

    if (size_id == 2) {
        wanted = 16
    }
    if (size_id == 3) {
        wanted = 32
    }
    if (size_id == 4) {
        wanted = 64
    }

    if (kind > 2) {
        compiler_error(18) return 0
    }
    if (code >= 8) {
        if (bits != 64) {
            compiler_error(18) return 0
        }
    }
    if (width != wanted) {
        compiler_error(18) return 0
    }

    if (width == 8) {
        if (kind == 1) {
            if (code >= 4) {
                if (bits != 64) {
                    compiler_error(18) return 0
                }
            }
        }
    }

    if (width != 8) {
        asm_opsize(width)
    }

    I64 force = 0
    if (width == 8) {
        if (kind == 1) {
            if (code >= 4) {
                force = 1
            }
        }
    }

    asm_rex(width, code, 0, force)

    if (width == 8) {
        asm_put8(0x88)
    }
    if (width != 8) {
        asm_put8(0x89)
    }

    if (bits == 16) {
        asm_put8(((code & 7) * 8) + 6)
        I64 patch = mem_read64(0x800090)
        asm_put16(0)
        if (address_kind == 2) {
            patch16_at(patch, address)
        }
        if (address_kind == 3) {
            asm_add_fixup(address, patch, 0 - 3)
        }
        return 1
    }

    if (bits == 32) {
        asm_put8(((code & 7) * 8) + 5)
        I64 patch2 = mem_read64(0x800090)
        asm_put32(0)
        if (address_kind == 2) {
            patch32_at(patch2, address)
        }
        if (address_kind == 3) {
            asm_add_fixup(address, patch2, 0 - 4)
        }
        return 1
    }

    if (bits == 64) {
        asm_put2(((code & 7) * 8) + 4, 0x25)
        I64 patch3 = mem_read64(0x800090)
        asm_put32(0)
        if (address_kind == 2) {
            patch32_at(patch3, address)
        }
        if (address_kind == 3) {
            asm_add_fixup(address, patch3, 0 - 4)
        }
        return 1
    }

    compiler_error(17)
    return 0
}

fn asm_emit_selector_op(I64 group, I64 reg) {
    I64 kind = (reg >> 8) & 15
    I64 width = asm_reg_width(reg)
    I64 code = reg & 31
    I64 bits = mem_read64(0x800508)

    if (kind != 1) {
        compiler_error(18) return 0
    }
    if (width != 16) {
        compiler_error(18) return 0
    }
    if (code >= 8) {
        if (bits != 64) {
            compiler_error(18) return 0
        }
    }

    asm_rex(0, 0, code, 0)
    asm_put3(0x0F, 0x00, 0xC0 + group * 8 + (code & 7))
    return 1
}

fn asm_emit_indirect(I64 reg, I64 call_mode) {
    I64 kind = (reg >> 8) & 15
    I64 width = asm_reg_width(reg)
    I64 code = reg & 31
    I64 bits = mem_read64(0x800508)

    if (kind != 1) {
        compiler_error(18) return 0
    }
    if (code >= 8) {
        if (bits != 64) {
            compiler_error(18) return 0
        }
    }

    if (bits == 16) {
        if (width != 16) {
            compiler_error(18) return 0
        }
    }

    if (bits == 32) {
        if (width != 32) {
            compiler_error(18) return 0
        }
    }

    if (bits == 64) {
        if (width != 64) {
            compiler_error(18) return 0
        }
        asm_rex(0, 0, code, 0)
    }

    if (bits == 0) {
        compiler_error(17) return 0
    }

    asm_put8(0xFF)

    I64 group = 4
    if (call_mode != 0) {
        group = 2
    }

    asm_put8(0xC0 + group * 8 + (code & 7))
    return 1
}

fn asm_emit_lgdt_lidt(I64 idt, I64 address_kind, I64 address) {
    I64 bits = mem_read64(0x800508)

    asm_put2(0x0F, 0x01)

    I64 group = 2
    if (idt != 0) {
        group = 3
    }

    if (bits == 16) {
        asm_put8(group * 8 + 6)
        I64 patch = mem_read64(0x800090)
        asm_put16(0)
        if (address_kind == 2) {
            patch16_at(patch, address)
        }
        if (address_kind == 3) {
            asm_add_fixup(address, patch, 0 - 3)
        }
        return 1
    }

    if (bits == 32) {
        asm_put8(group * 8 + 5)
        I64 patch2 = mem_read64(0x800090)
        asm_put32(0)
        if (address_kind == 2) {
            patch32_at(patch2, address)
        }
        if (address_kind == 3) {
            asm_add_fixup(address, patch2, 0 - 4)
        }
        return 1
    }

    if (bits == 64) {
        asm_put2(group * 8 + 4, 0x25)
        I64 patch3 = mem_read64(0x800090)
        asm_put32(0)
        if (address_kind == 2) {
            patch32_at(patch3, address)
        }
        if (address_kind == 3) {
            asm_add_fixup(address, patch3, 0 - 4)
        }
        return 1
    }

    compiler_error(17)
    return 0
}

fn asm_emit_in(I64 dest, I64 port_kind, I64 port_value) {
    I64 width = asm_reg_width(dest)
    I64 code = dest & 31
    I64 kind = (dest >> 8) & 15

    if (kind > 2) {
        compiler_error(18) return 0
    }
    if (code != 0) {
        compiler_error(18) return 0
    }
    if (width == 64) {
        compiler_error(18) return 0
    }

    if (width != 8) {
        asm_opsize(width)
    }

    if (port_kind == 2) {
        if (port_value > 255) {
            compiler_error(18) return 0
        }
        if (width == 8) {
            asm_put8(0xE4)
        }
        if (width != 8) {
            asm_put8(0xE5)
        }
        asm_put8(port_value)
        return 1
    }

    if (port_kind == 1) {
        I64 pwidth = asm_reg_width(port_value)
        I64 pcode = port_value & 31
        I64 pkind = (port_value >> 8) & 15
        if (pkind != 1) {
            compiler_error(18) return 0
        }
        if (pwidth != 16) {
            compiler_error(18) return 0
        }
        if (pcode != 2) {
            compiler_error(18) return 0
        }

        if (width == 8) {
            asm_put8(0xEC)
        }
        if (width != 8) {
            asm_put8(0xED)
        }
        return 1
    }

    compiler_error(18)
    return 0
}

fn asm_emit_out(I64 port_kind, I64 port_value, I64 source) {
    I64 width = asm_reg_width(source)
    I64 code = source & 31
    I64 kind = (source >> 8) & 15

    if (kind > 2) {
        compiler_error(18) return 0
    }
    if (code != 0) {
        compiler_error(18) return 0
    }
    if (width == 64) {
        compiler_error(18) return 0
    }

    if (width != 8) {
        asm_opsize(width)
    }

    if (port_kind == 2) {
        if (port_value > 255) {
            compiler_error(18) return 0
        }
        if (width == 8) {
            asm_put8(0xE6)
        }
        if (width != 8) {
            asm_put8(0xE7)
        }
        asm_put8(port_value)
        return 1
    }

    if (port_kind == 1) {
        I64 pwidth = asm_reg_width(port_value)
        I64 pcode = port_value & 31
        I64 pkind = (port_value >> 8) & 15
        if (pkind != 1) {
            compiler_error(18) return 0
        }
        if (pwidth != 16) {
            compiler_error(18) return 0
        }
        if (pcode != 2) {
            compiler_error(18) return 0
        }

        if (width == 8) {
            asm_put8(0xEE)
        }
        if (width != 8) {
            asm_put8(0xEF)
        }
        return 1
    }

    compiler_error(18)
    return 0
}

fn parse_inline_asm() {
    if (mem_read64(os_safe_mode_addr()) != 0) {
        compiler_error(22)
        return 0
    }

    if (use_asm_feature() == 0) {
        return 0
    }

    expect_word("asmb")
    expect_sym(41)
    expect_sym(123)

    I64 done = 0

    while (done == 0) {
        take()

        if (ct() == 4) {
            if (cv() == 125) {
                done = 1
            }
        }

        if (done == 0) {
            if (ct() != 1) {
                compiler_error(18)
                return 0
            }

            I64 handled = 0

            if (tok_is("bits16") != 0) {
                if ((mem_read64(0x8000A0) & 1) == 0) {
                    compiler_error(17) return 0
                }
                mem_write64(0x800508, 16)
                handled = 1
            }

            if (tok_is("bits32") != 0) {
                if ((mem_read64(0x8000A0) & 2) == 0) {
                    compiler_error(17) return 0
                }
                mem_write64(0x800508, 32)
                handled = 1
            }

            if (tok_is("bits64") != 0) {
                if ((mem_read64(0x8000A0) & 4) == 0) {
                    compiler_error(17) return 0
                }
                mem_write64(0x800508, 64)
                handled = 1
            }

            if (tok_is("org") != 0) {
                handled = 1
                if (mem_read64(0x800518) != 0) {
                    compiler_error(18) return 0
                }
                expect_sym(40)
                take()
                if (ct() != 2) {
                    compiler_error(18) return 0
                }
                mem_write64(0x800510, cv())
                mem_write64(0x800518, 1)
                expect_sym(41)
            }

            if (tok_is("label") != 0) {
                handled = 1
                expect_sym(40)
                take()
                if (ct() != 1) {
                    compiler_error(18) return 0
                }
                asm_register_label(chash(), mem_read64(0x800090))
                expect_sym(41)
            }

            if (tok_is("mov") != 0) {
                handled = 1
                expect_sym(40)

                asm_parse_operand()
                I64 dk = mem_read64(0x800550)
                I64 dv = mem_read64(0x800558)
                if (dk == 1) {
                    dv = mem_read64(0x800560)
                }

                expect_sym(44)

                asm_parse_operand()
                I64 sk = mem_read64(0x800550)
                I64 sv = mem_read64(0x800558)
                if (sk == 1) {
                    sv = mem_read64(0x800560)
                }

                expect_sym(41)

                asm_emit_mov(dk, dv, sk, sv)
            }

            if (tok_is("add") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                I64 dk2 = mem_read64(0x800550)
                I64 dv2 = mem_read64(0x800560)
                if (dk2 != 1) {
                    compiler_error(18) return 0
                }
                expect_sym(44)
                asm_parse_operand()
                I64 sk2 = mem_read64(0x800550)
                I64 sv2 = mem_read64(0x800558)
                if (sk2 == 1) {
                    sv2 = mem_read64(0x800560)
                }
                expect_sym(41)
                asm_emit_binop(0x00, 0x01, 0, dv2, sk2, sv2)
            }

            if (tok_is("or") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                I64 dk3 = mem_read64(0x800550)
                I64 dv3 = mem_read64(0x800560)
                if (dk3 != 1) {
                    compiler_error(18) return 0
                }
                expect_sym(44)
                asm_parse_operand()
                I64 sk3 = mem_read64(0x800550)
                I64 sv3 = mem_read64(0x800558)
                if (sk3 == 1) {
                    sv3 = mem_read64(0x800560)
                }
                expect_sym(41)
                asm_emit_binop(0x08, 0x09, 1, dv3, sk3, sv3)
            }

            if (tok_is("and") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                I64 dk4 = mem_read64(0x800550)
                I64 dv4 = mem_read64(0x800560)
                if (dk4 != 1) {
                    compiler_error(18) return 0
                }
                expect_sym(44)
                asm_parse_operand()
                I64 sk4 = mem_read64(0x800550)
                I64 sv4 = mem_read64(0x800558)
                if (sk4 == 1) {
                    sv4 = mem_read64(0x800560)
                }
                expect_sym(41)
                asm_emit_binop(0x20, 0x21, 4, dv4, sk4, sv4)
            }

            if (tok_is("sub") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                I64 dk5 = mem_read64(0x800550)
                I64 dv5 = mem_read64(0x800560)
                if (dk5 != 1) {
                    compiler_error(18) return 0
                }
                expect_sym(44)
                asm_parse_operand()
                I64 sk5 = mem_read64(0x800550)
                I64 sv5 = mem_read64(0x800558)
                if (sk5 == 1) {
                    sv5 = mem_read64(0x800560)
                }
                expect_sym(41)
                asm_emit_binop(0x28, 0x29, 5, dv5, sk5, sv5)
            }

            if (tok_is("xor") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                I64 dk6 = mem_read64(0x800550)
                I64 dv6 = mem_read64(0x800560)
                if (dk6 != 1) {
                    compiler_error(18) return 0
                }
                expect_sym(44)
                asm_parse_operand()
                I64 sk6 = mem_read64(0x800550)
                I64 sv6 = mem_read64(0x800558)
                if (sk6 == 1) {
                    sv6 = mem_read64(0x800560)
                }
                expect_sym(41)
                asm_emit_binop(0x30, 0x31, 6, dv6, sk6, sv6)
            }

            if (tok_is("cmp") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                I64 dk7 = mem_read64(0x800550)
                I64 dv7 = mem_read64(0x800560)
                if (dk7 != 1) {
                    compiler_error(18) return 0
                }
                expect_sym(44)
                asm_parse_operand()
                I64 sk7 = mem_read64(0x800550)
                I64 sv7 = mem_read64(0x800558)
                if (sk7 == 1) {
                    sv7 = mem_read64(0x800560)
                }
                expect_sym(41)
                asm_emit_binop(0x38, 0x39, 7, dv7, sk7, sv7)
            }

            if (tok_is("test") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                if (mem_read64(0x800550) != 1) {
                    compiler_error(18) return 0
                }
                I64 testdst = mem_read64(0x800560)
                expect_sym(44)
                asm_parse_operand()
                if (mem_read64(0x800550) != 1) {
                    compiler_error(18) return 0
                }
                I64 testsrc = mem_read64(0x800560)
                expect_sym(41)
                asm_emit_reg_reg(0x84, 0x85, testdst, testsrc)
            }

            if (tok_is("shl") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                if (mem_read64(0x800550) != 1) {
                    compiler_error(18) return 0
                }
                I64 shiftreg = mem_read64(0x800560)
                expect_sym(44)
                asm_parse_operand()
                if (mem_read64(0x800550) != 2) {
                    compiler_error(18) return 0
                }
                I64 shiftamt = mem_read64(0x800558)
                expect_sym(41)
                asm_emit_shift(4, shiftreg, shiftamt)
            }

            if (tok_is("shr") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                if (mem_read64(0x800550) != 1) {
                    compiler_error(18) return 0
                }
                I64 shiftreg2 = mem_read64(0x800560)
                expect_sym(44)
                asm_parse_operand()
                if (mem_read64(0x800550) != 2) {
                    compiler_error(18) return 0
                }
                I64 shiftamt2 = mem_read64(0x800558)
                expect_sym(41)
                asm_emit_shift(5, shiftreg2, shiftamt2)
            }

            if (tok_is("sar") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                if (mem_read64(0x800550) != 1) {
                    compiler_error(18) return 0
                }
                I64 shiftreg3 = mem_read64(0x800560)
                expect_sym(44)
                asm_parse_operand()
                if (mem_read64(0x800550) != 2) {
                    compiler_error(18) return 0
                }
                I64 shiftamt3 = mem_read64(0x800558)
                expect_sym(41)
                asm_emit_shift(7, shiftreg3, shiftamt3)
            }

            if (tok_is("push") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                if (mem_read64(0x800550) != 1) {
                    compiler_error(18) return 0
                }
                asm_emit_pushpop(mem_read64(0x800560), 0)
                expect_sym(41)
            }

            if (tok_is("pop") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                if (mem_read64(0x800550) != 1) {
                    compiler_error(18) return 0
                }
                asm_emit_pushpop(mem_read64(0x800560), 1)
                expect_sym(41)
            }

            if (tok_is("inc") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                if (mem_read64(0x800550) != 1) {
                    compiler_error(18) return 0
                }
                asm_emit_incdec(mem_read64(0x800560), 0)
                expect_sym(41)
            }

            if (tok_is("dec") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                if (mem_read64(0x800550) != 1) {
                    compiler_error(18) return 0
                }
                asm_emit_incdec(mem_read64(0x800560), 1)
                expect_sym(41)
            }

            if (tok_is("sldt") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                if (mem_read64(0x800550) != 1) {
                    compiler_error(18) return 0
                }
                asm_emit_selector_op(0, mem_read64(0x800560))
                expect_sym(41)
            }

            if (tok_is("str") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                if (mem_read64(0x800550) != 1) {
                    compiler_error(18) return 0
                }
                asm_emit_selector_op(1, mem_read64(0x800560))
                expect_sym(41)
            }

            if (tok_is("lldt") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                if (mem_read64(0x800550) != 1) {
                    compiler_error(18) return 0
                }
                asm_emit_selector_op(2, mem_read64(0x800560))
                expect_sym(41)
            }

            if (tok_is("ltr") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                if (mem_read64(0x800550) != 1) {
                    compiler_error(18) return 0
                }
                asm_emit_selector_op(3, mem_read64(0x800560))
                expect_sym(41)
            }

            if (tok_is("int") != 0) {
                handled = 1
                expect_sym(40)
                take()
                if (ct() != 2) {
                    compiler_error(18) return 0
                }
                if (cv() > 255) {
                    compiler_error(18) return 0
                }
                asm_put2(0xCD, cv())
                expect_sym(41)
            }

            if (tok_is("jmp") != 0) {
                handled = 1
                expect_sym(40)
                take()
                if (ct() != 1) {
                    compiler_error(18) return 0
                }
                asm_emit_branch(0xE9, chash())
                expect_sym(41)
            }

            if (tok_is("call") != 0) {
                handled = 1
                expect_sym(40)
                take()
                if (ct() != 1) {
                    compiler_error(18) return 0
                }
                asm_emit_branch(0xE8, chash())
                expect_sym(41)
            }

            if (tok_is("jmp_reg") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                if (mem_read64(0x800550) != 1) {
                    compiler_error(18) return 0
                }
                asm_emit_indirect(mem_read64(0x800560), 0)
                expect_sym(41)
            }

            if (tok_is("call_reg") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                if (mem_read64(0x800550) != 1) {
                    compiler_error(18) return 0
                }
                asm_emit_indirect(mem_read64(0x800560), 1)
                expect_sym(41)
            }

            if (tok_is("je") != 0) {
                handled = 1
                expect_sym(40) take()
                if (ct() != 1) {
                    compiler_error(18) return 0
                }
                asm_emit_branch(0x84, chash()) expect_sym(41)
            }

            if (tok_is("jne") != 0) {
                handled = 1
                expect_sym(40) take()
                if (ct() != 1) {
                    compiler_error(18) return 0
                }
                asm_emit_branch(0x85, chash()) expect_sym(41)
            }

            if (tok_is("jz") != 0) {
                handled = 1
                expect_sym(40) take()
                if (ct() != 1) {
                    compiler_error(18) return 0
                }
                asm_emit_branch(0x84, chash()) expect_sym(41)
            }

            if (tok_is("jnz") != 0) {
                handled = 1
                expect_sym(40) take()
                if (ct() != 1) {
                    compiler_error(18) return 0
                }
                asm_emit_branch(0x85, chash()) expect_sym(41)
            }

            if (tok_is("jc") != 0) {
                handled = 1
                expect_sym(40) take()
                if (ct() != 1) {
                    compiler_error(18) return 0
                }
                asm_emit_branch(0x82, chash()) expect_sym(41)
            }

            if (tok_is("jnc") != 0) {
                handled = 1
                expect_sym(40) take()
                if (ct() != 1) {
                    compiler_error(18) return 0
                }
                asm_emit_branch(0x83, chash()) expect_sym(41)
            }

            if (tok_is("jb") != 0) {
                handled = 1
                expect_sym(40) take()
                if (ct() != 1) {
                    compiler_error(18) return 0
                }
                asm_emit_branch(0x82, chash()) expect_sym(41)
            }

            if (tok_is("jae") != 0) {
                handled = 1
                expect_sym(40) take()
                if (ct() != 1) {
                    compiler_error(18) return 0
                }
                asm_emit_branch(0x83, chash()) expect_sym(41)
            }

            if (tok_is("jbe") != 0) {
                handled = 1
                expect_sym(40) take()
                if (ct() != 1) {
                    compiler_error(18) return 0
                }
                asm_emit_branch(0x86, chash()) expect_sym(41)
            }

            if (tok_is("ja") != 0) {
                handled = 1
                expect_sym(40) take()
                if (ct() != 1) {
                    compiler_error(18) return 0
                }
                asm_emit_branch(0x87, chash()) expect_sym(41)
            }

            if (tok_is("jl") != 0) {
                handled = 1
                expect_sym(40) take()
                if (ct() != 1) {
                    compiler_error(18) return 0
                }
                asm_emit_branch(0x8C, chash()) expect_sym(41)
            }

            if (tok_is("jge") != 0) {
                handled = 1
                expect_sym(40) take()
                if (ct() != 1) {
                    compiler_error(18) return 0
                }
                asm_emit_branch(0x8D, chash()) expect_sym(41)
            }

            if (tok_is("jle") != 0) {
                handled = 1
                expect_sym(40) take()
                if (ct() != 1) {
                    compiler_error(18) return 0
                }
                asm_emit_branch(0x8E, chash()) expect_sym(41)
            }

            if (tok_is("jg") != 0) {
                handled = 1
                expect_sym(40) take()
                if (ct() != 1) {
                    compiler_error(18) return 0
                }
                asm_emit_branch(0x8F, chash()) expect_sym(41)
            }

            if (tok_is("jmp_far") != 0) {
                handled = 1
                expect_sym(40)
                take()
                if (ct() != 2) {
                    compiler_error(18) return 0
                }
                I64 selector = cv()
                expect_sym(44)
                asm_parse_operand()
                I64 fk = mem_read64(0x800550)
                I64 fv = mem_read64(0x800558)
                if (fk == 1) {
                    compiler_error(18) return 0
                }
                expect_sym(41)
                asm_emit_far_jump(selector, fk, fv)
            }

            if (tok_is("load8") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                if (mem_read64(0x800550) != 1) {
                    compiler_error(18) return 0
                }
                I64 lr8 = mem_read64(0x800560)
                expect_sym(44)
                asm_parse_operand()
                I64 lak8 = mem_read64(0x800550)
                I64 lav8 = mem_read64(0x800558)
                if (lak8 == 1) {
                    compiler_error(18) return 0
                }
                expect_sym(41)
                asm_emit_abs_memory(1, lr8, lak8, lav8)
            }

            if (tok_is("load16") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                if (mem_read64(0x800550) != 1) {
                    compiler_error(18) return 0
                }
                I64 lr16 = mem_read64(0x800560)
                expect_sym(44)
                asm_parse_operand()
                I64 lak16 = mem_read64(0x800550)
                I64 lav16 = mem_read64(0x800558)
                if (lak16 == 1) {
                    compiler_error(18) return 0
                }
                expect_sym(41)
                asm_emit_abs_memory(2, lr16, lak16, lav16)
            }

            if (tok_is("load32") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                if (mem_read64(0x800550) != 1) {
                    compiler_error(18) return 0
                }
                I64 lr32 = mem_read64(0x800560)
                expect_sym(44)
                asm_parse_operand()
                I64 lak32 = mem_read64(0x800550)
                I64 lav32 = mem_read64(0x800558)
                if (lak32 == 1) {
                    compiler_error(18) return 0
                }
                expect_sym(41)
                asm_emit_abs_memory(3, lr32, lak32, lav32)
            }

            if (tok_is("load64") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                if (mem_read64(0x800550) != 1) {
                    compiler_error(18) return 0
                }
                I64 lr64 = mem_read64(0x800560)
                expect_sym(44)
                asm_parse_operand()
                I64 lak64 = mem_read64(0x800550)
                I64 lav64 = mem_read64(0x800558)
                if (lak64 == 1) {
                    compiler_error(18) return 0
                }
                expect_sym(41)
                asm_emit_abs_memory(4, lr64, lak64, lav64)
            }

            if (tok_is("store8") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                I64 sak8 = mem_read64(0x800550)
                I64 sav8 = mem_read64(0x800558)
                if (sak8 == 1) {
                    compiler_error(18) return 0
                }
                expect_sym(44)
                asm_parse_operand()
                I64 sik8 = mem_read64(0x800550)
                I64 siv8 = mem_read64(0x800558)
                if (sik8 == 1) {
                    siv8 = mem_read64(0x800560)
                }
                expect_sym(41)
                if (sik8 == 1) {
                    asm_emit_store_reg(1, sak8, sav8, siv8)
                }
                if (sik8 == 2) {
                    asm_emit_store_imm(1, sak8, sav8, siv8)
                }
                if (sik8 == 3) {
                    compiler_error(18) return 0
                }
            }

            if (tok_is("store16") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                I64 sak16 = mem_read64(0x800550)
                I64 sav16 = mem_read64(0x800558)
                if (sak16 == 1) {
                    compiler_error(18) return 0
                }
                expect_sym(44)
                asm_parse_operand()
                I64 sik16 = mem_read64(0x800550)
                I64 siv16 = mem_read64(0x800558)
                if (sik16 == 1) {
                    siv16 = mem_read64(0x800560)
                }
                expect_sym(41)
                if (sik16 == 1) {
                    asm_emit_store_reg(2, sak16, sav16, siv16)
                }
                if (sik16 == 2) {
                    asm_emit_store_imm(2, sak16, sav16, siv16)
                }
                if (sik16 == 3) {
                    compiler_error(18) return 0
                }
            }

            if (tok_is("store32") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                I64 sak32 = mem_read64(0x800550)
                I64 sav32 = mem_read64(0x800558)
                if (sak32 == 1) {
                    compiler_error(18) return 0
                }
                expect_sym(44)
                asm_parse_operand()
                I64 sik32 = mem_read64(0x800550)
                I64 siv32 = mem_read64(0x800558)
                if (sik32 == 1) {
                    siv32 = mem_read64(0x800560)
                }
                expect_sym(41)
                if (sik32 == 1) {
                    asm_emit_store_reg(3, sak32, sav32, siv32)
                }
                if (sik32 == 2) {
                    asm_emit_store_imm(3, sak32, sav32, siv32)
                }
                if (sik32 == 3) {
                    compiler_error(18) return 0
                }
            }

            if (tok_is("store64") != 0) {
                handled = 1
                if (mem_read64(0x800508) != 64) {
                    compiler_error(18) return 0
                }
                expect_sym(40)
                asm_parse_operand()
                I64 sak64 = mem_read64(0x800550)
                I64 sav64 = mem_read64(0x800558)
                if (sak64 == 1) {
                    compiler_error(18) return 0
                }
                expect_sym(44)
                asm_parse_operand()
                if (mem_read64(0x800550) != 1) {
                    compiler_error(18) return 0
                }
                I64 siv64 = mem_read64(0x800560)
                expect_sym(41)
                asm_emit_store_reg(4, sak64, sav64, siv64)
            }

            if (tok_is("lgdt") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                I64 gk = mem_read64(0x800550)
                I64 gv = mem_read64(0x800558)
                if (gk == 1) {
                    compiler_error(18) return 0
                }
                expect_sym(41)
                asm_emit_lgdt_lidt(0, gk, gv)
            }

            if (tok_is("lidt") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                I64 ik = mem_read64(0x800550)
                I64 iv = mem_read64(0x800558)
                if (ik == 1) {
                    compiler_error(18) return 0
                }
                expect_sym(41)
                asm_emit_lgdt_lidt(1, ik, iv)
            }

            if (tok_is("in") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                if (mem_read64(0x800550) != 1) {
                    compiler_error(18) return 0
                }
                I64 inreg = mem_read64(0x800560)
                expect_sym(44)
                asm_parse_operand()
                I64 inpk = mem_read64(0x800550)
                I64 inpv = mem_read64(0x800558)
                if (inpk == 1) {
                    inpv = mem_read64(0x800560)
                }
                expect_sym(41)
                asm_emit_in(inreg, inpk, inpv)
            }

            if (tok_is("out") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                I64 outpk = mem_read64(0x800550)
                I64 outpv = mem_read64(0x800558)
                if (outpk == 1) {
                    outpv = mem_read64(0x800560)
                }
                expect_sym(44)
                asm_parse_operand()
                if (mem_read64(0x800550) != 1) {
                    compiler_error(18) return 0
                }
                I64 outreg = mem_read64(0x800560)
                expect_sym(41)
                asm_emit_out(outpk, outpv, outreg)
            }

            if (tok_is("db") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                I64 dbk = mem_read64(0x800550)
                I64 dbv = mem_read64(0x800558)
                if (dbk == 1) {
                    compiler_error(18) return 0
                }
                if (dbk == 3) {
                    compiler_error(18) return 0
                }
                if (dbv > 255) {
                    compiler_error(18) return 0
                }
                asm_put8(dbv)
                expect_sym(41)
            }

            if (tok_is("dw") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                I64 dwk = mem_read64(0x800550)
                I64 dwv = mem_read64(0x800558)
                if (dwk == 1) {
                    compiler_error(18) return 0
                }
                I64 dwp = mem_read64(0x800090)
                asm_put16(0)
                if (dwk == 2) {
                    patch16_at(dwp, dwv)
                }
                if (dwk == 3) {
                    asm_add_fixup(dwv, dwp, 0 - 3)
                }
                expect_sym(41)
            }

            if (tok_is("dd") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                I64 ddk = mem_read64(0x800550)
                I64 ddv = mem_read64(0x800558)
                if (ddk == 1) {
                    compiler_error(18) return 0
                }
                I64 ddp = mem_read64(0x800090)
                asm_put32(0)
                if (ddk == 2) {
                    patch32_at(ddp, ddv)
                }
                if (ddk == 3) {
                    asm_add_fixup(ddv, ddp, 0 - 4)
                }
                expect_sym(41)
            }

            if (tok_is("dq") != 0) {
                handled = 1
                expect_sym(40)
                asm_parse_operand()
                I64 dqk = mem_read64(0x800550)
                I64 dqv = mem_read64(0x800558)
                if (dqk == 1) {
                    compiler_error(18) return 0
                }
                I64 dqp = mem_read64(0x800090)
                asm_put64(0)
                if (dqk == 2) {
                    patch64_at(dqp, dqv)
                }
                if (dqk == 3) {
                    asm_add_fixup(dqv, dqp, 0 - 5)
                }
                expect_sym(41)
            }

            if (tok_is("zero") != 0) {
                handled = 1
                expect_sym(40)
                take()
                if (ct() != 2) {
                    compiler_error(18) return 0
                }
                I64 zeros = cv()
                I64 zi = 0
                while (zi < zeros) {
                    asm_put8(0)
                    zi = zi + 1
                }
                expect_sym(41)
            }

            if (tok_is("align") != 0) {
                handled = 1
                expect_sym(40)
                take()
                if (ct() != 2) {
                    compiler_error(18) return 0
                }
                I64 alignment = cv()
                if (alignment == 0) {
                    compiler_error(18) return 0
                }

                while ((mem_read64(0x800090) % alignment) != 0) {
                    asm_put8(0)
                }

                expect_sym(41)
            }

            if (tok_is("pad_to") != 0) {
                handled = 1
                expect_sym(40)
                take()
                if (ct() != 2) {
                    compiler_error(18) return 0
                }
                I64 target_position = cv()

                if (mem_read64(0x800090) > target_position) {
                    compiler_error(18)
                    return 0
                }

                while (mem_read64(0x800090) < target_position) {
                    asm_put8(0)
                }

                expect_sym(41)
            }

            if (tok_is("clts") != 0) {
                handled = 1 asm_put2(0x0F, 0x06)
            }
            if (tok_is("invd") != 0) {
                handled = 1 asm_put2(0x0F, 0x08)
            }
            if (tok_is("wbinvd") != 0) {
                handled = 1 asm_put2(0x0F, 0x09)
            }
            if (tok_is("pause") != 0) {
                handled = 1 asm_put2(0xF3, 0x90)
            }
            if (tok_is("int3") != 0) {
                handled = 1 asm_put8(0xCC)
            }
            if (tok_is("leave") != 0) {
                handled = 1 asm_put8(0xC9)
            }
            if (tok_is("lahf") != 0) {
                handled = 1 asm_put8(0x9F)
            }
            if (tok_is("sahf") != 0) {
                handled = 1 asm_put8(0x9E)
            }
            if (tok_is("rdtscp") != 0) {
                handled = 1 asm_put3(0x0F, 0x01, 0xF9)
            }
            if (tok_is("xgetbv") != 0) {
                handled = 1 asm_put3(0x0F, 0x01, 0xD0)
            }
            if (tok_is("xsetbv") != 0) {
                handled = 1 asm_put3(0x0F, 0x01, 0xD1)
            }
            if (tok_is("swapgs") != 0) {
                handled = 1
                if (mem_read64(0x800508) != 64) {
                    compiler_error(18) return 0
                }
                asm_put3(0x0F, 0x01, 0xF8)
            }

            if (tok_is("cli") != 0) {
                handled = 1 asm_put8(0xFA)
            }
            if (tok_is("sti") != 0) {
                handled = 1 asm_put8(0xFB)
            }
            if (tok_is("cld") != 0) {
                handled = 1 asm_put8(0xFC)
            }
            if (tok_is("std") != 0) {
                handled = 1 asm_put8(0xFD)
            }
            if (tok_is("nop") != 0) {
                handled = 1 asm_put8(0x90)
            }
            if (tok_is("hlt") != 0) {
                handled = 1 asm_put8(0xF4)
            }
            if (tok_is("ret") != 0) {
                handled = 1 asm_put8(0xC3)
            }
            if (tok_is("cpuid") != 0) {
                handled = 1 asm_put2(0x0F, 0xA2)
            }
            if (tok_is("rdmsr") != 0) {
                handled = 1 asm_put2(0x0F, 0x32)
            }
            if (tok_is("wrmsr") != 0) {
                handled = 1 asm_put2(0x0F, 0x30)
            }
            if (tok_is("rdtsc") != 0) {
                handled = 1 asm_put2(0x0F, 0x31)
            }
            if (tok_is("syscall") != 0) {
                handled = 1
                if (mem_read64(0x800508) != 64) {
                    compiler_error(18) return 0
                }
                asm_put2(0x0F, 0x05)
            }
            if (tok_is("pusha") != 0) {
                handled = 1
                if (mem_read64(0x800508) == 64) {
                    compiler_error(18) return 0
                }
                asm_put8(0x60)
            }
            if (tok_is("popa") != 0) {
                handled = 1
                if (mem_read64(0x800508) == 64) {
                    compiler_error(18) return 0
                }
                asm_put8(0x61)
            }
            if (tok_is("pushf") != 0) {
                handled = 1 asm_put8(0x9C)
            }
            if (tok_is("popf") != 0) {
                handled = 1 asm_put8(0x9D)
            }
            if (tok_is("lodsb") != 0) {
                handled = 1 asm_put8(0xAC)
            }
            if (tok_is("stosb") != 0) {
                handled = 1 asm_put8(0xAA)
            }
            if (tok_is("movsb") != 0) {
                handled = 1 asm_put8(0xA4)
            }
            if (tok_is("rep_movsb") != 0) {
                handled = 1 asm_put2(0xF3, 0xA4)
            }
            if (tok_is("rep_stosb") != 0) {
                handled = 1 asm_put2(0xF3, 0xAA)
            }

            if (tok_is("iret") != 0) {
                handled = 1
                if (mem_read64(0x800508) != 16) {
                    compiler_error(18) return 0
                }
                asm_put8(0xCF)
            }

            if (tok_is("iretd") != 0) {
                handled = 1
                I64 ibits = mem_read64(0x800508)
                if (ibits == 64) {
                    compiler_error(18) return 0
                }
                if (ibits == 16) {
                    asm_put8(0x66)
                }
                asm_put8(0xCF)
            }

            if (tok_is("iretq") != 0) {
                handled = 1
                if (mem_read64(0x800508) != 64) {
                    compiler_error(18) return 0
                }
                asm_put2(0x48, 0xCF)
            }

            if (tok_is("pad_boot") != 0) {
                handled = 1

                if (mem_read64(0x800030) == 0) {
                    compiler_error(15)
                    return 0
                }

                if (mem_read64(0x800090) > 510) {
                    compiler_error(18)
                    return 0
                }

                while (mem_read64(0x800090) < 510) {
                    asm_put8(0)
                }
            }

            if (tok_is("sign_boot") != 0) {
                handled = 1

                if (mem_read64(0x800030) == 0) {
                    compiler_error(15)
                    return 0
                }

                if (mem_read64(0x8000A8) != 0) {
                    compiler_error(18)
                    return 0
                }

                if (mem_read64(0x800090) != 510) {
                    compiler_error(18)
                    return 0
                }

                asm_put2(0x55, 0xAA)
                mem_write64(0x800088, 1)
            }

            if (handled == 0) {
                compiler_error(18)
                return 0
            }

            if (failed() != 0) {
                return 0
            }
        }
    }

    expect_sym(40)
    expect_word("asme")
    expect_sym(41)

    return 0
}

fn parse_statement() {
    take()
    I64 token_kind = ct()

    if (token_kind == 1) {
        if (tok_is("if") != 0) {
            parse_if_statement() return 0
        }
        if (tok_is("while") != 0) {
            parse_while_statement() return 0
        }
        if (tok_is("return") != 0) {
            parse_return_statement() return 0
        }
        if (tok_is("pin") != 0) {
            parse_pin_statement() return 0
        }
        if (tok_is("break") != 0) {
            if (loop_depth() <= 0) { compiler_error(33) return 0 }
            I64 break_patch = emit_jmp()
            loop_add_break(break_patch)
            return 0
        }
        if (tok_is("continue") != 0) {
            I64 continue_start = loop_start()
            if (continue_start == 0) { compiler_error(33) return 0 }
            I64 continue_patch = emit_jmp()
            patch_rel(continue_patch, continue_start)
            return 0
        }
        if (tok_is("unsafe") != 0) {
            expect_sym(123)
            unsafe_enter()
            parse_block()
            unsafe_leave()
            return 0
        }
        if (tok_is("const") != 0) {
            take()
            if (ct() != 1) { compiler_error(34) return 0 }
            I64 const_type = type_id(cp())
            if (const_type == 0) { compiler_error(34) return 0 }
            take()
            if (ct() != 1) { fail() return 0 }
            I64 const_hash = chash()
            I64 const_index = register_var(const_hash, const_type)
            parse_assignment_hash(const_hash)
            var_set_const(const_index, 1)
            return 0
        }

        I64 declared_type = type_id(cp())
        if (declared_type != 0) {
            take()
            if (ct() != 1) {
                fail() return 0
            }

            I64 hash = chash()
            register_var(hash, declared_type)
            parse_assignment_hash(hash)
            return 0
        }

        I64 hash2 = chash()
        I64 name = cp()
        I64 builtin = builtin_id(name)

        if (look_sym(40) != 0) {
            if (builtin != 0) {
                parse_builtin_call(builtin) return 0
            }
            parse_generic_call(hash2)
            return 0
        }

        if (look_sym(61) != 0) {
            parse_assignment_hash(hash2)
            return 0
        }
    }

    if (token_kind == 4) {
        if (cv() == 40) {
            parse_inline_asm()
            return 0
        }
        if (cv() == 42) {
            if (require_unsafe_memory() == 0) { return 0 }
            parse_expression(0)
            emit_push()
            expect_sym(61)
            parse_expression(0)
            emit_pop_arg(0)
            emit_mem_write64_code()
            return 0
        }
    }

    fail()
    return 0
}

fn parse_block() {
    I64 done = 0

    while (done == 0) {
        if (look_sym(125) != 0) {
            take()
            done = 1
        }

        if (done == 0) {
            if (peek() == 0) {
                fail() return 0
            }
            if (failed() != 0) {
                return 0
            }
            parse_statement()
            if (failed() != 0) {
                return 0
            }
        }
    }

    return 0
}

fn parse_function() {
    if (use_custom_feature() == 0) {
        return 0
    }

    take()
    if (ct() != 1) {
        fail() return 0
    }

    I64 function_hash = chash()
    I64 is_main = tok_is("main")
    reset_vars()
    mem_write64(0x8005D8, 0)
    mem_write64(0x8005E0, 0)
    mem_write64(0x800058, is_main)

    expect_sym(40)

    I64 params = 0
    I64 parsing = 1
    if (look_sym(41) != 0) {
        parsing = 0
    }

    while (parsing != 0) {
        take()
        if (ct() != 1) {
            fail() return 0
        }

        I64 param_type = type_id(cp())
        if (param_type == 0) {
            fail() return 0
        }

        take()
        if (ct() != 1) {
            fail() return 0
        }

        I64 index = register_var(chash(), param_type)
        mem_write64(0x800400 + params * 16, index)
        mem_write64(0x800408 + params * 16, param_type)

        params = params + 1
        if (params > 6) {
            fail() return 0
        }

        if (look_sym(44) != 0) {
            take()
        }
        if (look_sym(41) != 0) {
            parsing = 0
        }
    }

    expect_sym(41)
    expect_sym(123)

    I64 position = tell()
    register_function(function_hash, position, params)
    if (failed() != 0) {
        return 0
    }

    if (is_main != 0) {
        mem_write64(0x800060, position)
    }

    emit_prolog()

    I64 i = 0
    while (i < params) {
        I64 param_index = mem_read64(0x800400 + i * 16)
        I64 param_type2 = mem_read64(0x800408 + i * 16)
        emit_store_arg_typed(param_index, i, param_type2)
        i = i + 1
    }

    parse_block()
    if (failed() != 0) {
        return 0
    }

    if (is_main != 0) {
        if (out_raw() != 0) {
            if (mem_read64(0x800568) != 0) {
                emit_imm(0)
                emit_epilog()
            }
            else {
                emit_raw_halt()
            }
        }
        else {
            emit_main_exit0()
        }
    }
    else {
        emit_imm(0)
        emit_epilog()
    }

    mem_write64(0x800058, 0)
    return 0
}

fn import_table_base() { return 0x7A0000 }
fn import_pool_base() { return 0x7A2000 }
fn import_pool_limit() { return 0x7B2000 }
fn import_stack_base() { return 0x7B3000 }

fn import_register(I64 path) {
    I64 hash = hash_text(path)
    I64 count = mem_read64(0x8005C0)
    I64 i = 0
    while (i < count) {
        I64 entry = import_table_base() + i * 16
        if (mem_read64(entry) == hash) {
            if (strcmp(mem_read64(entry + 8), path) == 0) { return 0 }
        }
        i = i + 1
    }
    if (count >= 256) { compiler_error(32) return 0 - 1 }

    I64 length = strlen(path)
    I64 pool = mem_read64(0x8005C8)
    if (pool == 0) { pool = import_pool_base() }
    if ((pool + length + 1) >= import_pool_limit()) {
        compiler_error(32)
        return 0 - 1
    }

    I64 j = 0
    while (j <= length) {
        mem_write8(pool + j, mem_read8(path + j))
        j = j + 1
    }

    I64 entry2 = import_table_base() + count * 16
    mem_write64(entry2, hash)
    mem_write64(entry2 + 8, pool)
    mem_write64(0x8005C0, count + 1)
    mem_write64(0x8005C8, pool + length + 1)
    return pool
}

fn source_state_save(I64 frame) {
    mem_write64(frame, mem_read64(0x800000))
    mem_write64(frame + 8, mem_read64(0x800010))
    mem_write64(frame + 16, mem_read64(0x800018))
    mem_write64(frame + 24, mem_read64(0x800020))
    mem_write64(frame + 32, mem_read64(0x8000C0))
    mem_write64(frame + 40, mem_read64(0x8000C8))
    mem_write64(frame + 48, mem_read64(0x8000E0))
    mem_write64(frame + 56, mem_read64(0x800070))
    return 0
}

fn source_state_restore(I64 frame) {
    mem_write64(0x800000, mem_read64(frame))
    mem_write64(0x800010, mem_read64(frame + 8))
    mem_write64(0x800018, mem_read64(frame + 16))
    mem_write64(0x800020, mem_read64(frame + 24))
    mem_write64(0x8000C0, mem_read64(frame + 32))
    mem_write64(0x8000C8, mem_read64(frame + 40))
    mem_write64(0x8000E0, mem_read64(frame + 48))
    mem_write64(0x800070, mem_read64(frame + 56))
    mem_write64(0x8000E8, mem_read64(frame + 32))
    mem_write64(0x8000F0, mem_read64(frame + 40))
    return 0
}

fn head_table_base() { return 0x7B6000 }
fn head_pool_base() { return 0x7B7000 }
fn head_pool_limit() { return 0x7B9000 }

fn head_root_path_addr() { return 0x7B9000 }
fn head_temp_path_addr() { return 0x7BA000 }

fn path_is_absolute(I64 path) {
    if (mem_read8(path) == 47) { return 1 }
    if (mem_read8(path) == 92) { return 1 }
    if (mem_read8(path) != 0) {
        if (mem_read8(path + 1) == 58) { return 1 }
    }
    return 0
}

fn path_build_relative(I64 owner, I64 child, I64 dest) {
    I64 child_len = strlen(child)
    if (child_len >= 4095) { compiler_error(39) return 0 }

    if (path_is_absolute(child) != 0) {
        I64 k = 0
        while (k <= child_len) {
            mem_write8(dest + k, mem_read8(child + k))
            k = k + 1
        }
        return dest
    }

    I64 owner_len = strlen(owner)
    I64 cut = 0
    I64 i = owner_len
    while (i > 0) {
        i = i - 1
        I64 c = mem_read8(owner + i)
        if (c == 47) {
            cut = i + 1
            i = 0
        }
        else {
            if (c == 92) {
                cut = i + 1
                i = 0
            }
        }
    }

    if ((cut + child_len) >= 4095) { compiler_error(39) return 0 }
    I64 j = 0
    while (j < cut) {
        mem_write8(dest + j, mem_read8(owner + j))
        j = j + 1
    }
    I64 n = 0
    while (n <= child_len) {
        mem_write8(dest + cut + n, mem_read8(child + n))
        n = n + 1
    }
    return dest
}

fn head_root_path_init(I64 input_path) {
    return path_build_relative(input_path, "head.h", head_root_path_addr())
}

fn path_is_header(I64 path) {
    I64 n = strlen(path)
    if (n < 3) { return 0 }
    if (mem_read8(path + n - 2) != 46) { return 0 }
    I64 c = mem_read8(path + n - 1)
    if (c == 104) { return 1 }
    if (c == 72) { return 1 }
    return 0
}

fn head_find_entry(I64 name) {
    I64 hash = hash_text(name)
    I64 count = mem_read64(0x800610)
    I64 i = 0
    while (i < count) {
        I64 entry = head_table_base() + i * 24
        if (mem_read64(entry) == hash) {
            if (strcmp(mem_read64(entry + 8), name) == 0) { return entry }
        }
        i = i + 1
    }
    return 0
}

fn head_claim(I64 name) {
    I64 old = head_find_entry(name)
    if (old != 0) {
        I64 state = mem_read64(old + 16)
        if (state == 2) { return 0 }
        if (state == 1) { compiler_error(38) return 0 - 1 }
    }

    I64 count = mem_read64(0x800610)
    if (count >= 128) { compiler_error(38) return 0 - 1 }
    I64 length = strlen(name)
    I64 pool = mem_read64(0x800618)
    if (pool == 0) { pool = head_pool_base() }
    if ((pool + length + 1) >= head_pool_limit()) {
        compiler_error(38)
        return 0 - 1
    }

    I64 j = 0
    while (j <= length) {
        mem_write8(pool + j, mem_read8(name + j))
        j = j + 1
    }

    I64 entry2 = head_table_base() + count * 24
    mem_write64(entry2, hash_text(name))
    mem_write64(entry2 + 8, pool)
    mem_write64(entry2 + 16, 1)
    mem_write64(0x800610, count + 1)
    mem_write64(0x800618, pool + length + 1)
    return entry2
}

fn skip_head_body() {
    I64 depth = 1
    while (depth > 0) {
        take()
        if (ct() == 0) { compiler_error(39) return 0 }
        if (ct() == 4) {
            if (cv() == 123) { depth = depth + 1 }
            if (cv() == 125) { depth = depth - 1 }
        }
    }
    return 1
}

fn parse_fhf_statement() {
    take()
    if (ct() != 3) { compiler_error(39) return 0 }
    if (path_is_header(cp()) == 0) { compiler_error(39) return 0 }
    I64 resolved = path_build_relative(mem_read64(0x8000E0), cp(), head_temp_path_addr())
    if (failed() != 0) { return 0 }
    return parse_import_file(resolved)
}

fn parse_named_head_statement() {
    expect_sym(60)
    take()
    if (ct() != 1) { compiler_error(35) return 0 }
    I64 entry = head_claim(cp())
    expect_sym(62)
    if (failed() != 0) { return 0 }
    if (entry == 0) { return 1 }
    if (entry < 0) { return 0 }
    return apply_named_head(entry)
}

fn parse_head_definition_body() {
    I64 done = 0
    while (done == 0) {
        take()
        if (ct() == 0) { compiler_error(39) return 0 }
        if (ct() == 4) {
            if (cv() == 125) { done = 1 }
        }
        if (done == 0) {
            if (ct() != 1) { compiler_error(39) return 0 }
            I64 handled = 0
            if (tok_is("fhf") != 0) {
                handled = 1
                parse_fhf_statement()
            }
            if (tok_is("head") != 0) {
                handled = 1
                parse_named_head_statement()
            }
            if (handled == 0) { compiler_error(39) return 0 }
            if (failed() != 0) { return 0 }
        }
    }
    return 1
}

fn apply_named_head(I64 entry) {
    I64 target = mem_read64(entry + 8)
    I64 depth = mem_read64(0x8005D0)
    if (depth >= 16) { compiler_error(38) return 0 }
    if (mem_read64(0x800070) != 0) { fail() return 0 }

    I64 root_head = head_root_path_addr()
    I64 fd = os_open(root_head, 0)
    if (fd < 0) { compiler_error(36) return 0 }
    I64 size = os_file_size(fd)
    if (size < 0) { os_close(fd) compiler_error(36) return 0 }
    if (size > 1048576) { os_close(fd) compiler_error(38) return 0 }

    I64 frame = import_stack_base() + depth * 64
    source_state_save(frame)
    mem_write64(0x8005D0, depth + 1)
    mem_write64(0x800000, fd)
    mem_write64(0x800010, 0)
    mem_write64(0x800018, size)
    mem_write64(0x800020, 0)
    mem_write64(0x800070, 0)
    mem_write64(0x8000C0, 1)
    mem_write64(0x8000C8, 0)
    mem_write64(0x8000E0, root_head)
    mem_write64(0x8000E8, 1)
    mem_write64(0x8000F0, 1)
    os_file_seek(fd, 0)
    read_char()

    I64 found = 0
    I64 done = 0
    while (done == 0) {
        take()
        if (ct() == 0) { done = 1 }
        if (done == 0) {
            if (ct() != 1) { compiler_error(39) done = 1 }
            else {
                if (tok_is("head") == 0) { compiler_error(39) done = 1 }
                else {
                    expect_sym(60)
                    take()
                    if (ct() != 1) { compiler_error(35) done = 1 }
                    else {
                        I64 match = strcmp(cp(), target) == 0
                        expect_sym(62)
                        expect_sym(123)
                        if (failed() != 0) { done = 1 }
                        else {
                            if (match != 0) {
                                found = 1
                                parse_head_definition_body()
                                done = 1
                            }
                            else {
                                skip_head_body()
                            }
                        }
                    }
                }
            }
        }
    }

    os_close(fd)
    source_state_restore(frame)
    mem_write64(0x8005D0, depth)

    if (failed() != 0) { return 0 }
    if (found == 0) { compiler_error(37) return 0 }
    mem_write64(entry + 16, 2)
    return 1
}

fn parse_import_statement() {
    take()
    if (ct() != 3) { compiler_error(31) return 0 }
    return parse_import_file(cp())
}

fn parse_import_file(I64 path) {
    I64 stable = import_register(path)
    if (stable == 0) { return 1 }
    if (stable < 0) { return 0 }

    I64 depth = mem_read64(0x8005D0)
    if (depth >= 16) { compiler_error(32) return 0 }
    if (mem_read64(0x800070) != 0) { fail() return 0 }

    I64 fd = os_open(stable, 0)
    if (fd < 0) { compiler_error(31) return 0 }
    I64 size = os_file_size(fd)
    if (size < 0) { os_close(fd) compiler_error(31) return 0 }
    if (size > 2097152) { os_close(fd) compiler_error(32) return 0 }

    I64 frame = import_stack_base() + depth * 64
    source_state_save(frame)
    mem_write64(0x8005D0, depth + 1)

    mem_write64(0x800000, fd)
    mem_write64(0x800010, 0)
    mem_write64(0x800018, size)
    mem_write64(0x800020, 0)
    mem_write64(0x800070, 0)
    mem_write64(0x8000C0, 1)
    mem_write64(0x8000C8, 0)
    mem_write64(0x8000E0, stable)
    mem_write64(0x8000E8, 1)
    mem_write64(0x8000F0, 1)
    os_file_seek(fd, 0)
    read_char()

    I64 done = 0
    while (done == 0) {
        take()
        I64 kind = ct()
        if (kind == 0) { done = 1 }

        if (done == 0) {
            I64 handled = 0
            if (kind == 1) {
                if (tok_is("fn") != 0) {
                    handled = 1
                    parse_function()
                }
                if (tok_is("import") != 0) {
                    handled = 1
                    parse_import_statement()
                }
                if (tok_is("fhf") != 0) {
                    handled = 1
                    parse_fhf_statement()
                }
                if (tok_is("head") != 0) {
                    if (look_sym(60) != 0) {
                        handled = 1
                        parse_named_head_statement()
                    }
                }
            }
            if (handled == 0) { fail() }
            if (failed() != 0) { done = 1 }
        }
    }

    os_close(fd)
    source_state_restore(frame)
    mem_write64(0x8005D0, depth)
    return failed() == 0
}

fn official_head_mask_addr() { return 0x800620 }

fn official_head_bit(I64 name) {
    if (strcmp(name, "custom") == 0) { return 1 }
    if (strcmp(name, "memory") == 0) { return 2 }
    if (strcmp(name, "input") == 0) { return 4 }
    if (strcmp(name, "file") == 0) { return 8 }
    if (strcmp(name, "network") == 0) { return 16 }
    if (strcmp(name, "networking") == 0) { return 16 }
    if (strcmp(name, "time") == 0) { return 32 }
    if (strcmp(name, "math") == 0) { return 64 }
    if (strcmp(name, "graphics") == 0) { return 128 }
    if (strcmp(name, "audio") == 0) { return 256 }
    if (strcmp(name, "thread") == 0) { return 512 }
    if (strcmp(name, "crypto") == 0) { return 1024 }
    if (strcmp(name, "process") == 0) { return 2048 }
    if (strcmp(name, "game") == 0) { return 4096 }
    if (strcmp(name, "safe") == 0) { return 8192 }
    if (strcmp(name, "system") == 0) { return 16384 }
    return 0
}

fn official_head_enabled(I64 bit) {
    return (mem_read64(official_head_mask_addr()) & bit) != 0
}

fn enable_official_head(I64 name) {
    I64 bit = official_head_bit(name)
    if (bit == 0) { compiler_error(40) return 0 }

    I64 mask = mem_read64(official_head_mask_addr())
    if ((mask & bit) != 0) { compiler_error(40) return 0 }
    mem_write64(official_head_mask_addr(), mask | bit)

    if (bit == 1) {
        if ((mem_read64(0x8000A0) & 3) != 0) { compiler_error(16) return 0 }
        mem_write64(0x800098, 1)
    }
    if (bit == 8192) {
        mem_write64(os_safe_mode_addr(), 1)
    }
    return 1
}

fn refresh_asm_head_mode() {
    I64 asm_mask = mem_read64(0x8000A0)

    if ((asm_mask & 3) != 0) {
        if (mem_read64(0x800030) == 0) { compiler_error(15) return 0 }
        if (mem_read64(0x800098) != 0) { compiler_error(16) return 0 }
    }

    if (asm_mask == 1) { mem_write64(0x800508, 16) }
    if (asm_mask == 2) { mem_write64(0x800508, 32) }
    if (asm_mask == 4) { mem_write64(0x800508, 64) }
    if (asm_mask != 1) {
        if (asm_mask != 2) {
            if (asm_mask != 4) { mem_write64(0x800508, 0) }
        }
    }
    return 1
}

fn parse_official_head_statement() {
    expect_sym(40)
    if (failed() != 0) { return 0 }

    I64 feature_count = 0
    I64 done = 0

    while (done == 0) {
        take()
        if (ct() == 4) {
            if (cv() == 41) { done = 1 }
        }

        if (done == 0) {
            if (ct() != 1) { fail() return 0 }

            if (tok_is("asm") != 0) {
                expect_sym(45)
                take()
                if (ct() != 1) { fail() return 0 }
                if (tok_is("x86") == 0) { fail() return 0 }
                expect_sym(45)
                take()
                if (ct() != 2) { fail() return 0 }

                I64 bits = cv()
                I64 bit = 0
                if (bits == 16) { bit = 1 }
                if (bits == 32) { bit = 2 }
                if (bits == 64) { bit = 4 }
                if (bit == 0) { compiler_error(17) return 0 }

                I64 oldmask = mem_read64(0x8000A0)
                if ((oldmask & bit) != 0) { compiler_error(40) return 0 }
                mem_write64(0x8000A0, oldmask | bit)
                feature_count = feature_count + 1
            }
            else {
                if (enable_official_head(cp()) == 0) { return 0 }
                feature_count = feature_count + 1
            }
        }
    }

    if (feature_count == 0) { fail() return 0 }
    return refresh_asm_head_mode()
}

fn parse_program() {
    take()
    if (tok_is("head") == 0) { fail() return 0 }
    if (look_sym(40) == 0) { fail() return 0 }
    parse_official_head_statement()
    if (failed() != 0) { return 0 }

    I64 wrapped = 0
    if (look_sym(123) != 0) {
        expect_sym(123)
        wrapped = 1
    }

    I64 done = 0
    while (done == 0) {
        take()
        I64 token_kind = ct()
        I64 value = cv()

        if (token_kind == 0) {
            if (wrapped != 0) { fail() return 0 }
            done = 1
        }

        if (token_kind == 4) {
            if (value == 125) {
                if (wrapped == 0) { fail() return 0 }
                done = 1
            }
        }

        if (done == 0) {
            if (mem_read64(0x800088) != 0) { fail() return 0 }

            I64 handled = 0
            if (token_kind == 1) {
                if (tok_is("fn") != 0) {
                    handled = 1
                    parse_function()
                    if (failed() != 0) { return 0 }
                }
                if (tok_is("import") != 0) {
                    handled = 1
                    parse_import_statement()
                    if (failed() != 0) { return 0 }
                }
                if (tok_is("fhf") != 0) {
                    handled = 1
                    parse_fhf_statement()
                    if (failed() != 0) { return 0 }
                }
                if (tok_is("head") != 0) {
                    if (look_sym(40) != 0) {
                        handled = 1
                        parse_official_head_statement()
                        if (failed() != 0) { return 0 }
                    }
                    else {
                        if (look_sym(60) != 0) {
                            handled = 1
                            parse_named_head_statement()
                            if (failed() != 0) { return 0 }
                        }
                    }
                }
            }

            if (token_kind == 4) {
                if (value == 40) {
                    handled = 1
                    if (mem_read64(0x8000B8) == 0) {
                        mem_write64(0x8000B8, mem_read64(0x800090))
                    }
                    parse_inline_asm()
                    if (failed() != 0) { return 0 }
                }
            }

            if (handled == 0) { fail() return 0 }
        }
    }

    if (failed() != 0) { return 0 }
    resolve_calls()
    if (failed() != 0) { return 0 }
    warn_unused_features()
    return 0
}

fn emit_elf_header() {
    out8(0x7F)
    out8(0x45)
    out8(0x4C)
    out8(0x46)
    out8(2)
    out8(1)
    out8(1)

    if (mem_read64(0x800598) == 2) {
        out8(9)
    }
    else {
        out8(0)
    }

    I64 i = 8
    while (i < 16) {
        out8(0)
        i = i + 1
    }

    out8(2)
    out8(0)
    out8(0x3E)
    out8(0)
    out32(1)
    out64(0)
    out64(64)
    out64(0)
    out32(0)
    out8(64)
    out8(0)
    out8(56)
    out8(0)
    out8(1)
    out8(0)
    out8(0)
    out8(0)
    out8(0)
    out8(0)
    out8(0)
    out8(0)

    out32(1)
    out32(7)
    out64(0)
    out64(0x400000)
    out64(0x400000)
    out64(0)
    out64(0)
    out64(0x1000)
    return 0
}

fn finish_output() {
    finish_strings()

    I64 main_position = mem_read64(0x800060)
    I64 custom_used = mem_read64(0x8000A8)
    I64 asm_used = mem_read64(0x8000B0)
    I64 entry_position = main_position

    if (main_position == 0) {
        if (custom_used != 0) {
            fail() return 0
        }
        if (asm_used == 0) {
            fail() return 0
        }
        entry_position = mem_read64(0x8000B8)
    }

    if (out_raw() != 0) {
        if (main_position == 0) {
            I64 raw_fd = mem_read64(0x800008)
            I64 raw_end = mem_read64(0x800090)

            os_file_seek(raw_fd, 0)
            os_file_write8(raw_fd, 0x90)
            os_file_write8(raw_fd, 0x90)
            os_file_write8(raw_fd, 0x90)
            os_file_write8(raw_fd, 0x90)
            os_file_write8(raw_fd, 0x90)

            os_file_seek(raw_fd, raw_end)
            return 0
        }

        I64 raw_patch = mem_read64(0x800080)
        patch_rel(raw_patch, entry_position)
        return 0
    }

    I64 size = tell()
    patch64_at(24, 0x400000 + entry_position)
    patch64_at(96, size)
    patch64_at(104, 0x500000)
    return 0
}

fn ends_program_bin(I64 path) {
    I64 length = strlen(path)

    if (length < 4) {
        return 0
    }

    if (mem_read8(path + length - 4) != 46) {
        return 0
    }

    I64 b = mem_read8(path + length - 3)
    I64 i = mem_read8(path + length - 2)
    I64 n = mem_read8(path + length - 1)

    I64 lower = 0

    if (b == 98) {
        if (i == 105) {
            if (n == 110) {
                lower = 1
            }
        }
    }

    if (lower != 0) {
        return 1
    }

    I64 upper = 0

    if (b == 66) {
        if (i == 73) {
            if (n == 78) {
                upper = 1
            }
        }
    }

    return upper
}

fn initialize_state(I64 input, I64 output) {
    mem_write64(0x800000, input)
    mem_write64(0x800008, output)
    mem_write64(0x800010, 0)
    mem_write64(0x800020, 0)
    mem_write64(0x800038, 0)
    mem_write64(0x800040, 0)
    mem_write64(0x800048, 0)
    mem_write64(0x800050, 0)
    mem_write64(0x800058, 0)
    mem_write64(0x800060, 0)
    mem_write64(0x800068, 0x840000)
    mem_write64(0x800070, 0)
    mem_write64(0x800078, 0)
    mem_write64(0x800088, 0)
    mem_write64(0x800090, 0)
    mem_write64(0x800098, 0)
    mem_write64(0x8000A0, 0)
    mem_write64(0x8000A8, 0)
    mem_write64(0x8000B0, 0)
    mem_write64(0x8000B8, 0)
    mem_write64(0x8000C0, 1)
    mem_write64(0x8000C8, 0)
    mem_write64(0x8000D0, 0)
    mem_write64(0x8000D8, 0)
    mem_write64(0x8000E0, 0)
    mem_write64(0x8000E8, 1)
    mem_write64(0x8000F0, 1)
    mem_write64(0x800508, 0)
    mem_write64(0x800510, 0)
    mem_write64(0x800518, 0)
    mem_write64(0x800540, 0)
    mem_write64(0x800550, 0)
    mem_write64(0x800558, 0)
    mem_write64(0x800560, 0)
    mem_write64(0x800568, 0)
    mem_write64(0x800598, 0)
    mem_write64(0x8005A0, 0)
    mem_write64(0x8005A8, 0)
    mem_write64(0x8005B0, 0)
    mem_write64(0x8005B8, 0)
    mem_write64(0x8005C0, 0)
    mem_write64(0x8005C8, import_pool_base())
    mem_write64(0x8005D0, 0)
    mem_write64(0x8005D8, 0)
    mem_write64(0x8005E0, 0)
    mem_write64(0x800610, 0)
    mem_write64(0x800618, head_pool_base())
    mem_write64(official_head_mask_addr(), 0)
    mem_write64(unsafe_depth_addr(), 0)
    mem_write64(os_safe_mode_addr(), 0)
    mem_write64(os_sink_pos_addr(), 0)
    mem_write64(os_sink_size_addr(), 0)
    return 0
}

fn compile_to_sink(I64 input_path, I64 output_name, I64 sink) {
    I64 input = os_open(input_path, 0)

    if (input < 0) {
        driver_error(23, input_path)
        return 0 - 1
    }

    initialize_state(input, sink)
    mem_write64(0x8000E0, input_path)
    head_root_path_init(input_path)
    if (failed() != 0) { os_close(input) return 0 - 1 }

    I64 raw_output = ends_program_bin(output_name)
    I64 program_target = 2

    if (raw_output != 0) {
        program_target = 0
    }

    mem_write64(0x800030, raw_output)
    mem_write64(0x800568, program_target)
    mem_write64(os_safe_mode_addr(), 0)

    if (raw_output == 0) {
        I64 target_override = mem_read64(0x8005F0)
        if (target_override == 1) { mem_write64(0x800598, 1) }
        if (target_override == 2) { mem_write64(0x800598, 2) }
        if (target_override == 0) { detect_host_abi() }
    }

    os_sink_reset(sink)

    I64 size = os_file_size(input)

    if (size < 0) {
        driver_error(24, input_path)
        os_close(input)
        return 0 - 1
    }

    if (size > 2097152) {
        driver_error(25, input_path)
        os_close(input)
        return 0 - 1
    }

    mem_write64(0x800018, size)
    os_file_seek(input, 0)

    if (raw_output == 0) {
        emit_elf_header()
    }
    else {
        out8(0xE9)
        I64 entry_patch = tell()
        out32(0)
        mem_write64(0x800080, entry_patch)
    }

    read_char()
    parse_program()

    if (failed() == 0) {
        finish_output()
    }

    I64 output_size = tell()
    os_close(input)

    if (os_sink_guard_ok(sink) == 0) {
        driver_error(26, output_name)
        return 0 - 1
    }

    print_diagnostic_summary()

    if (failed() != 0) {
        compiler_write("mcc: no output written\n")
        return 0 - 1
    }

    if (output_size > os_sink_limit(sink)) {
        driver_error(27, output_name)
        return 0 - 1
    }

    return output_size
}

fn compile_aot(I64 input_path, I64 output_path) {
    I64 size = compile_to_sink(
        input_path,
        output_path,
        os_aot_handle()
    )

    if (size < 0) {
        return 1
    }

    if (os_write_file(output_path, os_aot_base(), size) == 0) {
        driver_error(28, output_path)
        return 1
    }

    print_output_info(output_path, size)
    return 0
}

fn compile_check(I64 input_path) {
    I64 size = compile_to_sink(input_path, "check.elf", os_aot_handle())
    if (size < 0) { return 1 }
    compiler_write("mcc: check OK\n")
    return 0
}

fn print_help() {
    compiler_write("MicroC native AOT compiler\n")
    compiler_write("usage:\n")
    compiler_write("  mcc source.mc -o output\n")
    compiler_write("  mcc --target=linux source.mc -o output\n")
    compiler_write("  mcc --target=freebsd source.mc -o output\n")
    compiler_write("  mcc --check source.mc\n")
    compiler_write("  mcc --version\n")
    compiler_write("source layout: heads first, then flat top-level functions (no head wrapper)\n")
    compiler_write("safe mode: head(safe); legacy wrapped head syntax is accepted for old source\n")
    compiler_write("built-in heads: custom memory input file process networking time math graphics audio crypto thread game system safe\n")
    compiler_write("user heads: head<name>; definitions live in head.h and use fhf \"file.h\"\n")
    compiler_write("raw BIN is selected by a .bin output suffix\n")
    return 0
}

fn compiler_main(I64 count, I64 arg1, I64 arg2, I64 arg3, I64 arg4) {
    mem_write64(0x8005F0, 0)

    if (count == 2) {
        if (strcmp(arg1, "--version") == 0) {
            compiler_write("MicroC compiler v1.0\n")
            return 0
        }

        if (strcmp(arg1, "--help") == 0) {
            print_help()
            return 0
        }
    }

    if (count == 3) {
        if (strcmp(arg1, "--check") == 0) {
            I64 check_result = compile_check(arg2)
            return check_result
        }
    }

    if (count == 4) {
        if (strcmp(arg2, "-o") != 0) {
            driver_error(29, 0)
            print_help()
            return 1
        }

        I64 compile_result = compile_aot(arg1, arg3)
        return compile_result
    }

    if (count == 5) {
        I64 target = 0

        if (strcmp(arg1, "--target=linux") == 0) {
            target = 1
        }

        if (strcmp(arg1, "--target=freebsd") == 0) {
            target = 2
        }

        if (target == 0) {
            driver_error(29, 0)
            print_help()
            return 1
        }

        if (strcmp(arg3, "-o") != 0) {
            driver_error(29, 0)
            print_help()
            return 1
        }

        mem_write64(0x8005F0, target)

        I64 target_result = compile_aot(arg2, arg4)
        return target_result
    }

    print_help()
    return 1
}

fn main() {
    I64 count = argc()

    I64 arg1 = 0
    I64 arg2 = 0
    I64 arg3 = 0
    I64 arg4 = 0

    if (count > 1) { arg1 = argv(1) }
    if (count > 2) { arg2 = argv(2) }
    if (count > 3) { arg3 = argv(3) }
    if (count > 4) { arg4 = argv(4) }

    return compiler_main(count, arg1, arg2, arg3, arg4)
}
