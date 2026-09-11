head(custom) {
    fn seconds_to_time(I64 total) {
        I64 hours = total % 3600
        pin("%I64\n", hours)
    }

    fn main() {
        seconds_to_time(73616)
    }
}