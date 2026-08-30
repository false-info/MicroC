head(custom) {
    fn biggest(I64 x, I64 y) {
        if (x <= y) {
            return x
        }
        return y
    }
    fn main() {
        I64 result = biggest(32, 1)
        pin("the bigger one is: %I64", result)
    }
}