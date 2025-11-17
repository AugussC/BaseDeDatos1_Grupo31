# Informe del Proyecto: Optimización de Consultas a Través de Índices


### 1. Introducción

En este trabajo se presenta una evaluación empírica del impacto de los índices de base de datos en el rendimiento de las consultas, centrándose en búsquedas por rango de fechas. El estudio se realiza sobre la tabla "Llamada" de la base de datos "Operador911", A la cual agregamos los 1,000,000 registros.

El objetivo principal es medir y comparar los Tiempos de Respuesta y los Planes de Ejecución en tres escenarios clave: sin índice específico, con índice agrupado, y con índice no agrupado cubriente, para demostrar la mejora en la eficiencia de las operaciones.

---

### 2. Tipos de Índices Aplicados en la Prueba

#### Índice Agrupado (Clustered Index)
Un índice agrupado define el **orden físico** en el que se almacenan las filas de una tabla. Solo puede existir uno por tabla. Al aplicarlo a la columna "fecha_creacion", los datos se reordenan físicamente, lo que es ideal para búsquedas de rango `BETWEEN` porque permite al motor acceder directamente al punto inicial y leer las filas contiguas `Index Seek`.

* **Código SQL utilizado:**
    ```sql
    CREATE CLUSTERED INDEX IX_Llamada_FechaCreacion_Clustered 
    ON Llamada (fecha_creacion ASC);
    ```

#### Índice No Agrupado Cubriente (Non-Clustered Covering Index)
Un índice no agrupado es una estructura de datos independiente. Se denomina **cubriente** (*Covering Index*) cuando contiene todas las columnas requeridas por la consulta. En nuestro caso, la clave "fecha_creacion" más las columnas `INCLUDE` ("nombre", "telefono", "id_llamada"). Su beneficio clave es que permite al motor resolver la consulta íntegramente dentro de la estructura del índice, eliminando costosos accesos a la tabla base `Key Lookup`.

* **Código SQL utilizado:**
    ```sql
    CREATE NONCLUSTERED INDEX IX_Llamada_FechaCreacion_Covering_Correcto
    ON Llamada (fecha_creacion ASC)
    INCLUDE (nombre, telefono, id_llamada);
    ```


### 3. Metodología y Preparación de la Base de Datos

Para garantizar la validez de las pruebas de rendimiento, la base de datos Operador911 se preparó de la siguiente manera:

1.  Como primera instancia, se insertaron 1,000,000 de registros en la tabla "Llamada" utilizando un script optimizado de `Tally Table`.
2.  Otra cosa fue que la clave primaria original "id_llamada" fue modificada de `CLUSTERED` a `NON-CLUSTERED` para permitir la creación del índice agrupado de prueba en "fecha_creacion".

La consulta utilizada como caso de prueba en todos los escenarios fue una búsqueda por rango de un año completo (2022):

```sql
SELECT id_llamada, fecha_creacion, nombre, telefono
FROM Llamada
WHERE fecha_creacion >= '2022-01-01' AND fecha_creacion < '2023-01-01'
ORDER BY fecha_creacion;
```


### 4. Resultados de las Pruebas

#### 4.1. Nota Metodológica: Caché vs. Lecturas Lógicas

Es importante destacar por qué las pruebas se ejecutaron de forma secuencial y no "todas juntas".

1.  La estructura de una tabla solo puede estar en un estado a la vez. Un índice agrupado (Tarea 3) y una tabla sin él (Tarea 2) son estados **mutuamente excluyentes**.
2.  El "Tiempo Transcurrido" (ej: 873 ms vs 887 ms) puede ser engañoso. La primera consulta (el `Table Scan`) carga el millón de registros del disco a la **memoria RAM (caché)**. Las pruebas siguientes (los `Index Seek`) se benefician de esta caché, pareciendo artificialmente rápidas.

Por esta razón, la métrica más fiable para medir el consumo y el trabajo real del motor no es el tiempo, sino las Lecturas Lógicas (el número de páginas de 8KB que el motor tuvo que leer, ya sea de disco o de caché).

#### 4.2. Tabla Comparativa de Rendimiento

| Escenario (Tarea) | Plan de Ejecución | Lecturas Lógicas (Trabajo Real) | Tiempo Transcurrido (En Caché) |
| :--- | :--- | :--- | :--- |
| **1. Baseline (Tarea 2)** | `Table Scan` + `Sort` | **10,330** | 873 ms |
| **2. Índice Agrupado (Tarea 3)** | `Clustered Index Seek` | **1,680** | 887 ms |
| **3. Índice Cubriente (Tarea 5)** | `Index Seek (NonClustered)` | **1,157** | 872 ms |

#### 4.3. Evaluación del Rendimiento

* **Escenario 1 (Baseline):** El plan de ejecución mostró un `Table Scan` (costo 76%). El motor se vio obligado a leer la tabla completa (**10,330** páginas) y luego crear una "Worktable" para ordenar los resultados, un proceso altamente ineficiente.
![imagen10]([[https://github.com/AugussC/BaseDeDatos1_Grupo31/blob/main/Scripts/Tema 3 Optimización de consultas a través de índices/Imagen1_TableSacan.png](https://github.com/AugussC/BaseDeDatos1_Grupo31/blob/main/Scripts/Tema%203%20Optimizaci%C3%B3n%20de%20consultas%20a%20trav%C3%A9s%20de%20%C3%ADndices/Imagen1_TableSacan.png)])

* **Escenario 2 (Índice Agrupado):** El plan cambió a un `Clustered Index Seek`. Al estar los datos físicamente ordenados por fecha, el motor solo tuvo que leer las páginas que contenían el rango de 2022. Esto redujo las lecturas en un 84%, de 10,330 a 1,680.
![imagen13]([[https://github.com/AugussC/BaseDeDatos1_Grupo31/blob/main/Scripts/Tema%203%20Optimizaci%C3%B3n%20de%20consultas%20a%20trav%C3%A9s%20de%20%C3%ADndices/Imagen2_ClusteredIndexSeek.png](https://github.com/AugussC/BaseDeDatos1_Grupo31/blob/main/Scripts/Tema%203%20Optimizaci%C3%B3n%20de%20consultas%20a%20trav%C3%A9s%20de%20%C3%ADndices/Imagen2_ClusteredIndexSeek.png)])    

* **Escenario 3 (Índice Cubriente):** El plan mostró un `Index Seek (NonClustered)` limpio. Este fue el escenario más eficiente, reduciendo las lecturas a solo **1,157** (una reducción total del 89%). El motor nunca tocó la tabla base; leyó solo la estructura del índice, que era más "delgada" y compacta que el índice agrupado (que es la tabla entera).
![imagen12]([[https://github.com/AugussC/BaseDeDatos1_Grupo31/blob/main/Scripts/Tema%203%20Optimizaci%C3%B3n%20de%20consultas%20a%20trav%C3%A9s%20de%20%C3%ADndices/Imagen2_ClusteredIndexSeek.png](https://github.com/AugussC/BaseDeDatos1_Grupo31/blob/main/Scripts/Tema%203%20Optimizaci%C3%B3n%20de%20consultas%20a%20trav%C3%A9s%20de%20%C3%ADndices/Imagen3_IndexSeek.png)])

---

### 5. Conclusión

Las pruebas realizadas demuestran de forma concluyente que la aplicación estratégica de índices es el factor más crítico para la optimización de consultas en bases de datos de gran volumen.

Aunque los tiempos de respuesta fueron similares debido al almacenamiento en caché, la métrica de **Lecturas Lógicas** reveló la diferencia real en el consumo de recursos:

1.  El **Índice Agrupado** ofreció una mejora masiva (84% menos lecturas) al alinear el orden físico de los datos con la consulta.
2.  El **Índice No Agrupado Cubriente** fue el ganador en eficiencia (89% menos lecturas), ya que era una estructura más pequeña y especializada que satisfizo la consulta al 100% sin tocar la tabla principal.

Este proyecto confirma que entender los tipos de índices y cómo cubren una consulta es esencial para diseñar un sistema de base de datos rápido y escalable.

### 6. Bibliografía

* Microsoft (2025). *SQL Server Index Design Guide*. Recuperado de: `https://learn.microsoft.com/es-es/sql/relational-databases/sql-server-index-design-guide`
* Microsoft (2025). *Indexes - SQL Server*. Recuperado de: `https://learn.microsoft.com/es-es/sql/relational-databases/indexes/indexes?view=sql-server-ver16`
