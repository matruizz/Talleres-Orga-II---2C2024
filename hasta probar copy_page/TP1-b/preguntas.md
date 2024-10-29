# Preguntas

1. La convencion de llamadas es el conjunto de reglas para asegurar compatibilidad de los programas al usar o definir funciones 
En la arquitectura de 64 bits, estan definidos los registros no volariles RBX, RBP, R12 A R15. El valor de retorno, en caso de ser un numero entero o un puntero se alnacena en Rax, en cambio si es un flotante sera en XMMO. Los argumentos de la funcion que son enteros pasaran a los registros RDI, RSI, RDX, RCX, R8, Y R9 de izquierda a derecha, en cambio los flotantes por los XMM0 a XMM7 de izquierda a derecha. En caso de que no haya suficientes registros para los parametros, estos pasaran de derecha a izquierda por la pila. Al terminar de realizar una funcion, todo push, debe tener su pop. Finalmente la pila debe estar alineada a 16 bytes.
Luego, para las arquitecturas de 32 bits, los registros no volatiles seran los EBX, EBP, ESI, y EDI. El valor de retorno se almacenara en EAX, y, al no haber sufientes registros, todos los argumentos de las funciones iran a la pila. Al igual que en 64 bits, todo push debe tener su pop, y la pila debe estar alineada a 64 bits 

2. El compilador de C es quien se encarga de asegurarlo. En ASM es el programador quien se encarga de cumplir con la convención
3. El espacio de memoria contigua designado por el RBP y el RSP en una función dada. El prólogo es la parte donde se asigna la memoria en la función pusheando y el eplogo libera la memoria una vez terminada la función.
4. Las variables temporales se almacenan en el stack en direcciones menores en memoria relativo al RBP
5. Para las funciones de libc, se requiere un alineamiento a 16 bytes. Al ejecutarse la primera instrucción que guarda el RIP, esta instrucción nos lo desalinea y termina alineado a 8 bytes.
6. 
a. Al cambiar de lugar los campos del struct, el programa que fue compilado surgen problemas porque, por ejemplo, cuando se quiera acceder al campo r del pixel se va a acceder a la información del campo a.
b. Al reordenar estos parametros, al querer acceder al parametro correspondiente al puntero al array se va a producir un error de acceso a memoria invalida segmentation fault.
c. Como el programa que compilamos tiene en cuenta solo los primeros 16 bits del registro RAX pero debido a que la funcion de la biblioteca modificada ahora los resultados pueden ser de 64 bits, por lo que de ahora en mas, se trabajara con la parte baja del rax, habiendo usuarios repetidos si se registran usuarios con igual parte baja.
d. En este caso, pasaria algo similar al caso c, puesto que al ahora, id_usuario ser de 64 bits, es significara que solo se va a tener en cuenta su parte baja de 16 bits, lo que llevaria a cambiar nombres de usuarios que no corresponden
e. En este caso, no habria problema en el programa, puesto tanto el float como el int utilizan distintos tipos de registros, al cambiar el orden, de igual forma se buscaran en dichos registros especificos correspondientes
7. Pueden pasar muchas cosas, pueden producirse errores de acceso a memoria, producirse comportamiento no deseado en el programa, como puede seguir funcionando correctamente.

## Pila
La clave fue encontrada en la función strCmp. Esta función fue encontrada de la siguiente manera
- con un objdump vemos que la función main llama a otras funciones. incluida la función que buscamos, print_authentication_message
- abrimos gdb en el ejecutable y ponemos un breakpoint en esta funcion
- como la función viene con el int miss en 1, asumimos que la función ya detecto que el intento de clave es invalido puesto que displayea el mensaje de clave invalida
- vemos el stack de llamados del programa y descubrimos la funcion anterior do_some_more_stuff y do_some_stuff 
- la validacion tendria que estar entonces en alguna de estas dos funciones
- la funcion do_some_more_stuff hace un call a strCmp
- strCmp requiere entonces de dos strings, la clave que estamos buscando y el intento
- sabemos que la clave es de tipo char* por lo que strCmp recibe el address en memoria de la clave en RSI o RDX
- buscamos los address guardado registro con x/s que nos deberia dar la porcion del stack en formato string
- RDX : nuestro intento
- y en RDI?
- boom
- clave encontrada: "clave_192.168.100.117"

