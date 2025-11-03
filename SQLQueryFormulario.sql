use database_FormOpret
go

--nueva tabla RegistroUsuarios
create table RegistroUsuarios (
	id_usuarios varchar(100) primary key not null, --no ingresar datos en este campo
	nombre_apellido varchar(200) not null,
	usuario varchar(50) unique not null,
	email varchar(100) unique not null,
	passwords varchar(300) not null,
	foto varbinary(max) null,
	fecha_creacion varchar(100) null,
	rol varchar(50) null,
)
go

-- tabla de Reseteo de Password
create table PasswordResetToken (
	token varchar(100) primary key not null,
	id_usuarios varchar(100) not null,
	expiration DATETIME not null
)
go

--nueva tabla de Sesion
create table Sesion(
	id_sesion int primary key not null,
	tipo_respuesta varchar(100) not null,
	grupo_tema varchar(100) null,
	cod_pregunta int not null,
	cod_subPregunta varchar(100) null,
	rango varchar(100) null,
	estado bit
)
go

--nueva tabla de preguntas
create table Pregunta (
	cod_pregunta int primary key not null,
	pregunta varchar(255) null
)
go

INSERT INTO Pregunta (cod_pregunta, pregunta) VALUES
(1, 'ES EMPLEADO DE OPRET/MSD'),
(2, 'GENERO'),
(3, 'EDAD'),
(4, 'NACIONALIDAD'),
(5, 'TITULO DE TRANSPORTE'),
(6, 'PRODUCTO UTILIZADO'),
(7, 'MOTIVO DEL VIAJE'),
(8, 'FRECUENCIA DE VIAJES POR SEMANA'),
(9, 'VALORACION METRO-TELEFERICO'),
(10, 'TIEMPO EN FILA PARA INGRESAR A LA ESTACION'),
(11, 'TIEMPO DE ESPERA TREN EN ANDEN'),
(12, 'PUNTUALIDAD TREN'),
(13, 'TIEMPO DE ESPERA CABINA TELEFERICO'),
(14, 'PUNTUALIDAD CABINA TELEFERICO'),
(15, 'PARADA ANORMAL EN EL TREN'),
(16, 'PARADA ANORMAL EN EL TELEFERICO'),
(17, 'ATENCION Y/O AMABILIDAD DEL PERSONAL DE METRO'),
(18, 'ATENCION Y/O AMABILIDAD DEL PERSONAL DE CESMET'),
(19, 'ATENCION ANTE QUEJAS Y RECLAMACIONES'),
(20, 'DISPONIBILIDAD DE MENUDO EN LAS BOLETERIAS'),
(21, 'LIMPIEZA ESTACIONES'),
(22, 'MANTENIMIENTO ESTACIONES'),
(23, 'ILUMINACION ESTACIONES'),
(24, 'VENTILACION ESTACIONES'),
(25, 'TEMPERATURA ESTACIONES'),
(26, 'LIMPIEZA TRENES'),
(27, 'MANTENIMIENTO TRENES'),
(28, 'ILUMINACION TRENES'),
(29, 'TEMPERATURA TRENES'),
(30, 'TEMPERATURA EN EL TREN'),
(31, 'LIMPIEZA CABINAS TELEFERICO'),
(32, 'MANTENIMIENTO TELEFERICO'),
(33, 'ILUMINACION CABINAS TELEFERICO'),
(34, 'VENTILACION CABINA TELEFERICO'),
(35, 'NIVEL DE RUIDO EN INSTALACIONES'),
(36, 'SEGURIDAD ANTE ROBOS'),
(37, 'SEGURIDAD ANTE AGRESIONES'),
(38, 'SEGURIDAD ANTE ACCIDENTES'),
(39, 'RESPETO AL MEDIO AMBIENTE'),
(40, 'ESPACIO DISPONIBLE EN LOS TRENES'),
(41, 'DISPONIBILIDAD ESCALERAS ELECTRICAS'),
(42, 'DISPONIBILIDAD ASCENSORES'),
(43, 'PROCESO COMPRA-RECARGA'),
(44, 'CANTIDAD DE TORNIQUETES'),
(45, 'DISPONIBILIDAD DE TORNIQUETES'),
(46, 'PROCESO DE INFORMACION ANTE INCIDENCIAS'),
(47, 'SEÑALIZACION EN ESTACIONES'),
(48, 'SEÑALIZACION EN TRENES');


--nueva tabla de SubPreguntas
create table SubPreguntas (
	cod_subPregunta varchar(100) primary key not null,
	sub_preguntas varchar(255) null
)
go

insert into SubPreguntas (cod_subPregunta, sub_preguntas) values
	('P-4.A', 'VALORACION IMPORTANCIA 0-10'),
	('P-4.B', ' VALORACION SERVICIO RECIBIDO 0-10'),
	('P-5', 'EXPECTATIVA DEL PASAJERO PARA EL FUTURO');

--nueva tabla de respuestas
create table Respuestas(
	id_respuestas int primary key identity(1,1) not null,
	id_usuarios varchar(100) not null,
	no_encuesta varchar(100) null,
	id_sesion int not null,
	respuesta varchar(255) null,
	comentarios varchar(max) null,
	justificacion varchar(max) null,
	hora_respuestas varchar(100),
	fecha_respuestas VARCHAR(100) NULL,
	identifacador_form int
)
go

--tabla de Formulario
create table Formulario ( --registro de inicio del formulario
	identifacador_form int primary key identity(1,1),
	id_usuarios varchar(100) not null,
	fecha varchar(100) null,
	hora varchar(100) null,
	id_estacion int null,
	id_linea varchar(20) null
)
go

--tabla de Linea
create table Linea (
	id_linea varchar(20) primary key not null,
	tipo_linea varchar(50) not null,
	nombre_linea varchar(255)
)
go

insert into Linea values('LM001', 'Linea Metro', 'Linea 1')
insert into Linea values('LM002', 'Linea Metro', 'Linea 2')
insert into Linea values('LT001', 'Linea Teleferico', 'T1')

--tabla de Estacion
create table Estacion (
	id_estacion int primary key not null,
	id_linea varchar(20) not null,
	nombre_estacion varchar(255)
)
go

insert into Estacion values(7, 'LM001', 'Los Taínos');
insert into Estacion values(1, 'LM001', 'Mamá Tingó');
insert into Estacion values(2, 'LM001', 'Gregorio Urbano Gilbert');
insert into Estacion values(3, 'LM001', 'Gregorio Luperón');
insert into Estacion values(4, 'LM001', 'José Francisco Peña Gómez');
insert into Estacion values(5, 'LM001', 'Hermanas Mirabal');
insert into Estacion values(6, 'LM001', 'Máximo Gómez');
insert into Estacion values(8, 'LM001', 'Pedro Livio Cedeño');
insert into Estacion values(9, 'LM001', 'Manuel Arturo Peña Batlle');
insert into Estacion values(10, 'LM001', 'Juan Pablo Duarte');
insert into Estacion values(11, 'LM001', 'Juan Bosch');
insert into Estacion values(12, 'LM001', 'Casandra Damirón');
insert into Estacion values(13, 'LM001', 'Joaquín Balaguer');
insert into Estacion values(14, 'LM001', 'Amín Abel');
insert into Estacion values(15, 'LM001', 'Francisco Alberto Caamaño');
insert into Estacion values(16, 'LM001', 'Centro de los Héroes');

insert into Estacion values(17, 'LM002', 'María Montez');
insert into Estacion values(18, 'LM002', 'Pedro Francisco Bonó');
insert into Estacion values(19, 'LM002', 'Ulises F. Espaillat');
insert into Estacion values(20, 'LM002', 'Eduardo Brito');
insert into Estacion values(21, 'LM002', 'Juan Pablo Duarte');
insert into Estacion values(22, 'LM002', 'Francisco Gregorio Billini');
insert into Estacion values(23, 'LM002', 'Pedro Mir');
insert into Estacion values(24, 'LM002', 'Freddy Beras Goico');
insert into Estacion values(25, 'LM002', 'Juan Ulises García');
insert into Estacion values(26, 'LM002', 'Coronel Rafael Tomas Fernández');
insert into Estacion values(27, 'LM002', 'Mauricio Baez');
insert into Estacion values(28, 'LM002', 'Ramón Cáceres');
insert into Estacion values(29, 'LM002', 'Horacio Vásquez');
insert into Estacion values(30, 'LM002', 'Manuel de Jesús Abreu Galvan');
insert into Estacion values(31, 'LM002', 'Ercilia Pepín');
insert into Estacion values(32, 'LM002', 'Rosa Duarte');
insert into Estacion values(33, 'LM002', 'Trina de Moya de Vásquez');
insert into Estacion values(34, 'LM002', 'Concepción Bona');

insert into Estacion values(35, 'LT001', 'Gualey');
insert into Estacion values(36, 'LT001', 'Tres Brazos');
insert into Estacion values(37, 'LT001', 'Sabana Perdida');
insert into Estacion values(38, 'LT001', 'Charles de Gaulle');

---------------------------------------------------------Foreign Key

-- --------------------------------registroForm
-- Formulario - Usuarios
alter table Formulario 
add constraint fk_User_Form
foreign key (id_usuarios) 
references RegistroUsuarios(id_usuarios)

-- Formulario - Linea
alter table Formulario add constraint fk_Formulario_Linea
foreign key (id_linea) references Linea(id_linea)

-- Formulario - Estacion
alter table Formulario add constraint fk_Formulario_Estacion
foreign key (id_estacion) references Estacion(id_estacion)

-- -------------------------------repuesta
-- Respuestas - Sesion
alter table Respuestas add constraint fk_Respuestas_Sesion
foreign key (id_sesion) references Sesion(id_sesion)

-- Respuestas - Usuarios
alter table Respuestas add constraint fk_Respuestas_User
foreign key (id_usuarios) references RegistroUsuarios(id_usuarios)

-- Respuestas - Formulario
alter table Respuestas add constraint fk_Respuestas_Form
foreign key (identifacador_form) references Formulario(identifacador_form)

-- -------------------------------Sesion

-- Sesion - Sub_Preguntas
alter table Sesion add constraint fk_Sesion_SubPreguntas
foreign key ([cod_subPregunta]) references SubPreguntas([cod_subPregunta])

-- Sesion - Preguntas
alter table [dbo].[Sesion] add constraint fk_Sesion_Pregunta
foreign key ([cod_pregunta]) references [dbo].[Pregunta]([cod_pregunta])

----------------------------------Estacion
alter table Estacion add constraint fk_Estacion_linea
foreign key (id_linea) references Linea(id_linea)

----------------------------------PasswordResetToken
-- PasswordResetToken - RegistroUsuarios
alter table PasswordResetToken add constraint fk_Token_Usuarios
foreign key (id_usuarios) references RegistroUsuarios(id_usuarios)