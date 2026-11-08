%ifndef HDRVIRTPHYS
%define HDRVIRTPHYS

bits 64

; input: rsi
; output: rdi
; broken: rcx rdx rax
virt_phys:
	mov rdi, rsi
	call .main
	mov rdi, rax
	ret
.main:
    mov rax, rdi
    shr rax, 39
    and rax, 0x1FF

    mov rcx, cr3
    and rcx, 0xFFFFFFFFFFFFF000
    mov rcx, [rcx + rax*8]
    test rcx, 0x1
    jz .not_present
    and rcx, 0xFFFFFFFFFFFFF000

    mov rax, rdi
    shr rax, 30
    and rax, 0x1FF

    mov rcx, [rcx + rax*8]
    test rcx, 0x1
    jz .not_present
    test rcx, 0x80
    jnz .gig_page
    and rcx, 0xFFFFFFFFFFFFF000

    mov rax, rdi
    shr rax, 21
    and rax, 0x1FF

    mov rdx, [rcx + rax*8]
    test rdx, 0x1
    jz .not_present
    test rdx, 0x80
    jnz .huge_page
    and rdx, 0xFFFFFFFFFFFFF000

    mov rax, rdi
    shr rax, 12
    and rax, 0x1FF

    mov rax, [rdx + rax*8]
    test rax, 0x1
    jz .not_present
    and rax, 0xFFFFFFFFFFFFF000

    mov rcx, rdi
    and rcx, 0xFFF
    add rax, rcx
    ret

.huge_page:
    and rdx, strict qword 0x000FFFFFFFE00000
    mov rax, rdi
    and rax, 0x001FFFFF
    add rax, rdx
    ret

.gig_page:
    and rcx, strict qword 0x000FFFFFC0000000
    mov rax, rdi
    and rax, 0x3FFFFFFF
    add rax, rcx
    ret

.not_present:
    xor rax, rax
    ret

%endif
