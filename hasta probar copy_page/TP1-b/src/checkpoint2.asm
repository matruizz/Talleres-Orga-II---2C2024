extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4
global alternate_sum_4_simplified
global alternate_sum_8
global product_2_f
global product_9_f
global alternate_sum_4_using_c

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[eDI], x2[eSI], x3[eDX], x4[eCX]
; x1 - x2 + x3 - x4
alternate_sum_4:
	;prologo
        push rbp ; alineado a 16
	mov rbp, rsp

	sub edi, esi ; x1 - x2
	add edi, edx ; (resArriba) + x3
	sub edi, ecx ; (ResArriba) - x4
    mov eax, edi 
        
	;recordar que si la pila estaba alineada a 16 al hacer la llamada
	;con el push de RIP como efecto del CALL queda alineada a 8

	;epilogo
	pop rbp
	ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[edi], x2[esi], x3[edx], x4[ecx]
alternate_sum_4_using_c:
	;prologo
	push rbp ; alineado a 16
	mov rbp,rsp
	
	call restar_c

	mov edi, eax
	mov esi, edx

	call sumar_c

	mov edi, eax
	mov esi, ecx

	call restar_c

	;epilogo
	pop rbp
	ret



; uint32_t alternate_sum_4_simplified(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[?], x2[?], x3[?], x4[?]
alternate_sum_4_simplified:
	sub edi, esi ; x1 - x2
        add edi, edx ; (resArriba) + x3
        sub edi, ecx ; (ResArriba) - x4
        mov eax, edi

	ret


; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; registros y pila: x1[edi], x2[esi], x3[edx], x4[ecx], x5[r8], x6[r9], x7[rbp + 0x10], x8[rbp + 0x18]
alternate_sum_8:
	;prologo
        push rbp
	mov rbp, rsp ;x1-x2+x3-x4+x5-x6+x7-x8 (x8 luego x7)
	
    sub edi, esi ; x1 - x2
    add edi, edx ; (resArriba) + x3
    sub edi, ecx ; (ResArriba) - x4	
	add edi, r8d  ;
	sub edi, r9d
	add edi, [rbp + 0x10]
	sub edi, [rbp + 0x18]
	mov eax, edi
		
	
	
	
	pop rbp
	;epilogo
	ret


; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa
;void product_2_f(uint32_t * destination, uint32_t x1, float f1);
;registros: destination[RDI], x1[ESI], f1[XMM0]
product_2_f:

	CVTSI2SS xmm1, esi  ; convierto a float
	mulss xmm0, xmm1    ; mult. los float
	CVTTSS2SI esi, xmm0 ; convierto a int el res
      
	mov [rdi], esi

	ret


;extern void product_9_f(double * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
;registros y pila: destination[rdi], x1[esi], f1[XMM0], x2[edx], f2[XMM1], x3[ecx], f3[XMM2], x4[r8d], f4[XMM3]
;	, x5[r9d], f5[XMM4], x6[RBP+0X10], f6[XMM5], x7[RBP+ 0X18], f7[XMM6], x8[RBP+0X20], f8[XMM7],
;	, x9[RBP+0X28], f9[RBP+0X30]
product_9_f:
	;prologo
	push rbp
	mov rbp, rsp

	;convertimos los flotantes de cada registro xmm en doubles
	CVTSS2SD xmm0, xmm0

	CVTSS2SD xmm1, xmm1

	CVTSS2SD xmm2, xmm2

	CVTSS2SD xmm3, xmm3

	CVTSS2SD xmm4, xmm4

	CVTSS2SD xmm5, xmm5

	CVTSS2SD xmm6, xmm6

	CVTSS2SD xmm7, xmm7
        
	;multiplicamos los doubles en xmm0 <- xmm0 * xmm1, xmmo * xmm2 , ...

	MULSD xmm0, xmm1

	MULSD xmm0, xmm2

	MULSD xmm0, xmm3

	MULSD xmm0, xmm4

	MULSD xmm0, xmm5

	MULSD xmm0, xmm6

	MULSD xmm0, xmm7

	movq xmm7, qword [rbp+0X30] 

	CVTSS2SD xmm7, xmm7	

	MULSD xmm0, xmm7

	; convertimos los enteros en doubles y los multiplicamos por xmm0.
	CVTSI2SD xmm1, DWORD esi

	CVTSI2SD xmm2, DWORD edx

	CVTSI2SD xmm3, DWORD ecx

	CVTSI2SD xmm4, DWORD r8d

	CVTSI2SD xmm5, DWORD r9d

	MULSD xmm0, xmm1

	MULSD xmm0, xmm2

	MULSD xmm0, xmm3

	MULSD xmm0, xmm4

	MULSD xmm0, xmm5

	mov esi,DWORD [rbp+0x10]

	mov edx,DWORD [rbp+0x18]

	mov ecx,DWORD [rbp+0x20]

	mov r8d,DWORD [rbp+0x28]

	CVTSI2SD xmm1, DWORD esi

	CVTSI2SD xmm2, DWORD edx
    
	CVTSI2SD xmm3, DWORD ecx
    
	CVTSI2SD xmm4, DWORD r8d
    
	MULSD xmm0, xmm1
    
	MULSD xmm0, xmm2
    
	MULSD xmm0, xmm3
    
	MULSD xmm0, xmm4

	movsd [rdi], xmm0

	; epilogo
	pop rbp
	ret


