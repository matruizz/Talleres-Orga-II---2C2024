# System Programming: Paginación.

En este taller vamos a inicializar y a habilitar los mecanismos de
manejo de memoria de nuestro kernel. En particular, activaremos el
módulo de paginación del microprocesador

## Organización de la memoria 

Primero vamos a explicar cómo se encuentra el mapa de memoria física
para comprender de qué modo inicializar las tablas de memoria. El primer
MB de memoria física será organizado según indica la figura
[1].
En la misma se observa que a partir de la dirección `0x1200` se
encuentra ubicado el *kernel*; inmediatamente después se ubica el código
de las tareas A y B. A continuación se encuentra el código de la tarea
Idle. El resto del mapa muestra el rango para la pila del kernel, desde
`0x24000` y a continuación la tabla y directorio de páginas donde
inicializar paginación para el kernel. La parte derecha de la figura
muestra la memoria a partir de la dirección `0xA0000`, donde se
encuentra mapeada la memoria de vídeo y el código del `BIOS`.

![Mapa de la organización de la memoria física del *kernel*](img/mapa_fisico.png)

## Unidad de Manejo de Memoria

Ya viendo la memoria física en forma más general, vemos que se divide
en: *kernel*, *área libre kernel* y *área libre tareas*.

El área asociada al *kernel* corresponde al primer MB de memoria, el
*área libre kernel* a los siguientes 3 MB, y el *área libre tareas*
comienza en el cuarto MB de memoria.

La administración de las áreas libres de memoria (área libre de kernel y
área libre de tareas) se realizará a partir de una región de memoria
específica para cada una. Podemos comprenderlas como un arreglo
predefinido de páginas y dos contadores de páginas, uno para kernel y
otro para usuarix, que indican cuál será la próxima página a emplear de
cada región. Para páginas de kernel el arreglo va de `0x100000` a
`0x3FFFFF` y para páginas de usuarix de `0x400000` a `0x2FFFFFF`. Luego
de cada pedido incrementamos el contador correspondiente. Para el
contexto de la materia no implementamos un mecanismo que permita liberar
las páginas pedidas. Vamos a referirnos al módulo que implementa este
mecanismo como la **unidad de manejo de memoria**, o en inglés, *memory
management unit*, MMU.

Las páginas del *área libre kernel* serán utilizadas para datos del
kernel: directorios de páginas, tablas de páginas y pilas de nivel cero.
Las páginas del *área libre tareas* serán utilizadas para datos de las
tareas, stack de las mismas y memoria compartida bajo demanda.

![Mapa de memoria de la tarea](img/tarea.png)

La memoria virtual de cada una de las tareas tiene mapeado inicialmente
el *kernel* y el *área libre kernel* con *identity mapping* en nivel 0.
Además se mapearán las páginas de código correspondientes, la página de
memoria compartida y una página para la pila obtenida desde el *área
libre de tareas*.

A partir de la dirección virtual *0x07000000* se encontrará una página
de memoria compartida de lectura y escritura nivel 3. Esta página será
mappeada on-demand cuando se intente hacer una lectura o escritura en
este espacio. La página física debe encontrarse en la dirección
*0x03000000*.

El código de las tareas se encontrará a partir de la dirección virtual
*0x08000000* y será mapeado como sólo lectura de nivel 3 a la dirección
física del código correspondiente. Cada tarea puede utilizar hasta 8Kb
de código. El stack será mapeado en la página siguiente, con permisos de
lectura y escritura. La página física debe obtenerse del *área libre de
tareas*. Finalmente, luego de la pila se mapeará la página de memoria
compartida como sólo lectura de nivel 3. Esta página la usaremos más
adelante para que las tareas puedan acceder fácilmente a información
relevante del contexto de ejecución (teclas apretadas, tiempo desde el
arranque del sistema, etc).

### Notas 

- Por construcción del *kernel*, las direcciones de los mapas de memoria (`page directory` y `page table`) están mapeadas con *identity mapping*.

- En las funciones en donde se modifica el directorio o tabla de páginas, se debe llamar a la función `tlbflush` para que se invalide la *cache* de traducción de direcciones.

### Uso de qemu+gdb 

A continuación una descripción de los comandos que pueden utilizar en
gdb para acceder a la información sobre el mapeo de páginas:

-   `info page` - muestra información general sobre el mapeo

-   `info page [vaddr]` - muestra la traducción de *vaddr* dando el detalle de las entradas PD y PT correspondientes

-   `info page directory` - lista las entradas presentes del PD actual con sus atributos

-   `info table [idx]` - lista las entradas presentes de la i-ésima page table

-   `x /nuf [addr]` - Muestra el contenido de la dirección `[addr]`

-   `xp /nuf [addr]` - Muestra el contenido de la dirección física `[addr]`\
    `n` es el número que indica cuantos valores se mostrarán (default 1)\
    `u` es el tamaño de la unidad, puede ser[^1]:

      ------------------------ ----------------------------
      `b : byte`               `h : word (half-word)`
      `w : doubleword(word)`   `g : quadword(giant word)`
      ------------------------ ----------------------------

    `f` es el formato del número, puede ser:

      ------------- ------------------- -----------------
      `x : hex`     `d : decimal`       `u : sin signo`
      `o : octal`   `t : binario`       `c : char`
      `s : ascii`   `i : instrucción`   
      ------------- ------------------- -----------------

[^1]: Entre paréntesis el nombre consistente con gdb

## Ejercicios

### Primera parte: Preguntas teoricas 

a)  ¿Cuántos niveles de privilegio podemos definir en las estructuras de
    paginación?
Existen dos niveles de privilegio; de kernel (0) y de usuario (1)
b)  ¿Cómo se traduce una dirección lógica en una dirección física? ¿Cómo
    participan la dirección lógica, el registro de control `CR3`, el
    directorio y la tabla de páginas? Recomendación: describan el
    proceso en pseudocódigo

En primer lugar, la dirección logica se traduce a direccion lineal a través de la unidad de segmentación (lo hecho en el taller de segmentación) y luego se agarra la dirección lineal en la cual a partir de los 10 bits mas significativos se busca la ubicacion de la tabla de paginas en el directorio (cuya dirección la conocemos ya que se encuentra ubicada en los 20 bits mas significativos del registro CR3). Luego los siguientes 10 bits indican la ubicación de la direccion base de la pagina en la tabla de paginas. Finalmente los 12 bits mas bajos indican el offset donde esta la dirección fisica. 

c)  ¿Cuál es el efecto de los siguientes atributos en las entradas de la
    tabla de página?

  - `D`: Indica si la pagina ha sido modificada
  - `A`: Indica si la pagina ha sido accedida
  - `PCD`: Deshabilita su escritura en el cache 
  - `PWT`: Habilita la escritura de todos los niveles del cache 
  - `U/S`: Indica el privilegio de la pagina donde 0 corresponde al kernel y 1 a usuario.
  - `R/W`: Indica si la pagina es Read Only o de escritura. 
  - `P`: Si la pagina esta presente en memoria


d)  ¿Qué sucede si los atributos U/S y R/W del directorio y de la tabla
    de páginas difieren? ¿Cuáles terminan siendo los atributos de una
    página determinada en ese caso? Hint: buscar la tabla *Combined
    Page-Directory and Page-Table Protection* del manual 3 de Intel

En el caso de que el directorio de paginas y la tabla de paginas sean nivel usuario, el access type sera solo de lectura si alguno de los access types del directiorio de paginas y de la pagina en sí es solo de lectura. El unico caso en el que sea de lectura/escritura sera aquel en el que tanto el directorio de pagina como la tabla de pagina sean de lectura y escritura.
Luego, en el caso en el que interactuen directorios y tablas de pagina con distinto privilegio, sera de lectura y escritura si y solo si tanto el directorio de pagina como la tabla de pagina estan en modo lectura/escritura. En otros casos, donde lo anterior no sucede, el access type sera de lectura y escritura bajo el requerimiento de que la flag WP del registro CR0 este en 0, en caso de que este en 1, dicho access type dependera de los flags de la tabla de paginas y el directorio. 


e)  Suponiendo que el código de la tarea ocupa dos páginas y
    utilizaremos una página para la pila de la tarea. ¿Cuántas páginas
    hace falta pedir a la unidad de manejo de memoria para el
    directorio, tablas de páginas y la memoria de una tarea?

Necesitaremos un total de 5 paginas, una pagina para el directorio de paginas, luego una pagina para la tabla de paginas, y finalmente 3 paginas para la tarea y la pila

f)  Completen las entradas referentes a MMU de `defines.h` y comprendan
    la función y motivación de dichos defines:

  - `VIRT_PAGE_DIR(X)`: Dada `X` una dirección virtual calcula el índice dentro del directorio de páginas de la PDE asociada.

  - `VIRT_PAGE_TABLE(X)`: Dada `X` una dirección virtual calcula el índice dentro de la tabla de páginas de la PTE asociada.

  - `VIRT_PAGE_OFFSET(X)`: Dada `X` una dirección devuelve el offset dentro de su página.

  - `CR3_TO_PAGE_DIR(X)`: Obtiene la dirección física del directorio donde `X` es el contenido del registro `CR3`.

  - `MMU_ENTRY_PADDR(X)`: Obtiene la dirección física correspondiente, donde `X` es el campo address de 20 bits en una entrada de la tabla de páginas o del page directory

g)  ¿Qué es el buffer auxiliar de traducción (*translation lookaside
    buffer* o **TLB**) y por qué es necesario purgarlo (`tlbflush`) al
    introducir modificaciones a nuestras estructuras de paginación
    (directorio, tabla de páginas)? ¿Qué atributos posee cada traducción
    en la TLB? Al desalojar una entrada determinada de la TLB ¿Se ve
    afectada la homóloga en la tabla original para algún caso?

El TLB es una estructura de memoria donde se guardan las ultimas traducciones de dirección lineal a fisica las cuales son los accesos a las paginas que se están usando en el momento (como una cache). Es necesario purgarlo ya que el CR3 se ocupa de una tarea dada y las traducciones guardadas podran ya no ser relevantes para la tarea actual (con excepcion de las entradas globales). Posee los bits que corresponden al directorio y tabla de acceso al DTP y PT, y la dirección fisica base del descriptor de la pagina y los bits de control. Se ve afectada en el caso de que este activado el bit Dirty de   






### Segunda parte: Activando el mecanismo de paginación.

a)  Escriban el código de las funciones `mmu_next_free_kernel_page`,
    `mmu_next_free_user_page` y de `mmu_init_kernel_dir` de `mmu.c` para
    completar la inicialización del directorio y tablas de páginas para
    el *kernel*.

  > Recuerden que las entradas del directorio y la tabla deben realizar un mapeo por identidad (las direcciones lineales son iguales a las direcciones físicas) para el rango reservado para el kernel, de `0x00000000` a `0x003FFFFF`, como ilustra la figura [2]. Esta función debe inicializar también el directorio de páginas en la dirección `0x25000` y las tablas de páginas según muestra la figura [1] ¿Cuántas entradas del directorio de página hacen falta?

b)  Completar el código para activar paginación en `kernel.asm`.
    Recuerden que es necesario inicializar el registro `CR3` y activar
    el bit correspondiente de CR0. Esta inicialización debe realizarse
    antes de activar las interrupciones del procesador.

c)  Introduzcan un breakpoint luego de activar paginación y prueben
    hacer **info page** para comprobar que el mapeo identidad se realizó
    correctamente.

### Tercera parte: Definiendo la MMU.

a)  Completen el código de la función `mmu_map_page`, `mmu_unmap_page`

b)  Completen el código de `copy_page`, ¿por qué es necesario mapear y
    desmapear las páginas de destino y fuente? ¿Qué función cumplen
    `SRC_VIRT_PAGE` y `DST_VIRT_PAGE`? ¿Por qué es necesario obtener el
    CR3 con rcr3()?

    Es necesario mapear y desmapear las paginas que queremos usar porque el kernel tiene encendida la paginación por lo que para trabajar con los contenidos de direcciones fisicas tenemos que utilizar direcciones virtuales que esten mapeadas a las físicas. SRC_VIRT_PAGE y DST_VIRT_PAGE cumplen la función de direcciones virtuales auxiliares que nos permiten hacer el mapeo a las direcciones físicas. Nesecitamos el cr3 actual para tener la dirección del derectorio de tabla de páginas de la tarea actual.

c)  Realicen una prueba donde se compruebe el funcionamiento de
    `copy_page`. Pueden usar gdb con el comando `x` para inspeccionar el
    contenido de direcciones virtuales y `xp` para inspeccionar el
    contenido de direcciones físicas.

d)  Completen la rutina (`mmu_init_task_dir`|) encargada de inicializar
    un directorio de páginas y tablas de páginas para una tarea,
    respetando la figura [2]. La rutina debe mapear las páginas de
    código como solo lectura, a partir de la dirección virtual
    `0x08000000`, el stack como lectura-escritura con base en
    `0x08003000` y la página de memoria compartida luego del stack.
    Recuerden que la memoria para la pila de la tarea debe obtenerse del
    area libre de tareas.

e)  Completen la rutina de atención de interrupción del Page Fault para
    que, si se intenta acceder al rango de memoria compartido on demand
    cuando este no está mapeado, se mapee. Respeten la figura
    [2]. Se debe mapear como de lectura-escritura a nivel usuario.

f)  A modo de prueba, en `kernel.asm` vamos a construir un mapa de
    memoria para una tarea ficticia (es decir, cargar el `CR3` de una
    tarea) e intercambiarlo con el del *kernel*. Para esto tendrán que
    usar la función antes construida, `mmu_init_task_dir`. Supongan que
    la tarea se encuentra ubicada en la dirección física 0x18000.

  - Una vez hecho el cambio de cr3, hagan dos escrituras en alguna
    parte de la zona de memoria compartida on-demand y luego vuelvan
    a la normalidad. Deberían ver el mensaje
    `”Atendiendo Page Fault...”` luego de la primer escritura y
    ningún mensaje luego de la segunda.

  - Inspeccionen el mapa de memoria con el comando `info page` con
    breakpoints una vez que se asigna el `CR3` de la tarea y cuando
    se restituye el `CR3` del kernel.
