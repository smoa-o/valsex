bits 32
org 0x100000

default rel

jmp tlm

; exstatus (bit 7~0)
; ... LCR3 PAE LME PG FJMP LMPASS

status:   db 0
exstatus: db 0

tlm_start:

tlm:
    cli

    mov ax, 0x10
    mov ds, ax
    mov es, ax
    
    mov edi, 0x210000
    xor eax, eax
    mov ecx, (3 * 4096) / 4
    rep stosd

    mov dword [0x210000],     0x211003
    mov dword [0x210000 + 511*8], 0x211003

    mov dword [0x211000],     0x212003

    mov dword [0x212000],     0x000083
    mov dword [0x212000 + 8], 0x200083

    or byte [0x7000], (1 << 7)

    mov eax, 0x210000
    mov cr3, eax
    or byte [exstatus], (1 << 5)

    mov eax, cr4
    or eax, (1 << 5)
    mov cr4, eax
    or byte [exstatus], (1 << 4)

    mov ecx, 0xc0000080
    rdmsr
    or eax, (1 << 8)
    wrmsr
    or byte [exstatus], (1 << 3)

    mov eax, cr0
    or eax, (1 << 31)
    mov cr0, eax
    or byte [exstatus], (1 << 2)

    jmp 0x18:lm

bits 64

lm:
    mov ax, 0x20
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    or byte [exstatus], (1 << 1)

    or byte [exstatus], (1 << 0)
    or byte [status],   (1 << 0)

    cli
    hlt
    jmp $
