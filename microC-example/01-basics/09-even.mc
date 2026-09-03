head(custom) {
    fn main() {
        I64 x = 1
        while(x <= 10) {
            pin("%I64 is ", x)
            if((x % 2) == 0) {
                pin("even\n")
            } else {
                pin("odd\n")
            }
            x = x + 1
        }
    }
}