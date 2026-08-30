head(custom) {
    fn add(I64 x, I64 y) {
        return x + y
    }
    fn main() {
        I64 result = add(7 + 5)
        pin("result: %I64\n", result)
    }
}