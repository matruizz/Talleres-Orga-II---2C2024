section .text

; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 3A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej3a
global EJERCICIO_3A_HECHO
EJERCICIO_3A_HECHO: db TRUE  ; Cambiar por `TRUE` para correr los tests.

; Dada una imagen origen escribe en el destino `scale * px + offset` por cada
; píxel en la imagen.
;
; Parámetros:
;   - dst_depth: La imagen destino (mapa de profundidad). Está en escala de
;                grises a 32 bits con signo por canal.
;   - src_depth: La imagen origen (mapa de profundidad). Está en escala de
;                grises a 8 bits sin signo por canal.
;   - scale:     El factor de escala. Es un entero con signo de 32 bits.
;                Multiplica a cada pixel de la entrada.
;   - offset:    El factor de corrimiento. Es un entero con signo de 32 bits.
;                Se suma a todos los píxeles luego de escalarlos.
;   - width:     El ancho en píxeles de `src_depth` y `dst_depth`.
;   - height:    El alto en píxeles de `src_depth` y `dst_depth`.
global ej3a
ej3a:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits.
	;
	; r/m64 = int32_t* dst_depth RDI
	; r/m64 = uint8_t* src_depth RSI
	; r/m32 = int32_t  scale EDX
	; r/m32 = int32_t  offset ECX
	; r/m32 = int      width R8D
	; r/m32 = int      height R9D
	push rbp
	mov rbp, rsp

	imul r9d, r8d
	xor r8, r8	
	
	movd xmm2, edx
	movd xmm3, ecx      			
	
	pshufd xmm2, xmm2, 0x00			;xmm2 = [scale, scale, scale, scale]
	pshufd xmm3, xmm3, 0x00			;xmm3 = [offset, offset, offset, offset]
	
	.ciclo:
		pmovzxbd xmm0, dword[rsi]
		
		pmulld xmm0, xmm2		;mul los dwords por scale
		paddd xmm0, xmm3		;sum los dwords por offset
	
		movdqu [rdi], xmm0		;resultado almacenado en dst

		add r8d, 4			
		add rsi, 4			;muevo a los siguientes 4 bytes de input
		add rdi, 16			;muevo a los 4 int32ts siguientes
		cmp r8d, r9d			;comparo con cant total de pixeles
		jne .ciclo



	pop rbp
	ret


; Marca el ejercicio 3B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej3b
global EJERCICIO_3B_HECHO
EJERCICIO_3B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Dadas dos imágenes de origen (`a` y `b`) en conjunto con sus mapas de
; profundidad escribe en el destino el pixel de menor profundidad por cada
; píxel de la imagen. En caso de empate se escribe el píxel de `b`.
;   b > a = a
;   b <= a = b
; Parámetros:
;   - dst:     La imagen destino. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - a:       La imagen origen A. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - depth_a: El mapa de profundidad de A. Está en escala de grises a 32 bits
;              con signo por canal.
;   - b:       La imagen origen B. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - depth_b: El mapa de profundidad de B. Está en escala de grises a 32 bits
;              con signo por canal.
;   - width:  El ancho en píxeles de todas las imágenes parámetro.
;   - height: El alto en píxeles de todas las imágenes parámetro.
global ej3b
ej3b:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits.
	;
	; r/m64 = rgba_t*  dst       RDI
	; r/m64 = rgba_t*  a         RSI
	; r/m64 = int32_t* depth_a   RDX
	; r/m64 = rgba_t*  b         RCX
	; r/m64 = int32_t* depth_b   R8
	; r/m32 = int      width     R9D
	; r/m32 = int      height    Pila (Rbp + 0x10) 

	push rbp
	mov rbp, rsp

	imul r9d, dword [rbp+0x10]

	xor r10, r10  ;iterador

	.ciclo:

		movdqu xmm0, [rsi] ; imagen a  
		movdqu xmm1, [rdx] ; profundidad de imagen a
	
		movdqu xmm2, [rcx] ; imagen b
        	movdqu xmm3, [r8] ; profundidad de imagen b

		PCMPGTD xmm3, xmm1 ; b > a xmm3 = Tiene 1s donde va a, y 0s donde va b
		
		pand xmm0, xmm3 ; xmm0 = los pixeles de a que me importan

		pandn xmm3, xmm2; xmm2 = Los pixeles de b que me importan
		
		por xmm0, xmm3

		movdqu [rdi], xmm0

		add rdi, 16
		add rsi, 16
		add rcx, 16
		add rdx, 16
		add r8, 16
		add r10d, 4

		cmp r10d, r9d
		jne .ciclo	
 	
	pop rbp
	ret
