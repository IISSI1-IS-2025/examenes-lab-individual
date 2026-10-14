DROP TABLE IF EXISTS RespuestasIncidencia;
DROP TABLE IF EXISTS Incidencias;

CREATE TABLE Incidencias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pedidoId INT NOT NULL,
    fechaApertura DATE NOT NULL,
    asunto VARCHAR(255) NOT NULL,
    descripcion TEXT NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'Abierta' CHECK (estado IN ('Abierta', 'En proceso', 'Cerrada')),
    fechaCierre DATE,
    FOREIGN KEY (pedidoId) REFERENCES Pedidos(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_fecha_cierre_posterior CHECK (fechaCierre IS NULL OR fechaCierre >= fechaApertura)
);

CREATE TABLE RespuestasIncidencia (
    id INT PRIMARY KEY AUTO_INCREMENT,
    incidenciaId INT NOT NULL,
    empleadoId INT,
    fecha DATE NOT NULL,
    mensaje TEXT NOT NULL,
    FOREIGN KEY (incidenciaId) REFERENCES Incidencias(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (empleadoId) REFERENCES Empleados(id)
        ON DELETE SET NULL
        ON UPDATE SET NULL
);
