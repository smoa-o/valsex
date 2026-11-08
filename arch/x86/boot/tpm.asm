org 0x7e00

TLM equ 0x100000
TLM_SECTOR equ 0x0        ; LBA 扇区号 = 0x10 (第16扇区)
TLML equ 18         ; TLM 超过512字节，读2个扇区

default abs

tpm:
    cli

    lgdt [GdtPtr]
    or byte [0x7000], (1 << 5)

    call enable_a20
    or byte [0x7000], (1 << 4)

    mov eax, cr0
    or eax, 1
    mov cr0, eax
    or byte [0x7000], (1 << 3)

    jmp 0x08:pm

enable_a20:
    xor al, al
    in al, 0x92
    or al, 2
    and al, 0xfe
    out 0x92, al
    ret

bits 32
pm:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    or byte [0x7000], (1 << 2)

    ; ---- ATA PIO Read ----
    ; LBA 0x10, 2 sectors → 0x100000

    ; 等待 BSY=0, DRDY=1
    mov dx, 0x1f7
.wait_ready:
    nop
    in al, dx
    and al, 0xc0
    cmp al, 0x40
    jnz .wait_ready

    ; 扇区计数
    mov dx, 0x1f2
    mov al, TLML
    out dx, al

    ; LBA Low (1f3)
    inc dx
    mov al, TLM_SECTOR & 0xff
    out dx, al

    ; LBA Mid (1f4)
    inc dx
    mov al, (TLM_SECTOR >> 8) & 0xff
    out dx, al

    ; LBA High (1f5)
    inc dx
    mov al, (TLM_SECTOR >> 16) & 0xff
    out dx, al

    ; Drive/Head (1f6): LBA模式, 主盘, LBA[27:24]
    inc dx
    mov al, 0xe0 | ((TLM_SECTOR >> 24) & 0x0f)
    out dx, al

    ; 发送读命令 (0x20)
    inc dx
    mov al, 0x20
    out dx, al

    ; 等待 DRQ=1
.wait_drq:
    in al, dx
    test al, 1
    jnz .err
    and al, 0x88
    cmp al, 0x08          ; BSY=0, DRQ=1
    jnz .wait_drq

    ; 读取数据
    sub dx, 7             ; dx = 0x1f0
    mov ecx, 256 * TLML
    mov edi, TLM
    mov ax, 0x10
    mov es, ax
    cld
    rep insw

.done:
    or byte [0x7000], (1 << 6)
    ; 32-bit far jump to TLM @ 0x100000 (was 16-bit, offset truncated to 0)
    ;db 0xEA
    ;dd 0x00100000
    ;dw 0x0008
    jmp 0x08:0x100000

.err:
    or byte [0x7000], (1 << 0)
    cli
    hlt
    jmp $

align 8

GdtStart:
    dq 0x0000000000000000
    dq 0x00CF9A000000FFFF    ; 0x08: 32-bit ring0 code
    dq 0x00CF92000000FFFF    ; 0x10: 32-bit ring0 data
    dq 0x00209A0000000000    ; 0x18: 64-bit ring0 code
    dq 0x0020920000000000    ; 0x20: 64-bit ring0 data
    dq 0x0020FA0000000000    ; 0x28: 64-bit ring3 code
    dq 0x0020F20000000000    ; 0x30: 64-bit ring3 data
GdtEnd:
GdtPtr:
    dw GdtEnd - GdtStart - 1
    dq GdtStart
