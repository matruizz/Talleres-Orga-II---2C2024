section .rodata
; Poner acá todas las máscaras y coeficientes que necesiten para el filtro
				;  0     1    2      3    4     5     6     7     8     9  ...
transparencia: db 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF

constantes: dd 0.2126, 0.7152, 0.0722, 0.0 

shuffle1: db 0x0, 0x0, 0x0, 0x3, 0x4, 0x4, 0x4, 0x7, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3
shuffle2: db 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x0, 0x0, 0x0, 0x3, 0x4, 0x4, 0x4, 0x7

section .text

; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej1
global EJERCICIO_1_HECHO
EJERCICIO_1_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Convierte una imagen dada (`src`) a escala de grises y la escribe en el
; canvas proporcionado (`dst`).
;
; Para convertir un píxel a escala de grises alcanza con realizar el siguiente
; cálculo:
; ```
; luminosidad = 0.2126 * rojo + 0.7152 * verde + 0.0722 * azul
; ```
;xmm0 = 0.21, 0.7152, 0.07 1
; Como los píxeles de las imágenes son RGB entonces el píxel destino será
; ```
; rojo  = luminosidad
; verde = luminosidad
; azul  = luminosidad
; alfa  = 255
; ```
;
; Parámetros:
;   - dst:    La imagen destino. Está a color (RGBA) en 8 bits sin signo por
;             canal.
;   - src:    La imagen origen A. Está a color (RGBA) en 8 bits sin signo por
;             canal.
;   - width:  El ancho en píxeles de `src` y `dst`.
;   - height: El alto en píxeles de `src` y `dst`.
global ej1
;rdi = src; rsi = dst; edx = w; ecx = h
ej1:
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

	xor r9, r9		;limpiamos r9 para usarlo como iterador

	mov eax, ecx
	mul edx			;eax = #de pixeles de la imagen

	pxor xmm14, xmm14

	.ciclo:

	;IDEA: 
	; - en xmm1 tengo 4 pixeles osea: abgr1 abgr2 abgr3 abgr4
	; - En xmm2 tengo extendidos los colores del pixel de mas a la derecha: a4 b4 g4 r4 
	; - En xmm3 tengo lo mismo pero con los de abgr3: a3 b3 g4 r4
	; - Luego tanto en xmm2 y xmm3 los convierto a float, y los multiplico por las constantes (a por 0) 
	; - Luego utilizo la suma horizontal HADDPS entre xmm2 y xmm3 y lo guardo en xmm2, queda:
	; xmm2 = b3 g3+r3 b4 g4+r4
	; - Luego hago lo mismo entre xmm2 y cualquiero otro registro, va a haber basura en los 64 bits mas altos, no importa
	; xmm2 = basura basura b3+g3+r3 b4+g4+r4
	; - Luego lo acomodo en mi xmmRes de la forma en la que corresponde con shuffle
	; - Repito lo mismo con abgr1 y abgr2, y lo escribo 

		movdqu xmm0, [constantes]       ;xmm0 = constantes para mult
				              	;		128            0
		movdqu  xmm1, [rsi]				;xmm1 = [p3, p2, p1, p0]

		pmovzxbd xmm2, xmm1             ;xmm2 = extiendo el pixel de mas a derecha: a b g r
		
		psrldq xmm1, 4                  ;xmm1 = pongo e pixel de antes de la derecha, como el de la derecha

		pmovzxbd xmm3, xmm1             ;xmm3 = extiendo el pixel mas a la drecha

		cvtdq2ps xmm2, xmm2				;xmm2 = Convierto los "a b g r" a float

		cvtdq2ps xmm3, xmm3             ;igual que xmm2, pero con el otro pixel

		mulps xmm2, xmm0 				;xmm2 = multiplico m2 por las constantes	        

		mulps xmm3, xmm0                ;igual que arriba

		haddps xmm2, xmm3               ;xmm2 = b1 g1+r1 b0 g0+r0

		haddps xmm2, xmm14              ;xmm2 = 0 0 b1+g1+r1 b0+g0+r0

		cvtps2dq xmm2, xmm2             ;xmm2 = [0 0 0 0 | 0 0 0 0 | 0 0 0 res1 0 0 0 res0]convierto a entero 
		
		movdqu xmm3, [shuffle1]
										;		128														0
		pshufb xmm2, xmm3				;xmm2 = [0 0 0 0 | 0 0 0 0 | 0 res1 res1 res1 | 0 res0 res0 res0]
		
		movdqu xmm15, xmm2
;-------------------------------------------------
		psrldq xmm1, 4

		pmovzxbd xmm2, xmm1             ;xmm2 = extiendo el pixel de mas a derecha: a b g r
		
       		psrldq xmm1, 4                  ;xmm1 = pongo e pixel de antes de la derecha, como el de la derecha

		pmovzxbd xmm3, xmm1             ;xmm3 = extiendo el pixel mas a la drecha

		cvtdq2ps xmm2, xmm2				;xmm2 = Convierto los "a b g r" a float

		cvtdq2ps xmm3, xmm3             ;igual que xmm2, pero con el otro pixel

		mulps xmm2, xmm0 				;xmm2 = multiplico m2 por las constantes	        

		mulps xmm3, xmm0                ;igual que arriba

		haddps xmm2, xmm3               ;xmm2 = b1 g1+r1 b0 g0+r0

		haddps xmm2, xmm14              ;xmm2 = 0 0 b1+g1+r1 b0+g0+r0
										;		128										  0
		cvtps2dq xmm2, xmm2             ;xmm2 = [0 0 0 0 | 0 0 0 0 | 0 0 0 res1 0 0 0 res0]convierto a entero 
		
		movdqu xmm3, [shuffle2]
										;		128														0
		pshufb xmm2, xmm3				;xmm2 = [0 0 0 0 | 0 0 0 0 | 0 res1 res1 res1 | 0 res0 res0 res0]
		
		por xmm15, xmm2					;xmm15 = [0 r3 r3 r3 |0 r2 r2 r2 |0 r1 r1 r1 |0 r0 r0 r0]

;-----------------------------------------------------------------------------------------------------------------------------

		movdqu xmm14, [transparencia]
	
		por xmm15, xmm14		
		
		movdqu [rdi], xmm15


		add rsi, 16
		add rdi, 16
		add r9d, 4
		
		cmp r9d, eax
		jne .ciclo


	pop rbp
	ret

