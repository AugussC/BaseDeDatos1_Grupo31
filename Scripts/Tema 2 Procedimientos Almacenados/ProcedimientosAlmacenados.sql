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



