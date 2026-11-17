DELIMITER //

CREATE TRIGGER t_asegurar_misma_modalidad_en_citas
BEFORE INSERT ON LineasCita
FOR EACH ROW
BEGIN
    DECLARE v_tipoServicioNuevo INT;
    DECLARE v_existeOtraModalidad BOOLEAN;

    SELECT tipoServicioId INTO v_tipoServicioNuevo
    FROM Servicios
    WHERE id = NEW.servicioId;

    SELECT EXISTS (
        SELECT 1
        FROM LineasCita lc
        JOIN Servicios s ON lc.servicioId = s.id
        WHERE lc.citaId = NEW.citaId
          AND s.tipoServicioId <> v_tipoServicioNuevo
    ) INTO v_existeOtraModalidad;

    IF v_existeOtraModalidad THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'La cita no puede incluir servicios de modalidades diferentes.';
    END IF;
END//

DELIMITER ;
