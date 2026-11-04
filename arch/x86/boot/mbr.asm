org 0x7c00

mmain:
	; clear n bit: and var, ~(1 << n)
	; stay n bit: or var, (1 << n)

	; 0x7000 (bit 7~0)
	; ...6 Rsvd... RMPASS FIN

	mov byte [0x7000], 3
	
	cli
	hlt
	jmp $

times 510 - ($ - $$)	db 0
dw 0xaa55

