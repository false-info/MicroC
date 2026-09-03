head(custom) {
    fn add(I64 a, I64 b) {
        return a + b
    }

    fn sub(I64 a, I64 b) {
        return a - b
    }

    fn mult(I64 a, I64 b) {
        return a * b
    }

    fn main() {
        I64 add_result = add(10, 5)
        I64 sub_result = sub(10, 5)
        I64 mult_result = mult(10, 5)
        pin("a + b is %I64\n", add_result)
        pin("a - b is %I64\n", sub_result)
        pin("a * b is %I64\n", mult_result)
    }

}