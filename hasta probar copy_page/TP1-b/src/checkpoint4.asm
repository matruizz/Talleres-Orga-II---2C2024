extern malloc
extern free
extern fprintf

section .data

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a, char* b)
;rdi = a, rsi = b
strCmp:
	push rbp
	mov rbp, rsp

	xor rax, rax

	xor rdx, rdx
	xor rcx, rcx

	mov dl, byte [rdi]
	mov cl, byte [rsi]

	.ciclo:

		cmp dl, cl
		jg .aMayor
		

		;SE PUEDE USAR EL CMP UNA SOLA VEZ
		;cmp dl, cl
		jl .bMayor

		cmp dl, 0
		je .fin

		
		inc rdi
		inc rsi

		mov dl, byte [rdi]
		mov cl, byte [rsi]


		jmp .ciclo




	.aMayor:
		mov rax, 0xFFFF_FFFF
		jmp .fin

	.bMayor:
		inc rax
		jmp .fin

	.fin:
	pop rbp
	ret

; char* strClone(char* a)
; rdi = a
 
strClone:
	push rbp                ;prologo
	mov rbp, rsp
	
	xor rdx, rdx	
	xor rax, rax	
	xor rcx, rcx
	xor r10, r10
	mov rdx, rdi            ;guardo puntero para llamar funciones externas
	
	.copiar:
		call strLen     ;tamaño del string en rax
		inc rax         ;porque si no, malloc no cuenta el caracter nulo
		mov rdi, rax    ;para que malloc tenga el tamaño del string
		
		push rdx	
		sub rsp, 0x8

		call malloc     ;puntero con memoria asignada ahora en rax

		add rsp, 0x8	
		pop rdx		;preservo puntero original
		
		mov rdi, rdx    ;devuelvo el puntero a su lugar	
       		mov rcx, rax    ;puntero de la memoria a clonar	
	.clonar:
		mov r10b, byte [rdx]
		cmp r10b, 0
		je .fin

		mov byte [rcx], r10b
	
		inc rcx
		inc rdx
		
		jmp .clonar		 		
			
	.fin:
		mov byte[rcx], 0 ;clono el caracter nulo 	
		pop rbp          ;epilogo
		ret

; void strDelete(char* a)
strDelete:
	push rbp
	mov rbp, rsp

	call free

	pop rbp

	ret

; void strPrint(char* a, FILE* pFile)
; a = rdi, pfile = rsi
strPrint:
	push rbp
	mov rbp, rsp

	mov r12, rdi
	mov rdi, rsi
	mov rsi, r12
	
	;rdi: pfile    rsi: char*

	cmp byte [rsi], 0
	je .esVacio
	
	call fprintf
	
	jmp .fin
	
	.esVacio:
		push rdi
		push rsi

		mov rdi, 5

		call malloc

		pop rsi
		pop rdi

		mov r12, rax

		mov QWORD[r12], 0x4C_4C_55_4E
		
		add r12, 4

		mov byte[r12], 0

		mov rsi, rax
		
		call fprintf
	.fin:
		pop rbp
		ret

; uint32_t strLen(char* a)
; rdi = a
strLen:
	push rbp
	mov rbp, rsp
	
	xor rax, rax
	mov r10, rdi
	
	.len:
		mov r11b, byte[r10]
		cmp r11b, 0
		je .fin

		inc r10
		inc rax
		jmp .len

	.fin:
		pop rbp
		ret


