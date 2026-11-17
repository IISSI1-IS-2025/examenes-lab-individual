DROP TABLE IF EXISTS PlanesSalud;

CREATE TABLE PlanesSalud (
    id INT PRIMARY KEY AUTO_INCREMENT,
    animalId INT NOT NULL UNIQUE,
    fechaInicio DATE NOT NULL,
    fechaFin DATE NOT NULL,
    incluyeCoberturaUrgencias BOOLEAN NOT NULL,
    FOREIGN KEY (animalId) REFERENCES Animales(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CHECK (fechaFin > fechaInicio)
);
