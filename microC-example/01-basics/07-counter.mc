head(custom) {
    fn main() {
        I64 x = 0
        pin("counting up from %I64\n", x)
        while (x != 10) {
            pin("x is %I64\n", x)
            x = x + 1
            if(x == 10) {
                pin("x stopped at %I64\n", x)
            }
        }
    }
}