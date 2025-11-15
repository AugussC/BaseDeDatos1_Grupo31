/* 
---------------------------------------------------------------
  TEMA: MANEJO DE TRANSACCIONES Y TRANSACCIONES ANIDADAS
---------------------------------------------------------------
Las transacciones permiten ejecutar un conjunto de instrucciones 
SQL como una unidad lógica: o todas se completan con éxito (COMMIT)
o ninguna se aplica (ROLLBACK). 

Las transacciones anidadas surgen cuando dentro de una transacción 
se ejecuta otra (por ejemplo, un procedimiento que llama a otro).
Esto permite mayor control: se pueden realizar “savepoints” para 
deshacer parcialmente operaciones sin cancelar toda la transacción.

---------------------------------------------------------------
  CASO PRÁCTICO – SISTEMA DE ALERTAS POLICIALES
---------------------------------------------------------------
Escenario:
- Cuando llega una nueva alerta, se asigna una patrulla disponible.
- Simultáneamente se registra la ubicación actual de esa patrulla.
- Si ocurre un error (por ejemplo, la patrulla ya está ocupada),
  se deshace todo el proceso.

El proceso se realiza usando dos procedimientos:
  1. sp_AsignarPatrullaAAlerta → transacción principal.
  2. sp_RegistrarUbicacionPatrulla → transacción anidada.
*/

DROP PROCEDURE IF EXISTS sp_AsignarPatrullaAAlerta;
GO
DROP PROCEDURE IF EXISTS sp_RegistrarUbicacionPatrulla;
GO


---------------------------------------------------------------
-- PROCEDIMIENTO ANIDADO: REGISTRAR UBICACIÓN DE PATRULLA
---------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_RegistrarUbicacionPatrulla
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
GO


---------------------------------------------------------------
-- PROCEDIMIENTO PRINCIPAL: ASIGNAR PATRULLA A ALERTA
---------------------------------------------------------------
CREATE OR ALTER PROCEDURE sp_AsignarPatrullaAAlerta
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
GO



/* ================================================================
   DATOS DE PRUEBA
=================================================================*/

-- 1️⃣ Crear Alertas nuevas (simulando llamadas entrantes)
INSERT INTO Alerta (estado, importancia, tipo_incidencia, direccion, id_usuario, id_patrulla, id_canal)
VALUES 
('En Espera', 'Alta',  'Robo en progreso', 'Av. Colón 1234', 1, NULL, 2),
('En Espera', 'Media', 'Disturbio en la vía pública', 'San Martín 450', 1, NULL, 2),
('En Espera', 'Baja',  'Ruido molesto', 'Ituzaingó 920', 1, NULL, 2),
('En Espera', 'Alta',  'Accidente de tránsito', 'Bv. Illia 1020', 1, NULL, 2);
GO

-- 2️⃣ Crear llamadas asociadas
INSERT INTO Llamada (fecha_creacion, nombre, telefono, id_alerta)
VALUES 
(GETDATE(), 'Carlos Pérez', '3516547890', 48),
(GETDATE(), 'Ana López', '3517982345', 49),
(GETDATE(), 'Jorge Díaz', '3519234567', 50),
(GETDATE(), 'Lucía Torres', '3517776655', 51);
GO

-- 3️⃣ Patrulla ocupada (para prueba de error)
UPDATE Alerta
SET id_patrulla = 13, estado = 'Asignada'
WHERE id_alerta = 44;
GO

-- 4️⃣ Verificación de datos
SELECT 
    a.id_alerta, a.estado, a.importancia, a.tipo_incidencia, a.direccion, 
    a.id_usuario, a.id_patrulla, l.id_llamada, l.telefono
FROM Alerta a
JOIN Llamada l ON a.id_alerta = l.id_alerta
WHERE a.estado = 'En Espera';
GO


---------------------------------------------------------------
-- PRUEBA 1: TRANSACCIÓN EXITOSA
---------------------------------------------------------------
EXEC sp_AsignarPatrullaAAlerta 
    @id_alerta = 45, -- Puede variar de 45 a 51
    @id_patrulla = 14,  -- patrulla libre
    @latitud = -31.420083,
    @longitud = -64.188776,
    @orden = 1;
GO

-- En caso de que falle aplicar
UPDATE ALERTA
SET estado = 'En Espera'
WHERE id_alerta = 45

UPDATE ALERTA
SET id_patrulla = NULL
WHERE id_alerta = 45
---------------------------------------------------------------
-- PRUEBA 2: TRANSACCIÓN FALLIDA (PATRULLA YA ASIGNADA)
---------------------------------------------------------------
EXEC sp_AsignarPatrullaAAlerta 
    @id_alerta = 46,
    @id_patrulla = 13,  -- patrulla ocupada
    @latitud = -31.425000,
    @longitud = -64.190000,
    @orden = 1;
GO

EXEC sp_AsignarPatrullaAAlerta 
    @id_alerta = 44,  -- Alerta asignada
    @id_patrulla = 15,  
    @latitud = -31.425000,
    @longitud = -64.190000,
    @orden = 1;
GO

---------------------------------------------------------------
-- FIN DEL SCRIPT - CONSULTAS DE CONTROL
---------------------------------------------------------------
SELECT * FROM Alerta;
SELECT * FROM Llamada;
SELECT * FROM Ubicacion;
SELECT * FROM Patrulla;
GO


