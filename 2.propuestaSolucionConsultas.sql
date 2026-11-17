-- 2.1
SELECT
    s.nombre AS nombre_servicio,
    ts.nombre AS modalidad,
    lc.precio AS precio_unitario
FROM LineasCita lc
JOIN Servicios s ON lc.servicioId = s.id
JOIN TiposServicio ts ON s.tipoServicioId = ts.id
WHERE ts.nombre = 'Teleconsulta';

-- 2.2
SELECT
    u.nombre AS nombre_veterinario,
    COUNT(citasConImporte.citaId) AS numero_citas_mas_150,
    COALESCE(SUM(citasConImporte.importe), 0) AS importe_total
FROM Veterinarios v
JOIN Usuarios u ON v.usuarioId = u.id
LEFT JOIN (
    SELECT
        c.id AS citaId,
        c.veterinarioId,
        SUM(lc.precio * lc.unidades) AS importe
    FROM Citas c
    JOIN LineasCita lc ON c.id = lc.citaId
    WHERE c.estado = 'Realizada'
      AND YEAR(c.fechaHora) = YEAR(CURDATE())
    GROUP BY c.id, c.veterinarioId
    HAVING SUM(lc.precio * lc.unidades) > 150
) AS citasConImporte ON v.id = citasConImporte.veterinarioId
GROUP BY v.id, u.nombre
ORDER BY importe_total DESC;
