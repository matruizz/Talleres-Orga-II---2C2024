#include "lista_enlazada.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>


lista_t* nueva_lista(void) {
  lista_t* l = malloc(sizeof(lista_t)); //Reservo memoria
  l->head = NULL;
  return l;
}

uint32_t longitud(lista_t* lista) {
  uint32_t res = 0;

  if(lista != NULL){ //Veo si el puntero es null
	  
    nodo_t* r = lista->head;
    
    while(r != NULL){
      res++;
      r = r->next;

    }
  }

  return res;
}

void agregar_al_final(lista_t* lista, uint32_t* arreglo, uint64_t longitud) {
 if(lista != NULL){
  nodo_t* new_nodo = malloc(sizeof(nodo_t));

  uint32_t* arregloCopia = malloc(longitud*sizeof(uint32_t));
  
  for(uint64_t i = 0; i< longitud; i++){
    arregloCopia[i] = arreglo[i];
  
  }
  
  new_nodo->next = NULL;
  new_nodo->longitud = longitud;
  new_nodo->arreglo = arregloCopia;

  nodo_t* r = lista->head;

  if(r != NULL){

    while(r->next != NULL){
      r = r->next;
    }

    r->next = new_nodo;
  } else{
      lista->head = new_nodo;
  }
 } 
}

nodo_t* iesimo(lista_t* lista, uint32_t i) {
  nodo_t* res = NULL;

  if(lista != NULL){
    res = lista->head;
    uint32_t j = 0;	

    while(j != i && res != NULL ){
    	res = res->next;
	j++;
    }
  }
 
  return res;
}

uint64_t cantidad_total_de_elementos(lista_t* lista) {
uint64_t cant = 0;

 if(lista != NULL){
  nodo_t* r = lista->head;
  while(r != NULL){
   cant = r->longitud + cant;
   r = r->next;
  }
 } 
 return cant;
}

void imprimir_lista(lista_t* lista) {

 if(lista != NULL){
  nodo_t* r = lista -> head;
  while(r != NULL){
   printf("|%lu| ->", r->longitud);
   r = r->next;
  }
 }
 printf(" null");
 }

// Función auxiliar para lista_contiene_elemento
int array_contiene_elemento(uint32_t* array, uint64_t size_of_array, uint32_t elemento_a_buscar) {

uint64_t it = 0;

int res = 0;

while(it < size_of_array && res != 1){
	if(array[it] == elemento_a_buscar){
	  res = 1;
	}
	it++;

}

return res;


} 

int lista_contiene_elemento(lista_t* lista, uint32_t elemento_a_buscar) {
 int res = 0;
 if(lista != NULL){
  nodo_t* r = lista->head;
  while(r != NULL && res != 1){
   res = array_contiene_elemento(r->arreglo, r->longitud, elemento_a_buscar);
   r = r->next;
  }
  }
 return res;
}


// Devuelve la memoria otorgada para construir la lista indicada por el primer argumento.
// Tener en cuenta que ademas, se debe liberar la memoria correspondiente a cada array de cada elemento de la lista.
void destruir_lista(lista_t* lista) {
 if(lista != NULL){
 nodo_t* r = lista -> head;
 while(r != NULL){
 nodo_t* tmp = r;
 r = r-> next;
 free(tmp->arreglo);
 free(tmp);
 }	 
 free(lista);
 }









}
