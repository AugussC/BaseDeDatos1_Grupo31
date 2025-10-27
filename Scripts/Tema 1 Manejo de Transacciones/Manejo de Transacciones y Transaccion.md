## Manejo de Transacciones y Transacciones Anidadas

### Conceptos Fundamentales

Antes de hablar del manejo de transacciones, es fundamental entender qué es una transacción en bases de datos.

Una **transacción** es una unidad lógica de trabajo que agrupa una o varias operaciones (inserciones, actualizaciones, eliminaciones o consultas) que deben ejecutarse **todas juntas o ninguna**, garantizando así la **consistencia del sistema**.

En términos generales, una transacción es un conjunto de acciones que transforma el estado del sistema de forma coherente, respetando las **restricciones de integridad** definidas. Los cambios surgen por operaciones de actualización, inserción o eliminación, y el objetivo es que la base de datos **nunca entre en un estado inconsistente**, ni siquiera temporalmente.

Las transacciones simplifican la construcción de sistemas confiables mediante mecanismos que proporcionan soporte uniforme para:

- Operación de comparación de datos.
- Aislamiento y serialización entre transacciones concurrentes.
- Atomicidad en su ejecución.
- Recuperación ante fallos.

El objetivo del manejo de transacciones es garantizar la **transparencia** tanto en la ejecución concurrente de operaciones como en la recuperación ante fallas, asegurando que la base de datos siempre vuelva a un **estado consistente** al finalizar una transacción.

### Instrucciones y Propiedades de las Transacciones

Las **instrucciones de transacción** son comandos que el compilador o el gestor de base de datos interpreta para controlar su ejecución. Las principales son:

- **BEGIN_TRANSACTION:** inicia una transacción.  
- **END_TRANSACTION (COMMIT):** finaliza y confirma los cambios.  
- **ABORT_TRANSACTION (ROLLBACK):** cancela la transacción y revierte los valores previos.  
- **READ / WRITE:** lectura y escritura de datos en archivos o tablas.

Las operaciones comprendidas entre `BEGIN` y `END` forman el cuerpo de la transacción y deben ejecutarse **todas o ninguna**.  
El número exacto de instrucciones disponibles depende del sistema de base de datos utilizado.

### Propiedades ACID de las Transacciones

Las transacciones cuentan con las siguientes propiedades fundamentales:

- **Atomicidad:**  
  La transacción se ejecuta como una unidad indivisible: o se completan todas las operaciones, o no se realiza ninguna. Si ocurre una falla, los cambios parciales se revierten.

- **Consistencia:**  
  Asegura que la base de datos pase de un estado válido a otro, respetando las reglas de integridad definidas.

- **Aislamiento:**  
  Los resultados de una transacción no deben ser visibles para otras hasta que se confirme.  
  Las ejecuciones concurrentes deben producir el mismo resultado que si fueran secuenciales (**seriabilidad**).

- **Durabilidad:**  
  Una vez confirmada, la transacción es permanente; sus efectos persisten incluso ante fallas del sistema.

Las transacciones garantizan **ejecución confiable**, **control de concurrencia** y **recuperación ante fallos o replicación**.

### Estructura de Transacciones

La estructura de una transacción depende del modelo utilizado, que puede ser **plano** o **anidado**.

- **Transacciones Planas:**  
  Secuencia de operaciones primitivas delimitadas por `BEGIN` y `END`.

  ```sql
  BEGIN TRANSACTION Reservacion;
  ...
  END;
  ```

- **Las Transacciones Anidadas:**
  Consiste en tener transacciones que pueden ser de otras transacciones incluidas dentro de otras de un nivel superior que se les conoce como **subtransacciones**.
    ```sql
    BEGIN TRANSACTION Reservacion
        BEGIN TRANSACTION Vuelo
        ... 
        End (Vuelo)
        BEGIN TRANSACTION Hotel
        ...
        ...END
    ...END 
    ```
    Una transacción anidada dentro de otra conserva las mismas propiedades que la de su padre, lo que implica que puede contener, a su vez, otras transacciones dentro de ella.

    Existen restricciones obvias en una transacción anidada, como que debe comenzar después que su transacción padre y finalizar antes que ella.  
    Si la transacción padre de una o varias subtransacciones aborta, las subtransacciones también serán abortadas.

    Las transacciones anidadas mejoran la concurrencia y permiten una **recuperación parcial ante fallas**, reduciendo el costo de recuperación.


### Tipos de Transacciones según Lectura y Escritura

El orden de las operaciones de lectura y escritura dentro de una transacción influye en su comportamiento y en el control de concurrencia.  
Según este criterio, las transacciones se clasifican en:

- **Transacciones Generales:**  
  Permiten mezclar libremente operaciones de lectura y escritura sin restricciones.

- **Transacciones Restringidas:**  
  Imponen que un dato debe ser leído antes de poder ser modificado.  
  Es decir, no se puede escribir sobre un valor sin haberlo leído previamente.

- **Transacciones de Dos Pasos:**  
  Son un tipo de transacción restringida donde todas las operaciones de lectura se realizan antes de las de escritura, separando claramente ambas fases.

- **Modelo de Acción Restringida:**  
  Aplica una restricción aún mayor, exigiendo que cada par `<READ, WRITE>` se ejecute de forma atómica, garantizando así la integridad y consistencia en cada operación.


### Ejecución de Transacciones Centralizadas y Distribuidas

El procesamiento de transacciones implica una serie de operaciones que modifican los recursos del sistema dentro de un bloque delimitado por un inicio y un fin.  
Durante este proceso, otros usuarios no pueden alterar los datos hasta alcanzar un estado estable, evitando inconsistencias temporales y conflictos.

#### Aspectos principales del procesamiento de transacciones:

- **Modelo de estructura:**  
  Determina si las transacciones son planas o anidadas, lo que influye en su complejidad y control.

- **Consistencia de la base de datos interna:**  
  Los algoritmos de control deben garantizar el cumplimiento de las restricciones de integridad antes de confirmar una transacción.

- **Protocolos de Confiabilidad:**  
  En sistemas distribuidos, se requieren mecanismos de comunicación entre nodos para mantener la atomicidad y la integridad de los datos.

- **Control de concurrencia:**  
  Coordina la ejecución simultánea de transacciones para asegurar su aislamiento y evitar conflictos.

- **Control de réplicas:**  
  Asegura la consistencia entre copias de datos almacenadas en distintos nodos o servidores.


### Modos de Ejecución

- **Ejecución Serializada:**  
  Las transacciones se ejecutan de forma secuencial, una tras otra.  
  Aunque reducen el rendimiento, simplifican la sincronización y garantizan la consistencia.

- **Ejecución Calendarizada:**  
  Las transacciones se ejecutan en paralelo, asignando tiempos de procesamiento.  
  Mejoran el rendimiento al permitir múltiples operaciones simultáneas, aunque requieren algoritmos de sincronización más complejos.

### Protocolos de Control y Confiabilidad

Para mantener la seguridad y estabilidad del sistema, se emplean mecanismos como:

- Atomicidad de las operaciones.  
- Protocolos de recuperación total ante fallas.  
- Protocolos de compromiso global para asegurar que todos los nodos confirmen o aborten una transacción en conjunto.

