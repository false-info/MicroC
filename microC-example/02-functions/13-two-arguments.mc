head(custom) {
    fn diff(I64 a, I64 b) {
        return a - b
    }

    fn main() {
        I64 result = diff(12, 5)
        pin("diffrace is %I64\n", result)
    }
}