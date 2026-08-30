head(custom) {
    fn main() {
        I64 x = 0
        while (x <= 20) {
            x = x + 1
            if (x == 5) {
                pin("five\n")
            }
            if (x == 10) {
                pin("ten\n")
            }
            if (x == 20) {
                pin("twenty\n")
            }
        }
    }
}