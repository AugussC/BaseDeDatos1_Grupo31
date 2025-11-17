USE Operador911BD;
GO

/*TABLA DE AUDITORÍA*/
CREATE TABLE [dbo].[Auditoria_Alerta](
    [id_auditoria] INT IDENTITY(1,1) PRIMARY KEY,
    [id_alerta] INT NOT NULL,
    [estado_anterior] NVARCHAR(20) NOT NULL,
    [importancia_anterior] VARCHAR(10) NOT NULL,
    [tipo_incidencia_anterior] VARCHAR(100) NOT NULL,
    [direccion_anterior] VARCHAR(150) NOT NULL,
    [fecha_cierre_anterior] DATETIME NULL,
    [id_usuario_anterior] INT NOT NULL,
    [id_patrulla_anterior] INT NULL,
    [id_canal_anterior] INT NOT NULL,
    [fecha_operacion] DATETIME NOT NULL DEFAULT GETDATE(),
    [usuario_bd] SYSNAME NOT NULL,
    [tipo_operacion] VARCHAR(10) NOT NULL
);
GO


/*TRIGGER DE AUDITORÍA – UPDATE SOBRE ALERTA*/
CREATE TRIGGER TR_Alerta_Auditoria_Update
ON [dbo].[Alerta]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Auditoria_Alerta(
        id_alerta, estado_anterior, importancia_anterior,
        tipo_incidencia_anterior, direccion_anterior,
        fecha_cierre_anterior, id_usuario_anterior,
        id_patrulla_anterior, id_canal_anterior,
        fecha_operacion, usuario_bd, tipo_operacion
    )
    SELECT
        d.id_alerta, d.estado, d.importancia,
        d.tipo_incidencia, d.direccion,
        d.fecha_cierre, d.id_usuario,
        d.id_patrulla, d.id_canal,
        GETDATE(), SUSER_SNAME(), 'UPDATE'
    FROM deleted d;
END;
GO


/*TRIGGER DE AUDITORÍA – DELETE SOBRE ALERTA*/
CREATE TRIGGER TR_Alerta_Auditoria_Delete
ON [dbo].[Alerta]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Auditoria_Alerta(
        id_alerta, estado_anterior, importancia_anterior,
        tipo_incidencia_anterior, direccion_anterior,
        fecha_cierre_anterior, id_usuario_anterior,
        id_patrulla_anterior, id_canal_anterior,
        fecha_operacion, usuario_bd, tipo_operacion
    )
    SELECT
        d.id_alerta, d.estado, d.importancia,
        d.tipo_incidencia, d.direccion,
        d.fecha_cierre, d.id_usuario,
        d.id_patrulla, d.id_canal,
        GETDATE(), SUSER_SNAME(), 'DELETE'
    FROM deleted d;
END;
GO


/*TRIGGER QUE BLOQUEA DELETE DE USUARIOS*/
CREATE TRIGGER TR_Usuario_Bloquear_Delete
ON [dbo].[Usuario]
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR(
        'No está permitido eliminar usuarios. Debe marcarse como inactivo.',
        16, 1
    );
END;
GO


/* CASOS DE PRUEBA*/
PRINT '=== Caso 2.1: Cambiar importancia de una alerta ===';
UPDATE Alerta
SET importancia = 'Media'
WHERE id_alerta = 1;   -- usar un id real
GO

PRINT '=== Caso 2.2: Cambiar estado de una alerta ===';
UPDATE Alerta
SET estado = 'Cerrada'
WHERE id_alerta = 17;
GO

PRINT '=== Caso 2.3: Cambiar múltiples campos ===';
UPDATE Alerta
SET importancia = 'Alta',
    estado = 'En Proceso',
    direccion = 'Av. Independencia 1234'
WHERE id_alerta = 25;
GO

PRINT '=== Caso 2.4: UPDATE múltiple (varias filas) ===';
UPDATE Alerta
SET importancia = 'Baja'
WHERE importancia = 'Media';
GO


/*CONSULTAS DE AUDITORÍA DESPUÉS DE LOS UPDATE*/

PRINT '=== Auditoría después de los cambios ===';
SELECT * FROM Auditoria_Alerta ORDER BY fecha_operacion DESC;
GO

PRINT '=== Auditoría solo de operaciones UPDATE ===';
SELECT *
FROM Auditoria_Alerta
WHERE tipo_operacion = 'UPDATE'
ORDER BY fecha_operacion DESC;
GO


/*PRUEBA DEL TRIGGER QUE BLOQUEA EL DELETE DE USUARIOS*/
PRINT '=== Caso 4.1: Intento de borrar un usuario (debe fallar) ===';
DELETE FROM Usuario
WHERE id_usuario = 9;  -- usar id real, NO se borra
GO


/*INFORME DE TRAZABILIDAD (HISTORIAL DE UNA ALERTA)*/
PRINT '=== Trazabilidad completa de la alerta con id = 1 ===';
SELECT 
    id_alerta,
    estado_anterior,
    importancia_anterior,
    direccion_anterior,
    fecha_operacion,
    usuario_bd
FROM Auditoria_Alerta
WHERE id_alerta = 1
ORDER BY fecha_operacion ASC;
GO
