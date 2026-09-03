head(custom) {
    fn myfn(I64 a, I64 b) {
        return a + b
    }

    fn main() {
        I64 myfn = myfn(487, 478)
        pin("my first fn a + b is %I64\n", myfn)
    }
}