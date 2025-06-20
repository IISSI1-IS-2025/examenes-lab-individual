--------------------------------------
-- 1: Creación de la tabla Promociones

CREATE TABLE Promociones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    productoId INT NOT NULL,
    descuento DECIMAL(4,2) CHECK (descuento > 0 AND descuento <= 1), -- Descuento como % (0.20 = 20%)
    fechaInicio DATE NOT NULL,
    fechaFin DATE NOT NULL,
    CONSTRAINT fk_promocion_producto FOREIGN KEY (productoId) REFERENCES Productos(id),
    CONSTRAINT chk_fechas_validas CHECK (fechaInicio <= fechaFin)
);

-------------------------------------------------------------------
-- 2.1: Procedimiento de inserción de datos en la tabla Promociones
DELIMITER //
CREATE PROCEDURE insertarPromocion(	IN p_productoId INT,
									IN p_descuento DECIMAL(4,2),
									IN p_fechaInicio DATE,
									IN p_fechaFin DATE)
BEGIN
	INSERT INTO Promociones(productoId, descuento, fechaInicio, fechaFin)
	VALUES (p_productoId, p_descuento, p_fechaInicio, p_fechaFin);
END //
DELIMITER ;

--------------------------------------------------------------------------------------------------------------
-- 3.1: Obtener las promociones activas actualmente, junto con los productos implicados y precios finales tras aplicar descuento.
SELECT p.nombre,
       p.precio AS PrecioOriginal,
       pr.descuento,
       ROUND(p.precio * (1 - pr.descuento), 2) AS PrecioFinal,
       pr.fechaInicio,
       pr.fechaFin
FROM Productos p
JOIN Promociones pr ON p.id = pr.productoId
WHERE CURRENT_DATE BETWEEN pr.fechaInicio AND pr.fechaFin;

-----------------------------------------------------
-- 3.2: Productos nunca promocionados hasta la fecha.
SELECT p.nombre, p.precio
FROM Productos p
LEFT JOIN Promociones pr ON p.id = pr.productoId
WHERE pr.id IS NULL;

-----------------------------------------------
-- 3.3: (Opcional) Consulta sin promociones (?)



------------------------------------------------------------------------------------------------------------
-- 4.1 Trigger: Al insertar una nueva línea de pedido, automáticamente aplica el precio con descuento si hay promoción activa.

DELIMITER //
CREATE OR REPLACE TRIGGER trg_actualizar_precio_pedido_promocion
BEFORE INSERT ON LineasPedido FOR EACH ROW 
BEGIN
	 DECLARE descuentoActivo DECIMAL(4,2);
	 
    SELECT descuento INTO descuentoActivo
    FROM Promociones
    WHERE productoId = new.productoId
      AND CURRENT_DATE BETWEEN fechaInicio AND fechaFin;

    IF (descuentoActivo IS NOT NULL) THEN
        SET new.precio = new.precio * (1 - descuentoActivo);
    END IF;
END //
DELIMITER ;

----------------------------------------------
-- 4.2: Caso de estudio para forzar el trigger

INSERT INTO Pedidos (fechaRealizacion, fechaEnvio, direccionEntrega, comentarios, clienteId, empleadoId) VALUES
('2025-07-08', '2025-07-09', '123 Calle Principal', 'Pedido con importe bajo', 1, 1);

INSERT INTO LineasPedido (pedidoId, productoId, unidades, precio) VALUES
(16, 1, 1, 15.99),      -- Pedido 16, Promoción pasada
(16, 2, 3, 29.99),      -- Pedido 16, Promoción activa
(16, 4, 3, 59.99);      -- Pedido 16, Promoción futura

-----------------------------------------------
-- 5.1 Procedimiento almacenado con transacción

DELIMITER //
CREATE PROCEDURE p_anularPedido(IN p_pedidoId INT)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Error al anular el pedido";
	END;

    START TRANSACTION;

    -- 1. Actualizar el stock de los productos según las líneas del pedido
    UPDATE Productos p
    JOIN LineasPedido lp ON p.id = lp.productoId
    SET p.stock = p.stock + lp.unidades
    WHERE lp.pedidoId = p_pedidoId;

    -- 2. Eliminar las líneas del pedido
    DELETE FROM LineasPedido 
    WHERE pedidoId = p_pedidoId;

    -- 3. Eliminar el pedido
    DELETE FROM Pedidos
    WHERE id = p_pedidoId;

    COMMIT;
END //
DELIMITER ;

--------------------------------
-- 5.2: Llamada al procedimiento

CALL p_anularPedido(16);
