DROP DATABASE IF EXISTS technologic_library;
CREATE DATABASE technologic_library
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE technologic_library;

-- 1. TABLA: roles
CREATE TABLE roles (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL UNIQUE,
    limite_prestamos INT NOT NULL DEFAULT 3,
    dias_prestamo_permitidos INT NOT NULL DEFAULT 7
) ENGINE=InnoDB;

-- 2. TABLA: usuarios
CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    cedula_identidad VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email_institucional VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    estado ENUM('Activo', 'Inactivo', 'Sancionado') NOT NULL DEFAULT 'Activo',
    id_rol INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_usuarios_roles FOREIGN KEY (id_rol) 
        REFERENCES roles(id_rol) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 3. TABLA: autores
CREATE TABLE autores (
    id_autor INT AUTO_INCREMENT PRIMARY KEY,
    nombre_completo VARCHAR(150) NOT NULL,
    nacionalidad VARCHAR(50) NULL
) ENGINE=InnoDB;

-- 4. TABLA: editoriales
CREATE TABLE editoriales (
    id_editorial INT AUTO_INCREMENT PRIMARY KEY,
    nombre_editorial VARCHAR(100) NOT NULL UNIQUE,
    sitio_web VARCHAR(255) NULL
) ENGINE=InnoDB;

-- 5. TABLA: categorias
CREATE TABLE categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre_categoria VARCHAR(100) NOT NULL UNIQUE,
    codigo_dewey VARCHAR(20) NULL
) ENGINE=InnoDB;

-- 6. TABLA: libros
CREATE TABLE libros (
    id_libro INT AUTO_INCREMENT PRIMARY KEY,
    isbn_issn VARCHAR(30) UNIQUE,
    titulo VARCHAR(255) NOT NULL,
    anio_publicacion INT NULL,
    id_editorial INT NOT NULL,
    id_categoria INT NOT NULL,
    formato_tipo ENUM('Libro_Fisico', 'Paper', 'Software_Licencia') NOT NULL DEFAULT 'Libro_Fisico',
    registro_marc22 TEXT NULL,
    es_digital BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_recursos_editoriales FOREIGN KEY (id_editorial) 
        REFERENCES editoriales(id_editorial) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_recursos_categorias FOREIGN KEY (id_categoria) 
        REFERENCES categorias(id_categoria) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 7. TABLA INTERMEDIA: recurso_autor (Relacion N:M)
CREATE TABLE recurso_autor (
    id_recurso INT NOT NULL,
    id_autor INT NOT NULL,
    PRIMARY KEY (id_recurso, id_autor),
    CONSTRAINT fk_ra_recursos FOREIGN KEY (id_recurso) 
        REFERENCES libros (id_libro) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_ra_autores FOREIGN KEY (id_autor) 
        REFERENCES autores(id_autor) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 8. TABLA: ejemplares_fisicos
CREATE TABLE ejemplares_fisicos (
    id_ejemplar INT AUTO_INCREMENT PRIMARY KEY,
    id_libro INT NOT NULL,
    codigo_barras VARCHAR(50) NOT NULL UNIQUE,
    codigo_qr VARCHAR(100) NULL UNIQUE,
    estado_ejemplar ENUM('Disponible', 'Prestado', 'En_Reparacion', 'Extraviado') NOT NULL DEFAULT 'Disponible',
    ubicacion_estante VARCHAR(50) NOT NULL,
    CONSTRAINT fk_ejemplares_libros FOREIGN KEY (id_libro) 
        REFERENCES libros (id_libro) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 9. TABLA: prestamos
CREATE TABLE prestamos (
    id_prestamo INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_ejemplar INT NOT NULL,
    id_bibliotecario INT NOT NULL,
    fecha_prestamo DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_dev_prevista DATETIME NOT NULL,
    fecha_dev_real DATETIME NULL,
    estado_prestamo ENUM('Activo', 'Devuelto', 'Vencido') NOT NULL DEFAULT 'Activo',
    CONSTRAINT fk_prestamos_usuarios FOREIGN KEY (id_usuario) 
        REFERENCES usuarios(id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_prestamos_ejemplares FOREIGN KEY (id_ejemplar) 
        REFERENCES ejemplares_fisicos(id_ejemplar) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_prestamos_bibliotecario FOREIGN KEY (id_bibliotecario) 
        REFERENCES usuarios(id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 10. TABLA: reservas
CREATE TABLE reservas (
    id_reserva INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_libro INT NOT NULL,
    fecha_reserva DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_reserva ENUM('Pendiente', 'Asignada', 'Cancelada', 'Expirada') NOT NULL DEFAULT 'Pendiente',
    orden_prioridad INT NOT NULL DEFAULT 1,
    CONSTRAINT fk_reservas_usuarios FOREIGN KEY (id_usuario) 
        REFERENCES usuarios(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_reservas_libros FOREIGN KEY (id_libro) 
        REFERENCES libros (id_libro) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 11. TABLA: sanciones
CREATE TABLE sanciones (
    id_sancion INT AUTO_INCREMENT PRIMARY KEY,
    id_prestamo INT NOT NULL UNIQUE,
    id_usuario INT NOT NULL,
    dias_retraso INT NOT NULL CHECK (dias_retraso > 0),
    monto_multa DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (monto_multa >= 0),
    estado_pago ENUM('Pendiente', 'Pagado', 'Condonado') NOT NULL DEFAULT 'Pendiente',
    fecha_emision DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sanciones_prestamos FOREIGN KEY (id_prestamo) 
        REFERENCES prestamos(id_prestamo) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_sanciones_usuarios FOREIGN KEY (id_usuario) 
        REFERENCES usuarios(id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =========================================================
-- INSERCIÓN DE DATOS AMPLIADOS (DML)
-- =========================================================

INSERT INTO roles (nombre_rol, limite_prestamos, dias_prestamo_permitidos) VALUES 
('Estudiante', 3, 7),
('Docente', 5, 14),
('Bibliotecario', 10, 30),
('Administrador', 10, 30);

-- Usuarios ampliados (Más estudiantes y bibliotecarios)
INSERT INTO usuarios (cedula_identidad, nombre, apellido, email_institucional, password_hash, estado, id_rol) VALUES 
('1720458921', 'Carlos', 'Mendoza', 'cmendoza@unitecnologica.edu', '$2a$12$e82hX91K...hash_bib1', 'Activo', 3),
('1733445566', 'Sofía', 'Torres', 'storres@unitecnologica.edu', '$2a$12$f82hX92K...hash_bib2', 'Activo', 3),
('1752189403', 'Ana', 'Gómez', 'agomez@unitecnologica.edu', '$2a$12$f91jZ02L...hash_est1', 'Activo', 1),
('1752893410', 'María', 'Pérez', 'mperez@unitecnologica.edu', '$2a$12$a91jZ03L...hash_est2', 'Activo', 1),
('1711223344', 'Jorge', 'Ramírez', 'jramirez@unitecnologica.edu', '$2a$12$b91jZ04L...hash_est3', 'Activo', 1),
('1709845123', 'Dr. Roberto', 'Silva', 'rsilva@unitecnologica.edu', '$2a$12$a12kB93M...hash_doc', 'Activo', 2);

-- Autores ampliados
INSERT INTO autores (nombre_completo, nacionalidad) VALUES 
('Martin Fowler', 'Británica'),
('Robert C. Martin', 'Estadounidense'),
('Andrew S. Tanenbaum', 'Estadounidense'),
('Erich Gamma', 'Estadounidense'),
('Andrew Hunt', 'Estadounidense'),
('Avi Silberschatz', 'Israelí');

-- Editoriales ampliadas
INSERT INTO editoriales (nombre_editorial, sitio_web) VALUES 
('Addison-Wesley', 'https://www.informit.com/imprint/addisonwesley'),
('Prentice Hall', 'https://www.pearson.com'),
('O\'Reilly Media', 'https://www.oreilly.com'),
('Manning Publications', 'https://www.manning.com'),
('No Starch Press', 'https://nostarch.com');

-- Categorías ampliadas
INSERT INTO categorias (nombre_categoria, codigo_dewey) VALUES 
('Ingeniería de Software', '005.1'),
('Sistemas Operativos', '005.43'),
('Bases de Datos', '005.74'),
('Inteligencia Artificial', '006.3'),
('Redes de Computadoras', '004.6');

-- Libros ampliados con sus códigos (ISBN)
INSERT INTO libros (isbn_issn, titulo, anio_publicacion, id_editorial, id_categoria, formato_tipo, registro_marc22, es_digital) VALUES 
('978-0132350884', 'Clean Code: A Handbook of Agile Software Craftsmanship', 2008, 1, 1, 'Libro_Fisico', 'LEADER ...', FALSE),
('978-0133591620', 'Modern Operating Systems', 2014, 2, 2, 'Libro_Fisico', 'LEADER ...', FALSE),
('978-0134757599', 'Refactoring: Improving the Design of Existing Code', 2018, 1, 1, 'Libro_Fisico', 'LEADER ...', TRUE),
('978-0201633610', 'Design Patterns: Elements of Reusable Object-Oriented Software', 1994, 1, 1, 'Libro_Fisico', 'LEADER ...', FALSE),
('978-0135957059', 'The Pragmatic Programmer: Your Journey to Mastery', 2019, 1, 1, 'Libro_Fisico', 'LEADER ...', FALSE),
('978-0078022159', 'Database System Concepts', 2019, 2, 3, 'Libro_Fisico', 'LEADER ...', FALSE);

-- Relación Recursos - Autores
INSERT INTO recurso_autor (id_recurso, id_autor) VALUES 
(1, 2), -- Clean Code -> Robert C. Martin
(2, 3), -- Modern Operating Systems -> Andrew S. Tanenbaum
(3, 1), -- Refactoring -> Martin Fowler
(4, 4), -- Design Patterns -> Erich Gamma
(5, 5), -- The Pragmatic Programmer -> Andrew Hunt
(6, 6); -- Database System Concepts -> Avi Silberschatz

-- Ejemplares físicos de cada libro con sus códigos de barras y QR
INSERT INTO ejemplares_fisicos (id_libro, codigo_barras, codigo_qr, estado_ejemplar, ubicacion_estante) VALUES 
(1, 'BIB-TEC-001001', 'QR-CC-01', 'Prestado', 'Estante A-3'),
(1, 'BIB-TEC-001002', 'QR-CC-02', 'Disponible', 'Estante A-3'),
(2, 'BIB-TEC-002001', 'QR-MOS-01', 'Disponible', 'Estante B-1'),
(4, 'BIB-TEC-003001', 'QR-DP-01', 'Disponible', 'Estante A-4'),
(5, 'BIB-TEC-004001', 'QR-PP-01', 'Disponible', 'Estante A-4'),
(6, 'BIB-TEC-005001', 'QR-DSC-01', 'Disponible', 'Estante C-2');

-- Préstamo de prueba inicial
INSERT INTO prestamos (id_usuario, id_ejemplar, id_bibliotecario, fecha_prestamo, fecha_dev_prevista, fecha_dev_real, estado_prestamo) VALUES 
(3, 1, 1, NOW() - INTERVAL 10 DAY, NOW() - INTERVAL 3 DAY, NULL, 'Vencido');

-- Sanción del préstamo de prueba
INSERT INTO sanciones (id_prestamo, id_usuario, dias_retraso, monto_multa, estado_pago) VALUES 
(1, 3, 3, 4.50, 'Pendiente');

-- =========================================================
-- CONSULTA INTEGRAL DE COMPROBACIÓN
-- =========================================================
SELECT 
    p.id_prestamo,
    u.nombre AS estudiante_nombre,
    u.apellido AS estudiante_apellido,
    l.titulo AS libro_prestado,
    ef.codigo_barras,
    p.fecha_prestamo,
    p.fecha_dev_prevista,
    p.estado_prestamo,
    s.monto_multa
FROM prestamos p
JOIN usuarios u ON p.id_usuario = u.id_usuario
JOIN ejemplares_fisicos ef ON p.id_ejemplar = ef.id_ejemplar
JOIN libros l ON ef.id_libro = l.id_libro
LEFT JOIN sanciones s ON p.id_prestamo = s.id_prestamo;

-- Tercera Entrega--
-- =========================================================
-- ÍNDICES DE OPTIMIZACIÓN
-- =========================================================
CREATE INDEX idx_libro_titulos ON libros(titulo);
CREATE INDEX idx_ejemplares_codigo_barras ON ejemplares_fisicos(codigo_barras);
CREATE INDEX idx_prestamos_estado ON prestamos(estado_prestamo);
CREATE INDEX idx_usuarios_email ON usuarios(email_institucional);

-- =========================================================
-- PROCEDIMIENTO ALMACENADO
-- =========================================================
DELIMITER //
CREATE PROCEDURE sp_registrar_prestamo (
    IN p_id_usuario INT,
    IN p_id_usuario INT,
    IN p_id_ejemplar INT,
    IN p_id_bibliotecario INT,
    IN p_dias_prestamo INT
)
BEGIN
    INSERT INTO prestamos (id_usuario, id_ejemplar, id_bibliotecario, fecha_prestamo, fecha_dev_prevista, estado_prestamo)
    VALUES (p_id_usuario, p_id_ejemplar, p_id_bibliotecario, CURRENT_DATE(), DATE_ADD(CURRENT_DATE(), INTERVAL p_dias_prestamo DAY), 'Activo');
END //
DELIMITER ;

-- =========================================================
-- TRIGGER DE ACTUALIZACIÓN DE ESTADO
-- =========================================================
DELIMITER //
CREATE TRIGGER trg_actualizar_estado_prestamo
BEFORE UPDATE ON prestamos
FOR EACH ROW
BEGIN
    IF NEW.fecha_dev_real IS NOT NULL AND NEW.fecha_dev_real > NEW.fecha_dev_prevista THEN
        SET NEW.estado_prestamo = 'Vencido';
    END IF;
END //
DELIMITER ;