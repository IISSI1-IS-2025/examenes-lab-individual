DROP TABLE IF EXISTS PlanesSalud;
DROP TABLE IF EXISTS ServiciosCita;
DROP TABLE IF EXISTS Citas;
DROP TABLE IF EXISTS Servicios;
DROP TABLE IF EXISTS TiposServicio;
DROP TABLE IF EXISTS Animales;
DROP TABLE IF EXISTS Clientes;
DROP TABLE IF EXISTS Veterinarios;
DROP TABLE IF EXISTS Usuarios;

CREATE TABLE Usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    contraseña VARCHAR(255) NOT NULL CHECK (CHAR_LENGTH(contraseña) >= 8),
    nombre VARCHAR(255) NOT NULL
);

CREATE TABLE Veterinarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuarioId INT NOT NULL,
    salario DECIMAL(10, 2) NOT NULL CHECK (salario >= 0),
    FOREIGN KEY (usuarioId) REFERENCES Usuarios(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuarioId INT NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    FOREIGN KEY (usuarioId) REFERENCES Usuarios(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Animales (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    especie VARCHAR(100) NOT NULL,
    fechaNacimiento DATE,
    clienteId INT NOT NULL,
    FOREIGN KEY (clienteId) REFERENCES Clientes(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE Citas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fechaHora DATETIME NOT NULL,
    estado ENUM('Pendiente', 'Realizada', 'Cancelada') NOT NULL DEFAULT 'Pendiente',
    observaciones TEXT,
    animalId INT NOT NULL,
    veterinarioId INT,
    FOREIGN KEY (animalId) REFERENCES Animales(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY (veterinarioId) REFERENCES Veterinarios(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE TiposServicio (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Servicios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10, 2) NOT NULL CHECK (precio >= 0),
    tipoServicioId INT NOT NULL,
    FOREIGN KEY (tipoServicioId) REFERENCES TiposServicio(id)
);

CREATE TABLE ServiciosCita (
    id INT PRIMARY KEY AUTO_INCREMENT,
    citaId INT NOT NULL,
    servicioId INT NOT NULL,
    unidades INT NOT NULL CHECK (unidades > 0 AND unidades <= 100),
    precio DECIMAL(10, 2) NOT NULL CHECK (precio >= 0),
    FOREIGN KEY (citaId) REFERENCES Citas(id),
    FOREIGN KEY (servicioId) REFERENCES Servicios(id),
    UNIQUE (citaId, servicioId)
);
