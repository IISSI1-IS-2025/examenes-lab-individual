--------------------------------------
-- 1: Creación de la tabla 

DROP TABLE IF EXISTS lineaspedido;
DROP TABLE IF EXISTS pedidos;
DROP TABLE IF EXISTS Envios;


CREATE TABLE Envios (
	id INT PRIMARY KEY AUTO_INCREMENT,
   fechaEnvio DATE NOT NULL,
   fechaEntrega DATE,
   estadoEnvio VARCHAR(20) NOT NULL,
   CONSTRAINT Enum_estado_envio CHECK (estadoEnvio IN ('En preparación','Enviado','Entregado')),
   CONSTRAINT fechas CHECK (fechaentrega IS NULL OR fechaentrega >= fechaenvio)
);


CREATE TABLE Pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fechaRealizacion DATE NOT NULL,
    envioId INT,
    direccionEntrega VARCHAR(255) NOT NULL,
    comentarios TEXT,
    clienteId INT NOT NULL,
    empleadoId INT,
    FOREIGN KEY (clienteId) REFERENCES Clientes(id) 
        ON DELETE RESTRICT 
        ON UPDATE RESTRICT,
    FOREIGN KEY (empleadoId) REFERENCES Empleados(id) 
        ON DELETE SET NULL 
        ON UPDATE SET NULL,
   FOREIGN KEY (envioId) REFERENCES Envios(id) 
        ON DELETE SET NULL 
        ON UPDATE SET NULL
);

CREATE TABLE LineasPedido (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pedidoId INT NOT NULL,
    productoId INT NOT NULL,
    unidades INT NOT NULL CHECK (unidades > 0 AND unidades <= 100),
    precio DECIMAL(10, 2) NOT NULL CHECK (precio >= 0),
    FOREIGN KEY (pedidoId) REFERENCES Pedidos(id),
    FOREIGN KEY (productoId) REFERENCES Productos(id),
    UNIQUE (pedidoId, productoId)
);

-------------------------------------------------------------------
-- 2: Inserción de datos
INSERT INTO envios (fechaEnvio, fechaEntrega, estadoEnvio) VALUES
	('2025-10-23', NULL, 'En preparación'),
	('2010-06-03', '2010-06-05', 'Entregado');

-- Insertar datos en la tabla Pedidos
INSERT INTO Pedidos (fechaRealizacion, envioId, direccionEntrega, comentarios, clienteId, empleadoId) VALUES
('2024-10-01', 1, '123 Calle Principal', 'Entregar en la puerta', 1,  1),
('2024-10-02', 1, '456 Avenida Secundaria', 'Entregar en recepción', 2, NULL),
('2010-06-01', 2, '123 Calle VeteTuASaber', 'Cliente con movilidad reducida', 1,  2);

-- Insertar datos en la tabla LineasPedido - Conjunto de inserciones correctas
-- Productos permitidos para todos los clientes
INSERT INTO LineasPedido (pedidoId, productoId, unidades, precio) VALUES
(1, 1, 1, 699.99),   -- Smartphone (permitido)
(1, 5, 2, 15.99),    -- Camiseta (permitido)
(1, 3, 1, 9.99),     -- Libro Electrónico (permitido)
(3, 2, 1, 1100.00),   -- Laptop (permitido)
(3, 8, 2, 29.99),    -- Audífono (permitido)
(3, 9, 1, 12.99);     -- Tableta (permitido)


-----------------------------------------------
-- 3: Consultas
-- 3.1: 


--------------------------------------------------------------------------------------------------------------
-- 3.2: 




------------------------------------------------------------------------------------------------------------
-- 5.1 Procedimiento almacenado con transacción

DELIMITER //
-- Cree un procedimiento que permita dar de alta un nuevo envío, con fecha de envío la de hoy y estado "En preparación"
-- y asigne todos aquellos pedidos realizados hasta el día de ayer y que NO hayan sido incluídos en ningún otro envío aún.
CREATE OR REPLACE PROCEDURE p_nuevoEnvio()
BEGIN
	DECLARE envio_id INT;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Error al crear el envío";
	END;

    START TRANSACTION;

    -- 1. Crear el envío, guardando su id
   INSERT INTO envios (fechaEnvio, fechaEntrega, estadoEnvio) VALUES
	(CURDATE(), NULL, 'En preparación');
	SET envio_id = LAST_INSERT_ID();
    
    UPDATE Pedidos p
    SET p.envioId = envio_id
    WHERE p.fechaRealizacion < CURDATE() AND p.envioId IS NULL;

    COMMIT;
END //
DELIMITER ;

--------------------------------
-- Llamada al procedimiento



-----------------------------------------------
-- 5 Trigger: No se puede asignar un pedido a un envío si no contiene productos físicos.

DELIMITER //
CREATE OR REPLACE TRIGGER trg_asegurar_envio_pedidos_fisicos
BEFORE UPDATE ON Pedidos FOR EACH ROW 
BEGIN
	
	DECLARE fisicos INT;
	
	SELECT COUNT(*) INTO fisicos
	FROM pedidos p 
		JOIN LineasPedido lp ON lp.pedidoId = p.id
		JOIN productos ON productos.id = lp.productoId
		JOIN tiposproducto tp ON productos.tipoProductoId=tp.id 
	WHERE lp.pedidoId = NEW.id AND tp.nombre LIKE 'Físicos'
	GROUP BY p.id;
		 
   IF (fisicos <=0) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El pedido no puede incluirse en ningún envío por no contener productos físicos.';
   END IF;
END //
DELIMITER ;