head(custom) {
    fn double(I64 x) {
        return x * 2
    }
    fn main() {
        I64 result = double(21)
        pin("%I64\n", result)       
    }
}