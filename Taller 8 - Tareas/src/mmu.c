/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Definicion de funciones del manejador de memoria
*/

#include "mmu.h"
#include "i386.h"

#include "kassert.h"

static pd_entry_t* kpd = (pd_entry_t*)KERNEL_PAGE_DIR;
static pt_entry_t* kpt = (pt_entry_t*)KERNEL_PAGE_TABLE_0;

static const uint32_t identity_mapping_end = 0x003FFFFF;
static const uint32_t user_memory_pool_end = 0x02FFFFFF;

static paddr_t next_free_kernel_page = 0x100000;
static paddr_t next_free_user_page = 0x400000;

/**
 * kmemset asigna el valor c a un rango de memoria interpretado
 * como un rango de bytes de largo n que comienza en s
 * @param s es el puntero al comienzo del rango de memoria
 * @param c es el valor a asignar en cada byte de s[0..n-1]
 * @param n es el tamaño en bytes a asignar
 * @return devuelve el puntero al rango modificado (alias de s)
*/
static inline void* kmemset(void* s, int c, size_t n) {
  uint8_t* dst = (uint8_t*)s;
  for (size_t i = 0; i < n; i++) {
    dst[i] = c;
  }
  return dst;
}

/**
 * zero_page limpia el contenido de una página que comienza en addr
 * @param addr es la dirección del comienzo de la página a limpiar
*/
static inline void zero_page(paddr_t addr) {
  kmemset((void*)addr, 0x00, PAGE_SIZE);
}


void mmu_init(void) {}


/**
 * mmu_next_free_kernel_page devuelve la dirección física de la próxima página de kernel disponible. 
 * Las páginas se obtienen en forma incremental, siendo la primera: next_free_kernel_page
 * @return devuelve la dirección de memoria de comienzo de la próxima página libre de kernel
 */
paddr_t mmu_next_free_kernel_page(void) {
  next_free_kernel_page = next_free_kernel_page + PAGE_SIZE;

  zero_page(next_free_kernel_page);

  return next_free_kernel_page - PAGE_SIZE;
}

/**
 * mmu_next_free_user_page devuelve la dirección de la próxima página de usuarix disponible
 * @return devuelve la dirección de memoria de comienzo de la próxima página libre de usuarix
 */
paddr_t mmu_next_free_user_page(void) {
  next_free_user_page = next_free_user_page + PAGE_SIZE;

  //zero_page(next_free_user_page);

  return next_free_user_page - PAGE_SIZE;
}

/**
 * mmu_init_kernel_dir inicializa las estructuras de paginación vinculadas al kernel y
 * realiza el identity mapping
 * @return devuelve la dirección de memoria de la página donde se encuentra el directorio
 * de páginas usado por el kernel
 */
paddr_t mmu_init_kernel_dir(void) {
  zero_page(KERNEL_PAGE_DIR); //Limpiamos la pagina del directorio
  zero_page(KERNEL_PAGE_TABLE_0); //Limpiamos la pagina de la tabla de paginas

  kpd[0].pt = (KERNEL_PAGE_TABLE_0 >> 12);        //Seteamos los atributos para la primera entrada del directorio
  kpd[0].attrs = 3;// (MMU_P | MMU_W); //Seteamos la dirección base de la tabla de páginas.

  for (int i = 0; i < 1024; i++)    //Realizamos el identity mapping
  {                                 //Las primeras 1024 entradas de la tabla de páginas apuntan
    kpt[i].attrs = 3;//(MMU_P | MMU_W); 
    kpt[i].page = i;
  }

  return KERNEL_PAGE_DIR;
}

/**
 * mmu_map_page agrega las entradas necesarias a las estructuras de paginación de modo de que
 * la dirección virtual virt se traduzca en la dirección física phy con los atributos definidos en attrs
 * @param cr3 el contenido que se ha de cargar en un registro CR3 al realizar la traducción
 * @param virt la dirección virtual que se ha de traducir en phy
 * @param phy la dirección física que debe ser accedida (dirección de destino)
 * @param attrs los atributos a asignar en la entrada de la tabla de páginas
 */
void mmu_map_page(uint32_t cr3, vaddr_t virt, paddr_t phy, uint32_t attrs) {

  pd_entry_t* pd = (pd_entry_t*) CR3_TO_PAGE_DIR(cr3);

  uint32_t dIndex = VIRT_PAGE_DIR(virt);
  uint32_t tIndex = VIRT_PAGE_TABLE(virt);

  //Tiene que ser asi por que no exite la asignacion del tipo pd_entry_t
  pd_entry_t* pde = &pd[dIndex];

  if ( (pde->attrs & MMU_P) != 1)
  {
    pde->pt = (mmu_next_free_kernel_page() >> 12);
  }

  pde->attrs = (attrs | MMU_P);

  pt_entry_t* pTable = (pt_entry_t*) (pde->pt << 12);

  pTable[tIndex].attrs = (attrs | MMU_P);
  pTable[tIndex].page = (phy >> 12);

  tlbflush();
}

/**
 * mmu_unmap_page elimina la entrada vinculada a la dirección virt en la tabla de páginas correspondiente
 * @param virt la dirección virtual que se ha de desvincular
 * @return la dirección física de la página desvinculada
 */
paddr_t mmu_unmap_page(uint32_t cr3, vaddr_t virt) {

  pd_entry_t* pd = (pd_entry_t*) CR3_TO_PAGE_DIR(cr3);

  uint32_t dIndex = VIRT_PAGE_DIR(virt);
  uint32_t tIndex = VIRT_PAGE_TABLE(virt);

  pd_entry_t pde = pd[dIndex];
 
  pt_entry_t* pt = (pt_entry_t*) MMU_ENTRY_PADDR(pde.pt);

  pt[tIndex].attrs = 0;

  tlbflush();

  return MMU_ENTRY_PADDR(pt[tIndex].page);
}

#define DST_VIRT_PAGE 0xA00000
#define SRC_VIRT_PAGE 0xB00000

/**
 * copy_page copia el contenido de la página física localizada en la dirección src_addr a la página física ubicada en dst_addr
 * @param dst_addr la dirección a cuya página queremos copiar el contenido
 * @param src_addr la dirección de la página cuyo contenido queremos copiar
 *
 * Esta función mapea ambas páginas a las direcciones SRC_VIRT_PAGE y DST_VIRT_PAGE, respectivamente, realiza
 * la copia y luego desmapea las páginas. Usar la función rcr3 definida en i386.h para obtener el cr3 actual
 */
void copy_page(paddr_t dst_addr, paddr_t src_addr) {

  uint32_t cr3 = rcr3();

  mmu_map_page(cr3, SRC_VIRT_PAGE, src_addr, MMU_P);
  mmu_map_page(cr3, DST_VIRT_PAGE, dst_addr, (MMU_P | MMU_W));

  vaddr_t* fuente = (vaddr_t*) SRC_VIRT_PAGE;
  vaddr_t* destino = (vaddr_t*) DST_VIRT_PAGE;

  for (uint32_t i = 0; i < 1024; i++)
  {
    destino[i] = fuente[i];
  }

  //MMU_UNMAP_PAGE ya hace los tblflush()
  mmu_unmap_page(cr3, DST_VIRT_PAGE);
  mmu_unmap_page(cr3, SRC_VIRT_PAGE);

  tlbflush();
}

 /**
 * mmu_init_task_dir inicializa las estructuras de paginación vinculadas a una tarea cuyo código se encuentra en la dirección phy_start
 * @pararm phy_start es la dirección donde comienzan las dos páginas de código de la tarea asociada a esta llamada
 * @return el contenido que se ha de cargar en un registro CR3 para la tarea asociada a esta llamada
 */
paddr_t mmu_init_task_dir(paddr_t phy_start) {

  paddr_t cr3 = mmu_next_free_kernel_page();

  //zero_page(cr3);

  //Identity mapping
  for (int i = 0; i < 1024; i++)
  {
    mmu_map_page(cr3, (i << 12), (i << 12), MMU_P | MMU_W);
  }

  //Mapeo de 2 paginas de codigo
  mmu_map_page(cr3, TASK_CODE_VIRTUAL, phy_start, MMU_P | MMU_U);
  mmu_map_page(cr3, TASK_CODE_VIRTUAL + PAGE_SIZE, phy_start + PAGE_SIZE, MMU_P | MMU_U);


  paddr_t stackBasePhy = mmu_next_free_user_page();
  //zero_page(stackBasePhy);
  mmu_map_page(cr3, TASK_STACK_BASE - PAGE_SIZE, stackBasePhy, MMU_P | MMU_W | MMU_U);


  paddr_t sharedBasePhy = mmu_next_free_user_page();
  //zero_page(sharedBasePhy);
  mmu_map_page(cr3, TASK_SHARED_PAGE, sharedBasePhy, MMU_P | MMU_U);

  return cr3;
}

// COMPLETAR: devuelve true si se atendió el page fault y puede continuar la ejecución 
// y false si no se pudo atender
bool page_fault_handler(vaddr_t virt) {
  print("Atendiendo page fault...", 0, 0, C_FG_WHITE | C_BG_BLACK);
  // Chequeemos si el acceso fue dentro del area on-demand
  if ((ON_DEMAND_MEM_START_VIRTUAL <= virt) && (ON_DEMAND_MEM_END_VIRTUAL >= virt))
  {
    // En caso de que si, mapear la pagina
    uint32_t cr3 = rcr3();
    paddr_t phy = mmu_next_free_user_page();
    mmu_map_page(cr3, virt, phy, MMU_U | MMU_P | MMU_W);
    return true;
  }else{
    return false;
  }
}
