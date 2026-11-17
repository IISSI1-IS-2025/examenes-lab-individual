DELIMITER //

CREATE PROCEDURE actualizar_precio_servicio_lineas_cita(
    IN p_servicioId INT,
    IN p_nuevoPrecio DECIMAL(10, 2)
)
BEGIN
    DECLARE v_precioActual DECIMAL(10, 2) DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT precio INTO v_precioActual
    FROM Servicios
    WHERE id = p_servicioId
    FOR UPDATE;

    IF v_precioActual IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Servicio no encontrado';
    END IF;

    IF p_nuevoPrecio IS NULL OR p_nuevoPrecio < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El nuevo precio debe ser mayor o igual que cero';
    END IF;

    IF p_nuevoPrecio < v_precioActual * 0.5 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se permite rebajar el precio más del 50%';
    END IF;

    UPDATE Servicios
    SET precio = p_nuevoPrecio
    WHERE id = p_servicioId;

    UPDATE LineasCita lc
    JOIN Citas c ON lc.citaId = c.id
    SET lc.precio = p_nuevoPrecio
    WHERE lc.servicioId = p_servicioId
      AND c.estado = 'Pendiente';

    COMMIT;
END//

DELIMITER ;
