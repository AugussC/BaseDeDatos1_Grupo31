# Procedimientos Almacenados
## Conceptos Fundamentales

Un procedimiento almacenado (stored procedure) es un conjunto de sentencias SQL precompiladas y almacenadas en el servidor de bases de datos. Su propósito es ejecutar tareas específicas —como consultas, actualizaciones o validaciones— de forma controlada y eficiente, evitando la repetición de código y mejorando el rendimiento general del sistema.

En términos simples, un procedimiento almacenado es un bloque de código reutilizable que puede recibir parámetros, ejecutar operaciones y devolver resultados o valores de salida. Constituye una herramienta clave en la administración, optimización y seguridad de las bases de datos.

Los procedimientos almacenados se utilizan ampliamente para:

- Automatizar procesos repetitivos.

- Aplicar reglas de negocio directamente en la base de datos.
 
- Controlar la integridad de los datos mediante validaciones centralizadas.

- Reducir el tráfico entre la aplicación y el servidor.

- Mejorar la seguridad al restringir el acceso directo a las tablas.

En su ejecución, el motor de la base de datos procesa el procedimiento una sola vez (compilación inicial) y almacena su plan de ejecución en memoria, lo que agiliza las llamadas posteriores.

## Estructura y Sintaxis Básica

La estructura general de un procedimiento almacenado varía según el gestor de base de datos (SQL Server, MySQL, Oracle, PostgreSQL, etc.), pero suele seguir el siguiente formato:
  ```sql
    CREATE PROCEDURE nombre_procedimiento
        @param1 tipo_dato [= valor_predeterminado],
        @param2 tipo_dato OUTPUT
    AS
    BEGIN
        -- Bloque de instrucciones SQL
        DECLARE @variable_local tipo_dato;
    
        SELECT @variable_local = columna
        FROM tabla
        WHERE condicion;
    
        UPDATE tabla
        SET campo = @param1
        WHERE otra_condicion;
    
        RETURN @@ROWCOUNT; -- Valor opcional de retorno
    END;
```
Elementos Principales:

- **CREATE PROCEDURE / ALTER PROCEDURE:** crea o modifica el procedimiento.

- **Parámetros:** pueden ser de entrada (INPUT), salida (OUTPUT) o ambos.

- **BEGIN/END:** delimitan el cuerpo del procedimiento.

- **RETURN:** devuelve un valor numérico opcional que indica el resultado de la ejecución.

## Ventajas del Uso de Procedimientos Almacenados

- Eficiencia y rendimiento:
Los procedimientos se compilan una sola vez y se almacenan en caché, reduciendo el tiempo de ejecución.

- Seguridad:
Permiten limitar el acceso directo a las tablas, de modo que los usuarios solo puedan interactuar a través de procedimientos controlados.

- Mantenibilidad:
Centralizan la lógica de negocio en el servidor, lo que simplifica la actualización del código sin necesidad de modificar las aplicaciones cliente.

- Reducción del tráfico de red:
En lugar de enviar múltiples comandos SQL desde la aplicación, se invoca un solo procedimiento, minimizando la comunicación entre cliente y servidor.

- Reutilización del código:
Los procedimientos pueden ser llamados desde distintas aplicaciones o procesos, fomentando la modularidad.

## Tipos de Procedimientos Almacenados

- Procedimientos del Usuario:
Definidos por el desarrollador para satisfacer necesidades específicas del sistema.
Ejemplo: registrar ventas, calcular descuentos, generar reportes, etc.

- Procedimientos del Sistema:
Incluidos por defecto en el motor de base de datos. Permiten realizar tareas administrativas, como crear tablas, consultar propiedades o modificar configuraciones internas.

- Procedimientos Recursivos:
Son aquellos que se llaman a sí mismos dentro de su propio cuerpo. Se utilizan para recorrer estructuras jerárquicas como árboles o listas enlazadas.

- Procedimientos Temporales:
Solo existen durante la sesión actual del usuario. Son útiles para operaciones puntuales o de prueba.
Parámetros y Valores de Retorno

### Los procedimientos almacenados pueden trabajar con distintos tipos de parámetros:

**Entrada (IN):** reciben valores al ser invocados.

**Salida (OUT):** devuelven valores al finalizar.

**Entrada/Salida (INOUT):** pueden modificarse dentro del procedimiento.

## Ejemplo:
```sql
CREATE PROCEDURE ObtenerSueldo
    @EmpleadoID INT,
    @Sueldo DECIMAL(10,2) OUTPUT
AS
BEGIN
    SELECT @Sueldo = salario
    FROM Empleados
    WHERE id = @EmpleadoID;
END;
```
### La ejecución sería:
```sql
DECLARE @Resultado DECIMAL(10,2);
EXEC ObtenerSueldo 101, @Resultado OUTPUT;
PRINT @Resultado;
```

### Manejo de Errores y Control de Transacciones

Dentro de un procedimiento almacenado, es posible manejar errores y fallos mediante bloques TRY...CATCH, garantizando la integridad de los datos mediante transacciones controladas.
Esto asegura que, si ocurre un error en alguna de las operaciones, se revierten los cambios, manteniendo la base de datos en un estado consistente.
```sql
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE Cuentas SET saldo = saldo - 100 WHERE id = 1;
    UPDATE Cuentas SET saldo = saldo + 100 WHERE id = 2;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error en la transferencia.';
END CATCH;
```

## Llamadas y Ejecución de Procedimientos

Los procedimientos almacenados se pueden ejecutar de distintas formas, dependiendo del sistema gestor:
```sql
EXEC nombre_procedimiento @parametro = valor;
-- o
CALL nombre_procedimiento(valor);
```

También pueden ser invocados desde otras aplicaciones o desde dentro de otro procedimiento (anidamiento), lo que permite construir estructuras modulares y jerárquicas.

## Diferencias entre Procedimientos Almacenados y Funciones Definidas por el Usuario
### 1. Tipo de operación

Procedimientos almacenados (SP):
Ejecutan operaciones completas: inserts, updates, deletes, prints, manejo de transacciones, llamadas a otros SP, etc.

Funciones (UDF):
Devuelven un valor (escalar) o una tabla.
Solo pueden calcular y devolver datos, nunca modificar tablas.

## 2. Uso en consultas

SP:
NO pueden usarse en SELECT, WHERE, JOIN, etc.
### 3. Permiten transacciones

SP:
Sí pueden iniciar, confirmar o deshacer transacciones (BEGIN TRAN / COMMIT / ROLLBACK).

UDF:
No permiten transacciones.

### 4. Efectos secundarios

SP:
Pueden generar efectos secundarios (modificar datos, imprimir mensajes, ejecutar SP anidados).

UDF:
No pueden modificar nada fuera de sí mismas.
No prints, no inserts, no updates.

### 5. Valores de retorno

SP:
Pueden devolver cero o muchos conjuntos de resultados (SELECTs).
Opcionalmente un valor de retorno entero (RETURN 0).
También pueden usar parámetros OUTPUT.

UDF:
Devuelven exactamente un valor:

## Procedimientos Almacenados y Concurrencia

Al ejecutarse en el servidor, los procedimientos almacenados aprovechan el control de concurrencia del motor de base de datos. Esto evita conflictos entre usuarios simultáneos que intentan acceder o modificar los mismos datos.

Mediante mecanismos de bloqueo (locking) y aislamiento (isolation levels), se garantiza que cada procedimiento mantenga la integridad de las operaciones que realiza.

## Evaluacion del rendimiento
Se realizo una pequeña prueba de eficiencia para obesrvar la comparacion de operaciones directas y procediementos almacenados. En la prueba que realizamos se puede
observar una diferencia de 1 ms a favor de la operacion directa por sobre la operacion con procedimientos. Esta diferencia se puede evidenciar mas
segun la cantidad de registros cargados.(La prueba se realizo con los datos cargados en el lote de datos subido)
![imagen1](https://github.com/AugussC/BaseDeDatos1_Grupo31/blob/main/Scripts/Tema%202%20Procedimientos%20Almacenados/MensajePruebaEficiencia.jpg?raw=true)

## Conclusión

Los procedimientos almacenados son un pilar fundamental en el diseño de sistemas de bases de datos robustos.
Permiten modularizar, asegurar y optimizar el acceso a los datos, reduciendo errores y mejorando la eficiencia del sistema.
Además, facilitan la consistencia lógica de las operaciones y la coordinación entre transacciones, integrándose estrechamente con otros mecanismos del gestor, como los disparadores, vistas y funciones definidas por el usuario.

### BIBLIOGRAFIA
1. Microsoft. (2025). Microsoft Learn. https://learn.microsoft.com/es-es/sql/relational-databases/stored-procedures/stored-procedures-database-engine?view=sql-server-ver17
3. W3Schools. SQL Stored Procedures for SQL Server. https://www.w3schools.com/sql/sql_stored_procedures.asp
