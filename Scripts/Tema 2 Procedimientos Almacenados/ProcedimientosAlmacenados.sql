/*
     Explicacion practica de un procedimiento almacenado usando la base de datos del proyecto y 
     usando un caso simple para su mejor entendimiento. Paso a paso.
     Un procedimiento almacenado tal como su nombre indica es un procedimiento que si bien se podria 
     hacer dentro de el codigo en si de una aplicacion, se hace dentro de la propia base de datos para una mejor 
     optimizacion. Es recomendable su uso cuando se operan con datos directos de la base de datos y son operaciones simples
     que no requieren un registro externo en la app/sistema.
*/


USE [Operador911BD];  -- 1) Selecciona la base de datos donde se creará el procedimiento
GO

-- 2) Si ya existe el procedimiento con este nombre, lo eliminamos para poder recrearlo sin error.
IF OBJECT_ID('dbo.sp_ObtenerPatrullasActivas', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_ObtenerPatrullasActivas;
GO

-- 3) Creación del procedimiento almacenado
--    Nombre: dbo.sp_ObtenerPatrullasActivas
--    Objetivo: devolver todas las patrullas cuyo campo "activo" = 1
CREATE PROCEDURE dbo.sp_ObtenerPatrullasActivas
AS
BEGIN
    -- 4) Inicio del bloque de código del procedimiento

    SET NOCOUNT ON; 
    -- 5) Evita mensajes adicionales de "n rows affected" que pueden interferir con aplicaciones clientes.

    -- 6) Consulta principal: selecciona columnas relevantes de la tabla Patrulla
    --    (se listan columnas específicas en vez de SELECT * para buenas prácticas)
    SELECT 
        id_patrulla,
        codigo_patrulla,
        tipo,
        estado,
        id_comisaria,
        activo
    FROM dbo.Patrulla
    WHERE activo = 1;  -- 7) Filtramos solo las patrullas activas

    -- 8) Fin del bloque del procedimient
END;
GO

/*
    Luego para su posterior ejecucion se utiliza la palabra reservada EXEC y el nombre asignado al procedimiento
*/

USE [Operador911BD];
EXEC dbo.sp_ObtenerPatrullasActivas;

/*
    Salida esperada al ejecutar: Un conjunto de filas con las columnas id_patrulla,
    codigo_patrulla, tipo, estado, id_comisaria,activo para cada patrulla cuyo activo = 1
*/


-- Estos dos procedimientos ya estaban creados previamente, asumiendo su uso para el proyecto de taller 2 --
---------------------------------------------------------------
-- PROCEDIMIENTO ANIDADO: REGISTRAR UBICACIÓN DE PATRULLA
---------------------------------------------------------------
CREATE   PROCEDURE [dbo].[sp_RegistrarUbicacionPatrulla]
    @id_patrulla INT,
    @latitud DECIMAL(9,6),
    @longitud DECIMAL(9,6),
    @orden INT 
AS
BEGIN
    BEGIN TRY
        SAVE TRANSACTION SaveUbicacion;

        INSERT INTO Ubicacion (id_patrulla, latitud, longitud, orden)
        VALUES (@id_patrulla, @latitud, @longitud, @orden);

        PRINT 'Ubicación registrada correctamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Error al registrar la ubicación. Se revierte el bloque.';
        ROLLBACK TRANSACTION SaveUbicacion;
    END CATCH
END;


---------------------------------------------------------------
-- PROCEDIMIENTO PRINCIPAL: ASIGNAR PATRULLA A ALERTA
---------------------------------------------------------------
CREATE   PROCEDURE [dbo].[sp_AsignarPatrullaAAlerta]
    @id_alerta INT,
    @id_patrulla INT,
    @latitud DECIMAL(9,6),
    @longitud DECIMAL(9,6),
    @orden INT 
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN;

        DECLARE @estadoAlerta VARCHAR(50);
        DECLARE @patrullaActiva INT;

        -- Verificar si la alerta sigue pendiente
        SELECT @estadoAlerta = estado FROM Alerta WHERE id_alerta = @id_alerta;

        IF (@estadoAlerta <> 'En Espera')
            RAISERROR('La alerta no está en estado pendiente.', 16, 1);

        -- Verificar si la patrulla está disponible
        SELECT @patrullaActiva = COUNT(*) 
        FROM Alerta 
        WHERE id_patrulla = @id_patrulla AND estado = 'Asignada';

        IF (@patrullaActiva > 0)
            RAISERROR('La patrulla ya está asignada a otra alerta.', 16, 1);

        -- Asignar patrulla a alerta
        UPDATE Alerta
        SET id_patrulla = @id_patrulla,
            estado = 'Asignada'
        WHERE id_alerta = @id_alerta;

        PRINT 'Patrulla asignada a alerta.';

        -- Llamar al procedimiento anidado
        EXEC sp_RegistrarUbicacionPatrulla 
            @id_patrulla = @id_patrulla,
            @latitud = @latitud,
            @longitud = @longitud,
            @orden = @orden;

        COMMIT TRAN;
        PRINT 'Transacción completada con éxito.';
    END TRY
    BEGIN CATCH
        PRINT 'Error detectado. Se revierte la transacción principal.';
        ROLLBACK TRAN;
        PRINT ERROR_MESSAGE();
    END CATCH
END;

----------------------------------------------------------------
-- 1) LOTE DE INSERT DIRECTO (ejemplo práctico)
----------------------------------------------------------------
use Operador911BD
PRINT '--- Lote INSERT directo: inicio ---';

-- Insertar canales
INSERT INTO Canal (tipo_canal) VALUES
('Boton de Panico'), ('Alerta'), ('Camara');
PRINT 'Canales insertados.';

-- Insertar usuarios (operadores / comisario)
INSERT INTO Usuario (nombre, apellido, DNI, correo, contraseña, rol, activo)
VALUES
('Diego', 'Sosa', 30111222, 'diego.sosa@policia.local', 'hash1', 'Jefe Operador', 1),
('Laura', 'Martinez', 30122333, 'laura.martinez@policia.local', 'hash2', 'Operador', 1),
('Martín', 'Gomez',   30133444, 'martin.gomez@policia.local', 'hash3', 'Comisario', 1);
PRINT 'Usuarios insertados.';

-- Insertar comisarías (nota: id_usuario_comisario puede ser nulo o referenciar Usuario)
INSERT INTO Comisaria (nombre, direccion, telefono, latitud, longitud, id_usuario_comisario)
VALUES
('Comisaria Central', 'Av. Principal 100', '0351123456', -31.416, -64.183, 3),
('Comisaria Norte',   'Calle Norte 234',     '0351987654', -31.370, -64.180, NULL);
PRINT 'Comisarías insertadas.';

-- Insertar patrullas
INSERT INTO Patrulla (codigo_patrulla, tipo, estado, id_comisaria, activo)
VALUES
('P-001', 'Camioneta', 'En Servicio', 1, 1),
('P-002', 'Moto',      'En Base',     2, 1),
('P-003', 'Auto',      'Ocupado',     1, 1);
PRINT 'Patrullas insertadas.';

-- Insertar policías
INSERT INTO Policia (nombre, apellido, DNI, id_comisaria, activo, genero)
VALUES
('Carlos', 'Perez', 40111222, 1, 1, 'M'),
('María',  'Lopez', 40122333, 2, 1, 'F');
PRINT 'Policías insertados.';

-- Insertar planillas (combinación patrulla-policia)
INSERT INTO Planilla (id_patrulla, nro_placa, dia_semana, turno)
VALUES
(1, 1, 'Lunes', '06-18'),
(2, 2, 'Martes', '18-06');
PRINT 'Planillas insertadas.';

-- Insertar alertas (hay FK a Usuario y Canal; id_patrulla puede ser NULL)
INSERT INTO Alerta (estado, importancia, tipo_incidencia, direccion, fecha_cierre, id_usuario, id_patrulla, id_canal)
VALUES
('En Espera', 'Alta', 'Robo', 'Calle Falsa 123', NULL, 2, 1, 1),
('En Espera', 'Media','Accidente', 'Ruta 9 km 10',   NULL, 2, 3, 2);
PRINT 'Alertas insertadas.';

-- Insertar llamadas (FK a Alerta)
INSERT INTO Llamada (fecha_creacion, nombre, telefono, id_alerta)
VALUES
(GETDATE(), 'Vecino A', '351111111', 1),
(GETDATE(), 'Automovilista', '351222222', 2);
PRINT 'Llamadas insertadas.';

-- Insertar ubicaciones (para patrullas)
INSERT INTO Ubicacion (id_patrulla, latitud, longitud, orden)
VALUES
(1, -31.4160, -64.1830, 1),
(1, -31.4170, -64.1840, 2),
(2, -31.3700, -64.1800, 1);
PRINT 'Ubicaciones insertadas.';

-- Insertar reportes (FKs compuestas a Planilla)
INSERT INTO Reporte (descripcion, id_alerta, id_patrulla, nro_placa, id_planilla)
VALUES
('Reporte inicial - llegada al lugar', 1, 1, 1, 1),
('Reporte secundario - control vehicular', 2, 2, 2, 2);
PRINT 'Reportes insertados.';

PRINT '--- Lote INSERT directo: fin ---';
GO

----------------------------------------------------------------
-- 2) PROCEDIMIENTOS DE INSERCIÓN (uno por tabla principal)
----------------------------------------------------------------
use Operador911BD

--  Insertar Canal
IF OBJECT_ID('dbo.sp_InsertCanal','P') IS NOT NULL DROP PROCEDURE dbo.sp_InsertCanal;
GO
CREATE PROCEDURE dbo.sp_InsertCanal
    @tipo_canal VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    -- Inserta un nuevo tipo de canal
    INSERT INTO Canal (tipo_canal) VALUES (@tipo_canal);
    PRINT 'Canal insertado via SP.';
END;
GO

-- Insertar Usuario
IF OBJECT_ID('dbo.sp_InsertUsuario','P') IS NOT NULL DROP PROCEDURE dbo.sp_InsertUsuario; 
GO
CREATE PROCEDURE dbo.sp_InsertUsuario
    @nombre VARCHAR(100),
    @apellido VARCHAR(100),
    @DNI INT,
    @correo VARCHAR(100),
    @contrasena VARCHAR(300),
    @rol NVARCHAR(20),
    @activo BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Usuario (nombre, apellido, DNI, correo, contraseña, rol, activo)
    VALUES (@nombre, @apellido, @DNI, @correo, @contrasena, @rol, @activo);
    PRINT 'Usuario insertado via SP.';
END;
GO

-- Insertar Comisaria
IF OBJECT_ID('dbo.sp_InsertComisaria','P') IS NOT NULL DROP PROCEDURE dbo.sp_InsertComisaria;
GO
CREATE PROCEDURE dbo.sp_InsertComisaria
    @nombre VARCHAR(200),
    @direccion VARCHAR(150),
    @telefono VARCHAR(20),
    @latitud FLOAT,
    @longitud FLOAT,
    @id_usuario_comisario INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Comisaria (nombre, direccion, telefono, latitud, longitud, id_usuario_comisario)
    VALUES (@nombre, @direccion, @telefono, @latitud, @longitud, @id_usuario_comisario);
    PRINT 'Comisaria insertada via SP.';
END;
GO

-- Insertar Patrulla
IF OBJECT_ID('dbo.sp_InsertPatrulla','P') IS NOT NULL DROP PROCEDURE dbo.sp_InsertPatrulla;
GO
CREATE PROCEDURE dbo.sp_InsertPatrulla
    @codigo_patrulla VARCHAR(20),
    @tipo VARCHAR(20),
    @estado VARCHAR(20),
    @id_comisaria INT,
    @activo BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Patrulla (codigo_patrulla, tipo, estado, id_comisaria, activo)
    VALUES (@codigo_patrulla, @tipo, @estado, @id_comisaria, @activo);
    PRINT 'Patrulla insertada via SP.';
END;
GO

-- Insertar Policia
IF OBJECT_ID('dbo.sp_InsertPolicia','P') IS NOT NULL DROP PROCEDURE dbo.sp_InsertPolicia;
GO
CREATE PROCEDURE dbo.sp_InsertPolicia
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @DNI INT,
    @id_comisaria INT,
    @activo BIT = 1,
    @genero CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Policia (nombre, apellido, DNI, id_comisaria, activo, genero)
    VALUES (@nombre, @apellido, @DNI, @id_comisaria, @activo, @genero);
    PRINT 'Policia insertado via SP.';
END;
GO

-- Insertar Planilla
IF OBJECT_ID('dbo.sp_InsertPlanilla','P') IS NOT NULL DROP PROCEDURE dbo.sp_InsertPlanilla;
GO
CREATE PROCEDURE dbo.sp_InsertPlanilla
    @id_patrulla INT,
    @nro_placa INT,
    @dia_semana VARCHAR(10),
    @turno VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Planilla (id_patrulla, nro_placa, dia_semana, turno)
    VALUES (@id_patrulla, @nro_placa, @dia_semana, @turno);
    PRINT 'Planilla insertada via SP.';
END;
GO

-- Insertar Alerta
IF OBJECT_ID('dbo.sp_InsertAlerta','P') IS NOT NULL DROP PROCEDURE dbo.sp_InsertAlerta;
GO
CREATE PROCEDURE dbo.sp_InsertAlerta
    @estado NVARCHAR(20),
    @importancia VARCHAR(10),
    @tipo_incidencia VARCHAR(100),
    @direccion VARCHAR(150),
    @id_usuario INT,
    @id_patrulla INT = NULL,
    @id_canal INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Alerta (estado, importancia, tipo_incidencia, direccion, fecha_cierre, id_usuario, id_patrulla, id_canal)
    VALUES (@estado, @importancia, @tipo_incidencia, @direccion, NULL, @id_usuario, @id_patrulla, @id_canal);
    PRINT 'Alerta insertada via SP.';
END;
GO

-- Insertar Llamada
IF OBJECT_ID('dbo.sp_InsertLlamada','P') IS NOT NULL DROP PROCEDURE dbo.sp_InsertLlamada;
GO
CREATE PROCEDURE dbo.sp_InsertLlamada
    @nombre VARCHAR(50),
    @telefono VARCHAR(50),
    @id_alerta INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Llamada (fecha_creacion, nombre, telefono, id_alerta)
    VALUES (GETDATE(), @nombre, @telefono, @id_alerta);
    PRINT 'Llamada insertada via SP.';
END;
GO

-- Insertar Ubicacion
IF OBJECT_ID('dbo.sp_InsertUbicacion','P') IS NOT NULL DROP PROCEDURE dbo.sp_InsertUbicacion;
GO
CREATE PROCEDURE dbo.sp_InsertUbicacion
    @id_patrulla INT,
    @latitud FLOAT,
    @longitud FLOAT,
    @orden INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Ubicacion (id_patrulla, latitud, longitud, orden)
    VALUES (@id_patrulla, @latitud, @longitud, @orden);
    PRINT 'Ubicacion insertada via SP.';
END;
GO

-- Insertar Reporte
IF OBJECT_ID('dbo.sp_InsertReporte','P') IS NOT NULL DROP PROCEDURE dbo.sp_InsertReporte;
GO
CREATE PROCEDURE dbo.sp_InsertReporte
    @descripcion VARCHAR(2000),
    @id_alerta INT,
    @id_patrulla INT,
    @nro_placa INT,
    @id_planilla INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Reporte (descripcion, id_alerta, id_patrulla, nro_placa, id_planilla)
    VALUES (@descripcion, @id_alerta, @id_patrulla, @nro_placa, @id_planilla);
    PRINT 'Reporte insertado via SP.';
END;
GO

----------------------------------------------------------------
-- 3) LOTE DE INSERT invocando a los PROCEDIMIENTOS
----------------------------------------------------------------
use Operador911BD
PRINT '--- Lote INSERT via SP: inicio ---';

EXEC dbo.sp_InsertCanal 'Camara';
EXEC dbo.sp_InsertUsuario 'Sofia','Diaz', 30144555, 'sofia.diaz@policia.local', 'hash4', 'Operador', 1;
EXEC dbo.sp_InsertComisaria 'Comisaria Oeste', 'Boulevard Oeste 50', '035100000', -31.430, -64.190, NULL;
EXEC dbo.sp_InsertPatrulla 'P-010', 'Camioneta', 'En Servicio', 1, 1;
EXEC dbo.sp_InsertPolicia 'Lucas','Alvarez', 40133445, 1, 1, 'M';
EXEC dbo.sp_InsertPlanilla 1, 3, 'Miercoles', '06-18';
EXEC dbo.sp_InsertAlerta N'En Espera', 'Baja', 'Incendio', 'Barrio Verde 45', 2, NULL, 3;
EXEC dbo.sp_InsertLlamada 'Denunciante B', '351333333', 3;
EXEC dbo.sp_InsertUbicacion 1, -31.4180, -64.1850, 3;
EXEC dbo.sp_InsertReporte 'Reporte via SP - verificación', 3, 1, 1, 3;

PRINT '--- Lote INSERT via SP: fin ---';

----------------------------------------------------------------
-- 4) PROCEDIMIENTOS para UPDATE y DELETE
----------------------------------------------------------------

--cambiar estado de patrulla
IF OBJECT_ID('dbo.sp_UpdatePatrullaEstado','P') IS NOT NULL DROP PROCEDURE dbo.sp_UpdatePatrullaEstado; GO
CREATE PROCEDURE dbo.sp_UpdatePatrullaEstado
    @id_patrulla INT,
    @nuevoEstado VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM Patrulla WHERE id_patrulla = @id_patrulla)
    BEGIN
        RAISERROR('Patrulla no existe.', 16, 1);
        RETURN;
    END
    UPDATE Patrulla
    SET estado = @nuevoEstado
    WHERE id_patrulla = @id_patrulla;
    PRINT 'Estado de patrulla actualizado via SP.';
END;
GO

-- eliminar patrulla (ejemplo con chequeo de dependencias simples)
IF OBJECT_ID('dbo.sp_DeletePatrulla','P') IS NOT NULL DROP PROCEDURE dbo.sp_DeletePatrulla; GO
CREATE PROCEDURE dbo.sp_DeletePatrulla
    @id_patrulla INT
AS
BEGIN
    SET NOCOUNT ON;
    -- No permitir borrado si hay reportes o ubicaciones asociadas
    IF EXISTS (SELECT 1 FROM Reporte WHERE id_patrulla = @id_patrulla)
    BEGIN
        RAISERROR('No se puede eliminar: existen reportes asociados a la patrulla.', 16, 1);
        RETURN;
    END
    IF EXISTS (SELECT 1 FROM Ubicacion WHERE id_patrulla = @id_patrulla)
    BEGIN
        RAISERROR('No se puede eliminar: existen ubicaciones asociadas a la patrulla.', 16, 1);
        RETURN;
    END
    DELETE FROM Patrulla WHERE id_patrulla = @id_patrulla;
    PRINT 'Patrulla eliminada via SP.';
END;
GO

-- Actualizamos estado de la patrulla 3 a 'En Base'
EXEC dbo.sp_UpdatePatrullaEstado 3, 'En Base';
GO

----------------------------------------------------------------
-- 5) PROCEDIMIENTO PARA COMPARAR EFICIENCIA

----------------------------------------------------------------

-- SP auxiliar
IF OBJECT_ID('dbo.sp_ListarPatrullasPorComisaria','P') IS NOT NULL DROP PROCEDURE dbo.sp_ListarPatrullasPorComisaria; 
GO
CREATE PROCEDURE dbo.sp_ListarPatrullasPorComisaria
    @id_comisaria INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT id_patrulla, codigo_patrulla, tipo, estado, activo
    FROM Patrulla
    WHERE id_comisaria = @id_comisaria;
END;
GO

-- SP principal que activa medición
IF OBJECT_ID('dbo.sp_CompararEficienciaPatrullas','P') IS NOT NULL DROP PROCEDURE dbo.sp_CompararEficienciaPatrullas; 
GO
CREATE PROCEDURE dbo.sp_CompararEficienciaPatrullas
    @id_comisaria INT
AS
BEGIN
    SET NOCOUNT ON;

    PRINT '=== COMIENZA PRUEBA DE EFICIENCIA: SELECT directo vs SP ===';

    -- A) Operación directa
    PRINT 'A) Consulta DIRECTA:';
    SET STATISTICS TIME ON;       -- activamos medición
    SELECT id_patrulla, codigo_patrulla, tipo, estado, activo
    FROM Patrulla
    WHERE id_comisaria = @id_comisaria;
    SET STATISTICS TIME OFF;      -- apagamos medición

    -- B) Operación usando SP
    PRINT 'B) Consulta mediante PROCEDIMIENTO (SP):';
    SET STATISTICS TIME ON;
    EXEC dbo.sp_ListarPatrullasPorComisaria @id_comisaria = @id_comisaria;
    SET STATISTICS TIME OFF;

    PRINT '=== FIN PRUEBA DE EFICIENCIA ===';
END;
GO
/*
    Ejecucion de la prueba, en la prueba que realizamos se puede observar una diferencia de 1 ms a favor
    de la operacion directa por sobre la operacion con procedimientos. Esta diferencia se puede evidenciar mas
    segun la cantidad de registros cargados.(La prueba se realizo con los datos cargados en el lote de datos subido)
*/
EXEC dbo.sp_CompararEficienciaPatrullas 1

-- Los siguientes procedimientos almacenados no se usan activamenete en el proyecto de taller, se crean como ejemplos --
---------------------------------------------------------------
-- PROCEDIMIENTO: CREAR ALERTA
---------------------------------------------------------------
CREATE PROCEDURE [dbo].[sp_CrearAlerta]
    @estado NVARCHAR(20),
    @importancia VARCHAR(10),
    @tipo_incidencia VARCHAR(100),
    @direccion VARCHAR(150),
    @id_usuario INT,
    @id_canal INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN;

        -- Verificar usuario existente
        IF NOT EXISTS (SELECT 1 FROM Usuario WHERE id_usuario = @id_usuario AND activo = 1)
            RAISERROR('El usuario no existe o está inactivo.', 16, 1);

        -- Verificar canal existente
        IF NOT EXISTS (SELECT 1 FROM Canal WHERE id_canal = @id_canal)
            RAISERROR('El canal especificado no existe.', 16, 1);

        INSERT INTO Alerta (estado, importancia, tipo_incidencia, direccion, fecha_cierre, id_usuario, id_patrulla, id_canal)
        VALUES (@estado, @importancia, @tipo_incidencia, @direccion, NULL, @id_usuario, NULL, @id_canal);

        PRINT 'Alerta creada correctamente.';

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        PRINT 'Error al crear la alerta. Se revierte la transacción.';
        ROLLBACK TRAN;
        PRINT ERROR_MESSAGE();
    END CATCH
END;

---------------------------------------------------------------
-- PROCEDIMIENTO: CERRAR ALERTA
---------------------------------------------------------------
CREATE PROCEDURE [dbo].[sp_CerrarAlerta]
    @id_alerta INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN;

        DECLARE @estadoActual VARCHAR(20);

        SELECT @estadoActual = estado FROM Alerta WHERE id_alerta = @id_alerta;

        IF (@estadoActual IS NULL)
            RAISERROR('La alerta no existe.', 16, 1);

        IF (@estadoActual = 'Atendida')
            RAISERROR('La alerta ya está cerrada.', 16, 1);

        UPDATE Alerta
        SET estado = 'Atendida',
            fecha_cierre = GETDATE()
        WHERE id_alerta = @id_alerta;

        PRINT 'Alerta cerrada exitosamente.';

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        PRINT 'Error al cerrar la alerta. Se revierte la transacción.';
        ROLLBACK TRAN;
        PRINT ERROR_MESSAGE();
    END CATCH
END;


---------------------------------------------------------------
-- PROCEDIMIENTO: REGISTRAR LLAMADA
---------------------------------------------------------------
CREATE PROCEDURE [dbo].[sp_RegistrarLlamada]
    @id_alerta INT,
    @nombre VARCHAR(50),
    @telefono VARCHAR(50)
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN;

        IF NOT EXISTS (SELECT 1 FROM Alerta WHERE id_alerta = @id_alerta)
            RAISERROR('La alerta vinculada no existe.', 16, 1);

        INSERT INTO Llamada (fecha_creacion, nombre, telefono, id_alerta)
        VALUES (GETDATE(), @nombre, @telefono, @id_alerta);

        PRINT 'Llamada registrada correctamente.';

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        PRINT 'Error al registrar la llamada. Se revierte la transacción.';
        ROLLBACK TRAN;
        PRINT ERROR_MESSAGE();
    END CATCH
END;

---------------------------------------------------------------
-- PROCEDIMIENTO: ACTUALIZAR ESTADO DE PATRULLA
---------------------------------------------------------------
CREATE PROCEDURE [dbo].[sp_ActualizarEstadoPatrulla]
    @id_patrulla INT,
    @estado VARCHAR(20)
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN;

        IF NOT EXISTS (SELECT 1 FROM Patrulla WHERE id_patrulla = @id_patrulla)
            RAISERROR('La patrulla no existe.', 16, 1);

        UPDATE Patrulla
        SET estado = @estado
        WHERE id_patrulla = @id_patrulla;

        PRINT 'Estado de patrulla actualizado correctamente.';

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        PRINT 'Error al actualizar el estado de la patrulla. Se revierte la transacción.';
        ROLLBACK TRAN;
        PRINT ERROR_MESSAGE();
    END CATCH
END;


---------------------------------------------------------------
-- PROCEDIMIENTO: GENERAR REPORTE DE INTERVENCIÓN
---------------------------------------------------------------
CREATE PROCEDURE [dbo].[sp_GenerarReporteIntervencion]
    @descripcion VARCHAR(2000),
    @id_alerta INT,
    @id_patrulla INT,
    @nro_placa INT,
    @id_planilla INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN;

        -- Validar FK compuesta
        IF NOT EXISTS (
            SELECT 1 
            FROM Planilla 
            WHERE id_planilla = @id_planilla
            AND id_patrulla = @id_patrulla
            AND nro_placa = @nro_placa
        )
            RAISERROR('La combinación de planilla, patrulla y policía no es válida.', 16, 1);

        -- Validar alerta existente
        IF NOT EXISTS (SELECT 1 FROM Alerta WHERE id_alerta = @id_alerta)
            RAISERROR('La alerta indicada no existe.', 16, 1);

        INSERT INTO Reporte (descripcion, id_alerta, id_patrulla, nro_placa, id_planilla)
        VALUES (@descripcion, @id_alerta, @id_patrulla, @nro_placa, @id_planilla);

        PRINT 'Reporte registrado exitosamente.';

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        PRINT 'Error al registrar el reporte. Se revierte la transacción.';
        ROLLBACK TRAN;
        PRINT ERROR_MESSAGE();
    END CATCH
END;

/*
     Procedimientos anidados: procedimientos que llaman a otros prpocedimientos
*/

---------------------------------------------------------------
-- PROCEDIMIENTO: OBTENER PATRULLAS ACTIVAS (procedimeinto interno)
---------------------------------------------------------------
     
USE Operador911BD;
GO

IF OBJECT_ID('dbo.sp_ObtenerPatrullasActivas', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_ObtenerPatrullasActivas;
GO

CREATE PROCEDURE dbo.sp_ObtenerPatrullasActivas
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        id_patrulla,
        codigo_patrulla,
        tipo,
        estado,
        id_comisaria,
        activo
    FROM dbo.Patrulla
    WHERE activo = 1;
END;
GO


---------------------------------------------------------------
-- PROCEDIMIENTO: GENERAR INFORME DE PATRULLAS ACTIVAS (procedimiento externo)
---------------------------------------------------------------

USE Operador911BD;
GO

-- Si existe, lo eliminamos
IF OBJECT_ID('dbo.sp_InformePatrullasActivas', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_InformePatrullasActivas;
GO

-- Procedimiento externo: llama al procedimiento interno
CREATE PROCEDURE dbo.sp_InformePatrullasActivas
AS
BEGIN
    SET NOCOUNT ON;

    -- 1) Muestra un encabezado para dar contexto al informe
    PRINT '==============================';
    PRINT ' INFORME DE PATRULLAS ACTIVAS ';
    PRINT '==============================';

    -- 2) Llamamos al procedimiento almacenado interno
    --    Esto demuestra la anidación de procedimientos almacenados.
    EXEC dbo.sp_ObtenerPatrullasActivas;

    -- 3) Mensaje final
    PRINT '------ FIN DEL INFORME ------';
END;
GO
