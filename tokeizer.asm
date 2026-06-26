bits 64
default rel

TOK_PIN equ 1
TOK_END equ 255

section .data
source db 'pin', 0

section .bss
tokens resb 16

section .text
tokeize:
	lea rsi, [source]
	lea rdi, [tokens]

.next:
	mov al, [rsi]
	cmp al, 0
	je .done

	cmp al, 'p'
	je .try_pin
	inc rsi
	jmp .next

.try_pin:
	cmp byte [rsi + 0], 'p'
	jne .not_pin

	cmp byte [rsi + 1], 'i'
	jne .not_pin

	cmp byte [rsi + 2], 'n'
	jne .not_pin

	add rsi, 3
	jmp .next

.not_pin:
	inc rsi
	jmp .next

.done:
	mov byte [rdi], TOK_END
.halt:
	hlt
	jmp .halt
