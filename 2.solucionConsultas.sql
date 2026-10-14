-- ============================================================
-- 2.1. Incidencias no cerradas, abiertas hace más de 2 días, sin ninguna respuesta en los últimos 2 días.
-- ============================================================
-- Las condiciones de fecha pueden escribirse de forma equivalente con DATE_SUB, TIMESTAMPDIFF o DATEDIFF:
--   abierta hace más de 2 días:  fechaApertura < DATE_SUB(CURDATE(), INTERVAL 2 DAY)
--                                TIMESTAMPDIFF(DAY, fechaApertura, CURDATE()) > 2
--                                DATEDIFF(CURDATE(), fechaApertura) > 2
--   respuesta reciente:          fecha >= DATE_SUB(CURDATE(), INTERVAL 2 DAY)
--                                TIMESTAMPDIFF(DAY, fecha, CURDATE()) <= 2
--                                DATEDIFF(CURDATE(), fecha) <= 2

-- 2.1. Solución de referencia: NOT IN con una subconsulta que ya filtra las respuestas recientes
-- (mismo patrón que "productos que no han sido pedidos por ningún cliente menor de 18 años" del lab4).
SELECT Usuarios.nombre AS nombreCliente, Incidencias.id AS incidenciaId, Incidencias.fechaApertura
FROM Usuarios
INNER JOIN Clientes ON Usuarios.id = Clientes.usuarioId
INNER JOIN Pedidos ON Pedidos.clienteId = Clientes.id
INNER JOIN Incidencias ON Incidencias.pedidoId = Pedidos.id
WHERE Incidencias.estado <> 'Cerrada'
  AND Incidencias.fechaApertura < DATE_SUB(CURDATE(), INTERVAL 2 DAY)
  AND Incidencias.id NOT IN (
      SELECT RespuestasIncidencia.incidenciaId
      FROM RespuestasIncidencia
      WHERE RespuestasIncidencia.fecha >= DATE_SUB(CURDATE(), INTERVAL 2 DAY)
  );

-- 2.1. Alternativa B: NOT EXISTS con subconsulta correlacionada
-- SELECT Usuarios.nombre AS nombreCliente, Incidencias.id AS incidenciaId, Incidencias.fechaApertura
-- FROM Usuarios
-- INNER JOIN Clientes ON Usuarios.id = Clientes.usuarioId
-- INNER JOIN Pedidos ON Pedidos.clienteId = Clientes.id
-- INNER JOIN Incidencias ON Incidencias.pedidoId = Pedidos.id
-- WHERE Incidencias.estado <> 'Cerrada'
--   AND Incidencias.fechaApertura < DATE_SUB(CURDATE(), INTERVAL 2 DAY)
--   AND NOT EXISTS (SELECT * FROM RespuestasIncidencia
--                   WHERE RespuestasIncidencia.incidenciaId = Incidencias.id
--                     AND RespuestasIncidencia.fecha >= DATE_SUB(CURDATE(), INTERVAL 2 DAY));

-- 2.1. Alternativa C: LEFT JOIN a una subconsulta de respuestas recientes + IS NULL
-- SELECT Usuarios.nombre AS nombreCliente, Incidencias.id AS incidenciaId, Incidencias.fechaApertura
-- FROM Usuarios
-- INNER JOIN Clientes ON Usuarios.id = Clientes.usuarioId
-- INNER JOIN Pedidos ON Pedidos.clienteId = Clientes.id
-- INNER JOIN Incidencias ON Incidencias.pedidoId = Pedidos.id
-- LEFT JOIN (SELECT incidenciaId FROM RespuestasIncidencia
--            WHERE fecha >= DATE_SUB(CURDATE(), INTERVAL 2 DAY)) AS Recientes
--     ON Recientes.incidenciaId = Incidencias.id
-- WHERE Incidencias.estado <> 'Cerrada'
--   AND Incidencias.fechaApertura < DATE_SUB(CURDATE(), INTERVAL 2 DAY)
--   AND Recientes.incidenciaId IS NULL;

-- 2.1. Alternativa D: LEFT JOIN + GROUP BY + HAVING sobre la última respuesta
-- SELECT Usuarios.nombre AS nombreCliente, Incidencias.id AS incidenciaId, Incidencias.fechaApertura
-- FROM Usuarios
-- INNER JOIN Clientes ON Usuarios.id = Clientes.usuarioId
-- INNER JOIN Pedidos ON Pedidos.clienteId = Clientes.id
-- INNER JOIN Incidencias ON Incidencias.pedidoId = Pedidos.id
-- LEFT JOIN RespuestasIncidencia ON RespuestasIncidencia.incidenciaId = Incidencias.id
-- WHERE Incidencias.estado <> 'Cerrada'
--   AND Incidencias.fechaApertura < DATE_SUB(CURDATE(), INTERVAL 2 DAY)
-- GROUP BY Usuarios.nombre, Incidencias.id, Incidencias.fechaApertura
-- HAVING MAX(RespuestasIncidencia.fecha) IS NULL
--     OR MAX(RespuestasIncidencia.fecha) < DATE_SUB(CURDATE(), INTERVAL 2 DAY);

-- 2.1. Alternativa E (fuera del lab4, se acepta): condición de fecha en el ON del LEFT JOIN + IS NULL
-- SELECT Usuarios.nombre AS nombreCliente, Incidencias.id AS incidenciaId, Incidencias.fechaApertura
-- FROM Usuarios
-- INNER JOIN Clientes ON Usuarios.id = Clientes.usuarioId
-- INNER JOIN Pedidos ON Pedidos.clienteId = Clientes.id
-- INNER JOIN Incidencias ON Incidencias.pedidoId = Pedidos.id
-- LEFT JOIN RespuestasIncidencia ON RespuestasIncidencia.incidenciaId = Incidencias.id
--     AND RespuestasIncidencia.fecha >= DATE_SUB(CURDATE(), INTERVAL 2 DAY)
-- WHERE Incidencias.estado <> 'Cerrada'
--   AND Incidencias.fechaApertura < DATE_SUB(CURDATE(), INTERVAL 2 DAY)
--   AND RespuestasIncidencia.id IS NULL;

-- ============================================================
-- 2.2. Para cada empleado, número de incidencias cerradas en las que ha participado y tiempo medio de
-- resolución en días. Deben aparecer también los empleados que no hayan cerrado ninguna incidencia.
-- ============================================================
-- La clave es que cada par (empleado, incidencia) cuente una sola vez: sin eliminar repetidos, una
-- incidencia con varias respuestas del mismo empleado pesaría varias veces en el AVG.
-- Los días de resolución pueden calcularse con TIMESTAMPDIFF(DAY, fechaApertura, fechaCierre) o con
-- DATEDIFF(fechaCierre, fechaApertura).

-- 2.2. Solución de referencia: LEFT JOIN a una subconsulta que filtra las cerradas y agrupa por
-- (empleado, incidencia) (mismo patrón que topProductos del lab4). Los empleados sin incidencias cerradas
-- quedan con NULL: COUNT de una columna no cuenta los NULL (da 0) y AVG devuelve NULL, que COALESCE pasa a 0.
SELECT Usuarios.nombre AS nombreEmpleado,
       Empleados.id AS empleadoId,
       COUNT(Cerradas.incidenciaId) AS numIncidenciasCerradas,
       COALESCE(AVG(Cerradas.diasResolucion), 0) AS tiempoMedioResolucionDias
FROM Empleados
INNER JOIN Usuarios ON Usuarios.id = Empleados.usuarioId
LEFT JOIN (
    SELECT RespuestasIncidencia.empleadoId,
           Incidencias.id AS incidenciaId,
           TIMESTAMPDIFF(DAY, Incidencias.fechaApertura, Incidencias.fechaCierre) AS diasResolucion
    FROM RespuestasIncidencia
    INNER JOIN Incidencias ON Incidencias.id = RespuestasIncidencia.incidenciaId
    WHERE Incidencias.estado = 'Cerrada'
    GROUP BY RespuestasIncidencia.empleadoId, Incidencias.id
) AS Cerradas ON Cerradas.empleadoId = Empleados.id
GROUP BY Empleados.id, Usuarios.nombre
ORDER BY numIncidenciasCerradas DESC;

-- 2.2. Alternativa B: igual que la referencia, pero con SELECT DISTINCT en la subconsulta
-- SELECT Usuarios.nombre AS nombreEmpleado,
--        Empleados.id AS empleadoId,
--        COUNT(Cerradas.incidenciaId) AS numIncidenciasCerradas,
--        COALESCE(AVG(Cerradas.diasResolucion), 0) AS tiempoMedioResolucionDias
-- FROM Empleados
-- INNER JOIN Usuarios ON Usuarios.id = Empleados.usuarioId
-- LEFT JOIN (
--     SELECT DISTINCT RespuestasIncidencia.empleadoId,
--            Incidencias.id AS incidenciaId,
--            TIMESTAMPDIFF(DAY, Incidencias.fechaApertura, Incidencias.fechaCierre) AS diasResolucion
--     FROM RespuestasIncidencia
--     INNER JOIN Incidencias ON Incidencias.id = RespuestasIncidencia.incidenciaId
--     WHERE Incidencias.estado = 'Cerrada'
-- ) AS Cerradas ON Cerradas.empleadoId = Empleados.id
-- GROUP BY Empleados.id, Usuarios.nombre
-- ORDER BY numIncidenciasCerradas DESC;

-- 2.2. Alternativa C: vista con los pares (empleado, incidencia cerrada) y LEFT JOIN a la vista
-- CREATE OR REPLACE VIEW v_incidencias_cerradas_empleado AS
-- SELECT RespuestasIncidencia.empleadoId,
--        Incidencias.id AS incidenciaId,
--        TIMESTAMPDIFF(DAY, Incidencias.fechaApertura, Incidencias.fechaCierre) AS diasResolucion
-- FROM RespuestasIncidencia
-- INNER JOIN Incidencias ON Incidencias.id = RespuestasIncidencia.incidenciaId
-- WHERE Incidencias.estado = 'Cerrada'
-- GROUP BY RespuestasIncidencia.empleadoId, Incidencias.id;
-- SELECT Usuarios.nombre AS nombreEmpleado,
--        Empleados.id AS empleadoId,
--        COUNT(Cerradas.incidenciaId) AS numIncidenciasCerradas,
--        COALESCE(AVG(Cerradas.diasResolucion), 0) AS tiempoMedioResolucionDias
-- FROM Empleados
-- INNER JOIN Usuarios ON Usuarios.id = Empleados.usuarioId
-- LEFT JOIN v_incidencias_cerradas_empleado AS Cerradas ON Cerradas.empleadoId = Empleados.id
-- GROUP BY Empleados.id, Usuarios.nombre
-- ORDER BY numIncidenciasCerradas DESC;

-- 2.2. Alternativa D: subconsultas correlacionadas en el SELECT con EXISTS (sin LEFT JOIN ni GROUP BY)
-- SELECT Usuarios.nombre AS nombreEmpleado,
--        Empleados.id AS empleadoId,
--        (SELECT COUNT(*) FROM Incidencias
--         WHERE Incidencias.estado = 'Cerrada'
--           AND EXISTS (SELECT * FROM RespuestasIncidencia
--                       WHERE RespuestasIncidencia.incidenciaId = Incidencias.id
--                         AND RespuestasIncidencia.empleadoId = Empleados.id)) AS numIncidenciasCerradas,
--        COALESCE((SELECT AVG(TIMESTAMPDIFF(DAY, Incidencias.fechaApertura, Incidencias.fechaCierre))
--                  FROM Incidencias
--                  WHERE Incidencias.estado = 'Cerrada'
--                    AND EXISTS (SELECT * FROM RespuestasIncidencia
--                                WHERE RespuestasIncidencia.incidenciaId = Incidencias.id
--                                  AND RespuestasIncidencia.empleadoId = Empleados.id)), 0) AS tiempoMedioResolucionDias
-- FROM Empleados
-- INNER JOIN Usuarios ON Usuarios.id = Empleados.usuarioId
-- ORDER BY numIncidenciasCerradas DESC;

-- 2.2. Alternativa E: subconsultas correlacionadas en el SELECT con IN
-- SELECT Usuarios.nombre AS nombreEmpleado,
--        Empleados.id AS empleadoId,
--        (SELECT COUNT(*) FROM Incidencias
--         WHERE Incidencias.estado = 'Cerrada'
--           AND Incidencias.id IN (SELECT RespuestasIncidencia.incidenciaId FROM RespuestasIncidencia
--                                  WHERE RespuestasIncidencia.empleadoId = Empleados.id)) AS numIncidenciasCerradas,
--        COALESCE((SELECT AVG(TIMESTAMPDIFF(DAY, Incidencias.fechaApertura, Incidencias.fechaCierre))
--                  FROM Incidencias
--                  WHERE Incidencias.estado = 'Cerrada'
--                    AND Incidencias.id IN (SELECT RespuestasIncidencia.incidenciaId FROM RespuestasIncidencia
--                                           WHERE RespuestasIncidencia.empleadoId = Empleados.id)), 0) AS tiempoMedioResolucionDias
-- FROM Empleados
-- INNER JOIN Usuarios ON Usuarios.id = Empleados.usuarioId
-- ORDER BY numIncidenciasCerradas DESC;

-- 2.2. Alternativa F (fuera del lab4, se acepta): pares sin repetir + condición de estado en el ON
-- SELECT Usuarios.nombre AS nombreEmpleado,
--        Empleados.id AS empleadoId,
--        COUNT(Incidencias.id) AS numIncidenciasCerradas,
--        COALESCE(AVG(TIMESTAMPDIFF(DAY, Incidencias.fechaApertura, Incidencias.fechaCierre)), 0) AS tiempoMedioResolucionDias
-- FROM Empleados
-- INNER JOIN Usuarios ON Usuarios.id = Empleados.usuarioId
-- LEFT JOIN (SELECT DISTINCT empleadoId, incidenciaId FROM RespuestasIncidencia) AS Participaciones
--     ON Participaciones.empleadoId = Empleados.id
-- LEFT JOIN Incidencias ON Incidencias.id = Participaciones.incidenciaId AND Incidencias.estado = 'Cerrada'
-- GROUP BY Empleados.id, Usuarios.nombre
-- ORDER BY numIncidenciasCerradas DESC;

-- 2.2. Alternativa G (fuera del lab4, se acepta): EXISTS dentro del ON
-- SELECT Usuarios.nombre AS nombreEmpleado,
--        Empleados.id AS empleadoId,
--        COUNT(Incidencias.id) AS numIncidenciasCerradas,
--        COALESCE(AVG(TIMESTAMPDIFF(DAY, Incidencias.fechaApertura, Incidencias.fechaCierre)), 0) AS tiempoMedioResolucionDias
-- FROM Empleados
-- INNER JOIN Usuarios ON Usuarios.id = Empleados.usuarioId
-- LEFT JOIN Incidencias ON Incidencias.estado = 'Cerrada'
--     AND EXISTS (SELECT * FROM RespuestasIncidencia
--                 WHERE RespuestasIncidencia.incidenciaId = Incidencias.id
--                   AND RespuestasIncidencia.empleadoId = Empleados.id)
-- GROUP BY Empleados.id, Usuarios.nombre
-- ORDER BY numIncidenciasCerradas DESC;

-- 2.2. Alternativa H (fuera del lab4, se acepta): auto-join que conserva solo la primera respuesta de cada empleado a cada incidencia
-- SELECT Usuarios.nombre AS nombreEmpleado,
--        Empleados.id AS empleadoId,
--        COUNT(Incidencias.id) AS numIncidenciasCerradas,
--        COALESCE(AVG(TIMESTAMPDIFF(DAY, Incidencias.fechaApertura, Incidencias.fechaCierre)), 0) AS tiempoMedioResolucionDias
-- FROM Empleados
-- INNER JOIN Usuarios ON Usuarios.id = Empleados.usuarioId
-- LEFT JOIN RespuestasIncidencia R ON R.empleadoId = Empleados.id
-- LEFT JOIN RespuestasIncidencia RAnterior ON RAnterior.empleadoId = R.empleadoId
--     AND RAnterior.incidenciaId = R.incidenciaId
--     AND RAnterior.id < R.id
-- LEFT JOIN Incidencias ON Incidencias.id = R.incidenciaId AND Incidencias.estado = 'Cerrada'
-- WHERE RAnterior.id IS NULL
-- GROUP BY Empleados.id, Usuarios.nombre
-- ORDER BY numIncidenciasCerradas DESC;
