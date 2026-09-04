head(custom) {
    I64 source_fd = 0
    I64 source_size = 0
    I64 source_pos = 0
    I64 current = 0

    fn next_char() {
        current = file_read8(source_fd)
        source_pos = source_pos + 1
        if (source_pos >= source_size) {
            current
        }
    }
}