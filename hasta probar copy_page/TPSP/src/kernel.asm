; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TALLER System Programming - Arquitectura y Organizacion de Computadoras - FCEN
; ==============================================================================

%include "print.mac"
global start


; COMPLETAR - Agreguen declaraciones extern según vayan necesitando
extern GDT_DESC

extern screen_draw_layout
extern screen_draw_box

extern idt_init
extern IDT_DESC

extern pic_reset
extern pic_enable

extern mmu_init_kernel_dir

extern mmu_map_page
extern copy_page
extern DST_VIRT_PAGE


; COMPLETAR - Definan correctamente estas constantes cuando las necesiten
%define CS_RING_0_SEL 8
%define DS_RING_0_SEL 0b0000000000011000


BITS 16
;; Saltear seccion de datos
jmp start

;;
;; Seccion de datos.
;; -------------------------------------------------------------------------- ;;
start_rm_msg db     'Iniciando kernel en Modo Real'
start_rm_len equ    $ - start_rm_msg

start_pm_msg db     'Iniciando kernel en Modo Protegido'
start_pm_len equ    $ - start_pm_msg

;;
;; Seccion de código.
;; -------------------------------------------------------------------------- ;;

;; Punto de entrada del kernel.
BITS 16
start:
    ; COMPLETAR - Deshabilitar interrupciones
    cli

    ; Cambiar modo de video a 80 X 50
    mov ax, 0003h
    int 10h ; set mode 03h
    xor bx, bx
    mov ax, 1112h
    int 10h ; load 8x8 font


    ;Impriman el mensaje de bienvenida a modo protegido e inserten breakpoint en la instrucción siguiente

    ; COMPLETAR - Imprimir mensaje de bienvenida - MODO REAL
    ; (revisar las funciones definidas en print.mac y los mensajes se encuentran en la
    ; sección de datos)
    print_text_rm start_rm_msg, start_rm_len, 0b00000111, 20, 25

    ; COMPLETAR - Habilitar A20
    ; (revisar las funciones definidas en a20.asm)
    call A20_enable

    ; COMPLETAR - Cargar la GDT
    lgdt [GDT_DESC]


    ; COMPLETAR - Setear el bit PE del registro CR0
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; COMPLETAR - Saltar a modo protegido (far jump)
    ; (recuerden que un far jmp se especifica como jmp CS_selector:address)
    ; Pueden usar la constante CS_RING_0_SEL definida en este archivo
    jmp CS_RING_0_SEL:modo_protegido
BITS 32
modo_protegido:
    ; COMPLETAR - A partir de aca, todo el codigo se va a ejectutar en modo protegido
    ; Establecer selectores de segmentos DS, ES, GS, FS y SS en el segmento de datos de nivel 0
    ; Pueden usar la constante DS_RING_0_SEL definida en este archivo
    mov ax, DS_RING_0_SEL
    mov ds, ax
    mov es, ax
    mov gs, ax
    mov fs, ax
    mov ss, ax


    ; COMPLETAR - Establecer el tope y la base de la pila
    mov ebp, 0x25000
    mov esp, 0x25000

    ; COMPLETAR - Imprimir mensaje de bienvenida - MODO PROTEGIDO
    print_text_pm start_pm_msg, start_pm_len, 0b00000111, 20, 25

    ; COMPLETAR - Inicializar pantalla
    ;call screen_draw_box ;Faltan los parametros

    call screen_draw_layout
    
   
    ; Inicializar el directorio de paginas
    call mmu_init_kernel_dir    ;eax = direccion fisica del directorio de paginas


    ; Cargar directorio de paginas
    mov cr3, eax


    ; Habilitar paginacion
    mov eax, (0x1 << 31)
    mov edx, cr0
    or edx, eax
    mov cr0, edx


    ; COMPLETAR - Inicializar y cargar la IDT
    call idt_init
    lidt [IDT_DESC]


    ; COMPLETAR - Reiniciar y habilitar el controlador de interrupciones
    call pic_reset
    call pic_enable


    ; COMPLETAR - Habilitar interrupciones
    sti
    ; NOTA: Pueden chequear que las interrupciones funcionen forzando a que se
    ;       dispare alguna excepción (lo más sencillo es usar la instrucción
    ;       `int3`)
    ;int3

    ; Probar Sys_call
    int 88
    int 98

    ; Probar generar una excepción
    ;int 4 

    ;Probamos reloj:
    int 32
    ;int 33


    xor ecx, ecx
    xor edx, edx
    xor esi, esi
    xor edi, edi

    mov ecx, cr3
    mov edx, 0x4
    mov esi, 0x200000
    mov edi, 3

    push ecx
    push edx
    push esi
    push edi

    ;void mmu_map_page(uint32_t cr3, vaddr_t virt, paddr_t phy, uint32_t attrs)
    call mmu_map_page

    pop edi
    pop esi
    pop edx
    pop ecx

    ;Escribo cualquier cosa en una direccion cualquiera dentro del area libre del kernel
    mov [0x200000], DWORD 99

    xor ecx, ecx
    xor edx, edx
    mov ecx, 0x200000
    mov edx, 0x300000

    push ecx
    push edx
    call copy_page
    pop edx
    pop ecx

    ; Inicializar el directorio de paginas de la tarea de prueba
    ; Cargar directorio de paginas de la tarea
    ; Restaurar directorio de paginas del kernel

    ; Ciclar infinitamente 
    mov eax, 0xFFFF
    mov ebx, 0xFFFF
    mov ecx, 0xFFFF
    mov edx, 0xFFFF
    jmp $

;; -------------------------------------------------------------------------- ;;

%include "a20.asm"
