# Guía de corrección — Examen de laboratorio, tercera convocatoria (octubre 2026)

Esta guía recoge, para cada ejercicio, la solución de referencia, las alternativas que se han dado por buenas y los
descuentos que se han aplicado. Compara tu respuesta con ella para entender tu nota.

## Normas generales

- Cada ejercicio parte de su puntuación máxima y se le restan los descuentos. Ningún ejercicio baja de 0.
- Puntuación: ejercicio 1 (1,5), 2.1 (1,5), 2.2 (2), 3 (2,5) y 4 (2,5). En Blackboard son las preguntas 1 a 5, en
  ese orden.
- Todo el código se ha ejecutado en MariaDB con unos datos de prueba preparados para detectar los errores más
  habituales. En cada ejercicio se indica el resultado que se esperaba.
- El ejercicio 1 se puntúa tal como lo entregaste. Los ejercicios 2, 3 y 4 se han probado con **tus propias tablas**
  (si tenían errores, se corrigieron lo mínimo para poder ejecutar el resto), de modo que un fallo del ejercicio 1 no
  se vuelve a descontar en los siguientes. Se aceptan tus nombres de columnas si los usas de forma coherente, y
  guardar el estado con `ENUM`, con `VARCHAR` + `CHECK` o en una tabla de estados aparte (relación 1-N).
- Los errores de sintaxis o de ejecución (paréntesis, comas, `;` o `DELIMITER` que faltan, palabras clave mal
  escritas, variables sin declarar...) restan **−0,5 una sola vez por ejercicio**, aunque haya varios. Una solución
  que no se ejecuta no puede obtener la puntuación máxima.
- Los nombres de tabla en singular o incorrectos solo se descuentan en el ejercicio 1.
- No se ha penalizado el formato: Blackboard elimina los saltos de línea al exportar las respuestas, y las comillas
  tipográficas (‘ ’) se han tratado como comillas normales.

## Ejercicio 1 — Creación de tablas (1,5 puntos)

```sql
DROP TABLE IF EXISTS RespuestasIncidencia;
DROP TABLE IF EXISTS Incidencias;

CREATE TABLE Incidencias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pedidoId INT NOT NULL,
    fechaApertura DATE NOT NULL,
    asunto VARCHAR(255) NOT NULL,
    descripcion TEXT NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'Abierta' CHECK (estado IN ('Abierta', 'En proceso', 'Cerrada')),
    fechaCierre DATE,
    FOREIGN KEY (pedidoId) REFERENCES Pedidos(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_fecha_cierre_posterior CHECK (fechaCierre IS NULL OR fechaCierre >= fechaApertura)
);

CREATE TABLE RespuestasIncidencia (
    id INT PRIMARY KEY AUTO_INCREMENT,
    incidenciaId INT NOT NULL,
    empleadoId INT,
    fecha DATE NOT NULL,
    mensaje TEXT NOT NULL,
    FOREIGN KEY (incidenciaId) REFERENCES Incidencias(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (empleadoId) REFERENCES Empleados(id)
        ON DELETE SET NULL
        ON UPDATE SET NULL
);
```

**Se acepta también:** `ENUM` o una tabla de estados con sus tres valores en lugar del `CHECK` de `estado`; `DATETIME`
en lugar de `DATE`; otros nombres de columna equivalentes. `CHECK (fechaCierre >= fechaApertura)` sin
`fechaCierre IS NULL` es correcto: un `CHECK` cuyo resultado es NULL no rechaza la fila.

**Descuentos** (−0,5 cada uno):

- Nombre de tabla en singular o distinto de `Incidencias` y `RespuestasIncidencia` (por cada tabla).
- Falta un atributo o se sustituye por otro que no corresponde (por cada atributo).
- `descripcion` o `mensaje` con longitud fija (`VARCHAR(n)`) en lugar de `TEXT` (por cada atributo).
- `estado` sin `DEFAULT 'Abierta'`.
- Faltan `NOT NULL` en atributos obligatorios (una sola vez, aunque falten varios).
- `NOT NULL` en `fechaCierre` o en `empleadoId`, que deben admitir nulos. Además, `NOT NULL` junto a
  `ON DELETE SET NULL` impide crear la tabla.
- `UNIQUE` en `pedidoId` o en `incidenciaId`: un pedido puede tener varias incidencias y una incidencia varias
  respuestas.
- Falta la clave primaria.
- Falta una clave ajena o apunta a una tabla equivocada.
- `estado` no queda restringido a `'Abierta'`, `'En proceso'` y `'Cerrada'`.
- `CHECK` de la fecha de cierre ausente o incorrecto: con `>` o `<` estrictos (debe admitir la misma fecha),
  invertido, que exige `estado = 'Cerrada'` sin admitir `fechaCierre` NULL (rechaza las incidencias abiertas), que
  compara con un valor mal escrito o que obliga a que todas las incidencias estén cerradas.
- Falta `ON DELETE CASCADE` de Pedidos a Incidencias o de Incidencias a RespuestasIncidencia (por cada clave).
- La clave ajena del empleado no es `ON DELETE SET NULL` (con `RESTRICT` el empleado no puede causar baja; con
  `CASCADE` se borran sus respuestas).

## Ejercicio 2.1 — Incidencias sin respuesta reciente (1,5 puntos)

```sql
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
```

**Se acepta también:** `NOT EXISTS` con una subconsulta correlacionada; `LEFT JOIN` a una subconsulta de respuestas
recientes con `IS NULL`; `LEFT JOIN` + `GROUP BY` + `HAVING MAX(fecha) IS NULL OR MAX(fecha) < DATE_SUB(...)`;
condición de fecha en el `ON` del `LEFT JOIN` + `IS NULL`. Las fechas pueden compararse con `DATE_SUB`,
`TIMESTAMPDIFF` o `DATEDIFF`.

**Resultado esperado con los datos de prueba:** las incidencias 1 y 3 de "Cliente Uno". No deben salir una incidencia
abierta ayer, una con una respuesta antigua y otra reciente, ni una cuya última respuesta es de hace exactamente 2
días.

**Descuentos** (−0,5 cada uno):

- Falta o es incorrecto algún `JOIN` necesario (Usuarios–Clientes–Pedidos–Incidencias), se usan columnas que no
  existen o no se devuelve el nombre del cliente.
- Se pierden las incidencias que nunca han recibido respuesta: `INNER JOIN` con las respuestas, consulta que parte de
  las respuestas o `WHERE` sobre una columna de un `LEFT JOIN`.
- `LEFT JOIN` que añade filas que no son incidencias (pedidos sin incidencias).
- Condición de "no cerrada" ausente o incorrecta (filtrar solo `'Abierta'` deja fuera las `'En proceso'`).
- Condición de "abierta hace más de 2 días" ausente o incorrecta (`>= 2`, invertida o calculada respecto a otra
  fecha).
- Lógica invertida: buscar incidencias con alguna respuesta antigua (o reciente) en lugar de excluir las que tienen
  alguna respuesta en los últimos 2 días. Con una condición fila a fila, una incidencia con una respuesta antigua y
  otra reciente sigue apareciendo.
- No se excluyen las incidencias con respuestas recientes (no se usan las respuestas, o su fecha se compara con la
  de apertura en lugar de con la fecha actual).
- Solo se consideran las incidencias sin ninguna respuesta: se pierden las que solo tienen respuestas antiguas.
- La respuesta de hace exactamente 2 días se trata como antigua; el enunciado la considera reciente.
- Agrupación incorrecta (por ejemplo, `GROUP BY` por cliente en lugar de por incidencia).

## Ejercicio 2.2 — Incidencias cerradas y tiempo medio por empleado (2 puntos)

```sql
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
```

**Se acepta también:** `SELECT DISTINCT` en la subconsulta en lugar de `GROUP BY`; una vista con los pares
(empleado, incidencia cerrada); subconsultas correlacionadas en el `SELECT` con `EXISTS` o `IN`; pares sin repetir con
la condición de estado en el `ON`.

**Resultado esperado con los datos de prueba:** Empleado Uno, 3 incidencias y 1,67 días; Empleado Dos, 1 incidencia y
0 días; Empleado Tres, 0 incidencias y 0 días. Empleado Uno respondió dos veces a una misma incidencia, que debe contar
una sola vez.

**Descuentos** (−0,5 cada uno):

- El empleado se relaciona con la incidencia a través de `Pedidos.empleadoId` (quien gestionó el pedido) en lugar de
  a través de las respuestas (quien respondió).
- No se eliminan los pares (empleado, incidencia) repetidos. `COUNT(DISTINCT ...)` arregla el número pero no la
  media, y `AVG(DISTINCT ...)` elimina días repetidos, no incidencias repetidas.
- No se filtran, o se filtran mal, las incidencias cerradas.
- Desaparecen los empleados sin incidencias cerradas (filtro `estado = 'Cerrada'` en el `WHERE` exterior,
  `INNER JOIN` o `RIGHT JOIN`). Deben aparecer con 0.
- Se cuentan respuestas o empleados, o se suma, en lugar de contar incidencias.
- Tiempo medio ausente o mal calculado (días invertidos, hasta la fecha de respuesta en lugar de la de cierre,
  `DAY()` en lugar de una diferencia de fechas...).
- `COALESCE` sin el valor 0: los empleados sin incidencias salen con NULL.
- Falta `GROUP BY` por empleado o se agrupa por otra cosa.
- Columnas o `JOIN` incorrectos o inexistentes (por cada fallo). Una consulta incompleta, sin `SELECT` o sin `FROM`,
  puede perder la puntuación entera.

## Ejercicio 3 — Procedimiento CerrarIncidencia (2,5 puntos)

```sql
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
```

| Bloque | Puntos |
|---|---|
| Validación: la incidencia no existe o ya está cerrada, con el mensaje pedido | 1 |
| `INSERT` de la respuesta con los parámetros y `CURDATE()` | 0,5 |
| `UPDATE` de la incidencia a `'Cerrada'` con `fechaCierre = CURDATE()` | 0,5 |
| Transacción: `START TRANSACTION`, `COMMIT` y `EXIT HANDLER FOR SQLEXCEPTION` que haga `ROLLBACK` y propague el error | 0,5 |

El `EXIT HANDLER` también captura el `SIGNAL` de la validación. Con `ROLLBACK` + `RESIGNAL` (solución de referencia)
quien llama recibe el error original; con `ROLLBACK` + un `SIGNAL` con otro mensaje recibe un error, aunque no el de la
validación (no se ha penalizado). Si solo hace `ROLLBACK`, el procedimiento termina sin avisar y quien llama cree que
todo ha ido bien.

**Descuentos:**

- Validación ausente o que no detecta ninguno de los dos casos (condición con `AND`, invertida, sobre la variable
  equivocada...): −1.
- La validación no detecta la incidencia inexistente (por ejemplo, comprueba si el parámetro es NULL o compara con
  `= NULL`): −0,5.
- La validación no detecta, o invierte, la incidencia ya cerrada, o su consulta es incorrecta: −0,5.
- El mensaje no es literalmente `La incidencia no existe o ya está cerrada.`: −0,25.
- El `INSERT` falta o no usa los parámetros y `CURDATE()`: −0,5. Está mal construido o inserta un mensaje fijo: −0,25.
- El `UPDATE` no cierra la incidencia (falta, inserta una incidencia nueva, asigna un valor erróneo o no tiene
  `WHERE`): −0,5. No asigna `fechaCierre = CURDATE()` (o no cambia el estado), o modifica otros datos: −0,25.
- Sin transacción: −0,5. Sin `EXIT HANDLER` o sin `COMMIT`: −0,25. El manejador solo hace `ROLLBACK` (sin `RESIGNAL`
  ni `SIGNAL`), de modo que el error se pierde sin avisar: −0,25.
- El procedimiento no se llama `CerrarIncidencia`: −0,25.

## Ejercicio 4 — Trigger asegurar_respuesta_incidencia_abierta (2,5 puntos)

```sql
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
```

| Bloque | Puntos |
|---|---|
| Disparo: `BEFORE INSERT ON RespuestasIncidencia` | 0,5 |
| Bloqueo de respuestas a incidencias cerradas: estado leído con `NEW.incidenciaId` y `SIGNAL` | 1 |
| Paso de `'Abierta'` a `'En proceso'` con `UPDATE ... WHERE id = NEW.incidenciaId` | 1 |

El estado debe leerse directamente de `Incidencias` con `NEW.incidenciaId`. Si se obtiene mediante un `JOIN` con las
respuestas, en la primera respuesta de una incidencia no hay ninguna fila y el trigger no ve el estado.

**Descuentos:**

- El trigger no es `BEFORE INSERT ON RespuestasIncidencia` (otra tabla u otro evento): −0,5. Como entonces no actúa
  al insertar respuestas, el bloqueo y la transición valen como máximo la mitad.
- Bloqueo ausente, sin consultar el estado de la incidencia: −1. Bloqueo con fallos (estado obtenido mediante un
  `JOIN` con las respuestas, comparación con un valor mal escrito, variable de un tipo que no puede contenerlo): −0,5.
- Transición ausente o que solo cambia una variable local sin hacer `UPDATE`: −1 (−0,75 si al menos comprueba que
  estaba `'Abierta'`). Transición con fallos (`UPDATE` sin `WHERE`, sin comprobar que estaba `'Abierta'`, sobre la
  fila equivocada o con una búsqueda que falla): −0,5.
- Trigger sin cuerpo, solo con la cabecera: −2.
