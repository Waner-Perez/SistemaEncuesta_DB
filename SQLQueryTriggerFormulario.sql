use database_FormOpret
go

--creacion de Trigger para auto incrementar el id_sesion de la tabla Sesion
create TRIGGER trg_increment_Sesion
ON Sesion
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @max_id INT;
    DECLARE @new_id INT;

    -- Encontrar el ID máximo actual y agregar 1
    SELECT @max_id = ISNULL(MAX(id_sesion), 0) FROM Sesion;

    -- Generar nuevo ID
    SET @new_id = @max_id + 1;

    -- Insertar nueva fila con el nuevo ID
    INSERT INTO Sesion(id_sesion, tipo_respuesta, grupo_tema, cod_pregunta, cod_subPregunta, rango, estado)
    SELECT @new_id, tipo_respuesta, grupo_tema, cod_pregunta, cod_subPregunta, rango, estado
    FROM inserted;
END
GO

--creacion de Trigger para auto incrementar el id_usuarios de la tabla RegistroUsuarios

create TRIGGER trg_Increment_Usuarios
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

    -- Encontrar el ID máximo actual y agregar 1
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