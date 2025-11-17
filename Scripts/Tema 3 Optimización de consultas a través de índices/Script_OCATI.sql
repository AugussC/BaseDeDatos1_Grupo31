USE Operador911;
GO
/*

PASO 0: PREPARACIÓN DE DATOS DE REFERENCIA (FOREIGN KEYS)
Para la demostracion de la Optimización de consultas a través de índices vamos a utilizar la tabla "Llamada", debido
a que tiene fechas.
La tabla "Llamada" depende de la tabla `Alerta`, que a su vez depende de `Usuario` y `Canal`. 
Por lo tanto, aseguramos que existan registros mínimos en estas tablas para que la carga masiva no falle por restricciones de Clave Foránea (FK).
*/
-- Asegurar que existe id_usuario = 1
IF NOT EXISTS (SELECT 1 FROM Usuario WHERE id_usuario = 1)
BEGIN
    SET IDENTITY_INSERT Usuario ON; 
    INSERT INTO Usuario (id_usuario, nombre, apellido, DNI, correo, contraseña, rol, activo)
    VALUES (1, 'Admin', 'User', 11122233, 'admin@911.com', 'hashedpassword', 'Jefe Operador', 1);
    SET IDENTITY_INSERT Usuario OFF;
END
GO

-- Asegurar que existe id_canal = 2 (Utilizamos = a 2 porque es el unico cargado en nuestra base)
IF NOT EXISTS (SELECT 1 FROM Canal WHERE id_canal = 2)
BEGIN
    SET IDENTITY_INSERT Canal ON;
    INSERT INTO Canal (id_canal, tipo_canal) 
    VALUES (2, 'Boton de Panico'); -- 'Boton de Panico' es un valor válido reconocido entre nuestros datos de la bdd
    SET IDENTITY_INSERT Canal OFF;
END
GO

-- Asegurar un mínimo de 100 alertas para que la carga masiva tenga referencias
DECLARE @StartId INT;
DECLARE @TargetCount INT = 100;
DECLARE @CurrentCount INT = (SELECT COUNT(*) FROM Alerta);

SELECT @StartId = ISNULL(MAX(id_alerta), 0) + 1 FROM Alerta;

IF @CurrentCount < @TargetCount
BEGIN
    DECLARE @i INT = @StartId;
    SET IDENTITY_INSERT Alerta ON; 
    WHILE @i < (@StartId + (@TargetCount - @CurrentCount))
    BEGIN
        -- Para esto, usamos id_canal = 2 
        INSERT INTO Alerta (id_alerta, estado, importancia, tipo_incidencia, direccion, id_usuario, id_canal)
        VALUES (@i, 'En Espera', 'Media', 'Robo', 'Calle Falsa ' + CAST(@i AS VARCHAR(10)), 1, 2); 
        SET @i = @i + 1;
    END
    SET IDENTITY_INSERT Alerta OFF;
END
GO


/*
PASO 1: CARGA MASIVA DE 1 MILLÓN DE REGISTROS
Necesitamos un volumen de datos grande para que la diferencia de rendimiento entre un 'Scan' y un 'Seek' sea medible y significativa.
Para esto, usamos una "Tally Table" (tabla auxiliar de números generada con una CTE) para insertar 1,000,000 de filas en un único lote, lo cual es 
infinitamente más rápido que un bucle WHILE. (El cual anteriormente me explotó la computadora)
*/

-- 1.1. Configuracion de la Sesion y Limpieza
SET DATEFORMAT YMD; -- Soluciona errores de conversión del formato de la fecha
TRUNCATE TABLE Llamada;
GO

-- Procedemos a la carga
DECLARE @TargetCount_Load INT = 1000000; 
DECLARE @StartDate_Load DATETIME = '2020-01-01'; 
DECLARE @EndDate_Load DATETIME = '2025-12-31'; 
DECLARE @TotalSeconds_Load INT = DATEDIFF(SECOND, @StartDate_Load, @EndDate_Load);
DECLARE @MaxAlertaId_Load INT;

SELECT @MaxAlertaId_Load = MAX(id_alerta) FROM Alerta;

IF @MaxAlertaId_Load IS NULL OR @MaxAlertaId_Load = 0 BEGIN
    SELECT 'Error: La tabla Alerta está vacía. Abortando.' AS Resultado;
    RETURN;
END

-- Activamos IDENTITY_INSERT para poder insertar 'id_llamada' manualmente (1, 2, 3...)
SET IDENTITY_INSERT Llamada ON;

;WITH E1(N) AS (SELECT 1 UNION ALL SELECT 1),  
E2(N) AS (SELECT 1 FROM E1 a, E1 b),          
E4(N) AS (SELECT 1 FROM E2 a, E2 b),          
E8(N) AS (SELECT 1 FROM E4 a, E4 b),          
E16(N) AS (SELECT 1 FROM E8 a, E8 b),         
E32(N) AS (SELECT 1 FROM E16 a, E16 b),       
Numbers(ID) AS (
    SELECT TOP (@TargetCount_Load) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) 
    FROM E32
)
INSERT INTO Llamada (id_llamada, fecha_creacion, nombre, telefono, id_alerta)
SELECT 
    n.ID,
    -- Colocamos ISNULL para prevenir errores de NULL. (Errores que me ocurrieeron en el proceso de carga)
    ISNULL(DATEADD(SECOND, ABS(CHECKSUM(NEWID()) % @TotalSeconds_Load), @StartDate_Load), @StartDate_Load),
    'Llamante ' + CAST(n.ID AS VARCHAR(10)), 
    '3794' + RIGHT('000000' + CAST(n.ID AS VARCHAR(10)), 6), 
    (n.ID % @MaxAlertaId_Load) + 1 
FROM 
    Numbers n
OPTION (MAXDOP 1); 

-- Desactivamos IDENTITY_INSERT
SET IDENTITY_INSERT Llamada OFF; 
-- nos va a devolver un mensajito para avisarnos que terminó la carga
SELECT 'Carga masiva completada: 1,000,000 de registros insertados.' AS Resultado;
GO


/*
PASO 2: PREPARACIÓN PARA PRUEBAS DE ÍNDICE AGRUPADO
Por defecto, el PRIMARY KEY (PK) de "Llamada" en "id_llamada" es CLUSTERED. 
Esto quiere decir que solo puede haber UN índice por tabla, debido a ser CLUSTERED.
Para solucionar esto, debemos eliminar el PK CLUSTERED y recrearlo como NON-CLUSTERED. 
Esto "libera" el espacio agrupado para que podamos usarlo en "fecha_creacion".
*/

-- 2.1. Encontrar el nombre real de la restricción PK
DECLARE @PK_Name NVARCHAR(200);
SELECT @PK_Name = name 
FROM sys.objects 
WHERE parent_object_id = OBJECT_ID('Llamada') AND type = 'PK';

-- 2.2. Eliminar el PK CLUSTERED y recrearlo como NON-CLUSTERED
IF @PK_Name IS NOT NULL
BEGIN
    EXEC('ALTER TABLE Llamada DROP CONSTRAINT ' + @PK_Name);
    EXEC('ALTER TABLE Llamada ADD CONSTRAINT PK_Llamada_Id PRIMARY KEY NONCLUSTERED (id_llamada)');
    PRINT 'PRIMARY KEY modificada a NON-CLUSTERED.';
END
ELSE
BEGIN
    PRINT 'PRIMARY KEY no encontrada o ya es NON-CLUSTERED.';
END
GO

/*
PASO 3: PRUEBA 1 - BASELINE
Por que lo hacemos?: Para medir el rendimiento "antes" de cualquier optimización. 
Para esto, ejecutamos la consulta de prueba y registramos el Plan, las Lecturas Lógicas y el Tiempo Transcurrido.
*/

PRINT '--- INICIANDO PRUEBA 1: BASELINE (SIN ÍNDICE EN FECHA) ---';
SET STATISTICS TIME ON; 
SET STATISTICS IO ON;

SELECT 
    id_llamada, 
    fecha_creacion, 
    nombre, 
    telefono
FROM 
    Llamada
WHERE 
    fecha_creacion >= '2022-01-01' 
    AND fecha_creacion < '2023-01-01'
ORDER BY 
    fecha_creacion;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
PRINT '--- FIN PRUEBA 1 ---';
GO
-- RESULTADO: Table Scan (o Non-Clustered Index Scan), Lecturas Lógicas: 10,330, Tiempo: 873 ms
/*
PASO 4: PRUEBA 2 - ÍNDICE AGRUPADO
Ahora queremos medir cómo la reordenación física de la tabla mejora la búsqueda.
Para esto, creamos el índice CLUSTERED en "fecha_creacion" y repetimos la consulta.
*/

PRINT '--- INICIANDO PRUEBA 2: ÍNDICE AGRUPADO (CLUSTERED) ---';

-- 4.1. Crear el Índice Agrupado
CREATE CLUSTERED INDEX IX_Llamada_FechaCreacion_Clustered 
ON Llamada (fecha_creacion ASC);
GO

-- 4.2. Repetir la consulta
SET STATISTICS TIME ON; 
SET STATISTICS IO ON;

SELECT 
    id_llamada, 
    fecha_creacion, 
    nombre, 
    telefono
FROM 
    Llamada
WHERE 
    fecha_creacion >= '2022-01-01' 
    AND fecha_creacion < '2023-01-01'
ORDER BY 
    fecha_creacion;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
PRINT '--- FIN PRUEBA 2 ---';
GO
-- RESULTADO: Clustered Index Seek, Lecturas Lógicas: 1,680, Tiempo: 887 ms
  
/*
PASO 5: LIMPIEZA INTERMEDIA
Para poder probar el último índice, debemos eliminar el índice agrupado.
*/

PRINT '--- LIMPIANDO ÍNDICE AGRUPADO (TAREA 4) ---';
DROP INDEX IX_Llamada_FechaCreacion_Clustered ON Llamada;
GO

/*
PASO 6: PRUEBA 3 - ÍNDICE CUBRIENTE
Ahora queremos medir un índice NON-CLUSTERED que "cubre" la consulta, incluyendo todas las columnas del SELECT.
Para esto, tenemos que crear el índice NON-CLUSTERED en "fecha_creacion" y usamos "INCLUDE" para añadir "nombre", 
"telefono" e "id_llamada".
*/

PRINT '--- INICIANDO PRUEBA 3: ÍNDICE CUBRIENTE (NON-CLUSTERED) ---';

-- 6.1. Crear el Índice Cubriente
CREATE NONCLUSTERED INDEX IX_Llamada_FechaCreacion_Covering_Correcto
ON Llamada (fecha_creacion ASC)
INCLUDE (nombre, telefono, id_llamada); -- Incluimos TODAS las columnas del SELECT
GO

-- 6.2. Repetir la consulta
SET STATISTICS TIME ON; 
SET STATISTICS IO ON;

SELECT 
    id_llamada, 
    fecha_creacion, 
    nombre, 
    telefono
FROM 
    Llamada
WHERE 
    fecha_creacion >= '2022-01-01' 
    AND fecha_creacion < '2023-01-01'
ORDER BY 
    fecha_creacion;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
PRINT '--- FIN PRUEBA 3 ---';
GO
-- RESULTADO: Index Seek (NonClustered), Lecturas Lógicas: 1,157, Tiempo: 872 ms
