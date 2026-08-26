head(asm-x86-64 custom){ 
    (asmb) {
        cli
        hlt
        pad_boot
        sign_boot
    } (asme)
}
