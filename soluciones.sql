CREATE TABLE Promociones (
    idPromocion SERIAL PRIMARY KEY,
    idProducto INT NOT NULL,
    descuento DECIMAL(4,2) CHECK (descuento > 0 AND descuento <= 1), -- Descuento como % (0.20 = 20%)
    fechaInicio DATE NOT NULL,
    fechaFin DATE NOT NULL,
    CONSTRAINT fk_promocion_producto FOREIGN KEY (idProducto) REFERENCES Productos(idProducto),
    CONSTRAINT chk_fechas_validas CHECK (fechaInicio <= fechaFin)
);


2.1: Obtener las promociones activas actualmente, junto con los productos implicados y precios finales tras aplicar descuento.
SELECT p.nombreProducto,
       p.precioUnitario AS PrecioOriginal,
       pr.descuento,
       ROUND(p.precioUnitario * (1 - pr.descuento), 2) AS PrecioFinal,
       pr.fechaInicio,
       pr.fechaFin
FROM Productos p
JOIN Promociones pr ON p.idProducto = pr.idProducto
WHERE CURRENT_DATE BETWEEN pr.fechaInicio AND pr.fechaFin;



2.2: Productos nunca promocionados hasta la fecha.
SELECT p.idProducto, p.nombreProducto, p.precioUnitario
FROM Productos p
LEFT JOIN Promociones pr ON p.idProducto = pr.idProducto
WHERE pr.idPromocion IS NULL;

4. Trigger:

trg_actualizar_precio_pedido_promocion
Cuando se inserta una línea de pedido, automáticamente aplica el precio con descuento si hay promoción activa.
CREATE FUNCTION aplicar_descuento_promocion()
RETURNS TRIGGER AS $$
DECLARE
    descuentoActivo DECIMAL(4,2);
BEGIN
    SELECT descuento INTO descuentoActivo
    FROM Promociones
    WHERE idProducto = NEW.idProducto
      AND CURRENT_DATE BETWEEN fechaInicio AND fechaFin;

    IF descuentoActivo IS NOT NULL THEN
        NEW.precioUnitario := NEW.precioUnitario * (1 - descuentoActivo);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_actualizar_precio_pedido_promocion
BEFORE INSERT ON LineasPedido
FOR EACH ROW EXECUTE FUNCTION aplicar_descuento_promocion();




DELIMITER //

CREATE PROCEDURE anularPedido(IN p_idPedido INT)
BEGIN
    START TRANSACTION;

    -- 1. Actualizar el stock de los productos según las líneas del pedido
    UPDATE producto p
    JOIN lineaPedido lp ON p.idProducto = lp.idProducto
    SET p.stock = p.stock + lp.cantidad
    WHERE lp.idPedido = p_idPedido;

    -- 2. Eliminar las líneas del pedido
    DELETE FROM lineaPedido
    WHERE idPedido = p_idPedido;

    -- 3. Eliminar el pedido
    DELETE FROM pedido
    WHERE idPedido = p_idPedido;

    COMMIT;
END //

DELIMITER ;
