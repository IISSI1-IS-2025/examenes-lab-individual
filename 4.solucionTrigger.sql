DELIMITER //

CREATE TRIGGER asegurar_respuesta_incidencia_abierta BEFORE INSERT ON RespuestasIncidencia
FOR EACH ROW
BEGIN
    DECLARE estadoActual VARCHAR(20);

    SELECT estado INTO estadoActual
    FROM Incidencias WHERE id = NEW.incidenciaId;

    IF estadoActual = 'Cerrada' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se pueden añadir respuestas a una incidencia cerrada.';
    END IF;

    IF estadoActual = 'Abierta' THEN
        UPDATE Incidencias SET estado = 'En proceso' WHERE id = NEW.incidenciaId;
    END IF;
END //

DELIMITER ;
