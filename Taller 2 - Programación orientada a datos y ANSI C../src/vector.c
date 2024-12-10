#include "vector.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


vector_t* nuevo_vector(void) {
    vector_t* v = malloc(sizeof(vector_t));
    v->capacity = 2;
    v->size = 0;
    v->array = malloc(2*sizeof(uint32_t));

    return v; 
}

uint64_t get_size(vector_t* vector) {
    if(vector == NULL){
        return 0;
    }

    return vector->size;

}

void push_back(vector_t* vector, uint32_t elemento) {
    if(vector != NULL){
        
        if(vector->size == vector->capacity){
            vector->array = realloc(vector->array, sizeof(uint32_t) * (2*vector->capacity) );
            vector->capacity = vector->capacity * 2;
        } 

        vector->array[vector->size] = elemento;
        vector->size++;
    }
}

int son_iguales(vector_t* v1, vector_t* v2) {
    if ((v1 == NULL) || (v2 == NULL) )
    {
        return 0;
    }
    
    if ((v1->size == v2->size))
    {
        for (uint64_t i = 0; i < v1->size; i++)
        {
            if (v1->array[i] != v2->array[i])
            {
                return 0;
            }
        }

        return 1;
    }
    return 0;
}

uint32_t iesimo(vector_t* vector, size_t index) {
    if (index >= vector->size)
    {
        return 0;
    }
    return vector->array[index];
}

void copiar_iesimo(vector_t* vector, size_t index, uint32_t* out)
{
    if(vector != NULL)
    {
        *out = iesimo(vector, index);
    }
}


// Dado un array de vectores, devuelve un puntero a aquel con mayor longitud.
vector_t* vector_mas_grande(vector_t** array_de_vectores, size_t longitud_del_array) {
 if(array_de_vectores == NULL || longitud_del_array == 0){
  return NULL;
 }
 uint64_t max = 0;
 vector_t* res;

 for (size_t i = 0; i < longitud_del_array; i++)
 {
  if (array_de_vectores[i] != NULL)
  {
    if(max < array_de_vectores[i]->size || i == 0){
      max = array_de_vectores[i]->size;
      res = array_de_vectores[i];
    }  
  }
 }
 return res;
}
