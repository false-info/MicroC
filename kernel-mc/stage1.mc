head(asm-x86-16) {
    (asmb) {
        org(0x7C00)
        bits16
        cli
        xor(ax, ax)
        mov(ds, ax)
        mov(es, ax)
        mov(ss, ax)
        mov(sp, 0x7C00)
        sti
        cld
        push(dx)
        mov(si, stage2_dap)
        pop(dx)
        mov(ax, 0x42)
        int(0x13)
        jc(disk_error)
        jmp_far(0x0000, 0x8000)
        label(disk_error)
        cli
        label(hang)
        hlt
        label(stage2_dap)
        db(0x10)
        db(0x13)
        dw(16)
        dw(0x8000)
        dw(0)
        dd(1)
        dd(0)
        pad_boot
        sign_boot
    } (asme)
}