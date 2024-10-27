/* ** por compatibilidad se omiten tildes **
==============================================================================
TALLER System Programming - Arquitectura y Organizacion de Computadoras - FCEN
==============================================================================

  Definicion de funciones de impresion por pantalla.
*/

#include "screen.h"

void print(const char* text, uint32_t x, uint32_t y, uint16_t attr) {
  ca(*p)[VIDEO_COLS] = (ca(*)[VIDEO_COLS])VIDEO; 
  int32_t i;
  for (i = 0; text[i] != 0; i++) {
    p[y][x].c = (uint8_t)text[i];
    p[y][x].a = (uint8_t)attr;
    x++;
    if (x == VIDEO_COLS) {
      x = 0;
      y++;
    }
  }
}

void print_dec(uint32_t numero, uint32_t size, uint32_t x, uint32_t y,
               uint16_t attr) {
  ca(*p)[VIDEO_COLS] = (ca(*)[VIDEO_COLS])VIDEO; 
  uint32_t i;
  uint8_t letras[16] = "0123456789";

  for (i = 0; i < size; i++) {
    uint32_t resto = numero % 10;
    numero = numero / 10;
    p[y][x + size - i - 1].c = letras[resto];
    p[y][x + size - i - 1].a = attr;
  }
}

void print_hex(uint32_t numero, int32_t size, uint32_t x, uint32_t y,
               uint16_t attr) {
  ca(*p)[VIDEO_COLS] = (ca(*)[VIDEO_COLS])VIDEO; 
  int32_t i;
  uint8_t hexa[8];
  uint8_t letras[16] = "0123456789ABCDEF";
  hexa[0] = letras[(numero & 0x0000000F) >> 0];
  hexa[1] = letras[(numero & 0x000000F0) >> 4];
  hexa[2] = letras[(numero & 0x00000F00) >> 8];
  hexa[3] = letras[(numero & 0x0000F000) >> 12];
  hexa[4] = letras[(numero & 0x000F0000) >> 16];
  hexa[5] = letras[(numero & 0x00F00000) >> 20];
  hexa[6] = letras[(numero & 0x0F000000) >> 24];
  hexa[7] = letras[(numero & 0xF0000000) >> 28];
  for (i = 0; i < size; i++) {
    p[y][x + size - i - 1].c = hexa[i];
    p[y][x + size - i - 1].a = attr;
  }
}

/*
Que carajos es P!!!!!!!
segun entiendo p es un arreglo de punteros a variables de tipo ca por lo tanto
p == un numero n
ese numero es una direccion de memoria en la que esta almacenada puntero de tipo ca
es decir p[i] == el iesimo puntero a ca de p
p[i][j] == el j-esimo puntero a ca de p[i]???
lo que me confunde es como podes tener algo que a primera vista parece ser una cosa de
2 dimensiones habiendo declarado algo de solo una dimesion.
*/
void screen_draw_box(uint32_t fInit, uint32_t cInit, uint32_t fSize,
                     uint32_t cSize, uint8_t character, uint8_t attr) {
  ca(*p)[VIDEO_COLS] = (ca(*)[VIDEO_COLS])VIDEO;  //p == puntero a un array de 80 elementos de tipo ca
  uint32_t f;
  uint32_t c;
  for (f = fInit; f < fInit + fSize; f++) {
    for (c = cInit; c < cInit + cSize; c++) {
      p[f][c].c = character;
      p[f][c].a = attr;
    }
  }
}
/*
cada puntero apunta a un byte en especifico
por ejemplo:
int x = 10;
int *p = &x;
Aca p es un puntero decimos que apunta a x pero esta implicito que:
p tiene la direccion de memoria del primer byte que ocupa x (sin importar el tama;o de x)
Ahora como en este caso x es un int entonces sabemos que x tiene un tama;o de 4 bytes
luego si 
int *q = (p + 1)
entonces q es un puntero a int que simplemente es una variable que tiene guardado un numero
que representa la posicion de memoria en la que esta guardado el primer byte de p + 1,
esto implica que al hacer p + 1 la direccion de memoria a la que accedemos no es 
posicion de memoria de p + 1,  sino que en realidad estamos accediendo a posicion de memoria
de p + (1 * tama;o de elementos apuntados por p) que en este caso es p + 4
por lo tanto...
como p es un puntero a array de 80 elementos 
p es una posiscion de memeoria etiquetada con la etiqueta p que tiene guardada un numero que 
representa la posicion de memoria en donde esta guardada en primer ca de un array de 80 ca
y si hacemos p[i] lo que estamos haciendo es acceder a:
posicion apuntada por p + i * tama;o de cosas apuntadas por p, que en este caso es
p + (i * (80 * tama;o de ca)) == p + (i * 80 * 2)
*/

void screen_draw_layout(void) {
  screen_draw_box(0, 0, 50, 80, ' ', 5);
  print("-Dammy.", 25, 20, 5);
  print("-Santi.", 25, 21, 5);
  print("-Mateo.", 25, 22, 5);
}