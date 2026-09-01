head(custom) {
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
        if (mem_read64(0x800088) != 0) { return value }
        I64 fd = out_fd()
        file_write8(fd, value & 255)
        I64 position = mem_read64(0x800090)
        mem_write64(0x800090, position + 1)
        return value
    }

    fn out32(I64 value) {
        if (mem_read64(0x800088) != 0) { return value }
        I64 fd = mem_read64(0x800008)
        I64 position = mem_read64(0x800090)
        file_write8(fd, value & 255)
        file_write8(fd, (value >> 8) & 255)
        file_write8(fd, (value >> 16) & 255)
        file_write8(fd, (value >> 24) & 255)
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

        pin("\nmcc: %I64 errors, %I64 warnings\n", errors, warnings)
        return 0
    }

    fn print_output_info(I64 path, I64 size) {
        pin("mcc: created %s (%I64 bytes)\n", path, size)
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

        pin("%s:%I64:%I64: error: ", path, line, column)

        if (code == 2) { pin("custom syntax requires custom in head()\n") return 0 }
        if (code == 3) { pin("inline x86 assembly requires an asm-x86-* mode in head()\n") return 0 }
        if (code == 4) { pin("assignment to undeclared variable\n") return 0 }
        if (code == 5) { pin("variable already declared\n") return 0 }
        if (code == 6) { pin("identifier too long\n") return 0 }
        if (code == 7) { pin("string literal too long\n") return 0 }
        if (code == 8) { pin("wrong number of function arguments\n") return 0 }
        if (code == 9) { pin("function already declared\n") return 0 }
        if (code == 10) { pin("unterminated string literal\n") return 0 }
        if (code == 11) { pin("compiler string pool exhausted\n") return 0 }
        if (code == 12) { pin("hosted builtin unavailable in raw output\n") return 0 }
        if (code == 13) { pin("kernel-only builtin requires raw output\n") return 0 }
        if (code == 14) { pin("unknown function for fn_offset\n") return 0 }
        if (code == 15) { pin("x86-16/x86-32 assembly requires raw .bin output\n") return 0 }
        if (code == 16) { pin("custom codegen is x86-64 and cannot share x86-16/x86-32 head mode\n") return 0 }
        if (code == 17) { pin("assembly mode not enabled in head()\n") return 0 }
        if (code == 18) { pin("invalid assembly register or operands\n") return 0 }
        if (code == 19) { pin("unknown assembly label\n") return 0 }
        if (code == 20) { pin("assembly label already declared\n") return 0 }
        if (code == 21) { pin("assembly value or branch is out of range\n") return 0 }

        pin("compilation failed\n")
        return 0
    }

    fn compiler_warning(I64 code) {
        I64 warnings = mem_read64(0x8000D8)
        mem_write64(0x8000D8, warnings + 1)

        I64 path = mem_read64(0x8000E0)
        I64 line = mem_read64(0x8000E8)
        I64 column = mem_read64(0x8000F0)

        pin("%s:%I64:%I64: warning: ", path, line, column)

        if (code == 1) {
            pin("custom enabled in head() but never used\n")
            return 0
        }

        if (code == 2) {
            pin("x86 assembly enabled in head() but never used\n")
            return 0
        }

        pin("compiler warning\n")
        return 0
    }

    fn out64(I64 value) {
        if (mem_read64(0x800088) != 0) { return value }
        I64 fd = mem_read64(0x800008)
        I64 position = mem_read64(0x800090)
        file_write8(fd, value & 255)
        file_write8(fd, (value >> 8) & 255)
        file_write8(fd, (value >> 16) & 255)
        file_write8(fd, (value >> 24) & 255)
        file_write8(fd, (value >> 32) & 255)
        file_write8(fd, (value >> 40) & 255)
        file_write8(fd, (value >> 48) & 255)
        file_write8(fd, (value >> 56) & 255)
        mem_write64(0x800090, position + 8)
        return value
    }

    fn tell() {
        return mem_read64(0x800090)
    }

    fn seek_out(I64 position) {
        I64 fd = out_fd()
        file_seek(fd, position)
        mem_write64(0x800090, position)
        return position
    }

    fn patch32_at(I64 position, I64 value) {
        I64 end = tell()
        I64 fd = out_fd()
        seek_out(position)
        file_write8(fd, value & 255)
        file_write8(fd, (value >> 8) & 255)
        file_write8(fd, (value >> 16) & 255)
        file_write8(fd, (value >> 24) & 255)
        seek_out(end)
        return value
    }

    fn patch16_at(I64 position, I64 value) {
        I64 end = mem_read64(0x800090)
        I64 fd = mem_read64(0x800008)
        file_seek(fd, position)
        file_write8(fd, value & 255)
        file_write8(fd, (value >> 8) & 255)
        file_seek(fd, end)
        return value
    }


    fn patch64_at(I64 position, I64 value) {
        I64 end = tell()
        I64 fd = out_fd()
        seek_out(position)
        file_write8(fd, value & 255)
        file_write8(fd, (value >> 8) & 255)
        file_write8(fd, (value >> 16) & 255)
        file_write8(fd, (value >> 24) & 255)
        file_write8(fd, (value >> 32) & 255)
        file_write8(fd, (value >> 40) & 255)
        file_write8(fd, (value >> 48) & 255)
        file_write8(fd, (value >> 56) & 255)
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
        if (c == 32) { return 1 }
        if (c == 9) { return 1 }
        if (c == 10) { return 1 }
        if (c == 13) { return 1 }
        return 0
    }

    fn is_digit(I64 c) {
        if (c < 48) { return 0 }
        if (c > 57) { return 0 }
        return 1
    }

    fn is_alpha(I64 c) {
        if (c >= 65) {
            if (c <= 90) { return 1 }
        }
        if (c >= 97) {
            if (c <= 122) { return 1 }
        }
        if (c == 95) { return 1 }
        return 0
    }

    fn is_ident_more(I64 c) {
        I64 a = is_alpha(c)
        if (a != 0) { return 1 }
        I64 d = is_digit(c)
        if (d != 0) { return 1 }
        return 0
    }

    fn hex_value(I64 c) {
        if (c >= 48) {
            if (c <= 57) { return c - 48 }
        }
        if (c >= 65) {
            if (c <= 70) { return c - 55 }
        }
        if (c >= 97) {
            if (c <= 102) { return c - 87 }
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
        I64 c = file_read8(fd)

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
        if (slot == 0) { return 0x801000 }
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
        I64 h = 5381
        I64 i = 0
        I64 c = mem_read8(text)
        while (c != 0) {
            h = h * 33 + c
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

        mem_write64(0x8000E8, mem_read64(0x8000C0))
        mem_write64(0x8000F0, mem_read64(0x8000C8))

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

                        if (c == 110) { c = 10 }
                        if (c == 114) { c = 13 }
                        if (c == 116) { c = 9 }
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
            return token_type(0)
        }
        return lex_token(0)
    }

    fn ct() { return token_type(0) }
    fn cv() { return token_value(0) }
    fn cp() { return token_text(0) }
    fn clen() { return token_length(0) }
    fn chash() { return token_hash(0) }
    fn lp() { return token_text(1) }
    fn lv() { return token_value(1) }

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
        if (type != 4) { return 0 }
        return lv() == value
    }

    fn expect_sym(I64 value) {
        take()
        if (ct() != 4) { fail() return 0 }
        if (cv() != value) { fail() return 0 }
        return 1
    }

    fn expect_word(I64 word) {
        take()
        if (ct() != 1) { fail() return 0 }
        I64 p = cp()
        if (strcmp(p, word) != 0) { fail() return 0 }
        return 1
    }

    fn type_id(I64 name) {
        if (strcmp(name, "I8") == 0) { return 1 }
        if (strcmp(name, "I16") == 0) { return 2 }
        if (strcmp(name, "I32") == 0) { return 3 }
        if (strcmp(name, "I64") == 0) { return 4 }
        if (strcmp(name, "U8") == 0) { return 5 }
        if (strcmp(name, "U16") == 0) { return 6 }
        if (strcmp(name, "U32") == 0) { return 7 }
        if (strcmp(name, "U64") == 0) { return 8 }
        if (strcmp(name, "F64") == 0) { return 9 }
        if (strcmp(name, "Bool") == 0) { return 10 }
        return 0
    }

    fn type_bits(I64 type) {
        if (type == 1) { return 8 }
        if (type == 2) { return 16 }
        if (type == 3) { return 32 }
        if (type == 4) { return 64 }
        if (type == 5) { return 8 }
        if (type == 6) { return 16 }
        if (type == 7) { return 32 }
        if (type == 8) { return 64 }
        if (type == 9) { return 64 }
        if (type == 10) { return 1 }
        return 64
    }

    fn type_unsigned(I64 type) {
        if (type == 5) { return 1 }
        if (type == 6) { return 1 }
        if (type == 7) { return 1 }
        if (type == 8) { return 1 }
        if (type == 10) { return 1 }
        return 0
    }

    fn common_integer_type(I64 left, I64 right) {
        if (left == 10) { left = 4 }
        if (right == 10) { right = 4 }

        I64 lw = type_bits(left)
        I64 rw = type_bits(right)
        I64 width = lw
        if (rw > width) { width = rw }

        I64 unsigned_result = 0
        if (type_unsigned(left) != 0) {
            if (lw >= rw) { unsigned_result = 1 }
        }
        if (type_unsigned(right) != 0) {
            if (rw >= lw) { unsigned_result = 1 }
        }

        if (unsigned_result != 0) {
            if (width == 8) { return 5 }
            if (width == 16) { return 6 }
            if (width == 32) { return 7 }
            return 8
        }

        if (width == 8) { return 1 }
        if (width == 16) { return 2 }
        if (width == 32) { return 3 }
        return 4
    }

    fn builtin_id(I64 name) {
        if (strcmp(name, "open") == 0) { return 1 }
        if (strcmp(name, "close") == 0) { return 2 }
        if (strcmp(name, "file_read8") == 0) { return 3 }
        if (strcmp(name, "file_write8") == 0) { return 4 }
        if (strcmp(name, "file_size") == 0) { return 5 }
        if (strcmp(name, "file_seek") == 0) { return 6 }
        if (strcmp(name, "mem_read8") == 0) { return 7 }
        if (strcmp(name, "mem_write8") == 0) { return 8 }
        if (strcmp(name, "mem_read64") == 0) { return 9 }
        if (strcmp(name, "mem_write64") == 0) { return 10 }
        if (strcmp(name, "strlen") == 0) { return 11 }
        if (strcmp(name, "strcmp") == 0) { return 12 }
        if (strcmp(name, "argc") == 0) { return 13 }
        if (strcmp(name, "argv") == 0) { return 14 }
        if (strcmp(name, "debug_char") == 0) { return 15 }
        if (strcmp(name, "mem_read16") == 0) { return 16 }
        if (strcmp(name, "mem_write16") == 0) { return 17 }
        if (strcmp(name, "mem_read32") == 0) { return 18 }
        if (strcmp(name, "mem_write32") == 0) { return 19 }
        if (strcmp(name, "port_in8") == 0) { return 20 }
        if (strcmp(name, "port_in16") == 0) { return 21 }
        if (strcmp(name, "port_in32") == 0) { return 22 }
        if (strcmp(name, "port_out8") == 0) { return 23 }
        if (strcmp(name, "port_out16") == 0) { return 24 }
        if (strcmp(name, "port_out32") == 0) { return 25 }
        if (strcmp(name, "addr") == 0) { return 26 }
        if (strcmp(name, "cpu_read_cr0") == 0) { return 27 }
        if (strcmp(name, "cpu_write_cr0") == 0) { return 28 }
        if (strcmp(name, "cpu_read_cr2") == 0) { return 29 }
        if (strcmp(name, "cpu_read_cr3") == 0) { return 30 }
        if (strcmp(name, "cpu_write_cr3") == 0) { return 31 }
        if (strcmp(name, "cpu_read_cr4") == 0) { return 32 }
        if (strcmp(name, "cpu_write_cr4") == 0) { return 33 }
        if (strcmp(name, "cpu_invlpg") == 0) { return 34 }
        if (strcmp(name, "cpu_lgdt") == 0) { return 35 }
        if (strcmp(name, "cpu_lidt") == 0) { return 36 }
        if (strcmp(name, "cpu_ltr") == 0) { return 37 }
        if (strcmp(name, "cpu_rdmsr") == 0) { return 38 }
        if (strcmp(name, "cpu_wrmsr") == 0) { return 39 }
        if (strcmp(name, "cpu_rdtsc") == 0) { return 40 }
        if (strcmp(name, "cpuid_eax") == 0) { return 41 }
        if (strcmp(name, "cpuid_ebx") == 0) { return 42 }
        if (strcmp(name, "cpuid_ecx") == 0) { return 43 }
        if (strcmp(name, "cpuid_edx") == 0) { return 44 }
        if (strcmp(name, "cpu_read_rflags") == 0) { return 45 }
        if (strcmp(name, "cpu_write_rflags") == 0) { return 46 }
        if (strcmp(name, "cpu_swapgs") == 0) { return 47 }
        if (strcmp(name, "cpu_iretq") == 0) { return 48 }
        if (strcmp(name, "cpu_int3") == 0) { return 49 }
        if (strcmp(name, "cpu_pause") == 0) { return 50 }
        if (strcmp(name, "cpu_cli") == 0) { return 51 }
        if (strcmp(name, "cpu_sti") == 0) { return 52 }
        if (strcmp(name, "cpu_hlt") == 0) { return 53 }
        if (strcmp(name, "cpu_read_rsp") == 0) { return 54 }
        if (strcmp(name, "cpu_write_rsp") == 0) { return 55 }
        if (strcmp(name, "cpu_read_rbp") == 0) { return 56 }
        if (strcmp(name, "cpu_write_rbp") == 0) { return 57 }
        if (strcmp(name, "cpu_jump") == 0) { return 58 }
        if (strcmp(name, "cpu_call") == 0) { return 59 }
        if (strcmp(name, "fn_offset") == 0) { return 60 }
        if (strcmp(name, "code_offset") == 0) { return 61 }
        return 0
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
        out8(0x48) out8(0xC7) out8(0xC0) out32(60)
        out8(0x48) out8(0x31) out8(0xFF) out8(0x0F) out8(0x05)
        return 0
    }

    fn emit_main_exit_rax() {
        out8(0x48) out8(0x89) out8(0xC7) out8(0x48) out8(0xC7) out8(0xC0) out32(60)
        out8(0x0F) out8(0x05)
        return 0
    }

    fn emit_raw_halt() {
        if (mem_read64(0x800088) != 0) { return 0 }
        file_write8(mem_read64(0x800008), 0xFA)
        file_write8(mem_read64(0x800008), 0xF4)
        file_write8(mem_read64(0x800008), 0xEB)
        file_write8(mem_read64(0x800008), 0xFD)
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
        if (index == 0) { out8(0x5F) return 0 }
        if (index == 1) { out8(0x5E) return 0 }
        if (index == 2) { out8(0x5A) return 0 }
        if (index == 3) { out8(0x59) return 0 }
        if (index == 4) { out8(0x41) out8(0x58) return 0 }
        if (index == 5) { out8(0x41) out8(0x59) return 0 }
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
        if (source == target) { return target }

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
        if (argument == 0) { out8(0x48) out8(0x89) out8(0xF8) return 0 }
        if (argument == 1) { out8(0x48) out8(0x89) out8(0xF0) return 0 }
        if (argument == 2) { out8(0x48) out8(0x89) out8(0xD0) return 0 }
        if (argument == 3) { out8(0x48) out8(0x89) out8(0xC8) return 0 }
        if (argument == 4) { out8(0x4C) out8(0x89) out8(0xC0) return 0 }
        if (argument == 5) { out8(0x4C) out8(0x89) out8(0xC8) return 0 }
        fail()
        return 0
    }

    fn emit_store_arg_typed(I64 index, I64 argument, I64 type) {
        emit_arg_to_rax(argument)
        if (type != 9) { emit_normalize_type(type) }
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

        if (op == 37) { fail() emit_imm(0) return 9 }
        if (op == 38) { fail() emit_imm(0) return 9 }
        if (op == 124) { fail() emit_imm(0) return 9 }
        if (op == 94) { fail() emit_imm(0) return 9 }
        if (op == 1005) { fail() emit_imm(0) return 9 }
        if (op == 1006) { fail() emit_imm(0) return 9 }

        out8(0x66) out8(0x0F) out8(0x2E) out8(0xC1)
        if (op == 1001) { out8(0x0F) out8(0x94) out8(0xC0) }
        if (op == 1002) { out8(0x0F) out8(0x95) out8(0xC0) }
        if (op == 60) { out8(0x0F) out8(0x92) out8(0xC0) }
        if (op == 62) { out8(0x0F) out8(0x97) out8(0xC0) }
        if (op == 1003) { out8(0x0F) out8(0x96) out8(0xC0) }
        if (op == 1004) { out8(0x0F) out8(0x93) out8(0xC0) }
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
            if (result_shift == 10) { result_shift = 4 }

            out8(0x48) out8(0x89) out8(0xCA) out8(0x48) out8(0x89) out8(0xC1) out8(0x48) out8(0x89) out8(0xD0) out8(0x48) out8(0xD3) out8(0xE0)
            emit_normalize_type(result_shift)
            return result_shift
        }

        if (op == 1006) {
            I64 result_shift2 = left_type
            if (result_shift2 == 10) { result_shift2 = 4 }

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

        if (op == 1001) { out8(0x0F) out8(0x94) out8(0xC0) }
        if (op == 1002) { out8(0x0F) out8(0x95) out8(0xC0) }

        if (type_unsigned(result_type) != 0) {
            if (op == 60) { out8(0x0F) out8(0x92) out8(0xC0) }
            if (op == 62) { out8(0x0F) out8(0x97) out8(0xC0) }
            if (op == 1003) { out8(0x0F) out8(0x96) out8(0xC0) }
            if (op == 1004) { out8(0x0F) out8(0x93) out8(0xC0) }
        }

        if (type_unsigned(result_type) == 0) {
            if (op == 60) { out8(0x0F) out8(0x9C) out8(0xC0) }
            if (op == 62) { out8(0x0F) out8(0x9F) out8(0xC0) }
            if (op == 1003) { out8(0x0F) out8(0x9E) out8(0xC0) }
            if (op == 1004) { out8(0x0F) out8(0x9D) out8(0xC0) }
        }

        out8(0x48) out8(0x0F) out8(0xB6) out8(0xC0)
        return 10
    }

    fn precedence(I64 op) {
        if (op == 1001) { return 1 }
        if (op == 1002) { return 1 }
        if (op == 60) { return 1 }
        if (op == 62) { return 1 }
        if (op == 1003) { return 1 }
        if (op == 1004) { return 1 }
        if (op == 124) { return 2 }
        if (op == 94) { return 3 }
        if (op == 38) { return 4 }
        if (op == 1005) { return 5 }
        if (op == 1006) { return 5 }
        if (op == 43) { return 6 }
        if (op == 45) { return 6 }
        if (op == 42) { return 7 }
        if (op == 47) { return 7 }
        if (op == 37) { return 7 }
        return 0
    }

    fn reset_vars() {
        mem_write64(0x800048, 0)
        return 0
    }

    fn var_entry(I64 index) {
        return 0x828000 + (index - 1) * 16
    }

    fn var_type(I64 index) {
        if (index <= 0) { return 4 }
        return mem_read64(var_entry(index) + 8)
    }

    fn find_var(I64 hash) {
        I64 count = mem_read64(0x800048)
        I64 i = 0
        while (i < count) {
            I64 entry = 0x828000 + i * 16
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
        if (count >= 1024) { fail() return 0 }

        I64 entry = 0x828000 + count * 16
        mem_write64(entry, hash)
        mem_write64(entry + 8, type)
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
        if (count >= 256) { fail() return 0 }

        I64 entry = 0x810000 + count * 24
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
            I64 entry = 0x810000 + i * 24
            if (mem_read64(entry) == hash) { return mem_read64(entry + 8) }
            i = i + 1
        }
        return 0
    }

    fn find_function_params(I64 hash) {
        I64 count = mem_read64(0x800038)
        I64 i = 0
        while (i < count) {
            I64 entry = 0x810000 + i * 24
            if (mem_read64(entry) == hash) { return mem_read64(entry + 16) }
            i = i + 1
        }
        return 0 - 1
    }

    fn register_call(I64 hash, I64 patch, I64 arguments) {
        I64 count = mem_read64(0x800040)
        if (count >= 3500) { fail() return 0 }

        I64 entry = 0x812000 + count * 24
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
            I64 entry = 0x812000 + i * 24
            I64 hash = mem_read64(entry)
            I64 patch = mem_read64(entry + 8)
            I64 arguments = mem_read64(entry + 16)

            if (arguments >= 0) {
                I64 target = find_function(hash)

                if (target == 0) { fail() return 0 }

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
                    if (relative16 < (0 - 32768)) { compiler_error(21) return 0 }
                    if (relative16 > 32767) { compiler_error(21) return 0 }
                    patch16_at(patch, relative16)
                }

                if (arguments == 0 - 2) {
                    I64 relative32 = label_position - patch - 4
                    if (relative32 < (0 - 2147483648)) { compiler_error(21) return 0 }
                    if (relative32 > 2147483647) { compiler_error(21) return 0 }
                    patch32_at(patch, relative32)
                }

                if (arguments == 0 - 3) {
                    if (logical < 0) { compiler_error(21) return 0 }
                    if (logical > 65535) { compiler_error(21) return 0 }
                    patch16_at(patch, logical)
                }

                if (arguments == 0 - 4) {
                    if (logical < 0) { compiler_error(21) return 0 }
                    if (logical > 0xFFFFFFFF) { compiler_error(21) return 0 }
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
        if (count >= 512) { fail() return 0 }
        I64 saved = copy_string_pool(source, length)
        if (failed() != 0) { return 0 }
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
                file_write8(mem_read64(0x800008), mem_read8(source + j)) mem_write64(0x800090, mem_read64(0x800090) + 1)
                j = j + 1
            }
            i = i + 1
        }
        return 0
    }

    fn emit_runtime_open() {
        out8(0x48) out8(0xC7) out8(0xC2) out32(493)
        out8(0x48) out8(0xC7) out8(0xC0) out32(2)
        out8(0x0F) out8(0x05)
        return 0
    }

    fn emit_runtime_close() {
        out8(0x48) out8(0x89) out8(0xC7) out8(0x48) out8(0xC7) out8(0xC0) out32(3)
        out8(0x0F) out8(0x05)
        return 0
    }

    fn emit_runtime_read8() {
        out8(0x48) out8(0x89) out8(0xC7) out8(0x48) out8(0x83) out8(0xEC) out8(8) out8(0xC6) out8(0x04) out8(0x24) out8(0) out8(0x48) out8(0x89) out8(0xE6) out8(0x48) out8(0xC7) out8(0xC2) out32(1)
        out8(0x48) out8(0x31) out8(0xC0) out8(0x0F) out8(0x05) out8(0x48) out8(0x0F) out8(0xB6) out8(0x04) out8(0x24) out8(0x48) out8(0x83) out8(0xC4) out8(8)
        return 0
    }

    fn emit_runtime_write8() {
        out8(0x48) out8(0x83) out8(0xEC) out8(8) out8(0x88) out8(0x04) out8(0x24) out8(0x48) out8(0x89) out8(0xE6) out8(0x48) out8(0xC7) out8(0xC2) out32(1)
        out8(0x48) out8(0xC7) out8(0xC0) out32(1)
        out8(0x0F) out8(0x05) out8(0x48) out8(0x83) out8(0xC4) out8(8)
        return 0
    }

    fn emit_runtime_size() {
        out8(0x48) out8(0x89) out8(0xC7) out8(0x48) out8(0x31) out8(0xF6) out8(0x48) out8(0xC7) out8(0xC2) out32(2)
        out8(0x48) out8(0xC7) out8(0xC0) out32(8)
        out8(0x0F) out8(0x05)
        return 0
    }

    fn emit_runtime_seek() {
        out8(0x48) out8(0x89) out8(0xC6) out8(0x48) out8(0x31) out8(0xD2) out8(0x48) out8(0xC7) out8(0xC0) out32(8)
        out8(0x0F) out8(0x05)
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
        out8(0x48) out8(0x8B) out8(0x45) out8(0x08)
        return 0
    }

    fn emit_runtime_argv() {
        out8(0x48) out8(0x8B) out8(0x44) out8(0xC5) out8(0x10)
        return 0
    }

    fn emit_runtime_debug_char() {
        out8(0x48) out8(0x83) out8(0xEC) out8(8) out8(0x88) out8(0x04) out8(0x24) out8(0x48) out8(0xC7) out8(0xC7) out32(1)
        out8(0x48) out8(0x89) out8(0xE6) out8(0x48) out8(0xC7) out8(0xC2) out32(1)
        out8(0x48) out8(0xC7) out8(0xC0) out32(1)
        out8(0x0F) out8(0x05) out8(0x48) out8(0x83) out8(0xC4) out8(8)
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
        if (mem_read64(0x800088) != 0) { return 0 } file_write8(mem_read64(0x800008), (0x48) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x0F) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xB7) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x00) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) return 0 }
    fn emit_mem_read32_code() {
        if (mem_read64(0x800088) != 0) { return 0 } file_write8(mem_read64(0x800008), (0x8B) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x00) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) return 0 }
    fn emit_mem_write16_code() {
        if (mem_read64(0x800088) != 0) { return 0 } file_write8(mem_read64(0x800008), (0x66) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x89) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x07) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) return 0 }
    fn emit_mem_write32_code() {
        if (mem_read64(0x800088) != 0) { return 0 } file_write8(mem_read64(0x800008), (0x89) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x07) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) return 0 }

    fn emit_addr_var(I64 index) {
        if (mem_read64(0x800088) != 0) { return 0 }
        I64 displacement = 0 - index * 8
        file_write8(mem_read64(0x800008), (0x48) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x8D) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x85) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (displacement) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1)
        file_write8(mem_read64(0x800008), (displacement >> 8) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1)
        file_write8(mem_read64(0x800008), (displacement >> 16) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1)
        file_write8(mem_read64(0x800008), (displacement >> 24) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1)
        return 0
    }

    fn emit_port_in8_code() {
        if (mem_read64(0x800088) != 0) { return 0 } file_write8(mem_read64(0x800008), (0x89) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xC2) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x31) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xC0) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xEC) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) return 0 }
    fn emit_port_in16_code() {
        if (mem_read64(0x800088) != 0) { return 0 } file_write8(mem_read64(0x800008), (0x89) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xC2) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x31) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xC0) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x66) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xED) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) return 0 }
    fn emit_port_in32_code() {
        if (mem_read64(0x800088) != 0) { return 0 } file_write8(mem_read64(0x800008), (0x89) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xC2) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xED) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) return 0 }
    fn emit_port_out8_code() {
        if (mem_read64(0x800088) != 0) { return 0 } file_write8(mem_read64(0x800008), (0xEE) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) return 0 }
    fn emit_port_out16_code() {
        if (mem_read64(0x800088) != 0) { return 0 } file_write8(mem_read64(0x800008), (0x66) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xEF) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) return 0 }
    fn emit_port_out32_code() {
        if (mem_read64(0x800088) != 0) { return 0 } file_write8(mem_read64(0x800008), (0xEF) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) return 0 }

    fn emit_cpu_read_cr0_code() {
        if (mem_read64(0x800088) != 0) { return 0 } file_write8(mem_read64(0x800008), (0x0F) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x20) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xC0) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) return 0 }
    fn emit_cpu_write_cr0_code() {
        if (mem_read64(0x800088) != 0) { return 0 } file_write8(mem_read64(0x800008), (0x0F) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x22) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xC0) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) return 0 }
    fn emit_cpu_read_cr2_code() {
        if (mem_read64(0x800088) != 0) { return 0 } file_write8(mem_read64(0x800008), (0x0F) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x20) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xD0) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) return 0 }
    fn emit_cpu_read_cr3_code() {
        if (mem_read64(0x800088) != 0) { return 0 } file_write8(mem_read64(0x800008), (0x0F) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x20) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xD8) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) return 0 }
    fn emit_cpu_write_cr3_code() {
        if (mem_read64(0x800088) != 0) { return 0 } file_write8(mem_read64(0x800008), (0x0F) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x22) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xD8) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) return 0 }
    fn emit_cpu_read_cr4_code() {
        if (mem_read64(0x800088) != 0) { return 0 } file_write8(mem_read64(0x800008), (0x0F) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x20) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xE0) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) return 0 }
    fn emit_cpu_write_cr4_code() {
        if (mem_read64(0x800088) != 0) { return 0 } file_write8(mem_read64(0x800008), (0x0F) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x22) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xE0) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) return 0 }
    fn emit_cpu_invlpg_code() {
        if (mem_read64(0x800088) != 0) { return 0 } file_write8(mem_read64(0x800008), (0x0F) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x01) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x38) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) return 0 }
    fn emit_cpu_lgdt_code() {
        if (mem_read64(0x800088) != 0) { return 0 } file_write8(mem_read64(0x800008), (0x0F) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x01) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x10) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) return 0 }
    fn emit_cpu_lidt_code() {
        if (mem_read64(0x800088) != 0) { return 0 } file_write8(mem_read64(0x800008), (0x0F) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x01) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x18) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) return 0 }
    fn emit_cpu_ltr_code() {
        if (mem_read64(0x800088) != 0) { return 0 } file_write8(mem_read64(0x800008), (0x0F) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x00) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xD8) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) return 0 }

    fn emit_cpu_rdmsr_code() {
        if (mem_read64(0x800088) != 0) { return 0 }
        file_write8(mem_read64(0x800008), (0x89) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xC1) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1)
        file_write8(mem_read64(0x800008), (0x0F) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x32) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1)
        file_write8(mem_read64(0x800008), (0x48) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xC1) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xE2) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (32) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1)
        file_write8(mem_read64(0x800008), (0x48) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x09) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xD0) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1)
        return 0
    }

    fn emit_cpu_wrmsr_code() {
        if (mem_read64(0x800088) != 0) { return 0 }
        file_write8(mem_read64(0x800008), (0x48) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x89) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xC2) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1)
        file_write8(mem_read64(0x800008), (0x48) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xC1) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xEA) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (32) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1)
        file_write8(mem_read64(0x800008), (0x0F) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x30) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1)
        return 0
    }

    fn emit_cpu_rdtsc_code() {
        if (mem_read64(0x800088) != 0) { return 0 }
        file_write8(mem_read64(0x800008), (0x0F) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x31) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1)
        file_write8(mem_read64(0x800008), (0x48) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xC1) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xE2) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (32) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1)
        file_write8(mem_read64(0x800008), (0x48) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x09) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xD0) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1)
        return 0
    }

    fn emit_cpuid_result_code(I64 which) {
        if (mem_read64(0x800088) != 0) { return 0 }
        file_write8(mem_read64(0x800008), (0x53) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1)
        file_write8(mem_read64(0x800008), (0x0F) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xA2) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1)
        if (which == 1) { file_write8(mem_read64(0x800008), (0x89) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xD8) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) }
        if (which == 2) { file_write8(mem_read64(0x800008), (0x89) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xC8) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) }
        if (which == 3) { file_write8(mem_read64(0x800008), (0x89) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xD0) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) }
        file_write8(mem_read64(0x800008), (0x5B) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1)
        return 0
    }

    fn emit_zero_rax_code() {
        if (mem_read64(0x800088) != 0) { return 0 } file_write8(mem_read64(0x800008), (0x48) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0x31) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) file_write8(mem_read64(0x800008), (0xC0) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1) return 0 }

    fn parse_expression(I64 min_precedence) {
        I64 current_type = parse_primary()
        I64 running = 1

        while (running != 0) {
            I64 type = peek()
            if (type != 4) {
                running = 0
            }

            if (running != 0) {
                I64 op = lv()
                I64 prec = precedence(op)
                if (prec == 0) { running = 0 }
                if (prec < min_precedence) { running = 0 }

                if (running != 0) {
                    take()
                    emit_push()
                    I64 right_type = parse_expression(prec + 1)
                    current_type = emit_binary_typed(op, current_type, right_type)
                }
            }
        }

        return current_type
    }

    fn parse_builtin_call(I64 id) {
        expect_sym(40)

        if (out_raw() != 0) {
            I64 hosted = 0
            if (id >= 1) { if (id <= 6) { hosted = 1 } }
            if (id == 13) { hosted = 1 }
            if (id == 14) { hosted = 1 }
            if (id == 15) { hosted = 1 }
            if (hosted != 0) { compiler_error(12) return 4 }
        }

        if (out_raw() == 0) {
            I64 kernel_only = 0
            if (id >= 20) { if (id <= 61) { kernel_only = 1 } }
            if (id == 26) { kernel_only = 0 }
            if (kernel_only != 0) { compiler_error(13) return 4 }
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
            if (flags == 0) { emit_imm(0) }
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

        if (id == 16) { parse_expression(0) expect_sym(41) emit_mem_read16_code() return 6 }
        if (id == 17) { parse_expression(0) emit_push() expect_sym(44) parse_expression(0) emit_pop_arg(0) expect_sym(41) emit_mem_write16_code() return 6 }
        if (id == 18) { parse_expression(0) expect_sym(41) emit_mem_read32_code() return 7 }
        if (id == 19) { parse_expression(0) emit_push() expect_sym(44) parse_expression(0) emit_pop_arg(0) expect_sym(41) emit_mem_write32_code() return 7 }

        if (id == 20) { parse_expression(0) expect_sym(41) emit_port_in8_code() return 5 }
        if (id == 21) { parse_expression(0) expect_sym(41) emit_port_in16_code() return 6 }
        if (id == 22) { parse_expression(0) expect_sym(41) emit_port_in32_code() return 7 }
        if (id == 23) { parse_expression(0) emit_push() expect_sym(44) parse_expression(0) emit_pop_arg(2) expect_sym(41) emit_port_out8_code() return 5 }
        if (id == 24) { parse_expression(0) emit_push() expect_sym(44) parse_expression(0) emit_pop_arg(2) expect_sym(41) emit_port_out16_code() return 6 }
        if (id == 25) { parse_expression(0) emit_push() expect_sym(44) parse_expression(0) emit_pop_arg(2) expect_sym(41) emit_port_out32_code() return 7 }

        if (id == 26) {
            take()
            if (ct() != 1) { fail() return 4 }
            I64 index = find_var(chash())
            if (index == 0) { compiler_error(4) return 4 }
            expect_sym(41)
            emit_addr_var(index)
            return 8
        }

        if (id == 27) { expect_sym(41) emit_cpu_read_cr0_code() return 8 }
        if (id == 28) { parse_expression(0) expect_sym(41) emit_cpu_write_cr0_code() return 8 }
        if (id == 29) { expect_sym(41) emit_cpu_read_cr2_code() return 8 }
        if (id == 30) { expect_sym(41) emit_cpu_read_cr3_code() return 8 }
        if (id == 31) { parse_expression(0) expect_sym(41) emit_cpu_write_cr3_code() return 8 }
        if (id == 32) { expect_sym(41) emit_cpu_read_cr4_code() return 8 }
        if (id == 33) { parse_expression(0) expect_sym(41) emit_cpu_write_cr4_code() return 8 }
        if (id == 34) { parse_expression(0) expect_sym(41) emit_cpu_invlpg_code() return 8 }
        if (id == 35) { parse_expression(0) expect_sym(41) emit_cpu_lgdt_code() return 8 }
        if (id == 36) { parse_expression(0) expect_sym(41) emit_cpu_lidt_code() return 8 }
        if (id == 37) { parse_expression(0) expect_sym(41) emit_cpu_ltr_code() return 8 }
        if (id == 38) { parse_expression(0) expect_sym(41) emit_cpu_rdmsr_code() return 8 }
        if (id == 39) { parse_expression(0) emit_push() expect_sym(44) parse_expression(0) emit_pop_arg(3) expect_sym(41) emit_cpu_wrmsr_code() return 8 }
        if (id == 40) { expect_sym(41) emit_cpu_rdtsc_code() return 8 }

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

        if (id == 45) { expect_sym(41) out8(0x9C) out8(0x58) return 8 }
        if (id == 46) { parse_expression(0) expect_sym(41) out8(0x50) out8(0x9D) return 8 }
        if (id == 47) { expect_sym(41) out8(0x0F) out8(0x01) out8(0xF8) emit_zero_rax_code() return 8 }
        if (id == 48) { expect_sym(41) out8(0x48) out8(0xCF) return 8 }
        if (id == 49) { expect_sym(41) out8(0xCC) emit_zero_rax_code() return 8 }
        if (id == 50) { expect_sym(41) out8(0xF3) out8(0x90) emit_zero_rax_code() return 8 }
        if (id == 51) { expect_sym(41) out8(0xFA) emit_zero_rax_code() return 8 }
        if (id == 52) { expect_sym(41) out8(0xFB) emit_zero_rax_code() return 8 }
        if (id == 53) { expect_sym(41) out8(0xF4) emit_zero_rax_code() return 8 }
        if (id == 54) { expect_sym(41) out8(0x48) out8(0x89) out8(0xE0) return 8 }
        if (id == 55) { parse_expression(0) expect_sym(41) out8(0x48) out8(0x89) out8(0xC4) return 8 }
        if (id == 56) { expect_sym(41) out8(0x48) out8(0x89) out8(0xE8) return 8 }
        if (id == 57) { parse_expression(0) expect_sym(41) out8(0x48) out8(0x89) out8(0xC5) return 8 }
        if (id == 58) { parse_expression(0) expect_sym(41) out8(0xFF) out8(0xE0) return 8 }
        if (id == 59) { parse_expression(0) expect_sym(41) out8(0xFF) out8(0xD0) return 8 }

        if (id == 60) {
            take()
            if (ct() != 1) { fail() return 4 }
            I64 target = find_function(chash())
            if (target == 0) { compiler_error(14) return 4 }
            expect_sym(41)
            emit_imm(target)
            return 8
        }

        if (id == 61) { expect_sym(41) emit_imm(tell()) return 8 }

        fail()
        return 4
    }

    fn parse_generic_call(I64 hash) {
        expect_sym(40)
        I64 count = 0
        I64 more = 1
        if (look_sym(41) != 0) { more = 0 }

        while (more != 0) {
            parse_expression(0)
            emit_push()
            count = count + 1
            if (count > 6) { fail() return 4 }

            if (look_sym(44) != 0) {
                take()
            }
            if (look_sym(41) != 0) { more = 0 }
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
            if (index == 0) { fail() emit_imm(0) return 4 }
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

        I64 target_type = var_type(index)
        expect_sym(61)
        I64 source_type = parse_expression(0)
        emit_convert_type(source_type, target_type)
        emit_store_var(index)
        return target_type
    }

    fn parse_if_statement() {
        expect_sym(40)
        I64 condition_type = parse_expression(0)
        if (condition_type == 9) { emit_convert_type(9, 10) }
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
        parse_block()
        I64 back = emit_jmp()
        patch_rel(back, start)
        patch_rel(done, tell())
        return 0
    }

    fn parse_return_statement() {
        if (look_sym(125) != 0) {
            if (mem_read64(0x800058) != 0) {
                if (out_raw() != 0) { emit_raw_halt() return 0 }
                emit_main_exit0()
                return 0
            }
            emit_epilog()
            return 0
        }

        parse_expression(0)
        if (mem_read64(0x800058) != 0) {
            if (out_raw() != 0) { emit_raw_halt() return 0 }
            emit_main_exit_rax()
            return 0
        }
        emit_epilog()
        return 0
    }

    fn emit_pin_char_code() {
        out8(0x48) out8(0x83) out8(0xEC) out8(8) out8(0x88) out8(0x04) out8(0x24) out8(0x48) out8(0xC7) out8(0xC7) out32(1)
        out8(0x48) out8(0x89) out8(0xE6) out8(0x48) out8(0xC7) out8(0xC2) out32(1)
        out8(0x48) out8(0xC7) out8(0xC0) out32(1)
        out8(0x0F) out8(0x05) out8(0x48) out8(0x83) out8(0xC4) out8(8)
        return 0
    }

    fn emit_pin_text_code(I64 text, I64 length) {
        if (length == 0) { return 0 }

        emit_string_ptr(text, length)
        out8(0x48) out8(0x89) out8(0xC6) out8(0x48) out8(0xC7) out8(0xC7) out32(1)
        out8(0x48) out8(0xC7) out8(0xC2) out32(length)
        out8(0x48) out8(0xC7) out8(0xC0) out32(1)
        out8(0x0F) out8(0x05)
        return 0
    }

    fn emit_pin_i64_code() {
        out8(0x48) out8(0x83) out8(0xEC) out8(64) out8(0x49) out8(0x89) out8(0xE0) out8(0x49) out8(0x83) out8(0xC0) out8(63) out8(0x48) out8(0x31) out8(0xC9) out8(0x45) out8(0x31) out8(0xC9) out8(0x48) out8(0x85) out8(0xC0) out8(0x0F) out8(0x89)
        I64 non_negative = tell()
        out32(0)
        out8(0x48) out8(0xF7) out8(0xD8) out8(0x41) out8(0xB9) out32(1)
        patch_rel(non_negative, tell())

        out8(0x49) out8(0xC7) out8(0xC2) out32(10)

        I64 loop = tell()
        out8(0x48) out8(0x31) out8(0xD2) out8(0x49) out8(0xF7) out8(0xF2) out8(0x80) out8(0xC2) out8(48) out8(0x49) out8(0xFF) out8(0xC8) out8(0x41) out8(0x88) out8(0x10) out8(0x48) out8(0xFF) out8(0xC1) out8(0x48) out8(0x85) out8(0xC0) out8(0x0F) out8(0x85)
        I64 loop_back = tell()
        out32(0)
        patch_rel(loop_back, loop)

        out8(0x4D) out8(0x85) out8(0xC9) out8(0x0F) out8(0x84)
        I64 no_sign = tell()
        out32(0)
        out8(0x49) out8(0xFF) out8(0xC8) out8(0x41) out8(0xC6) out8(0x00) out8(45) out8(0x48) out8(0xFF) out8(0xC1)
        patch_rel(no_sign, tell())

        out8(0x4C) out8(0x89) out8(0xC6) out8(0x48) out8(0x89) out8(0xCA) out8(0x48) out8(0xC7) out8(0xC7) out32(1)
        out8(0x48) out8(0xC7) out8(0xC0) out32(1)
        out8(0x0F) out8(0x05) out8(0x48) out8(0x83) out8(0xC4) out8(64)
        return 0
    }

    fn emit_pin_u64_code() {
        out8(0x48) out8(0x83) out8(0xEC) out8(64) out8(0x49) out8(0x89) out8(0xE0) out8(0x49) out8(0x83) out8(0xC0) out8(63) out8(0x48) out8(0x31) out8(0xC9) out8(0x49) out8(0xC7) out8(0xC2) out32(10)

        I64 loop = tell()
        out8(0x48) out8(0x31) out8(0xD2) out8(0x49) out8(0xF7) out8(0xF2) out8(0x80) out8(0xC2) out8(48) out8(0x49) out8(0xFF) out8(0xC8) out8(0x41) out8(0x88) out8(0x10) out8(0x48) out8(0xFF) out8(0xC1) out8(0x48) out8(0x85) out8(0xC0) out8(0x0F) out8(0x85)
        I64 loop_back = tell()
        out32(0)
        patch_rel(loop_back, loop)

        out8(0x4C) out8(0x89) out8(0xC6) out8(0x48) out8(0x89) out8(0xCA) out8(0x48) out8(0xC7) out8(0xC7) out32(1)
        out8(0x48) out8(0xC7) out8(0xC0) out32(1)
        out8(0x0F) out8(0x05) out8(0x48) out8(0x83) out8(0xC4) out8(64)
        return 0
    }

    fn emit_pin_hex_code() {
        out8(0x48) out8(0x83) out8(0xEC) out8(32) out8(0x49) out8(0x89) out8(0xE0) out8(0x49) out8(0x83) out8(0xC0) out8(31) out8(0x48) out8(0x31) out8(0xC9)

        I64 loop = tell()
        out8(0x48) out8(0x89) out8(0xC2) out8(0x83) out8(0xE2) out8(15) out8(0x80) out8(0xFA) out8(9) out8(0x0F) out8(0x86)
        I64 number = tell()
        out32(0)
        out8(0x80) out8(0xC2) out8(55)
        I64 store_jump = emit_jmp()

        patch_rel(number, tell())
        out8(0x80) out8(0xC2) out8(48)

        patch_rel(store_jump, tell())
        out8(0x49) out8(0xFF) out8(0xC8) out8(0x41) out8(0x88) out8(0x10) out8(0x48) out8(0xFF) out8(0xC1) out8(0x48) out8(0xC1) out8(0xE8) out8(4) out8(0x48) out8(0x85) out8(0xC0) out8(0x0F) out8(0x85)
        I64 loop_back = tell()
        out32(0)
        patch_rel(loop_back, loop)

        out8(0x4C) out8(0x89) out8(0xC6) out8(0x48) out8(0x89) out8(0xCA) out8(0x48) out8(0xC7) out8(0xC7) out32(1)
        out8(0x48) out8(0xC7) out8(0xC0) out32(1)
        out8(0x0F) out8(0x05) out8(0x48) out8(0x83) out8(0xC4) out8(32)
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
        out8(0x48) out8(0x85) out8(0xC0) out8(0x0F) out8(0x84)
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
        out8(0x48) out8(0x89) out8(0xC2) out8(0x5E) out8(0x48) out8(0xC7) out8(0xC7) out32(1)
        out8(0x48) out8(0xC7) out8(0xC0) out32(1)
        out8(0x0F) out8(0x05)
        return 0
    }

    fn emit_pin_fixed6_code() {
        out8(0x48) out8(0x83) out8(0xEC) out8(8) out8(0x49) out8(0x89) out8(0xE0) out8(0x49) out8(0x83) out8(0xC0) out8(6) out8(0x48) out8(0x31) out8(0xC9) out8(0x49) out8(0xC7) out8(0xC2) out32(10)

        I64 loop = tell()
        out8(0x48) out8(0x31) out8(0xD2) out8(0x49) out8(0xF7) out8(0xF2) out8(0x80) out8(0xC2) out8(48) out8(0x49) out8(0xFF) out8(0xC8) out8(0x41) out8(0x88) out8(0x10) out8(0x48) out8(0xFF) out8(0xC1) out8(0x48) out8(0x83) out8(0xF9) out8(6) out8(0x0F) out8(0x85)
        I64 loop_back = tell()
        out32(0)
        patch_rel(loop_back, loop)

        out8(0x4C) out8(0x89) out8(0xC6) out8(0x48) out8(0xC7) out8(0xC2) out32(6)
        out8(0x48) out8(0xC7) out8(0xC7) out32(1)
        out8(0x48) out8(0xC7) out8(0xC0) out32(1)
        out8(0x0F) out8(0x05) out8(0x48) out8(0x83) out8(0xC4) out8(8)
        return 0
    }

    fn emit_pin_f64_code() {
        out8(0x48) out8(0x85) out8(0xC0) out8(0x0F) out8(0x89)
        I64 positive = tell()
        out32(0)

        emit_push()
        emit_imm(45)
        emit_pin_char_code()
        out8(0x58)

        patch_rel(positive, tell())
        out8(0x48) out8(0xD1) out8(0xE0) out8(0x48) out8(0xD1) out8(0xE8)

        emit_push()

        out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xC0) out8(0xF2) out8(0x48) out8(0x0F) out8(0x2C) out8(0xC0)
        emit_pin_u64_code()

        emit_imm(46)
        emit_pin_char_code()

        out8(0x58) out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xC0) out8(0xF2) out8(0x4C) out8(0x0F) out8(0x2C) out8(0xC0) out8(0xF2) out8(0x49) out8(0x0F) out8(0x2A) out8(0xC8) out8(0xF2) out8(0x0F) out8(0x5C) out8(0xC1) out8(0x66) out8(0x48) out8(0x0F) out8(0x7E) out8(0xC0) out8(0x48) out8(0xD1) out8(0xE0) out8(0x48) out8(0xD1) out8(0xE8) out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xC0)

        emit_imm(1000000)
        out8(0xF2) out8(0x48) out8(0x0F) out8(0x2A) out8(0xC8) out8(0xF2) out8(0x0F) out8(0x59) out8(0xC1)

        emit_imm(1)
        out8(0xF2) out8(0x48) out8(0x0F) out8(0x2A) out8(0xC8)
        emit_imm(2)
        out8(0xF2) out8(0x48) out8(0x0F) out8(0x2A) out8(0xD0) out8(0xF2) out8(0x0F) out8(0x5E) out8(0xCA) out8(0xF2) out8(0x0F) out8(0x58) out8(0xC1) out8(0xF2) out8(0x48) out8(0x0F) out8(0x2C) out8(0xC0)
        emit_pin_fixed6_code()
        return 0
    }

    fn pin_format_id(I64 text, I64 position, I64 length) {
        if (position + 1 >= length) { return 0 }
        if (mem_read8(text + position) != 37) { return 0 }

        I64 a = mem_read8(text + position + 1)

        if (a == 99) { return 1 }
        if (a == 115) { return 2 }
        if (a == 112) { return 3 }
        if (a == 37) { return 5 }
        if (a == 66) { return 19 }

        if (a == 73) {
            if (position + 2 < length) {
                if (mem_read8(text + position + 2) == 56) { return 10 }
            }
            if (position + 3 < length) {
                if (mem_read8(text + position + 2) == 49) {
                    if (mem_read8(text + position + 3) == 54) { return 11 }
                }
                if (mem_read8(text + position + 2) == 51) {
                    if (mem_read8(text + position + 3) == 50) { return 12 }
                }
                if (mem_read8(text + position + 2) == 54) {
                    if (mem_read8(text + position + 3) == 52) { return 13 }
                }
            }
        }

        if (a == 85) {
            if (position + 2 < length) {
                if (mem_read8(text + position + 2) == 56) { return 14 }
            }
            if (position + 3 < length) {
                if (mem_read8(text + position + 2) == 49) {
                    if (mem_read8(text + position + 3) == 54) { return 15 }
                }
                if (mem_read8(text + position + 2) == 51) {
                    if (mem_read8(text + position + 3) == 50) { return 16 }
                }
                if (mem_read8(text + position + 2) == 54) {
                    if (mem_read8(text + position + 3) == 52) { return 17 }
                }
            }
        }

        if (a == 70) {
            if (position + 3 < length) {
                if (mem_read8(text + position + 2) == 54) {
                    if (mem_read8(text + position + 3) == 52) { return 18 }
                }
            }
        }

        if (a == 88) {
            if (position + 3 < length) {
                if (mem_read8(text + position + 2) == 54) {
                    if (mem_read8(text + position + 3) == 52) { return 4 }
                }
            }
        }

        return 0
    }

    fn pin_format_length(I64 id) {
        if (id == 1) { return 2 }
        if (id == 2) { return 2 }
        if (id == 3) { return 2 }
        if (id == 5) { return 2 }
        if (id == 19) { return 2 }
        if (id == 10) { return 3 }
        if (id == 14) { return 3 }
        return 4
    }

    fn pin_format_target_type(I64 id) {
        if (id == 10) { return 1 }
        if (id == 11) { return 2 }
        if (id == 12) { return 3 }
        if (id == 13) { return 4 }
        if (id == 14) { return 5 }
        if (id == 15) { return 6 }
        if (id == 16) { return 7 }
        if (id == 17) { return 8 }
        if (id == 18) { return 9 }
        if (id == 19) { return 10 }
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

        if (target == 1) { emit_pin_i64_code() return 0 }
        if (target == 2) { emit_pin_i64_code() return 0 }
        if (target == 3) { emit_pin_i64_code() return 0 }
        if (target == 4) { emit_pin_i64_code() return 0 }

        if (target == 5) { emit_pin_u64_code() return 0 }
        if (target == 6) { emit_pin_u64_code() return 0 }
        if (target == 7) { emit_pin_u64_code() return 0 }
        if (target == 8) { emit_pin_u64_code() return 0 }

        if (target == 9) { emit_pin_f64_code() return 0 }
        if (target == 10) { emit_pin_bool_code() return 0 }

        fail()
        return 0
    }

    fn parse_pin_statement() {
        if (out_raw() != 0) { compiler_error(12) return 0 }
        expect_sym(40)
        take()

        if (ct() != 3) {
            fail()
            return 0
        }

        I64 original = cp()
        I64 length = clen()
        I64 text = copy_string_pool(original, length)
        if (failed() != 0) { return 0 }

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
        if (mem_read64(0x800088) != 0) { return value }
        I64 fd = mem_read64(0x800008)
        file_write8(fd, value & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 1)
        return value
    }


    fn asm_put2(I64 a, I64 b) {
        if (mem_read64(0x800088) != 0) { return 0 }
        I64 fd = mem_read64(0x800008)
        file_write8(fd, a & 255)
        file_write8(fd, b & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 2)
        return 0
    }
    fn asm_put3(I64 a, I64 b, I64 c) {
        if (mem_read64(0x800088) != 0) { return 0 }
        I64 fd = mem_read64(0x800008)
        file_write8(fd, a & 255)
        file_write8(fd, b & 255)
        file_write8(fd, c & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 3)
        return 0
    }
    fn asm_put4(I64 a, I64 b, I64 c, I64 d) {
        if (mem_read64(0x800088) != 0) { return 0 }
        I64 fd = mem_read64(0x800008)
        file_write8(fd, a & 255)
        file_write8(fd, b & 255)
        file_write8(fd, c & 255)
        file_write8(fd, d & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 4)
        return 0
    }
    fn asm_put5(I64 a, I64 b, I64 c, I64 d, I64 e) {
        if (mem_read64(0x800088) != 0) { return 0 }
        I64 fd = mem_read64(0x800008)
        file_write8(fd, a & 255)
        file_write8(fd, b & 255)
        file_write8(fd, c & 255)
        file_write8(fd, d & 255)
        file_write8(fd, e & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 5)
        return 0
    }
    fn asm_put6(I64 a, I64 b, I64 c, I64 d, I64 e, I64 f) {
        if (mem_read64(0x800088) != 0) { return 0 }
        I64 fd = mem_read64(0x800008)
        file_write8(fd, a & 255)
        file_write8(fd, b & 255)
        file_write8(fd, c & 255)
        file_write8(fd, d & 255)
        file_write8(fd, e & 255)
        file_write8(fd, f & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 6)
        return 0
    }

    fn asm_put16(I64 value) {
        if (mem_read64(0x800088) != 0) { return value }
        I64 fd = mem_read64(0x800008)
        file_write8(fd, value & 255)
        file_write8(fd, (value >> 8) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 2)
        return value
    }

    fn asm_put32(I64 value) {
        if (mem_read64(0x800088) != 0) { return value }
        I64 fd = mem_read64(0x800008)
        file_write8(fd, value & 255)
        file_write8(fd, (value >> 8) & 255)
        file_write8(fd, (value >> 16) & 255)
        file_write8(fd, (value >> 24) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 4)
        return value
    }

    fn asm_put64(I64 value) {
        if (mem_read64(0x800088) != 0) { return value }
        I64 fd = mem_read64(0x800008)
        file_write8(fd, value & 255)
        file_write8(fd, (value >> 8) & 255)
        file_write8(fd, (value >> 16) & 255)
        file_write8(fd, (value >> 24) & 255)
        file_write8(fd, (value >> 32) & 255)
        file_write8(fd, (value >> 40) & 255)
        file_write8(fd, (value >> 48) & 255)
        file_write8(fd, (value >> 56) & 255)
        mem_write64(0x800090, mem_read64(0x800090) + 8)
        return value
    }

    fn asm_reg_info(I64 hash) {
        if (hash == 0x597732) { return 0x120 }
        if (hash == 0x597774) { return 0x121 }
        if (hash == 0x597795) { return 0x122 }
        if (hash == 0x597753) { return 0x123 }
        if (hash == 0xB88AAF4) { return 0x124 }
        if (hash == 0xB8862A3) { return 0x125 }
        if (hash == 0xB88AA0D) { return 0x126 }
        if (hash == 0xB886A3E) { return 0x127 }
        if (hash == 0xB889F71) { return 0x128 }
        if (hash == 0xB889F92) { return 0x129 }
        if (hash == 0x17C9C69BA) { return 0x12A }
        if (hash == 0x17C9C69DB) { return 0x12B }
        if (hash == 0x17C9C69FC) { return 0x12C }
        if (hash == 0x17C9C6A1D) { return 0x12D }
        if (hash == 0x17C9C6A3E) { return 0x12E }
        if (hash == 0x17C9C6A5F) { return 0x12F }
        if (hash == 0x59772E) { return 0x224 }
        if (hash == 0x597770) { return 0x225 }
        if (hash == 0x597791) { return 0x226 }
        if (hash == 0x59774F) { return 0x227 }
        if (hash == 0x59773E) { return 0x140 }
        if (hash == 0x597780) { return 0x141 }
        if (hash == 0x5977A1) { return 0x142 }
        if (hash == 0x59775F) { return 0x143 }
        if (hash == 0x597988) { return 0x144 }
        if (hash == 0x597757) { return 0x145 }
        if (hash == 0x597981) { return 0x146 }
        if (hash == 0x597792) { return 0x147 }
        if (hash == 0xB889F86) { return 0x148 }
        if (hash == 0xB889FA7) { return 0x149 }
        if (hash == 0x17C9C69CF) { return 0x14A }
        if (hash == 0x17C9C69F0) { return 0x14B }
        if (hash == 0x17C9C6A11) { return 0x14C }
        if (hash == 0x17C9C6A32) { return 0x14D }
        if (hash == 0x17C9C6A53) { return 0x14E }
        if (hash == 0x17C9C6A74) { return 0x14F }
        if (hash == 0xB886D83) { return 0x160 }
        if (hash == 0xB886DC5) { return 0x161 }
        if (hash == 0xB886DE6) { return 0x162 }
        if (hash == 0xB886DA4) { return 0x163 }
        if (hash == 0xB886FCD) { return 0x164 }
        if (hash == 0xB886D9C) { return 0x165 }
        if (hash == 0xB886FC6) { return 0x166 }
        if (hash == 0xB886DD7) { return 0x167 }
        if (hash == 0xB889F73) { return 0x168 }
        if (hash == 0xB889F94) { return 0x169 }
        if (hash == 0x17C9C69BC) { return 0x16A }
        if (hash == 0x17C9C69DD) { return 0x16B }
        if (hash == 0x17C9C69FE) { return 0x16C }
        if (hash == 0x17C9C6A1F) { return 0x16D }
        if (hash == 0x17C9C6A40) { return 0x16E }
        if (hash == 0x17C9C6A61) { return 0x16F }
        if (hash == 0xB88A4D0) { return 0x180 }
        if (hash == 0xB88A512) { return 0x181 }
        if (hash == 0xB88A533) { return 0x182 }
        if (hash == 0xB88A4F1) { return 0x183 }
        if (hash == 0xB88A71A) { return 0x184 }
        if (hash == 0xB88A4E9) { return 0x185 }
        if (hash == 0xB88A713) { return 0x186 }
        if (hash == 0xB88A524) { return 0x187 }
        if (hash == 0x59792F) { return 0x188 }
        if (hash == 0x597930) { return 0x189 }
        if (hash == 0xB889E58) { return 0x18A }
        if (hash == 0xB889E59) { return 0x18B }
        if (hash == 0xB889E5A) { return 0x18C }
        if (hash == 0xB889E5B) { return 0x18D }
        if (hash == 0xB889E5C) { return 0x18E }
        if (hash == 0xB889E5D) { return 0x18F }
        if (hash == 0x5977BD) { return 0x340 }
        if (hash == 0x59777B) { return 0x341 }
        if (hash == 0x59798B) { return 0x342 }
        if (hash == 0x59779C) { return 0x343 }
        if (hash == 0x5977DE) { return 0x344 }
        if (hash == 0x5977FF) { return 0x345 }
        if (hash == 0xB8866EA) { return 0x480 }
        if (hash == 0xB8866EC) { return 0x482 }
        if (hash == 0xB8866ED) { return 0x483 }
        if (hash == 0xB8866EE) { return 0x484 }
        if (hash == 0xB8866F2) { return 0x488 }
        if (hash == 0xB886B2B) { return 0x580 }
        if (hash == 0xB886B2C) { return 0x581 }
        if (hash == 0xB886B2D) { return 0x582 }
        if (hash == 0xB886B2E) { return 0x583 }
        if (hash == 0xB886B31) { return 0x586 }
        if (hash == 0xB886B32) { return 0x587 }
        return 0
    }

    fn asm_reg_width(I64 info) {
        I64 code = (info >> 5) & 7
        if (code == 1) { return 8 }
        if (code == 2) { return 16 }
        if (code == 3) { return 32 }
        if (code == 4) { return 64 }
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
                if (ct() != 2) { compiler_error(18) return 0 }
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

        if (count >= 382) { fail() return 0 }

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
        if (count >= 3500) { fail() return 0 }

        I64 entry = 0x812000 + count * 24
        mem_write64(entry, hash)
        mem_write64(entry + 8, patch)
        mem_write64(entry + 16, kind)
        mem_write64(0x800040, count + 1)
        return patch
    }

    fn asm_rex(I64 width, I64 regcode, I64 rmcode, I64 force) {
        if (mem_read64(0x800508) != 64) { return 0 }

        I64 rex = 0x40
        if (width == 64) { rex = rex | 8 }
        if (regcode >= 8) { rex = rex | 4 }
        if (rmcode >= 8) { rex = rex | 1 }

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
            if (bits != 16) { asm_put8(0x66) }
            return 0
        }

        if (width == 32) {
            if (bits == 16) { asm_put8(0x66) }
            return 0
        }

        if (width == 64) {
            if (bits != 64) { compiler_error(18) return 0 }
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

        if (dw != sw) { compiler_error(18) return 0 }
        if (dkind > 2) { compiler_error(18) return 0 }
        if (skind > 2) { compiler_error(18) return 0 }

        I64 bits = mem_read64(0x800508)

        if (dc >= 8) {
            if (bits != 64) { compiler_error(18) return 0 }
        }
        if (sc >= 8) {
            if (bits != 64) { compiler_error(18) return 0 }
        }

        if (dw == 8) {
            if (dkind == 1) {
                if (dc >= 4) {
                    if (bits != 64) { compiler_error(18) return 0 }
                }
            }
            if (skind == 1) {
                if (sc >= 4) {
                    if (bits != 64) { compiler_error(18) return 0 }
                }
            }
        }

        if (dkind == 2) {
            if (skind == 1) {
                if (sc >= 4) { compiler_error(18) return 0 }
            }
        }
        if (skind == 2) {
            if (dkind == 1) {
                if (dc >= 4) { compiler_error(18) return 0 }
            }
        }

        if (dw != 8) { asm_opsize(dw) }

        I64 force = 0
        if (dw == 8) {
            if (dkind == 1) {
                if (dc >= 4) { force = 1 }
            }
            if (skind == 1) {
                if (sc >= 4) { force = 1 }
            }
            if (dkind == 2) { force = 0 }
            if (skind == 2) { force = 0 }
        }

        asm_rex(dw, sc, dc, force)

        if (dw == 8) { asm_put8(opcode8) }
        if (dw != 8) { asm_put8(opcodewide) }

        asm_put8(0xC0 + ((sc & 7) * 8) + (dc & 7))
        return 1
    }

    fn asm_emit_mov_imm(I64 dest, I64 kind, I64 value) {
        I64 dkind = (dest >> 8) & 15
        I64 width = asm_reg_width(dest)
        I64 code = dest & 31

        if (dkind > 2) { compiler_error(18) return 0 }
        I64 bits = mem_read64(0x800508)

        if (code >= 8) {
            if (bits != 64) { compiler_error(18) return 0 }
        }

        if (width == 8) {
            if (kind == 3) { compiler_error(18) return 0 }
            if (value > 255) { compiler_error(21) return 0 }

            I64 force = 0

            if (dkind == 1) {
                if (code >= 4) {
                    if (bits != 64) { compiler_error(18) return 0 }
                    force = 1
                }
            }

            if (dkind == 2) { force = 0 }

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
                if (value > 65535) { compiler_error(21) return 0 }
            }
            if (kind == 3) { asm_add_fixup(value, patch, 0 - 3) }
            asm_put16(0)
            if (kind == 2) { patch16_at(patch, value) }
            return 1
        }

        if (width == 32) {
            if (kind == 2) {
                if (value > 0xFFFFFFFF) { compiler_error(21) return 0 }
            }
            if (kind == 3) { asm_add_fixup(value, patch, 0 - 4) }
            asm_put32(0)
            if (kind == 2) { patch32_at(patch, value) }
            return 1
        }

        if (width == 64) {
            if (kind == 3) { asm_add_fixup(value, patch, 0 - 5) }
            asm_put64(0)
            if (kind == 2) { patch64_at(patch, value) }
            return 1
        }

        compiler_error(18)
        return 0
    }

    fn asm_emit_mov(I64 dest_kind, I64 dest_value, I64 source_kind, I64 source_value) {
        if (dest_kind != 1) { compiler_error(18) return 0 }

        I64 dest = dest_value
        I64 dkind = (dest >> 8) & 15

        if (source_kind == 2) {
            return asm_emit_mov_imm(dest, 2, source_value)
        }

        if (source_kind == 3) {
            return asm_emit_mov_imm(dest, 3, source_value)
        }

        if (source_kind != 1) { compiler_error(18) return 0 }

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
                if (sw != 16) { compiler_error(18) return 0 }
                I64 seg = dest & 7
                I64 scode = source & 31
                if (seg == 1) { compiler_error(18) return 0 }
                if (scode >= 8) {
                    if (mem_read64(0x800508) != 64) { compiler_error(18) return 0 }
                }
                asm_rex(0, 0, scode, 0)
                asm_put2(0x8E, 0xC0 + seg * 8 + (scode & 7))
                return 1
            }
        }

        if (dkind == 1) {
            if (skind == 3) {
                I64 dw = asm_reg_width(dest)
                if (dw != 16) { compiler_error(18) return 0 }
                I64 dcode = dest & 31
                if (dcode >= 8) {
                    if (mem_read64(0x800508) != 64) { compiler_error(18) return 0 }
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
                    if (bits != 64) { compiler_error(18) return 0 }
                }
                I64 sw2 = asm_reg_width(source)
                if ((source & 31) >= 8) {
                    if (bits != 64) { compiler_error(18) return 0 }
                }
                if (bits == 64) {
                    if (sw2 != 64) { compiler_error(18) return 0 }
                }
                if (bits != 64) {
                    if (sw2 != 32) { compiler_error(18) return 0 }
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
                    if (bits2 != 64) { compiler_error(18) return 0 }
                }
                I64 dw2 = asm_reg_width(dest)
                if ((dest & 31) >= 8) {
                    if (bits2 != 64) { compiler_error(18) return 0 }
                }
                if (bits2 == 64) {
                    if (dw2 != 64) { compiler_error(18) return 0 }
                }
                if (bits2 != 64) {
                    if (dw2 != 32) { compiler_error(18) return 0 }
                }
                asm_rex(0, source & 31, dest & 31, 0)
                asm_put3(0x0F, 0x20, 0xC0 + ((source & 7) * 8) + (dest & 7))
                return 1
            }
        }

        if (dkind == 5) {
            if (skind == 1) {
                I64 bits3 = mem_read64(0x800508)
                if (bits3 == 16) { compiler_error(18) return 0 }
                I64 sw3 = asm_reg_width(source)
                if (bits3 == 32) {
                    if (sw3 != 32) { compiler_error(18) return 0 }
                }
                if (bits3 == 64) {
                    if (sw3 != 64) { compiler_error(18) return 0 }
                }
                if ((source & 31) >= 8) {
                    if (bits3 != 64) { compiler_error(18) return 0 }
                }
                asm_rex(0, dest & 31, source & 31, 0)
                asm_put3(0x0F, 0x23, 0xC0 + ((dest & 7) * 8) + (source & 7))
                return 1
            }
        }

        if (dkind == 1) {
            if (skind == 5) {
                I64 bits4 = mem_read64(0x800508)
                if (bits4 == 16) { compiler_error(18) return 0 }
                I64 dw4 = asm_reg_width(dest)
                if (bits4 == 32) {
                    if (dw4 != 32) { compiler_error(18) return 0 }
                }
                if (bits4 == 64) {
                    if (dw4 != 64) { compiler_error(18) return 0 }
                }
                if ((dest & 31) >= 8) {
                    if (bits4 != 64) { compiler_error(18) return 0 }
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

        if (dkind > 2) { compiler_error(18) return 0 }
        if (dc >= 8) {
            if (mem_read64(0x800508) != 64) { compiler_error(18) return 0 }
        }
        if (dkind == 2) {
            if (width != 8) { compiler_error(18) return 0 }
        }
        if (width == 8) {
            if (dkind == 1) {
                if (dc >= 4) {
                    if (mem_read64(0x800508) != 64) { compiler_error(18) return 0 }
                }
            }
        }

        if (source_kind == 1) {
            return asm_emit_reg_reg(opcode8, opcodewide, dest, source_value)
        }

        if (source_kind != 2) { compiler_error(18) return 0 }

        if (width != 8) { asm_opsize(width) }

        I64 force = 0
        if (width == 8) {
            if (dkind == 1) {
                if (dc >= 4) { force = 1 }
            }
        }

        asm_rex(width, group, dc, force)

        if (width == 8) {
            asm_put3(0x80, 0xC0 + group * 8 + (dc & 7), source_value)
            return 1
        }

        asm_put2(0x81, 0xC0 + group * 8 + (dc & 7))

        if (width == 16) { asm_put16(source_value) return 1 }
        asm_put32(source_value)
        return 1
    }

    fn asm_emit_shift(I64 group, I64 reg, I64 amount) {
        I64 kind = (reg >> 8) & 15
        I64 width = asm_reg_width(reg)
        I64 code = reg & 31
        if (kind > 2) { compiler_error(18) return 0 }
        if (code >= 8) {
            if (mem_read64(0x800508) != 64) { compiler_error(18) return 0 }
        }
        if (kind == 2) {
            if (width != 8) { compiler_error(18) return 0 }
        }
        if (width == 8) {
            if (kind == 1) {
                if (code >= 4) {
                    if (mem_read64(0x800508) != 64) { compiler_error(18) return 0 }
                }
            }
        }

        if (width != 8) { asm_opsize(width) }

        I64 force = 0
        if (width == 8) {
            if (kind == 1) {
                if (code >= 4) { force = 1 }
            }
        }

        asm_rex(width, group, code, force)

        if (width == 8) { asm_put8(0xC0) }
        if (width != 8) { asm_put8(0xC1) }

        asm_put2(0xC0 + group * 8 + (code & 7), amount)
        return 1
    }

    fn asm_emit_pushpop(I64 reg, I64 pop) {
        I64 kind = (reg >> 8) & 15
        I64 width = asm_reg_width(reg)
        I64 code = reg & 31
        I64 bits = mem_read64(0x800508)

        if (kind != 1) { compiler_error(18) return 0 }
        if (width == 8) { compiler_error(18) return 0 }
        if (code >= 8) {
            if (bits != 64) { compiler_error(18) return 0 }
        }

        if (bits == 16) {
            if (width == 32) { asm_put8(0x66) }
            if (width == 64) { compiler_error(18) return 0 }
        }

        if (bits == 32) {
            if (width == 16) { asm_put8(0x66) }
            if (width == 64) { compiler_error(18) return 0 }
        }

        if (bits == 64) {
            if (width == 16) { asm_put8(0x66) }
            if (width == 32) { compiler_error(18) return 0 }
            asm_rex(0, 0, code, 0)
        }

        if (pop == 0) { asm_put8(0x50 + (code & 7)) }
        if (pop != 0) { asm_put8(0x58 + (code & 7)) }

        return 1
    }

    fn asm_emit_incdec(I64 reg, I64 dec) {
        I64 kind = (reg >> 8) & 15
        I64 width = asm_reg_width(reg)
        I64 code = reg & 31
        if (kind > 2) { compiler_error(18) return 0 }
        if (code >= 8) {
            if (mem_read64(0x800508) != 64) { compiler_error(18) return 0 }
        }
        if (kind == 2) {
            if (width != 8) { compiler_error(18) return 0 }
        }
        if (width == 8) {
            if (kind == 1) {
                if (code >= 4) {
                    if (mem_read64(0x800508) != 64) { compiler_error(18) return 0 }
                }
            }
        }

        if (width != 8) { asm_opsize(width) }

        I64 force = 0
        if (width == 8) {
            if (kind == 1) {
                if (code >= 4) { force = 1 }
            }
        }

        asm_rex(width, dec, code, force)

        if (width == 8) { asm_put8(0xFE) }
        if (width != 8) { asm_put8(0xFF) }

        asm_put8(0xC0 + dec * 8 + (code & 7))
        return 1
    }

    fn asm_emit_branch(I64 opcode, I64 hash) {
        I64 bits = mem_read64(0x800508)

        if (bits == 16) {
            if (opcode >= 0x80) {
                asm_put2(0x0F, opcode)
            }
            if (opcode == 0xE8) { asm_put8(0xE8) }
            if (opcode == 0xE9) { asm_put8(0xE9) }

            I64 patch = mem_read64(0x800090)
            asm_put16(0)
            asm_add_fixup(hash, patch, 0 - 1)
            return 1
        }

        if (bits == 32) {
            if (opcode >= 0x80) {
                asm_put2(0x0F, opcode)
            }
            if (opcode == 0xE8) { asm_put8(0xE8) }
            if (opcode == 0xE9) { asm_put8(0xE9) }

            I64 patch2 = mem_read64(0x800090)
            asm_put32(0)
            asm_add_fixup(hash, patch2, 0 - 2)
            return 1
        }

        if (bits == 64) {
            if (opcode >= 0x80) {
                asm_put2(0x0F, opcode)
            }
            if (opcode == 0xE8) { asm_put8(0xE8) }
            if (opcode == 0xE9) { asm_put8(0xE9) }

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
                if (target > 65535) { compiler_error(21) return 0 }
            }
            asm_put8(0xEA)
            I64 patch = mem_read64(0x800090)
            asm_put16(0)
            if (target_kind == 2) { patch16_at(patch, target) }
            if (target_kind == 3) { asm_add_fixup(target, patch, 0 - 3) }
            asm_put16(selector)
            return 1
        }

        if (bits == 32) {
            if (target_kind == 2) {
                if (target > 0xFFFFFFFF) { compiler_error(21) return 0 }
            }
            asm_put8(0xEA)
            I64 patch2 = mem_read64(0x800090)
            asm_put32(0)
            if (target_kind == 2) { patch32_at(patch2, target) }
            if (target_kind == 3) { asm_add_fixup(target, patch2, 0 - 4) }
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

        if (kind > 2) { compiler_error(18) return 0 }
        if (code >= 8) {
            if (bits != 64) { compiler_error(18) return 0 }
        }
        if (width == 8) {
            if (kind == 1) {
                if (code >= 4) {
                    if (bits != 64) { compiler_error(18) return 0 }
                }
            }
        }

        I64 wanted = op
        if (wanted == 1) { wanted = 8 }
        if (wanted == 2) { wanted = 16 }
        if (wanted == 3) { wanted = 32 }
        if (wanted == 4) { wanted = 64 }

        if (width != wanted) { compiler_error(18) return 0 }

        if (width != 8) { asm_opsize(width) }
        I64 force = 0
        if (width == 8) {
            if (kind == 1) {
                if (code >= 4) { force = 1 }
            }
        }
        asm_rex(width, code, 0, force)

        if (width == 8) { asm_put8(0x8A) }
        if (width != 8) { asm_put8(0x8B) }

        if (bits == 16) {
            asm_put8(((code & 7) * 8) + 6)
            I64 patch = mem_read64(0x800090)
            asm_put16(0)
            if (address_kind == 2) { patch16_at(patch, address) }
            if (address_kind == 3) { asm_add_fixup(address, patch, 0 - 3) }
            return 1
        }

        if (bits == 32) {
            asm_put8(((code & 7) * 8) + 5)
            I64 patch2 = mem_read64(0x800090)
            asm_put32(0)
            if (address_kind == 2) { patch32_at(patch2, address) }
            if (address_kind == 3) { asm_add_fixup(address, patch2, 0 - 4) }
            return 1
        }

        if (bits == 64) {
            asm_put2(((code & 7) * 8) + 4, 0x25)
            I64 patch3 = mem_read64(0x800090)
            asm_put32(0)
            if (address_kind == 2) { patch32_at(patch3, address) }
            if (address_kind == 3) { asm_add_fixup(address, patch3, 0 - 4) }
            return 1
        }

        compiler_error(17)
        return 0
    }

    fn asm_emit_store_imm(I64 size_id, I64 address_kind, I64 address, I64 value) {
        I64 bits = mem_read64(0x800508)
        I64 width = 8
        if (size_id == 2) { width = 16 }
        if (size_id == 3) { width = 32 }

        if (width == 8) {
            if (value > 255) { compiler_error(21) return 0 }
        }
        if (width == 16) {
            if (value > 65535) { compiler_error(21) return 0 }
        }
        if (width == 32) {
            if (value > 0xFFFFFFFF) { compiler_error(21) return 0 }
        }

        if (width != 8) { asm_opsize(width) }

        if (width == 8) { asm_put8(0xC6) }
        if (width != 8) { asm_put8(0xC7) }

        if (bits == 16) {
            asm_put8(0x06)
            I64 patch = mem_read64(0x800090)
            asm_put16(0)
            if (address_kind == 2) { patch16_at(patch, address) }
            if (address_kind == 3) { asm_add_fixup(address, patch, 0 - 3) }
        }

        if (bits == 32) {
            asm_put8(0x05)
            I64 patch2 = mem_read64(0x800090)
            asm_put32(0)
            if (address_kind == 2) { patch32_at(patch2, address) }
            if (address_kind == 3) { asm_add_fixup(address, patch2, 0 - 4) }
        }

        if (bits == 64) {
            asm_put2(0x04, 0x25)
            I64 patch3 = mem_read64(0x800090)
            asm_put32(0)
            if (address_kind == 2) { patch32_at(patch3, address) }
            if (address_kind == 3) { asm_add_fixup(address, patch3, 0 - 4) }
        }

        if (bits == 0) { compiler_error(17) return 0 }

        if (width == 8) { asm_put8(value) }
        if (width == 16) { asm_put16(value) }
        if (width == 32) { asm_put32(value) }

        return 1
    }

    fn asm_emit_store_reg(I64 size_id, I64 address_kind, I64 address, I64 reg) {
        I64 bits = mem_read64(0x800508)
        I64 kind = (reg >> 8) & 15
        I64 width = asm_reg_width(reg)
        I64 code = reg & 31
        I64 wanted = 8

        if (size_id == 2) { wanted = 16 }
        if (size_id == 3) { wanted = 32 }
        if (size_id == 4) { wanted = 64 }

        if (kind > 2) { compiler_error(18) return 0 }
        if (code >= 8) {
            if (bits != 64) { compiler_error(18) return 0 }
        }
        if (width != wanted) { compiler_error(18) return 0 }

        if (width == 8) {
            if (kind == 1) {
                if (code >= 4) {
                    if (bits != 64) { compiler_error(18) return 0 }
                }
            }
        }

        if (width != 8) { asm_opsize(width) }

        I64 force = 0
        if (width == 8) {
            if (kind == 1) {
                if (code >= 4) { force = 1 }
            }
        }

        asm_rex(width, code, 0, force)

        if (width == 8) { asm_put8(0x88) }
        if (width != 8) { asm_put8(0x89) }

        if (bits == 16) {
            asm_put8(((code & 7) * 8) + 6)
            I64 patch = mem_read64(0x800090)
            asm_put16(0)
            if (address_kind == 2) { patch16_at(patch, address) }
            if (address_kind == 3) { asm_add_fixup(address, patch, 0 - 3) }
            return 1
        }

        if (bits == 32) {
            asm_put8(((code & 7) * 8) + 5)
            I64 patch2 = mem_read64(0x800090)
            asm_put32(0)
            if (address_kind == 2) { patch32_at(patch2, address) }
            if (address_kind == 3) { asm_add_fixup(address, patch2, 0 - 4) }
            return 1
        }

        if (bits == 64) {
            asm_put2(((code & 7) * 8) + 4, 0x25)
            I64 patch3 = mem_read64(0x800090)
            asm_put32(0)
            if (address_kind == 2) { patch32_at(patch3, address) }
            if (address_kind == 3) { asm_add_fixup(address, patch3, 0 - 4) }
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

        if (kind != 1) { compiler_error(18) return 0 }
        if (width != 16) { compiler_error(18) return 0 }
        if (code >= 8) {
            if (bits != 64) { compiler_error(18) return 0 }
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

        if (kind != 1) { compiler_error(18) return 0 }
        if (code >= 8) {
            if (bits != 64) { compiler_error(18) return 0 }
        }

        if (bits == 16) {
            if (width != 16) { compiler_error(18) return 0 }
        }

        if (bits == 32) {
            if (width != 32) { compiler_error(18) return 0 }
        }

        if (bits == 64) {
            if (width != 64) { compiler_error(18) return 0 }
            asm_rex(0, 0, code, 0)
        }

        if (bits == 0) { compiler_error(17) return 0 }

        asm_put8(0xFF)

        I64 group = 4
        if (call_mode != 0) { group = 2 }

        asm_put8(0xC0 + group * 8 + (code & 7))
        return 1
    }


    fn asm_emit_lgdt_lidt(I64 idt, I64 address_kind, I64 address) {
        I64 bits = mem_read64(0x800508)

        asm_put2(0x0F, 0x01)

        I64 group = 2
        if (idt != 0) { group = 3 }

        if (bits == 16) {
            asm_put8(group * 8 + 6)
            I64 patch = mem_read64(0x800090)
            asm_put16(0)
            if (address_kind == 2) { patch16_at(patch, address) }
            if (address_kind == 3) { asm_add_fixup(address, patch, 0 - 3) }
            return 1
        }

        if (bits == 32) {
            asm_put8(group * 8 + 5)
            I64 patch2 = mem_read64(0x800090)
            asm_put32(0)
            if (address_kind == 2) { patch32_at(patch2, address) }
            if (address_kind == 3) { asm_add_fixup(address, patch2, 0 - 4) }
            return 1
        }

        if (bits == 64) {
            asm_put2(group * 8 + 4, 0x25)
            I64 patch3 = mem_read64(0x800090)
            asm_put32(0)
            if (address_kind == 2) { patch32_at(patch3, address) }
            if (address_kind == 3) { asm_add_fixup(address, patch3, 0 - 4) }
            return 1
        }

        compiler_error(17)
        return 0
    }

    fn asm_emit_in(I64 dest, I64 port_kind, I64 port_value) {
        I64 width = asm_reg_width(dest)
        I64 code = dest & 31
        I64 kind = (dest >> 8) & 15

        if (kind > 2) { compiler_error(18) return 0 }
        if (code != 0) { compiler_error(18) return 0 }
        if (width == 64) { compiler_error(18) return 0 }

        if (width != 8) { asm_opsize(width) }

        if (port_kind == 2) {
            if (port_value > 255) { compiler_error(18) return 0 }
            if (width == 8) { asm_put8(0xE4) }
            if (width != 8) { asm_put8(0xE5) }
            asm_put8(port_value)
            return 1
        }

        if (port_kind == 1) {
            I64 pwidth = asm_reg_width(port_value)
            I64 pcode = port_value & 31
            I64 pkind = (port_value >> 8) & 15
            if (pkind != 1) { compiler_error(18) return 0 }
            if (pwidth != 16) { compiler_error(18) return 0 }
            if (pcode != 2) { compiler_error(18) return 0 }

            if (width == 8) { asm_put8(0xEC) }
            if (width != 8) { asm_put8(0xED) }
            return 1
        }

        compiler_error(18)
        return 0
    }

    fn asm_emit_out(I64 port_kind, I64 port_value, I64 source) {
        I64 width = asm_reg_width(source)
        I64 code = source & 31
        I64 kind = (source >> 8) & 15

        if (kind > 2) { compiler_error(18) return 0 }
        if (code != 0) { compiler_error(18) return 0 }
        if (width == 64) { compiler_error(18) return 0 }

        if (width != 8) { asm_opsize(width) }

        if (port_kind == 2) {
            if (port_value > 255) { compiler_error(18) return 0 }
            if (width == 8) { asm_put8(0xE6) }
            if (width != 8) { asm_put8(0xE7) }
            asm_put8(port_value)
            return 1
        }

        if (port_kind == 1) {
            I64 pwidth = asm_reg_width(port_value)
            I64 pcode = port_value & 31
            I64 pkind = (port_value >> 8) & 15
            if (pkind != 1) { compiler_error(18) return 0 }
            if (pwidth != 16) { compiler_error(18) return 0 }
            if (pcode != 2) { compiler_error(18) return 0 }

            if (width == 8) { asm_put8(0xEE) }
            if (width != 8) { asm_put8(0xEF) }
            return 1
        }

        compiler_error(18)
        return 0
    }


    fn parse_inline_asm() {
        if (use_asm_feature() == 0) { return 0 }

        expect_word("asmb")
        expect_sym(41)
        expect_sym(123)

        I64 done = 0

        while (done == 0) {
            take()

            if (ct() == 4) {
                if (cv() == 125) { done = 1 }
            }

            if (done == 0) {
                if (ct() != 1) {
                    compiler_error(18)
                    return 0
                }

                I64 handled = 0

                if (tok_is("bits16") != 0) {
                    if ((mem_read64(0x8000A0) & 1) == 0) { compiler_error(17) return 0 }
                    mem_write64(0x800508, 16)
                    handled = 1
                }

                if (tok_is("bits32") != 0) {
                    if ((mem_read64(0x8000A0) & 2) == 0) { compiler_error(17) return 0 }
                    mem_write64(0x800508, 32)
                    handled = 1
                }

                if (tok_is("bits64") != 0) {
                    if ((mem_read64(0x8000A0) & 4) == 0) { compiler_error(17) return 0 }
                    mem_write64(0x800508, 64)
                    handled = 1
                }

                if (tok_is("org") != 0) {
                    handled = 1
                    if (mem_read64(0x800518) != 0) { compiler_error(18) return 0 }
                    expect_sym(40)
                    take()
                    if (ct() != 2) { compiler_error(18) return 0 }
                    mem_write64(0x800510, cv())
                    mem_write64(0x800518, 1)
                    expect_sym(41)
                }

                if (tok_is("label") != 0) {
                    handled = 1
                    expect_sym(40)
                    take()
                    if (ct() != 1) { compiler_error(18) return 0 }
                    asm_register_label(chash(), mem_read64(0x800090))
                    expect_sym(41)
                }

                if (tok_is("mov") != 0) {
                    handled = 1
                    expect_sym(40)

                    asm_parse_operand()
                    I64 dk = mem_read64(0x800550)
                    I64 dv = mem_read64(0x800558)
                    if (dk == 1) { dv = mem_read64(0x800560) }

                    expect_sym(44)

                    asm_parse_operand()
                    I64 sk = mem_read64(0x800550)
                    I64 sv = mem_read64(0x800558)
                    if (sk == 1) { sv = mem_read64(0x800560) }

                    expect_sym(41)

                    asm_emit_mov(dk, dv, sk, sv)
                }

                if (tok_is("add") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    I64 dk2 = mem_read64(0x800550)
                    I64 dv2 = mem_read64(0x800560)
                    if (dk2 != 1) { compiler_error(18) return 0 }
                    expect_sym(44)
                    asm_parse_operand()
                    I64 sk2 = mem_read64(0x800550)
                    I64 sv2 = mem_read64(0x800558)
                    if (sk2 == 1) { sv2 = mem_read64(0x800560) }
                    expect_sym(41)
                    asm_emit_binop(0x00, 0x01, 0, dv2, sk2, sv2)
                }

                if (tok_is("or") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    I64 dk3 = mem_read64(0x800550)
                    I64 dv3 = mem_read64(0x800560)
                    if (dk3 != 1) { compiler_error(18) return 0 }
                    expect_sym(44)
                    asm_parse_operand()
                    I64 sk3 = mem_read64(0x800550)
                    I64 sv3 = mem_read64(0x800558)
                    if (sk3 == 1) { sv3 = mem_read64(0x800560) }
                    expect_sym(41)
                    asm_emit_binop(0x08, 0x09, 1, dv3, sk3, sv3)
                }

                if (tok_is("and") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    I64 dk4 = mem_read64(0x800550)
                    I64 dv4 = mem_read64(0x800560)
                    if (dk4 != 1) { compiler_error(18) return 0 }
                    expect_sym(44)
                    asm_parse_operand()
                    I64 sk4 = mem_read64(0x800550)
                    I64 sv4 = mem_read64(0x800558)
                    if (sk4 == 1) { sv4 = mem_read64(0x800560) }
                    expect_sym(41)
                    asm_emit_binop(0x20, 0x21, 4, dv4, sk4, sv4)
                }

                if (tok_is("sub") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    I64 dk5 = mem_read64(0x800550)
                    I64 dv5 = mem_read64(0x800560)
                    if (dk5 != 1) { compiler_error(18) return 0 }
                    expect_sym(44)
                    asm_parse_operand()
                    I64 sk5 = mem_read64(0x800550)
                    I64 sv5 = mem_read64(0x800558)
                    if (sk5 == 1) { sv5 = mem_read64(0x800560) }
                    expect_sym(41)
                    asm_emit_binop(0x28, 0x29, 5, dv5, sk5, sv5)
                }

                if (tok_is("xor") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    I64 dk6 = mem_read64(0x800550)
                    I64 dv6 = mem_read64(0x800560)
                    if (dk6 != 1) { compiler_error(18) return 0 }
                    expect_sym(44)
                    asm_parse_operand()
                    I64 sk6 = mem_read64(0x800550)
                    I64 sv6 = mem_read64(0x800558)
                    if (sk6 == 1) { sv6 = mem_read64(0x800560) }
                    expect_sym(41)
                    asm_emit_binop(0x30, 0x31, 6, dv6, sk6, sv6)
                }

                if (tok_is("cmp") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    I64 dk7 = mem_read64(0x800550)
                    I64 dv7 = mem_read64(0x800560)
                    if (dk7 != 1) { compiler_error(18) return 0 }
                    expect_sym(44)
                    asm_parse_operand()
                    I64 sk7 = mem_read64(0x800550)
                    I64 sv7 = mem_read64(0x800558)
                    if (sk7 == 1) { sv7 = mem_read64(0x800560) }
                    expect_sym(41)
                    asm_emit_binop(0x38, 0x39, 7, dv7, sk7, sv7)
                }

                if (tok_is("test") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    if (mem_read64(0x800550) != 1) { compiler_error(18) return 0 }
                    I64 testdst = mem_read64(0x800560)
                    expect_sym(44)
                    asm_parse_operand()
                    if (mem_read64(0x800550) != 1) { compiler_error(18) return 0 }
                    I64 testsrc = mem_read64(0x800560)
                    expect_sym(41)
                    asm_emit_reg_reg(0x84, 0x85, testdst, testsrc)
                }

                if (tok_is("shl") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    if (mem_read64(0x800550) != 1) { compiler_error(18) return 0 }
                    I64 shiftreg = mem_read64(0x800560)
                    expect_sym(44)
                    asm_parse_operand()
                    if (mem_read64(0x800550) != 2) { compiler_error(18) return 0 }
                    I64 shiftamt = mem_read64(0x800558)
                    expect_sym(41)
                    asm_emit_shift(4, shiftreg, shiftamt)
                }

                if (tok_is("shr") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    if (mem_read64(0x800550) != 1) { compiler_error(18) return 0 }
                    I64 shiftreg2 = mem_read64(0x800560)
                    expect_sym(44)
                    asm_parse_operand()
                    if (mem_read64(0x800550) != 2) { compiler_error(18) return 0 }
                    I64 shiftamt2 = mem_read64(0x800558)
                    expect_sym(41)
                    asm_emit_shift(5, shiftreg2, shiftamt2)
                }

                if (tok_is("sar") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    if (mem_read64(0x800550) != 1) { compiler_error(18) return 0 }
                    I64 shiftreg3 = mem_read64(0x800560)
                    expect_sym(44)
                    asm_parse_operand()
                    if (mem_read64(0x800550) != 2) { compiler_error(18) return 0 }
                    I64 shiftamt3 = mem_read64(0x800558)
                    expect_sym(41)
                    asm_emit_shift(7, shiftreg3, shiftamt3)
                }

                if (tok_is("push") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    if (mem_read64(0x800550) != 1) { compiler_error(18) return 0 }
                    asm_emit_pushpop(mem_read64(0x800560), 0)
                    expect_sym(41)
                }

                if (tok_is("pop") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    if (mem_read64(0x800550) != 1) { compiler_error(18) return 0 }
                    asm_emit_pushpop(mem_read64(0x800560), 1)
                    expect_sym(41)
                }

                if (tok_is("inc") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    if (mem_read64(0x800550) != 1) { compiler_error(18) return 0 }
                    asm_emit_incdec(mem_read64(0x800560), 0)
                    expect_sym(41)
                }

                if (tok_is("dec") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    if (mem_read64(0x800550) != 1) { compiler_error(18) return 0 }
                    asm_emit_incdec(mem_read64(0x800560), 1)
                    expect_sym(41)
                }

                if (tok_is("sldt") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    if (mem_read64(0x800550) != 1) { compiler_error(18) return 0 }
                    asm_emit_selector_op(0, mem_read64(0x800560))
                    expect_sym(41)
                }

                if (tok_is("str") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    if (mem_read64(0x800550) != 1) { compiler_error(18) return 0 }
                    asm_emit_selector_op(1, mem_read64(0x800560))
                    expect_sym(41)
                }

                if (tok_is("lldt") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    if (mem_read64(0x800550) != 1) { compiler_error(18) return 0 }
                    asm_emit_selector_op(2, mem_read64(0x800560))
                    expect_sym(41)
                }

                if (tok_is("ltr") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    if (mem_read64(0x800550) != 1) { compiler_error(18) return 0 }
                    asm_emit_selector_op(3, mem_read64(0x800560))
                    expect_sym(41)
                }

                if (tok_is("int") != 0) {
                    handled = 1
                    expect_sym(40)
                    take()
                    if (ct() != 2) { compiler_error(18) return 0 }
                    if (cv() > 255) { compiler_error(18) return 0 }
                    asm_put2(0xCD, cv())
                    expect_sym(41)
                }

                if (tok_is("jmp") != 0) {
                    handled = 1
                    expect_sym(40)
                    take()
                    if (ct() != 1) { compiler_error(18) return 0 }
                    asm_emit_branch(0xE9, chash())
                    expect_sym(41)
                }

                if (tok_is("call") != 0) {
                    handled = 1
                    expect_sym(40)
                    take()
                    if (ct() != 1) { compiler_error(18) return 0 }
                    asm_emit_branch(0xE8, chash())
                    expect_sym(41)
                }

                if (tok_is("jmp_reg") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    if (mem_read64(0x800550) != 1) { compiler_error(18) return 0 }
                    asm_emit_indirect(mem_read64(0x800560), 0)
                    expect_sym(41)
                }

                if (tok_is("call_reg") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    if (mem_read64(0x800550) != 1) { compiler_error(18) return 0 }
                    asm_emit_indirect(mem_read64(0x800560), 1)
                    expect_sym(41)
                }

                if (tok_is("je") != 0) {
                    handled = 1
                    expect_sym(40) take()
                    if (ct() != 1) { compiler_error(18) return 0 }
                    asm_emit_branch(0x84, chash()) expect_sym(41)
                }

                if (tok_is("jne") != 0) {
                    handled = 1
                    expect_sym(40) take()
                    if (ct() != 1) { compiler_error(18) return 0 }
                    asm_emit_branch(0x85, chash()) expect_sym(41)
                }

                if (tok_is("jz") != 0) {
                    handled = 1
                    expect_sym(40) take()
                    if (ct() != 1) { compiler_error(18) return 0 }
                    asm_emit_branch(0x84, chash()) expect_sym(41)
                }

                if (tok_is("jnz") != 0) {
                    handled = 1
                    expect_sym(40) take()
                    if (ct() != 1) { compiler_error(18) return 0 }
                    asm_emit_branch(0x85, chash()) expect_sym(41)
                }

                if (tok_is("jc") != 0) {
                    handled = 1
                    expect_sym(40) take()
                    if (ct() != 1) { compiler_error(18) return 0 }
                    asm_emit_branch(0x82, chash()) expect_sym(41)
                }

                if (tok_is("jnc") != 0) {
                    handled = 1
                    expect_sym(40) take()
                    if (ct() != 1) { compiler_error(18) return 0 }
                    asm_emit_branch(0x83, chash()) expect_sym(41)
                }

                if (tok_is("jb") != 0) {
                    handled = 1
                    expect_sym(40) take()
                    if (ct() != 1) { compiler_error(18) return 0 }
                    asm_emit_branch(0x82, chash()) expect_sym(41)
                }

                if (tok_is("jae") != 0) {
                    handled = 1
                    expect_sym(40) take()
                    if (ct() != 1) { compiler_error(18) return 0 }
                    asm_emit_branch(0x83, chash()) expect_sym(41)
                }

                if (tok_is("jbe") != 0) {
                    handled = 1
                    expect_sym(40) take()
                    if (ct() != 1) { compiler_error(18) return 0 }
                    asm_emit_branch(0x86, chash()) expect_sym(41)
                }

                if (tok_is("ja") != 0) {
                    handled = 1
                    expect_sym(40) take()
                    if (ct() != 1) { compiler_error(18) return 0 }
                    asm_emit_branch(0x87, chash()) expect_sym(41)
                }

                if (tok_is("jl") != 0) {
                    handled = 1
                    expect_sym(40) take()
                    if (ct() != 1) { compiler_error(18) return 0 }
                    asm_emit_branch(0x8C, chash()) expect_sym(41)
                }

                if (tok_is("jge") != 0) {
                    handled = 1
                    expect_sym(40) take()
                    if (ct() != 1) { compiler_error(18) return 0 }
                    asm_emit_branch(0x8D, chash()) expect_sym(41)
                }

                if (tok_is("jle") != 0) {
                    handled = 1
                    expect_sym(40) take()
                    if (ct() != 1) { compiler_error(18) return 0 }
                    asm_emit_branch(0x8E, chash()) expect_sym(41)
                }

                if (tok_is("jg") != 0) {
                    handled = 1
                    expect_sym(40) take()
                    if (ct() != 1) { compiler_error(18) return 0 }
                    asm_emit_branch(0x8F, chash()) expect_sym(41)
                }

                if (tok_is("jmp_far") != 0) {
                    handled = 1
                    expect_sym(40)
                    take()
                    if (ct() != 2) { compiler_error(18) return 0 }
                    I64 selector = cv()
                    expect_sym(44)
                    asm_parse_operand()
                    I64 fk = mem_read64(0x800550)
                    I64 fv = mem_read64(0x800558)
                    if (fk == 1) { compiler_error(18) return 0 }
                    expect_sym(41)
                    asm_emit_far_jump(selector, fk, fv)
                }

                if (tok_is("load8") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    if (mem_read64(0x800550) != 1) { compiler_error(18) return 0 }
                    I64 lr8 = mem_read64(0x800560)
                    expect_sym(44)
                    asm_parse_operand()
                    I64 lak8 = mem_read64(0x800550)
                    I64 lav8 = mem_read64(0x800558)
                    if (lak8 == 1) { compiler_error(18) return 0 }
                    expect_sym(41)
                    asm_emit_abs_memory(1, lr8, lak8, lav8)
                }

                if (tok_is("load16") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    if (mem_read64(0x800550) != 1) { compiler_error(18) return 0 }
                    I64 lr16 = mem_read64(0x800560)
                    expect_sym(44)
                    asm_parse_operand()
                    I64 lak16 = mem_read64(0x800550)
                    I64 lav16 = mem_read64(0x800558)
                    if (lak16 == 1) { compiler_error(18) return 0 }
                    expect_sym(41)
                    asm_emit_abs_memory(2, lr16, lak16, lav16)
                }

                if (tok_is("load32") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    if (mem_read64(0x800550) != 1) { compiler_error(18) return 0 }
                    I64 lr32 = mem_read64(0x800560)
                    expect_sym(44)
                    asm_parse_operand()
                    I64 lak32 = mem_read64(0x800550)
                    I64 lav32 = mem_read64(0x800558)
                    if (lak32 == 1) { compiler_error(18) return 0 }
                    expect_sym(41)
                    asm_emit_abs_memory(3, lr32, lak32, lav32)
                }

                if (tok_is("load64") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    if (mem_read64(0x800550) != 1) { compiler_error(18) return 0 }
                    I64 lr64 = mem_read64(0x800560)
                    expect_sym(44)
                    asm_parse_operand()
                    I64 lak64 = mem_read64(0x800550)
                    I64 lav64 = mem_read64(0x800558)
                    if (lak64 == 1) { compiler_error(18) return 0 }
                    expect_sym(41)
                    asm_emit_abs_memory(4, lr64, lak64, lav64)
                }

                if (tok_is("store8") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    I64 sak8 = mem_read64(0x800550)
                    I64 sav8 = mem_read64(0x800558)
                    if (sak8 == 1) { compiler_error(18) return 0 }
                    expect_sym(44)
                    asm_parse_operand()
                    I64 sik8 = mem_read64(0x800550)
                    I64 siv8 = mem_read64(0x800558)
                    if (sik8 == 1) { siv8 = mem_read64(0x800560) }
                    expect_sym(41)
                    if (sik8 == 1) { asm_emit_store_reg(1, sak8, sav8, siv8) }
                    if (sik8 == 2) { asm_emit_store_imm(1, sak8, sav8, siv8) }
                    if (sik8 == 3) { compiler_error(18) return 0 }
                }

                if (tok_is("store16") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    I64 sak16 = mem_read64(0x800550)
                    I64 sav16 = mem_read64(0x800558)
                    if (sak16 == 1) { compiler_error(18) return 0 }
                    expect_sym(44)
                    asm_parse_operand()
                    I64 sik16 = mem_read64(0x800550)
                    I64 siv16 = mem_read64(0x800558)
                    if (sik16 == 1) { siv16 = mem_read64(0x800560) }
                    expect_sym(41)
                    if (sik16 == 1) { asm_emit_store_reg(2, sak16, sav16, siv16) }
                    if (sik16 == 2) { asm_emit_store_imm(2, sak16, sav16, siv16) }
                    if (sik16 == 3) { compiler_error(18) return 0 }
                }

                if (tok_is("store32") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    I64 sak32 = mem_read64(0x800550)
                    I64 sav32 = mem_read64(0x800558)
                    if (sak32 == 1) { compiler_error(18) return 0 }
                    expect_sym(44)
                    asm_parse_operand()
                    I64 sik32 = mem_read64(0x800550)
                    I64 siv32 = mem_read64(0x800558)
                    if (sik32 == 1) { siv32 = mem_read64(0x800560) }
                    expect_sym(41)
                    if (sik32 == 1) { asm_emit_store_reg(3, sak32, sav32, siv32) }
                    if (sik32 == 2) { asm_emit_store_imm(3, sak32, sav32, siv32) }
                    if (sik32 == 3) { compiler_error(18) return 0 }
                }

                if (tok_is("store64") != 0) {
                    handled = 1
                    if (mem_read64(0x800508) != 64) { compiler_error(18) return 0 }
                    expect_sym(40)
                    asm_parse_operand()
                    I64 sak64 = mem_read64(0x800550)
                    I64 sav64 = mem_read64(0x800558)
                    if (sak64 == 1) { compiler_error(18) return 0 }
                    expect_sym(44)
                    asm_parse_operand()
                    if (mem_read64(0x800550) != 1) { compiler_error(18) return 0 }
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
                    if (gk == 1) { compiler_error(18) return 0 }
                    expect_sym(41)
                    asm_emit_lgdt_lidt(0, gk, gv)
                }

                if (tok_is("lidt") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    I64 ik = mem_read64(0x800550)
                    I64 iv = mem_read64(0x800558)
                    if (ik == 1) { compiler_error(18) return 0 }
                    expect_sym(41)
                    asm_emit_lgdt_lidt(1, ik, iv)
                }

                if (tok_is("in") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    if (mem_read64(0x800550) != 1) { compiler_error(18) return 0 }
                    I64 inreg = mem_read64(0x800560)
                    expect_sym(44)
                    asm_parse_operand()
                    I64 inpk = mem_read64(0x800550)
                    I64 inpv = mem_read64(0x800558)
                    if (inpk == 1) { inpv = mem_read64(0x800560) }
                    expect_sym(41)
                    asm_emit_in(inreg, inpk, inpv)
                }

                if (tok_is("out") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    I64 outpk = mem_read64(0x800550)
                    I64 outpv = mem_read64(0x800558)
                    if (outpk == 1) { outpv = mem_read64(0x800560) }
                    expect_sym(44)
                    asm_parse_operand()
                    if (mem_read64(0x800550) != 1) { compiler_error(18) return 0 }
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
                    if (dbk == 1) { compiler_error(18) return 0 }
                    if (dbk == 3) { compiler_error(18) return 0 }
                    if (dbv > 255) { compiler_error(18) return 0 }
                    asm_put8(dbv)
                    expect_sym(41)
                }

                if (tok_is("dw") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    I64 dwk = mem_read64(0x800550)
                    I64 dwv = mem_read64(0x800558)
                    if (dwk == 1) { compiler_error(18) return 0 }
                    I64 dwp = mem_read64(0x800090)
                    asm_put16(0)
                    if (dwk == 2) { patch16_at(dwp, dwv) }
                    if (dwk == 3) { asm_add_fixup(dwv, dwp, 0 - 3) }
                    expect_sym(41)
                }

                if (tok_is("dd") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    I64 ddk = mem_read64(0x800550)
                    I64 ddv = mem_read64(0x800558)
                    if (ddk == 1) { compiler_error(18) return 0 }
                    I64 ddp = mem_read64(0x800090)
                    asm_put32(0)
                    if (ddk == 2) { patch32_at(ddp, ddv) }
                    if (ddk == 3) { asm_add_fixup(ddv, ddp, 0 - 4) }
                    expect_sym(41)
                }

                if (tok_is("dq") != 0) {
                    handled = 1
                    expect_sym(40)
                    asm_parse_operand()
                    I64 dqk = mem_read64(0x800550)
                    I64 dqv = mem_read64(0x800558)
                    if (dqk == 1) { compiler_error(18) return 0 }
                    I64 dqp = mem_read64(0x800090)
                    asm_put64(0)
                    if (dqk == 2) { patch64_at(dqp, dqv) }
                    if (dqk == 3) { asm_add_fixup(dqv, dqp, 0 - 5) }
                    expect_sym(41)
                }

                if (tok_is("zero") != 0) {
                    handled = 1
                    expect_sym(40)
                    take()
                    if (ct() != 2) { compiler_error(18) return 0 }
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
                    if (ct() != 2) { compiler_error(18) return 0 }
                    I64 alignment = cv()
                    if (alignment == 0) { compiler_error(18) return 0 }

                    while ((mem_read64(0x800090) % alignment) != 0) {
                        asm_put8(0)
                    }

                    expect_sym(41)
                }

                if (tok_is("pad_to") != 0) {
                    handled = 1
                    expect_sym(40)
                    take()
                    if (ct() != 2) { compiler_error(18) return 0 }
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

                if (tok_is("clts") != 0) { handled = 1 asm_put2(0x0F, 0x06) }
                if (tok_is("invd") != 0) { handled = 1 asm_put2(0x0F, 0x08) }
                if (tok_is("wbinvd") != 0) { handled = 1 asm_put2(0x0F, 0x09) }
                if (tok_is("pause") != 0) { handled = 1 asm_put2(0xF3, 0x90) }
                if (tok_is("int3") != 0) { handled = 1 asm_put8(0xCC) }
                if (tok_is("leave") != 0) { handled = 1 asm_put8(0xC9) }
                if (tok_is("lahf") != 0) { handled = 1 asm_put8(0x9F) }
                if (tok_is("sahf") != 0) { handled = 1 asm_put8(0x9E) }
                if (tok_is("rdtscp") != 0) { handled = 1 asm_put3(0x0F, 0x01, 0xF9) }
                if (tok_is("xgetbv") != 0) { handled = 1 asm_put3(0x0F, 0x01, 0xD0) }
                if (tok_is("xsetbv") != 0) { handled = 1 asm_put3(0x0F, 0x01, 0xD1) }
                if (tok_is("swapgs") != 0) {
                    handled = 1
                    if (mem_read64(0x800508) != 64) { compiler_error(18) return 0 }
                    asm_put3(0x0F, 0x01, 0xF8)
                }

                if (tok_is("cli") != 0) { handled = 1 asm_put8(0xFA) }
                if (tok_is("sti") != 0) { handled = 1 asm_put8(0xFB) }
                if (tok_is("cld") != 0) { handled = 1 asm_put8(0xFC) }
                if (tok_is("std") != 0) { handled = 1 asm_put8(0xFD) }
                if (tok_is("nop") != 0) { handled = 1 asm_put8(0x90) }
                if (tok_is("hlt") != 0) { handled = 1 asm_put8(0xF4) }
                if (tok_is("ret") != 0) { handled = 1 asm_put8(0xC3) }
                if (tok_is("cpuid") != 0) { handled = 1 asm_put2(0x0F, 0xA2) }
                if (tok_is("rdmsr") != 0) { handled = 1 asm_put2(0x0F, 0x32) }
                if (tok_is("wrmsr") != 0) { handled = 1 asm_put2(0x0F, 0x30) }
                if (tok_is("rdtsc") != 0) { handled = 1 asm_put2(0x0F, 0x31) }
                if (tok_is("syscall") != 0) {
                    handled = 1
                    if (mem_read64(0x800508) != 64) { compiler_error(18) return 0 }
                    asm_put2(0x0F, 0x05)
                }
                if (tok_is("pusha") != 0) {
                    handled = 1
                    if (mem_read64(0x800508) == 64) { compiler_error(18) return 0 }
                    asm_put8(0x60)
                }
                if (tok_is("popa") != 0) {
                    handled = 1
                    if (mem_read64(0x800508) == 64) { compiler_error(18) return 0 }
                    asm_put8(0x61)
                }
                if (tok_is("pushf") != 0) { handled = 1 asm_put8(0x9C) }
                if (tok_is("popf") != 0) { handled = 1 asm_put8(0x9D) }
                if (tok_is("lodsb") != 0) { handled = 1 asm_put8(0xAC) }
                if (tok_is("stosb") != 0) { handled = 1 asm_put8(0xAA) }
                if (tok_is("movsb") != 0) { handled = 1 asm_put8(0xA4) }
                if (tok_is("rep_movsb") != 0) { handled = 1 asm_put2(0xF3, 0xA4) }
                if (tok_is("rep_stosb") != 0) { handled = 1 asm_put2(0xF3, 0xAA) }

                if (tok_is("iret") != 0) {
                    handled = 1
                    if (mem_read64(0x800508) != 16) { compiler_error(18) return 0 }
                    asm_put8(0xCF)
                }

                if (tok_is("iretd") != 0) {
                    handled = 1
                    I64 ibits = mem_read64(0x800508)
                    if (ibits == 64) { compiler_error(18) return 0 }
                    if (ibits == 16) { asm_put8(0x66) }
                    asm_put8(0xCF)
                }

                if (tok_is("iretq") != 0) {
                    handled = 1
                    if (mem_read64(0x800508) != 64) { compiler_error(18) return 0 }
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
            if (tok_is("if") != 0) { parse_if_statement() return 0 }
            if (tok_is("while") != 0) { parse_while_statement() return 0 }
            if (tok_is("return") != 0) { parse_return_statement() return 0 }
            if (tok_is("pin") != 0) { parse_pin_statement() return 0 }

            I64 declared_type = type_id(cp())
            if (declared_type != 0) {
                take()
                if (ct() != 1) { fail() return 0 }

                I64 hash = chash()
                register_var(hash, declared_type)
                parse_assignment_hash(hash)
                return 0
            }

            I64 hash2 = chash()
            I64 name = cp()
            I64 builtin = builtin_id(name)

            if (look_sym(40) != 0) {
                if (builtin != 0) { parse_builtin_call(builtin) return 0 }
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
                if (peek() == 0) { fail() return 0 }
                if (failed() != 0) { return 0 }
                parse_statement()
                if (failed() != 0) { return 0 }
            }
        }

        return 0
    }

    fn parse_function() {
        if (use_custom_feature() == 0) { return 0 }

        take()
        if (ct() != 1) { fail() return 0 }

        I64 function_hash = chash()
        I64 is_main = tok_is("main")
        reset_vars()
        mem_write64(0x800058, is_main)

        expect_sym(40)

        I64 params = 0
        I64 parsing = 1
        if (look_sym(41) != 0) { parsing = 0 }

        while (parsing != 0) {
            take()
            if (ct() != 1) { fail() return 0 }

            I64 param_type = type_id(cp())
            if (param_type == 0) { fail() return 0 }

            take()
            if (ct() != 1) { fail() return 0 }

            I64 index = register_var(chash(), param_type)
            mem_write64(0x800400 + params * 16, index)
            mem_write64(0x800408 + params * 16, param_type)

            params = params + 1
            if (params > 6) { fail() return 0 }

            if (look_sym(44) != 0) { take() }
            if (look_sym(41) != 0) { parsing = 0 }
        }

        expect_sym(41)
        expect_sym(123)

        I64 position = tell()
        register_function(function_hash, position, params)
        if (failed() != 0) { return 0 }

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
        if (failed() != 0) { return 0 }

        if (is_main != 0) {
            if (out_raw() != 0) { emit_raw_halt() }
            else { emit_main_exit0() }
        } else {
            emit_imm(0)
            emit_epilog()
        }

        mem_write64(0x800058, 0)
        return 0
    }


    fn parse_program() {
        take()

        if (tok_is("head") == 0) { fail() return 0 }

        expect_sym(40)

        I64 feature_count = 0
        I64 features_done = 0

        while (features_done == 0) {
            take()

            if (ct() == 4) {
                if (cv() == 41) { features_done = 1 }
            }

            if (features_done == 0) {
                if (ct() != 1) { fail() return 0 }

                I64 known = 0

                if (tok_is("custom") != 0) {
                    if (mem_read64(0x800098) != 0) { fail() return 0 }
                    mem_write64(0x800098, 1)
                    feature_count = feature_count + 1
                    known = 1
                }

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

                    if (bit == 0) {
                        compiler_error(17)
                        return 0
                    }

                    I64 oldmask = mem_read64(0x8000A0)

                    if ((oldmask & bit) != 0) {
                        fail()
                        return 0
                    }

                    mem_write64(0x8000A0, oldmask | bit)

                    feature_count = feature_count + 1
                    known = 1
                }

                if (known == 0) { fail() return 0 }
            }
        }

        if (feature_count == 0) { fail() return 0 }

        I64 asm_mask = mem_read64(0x8000A0)

        if ((asm_mask & 3) != 0) {
            if (mem_read64(0x800030) == 0) {
                compiler_error(15)
                return 0
            }

            if (mem_read64(0x800098) != 0) {
                compiler_error(16)
                return 0
            }
        }

        if (asm_mask == 1) { mem_write64(0x800508, 16) }
        if (asm_mask == 2) { mem_write64(0x800508, 32) }
        if (asm_mask == 4) { mem_write64(0x800508, 64) }
        if (asm_mask != 1) {
            if (asm_mask != 2) {
                if (asm_mask != 4) {
                    mem_write64(0x800508, 0)
                }
            }
        }

        expect_sym(123)

        I64 done = 0

        while (done == 0) {
            take()

            I64 token_kind = ct()
            I64 value = cv()

            if (token_kind == 0) { fail() return 0 }

            if (token_kind == 4) {
                if (value == 125) { done = 1 }
            }

            if (done == 0) {
                if (mem_read64(0x800088) != 0) {
                    fail()
                    return 0
                }

                I64 handled = 0

                if (token_kind == 1) {
                    if (tok_is("fn") != 0) {
                        handled = 1
                        parse_function()
                        if (failed() != 0) { return 0 }
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

                if (handled == 0) {
                    fail()
                    return 0
                }
            }
        }

        if (failed() != 0) { return 0 }

        resolve_calls()

        if (failed() != 0) { return 0 }

        warn_unused_features()

        return 0
    }

    fn emit_elf_header() {
        out8(0x7F) out8(0x45) out8(0x4C) out8(0x46) out8(2) out8(1) out8(1)
        I64 i = 7
        while (i < 16) { out8(0) i = i + 1 }
        out8(2) out8(0) out8(0x3E) out8(0)
        out32(1)
        out64(0)
        out64(64)
        out64(0)
        out32(0)
        out8(64) out8(0) out8(56) out8(0) out8(1) out8(0) out8(0) out8(0) out8(0) out8(0) out8(0) out8(0)

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
            if (custom_used != 0) { fail() return 0 }
            if (asm_used == 0) { fail() return 0 }
            entry_position = mem_read64(0x8000B8)
        }

        if (out_raw() != 0) {
            if (main_position == 0) {
                I64 raw_fd = mem_read64(0x800008)
                I64 raw_end = mem_read64(0x800090)

                file_seek(raw_fd, 0)
                file_write8(raw_fd, 0x90)
                file_write8(raw_fd, 0x90)
                file_write8(raw_fd, 0x90)
                file_write8(raw_fd, 0x90)
                file_write8(raw_fd, 0x90)

                file_seek(raw_fd, raw_end)
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

    fn ends_bin(I64 path) {
        I64 length = strlen(path)
        if (length < 4) { return 0 }
        if (mem_read8(path + length - 4) != 46) { return 0 }
        if (mem_read8(path + length - 3) != 98) { return 0 }
        if (mem_read8(path + length - 2) != 105) { return 0 }
        if (mem_read8(path + length - 1) != 110) { return 0 }
        return 1
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
        return 0
    }

    fn main() {
        I64 count = argc()

        if (count < 4) {
            pin("usage: mcc input.mc -o output\n")
            return 1
        }

        I64 input_path = argv(1)
        I64 option = argv(2)
        I64 output_path = argv(3)

        if (strcmp(option, "-o") != 0) {
            pin("usage: mcc input.mc -o output\n")
            return 1
        }

        if (strcmp(input_path, output_path) == 0) {
            pin("input and output paths must differ\n")
            return 1
        }

        I64 input = open(input_path, 0)
        if (input < 0) {
            pin("could not open input\n")
            return 1
        }

        I64 output = open(output_path, 577)
        if (output < 0) {
            pin("could not create output\n")
            close(input)
            return 1
        }

        initialize_state(input, output)
        mem_write64(0x8000E0, input_path)

        I64 raw = ends_bin(output_path)
        mem_write64(0x800030, raw)

        I64 size = file_size(input)
        mem_write64(0x800018, size)
        file_seek(input, 0)

        if (raw == 0) {
            emit_elf_header()
        }

        if (raw != 0) {
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

        close(input)
        close(output)

        print_diagnostic_summary()

        if (failed() != 0) {
            I64 cleanup = open(output_path, 577)
            if (cleanup >= 0) { close(cleanup) }
            return 1
        }

        print_output_info(output_path, output_size)
        return 0
    }
}
