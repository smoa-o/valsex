%ifndef HDRRDATA
%define HDRRDATA

%include "virt_phys.asm"

bits 64

default abs

BM_BASE_ADDR equ 0x110010

ATA_DRIVE   equ 0x1F6
ATA_COUNT   equ 0x1F2
ATA_LBA0    equ 0x1F3
ATA_LBA1    equ 0x1F4
ATA_LBA2    equ 0x1F5
ATA_CMD     equ 0x1F7

ata_read:
	mov rsi, virt_phys
	call .main
	ret
.main:
    push rbx
    push rbp
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15
    push rdi
    push rsi

    mov r12, rax
    mov r13, rcx
    mov r14, rdi
    mov r15, rsi

    test r13, r13
    jz   .success
    cmp  r13, 256
    ja   .err_count

    sub  rsp, 16
    and  rsp, ~7

    mov rdi, r14
    call r15
    mov dword [rsp], edi

    mov eax, r13d
    shl eax, 9
    mov word [rsp + 4], ax

    mov word [rsp + 6], 0x8000

    mov rdi, rsp
    call r15

    mov edx, [BM_BASE_ADDR]
    add edx, 0x04
    mov eax, edi
    out dx, eax

    mov edx, [BM_BASE_ADDR]
    add edx, 0x02
    in  al, dx
    out dx, al

    mov dx, ATA_DRIVE
    mov al, 0xE0
    out dx, al

    mov dx, ATA_COUNT
    mov al, r13b
    out dx, al

    mov dx, ATA_LBA0
    mov rax, r12
    out dx, al

    mov dx, ATA_LBA1
    shr rax, 8
    out dx, al

    mov dx, ATA_LBA2
    shr rax, 8
    out dx, al

    mov dx, ATA_DRIVE
    mov al, 0xE0
    mov rbx, r12
    shr rbx, 24
    and bl, 0x0F
    or  al, bl
    out dx, al

    mov dx, ATA_CMD
    mov al, 0xC8
    out dx, al

    mov edx, [BM_BASE_ADDR]
    add edx, 0x00
    mov al, 0x01
    out dx, al

.wait:
    mov edx, [BM_BASE_ADDR]
    add edx, 0x02
    in  al, dx
    test al, 0x04
    jnz  .dma_done
    test al, 0x02
    jnz  .err_dma
    jmp  .wait

.dma_done:
    mov edx, [BM_BASE_ADDR]
    add edx, 0x00
    xor al, al
    out dx, al

.success:
    xor rax, rax
    jmp .cleanup

.err_dma:
    mov rax, 1
    jmp .cleanup

.err_count:
    mov rax, 2

.cleanup:
    add rsp, 16
    pop rsi
    pop rdi
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rbp
    pop rbx
    ret

%endif
