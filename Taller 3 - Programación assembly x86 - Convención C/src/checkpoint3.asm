

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar:
NODO_LENGTH	EQU	32
NODO_NEXT EQU 0
NODO_CATEGORIA EQU 8
NODO_ARREGLO EQU 16
LONGITUD_OFFSET	EQU	24


PACKED_NODO_LENGTH	EQU 21
PACKED_NODO_NEXT EQU 0
PACKED_NODO_CATEGORIA EQU 8
PACKED_NODO_ARREGLO EQU 9
PACKED_LONGITUD_OFFSET	EQU	17

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS
global cantidad_total_de_elementos
global cantidad_total_de_elementos_packed

;########### DEFINICION DE FUNCIONES
;extern uint32_t cantidad_total_de_elementos(lista_t* lista);
;registros: lista[rdi]
cantidad_total_de_elementos:
	push rbp
	mov rbp, rsp

	xor rax, rax

	cmp rdi, 0		;Si el puntero a la lista es null saltamaos al final
	je .fin

	;FIJARSE QUE SE PUEDA RDI RDI
	;SI FUNCIONA
	mov rdi, [rdi]	;rsi = puntero al primer nodo

	.ciclo:
		cmp rdi, 0
		je .fin

		;Funciona sin el DWORD
		add eax, DWORD [rdi + LONGITUD_OFFSET]
		
		mov rdi, [rdi]	;rdi = siguiente
		jmp .ciclo

	.fin:

	pop rbp
	ret

;extern uint32_t cantidad_total_de_elementos_packed(packed_lista_t* lista);
;registros: lista[?]
cantidad_total_de_elementos_packed:
	push rbp
	mov rbp, rsp

	xor rax, rax

	cmp rdi, 0		;Si el puntero a la lista es null saltamaos al final
	je .fin

	;FIJARSE QUE SE PUEDA RDI RDI
	mov rdi, [rdi]	;rsi = puntero al primer nodo

	.ciclo:
		cmp rdi, 0
		je .fin

		add eax, [rdi + PACKED_LONGITUD_OFFSET]
		
		mov rdi, [rdi]	;rdi = siguiente
		jmp .ciclo

	.fin:

	pop rbp
	ret
