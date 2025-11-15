Paso 1: Escribir el Programa de Prueba en C
Comienza con el programa más simple posible. No intentes implementar algoritmos complejos aún. Un buen punto de partida es un programa que realice una operación aritmética básica y termine. Por ejemplo, un simple_add.c:

C

int main() {
    // Usamos 'volatile' para asegurar que el compilador no optimice
    // las variables y genere instrucciones de carga y almacenamiento.
    volatile int a = 10;
    volatile int b = 20;
    volatile int result;

    result = a + b;

    // Bucle infinito al final para detener el procesador.
    // En hardware real, esto evita que ejecute basura.
    // En simulación, nos da un punto estable para verificar el resultado.
    while(1);

    return 0; // Esta línea nunca se alcanzará.
}
Este programa es ideal porque nos permitirá verificar varias instrucciones clave: ADDI (para cargar 10 y 20 en registros), ADD (para la suma), SW y LW (para mover las variables entre los registros y la pila de memoria) y BEQ o J (para el bucle infinito).

Paso 2: Compilar el Código C a un Archivo Objeto (ELF)
Ahora, utiliza la toolchain de RISC-V GCC que configuraste. La línea de comando es crucial. Abre una terminal en la carpeta donde guardaste simple_add.c y ejecuta:

Bash

riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -ffreestanding -T link.ld -o simple_add.elf simple_add.c
Desglosemos los flags importantes:

-march=rv32i -mabi=ilp32: Como vimos en la guía, esto asegura que se genere código máquina puro para nuestra arquitectura RV32I.   

-nostdlib -ffreestanding: Estas opciones le dicen al compilador que no enlace las bibliotecas estándar de C. Esto es fundamental porque nuestro procesador no tiene un sistema operativo que provea funciones como printf o manejo de memoria. Estamos programando sobre "metal desnudo" (bare-metal).

-T link.ld: Esto utiliza un linker script (que tendrás que crear, puede ser muy simple al principio) para decirle al enlazador dónde colocar el código y los datos en el mapa de memoria de nuestro procesador. Para empezar, solo necesitas definir el origen de la memoria de instrucciones.

-o simple_add.elf: Este es el archivo de salida en formato ELF, que contiene el código máquina junto con otra información de depuración.   

Paso 3: Extraer el Código Máquina a un Formato Hexadecimal
El archivo .elf no puede ser leído directamente por la memoria de nuestro diseño en SystemVerilog. Necesitamos extraer únicamente las instrucciones en un formato de texto hexadecimal. Este es un proceso de dos pasos:

Convertir de ELF a binario puro:

Bash

riscv64-unknown-elf-objcopy -O binary simple_add.elf simple_add.bin
Esto genera simple_add.bin, un archivo que contiene única y exclusivamente los bytes de las instrucciones.

Convertir de binario a texto hexadecimal (.hex o .mif):
El archivo .bin aún no es el formato correcto. Necesitamos un archivo de texto donde cada línea contenga una instrucción de 32 bits en formato hexadecimal. Aquí es donde entra en juego un script como el export_opcode_rv.py mencionado en la guía. Su función es leer el archivo .bin y escribir un archivo de texto formateado que ModelSim pueda entender para inicializar la memoria.

Paso 4: Simular en ModelSim
Con tu archivo programa.hex (o como lo llames) listo, ahora vamos a la simulación:

Configura el Testbench: Asegúrate de que tu processor_tb.sv instancia correctamente la memoria de instrucciones (imem.sv).

Carga el Programa: Dentro del bloque initial de tu testbench, usa la directiva de SystemVerilog $readmemh para cargar el contenido del archivo hexadecimal en la memoria simulada.

Fragmento de código

initial begin
    $readmemh("ruta/a/tu/programa.hex", dut.instruction_memory.ram);
    //... resto de la inicialización (reset, etc.)
end
Ejecuta la Simulación: Utiliza el script .do que preparamos en la guía para compilar los fuentes, iniciar la simulación y abrir la ventana de ondas.   

Analiza los Resultados: Esto es lo más importante. En la ventana de ondas, debes observar el comportamiento ciclo a ciclo:

Verifica que el PC se incrementa de 4 en 4.

Observa la instrucción que sale de la memoria de instrucciones y comprueba que coincide con lo que esperas de tu programa.

Monitoriza el banco de registros (regfile). Deberías ver cómo se escriben los valores 10 y 20 en dos registros.

Observa las entradas y la salida de la ALU para confirmar que realiza la suma.

Finalmente, verifica que el resultado (30, o 1E en hexadecimal) se escribe en el registro de destino (result).

Confirma que al final, el PC entra en un bucle, saltando a la misma dirección repetidamente.

Sobre la Comparación con el Otro Hardware
Has mencionado correctamente el objetivo final. Sin embargo, es fundamental seguir el enfoque incremental. La comparación con el hardware SoC (la DE10-Nano) es parte de la Sección 3 de la guía. Solo podemos llegar ahí cuando tengamos un diseño completamente verificado y funcional en simulación.

Por lo tanto, tu enfoque ahora debe ser 100% en la simulación. Una vez que el programa simple_add.c funcione a la perfección, escribirás programas de prueba un poco más complejos (para probar saltos, accesos a memoria, etc.) y repetirás el proceso hasta que todas las instrucciones RV32I estén validadas.

Tu primera tarea concreta es: lograr que el programa simple_add.c se ejecute correctamente en ModelSim y capturar una forma de onda que demuestre que el registro de destino contiene el valor 0x1E al final de la ejecución.