head(custom) {
    fn main() {
        I64 x = 65
        while (x <= 90) {
            pin("character: %c\nposition: %I64\n", x, x)
            x = x + 1
        }
    }
}