section .rodata
; Poner acá todas las máscaras y coeficientes que necesiten para el filtro
divmask: dd 3.0, 3.0, 3.0, 3.0 

summaskG: dd 64, 64, 64, 64

summaskB: dd 128, 128, 128, 128

submask: dd 192, 192, 192, 192

prodmask: dd 4, 4, 4, 4

submask384: dd 384, 384, 384, 384

minmask: dd 255, 255, 255, 255

limpiar: db 0xFF, 0x0, 0x0, 0x0, 0xFF, 0x0, 0x0, 0x0, 0xFF, 0x0, 0x0, 0x0, 0xFF, 0x0, 0x0, 0x0 

transparencia: db 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF


section .text

; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 2 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej1
global EJERCICIO_2_HECHO
EJERCICIO_2_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Aplica un efecto de "mapa de calor" sobre una imagen dada (`src`). Escribe la
; imagen resultante en el canvas proporcionado (`dst`).
;
; Para calcular el mapa de calor lo primero que hay que hacer es computar la
; "temperatura" del pixel en cuestión:
; ```
; temperatura = (rojo + verde + azul) / 3
; ```
;
; Cada canal del resultado tiene la siguiente forma:
; ```
; |          ____________________
; |         /                    \
; |        /                      \        Y = intensidad
; | ______/                        \______
; |
; +---------------------------------------
;              X = temperatura
; ```
;
; Para calcular esta función se utiliza la siguiente expresión:
; ```
; f(x) = min(255, max(0, 384 - 4 * |x - 192|))
; ```
;
; Cada canal esta offseteado de distinta forma sobre el eje X, por lo que los
; píxeles resultantes son:
; ```
; temperatura  = (rojo + verde + azul) / 3
; salida.rojo  = f(temperatura)
; salida.verde = f(temperatura + 64)
; salida.azul  = f(temperatura + 128)
; salida.alfa  = 255
; ```
;
; Parámetros:
;   - dst:    La imagen destino. Está a color (RGBA) en 8 bits sin signo por
;             canal.
;   - src:    La imagen origen A. Está a color (RGBA) en 8 bits sin signo por
;             canal.
;   - width:  El ancho en píxeles de `src` y `dst`.
;   - height: El alto en píxeles de `src` y `dst`.
global ej2
ej2:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits.
	;
	; r/m64 = rgba_t*  dst
	; r/m64 = rgba_t*  src
	; r/m32 = uint32_t width
	; r/m32 = uint32_t height
	
	push rbp
	mov rbp, rsp
	
	xor r9, r9 	;iterador
	mov eax, ecx
	mul edx 	;eax = cant de pixeles de imagen

	.ciclo: 	                               ;127                                 0
		movdqu xmm1, [rsi]                     ;xmm1 = [abgr3 | abgr2 | abgr1 | abgr0]
		movdqu xmm2, xmm1                     ;xmm2 = [mismo]
		movdqu xmm3, xmm1                     ;xmm3 = [mismo]

 		psrldq xmm2, 1                         ;xmm2 = [0abg | rabg | rabg | rabg]
		psrldq xmm3, 2                         ;xmm3 = [00ab | grab | grab | grab] 
	
		movdqu xmm4, [limpiar]
	
		pand xmm1, xmm4
		pand xmm2, xmm4
		pand xmm3, xmm4

		paddd xmm1, xmm2  
       		paddd xmm1, xmm3                     ;xmm1 = [0 0 (r+g+b)3 | 0 0 (r+g+b)2 | 0 0 (r+g+b)1 | 0 0 (r+g+b)0] (numerados)
   	
		cvtdq2ps xmm1, xmm1                    ;xmm1 = [pix3 | pix2 | pix1 | pix0]
	
		movdqu xmm4, [divmask]
		divps xmm1, xmm4                       ;xmm1 = [t3 | t2 | t1 | t0] floats
		
		cvttps2dq xmm1, xmm1                    ;xmm1 = [0 0 0 t3 | 0 0 0 t2 | 0 0 0 t1 | 0 0 0 t0] enteros con signo

		movdqu xmm4, [summaskG]
		movdqu xmm2, xmm1      
		paddd xmm2, xmm4                     ;xmm2 = [0 0 0 t3+64 | 0 0 0 t2+64 | 0 0 0 t1+64 | 0 0 0 t0+64]	

		movdqu xmm4, [summaskB]
		movdqu xmm3, xmm1
		paddd xmm3, xmm4                     ;xmm3 = [0 0 0 t3+128 | 0 0 0 t2+128 | 0 0 0 t1+128 | 0 0 0 t0+128]

	
		movdqu xmm4, [submask]
	
		psubd xmm1, xmm4	               ;t-192
		psubd xmm2, xmm4
		psubd xmm3, xmm4

		pabsd xmm1, xmm1	               ;|t-192|
		pabsd xmm2, xmm2
		pabsd xmm3, xmm3

		pslld xmm1, 2	               ;4*|t-192|
		pslld xmm2, 2
		pslld xmm3, 2

		movdqu xmm4, [submask384]
		psubd xmm4, xmm1		       ;384-4*|t-192|
		movdqu xmm1, xmm4	
	
		movdqu xmm4, [submask384]
		psubd xmm4, xmm2
		movdqu xmm2, xmm4

		movdqu xmm4, [submask384]
		psubd xmm4, xmm3	
		movdqu xmm3, xmm4

		pxor xmm4, xmm4
		pmaxsd xmm1, xmm4		       ;max(0, 384-4*|t-192|)
		pmaxsd xmm2, xmm4
		pmaxsd xmm3, xmm4	

		movdqu xmm4, [minmask]
		pminud xmm1, xmm4		       ;min(255, max(0, 384-4*|t-192|))
		pminud xmm2, xmm4
		pminud xmm3, xmm4	
	
		;Hasta ahora:
		;xmm1: f(t) de rojo packed
		;xmm2: f(t+64) de verde packed
		;xmm3: f(t+128) de azul packed		


		pslldq xmm2, 1
		pslldq xmm3, 2

		por xmm1, xmm2
		por xmm1, xmm3			       

		movdqu xmm4, [transparencia]

		por xmm1, xmm4

		movdqu [rdi], xmm1
		
		add rsi, 16
		add rdi, 16
		add r9d, 4

		cmp r9d, eax
		jne .ciclo
	
			
	pop rbp
	ret	

