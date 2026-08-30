head(custom) {
    fn main() {
        I64 x = 0
        while (x <= 10) {
            x = x + 1
            if (x == 10) {
                pin("done\n")
            }
        }
    }
}