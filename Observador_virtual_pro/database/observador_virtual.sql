-- ============================================================
--  OBSERVADOR VIRTUAL - I.J.P. Company
--  Base de Datos MySQL
--  Archivo: observador_virtual.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS observador_virtual
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE observador_virtual;

-- ------------------------------------------------------------
-- TABLA: usuarios
-- Almacena todos los usuarios del sistema (docentes, admin, acudientes)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS usuarios (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    nombre        VARCHAR(100) NOT NULL,
    email         VARCHAR(150) NOT NULL UNIQUE,
    usuario       VARCHAR(80)  NOT NULL UNIQUE,
    contrasena    VARCHAR(255) NOT NULL,          -- Se recomienda almacenar hash (bcrypt)
    rol           ENUM('admin','docente','acudiente') NOT NULL DEFAULT 'acudiente',
    activo        TINYINT(1) NOT NULL DEFAULT 1,
    creado_en     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- TABLA: recuperacion_contrasena
-- Códigos temporales para restablecimiento de contraseña
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS recuperacion_contrasena (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id    INT          NOT NULL,
    codigo        VARCHAR(10)  NOT NULL,
    expira_en     DATETIME     NOT NULL,
    usado         TINYINT(1)   NOT NULL DEFAULT 0,
    creado_en     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_recup_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- TABLA: grados
-- Grados escolares (10-A, 10-B, 11-A …)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS grados (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    nombre        VARCHAR(20)  NOT NULL,   -- Ej: "10"
    curso         VARCHAR(20)  NOT NULL,   -- Ej: "B"
    descripcion   VARCHAR(100),
    creado_en     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- TABLA: estudiantes
-- Información completa del estudiante
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS estudiantes (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    codigo_estudiante   VARCHAR(20)  NOT NULL UNIQUE,   -- Ej: 2023-00452
    nombres             VARCHAR(100) NOT NULL,
    apellidos           VARCHAR(100) NOT NULL,
    foto                VARCHAR(255),                   -- Ruta relativa a la foto
    grado_id            INT          NOT NULL,
    fecha_nacimiento    DATE,
    acudiente_nombre    VARCHAR(150),
    acudiente_telefono  VARCHAR(30),
    acudiente_email     VARCHAR(150),
    activo              TINYINT(1)   NOT NULL DEFAULT 1,
    creado_en           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_est_grado FOREIGN KEY (grado_id) REFERENCES grados(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- TABLA: documentos_estudiante
-- Archivos adjuntos del estudiante (doc. identidad, EPS, etc.)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS documentos_estudiante (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    estudiante_id       INT          NOT NULL,
    tipo_documento      ENUM('documento_identidad','certificado_eps','cedula_acudiente','acta_compromiso','otro') NOT NULL,
    nombre_archivo      VARCHAR(255) NOT NULL,
    ruta_archivo        VARCHAR(500) NOT NULL,
    subido_por          INT,                            -- usuario_id que subió el archivo
    creado_en           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_doc_estudiante FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id) ON DELETE CASCADE,
    CONSTRAINT fk_doc_usuario    FOREIGN KEY (subido_por)    REFERENCES usuarios(id)    ON DELETE SET NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- TABLA: observaciones
-- Registro de observaciones académicas / convivenciales
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS observaciones (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    estudiante_id       INT          NOT NULL,
    fecha               DATE         NOT NULL,
    tipo                ENUM('academico','convivencial','general') NOT NULL DEFAULT 'general',
    periodo             VARCHAR(20),                    -- Ej: "2023-2", "I Período"
    observacion         TEXT         NOT NULL,
    aspecto_academico   TEXT,
    aspecto_convivencial TEXT,
    compromiso          VARCHAR(255),
    firma               VARCHAR(150),                   -- Nombre del docente/directivo firmante
    docente_id          INT,                            -- usuario que registra la observación
    creado_en           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_obs_estudiante FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id) ON DELETE CASCADE,
    CONSTRAINT fk_obs_docente    FOREIGN KEY (docente_id)    REFERENCES usuarios(id)    ON DELETE SET NULL
) ENGINE=InnoDB;

-- ============================================================
-- DATOS DE PRUEBA
-- ============================================================

-- Usuarios de prueba (contraseña = "password123" — en producción usar hash)
INSERT INTO usuarios (nombre, email, usuario, contrasena, rol) VALUES
('Administrador',    'admin@ijpcompany.edu.co',    'admin',       'password123', 'admin'),
('Prof. Gómez',      'gomez@ijpcompany.edu.co',    'prof_gomez',  'password123', 'docente'),
('Coord. Académica', 'coord@ijpcompany.edu.co',    'coord_acad',  'password123', 'docente'),
('Prof. Rodríguez',  'rodriguez@ijpcompany.edu.co','prof_rod',    'password123', 'docente'),
('Director de Grupo','director@ijpcompany.edu.co', 'dir_grupo',   'password123', 'docente'),
('Juan Pérez',       'juan.perez@gmail.com',       'juan_perez',  'password123', 'acudiente');

-- Grados
INSERT INTO grados (nombre, curso, descripcion) VALUES
('10', 'A', 'Décimo grado grupo A'),
('10', 'B', 'Décimo grado grupo B'),
('11', 'A', 'Undécimo grado grupo A'),
('11', 'B', 'Undécimo grado grupo B'),
('9',  'A', 'Noveno grado grupo A'),
('9',  'B', 'Noveno grado grupo B');

-- Estudiantes de prueba
INSERT INTO estudiantes (codigo_estudiante, nombres, apellidos, grado_id, fecha_nacimiento, acudiente_nombre, acudiente_telefono, acudiente_email) VALUES
('2023-00452', 'Carlos',    'Martínez Torres',  2, '2008-03-14', 'María Torres',    '3101234567', 'maria.torres@gmail.com'),
('2023-00453', 'Valentina', 'García López',     2, '2008-07-22', 'Pedro García',    '3107654321', 'pedro.garcia@gmail.com'),
('2023-00454', 'Santiago',  'Rodríguez Pérez',  1, '2008-01-10', 'Ana Pérez',       '3112345678', 'ana.perez@gmail.com'),
('2023-00455', 'Camila',    'Hernández Silva',  1, '2008-11-05', 'Luis Hernández',  '3118765432', 'luis.hern@gmail.com'),
('2023-00456', 'Sebastián', 'López Ramírez',    3, '2007-06-18', 'Rosa Ramírez',    '3151234567', 'rosa.ram@gmail.com'),
('2023-00457', 'Isabella',  'Gómez Castro',     4, '2007-09-30', 'Jorge Gómez',     '3157654321', 'jorge.gom@gmail.com'),
('2023-00458', 'Mateo',     'Díaz Morales',     2, '2008-02-25', 'Carmen Morales',  '3161234567', 'carmen.mor@gmail.com'),
('2023-00459', 'Sofía',     'Vargas Jiménez',   2, '2008-08-12', 'Alberto Vargas',  '3167654321', 'alberto.var@gmail.com'),
('2023-00460', 'Nicolás',   'Suárez Mendoza',   5, '2009-04-03', 'Patricia Mendoza','3171234567', 'patricia.men@gmail.com'),
('2023-00461', 'Mariana',   'Torres Ríos',      6, '2009-12-19', 'Roberto Torres',  '3177654321', 'roberto.tor@gmail.com'),
('2023-00462', 'Tomás',     'Flores Aguilar',   2, '2008-05-07', 'Sandra Aguilar',  '3181234567', 'sandra.ag@gmail.com'),
('2023-00463', 'Lucía',     'Reyes Molina',     1, '2008-10-28', 'Fernando Reyes',  '3187654321', 'fernando.rey@gmail.com'),
('2023-00464', 'Emilio',    'Ortiz Navarro',    3, '2007-07-15', 'Elena Navarro',   '3191234567', 'elena.nav@gmail.com'),
('2023-00465', 'Paula',     'Ruiz Guerrero',    4, '2007-11-23', 'Diego Ruiz',      '3197654321', 'diego.ruiz@gmail.com'),
('2023-00466', 'Andrés',    'Mora Serrano',     2, '2008-04-09', 'Claudia Serrano', '3201234567', 'claudia.ser@gmail.com'),
('2023-00467', 'Daniela',   'Pinto Rojas',      2, '2008-09-17', 'Miguel Pinto',    '3207654321', 'miguel.pin@gmail.com');

-- Observaciones del estudiante 2023-00452 (Carlos Martínez)
INSERT INTO observaciones (estudiante_id, fecha, tipo, periodo, observacion, aspecto_academico, aspecto_convivencial, compromiso, firma, docente_id) VALUES
(1, '2023-10-24', 'academico',    '2023-2', 'Participación activa en clase de matemáticas', 'Excelente participación en actividades del aula',              'Comportamiento ejemplar',               'Mantener el ritmo',       'Prof. Gómez',         2),
(1, '2023-10-20', 'convivencial', '2023-2', 'Inasistencia injustificada',                   'Falta injustificada a clases',                                 'Llegada tarde sin justificación',       'Traer excusa médica',     'Coord. Académica',    3),
(1, '2023-10-15', 'academico',    '2023-2', 'Excelente desempeño en proyecto de ciencias',  'Lideró el grupo en la elaboración del proyecto de ciencias',   'Motivó a sus compañeros positivamente', 'Liderar grupo de estudio','Prof. Rodríguez',     4),
(1, '2023-10-05', 'convivencial', '2023-2', 'Llegada tarde recurrente',                     'Incumplimiento del horario escolar',                           'Tardanzas reiteradas',                  'Mejorar puntualidad',     'Director de Grupo',   5),
(1, '2023-09-28', 'general',      '2023-2', 'Entrega puntual de trabajos del período',      'Cumplimiento de todas las actividades académicas',             'Actitud positiva y colaborativa',       'Continuar así',           'Prof. Gómez',         2),
(1, '2023-09-10', 'academico',    '2023-1', 'Buen desempeño en evaluaciones del primer período', 'Promedio académico destacado',                            'Integración activa con el grupo',       'Mantener el esfuerzo',    'Coord. Académica',    3);

-- Observaciones del estudiante 2023-00453 (Valentina García)
INSERT INTO observaciones (estudiante_id, fecha, tipo, periodo, observacion, aspecto_academico, aspecto_convivencial, compromiso, firma, docente_id) VALUES
(2, '2023-10-22', 'academico', '2023-2', 'Excelente exposición en clase de español', 'Sobresaliente en la asignatura de lengua castellana', 'Participa activamente', 'Seguir con su dedicación', 'Prof. Gómez', 2),
(2, '2023-10-12', 'convivencial', '2023-2', 'Conflicto con compañero de clase',       'Sin afectación académica',                           'Discusión con compañero', 'Resolver conflictos pacíficamente', 'Director de Grupo', 5);

-- Observaciones del estudiante 2023-00454 (Santiago Rodríguez)
INSERT INTO observaciones (estudiante_id, fecha, tipo, periodo, observacion, aspecto_academico, aspecto_convivencial, compromiso, firma, docente_id) VALUES
(3, '2023-10-18', 'academico', '2023-2', 'Dificultad en matemáticas', 'Bajo rendimiento en algebra', 'Actitud tranquila', 'Asistir a clases de refuerzo', 'Prof. Rodríguez', 4);

-- ============================================================
-- VISTAS ÚTILES
-- ============================================================

-- Vista: listado completo de estudiantes con grado
CREATE OR REPLACE VIEW v_estudiantes AS
SELECT
    e.id,
    e.codigo_estudiante,
    CONCAT(e.nombres, ' ', e.apellidos) AS nombre_completo,
    e.foto,
    g.nombre  AS grado,
    g.curso,
    CONCAT(g.nombre, '-', g.curso) AS grado_completo,
    e.acudiente_nombre,
    e.acudiente_email,
    e.activo
FROM estudiantes e
JOIN grados g ON e.grado_id = g.id;

-- Vista: observaciones con nombre del estudiante
CREATE OR REPLACE VIEW v_observaciones AS
SELECT
    o.id,
    o.fecha,
    o.tipo,
    o.periodo,
    o.observacion,
    o.aspecto_academico,
    o.aspecto_convivencial,
    o.compromiso,
    o.firma,
    e.codigo_estudiante,
    CONCAT(e.nombres, ' ', e.apellidos) AS nombre_estudiante,
    CONCAT(g.nombre, '-', g.curso) AS grado_completo
FROM observaciones o
JOIN estudiantes e ON o.estudiante_id = e.id
JOIN grados g ON e.grado_id = g.id;

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================
