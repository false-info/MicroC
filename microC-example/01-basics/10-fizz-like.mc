head(custom) {
    fn main() {
        I64 x = 1
        while(x <= 15) {
            if((x % 15) == 0) {
                pin("both\n")
            }
            else {
                if((x % 3) == 0) {
                    pin("three\n")
                }
                else {
                    if((x % 5) == 0) {
                        pin("five\n")
                    }
                    else {
                        pin("%I64\n", x)
                    }
                }
            }
            x = x + 1
        }
    }
}