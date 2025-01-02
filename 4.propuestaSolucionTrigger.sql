DELIMITER //

CREATE TRIGGER t_asegurar_mismo_tipo_producto_en_pedidos
BEFORE INSERT ON LineasPedido
FOR EACH ROW
BEGIN
    DECLARE v_tipoProductoNuevo VARCHAR(255);
    DECLARE v_tipoProductoExistente VARCHAR(255);

    -- Obtener el tipo del producto que se intenta insertar
    SELECT tp.nombre
    INTO v_tipoProductoNuevo
    FROM Productos p
    JOIN TiposProducto tp ON p.tipoProductoId = tp.id
    WHERE p.id = NEW.productoId;

    -- Verificar si el pedido ya tiene líneas y qué tipo de producto contiene
    SELECT tp.nombre
    INTO v_tipoProductoExistente
    FROM LineasPedido lp
    JOIN Productos p ON lp.productoId = p.id
    JOIN TiposProducto tp ON p.tipoProductoId = tp.id
    WHERE lp.pedidoId = NEW.pedidoId
    LIMIT 1;

    -- Si el pedido ya tiene líneas, comparar los tipos y lanzar excepción si son diferentes
    IF v_tipoProductoExistente IS NOT NULL AND v_tipoProductoExistente <> v_tipoProductoNuevo THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El pedido no puede incluir productos de tipos diferentes (físicos y digitales).';
    END IF;
END//

DELIMITER ;
