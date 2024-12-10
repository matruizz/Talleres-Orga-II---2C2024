; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TALLER System Programming - Arquitectura y Organizacion de Computadoras - FCEN
; ==============================================================================

%include "print.mac"

global start

;Agreguen declaraciones extern según vayan necesitando
;Pasaje a modo protegido
extern GDT_DESC
extern screen_draw_layout

;Interrupciones
extern idt_init
extern IDT_DESC
extern pic_reset
extern pic_enable

;Paginacion
extern mmu_init_kernel_dir
extern copy_page
extern mmu_init_task_dir

;Tareas
extern tss_init
extern tasks_screen_draw
extern sched_init
extern tasks_init

;Definan correctamente estas constantes cuando las necesiten
%define CS_RING_0_SEL (1 << 3)
%define DS_RING_0_SEL (3 << 3)
%define INIT_RING_0_SEL (11 << 3)
%define IDLE_RING_0_SEL (12 << 3)


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
    ;;Deshabilitar interrupciones
    cli ;Pone un 0 en el bit 9 (if) del registro EFLAGS lo que desactiva la respuesta a interrupciones de hardware.
        ;sti hace lo contrario

    ; Cambiar modo de video a 80 X 50
    mov ax, 0003h
    int 10h ; set mode 03h
    xor bx, bx
    mov ax, 1112h
    int 10h ; load 8x8 font

    ;Imprimir mensaje de bienvenida - MODO REAL
    ; (revisar las funciones definidas en print.mac y los mensajes se encuentran en la
    ; sección de datos)
    print_text_rm start_rm_msg, start_rm_len, 5, 25, 25

    ;Habilitar A20
    ; (revisar las funciones definidas en a20.asm)
    call A20_enable

    ;Cargar la GDT
    lgdt [GDT_DESC]

    ;Setear el bit PE del registro CR0
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax

    ;Saltar a modo protegido (far jump)
    ; (recuerden que un far jmp se especifica como jmp CS_selector:address)
    ; Pueden usar la constante CS_RING_0_SEL definida en este archivo
    jmp CS_RING_0_SEL:modo_protegido
BITS 32
modo_protegido:
    ;A partir de aca, todo el codigo se va a ejectutar en modo protegido
    ; Establecer selectores de segmentos DS, ES, GS, FS y SS en el segmento de datos de nivel 0
    ; Pueden usar la constante DS_RING_0_SEL definida en este archivo
    mov ax, DS_RING_0_SEL
    mov ds, ax
    mov es, ax
    mov gs, ax
    mov fs, ax
    mov ss, ax

    ;Establecer el tope y la base de la pila
    mov ebp, 0x25000
    mov esp, 0x25000

    ;Imprimir mensaje de bienvenida - MODO PROTEGIDO
    print_text_pm start_pm_msg, start_pm_len, 5, 26, 25

    ;Inicializar pantalla
    call screen_draw_layout
   
    ; Inicializar el directorio de paginas
    call mmu_init_kernel_dir

    ; Cargar directorio de paginas
    mov ecx, cr3
    or eax, ecx
    mov cr3, eax

    ; Habilitar paginacion
    xor eax, eax
    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax

    ; Inicializar tss
    call tss_init       ;Carga a la gdt los descriptores de tss de la tarea inicial y idle

    ; Inicializar el scheduler
    call sched_init     ;Inicializa el scheduler == arreglo de entradas de sched_entry_t a slot_free

    ; Inicializar las tareas
    call tasks_init     ;Crea 4 tareas de 2 tipos y las deja en estado runnable en el scheduler

    ;Inicializar y cargar la IDT
    call idt_init   ;Inicializamos la idt
    lidt [IDT_DESC] ;Cargamos el descriptor de idt en el registro idtr

    ;Reiniciar y habilitar el controlador de interrupciones
    call pic_reset
    call pic_enable

    ; Cargar tarea inicial
    call tasks_screen_draw  ;Dibuja marcos y titulos inciales de la interfaz del sistema

    mov ax, INIT_RING_0_SEL ;Cargamos en ax el selector de tss de la tarea inicial
    ltr ax                  ;Cargamos el tr con el seletor de tss de la tarea inicial

    ;Habilitar interrupciones
    sti

    ; NOTA: Pueden chequear que las interrupciones funcionen forzando a que se
    ;       dispare alguna excepción (lo más sencillo es usar la instrucción
    ;       `int3`)
    ;int3

    ; Probar Sys_call
    int 88  ;Escribe un 88 en el eax
    int 98  ;Escribe un 98 en el eax

    ; Probar generar una excepción

    ;Prueba de copy_page
    ;Para probar esto utilizo paginas que estan identity mapeadas para poder acceder a ellas facilmente para escribir
    ;Antes de llamar a copyPage y tambien para leer el destino al final
    ;mov [0x200000], DWORD 123456789
    ;push DWORD 0x200000
    ;push DWORD 0x300000
    ;call copy_page  ;Para probar lo de tareas
    ;add esp, 0x8

    ; Inicializar el directorio de paginas de la tarea de prueba
    ;push DWORD 0x18000    ;CR3 para tarea ficticia
    ;call mmu_init_task_dir  ;Inicializamos las estructuras de memoria de la tarea ficticia
    ;add esp, 0x4

    ; Cargar directorio de paginas de la tarea
    ;mov cr3, eax

    ; Restaurar directorio de paginas del kernel
    ;mov eax, 0x25000
    ;mov cr3, eax    ;Recupero el cr3

    ; Saltar a la primera tarea: Idle
    jmp IDLE_RING_0_SEL:0


    ; Ciclar infinitamente 
    mov eax, 0xFFFF
    mov ebx, 0xFFFF
    mov ecx, 0xFFFF
    mov edx, 0xFFFF
    jmp $

;; -------------------------------------------------------------------------- ;;

%include "a20.asm"
