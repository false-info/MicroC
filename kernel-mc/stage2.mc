head(asm-x86-16 asm-x86-32 asm-x86-64) {
    (asmb) {
        org(0x8000)
        bits16

        cli
        cld

        xor(ax, ax)

        mov(ds, ax)
        mov(es, ax)
        mov(ss, ax)

        mov(sp, 0x7C00)

        push(dx)

        mov(ah, 0x0E)

        mov(al, 0x53)
        int(0x10)

        mov(al, 0x32)
        int(0x10)

        mov(eax, 0x80000000)
        cpuid

        cmp(eax, 0x80000001)
        jb(no_long_mode)

        mov(eax, 0x80000001)
        cpuid

        mov(ecx, 0x20000000)
        test(edx, ecx)
        jz(no_long_mode)

        in(al, 0x92)

        or(al, 0x02)
        and(al, 0xFE)

        out(0x92, al)

        mov(si, kernel_dap)

        pop(dx)

        mov(ah, 0x42)
        int(0x13)

        jc(kernel_disk_error)

        lgdt(gdt_descriptor)

        mov(eax, cr0)

        or(eax, 0x00000001)

        mov(cr0, eax)

        jmp_far(0x08, protected_entry)

        label(no_long_mode)

        pop(dx)

        mov(ah, 0x0E)

        mov(al, 0x4E)
        int(0x10)

        mov(al, 0x4F)
        int(0x10)

        mov(al, 0x20)
        int(0x10)

        mov(al, 0x4C)
        int(0x10)

        mov(al, 0x4D)
        int(0x10)

        jmp(stage2_halt16)

        label(kernel_disk_error)

        mov(ah, 0x0E)

        mov(al, 0x45)
        int(0x10)

        mov(al, 0x32)
        int(0x10)

        label(stage2_halt16)

        cli

        label(stage2_halt16_loop)

        hlt
        jmp(stage2_halt16_loop)

        bits32

        label(protected_entry)

        mov(ax, 0x10)

        mov(ds, ax)
        mov(es, ax)
        mov(ss, ax)
        mov(fs, ax)
        mov(gs, ax)

        mov(esp, 0x90000)

        cld

        mov(esi, 0x00010000)
        mov(edi, 0x00100000)
        mov(ecx, 49152)

        rep_movsb

        xor(eax, eax)

        mov(edi, 0x1000)
        mov(ecx, 0x3000)

        rep_stosb

        store32(0x1000, 0x00002003)
        store32(0x1004, 0)

        store32(0x2000, 0x00003003)
        store32(0x2004, 0)

        store32(0x3000, 0x00000083)
        store32(0x3004, 0)

        mov(eax, 0x1000)
        mov(cr3, eax)

        mov(eax, cr4)
        or(eax, 0x20)
        mov(cr4, eax)

        mov(ecx, 0xC0000080)

        rdmsr

        or(eax, 0x00000100)

        wrmsr

        mov(eax, cr0)

        or(eax, 0x80000000)

        mov(cr0, eax)

        jmp_far(0x18, long_mode_entry)

        bits64

        label(long_mode_entry)

        mov(ax, 0x10)

        mov(ds, ax)
        mov(es, ax)
        mov(ss, ax)

        mov(rsp, 0x90000)
        mov(rbp, rsp)

        mov(ax, 0x0F4C)
        store16(0xB8000, ax)

        mov(rax, 0x100000)

        jmp_reg(rax)

        cli

        label(long_mode_halt)

        hlt
        jmp(long_mode_halt)

        bits16

        label(kernel_dap)

        db(0x10)
        db(0x00)

        dw(96)

        dw(0x0000)
        dw(0x1000)

        dd(17)
        dd(0)

        align(8)

        label(gdt_start)

        dq(0x0000000000000000)
        dq(0x00CF9A000000FFFF)
        dq(0x00CF92000000FFFF)
        dq(0x00AF9A000000FFFF)

        label(gdt_descriptor)

        dw(31)
        dd(gdt_start)
    } (asme)
}