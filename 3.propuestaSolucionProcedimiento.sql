DELIMITER //

CREATE PROCEDURE insertar_producto_y_regalos(
    IN p_nombre VARCHAR(255),
    IN p_descripcion VARCHAR(255),
    IN p_precio DECIMAL(10,2),
    IN p_tipoProductoId INT,
    IN p_esParaRegalo BOOLEAN
)
BEGIN
    DECLARE clienteMasAntiguoId INT;
    DECLARE clienteMasAntiguoDireccion VARCHAR(255);
    DECLARE clienteMasAntiguoCodigoPostal VARCHAR(10);

    -- Verificar si el producto es para regalo y su precio
    IF p_esParaRegalo AND p_precio > 50 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se permite crear un producto para regalo de más de 50€';
    END IF;

    -- Iniciar transacción
    START TRANSACTION;

    -- Insertar el producto
    INSERT INTO Productos (nombre, descripcion, precio, tipoProductoId)
    VALUES (p_nombre, p_descripcion, p_precio, p_tipoProductoId);

    -- Si es para regalo, crear un pedido para el cliente más antiguo
    IF p_esParaRegalo THEN
        -- Obtener cliente más antiguo
        SELECT id, direccionEnvio, codigoPostal INTO clienteMasAntiguoId, clienteMasAntiguoDireccion, clienteMasAntiguoCodigoPostal
        FROM Clientes
        ORDER BY id ASC
        LIMIT 1;

        -- Crear pedido
        INSERT INTO Pedidos (fechaRealizacion, direccionEntrega, clienteId, comentarios)
        VALUES (CURDATE(), clienteMasAntiguoDireccion, clienteMasAntiguoId, 'Pedido de regalo');

        -- Agregar línea de pedido con coste 0€
        INSERT INTO LineasPedido (pedidoId, productoId, unidades, precio)
        VALUES (LAST_INSERT_ID(), LAST_INSERT_ID(), 1, 0);
    END IF;

    -- Confirmar transacción
    COMMIT;
END //

DELIMITER ;
