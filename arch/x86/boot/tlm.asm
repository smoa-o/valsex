bits 32
org 0x100000

default rel

jmp tlm

; exstatus (bit 7~0)
; ... LCR3 PAE LME PG FJMP LMPASS

status:   db 0
exstatus: db 0

; ============================================================
; 页表空间 — 放在代码里，加载到 0x100000 + 偏移
; 物理地址 = 0x100000 + pagetable - tlm_start
; 但你说 CR3 = 0x210000，所以我把页表写到 0x210000 处
; 用绝对地址直接写，不依赖标签偏移
; ============================================================

tlm_start:

tlm:
    cli

    mov ax, 0x10
    mov ds, ax
    mov es, ax

    ; ---- 在 0x210000 处建立页表 ----
    ; 0x210000 = PML4
    ; 0x211000 = PDPT
    ; 0x212000 = PD

    ; 清零 3 页
    mov edi, 0x210000
    xor eax, eax
    mov ecx, (3 * 4096) / 4
    rep stosd

    ; PML4[0] -> PDPT (0x211000), present | writable
    mov dword [0x210000],     0x211003
    ; PML4[511] -> PDPT (0x211000), present | writable (canonical)
    mov dword [0x210000 + 511*8], 0x211003

    ; PDPT[0] -> PD (0x212000), present | writable
    mov dword [0x211000],     0x212003

    ; PD[0] -> 2MB page at 0x000000, present | writable | 2MB
    mov dword [0x212000],     0x000083
    ; PD[1] -> 2MB page at 0x200000, present | writable | 2MB
    ; 覆盖 TLM 代码本身 (0x100000) 和页表 (0x210000)
    mov dword [0x212000 + 8], 0x200083

    or byte [0x7000], (1 << 7)

    ; ---- 加载 CR3 ----
    mov eax, 0x210000
    mov cr3, eax
    or byte [exstatus], (1 << 5)

    ; ---- 开启 PAE ----
    mov eax, cr4
    or eax, (1 << 5)
    mov cr4, eax
    or byte [exstatus], (1 << 4)

    ; ---- 开启 Long Mode (EFER.LME) ----
    mov ecx, 0xc0000080
    rdmsr
    or eax, (1 << 8)
    wrmsr
    or byte [exstatus], (1 << 3)

    ; ---- 开启 Paging (CR0.PG) ----
    mov eax, cr0
    or eax, (1 << 31)
    mov cr0, eax
    or byte [exstatus], (1 << 2)

    ; ---- 远跳进入 64 位 ----
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

    mov r8, status
    mov r9, exstatus

    or byte [exstatus], (1 << 0)
    or byte [status],   (1 << 0)

    cli
    hlt
    jmp $
