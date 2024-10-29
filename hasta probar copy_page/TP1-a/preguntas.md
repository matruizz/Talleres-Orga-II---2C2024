
# Preguntas 

### contar_espacios

¿Cuántos espacios tiene el string vacío?
Tiene un espacio en memoria con el caracter nulo.
### lista_enlazada
0. ¿Cuál sería el equivalente a inicializar una variable de tipo entero con 0, para el caso de una variable de tipo puntero?
Inicializando el puntero en NULL, pero no se puede desreferenciar. Otra opción, es usando memoria dinámica con malloc para indicar un bloque de memoria del tamaño del tipo de la variable.
1. Esquema de estructura de la lista
2. a. mi_lista: Alojado en HEAP
b. mi_otra_lista: STACK
c. mi_otra_lista.head: STACK
d. mi_lista->head: HEAP
¿Y si a la lista mi_otra_lista la creamos fuera de cualquier función? BSS al ser una variable global no inicalizada

### Integrador
1. El compilador lo calcula automaticamente al tener cada string en el final el caracter nulo.
2. Una forma seria utilizar un struct con dos campos, los cuales sean arrays, uno que corresponda a las vocales, y otro a las consonates, por lo que solamente resta devolver dicho struct. Otra forma seria utilizar un array multidimensionable el cual tenga dos elementos, donde el primero seria un array de vocales, y el otro un array de consonantes, solo resta devolver dicho array.

Forma 1:
`struct vowelsAndConsonants{
	char* vowels;
	char* consonants;

} 
`
Forma 2:
`** vowelsAndConsonants;`
