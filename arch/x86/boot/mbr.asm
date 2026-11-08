org 0x7c00

default abs

mmain:
	; clear n bit: and var, ~(1 << n)
	; stay n bit: or var, (1 << n)

	; 0x7000 (bit 7~0)
	; PGRDY PMATA LGDT A20 PE PMPASS RMPASS FIN

	;mov byte [0x7000], 3
	
	;cli
	;hlt
	;jmp $

	mov si, dx

	mov byte [0x7000], 0

	mov ah, 0x02
	mov al, 0x01
	xor ch, ch
	mov cl, 0x02
	mov dx, si
	xor dh, dh
	mov bx, 0x7e00
	int 0x13
	jc .err

	or byte [0x7000], (1 << 1)
	jmp 0x0000:0x7e00 ; TPM

.err:
	or byte [0x7000], (1 << 0)
	cli
	hlt
	jmp $

times 510 - ($ - $$)	db 0
dw 0xaa55
