head(asm-x86-16) {
    (asmb) {
        org(0x8000)
        bits16
        cli
        xor(ax, ax)
        mov(ds, ax)
        mov(es, ax)
        mov(ss, ax)
        mov(sp, 0x7000)
        sti
        push(dx)
        mov(si, kernel_dap)
        pop(dx)
        mov(ah, 0x42)
        int(0x13)
        label(hang)
        hlt
        jmp(hang)
    } (asme)
}