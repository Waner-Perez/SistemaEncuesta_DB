use database_FormOpret
go

--------------------- Filtrar tabla de Sesion, SubPreguntas y Preguntas
create proc sp_ObtenerPreguntasCompleto
as
begin
	select
		s.id_sesion AS CodPregunta,
        s.tipo_respuesta AS TipoRespuesta,
		s.grupo_tema AS NoIdentifEncuesta,
        p.pregunta AS Pregunta,
        sub.sub_preguntas AS SubPregunta,
		--s.estado AS Estado,
		CAST(s.estado AS int) AS Estado, --CAST se utiliza para convertir un valor de un tipo de datos a otro. bit a int
        s.rango AS Rango
	FROM 
        Sesion s
    INNER JOIN 
        Pregunta p ON s.cod_pregunta = p.cod_pregunta
    LEFT JOIN 
        SubPreguntas sub ON s.cod_subPregunta = sub.cod_subPregunta;
end;
go

exec sp_ObtenerPreguntasCompleto;
--DROP PROCEDURE IF EXISTS sp_ObtenerPreguntasCompleto;

-- Stored Procedure para filtrar las estaciones del metro por Linea
create proc sp_ObternerEstacionesPorLinea
	@idLinea varchar(20)
as
begin
	select 
		e.id_estacion as idEstacion,
		l.nombre_linea as nombreLinea, 
		e.nombre_estacion as nombreEstacion
	from Estacion e
	join Linea l on e.id_linea = l.id_linea
	where e.id_linea = @idLinea
end
go

exec sp_ObternerEstacionesPorLinea @idLinea = 'LT001'

--DROP PROCEDURE IF EXISTS sp_ObternerEstacionesPorLinea;

--------------------- Filtrar tabla de Formularios, Linea y Estacion
-- Stored Procedure para obtener los formularios

create proc sp_ObtenerForm_Linea_Estacion
as
begin
	select
		f.id_usuarios as IdUsuarios,
		ru.usuario as Usuarios,
		ru.nombre_apellido as NombreApellido,
		f.fecha as FechaEncuesta,
		f.hora as HoraEncuesta,
		l.nombre_linea as NombreLinea,
		e.nombre_estacion as NombrEstacion
	from
		Formulario f
	inner join
		Linea l on f.id_linea = l.id_linea
	inner join
		Estacion e on f.id_estacion = e.id_estacion
	inner join
		RegistroUsuarios ru on f.id_usuarios = ru.id_usuarios
end
go

EXEC sp_ObtenerForm_Linea_Estacion;
--DROP PROCEDURE IF EXISTS sp_ObtenerForm_Linea_Estacion;

--Stored Procedure para obtener la las Respuesta con Usuarios, Preguntas, SupPreguntas y Sesion

create proc sp_ObtenerRespuestas
as
begin
	select
		R.id_usuarios as IdUsuarios,
		F.identifacador_form as IdForm,
		RU.nombre_apellido as NombreApellido,
		RU.usuario as Usuarios,
		R.no_encuesta as NoEncuesta,
		R.id_sesion as IdSesion,
		P.cod_pregunta as CodPreguntas,
		P.pregunta as Preguntas,
		SP.cod_subPregunta as CodSupPreguntas,
		SP.sub_preguntas as SubPreguntas,
		R.hora_respuestas as HoraResp,
		L.nombre_linea as NombreLinea,
		E.nombre_estacion as NombrEstacion,
		R.respuesta as Respuestas,
		R.comentarios as Comentarios,
		R.justificacion as Justificacion
	from
		Respuestas R
	inner join
		RegistroUsuarios RU on R.id_usuarios = RU.id_usuarios
	inner join
		Sesion S on R.id_sesion = S.id_sesion
	inner join
		Pregunta P on S.cod_pregunta = P.cod_pregunta
	left join
		SubPreguntas SP on S.cod_subPregunta = SP.cod_subPregunta
	INNER JOIN
		Formulario F on R.identifacador_form = F.identifacador_form
	INNER JOIN
		Linea L on F.id_linea = L.id_linea
	INNER JOIN
		Estacion E on F.id_estacion = E.id_estacion
end
go

EXEC sp_ObtenerRespuestas;

--Stored procedure para el autoincremento con fecha para la tabla Respuesta

create proc sp_InsertarRespuesta
    @idUsuarios VARCHAR(100), 
    @idSesion INT,
    @respuesta VARCHAR(255) = NULL,
    @comentarios VARCHAR(MAX) = NULL, 
    @justificacion VARCHAR(MAX) = NULL,
	@horaRespuestas varchar(100) = null,
	@fechaRespuestas VARCHAR(100) = NULL,
    @finalizarSesion BIT
AS
BEGIN
    DECLARE @year VARCHAR(4)
    DECLARE @orden INT
    DECLARE @noEncuesta VARCHAR(100)
	DECLARE @identifacador_form INT

    -- Obtener el a�o actual
    SET @year = CAST(YEAR(GETDATE()) AS VARCHAR(4))

	-- Obtener el identificador del formulario correspondiente al idUsuarios
	select top 1 @identifacador_form = identifacador_form
	from Formulario
	-- para que las respuesta encajen perfectamente con el formulario estas deberande coincidir con idUsuario y la fecha de las dos tablas
	where id_usuarios = @idUsuarios and fecha = @fechaRespuestas
	ORDER BY identifacador_form DESC -- esta cl�usula ayuda a seleccionar el formulario m�s reciente si hay m�ltiples formularios con la misma fecha para el mismo usuario.

    -- Insertar el nuevo registro en la tabla Respuestas
    -- Utilizando un noEncuesta temporal (NULL)
    INSERT INTO Respuestas (id_usuarios, no_encuesta, id_sesion, respuesta, comentarios, justificacion, hora_respuestas, identifacador_form, fecha_respuestas)
    VALUES (@idUsuarios, NULL, @idSesion, @respuesta, @comentarios, @justificacion, @horaRespuestas, @identifacador_form, @fechaRespuestas)

    -- Generar el noEncuesta y actualizarlo solo si se finaliza la sesi�n
    IF @finalizarSesion = 1
	BEGIN
		-- Obtener el numero de orden correctamente
		SELECT @orden = ISNULL(MAX(CONVERT(INT, SUBSTRING(no_encuesta, CHARINDEX(' - ', no_encuesta) + 3, LEN(no_encuesta) - CHARINDEX(' - ', no_encuesta) - 2))), 0) + 1
		FROM Respuestas
		WHERE no_encuesta IS NOT NULL 
		  AND TRY_CAST(SUBSTRING(no_encuesta, CHARINDEX(' - ', no_encuesta) + 3, LEN(no_encuesta) - CHARINDEX(' - ', no_encuesta) - 2) AS INT) IS NOT NULL
		  AND YEAR(GETDATE()) = YEAR(GETDATE())

		-- Generar el noEncuesta
		SET @noEncuesta = @year + ' - ' + CAST(@orden AS VARCHAR)

		-- Actualizar los registros en la tabla Respuestas
		UPDATE Respuestas
		SET no_encuesta = @noEncuesta
		WHERE no_encuesta IS NULL
	END

    /*BEGIN
        -- Obtener el n�mero de orden global para el a�o actual
        SELECT @orden = ISNULL(MAX(CONVERT(INT, SUBSTRING(no_encuesta, 8, 2))), 0) + 1
        FROM Respuestas
        WHERE no_encuesta IS NOT NULL AND YEAR(GETDATE()) = YEAR(GETDATE())

        -- Generar el noEncuesta
        SET @noEncuesta = @year + ' - ' + RIGHT('00' + CAST(@orden AS VARCHAR(2)), 2)

        -- Actualizar el no_encuesta en la tabla Respuestas para el conjunto de preguntas
        UPDATE Respuestas
        SET no_encuesta = @noEncuesta
        WHERE no_encuesta IS NULL
    END*/
END
go

SELECT no_encuesta FROM Respuestas WHERE no_encuesta LIKE '2025 - %' ORDER BY no_encuesta DESC
SELECT TOP 10 * FROM Respuestas ORDER BY fecha_respuestas DESC

--DROP PROCEDURE IF EXISTS sp_InsertarRespuesta;

--como se le debe de insertar los datos 

EXEC sp_InsertarRespuesta 
    @idUsuarios = 'USER - 1', 
    @idSesion = 1,
	@horaRespuestas = '10:11:10 AM',
    @respuesta = 'Si',
    @comentarios = 'Algunos comentarios adicionales',
    @justificacion = 'Una justificaci�n adicional',
	@fechaRespuestas = '11-03-2025',
    @finalizarSesion = 1 

EXEC sp_InsertarRespuesta 
    @idUsuarios = 'USER - 1', 
    @idSesion = 1,
	@horaRespuestas = '10:11:10 AM',
    @respuesta = 'Si',
    @comentarios = 'Algunos comentarios adicionales',
    @justificacion = 'Una justificaci�n adicional',
	@fechaRespuestas = '11-03-2025',
    @finalizarSesion = 1

EXEC sp_InsertarRespuesta 
    @idUsuarios = 'USER - 1', 
    @idSesion = 1,
	@horaRespuestas = '10:11 AM',
    @respuesta = 'No',
    @comentarios = 'Algunos comentarios adicionales',
    @justificacion = 'Una justificaci�n adicional',
	@fechaRespuestas = '11-03-2025',
    @finalizarSesion = 0

EXEC sp_InsertarRespuesta 
    @idUsuarios = 'USER - 1', 
    @idSesion = 2,
	@horaRespuestas = '10:30 AM',
    @respuesta = '15 - 25',
    @comentarios = 'Algunos comentarios adicionales',
    @justificacion = 'Una justificaci�n adicional',
	@fechaRespuestas = '11-03-2025',
    @finalizarSesion = 0

EXEC sp_InsertarRespuesta 
    @idUsuarios = 'USER - 1', 
    @idSesion = 3,
	@horaRespuestas = '10:45 AM',
    @respuesta = '10',
    @comentarios = 'Algunos comentarios adicionales',
    @justificacion = 'Una justificaci�n adicional',
	@fechaRespuestas = '11-03-2025',
    @finalizarSesion = 1

/*
objetivo de este campo @finalizarSesion es que si es igual a 0 entonces no debera de incrementarce el noEncuesta, 
pero si es igual a 1 entonces si se incrementara el noEncuesta en la parte de numero de orden
*/

--Stored procedure para el la exportacion de los reportes en formato Excel
create proc sp_Report_Respuestas
as
begin
	select
		R.id_usuarios as rp_IdUsuarios,
		RU.nombre_apellido as rp_NombreApellido,
		RU.usuario as rp_Usuarios,
		RU.email as rp_Email,
		F.identifacador_form as rp_IdFormulario,
		F.fecha as rp_FechaInicioEncuesta,
		F.hora as rp_HoraInicioEncuesta,
		L.nombre_linea as rp_NombreLinea,
		E.nombre_estacion as rp_NombreEstacion,
		S.id_sesion as rp_IdSesion,
		S.cod_pregunta as rp_CodPreg,
		P.pregunta as rp_Pregunta,
		S.cod_subPregunta as rp_CodSubPreg,
		SP.sub_preguntas as rp_SubPregunta,
		R.no_encuesta as rp_NoEncuestas,
		S.tipo_respuesta as rp_TipoResp,
		R.hora_respuestas as rp_HoraRespondida,
		R.respuesta as rp_Respuestas,
		R.comentarios as rp_Comentarios,
		R.justificacion as rp_Justificacion

	from
		Respuestas R
	INNER JOIN 
		RegistroUsuarios RU ON R.id_usuarios = RU.id_usuarios
    INNER JOIN 
		Formulario F ON R.identifacador_form = F.identifacador_form
    INNER JOIN 
		Linea L ON F.id_linea = L.id_linea
    INNER JOIN 
		Estacion E ON F.id_estacion = E.id_estacion
    INNER JOIN 
		Sesion S ON R.id_sesion = S.id_sesion
    INNER JOIN 
		Pregunta P ON S.cod_pregunta = P.cod_pregunta
    LEFT JOIN -- (se utiliza LEFT JOIN porque puede que no siempre exista una subpregunta).
		SubPreguntas SP ON S.cod_subPregunta = SP.cod_subPregunta
end
go

EXEC sp_Report_Respuestas;