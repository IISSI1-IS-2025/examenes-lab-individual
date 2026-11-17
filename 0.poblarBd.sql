INSERT INTO Usuarios (email, contraseña, nombre) VALUES
('cliente1@vet.example', 'password123', 'Lucía Pérez'),
('vet1@vet.example', 'password123', 'Mario Ruiz'),
('cliente2@vet.example', 'password123', 'Ana Gómez'),
('vet2@vet.example', 'password123', 'Elena Díaz');

INSERT INTO Veterinarios (usuarioId, salario) VALUES
(2, 36000.00),
(4, 42000.00);

INSERT INTO Clientes (usuarioId, telefono) VALUES
(1, '600111222'),
(3, '600333444');

INSERT INTO Animales (nombre, especie, fechaNacimiento, clienteId) VALUES
('Luna', 'Perro', '2020-04-12', 1),
('Milo', 'Gato', '2022-09-03', 2),
('Nube', 'Perro', '2018-01-25', 1);

INSERT INTO TiposServicio (nombre) VALUES
('Presencial'),
('Teleconsulta');

INSERT INTO Servicios (nombre, descripcion, precio, tipoServicioId) VALUES
('Consulta general', 'Revisión veterinaria general', 45.00, 1),
('Vacunación', 'Administración de vacuna', 30.00, 1),
('Cirugía menor', 'Intervención quirúrgica menor', 220.00, 1),
('Consulta dermatológica online', 'Consulta dermatológica por videollamada', 80.00, 2),
('Seguimiento online', 'Seguimiento remoto del tratamiento', 40.00, 2),
('Analítica', 'Análisis clínico en laboratorio', 65.00, 1);

INSERT INTO Citas (fechaHora, estado, observaciones, animalId, veterinarioId) VALUES
(STR_TO_DATE(CONCAT(YEAR(CURDATE()), '-06-15 10:00:00'), '%Y-%m-%d %H:%i:%s'),
 'Realizada', 'Revisión y vacunación', 1, 1),
(STR_TO_DATE(CONCAT(YEAR(CURDATE()), '-07-10 11:00:00'), '%Y-%m-%d %H:%i:%s'),
 'Realizada', 'Intervención programada', 3, 1),
(STR_TO_DATE(CONCAT(YEAR(CURDATE()), '-08-20 12:00:00'), '%Y-%m-%d %H:%i:%s'),
 'Realizada', 'Consulta por videollamada', 2, 2),
(STR_TO_DATE(CONCAT(YEAR(CURDATE()), '-09-05 09:00:00'), '%Y-%m-%d %H:%i:%s'),
 'Pendiente', 'Revisión pendiente', 1, 2),
(STR_TO_DATE(CONCAT(YEAR(CURDATE()) - 2, '-06-15 10:00:00'), '%Y-%m-%d %H:%i:%s'),
 'Realizada', 'Cita de otro año', 2, 1);

INSERT INTO LineasCita (citaId, servicioId, unidades, precio) VALUES
(1, 1, 1, 45.00),
(1, 2, 1, 30.00),
(2, 3, 1, 220.00),
(3, 4, 1, 80.00),
(3, 5, 1, 40.00),
(4, 1, 1, 45.00),
(4, 6, 1, 65.00),
(5, 3, 1, 200.00);
