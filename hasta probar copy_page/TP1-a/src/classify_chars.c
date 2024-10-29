#include "classify_chars.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

uint8_t cantVocales = 5;

const char vocales[5] = {'a', 'e', 'i', 'o', 'u'};

uint8_t esVocal(char letra){

    for (size_t i = 0; i < cantVocales; i++)
    {
        if (vocales[i] == letra)
        {
            return 1;
        }
    }
    return 0;    
}
void classify_chars_in_string(char* string, char** vowels_and_cons) {
    
    
    //char* iterador = string;*iterador
    int i = 0;

    uint8_t cantCons = 0;
    uint8_t cantVoc = 0;

    while(string[i] != '\0' ){
        if(esVocal(string[i])){
            cantVoc++;
        } else{
            cantCons++;
        }
        i++;
    }

    vowels_and_cons[0] = (char*) calloc(cantVoc+1, sizeof(char));
    vowels_and_cons[1] = (char*) calloc(cantCons+1, sizeof(char));


    int iv = 0;
    int jc = 0;
    i = 0;
    
    while(string[i] != '\0'){
        if(esVocal(string[i])){
            vowels_and_cons[0][iv] = string[i];
            iv++;
        } else{
            vowels_and_cons[1][jc] = string[i];
            jc++;;
        }
        i++;
    }

    vowels_and_cons[0][iv] = '\0';
    vowels_and_cons[1][jc] = '\0';
    
}

void classify_chars(classifier_t* array, uint64_t size_of_array) {
if(array != NULL){
  for(uint64_t i = 0; i < size_of_array; i++){
    array[i].vowels_and_consonants = calloc(2, sizeof(char*));
    classify_chars_in_string(array[i].string, array[i].vowels_and_consonants);
  }
}


}
