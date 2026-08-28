head(asm-x86-64 custom) {

	i64 input = open("compiler.mc")
	i64 output = open("microc2")

	i64 current = 0
	i64 next = 0
	i64 line = 1

	i64 code = 0
	i64 token = 0
	i64 value = 0
	i64 address = 0
	i64 count = 0
	i64 i = 0

	fn read8() {
		current = file_read8(input)
	}

	fn emit8(i64 value) {
		file_write8(output, value)
	}

	fn emit16(i64 value) {
		file_write8(output, value)
		file_write8(output, value >> 8)
	}

	fn emit32(i64 value) {
		file_write8(output, value)
		file_write8(output, value >> 8)
		file_write8(output, value >> 16)
		file_write8(output, value >> 24)
	}

	fn emit64(i64 value) {
		emit32(value)
		emit32(value >> 32)
	}

	fn skip_space() {
		while (current == 32) {
			read8()
		}
		while (current == 9) {
			read8()
		}

		while (current == 10) {
			line = line + 1
			read8()
		}
	}

	fn is_digit(i64 c) {
		if (c < 48) {
			return 0
		}
		if (c > 57) {
			return 0
		}

		return 1
	}

	fn is_alpha(i64 c) {
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

	fn is_alnum(i64 c) {
		if (is_alpha(c) == 1) {
			return 1
		}
		if (is_digit(c) == 1) {
			return 1
		}

		return 0
	}

	fn read_identifier() {
		value = 0
		while (is_alnum(current) == 1) {
			value = value + current
			read8()
		}
	}

	fn read_number() {
		value = 0
		while (is_digit(current) == 1) {
			value = value * 10
			value = value + current
			read8()
		}
	}

	fn emit_exit() {
		emit8(0x48)
		emit8(0xC7)
		emit8(0xC0)
		emit32(60)
		emit8(0x48)
		emit8(0x31)
		emit8(0xFF)

		emit8(0x0F)
		emit8(0x05)
	}

	fn emit_prolog() {
		emit8(0x55)
		emit8(0x48)
		emit8(0x89)
		emit8(0xE5)

		emit8(0x48)
		emit8(0x81)
		emit8(0xEC)

		emit32(0x4000)
	}

	fn emit_ret() {
		emit8(0xC9)
		emit8(0xC3)
	}

	fn emit_write_char(i64 c) {
		emit8(0x48)
		emit8(0x83)
		emit8(0xEC)
		emit8(8)
		emit8(0xC6)
		emit8(0x04)
		emit8(0x24)
		emit8(c)

		emit8(0x48)
		emit8(0xC7)
		emit8(0xC7)
		emit32(1)

		emit8(0x48)
		emit8(0x89)
		emit8(0xE6)

		emit8(0x48)
		emit8(0xC7)
		emit8(0xC2)
		emit32(1)

		emit8(0x48)
		emit8(0xC7)
		emit8(0xC0)
		emit32(1)

		emit8(0x0F)
		emit8(0x05)

		emit8(0x48)
		emit8(0x83)
		emit8(0xC4)
		emit8(8)
	}

	fn parse_head() {
		read8()
		read8()
		read8()
		skip_space()

		read8()
		read8()
		read8()
		read8()
		read8()
		read8()
		read8()
		read8()
		read8()
		read8()

		skip_space()

		read8()
	}

	fn parse_asm() {
		while (current != 0) {
			if (current == 99) {
				emit8(0xFA)
			}

			if (current == 104) {
				emit8(0xF4)
			}

			if (current == 110) {
				emit8(0x90)
			}

			read8()
		}
	}

	fn main() { 

		read8()

		while (current != 0) {
			skip_space()

			if (current == 0) {
				return
			}

			if (current == 104) {
				parse_head()
			}

			if (current == 40) {
				read8()

				if (current == 97) {
					read8()
					read8()
					read8()
					read8()

					if (current == 41) {
						parse_asm()
					}
				}
			}

			if (is_alpha(current) == 1) {
				read_identifier()
			}

			if (is_digit(current) == 1) {
				read_number()
			}

			if (is_alnum(current) == 0) {
				if (current != 104) {
					if (current != 40) {
						read8()
					}
				}
			}
		}

		emit_exit()

		close(input)
		close(output)
	}

}
