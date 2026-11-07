org 0x7e00

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

	or byte [0x7000], (1 << 2) | (1 << 0)
	cli
	hlt
	jmp $

align 8

GdtStart:
    ; 0x00: null descriptor
    dq 0x0000000000000000

    ; 0x08~0x10: 32-bit ring0
    dq 0x00CF9A000000FFFF
    dq 0x00CF92000000FFFF

    ; 0x18~0x20: 64-bit ring0
    dq 0x00209A0000000000
    dq 0x0020920000000000

    ; 0x28~0x30: 64-bit ring3
    dq 0x0020FA0000000000
    dq 0x0020F20000000000
GdtEnd:
GdtPtr:
    dw GdtEnd - GdtStart - 1
    dq GdtStart
