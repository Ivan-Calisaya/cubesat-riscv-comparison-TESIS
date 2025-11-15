# Análisis Técnico: Adaptación de Código FPGA a SoC

## 🎯 Pregunta Clave para la Tesis
**¿Por qué no podemos usar directamente el código FPGA (`simple_add.c`) en el entorno SoC?**

## 📋 Código Original FPGA vs SoC

### **Código FPGA Original** (`simple_add.c`)
```c
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
```

### **Limitaciones del Código FPGA en SoC**

| Aspecto | FPGA Implementation | SoC Requirement | Razón |
|---------|-------------------|-----------------|--------|
| **I/O Output** | ❌ Sin salida visible | ✅ UART/Console output necesario | Sin output, no podemos verificar resultados |
| **Startup Code** | ❌ Minimal (directo a main) | ✅ Bootloader completo requerido | SoC necesita inicialización de sistema |
| **Memory Layout** | ❌ Implícito en FPGA | ✅ Explícito en linker script | SoC debe mapear memoria correctamente |
| **Stack Setup** | ❌ Hardware manejado | ✅ Software debe configurar | SoC requiere stack pointer inicial |
| **Debugging** | ❌ Solo variables internas | ✅ Output observable | Necesitamos ver resultados de ejecución |

---

## 🔍 Análisis Detallado de Diferencias

### **1. Problema de Observabilidad**

#### **FPGA Approach:**
- Las variables `a`, `b`, `result` están en registros/memoria
- Verificación vía **ModelSim waveforms** o **debug interfaces**
- Resultado observable en **simulación HDL**

#### **SoC Challenge:**
- Sin output, el programa ejecuta pero **no vemos resultados**
- QEMU no tiene acceso directo a variables internas
- Necesitamos **output explícito** vía UART/console

### **2. Entorno de Ejecución Diferente**

#### **FPGA Context:**
```
[Reset] → [PC = 0x00000000] → [main() directamente] → [while(1)]
```
- **Bootloader**: Mínimo, manejado por HDL
- **Stack**: Configurado en hardware
- **Memory map**: Definido en diseño HDL

#### **SoC Context:**
```
[Reset] → [Bootloader] → [Stack setup] → [BSS clear] → [main()] → [Output] → [halt]
```
- **Bootloader**: Requerido en software
- **Stack**: Debe configurarse explícitamente
- **Memory map**: Definido en linker script

### **3. Diferencias en Objetivos de Medición**

#### **FPGA Metrics:**
- **Latencia**: Ciclos de reloj desde reset hasta resultado
- **Recursos**: LUTs, FFs, BRAM utilizados
- **Timing**: Slack, frequency máxima
- **Power**: Static + dynamic power consumption

#### **SoC Metrics:**
- **Latencia**: Instrucciones ejecutadas, tiempo de ejecución
- **Recursos**: Memoria RAM utilizada
- **Throughput**: Operaciones por segundo
- **Energy**: Estimación basada en instrucciones

---

## 🛠️ Estrategia de Adaptación

### **Opción 1: Adaptación Mínima (Recomendada)**
Mantener la **lógica core idéntica**, agregar solo **infraestructura SoC**:

```c
// MISMA LÓGICA CORE que FPGA
volatile int a = 10;
volatile int b = 20;
volatile int result;
result = a + b;

// AGREGAR: Output para observabilidad
uart_puts("A = 10, B = 20, Result = ");
uart_put_number(result);
uart_puts("\n");
```

**Ventajas:**
- ✅ **Comparación directa** entre implementaciones
- ✅ **Mismo algoritmo** ejecutándose en ambas plataformas
- ✅ **Métricas comparables** (misma complejidad computacional)

### **Opción 2: Código Completamente Separado**
Crear implementación SoC independiente.

**Desventajas:**
- ❌ **Comparación menos válida** académicamente
- ❌ **Variables adicionales** pueden afectar métricas
- ❌ **Complejidad diferente** entre implementaciones

---

## 📊 Justificación Académica para Adaptación

### **Principio de Investigación**
> *"Para una comparación válida FPGA vs SoC, debemos ejecutar el **mismo algoritmo** en ambas plataformas, adaptando únicamente la **infraestructura de soporte** necesaria para cada entorno."*

### **Metodología Aplicada**

#### **Invariantes (Mantener Idénticos):**
1. **Lógica de cálculo**: `result = a + b`
2. **Valores de entrada**: `a = 10`, `b = 20`
3. **Tipo de datos**: `volatile int`
4. **Operación core**: Suma aritmética simple

#### **Variables (Adaptar por Plataforma):**
1. **Infraestructura I/O**: UART vs Debug interface
2. **Startup**: Bootloader vs HDL reset
3. **Memory management**: Linker script vs HDL memory map
4. **Observability**: Output functions vs waveform analysis

### **Impacto en Métricas**

| Métrica | Impacto de Adaptación | Comparabilidad |
|---------|----------------------|----------------|
| **Latencia Core** | ✅ Mínimo (mismo algoritmo) | ✅ Válida |
| **Throughput** | ✅ Mínimo (misma operación) | ✅ Válida |
| **Memory Usage** | ⚠️ Infraestructura adicional | ⚠️ Normalizable |
| **Energy** | ⚠️ I/O overhead | ⚠️ Separable |

---

## 🔬 Implementación Propuesta para Tesis

### **Código SoC Adaptado** (`simple_add_soc.c`)

```c
#include <stdint.h>

// Memory-mapped I/O para QEMU virt machine
#define UART_BASE 0x10000000
#define UART_THR  (UART_BASE + 0x00)

void uart_putchar(char c) {
    volatile uint32_t *uart_thr = (volatile uint32_t*)UART_THR;
    *uart_thr = c;
}

void uart_put_number(int num) {
    // Función simple para mostrar número
    char buffer[12];
    int i = 0;
    
    if (num == 0) {
        uart_putchar('0');
        return;
    }
    
    if (num < 0) {
        uart_putchar('-');
        num = -num;
    }
    
    while (num > 0) {
        buffer[i++] = '0' + (num % 10);
        num /= 10;
    }
    
    while (i > 0) {
        uart_putchar(buffer[--i]);
    }
}

int main(void) {
    // ===================================
    // LÓGICA CORE IDÉNTICA AL FPGA
    // ===================================
    volatile int a = 10;
    volatile int b = 20;
    volatile int result;

    result = a + b;
    // ===================================
    
    // INFRAESTRUCTURA SoC: Output para observabilidad
    uart_putchar('A');
    uart_putchar('=');
    uart_put_number(a);
    uart_putchar(',');
    uart_putchar(' ');
    uart_putchar('B');
    uart_putchar('=');
    uart_put_number(b);
    uart_putchar(',');
    uart_putchar(' ');
    uart_putchar('R');
    uart_putchar('=');
    uart_put_number(result);
    uart_putchar('\n');
    
    // BUCLE INFINITO (igual que FPGA)
    while(1) {
        __asm__ volatile ("wfi");  // Wait for interrupt (SoC equivalent)
    }

    return 0; // Esta línea nunca se alcanzará (igual que FPGA)
}
```

### **Diferencias Documentadas**

#### **Líneas Idénticas al FPGA:**
```c
volatile int a = 10;         // IDÉNTICO
volatile int b = 20;         // IDÉNTICO  
volatile int result;         // IDÉNTICO
result = a + b;              // IDÉNTICO
while(1);                    // FUNCIONALMENTE IDÉNTICO
```

#### **Líneas Agregadas para SoC:**
```c
#include <stdint.h>          // NUEVO: Headers para SoC
#define UART_BASE...         // NUEVO: Memory mapping
void uart_putchar()...       // NUEVO: I/O functions
uart_put_number(result);     // NUEVO: Output observabilidad
__asm__ volatile ("wfi");    // NUEVO: SoC-specific halt
```

---

## 📈 Métricas de Comparación Válidas

### **Métricas Core (Comparables Directamente)**
1. **Instrucciones de Cálculo**: ADD, LOAD, STORE para `result = a + b`
2. **Latencia Algorítmica**: Tiempo desde `a` y `b` hasta `result`
3. **Throughput Core**: Operaciones aritméticas por segundo

### **Métricas de Infraestructura (Documentar Separadamente)**
1. **Overhead de I/O**: Tiempo de UART output (solo SoC)
2. **Bootloader Cost**: Tiempo de startup (solo SoC)
3. **Memory Overhead**: RAM adicional para functions (solo SoC)

### **Normalización para Comparación**
```
Latencia_Efectiva_SoC = Latencia_Total - Overhead_IO - Overhead_Bootloader
Latencia_Efectiva_FPGA = Latencia_Medida

Comparación = Latencia_Efectiva_SoC / Latencia_Efectiva_FPGA
```

---

## ✅ Conclusión para Documentación de Tesis

### **Respuesta a la Pregunta Original:**
> *"¿El código FPGA sirve directamente para SoC?"*

**NO, pero la adaptación es mínima y académicamente válida:**

1. **✅ Lógica Core**: Se mantiene 100% idéntica
2. **✅ Algoritmo**: Mismo cálculo en ambas plataformas  
3. **✅ Comparabilidad**: Métricas core son directamente comparables
4. **⚠️ Infraestructura**: Adaptación necesaria para observabilidad y ejecución SoC
5. **📊 Normalización**: Métricas de overhead documentadas separadamente

### **Valor Académico de la Adaptación:**
- **Demuestra** diferencias arquitecturales entre FPGA y SoC
- **Cuantifica** overhead de infraestructura en cada plataforma
- **Permite** comparación válida manteniendo algoritmo constante
- **Documenta** trade-offs específicos de cada implementación

### **Para el Informe de Tesis:**
*"La adaptación del código FPGA al entorno SoC es necesaria para la observabilidad de resultados y correcta ejecución en el simulador QEMU. Se mantiene la lógica algorítmica core idéntica para garantizar la validez de la comparación, documentando separadamente el overhead introducido por la infraestructura específica de cada plataforma."*

---

## 📋 Archivos de Documentación Generados

1. **`FPGA-SOC-CODE-ANALYSIS.md`** (este archivo)
2. **`simple_add_comparison.md`** (análisis línea por línea)
3. **`metrics_normalization.md`** (metodología de normalización)

¿Te parece que esta documentación cubre bien la justificación académica para tu tesis?