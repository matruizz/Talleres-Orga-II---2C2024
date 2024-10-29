#include "contar_espacios.h"
#include <stdio.h>

uint32_t longitud_de_string(char* string) {

uint32_t res = 0;

if(string != NULL){
 	while(*string != '\0'){
  	res = res + 1;
  	string = string + 1;
 	}
  }
 return res;
}

uint32_t contar_espacios(char* string) {
uint32_t res = 0;

if(string != NULL){
	
 	while(*string != '\0'){
  		if(*string == ' '){
   		res = res + 1;
  	}
  	string = string + 1;
 	}
 }
 return res;
}

// Pueden probar acá su código (recuerden comentarlo antes de ejecutar los tests!)
/*
 int main() {

    printf("1. %d\n", contar_espacios("hola como andas?"));

    printf("2. %d\n", contar_espacios("holaaaa orga2"));

    printf("3. %d\n", longitud_de_string("holaaaa orga2"));


}
*/
