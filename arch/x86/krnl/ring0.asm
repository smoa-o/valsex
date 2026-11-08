bits 64
org 0x120000

default abs

ring0:
	; KRNLSTS (bit 63~0)
	; ... IR0 FIN
	
	mov rax, rsp
	mov qword [0x110000+24], rax ; KRNLSTK
	mov qword [0x110000+32], (1 << 0) | (1 << 1) ; KRNLSTS

	cli
	hlt
	jmp $
