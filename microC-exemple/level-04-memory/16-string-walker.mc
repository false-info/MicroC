head(custom) {
    fn main() {
        U64 str = "MicroC"
        I64 position = 0
        U8 character = mem_read8(str + position)
        while (position <= 5) {
            pin("character: %c\n", character)
            position = position + 1
            character = mem_read8(str + position)
        }
    }
}