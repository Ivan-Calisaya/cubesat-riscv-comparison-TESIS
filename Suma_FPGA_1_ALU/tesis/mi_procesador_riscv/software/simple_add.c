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