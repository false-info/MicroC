head(custom) {
    fn main() {
        I64 x = 10
        pin("counting down from %I64\n", x)
        while(x != 0) {
            pin("x is %I64\n", x)
            x = x - 1
            if(x == 0) {
                pin("stopped at %I64\n", x)
            }
        }
    }
}