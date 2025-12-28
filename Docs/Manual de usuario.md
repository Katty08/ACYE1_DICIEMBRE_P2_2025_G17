# Manual de Usuario  
## Sistema de Descifrado AES-128 en Arquitectura ARM64

---

## 1. Introducción

Este **Manual de Usuario** tiene como objetivo guiar al usuario en el uso correcto de la aplicación **Sistema de Descifrado AES-128 en ARM64**. El documento explica paso a paso cómo ejecutar el programa, ingresar los datos requeridos y comprender los resultados obtenidos, utilizando un lenguaje claro y accesible.

Este manual está dirigido a estudiantes, docentes y usuarios técnicos que deseen ejecutar la aplicación sin necesidad de conocer los detalles internos de su implementación en lenguaje ensamblador.

---

## 2. Requisitos del Sistema

Antes de ejecutar la aplicación, el usuario debe contar con los siguientes requisitos:

- Sistema operativo compatible con arquitectura **ARM64 (AArch64)**.
- Ensamblador y enlazador compatibles (GNU assembler y linker).
- Terminal de comandos.
- Archivos del proyecto correctamente compilados mediante el `Makefile`.

---

## 3. Compilación de la Aplicación

### 3.1 Compilación del Proyecto

Para compilar el sistema, el usuario debe ubicarse en la carpeta raíz del proyecto y ejecutar el siguiente comando:

```bash
make
```

Este comando ensamblará y enlazará todos los archivos necesarios, generando el ejecutable final.



---

## 4. Ejecución del Programa

### 4.1 Inicio de la Aplicación

Una vez compilado el proyecto, el programa se ejecuta con el siguiente comando:

```bash
./aes128
```

Al iniciar la aplicación, el sistema mostrará un mensaje solicitando la **última clave de ronda (Round 10)**.



---

## 5. Ingreso de la Última Clave de Ronda

El usuario debe ingresar una clave hexadecimal de **32 caracteres**, correspondiente a la clave de la ronda 10 del algoritmo AES-128.

### Ejemplo de entrada:

```text
2b7e151628aed2a6abf7158809cf4f3c
```

El sistema validará automáticamente que la clave tenga el formato correcto.



---

## 6. Expansión Inversa de Claves

Después de ingresar la clave, el sistema calculará automáticamente todas las claves de ronda anteriores mediante el algoritmo de expansión inversa.

En pantalla se mostrará:
- La clave de cada ronda.
- El orden correcto desde la ronda 10 hasta la ronda 0.



---

## 7. Ingreso del Texto Cifrado

Una vez completada la expansión de claves, el programa solicitará al usuario el **texto cifrado (ciphertext)**, el cual debe ingresarse también en formato hexadecimal (32 caracteres).

### Ejemplo de entrada:

```text
3925841d02dc09fbdc118597196a0b32
```



---

## 8. Proceso de Desencriptación

Tras ingresar el texto cifrado, el sistema ejecutará automáticamente el proceso de desencriptación AES-128. Durante este proceso, se muestran mensajes informativos que indican el avance por cada ronda del algoritmo.

Esto permite al usuario:
- Observar el flujo del proceso.
- Verificar que el algoritmo se está ejecutando correctamente.


---

## 9. Visualización del Texto Plano

Al finalizar el proceso, el sistema mostrará en pantalla el **texto plano (plaintext)** resultante, correspondiente al mensaje original antes del cifrado.

El resultado se presenta en formato hexadecimal, organizado en una matriz de 4×4 bytes conforme al estándar AES.


---

## 10. Interpretación de Resultados

El usuario debe considerar los siguientes aspectos al interpretar los resultados:

- Si el texto plano coincide con el valor esperado, el proceso fue exitoso.
- Si los valores no coinciden, se debe verificar:
  - Correcto ingreso de la clave.
  - Correcto ingreso del texto cifrado.
  - Compilación correcta del programa.

---

## 11. Mensajes de Error Comunes

El sistema puede mostrar mensajes de error en los siguientes casos:

- Ingreso de caracteres no hexadecimales.
- Longitud incorrecta de la clave o del texto cifrado.
- Error en la ejecución del programa.

Estos mensajes están diseñados para orientar al usuario y facilitar la corrección del error.



---

## 12. Buenas Prácticas de Uso

Se recomienda al usuario:

- Verificar cuidadosamente los datos ingresados.
- No incluir espacios adicionales en las entradas.
- Ejecutar el programa en un entorno controlado.
- Utilizar vectores de prueba conocidos para validar resultados.

---

## 13. Cierre del Programa

Una vez mostrado el texto plano, el programa finaliza automáticamente su ejecución. El usuario puede volver a ejecutarlo para procesar nuevos datos repitiendo el procedimiento descrito en este manual.

---

## 14. Conclusión

Este Manual de Usuario proporciona una guía completa y clara para el uso del **Sistema de Descifrado AES-128 en ARM64**. Siguiendo los pasos descritos, el usuario puede ejecutar correctamente la aplicación, interpretar sus resultados y aprovechar sus funcionalidades sin necesidad de conocimientos avanzados de programación en ensamblador.
