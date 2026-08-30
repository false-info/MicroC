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
        out8(value)
        out8(value >> 8)
        out8(value >> 16)
        out8(value >> 24)
        return value
    }
	fn print_disgnostic_summary() {
		I64 errors = mem_read64(0x8000E0)
		I64 warnings = mem_read64(0x8000E8)
		pin("\nmcc: errors: %I64   warnings: %I64\n", errors, warnings)
		return 0
	}

    fn out64(I64 value) {
        out32(value)
        out32(value >> 32)
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
            pin("MicroC compiler error: custom syntax requires custom in head()\n")
            mem_write64(0x800078, 1)
            return 0
        }
        mem_write64(0x8000A8, 1)
        return 1
    }

    fn use_asm_feature() {
        if (mem_read64(0x8000A0) == 0) {
            pin("MicroC compiler error: inline x86-64 assembly requires asm-x86-64 in head()\n")
            mem_write64(0x800078, 1)
            return 0
        }
        mem_write64(0x8000B0, 1)
        return 1
    }

    fn warn_unused_features() {
        if (mem_read64(0x800098) != 0) {
            if (mem_read64(0x8000A8) == 0) {
                pin("warning: custom enabled in head() but never used\n")
            }
        }
        if (mem_read64(0x8000A0) != 0) {
            if (mem_read64(0x8000B0) == 0) {
                pin("warning: asm-x86-64 enabled in head() but never used\n")
            }
        }
        return 0
    }

    fn fail() {
        mem_write64(0x800078, 1)
        pin("MicroC compiler error\n")
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
        if (c == 45) { return 1 }
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

        if (c == 0) {
            set_token(slot, 0)
            return 0
        }

        if (c == 34) {
            set_token(slot, 3)
            read_char()
            c = current_char()
            I64 length = 0
            while (c != 0) {
                if (c == 34) {
                    c = 0
                }
                if (c != 0) {
                    if (c == 92) {
                        read_char()
                        c = current_char()
                        if (c == 110) { c = 10 }
                        if (c == 114) { c = 13 }
                        if (c == 116) { c = 9 }
                    }
                    if (length < 255) {
                        mem_write8(text + length, c)
                        length = length + 1
                    }
                    read_char()
                    c = current_char()
                }
            }
            mem_write8(text + length, 0)
            mem_write64(base + 16, length)
            if (current_char() == 34) { read_char() }
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
                if (length2 < 255) {
                    mem_write8(text + length2, c)
                    length2 = length2 + 1
                }
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
        return 0
    }

    fn emit_prolog() {
        out8(0x55)
        out8(0x48) out8(0x89) out8(0xE5)
        out8(0x48) out8(0x81) out8(0xEC) out32(0x4000)
        return 0
    }

    fn emit_epilog() {
        out8(0xC9)
        out8(0xC3)
        return 0
    }

    fn emit_main_exit0() {
        out8(0x48) out8(0xC7) out8(0xC0) out32(60)
        out8(0x48) out8(0x31) out8(0xFF)
        out8(0x0F) out8(0x05)
        return 0
    }

    fn emit_main_exit_rax() {
        out8(0x48) out8(0x89) out8(0xC7)
        out8(0x48) out8(0xC7) out8(0xC0) out32(60)
        out8(0x0F) out8(0x05)
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
            out8(0x48) out8(0x85) out8(0xC0)
            out8(0x0F) out8(0x95) out8(0xC0)
            out8(0x48) out8(0x0F) out8(0xB6) out8(0xC0)
            return type
        }
        return type
    }

    fn emit_u64_to_f64() {
        out8(0x48) out8(0x85) out8(0xC0)
        out8(0x0F) out8(0x89)
        I64 simple = tell()
        out32(0)

        out8(0x48) out8(0x89) out8(0xC1)
        out8(0x48) out8(0x83) out8(0xE0) out8(1)
        out8(0x48) out8(0xD1) out8(0xE9)
        out8(0x48) out8(0x09) out8(0xC1)
        out8(0xF2) out8(0x48) out8(0x0F) out8(0x2A) out8(0xC1)
        out8(0xF2) out8(0x0F) out8(0x58) out8(0xC0)
        out8(0x66) out8(0x48) out8(0x0F) out8(0x7E) out8(0xC0)
        I64 done = emit_jmp()

        patch_rel(simple, tell())
        out8(0xF2) out8(0x48) out8(0x0F) out8(0x2A) out8(0xC0)
        out8(0x66) out8(0x48) out8(0x0F) out8(0x7E) out8(0xC0)

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
            out8(0xF2) out8(0x48) out8(0x0F) out8(0x2A) out8(0xC0)
            out8(0x66) out8(0x48) out8(0x0F) out8(0x7E) out8(0xC0)
            return target
        }

        if (source == 9) {
            if (target == 10) {
                out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xC0)
                out8(0x66) out8(0x0F) out8(0xEF) out8(0xC9)
                out8(0x66) out8(0x0F) out8(0x2E) out8(0xC1)
                out8(0x0F) out8(0x95) out8(0xC0)
                out8(0x48) out8(0x0F) out8(0xB6) out8(0xC0)
                return target
            }
            out8(0x66) out8(0x48) out8(0x0F) out8(0x6E) out8(0xC0)
            out8(0xF2) out8(0x48) out8(0x0F) out8(0x2C) out8(0xC0)
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
        out8(0x48) out8(0x85) out8(0xC0)
        out8(0x0F) out8(0x84)
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
            out8(0xF2) out8(0x48) out8(0x0F) out8(0x2A) out8(0xC8)
            out8(0xF2) out8(0x0F) out8(0x5E) out8(0xC1)
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
            out8(0xF2) out8(0x0F) out8(0x58) out8(0xC1)
            out8(0x66) out8(0x48) out8(0x0F) out8(0x7E) out8(0xC0)
            return 9
        }
        if (op == 45) {
            out8(0xF2) out8(0x0F) out8(0x5C) out8(0xC1)
            out8(0x66) out8(0x48) out8(0x0F) out8(0x7E) out8(0xC0)
            return 9
        }
        if (op == 42) {
            out8(0xF2) out8(0x0F) out8(0x59) out8(0xC1)
            out8(0x66) out8(0x48) out8(0x0F) out8(0x7E) out8(0xC0)
            return 9
        }
        if (op == 47) {
            out8(0xF2) out8(0x0F) out8(0x5E) out8(0xC1)
            out8(0x66) out8(0x48) out8(0x0F) out8(0x7E) out8(0xC0)
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

            out8(0x48) out8(0x89) out8(0xCA)
            out8(0x48) out8(0x89) out8(0xC1)
            out8(0x48) out8(0x89) out8(0xD0)
            out8(0x48) out8(0xD3) out8(0xE0)
            emit_normalize_type(result_shift)
            return result_shift
        }

        if (op == 1006) {
            I64 result_shift2 = left_type
            if (result_shift2 == 10) { result_shift2 = 4 }

            out8(0x48) out8(0x89) out8(0xCA)
            out8(0x48) out8(0x89) out8(0xC1)
            out8(0x48) out8(0x89) out8(0xD0)

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
            out8(0x48) out8(0x01) out8(0xC1)
            out8(0x48) out8(0x89) out8(0xC8)
            emit_normalize_type(result_type)
            return result_type
        }

        if (op == 45) {
            out8(0x48) out8(0x29) out8(0xC1)
            out8(0x48) out8(0x89) out8(0xC8)
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
                out8(0x48) out8(0x31) out8(0xD2)
                out8(0x48) out8(0xF7) out8(0xF1)
            }
            if (type_unsigned(result_type) == 0) {
                out8(0x48) out8(0x99)
                out8(0x48) out8(0xF7) out8(0xF9)
            }

            emit_normalize_type(result_type)
            return result_type
        }

        if (op == 37) {
            out8(0x48) out8(0x87) out8(0xC8)

            if (type_unsigned(result_type) != 0) {
                out8(0x48) out8(0x31) out8(0xD2)
                out8(0x48) out8(0xF7) out8(0xF1)
            }
            if (type_unsigned(result_type) == 0) {
                out8(0x48) out8(0x99)
                out8(0x48) out8(0xF7) out8(0xF9)
            }

            out8(0x48) out8(0x89) out8(0xD0)
            emit_normalize_type(result_type)
            return result_type
        }

        if (op == 38) {
            out8(0x48) out8(0x21) out8(0xC1)
            out8(0x48) out8(0x89) out8(0xC8)
            emit_normalize_type(result_type)
            return result_type
        }

        if (op == 124) {
            out8(0x48) out8(0x09) out8(0xC1)
            out8(0x48) out8(0x89) out8(0xC8)
            emit_normalize_type(result_type)
            return result_type
        }

        if (op == 94) {
            out8(0x48) out8(0x31) out8(0xC1)
            out8(0x48) out8(0x89) out8(0xC8)
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
        return 0x820000 + (index - 1) * 16
    }

    fn var_type(I64 index) {
        if (index <= 0) { return 4 }
        return mem_read64(var_entry(index) + 8)
    }

    fn find_var(I64 hash) {
        I64 count = mem_read64(0x800048)
        I64 i = 0
        while (i < count) {
            I64 entry = 0x820000 + i * 16
            if (mem_read64(entry) == hash) { return i + 1 }
            i = i + 1
        }
        return 0
    }

    fn register_var(I64 hash, I64 type) {
        I64 found = find_var(hash)
        if (found != 0) { return found }

        I64 count = mem_read64(0x800048)
        if (count >= 1024) { fail() return 0 }

        I64 entry = 0x820000 + count * 16
        mem_write64(entry, hash)
        mem_write64(entry + 8, type)
        mem_write64(0x800048, count + 1)
        return count + 1
    }

    fn register_function(I64 hash, I64 position) {
        I64 count = mem_read64(0x800038)
        if (count >= 256) { fail() return 0 }
        I64 entry = 0x810000 + count * 16
        mem_write64(entry, hash)
        mem_write64(entry + 8, position)
        mem_write64(0x800038, count + 1)
        return position
    }

    fn find_function(I64 hash) {
        I64 count = mem_read64(0x800038)
        I64 i = 0
        while (i < count) {
            I64 entry = 0x810000 + i * 16
            if (mem_read64(entry) == hash) { return mem_read64(entry + 8) }
            i = i + 1
        }
        return 0
    }

    fn register_call(I64 hash, I64 patch) {
        I64 count = mem_read64(0x800040)
        if (count >= 2048) { fail() return 0 }
        I64 entry = 0x812000 + count * 16
        mem_write64(entry, hash)
        mem_write64(entry + 8, patch)
        mem_write64(0x800040, count + 1)
        return patch
    }

    fn resolve_calls() {
        I64 count = mem_read64(0x800040)
        I64 i = 0
        while (i < count) {
            I64 entry = 0x812000 + i * 16
            I64 hash = mem_read64(entry)
            I64 patch = mem_read64(entry + 8)
            I64 target = find_function(hash)
            if (target == 0) { fail() return 0 }
            patch_rel(patch, target)
            i = i + 1
        }
        return 0
    }

    fn copy_string_pool(I64 source, I64 length) {
        I64 dest = mem_read64(0x800068)
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
                out8(mem_read8(source + j))
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
        out8(0x48) out8(0x89) out8(0xC7)
        out8(0x48) out8(0xC7) out8(0xC0) out32(3)
        out8(0x0F) out8(0x05)
        return 0
    }

    fn emit_runtime_read8() {
        out8(0x48) out8(0x89) out8(0xC7)
        out8(0x48) out8(0x83) out8(0xEC) out8(8)
        out8(0xC6) out8(0x04) out8(0x24) out8(0)
        out8(0x48) out8(0x89) out8(0xE6)
        out8(0x48) out8(0xC7) out8(0xC2) out32(1)
        out8(0x48) out8(0x31) out8(0xC0)
        out8(0x0F) out8(0x05)
        out8(0x48) out8(0x0F) out8(0xB6) out8(0x04) out8(0x24)
        out8(0x48) out8(0x83) out8(0xC4) out8(8)
        return 0
    }

    fn emit_runtime_write8() {
        out8(0x48) out8(0x83) out8(0xEC) out8(8)
        out8(0x88) out8(0x04) out8(0x24)
        out8(0x48) out8(0x89) out8(0xE6)
        out8(0x48) out8(0xC7) out8(0xC2) out32(1)
        out8(0x48) out8(0xC7) out8(0xC0) out32(1)
        out8(0x0F) out8(0x05)
        out8(0x48) out8(0x83) out8(0xC4) out8(8)
        return 0
    }

    fn emit_runtime_size() {
        out8(0x48) out8(0x89) out8(0xC7)
        out8(0x48) out8(0x31) out8(0xF6)
        out8(0x48) out8(0xC7) out8(0xC2) out32(2)
        out8(0x48) out8(0xC7) out8(0xC0) out32(8)
        out8(0x0F) out8(0x05)
        return 0
    }

    fn emit_runtime_seek() {
        out8(0x48) out8(0x89) out8(0xC6)
        out8(0x48) out8(0x31) out8(0xD2)
        out8(0x48) out8(0xC7) out8(0xC0) out32(8)
        out8(0x0F) out8(0x05)
        return 0
    }

    fn emit_runtime_strlen() {
        out8(0x48) out8(0x89) out8(0xC7)
        out8(0x48) out8(0x31) out8(0xC0)
        I64 loop = tell()
        out8(0x80) out8(0x3C) out8(0x07) out8(0)
        out8(0x0F) out8(0x84)
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
        out8(0x0F) out8(0xB6) out8(0x07)
        out8(0x0F) out8(0xB6) out8(0x16)
        out8(0x38) out8(0xD0)
        out8(0x0F) out8(0x85)
        I64 different = tell()
        out32(0)
        out8(0x84) out8(0xC0)
        out8(0x0F) out8(0x84)
        I64 equal = tell()
        out32(0)
        out8(0x48) out8(0xFF) out8(0xC7)
        out8(0x48) out8(0xFF) out8(0xC6)
        I64 back = emit_jmp()
        patch_rel(back, loop)

        I64 diff_target = tell()
        patch_rel(different, diff_target)
        out8(0x48) out8(0x0F) out8(0xB6) out8(0xC0)
        out8(0x48) out8(0x0F) out8(0xB6) out8(0xD2)
        out8(0x48) out8(0x29) out8(0xD0)
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
        out8(0x48) out8(0x83) out8(0xEC) out8(8)
        out8(0x88) out8(0x04) out8(0x24)
        out8(0x48) out8(0xC7) out8(0xC7) out32(1)
        out8(0x48) out8(0x89) out8(0xE6)
        out8(0x48) out8(0xC7) out8(0xC2) out32(1)
        out8(0x48) out8(0xC7) out8(0xC0) out32(1)
        out8(0x0F) out8(0x05)
        out8(0x48) out8(0x83) out8(0xC4) out8(8)
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
        register_call(hash, patch)
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
        if (index == 0) { index = register_var(hash, 4) }

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
            if (mem_read64(0x800058) != 0) { emit_main_exit0() return 0 }
            emit_epilog()
            return 0
        }

        parse_expression(0)
        if (mem_read64(0x800058) != 0) { emit_main_exit_rax() return 0 }
        emit_epilog()
        return 0
    }

    fn emit_pin_char_code() {
        out8(0x48) out8(0x83) out8(0xEC) out8(8)
        out8(0x88) out8(0x04) out8(0x24)
        out8(0x48) out8(0xC7) out8(0xC7) out32(1)
        out8(0x48) out8(0x89) out8(0xE6)
        out8(0x48) out8(0xC7) out8(0xC2) out32(1)
        out8(0x48) out8(0xC7) out8(0xC0) out32(1)
        out8(0x0F) out8(0x05)
        out8(0x48) out8(0x83) out8(0xC4) out8(8)
        return 0
    }

    fn emit_pin_text_code(I64 text, I64 length) {
        if (length == 0) { return 0 }

        emit_string_ptr(text, length)
        out8(0x48) out8(0x89) out8(0xC6)
        out8(0x48) out8(0xC7) out8(0xC7) out32(1)
        out8(0x48) out8(0xC7) out8(0xC2) out32(length)
        out8(0x48) out8(0xC7) out8(0xC0) out32(1)
        out8(0x0F) out8(0x05)
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
        out8(0x48) out8(0xC7) out8(0xC0) out32(1)
        out8(0x0F) out8(0x05)
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
        out8(0x48) out8(0xC7) out8(0xC0) out32(1)
        out8(0x0F) out8(0x05)
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
        out8(0x48) out8(0xC7) out8(0xC0) out32(1)
        out8(0x0F) out8(0x05)
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
        out8(0x48) out8(0xC7) out8(0xC0) out32(1)
        out8(0x0F) out8(0x05)
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
        out8(0x48) out8(0xC7) out8(0xC0) out32(1)
        out8(0x0F) out8(0x05)
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
        expect_sym(40)
        take()

        if (ct() != 3) {
            fail()
            return 0
        }

        I64 original = cp()
        I64 length = clen()
        I64 text = copy_string_pool(original, length)

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
                if (tok_is("cli") != 0) { out8(0xFA) }
                if (tok_is("sti") != 0) { out8(0xFB) }
                if (tok_is("nop") != 0) { out8(0x90) }
                if (tok_is("hlt") != 0) { out8(0xF4) }
                if (tok_is("ret") != 0) { out8(0xC3) }
                if (tok_is("syscall") != 0) { out8(0x0F) out8(0x05) }

                if (tok_is("pad_boot") != 0) {
                    I64 position = tell()
                    while (position < 510) {
                        out8(0)
                        position = position + 1
                    }
                }

                if (tok_is("sign_boot") != 0) {
                    if (tell() != 510) { fail() }
                    out8(0x55) out8(0xAA)
                    mem_write64(0x800088, 1)
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
                parse_statement()
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
        register_function(function_hash, position)

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

        if (is_main != 0) { emit_main_exit0() }
        if (is_main == 0) { emit_epilog() }

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

                if (tok_is("asm-x86-64") != 0) {
                    if (mem_read64(0x8000A0) != 0) { fail() return 0 }
                    mem_write64(0x8000A0, 1)
                    feature_count = feature_count + 1
                    known = 1
                }

                if (known == 0) { fail() return 0 }
            }
        }

        if (feature_count == 0) { fail() return 0 }
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
                I64 handled = 0

                if (token_kind == 1) {
                    if (tok_is("fn") != 0) {
                        handled = 1
                        parse_function()
                    }
                }

                if (token_kind == 4) {
                    if (value == 40) {
                        handled = 1
                        if (mem_read64(0x8000B8) == 0) {
                            mem_write64(0x8000B8, tell())
                        }
                        parse_inline_asm()
                    }
                }

                if (handled == 0) { fail() return 0 }
            }
        }

        resolve_calls()
        warn_unused_features()
        return 0
    }

    fn emit_elf_header() {
        out8(0x7F) out8(0x45) out8(0x4C) out8(0x46)
        out8(2) out8(1) out8(1)
        I64 i = 7
        while (i < 16) { out8(0) i = i + 1 }
        out8(2) out8(0)
        out8(0x3E) out8(0)
        out32(1)
        out64(0)
        out64(64)
        out64(0)
        out32(0)
        out8(64) out8(0)
        out8(56) out8(0)
        out8(1) out8(0)
        out8(0) out8(0)
        out8(0) out8(0)
        out8(0) out8(0)

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
        return 0
    }

    fn main() {
        I64 count = argc()

        if (count < 4) {
            pin("usage: compiler input.mc -o output\n")
            return 1
        }

        I64 input_path = argv(1)
        I64 option = argv(2)
        I64 output_path = argv(3)

        if (strcmp(option, "-o") != 0) {
            pin("usage: compiler input.mc -o output\n")
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
        finish_output()

        close(input)
        close(output)
		print_disgnostic_summary()
        if (failed() != 0) { return 1 }
        return 0
    }
}
