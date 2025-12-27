# Informe de Desarrollo 
## Implementación del Algoritmo de Desencriptación AES-128 en ARM64


- ADRIANA LUCIA OJEDA RIVAS - 202000363  
- CARLOS ALFREDO BARRIENTOS LÓPEZ  - 202003948
- KATERIN NAYELI VELASQUEZ HERNANDEZ      - 202100080
- DAVID NORBERTO FABRO GUZMÃN - 202307499 
---

## 1. Introducción

El presente informe describe de manera detallada el proceso de desarrollo del proyecto **Implementación del Algoritmo de Desencriptación AES-128 en lenguaje ensamblador ARM64**, elaborado como parte del curso *Arquitectura de Computadores y Ensambladores 1*. El proyecto tuvo como finalidad aplicar los conceptos teóricos vistos en clase a un caso práctico de alta complejidad técnica, permitiendo comprender el funcionamiento interno de un algoritmo criptográfico ampliamente utilizado en la industria.

El estándar **AES-128 (Advanced Encryption Standard)** es uno de los algoritmos de cifrado simétrico más utilizados a nivel mundial para la protección de información. Normalmente, este algoritmo se implementa en lenguajes de alto nivel o mediante instrucciones especializadas de hardware. Sin embargo, en este proyecto se optó por una implementación completa en lenguaje ensamblador ARM64, con el objetivo de profundizar en el manejo de registros, memoria, pila, llamadas al sistema y estructuras de datos a bajo nivel.

Este enfoque permitió analizar el impacto que tiene la arquitectura del procesador en la ejecución de algoritmos criptográficos y reforzó la comprensión de conceptos fundamentales como direccionamiento de memoria, uso eficiente de registros y control del flujo del programa.

---

## 2. Contexto y Justificación del Proyecto

La criptografía es un pilar fundamental en la seguridad informática moderna. Protocolos como HTTPS, sistemas de almacenamiento seguro y aplicaciones bancarias dependen directamente de algoritmos como AES para garantizar la confidencialidad de la información.

La elección de AES-128 como objeto de estudio se debe a su relevancia académica y práctica, así como a su estructura bien definida, lo que permite analizar con claridad cada una de sus etapas. Implementar este algoritmo en ensamblador representa un reto significativo, ya que obliga al desarrollador a comprender cada transformación a nivel de bits y bytes, sin depender de bibliotecas externas.

Asimismo, la arquitectura **ARM64 (AArch64)** fue seleccionada debido a su amplia adopción en dispositivos modernos, incluyendo servidores, teléfonos móviles y sistemas embebidos, lo que hace que el aprendizaje adquirido sea altamente aplicable en contextos reales.

---

## 3. Objetivos del Proyecto

### 3.1 Objetivo General

Desarrollar un sistema completo y funcional de desencriptación AES-128 utilizando lenguaje ensamblador ARM64, capaz de procesar entradas en formato hexadecimal y recuperar correctamente el texto plano original.

### 3.2 Objetivos Específicos

- Analizar el estándar FIPS-197 para comprender el funcionamiento interno del algoritmo AES-128.
- Implementar la expansión inversa de claves a partir de la clave de ronda 10.
- Desarrollar las transformaciones inversas del algoritmo AES de manera modular.
- Gestionar de forma correcta la entrada y salida de datos a nivel de sistema operativo.
- Aplicar buenas prácticas de programación en ensamblador, respetando la convención de llamadas ARM64.
- Validar el correcto funcionamiento del sistema mediante vectores de prueba oficiales.

---

## 4. Descripción General del Sistema

El sistema desarrollado funciona de manera interactiva, solicitando al usuario la información necesaria para ejecutar el proceso de desencriptación. En primer lugar, el usuario ingresa la última clave de ronda en formato hexadecimal. Posteriormente, se introduce el texto cifrado, también en formato hexadecimal.

A partir de estos datos, el sistema realiza los siguientes pasos:

1. Conversión de la clave hexadecimal a representación binaria.
2. Cálculo de todas las claves de ronda mediante expansión inversa.
3. Conversión del texto cifrado a un bloque de 16 bytes.
4. Ejecución del algoritmo de desencriptación AES-128.
5. Presentación del texto plano resultante en formato hexadecimal.

El diseño del sistema prioriza la claridad del flujo del programa y la separación de responsabilidades entre los distintos módulos.

---

## 5. Arquitectura y Organización del Proyecto

Para facilitar el desarrollo y la depuración, el proyecto fue dividido en varios archivos ensamblador, cada uno con una responsabilidad específica. Esta arquitectura modular permitió trabajar de manera ordenada y redujo la complejidad del sistema completo.

Cada módulo fue diseñado para cumplir una función clara, evitando dependencias innecesarias y facilitando la reutilización del código. Esta decisión fue clave para poder escalar el proyecto y realizar pruebas unitarias durante el desarrollo.

---

## 6. Proceso de Desarrollo

### 6.1 Análisis del Algoritmo AES-128

El desarrollo inició con un estudio detallado del estándar AES-128, identificando la estructura del estado, el número de rondas y las transformaciones involucradas. Se prestó especial atención al orden de las operaciones durante el proceso de descifrado, ya que este difiere del proceso de cifrado.

Comprender este flujo fue fundamental para evitar errores lógicos durante la implementación y para asegurar que cada ronda produjera los resultados esperados.

---

### 6.2 Implementación de la Expansión Inversa de Claves

La expansión inversa de claves fue uno de los componentes más desafiantes del proyecto. A diferencia de la expansión directa, esta requiere calcular las claves anteriores partiendo de la última clave de ronda.

Este proceso implicó el uso de operaciones como rotaciones de palabras, sustituciones mediante la S-box inversa y la aplicación de constantes de ronda. Todo esto fue implementado cuidadosamente para asegurar que las claves generadas coincidieran con las definidas por el estándar.

---

### 6.3 Desarrollo de las Transformaciones Inversas

Cada transformación inversa del algoritmo AES fue implementada como una función independiente. Esto incluyó:

- Sustitución inversa de bytes.
- Desplazamiento inverso de filas.
- Mezcla inversa de columnas.
- Adición de la clave de ronda.

Esta separación permitió validar cada transformación de forma individual antes de integrarlas en el algoritmo completo.

---

### 6.4 Integración y Flujo Principal

Una vez implementados los módulos individuales, se procedió a integrarlos en el flujo principal del programa. El archivo principal coordina la ejecución de cada etapa, asegurando que los datos se pasen correctamente entre funciones y que los registros se preserven según la convención ARM64.

Durante esta fase se realizaron múltiples pruebas para verificar que el flujo del programa fuera correcto y que no existieran errores de memoria o de control.

---

## 7. Retos Encontrados Durante el Desarrollo

### 7.1 Complejidad del Lenguaje Ensamblador

El uso de ensamblador representó un reto significativo debido a la ausencia de abstracciones de alto nivel. Cada operación debía ser cuidadosamente planificada y ejecutada.

**Solución:**  
Se optó por una metodología incremental, implementando y probando cada módulo de manera independiente antes de integrarlo al sistema.

---

### 7.2 Manejo del Campo Finito GF(2⁸)

La implementación de operaciones matemáticas en el campo finito requerido por AES fue especialmente compleja.

**Solución:**  
Se desarrollaron funciones auxiliares optimizadas para realizar multiplicaciones por constantes, reduciendo la complejidad del código principal.

---

### 7.3 Control de Registros y Memoria

El uso incorrecto de registros o de la pila podía provocar errores difíciles de detectar.

**Solución:**  
Se respetó estrictamente la convención de llamadas ARM64 y se documentó el uso de cada registro dentro de las funciones.

---

## 8. Resultados y Validación

El sistema fue validado utilizando vectores de prueba conocidos del estándar AES-128. Los resultados obtenidos coincidieron con los valores esperados, confirmando la correcta implementación del algoritmo.

Además, se verificó la estabilidad del programa frente a entradas válidas y se comprobó que el manejo de memoria fuera seguro.

---

## 9. Consideraciones de Seguridad y Buenas Prácticas

Durante el desarrollo se aplicaron diversas buenas prácticas, tales como:

- Validación estricta de la entrada del usuario.
- Uso de buffers de tamaño fijo.
- Separación adecuada de secciones de memoria.
- Uso eficiente de registros para mejorar el rendimiento.

---

## 10. Conclusiones

El desarrollo de este proyecto permitió comprender en profundidad el funcionamiento interno del algoritmo AES-128 y su relación con la arquitectura del procesador. La implementación en ensamblador ARM64 representó un reto técnico considerable, pero también una valiosa experiencia de aprendizaje.

Este proyecto fortaleció las habilidades en programación de bajo nivel y sentó las bases para futuros desarrollos relacionados con criptografía y seguridad informática.

---

## 11. Trabajo Futuro

Como posibles líneas de mejora se plantean:

- Implementar el proceso de cifrado AES-128.
- Soportar longitudes de clave mayores como AES-192 y AES-256.
- Optimizar el código utilizando instrucciones vectoriales.
- Incorporar manejo de múltiples bloques de datos.
- Desarrollar pruebas automatizadas para validar el sistema.
