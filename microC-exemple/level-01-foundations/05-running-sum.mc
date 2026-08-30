head(custom) {
    fn main() {
        I64 x = 0
        I64 sum = 0
        while (x <= 10) {
            sum = sum + x
            x = x + 1
        }
        pin("sum: %I64\n", sum)
    }
}