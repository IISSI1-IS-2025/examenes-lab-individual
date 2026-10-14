DELIMITER //

CREATE PROCEDURE CerrarIncidencia(IN p_incidenciaId INT, IN p_empleadoId INT, IN p_mensaje TEXT)
BEGIN
    DECLARE estadoActual VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT estado INTO estadoActual
    FROM Incidencias WHERE id = p_incidenciaId;

    IF estadoActual IS NULL OR estadoActual = 'Cerrada' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La incidencia no existe o ya está cerrada.';
    END IF;

    START TRANSACTION;

    INSERT INTO RespuestasIncidencia (incidenciaId, empleadoId, fecha, mensaje)
    VALUES (p_incidenciaId, p_empleadoId, CURDATE(), p_mensaje);

    UPDATE Incidencias
    SET estado = 'Cerrada', fechaCierre = CURDATE()
    WHERE id = p_incidenciaId;

    COMMIT;
END //

DELIMITER ;
