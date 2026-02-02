use database_FormOpret
go

------------------------------------Sesion
--creacion de Trigger para auto incrementar el id_sesion de la tabla Sesion
CREATE OR ALTER TRIGGER trg_increment_Sesion
ON Sesion
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @max_id INT;
    DECLARE @new_id INT;
    DECLARE @next_grupo INT;

    -- Encontrar el ID m�ximo actual y agregar 1
    SELECT @max_id = ISNULL(MAX(id_sesion), 0) FROM Sesion;

    -- Generar nuevo ID
    SET @new_id = @max_id + 1;

    -- ?? Pr�ximo grupo_tema SOLO de sesiones activas
    SELECT @next_grupo = ISNULL(MAX(CAST(grupo_tema AS INT)), 0) + 1
    FROM Sesion
    WHERE estado = 1;

    -- Insertar nueva fila con el nuevo ID
    INSERT INTO Sesion(id_sesion, tipo_respuesta, grupo_tema, cod_pregunta, cod_subPregunta, rango, estado)

    SELECT 
        @new_id, 
        tipo_respuesta, 

        CASE 
           WHEN estado = 1 THEN CAST(@next_grupo AS VARCHAR(100))
           ELSE '0'
        END,
        
        cod_pregunta, 
        cod_subPregunta, 
        rango, 
        estado

    FROM inserted;
END
GO

--creacion de Trigger para auto incrementar el campo de grupo_tema de la tabla Sesion de acuerdo al estado y el id_sesion
CREATE OR ALTER TRIGGER  trg_reordenar_grupo_tema
ON Sesion
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Ejecutar SOLO si cambi� el estado
    IF NOT EXISTS (
        SELECT 1
        FROM inserted i
        JOIN deleted d ON i.id_sesion = d.id_sesion
        WHERE ISNULL(i.estado, 0) <> ISNULL(d.estado, 0)
    )
        RETURN;

    -- 2. Recalcular numeraci�n SOLO de sesiones activas
    ;WITH SesionesActivas AS (
        SELECT
            id_sesion,
            ROW_NUMBER() OVER (ORDER BY id_sesion) AS nuevo_grupo
        FROM Sesion
        WHERE estado = 1
    )

    -- 3. Actualizar TODA la tabla
    --    Activas  -> numeradas
    --    Inactivas -> '0'
    UPDATE s
    SET grupo_tema = 
        CASE
            WHEN s.estado = 1
                THEN CAST(sa.nuevo_grupo AS VARCHAR(100))
            ELSE
                '0'
        END
    FROM Sesion s
    LEFT JOIN SesionesActivas sa
        ON s.id_sesion = sa.id_sesion;

END;
GO

-----------------------------------------------Usuarios
--creacion de Trigger para auto incrementar el id_usuarios de la tabla RegistroUsuarios
CREATE TRIGGER trg_Increment_Usuarios
ON RegistroUsuarios
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @nuevoIdUsuario VARCHAR(100)
    DECLARE @rol VARCHAR(50)
    DECLARE @sufijo VARCHAR(50)
    DECLARE @nuevoSufijo INT
    DECLARE @maxId INT

    SELECT @rol = rol FROM inserted

    IF @rol = 'Empleado'
    BEGIN
        SET @sufijo = 'USER'
    END
    ELSE IF @rol = 'Administrador'
    BEGIN
        SET @sufijo = 'ADMIN'
    END

    -- Encontrar el ID m�ximo actual y agregar 1
    SELECT @maxId = MAX(CAST(SUBSTRING(id_usuarios, CHARINDEX('-', id_usuarios) + 2, LEN(id_usuarios)) AS INT))
    FROM RegistroUsuarios
    WHERE id_usuarios LIKE @sufijo + ' - %'

    -- Manejar el caso cuando no hay registros existentes para el sufijo
    IF @maxId IS NULL
    BEGIN
        SET @maxId = 0
    END

    SET @nuevoSufijo = @maxId + 1
    SET @nuevoIdUsuario = @sufijo + ' - ' + CAST(@nuevoSufijo AS VARCHAR)

    INSERT INTO RegistroUsuarios (id_usuarios, nombre_apellido, usuario, email, passwords, foto, fecha_creacion, rol)
    SELECT @nuevoIdUsuario, nombre_apellido, usuario, email, passwords, foto, fecha_creacion, rol
    FROM inserted
END
GO