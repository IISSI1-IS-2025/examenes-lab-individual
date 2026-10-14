# Enunciado Evaluación Individual de Laboratorio - Convocatoria de Octubre 2026

**Si usted entrega sin haber sido verificada su identidad no podrá ser evaluado.**

## Tienda Online

Partiendo de la `tiendaOnline` vista durante los laboratorios descrita en el modelado conceptual siguiente:

![tiendaOnlineModeladoConceptual](./tiendaOnline.svg)

Las tablas y datos de prueba iniciales se encuentran en los ficheros `0.creacionTablas.sql` y `0.poblarBd.sql`.

Realice los siguientes ejercicios:

### 1. Creación de tablas. 1,5 puntos

Necesitamos gestionar las incidencias que nuestros clientes abren sobre sus pedidos (por ejemplo, un producto dañado, un retraso en el envío o una consulta sobre la factura). Para ello, se propone la creación de una nueva tabla llamada `Incidencias`. Cada incidencia está asociada a un único pedido, y un pedido puede tener varias incidencias.

Para cada incidencia necesitamos conocer la fecha de apertura, un asunto breve, una descripción -que no debe tener un límite de caracteres fijo- y el estado en el que se encuentra, que solo puede ser "Abierta", "En proceso" o "Cerrada" (por defecto, "Abierta"). También necesitamos la fecha de cierre, que solo existirá si la incidencia ya se ha cerrado, y que en ese caso debe ser igual o posterior a la fecha de apertura.

Sin embargo, con esto no es suficiente, ya que no conoceríamos las respuestas que el personal de atención al cliente va dando a cada incidencia. Por ello, se necesita también una tabla `RespuestasIncidencia` en la que se registre, para cada respuesta, la incidencia a la que pertenece, el empleado que la redacta (puede quedar sin empleado asignado si éste causa baja en la empresa, pero la respuesta debe conservarse), la fecha, y el mensaje -tampoco con límite de caracteres fijo-.

Asegúrese de que si se borra un pedido, se borren también sus incidencias y las respuestas asociadas a esas incidencias.

### 2. Consultas SQL (DQL). 3,5 puntos

#### 2.1. 1,5 puntos

Devuelva el nombre del cliente, el id de la incidencia y la fecha de apertura de aquellas incidencias que, sin estar cerradas, llevan abiertas más de 2 días y no han recibido ninguna respuesta en los últimos 2 días (es decir, no tienen ninguna respuesta con fecha igual o posterior a la de hace 2 días). Deben aparecer tanto las incidencias que nunca han recibido respuesta como las que solo tienen respuestas más antiguas.

#### 2.2. 2 puntos

Devuelva el nombre e id de cada empleado, el número de incidencias que ha cerrado (es decir, en las que ha respondido y que terminaron en estado "Cerrada") y el tiempo medio, en días, que se tardó en resolverlas (desde su fecha de apertura hasta su fecha de cierre). Tenga en cuenta que un empleado puede haber respondido varias veces a una misma incidencia: cada incidencia debe contar una sola vez, tanto en el número de incidencias como en el cálculo del tiempo medio. Deben aparecer también aquellos empleados que no hayan cerrado ninguna incidencia, con 0 incidencias y un tiempo medio de 0 días.

AYUDA: La función `COALESCE(valor1, valor2, ...)` devuelve el primer valor no nulo de la lista de argumentos. Es especialmente útil cuando una función de agregación como `AVG()` o `SUM()` devuelve `NULL` porque no hay valores que agregar. Ejemplo:

```sql
-- Si el pedido 99 no tiene líneas, AVG devuelve NULL. COALESCE lo convierte en 0.
SELECT COALESCE(AVG(precio), 0) FROM LineasPedido WHERE pedidoId = 99;
```

### 3. Procedimiento. 2,5 puntos

Cree un procedimiento llamado `CerrarIncidencia`, que, dado el id de una incidencia, el id del empleado que la resuelve y un mensaje, registre la respuesta de cierre y marque la incidencia como cerrada con la fecha actual.

Asegure que la incidencia existe y que no está ya cerrada, y, si no se cumple, devuelva el siguiente error: (1 punto)

```
La incidencia no existe o ya está cerrada.
```

Garantice que o bien se realizan todas las operaciones o bien no se realiza ninguna.

### 4. Trigger. 2,5 puntos

Cree un trigger `asegurar_respuesta_incidencia_abierta` que:

- Impida insertar una nueva respuesta en una incidencia que ya se encuentre en estado "Cerrada". (1,5 puntos)
- Si la incidencia estaba en estado "Abierta", al insertarse la primera respuesta la pase automáticamente a estado "En proceso". (1 punto)

### NOTA. Avisar a profesor ANTES de realizar la entrega

Antes de realizar la entrega, levante la mano y muestre su DNI o similar al profesor del aula para la verificación de su identidad.

Si ha llegado al límite de tiempo, el sistema realizará una entrega automática, espere al profesor a que verifique su identidad.

**Si su identidad no ha sido verificada no podrá ser evaluado.**

**ATENCIÓN: las pantallas están siendo grabadas durante la realización de esta prueba. Se le informa formalmente de que dichas grabaciones podrán ser utilizadas para la comprobación de la autoría y del proceso de realización de la prueba.**
