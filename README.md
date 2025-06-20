# Enunciado del Examen Individual de Laboratorio - Segunda Convocatoria
**Si usted entrega sin haber sido verificada su identidad no podrá ser evaluado.**

## Tienda Online

Partiendo de la `tiendaOnline` vista durante los laboratorios descrita en el modelado conceptual siguiente:

![tiendaOnlineModeladoConceptual](https://github.com/user-attachments/assets/92eb4ba8-1ed8-488b-bb5b-448c0836fee6)

Las tablas y datos de prueba iniciales se encuentran en los ficheros `0.1.creacionTablas.sql` y `0.2.poblarBd.sql`. Cree una base de datos y ejecute dichos scripts en el citado orden.

Realice los siguientes ejercicios:

### 1. Creación de tabla. 1 punto

Incluya su solución en el fichero `1.solucionCreacionTabla.sql`.

Necesitamos conocer las promociones de nuestros productos. Para ello se propone la creación de una nueva tabla llamada `Promociones`. Cada promoción solo estará relacionada con un producto, de manera que no todos los productos están promocionados.

Para cada promoción necesitamos conocer el descuento aplicado, la fecha de inicio y fecha de fin de la promoción.

Asegure que la fecha de fin de la promoción es posterior a la fecha de inicio.

### 2. Procedimiento. 1 punto

Incluya su solución en el fichero `2.solucionInsercionTabla.sql`.

Complete el procedimiento almacenado que se encuentra en el fichero para insertar una nueva promoción con los datos pasados como parámetros. 

Una vez que se ha compilado el procedimiento, ejecute el fichero `0.3.poblarPromociones.sql`.

### 2. Consultas. 3,5 puntos

Incluya su solución en el fichero `3.solucionConsultas.sql`.

#### 2.1. 0,75 puntos

Obtener las promociones activas actualmente, junto con los productos implicados y precios finales tras aplicar descuento.

#### 2.2. 1 punto

Productos nunca promocionados hasta la fecha.

#### 2.3. 1,75 puntos

Pensar una consulta (?)

### 4. Trigger. 2 puntos

Incluya su solución en el fichero `4.solucionTrigger.sql`.

Cree un trigger llamado `trg_actualizar_precio_pedido_promocion` que, al insertar una nueva línea de pedido, automáticamente aplique el precio con descuento si hay promoción activa.

Genere un caso de prueba que inserte un nuevo pedido y agregue al menos tres líneas de pedido, de manera que una línea corresponda a un producto con promoción ya pasada, otra línea con producto en promoción y otra más con promoción aún no activa. Compruebe que el trigger se ha ejecutado de la manera esperada.

### 5. Procedimiento. 2,5 puntos

Incluya su solución en el fichero `5.solucionProcedimiento.sql`.

Cree un procedimiento almacenado con transacción llamado `p_anularPedido` que reciba como parámetro un número de pedido. Deberá actualizar el campo de stock de producto, así como eliminar las líneas de pedido y el propio pedido.

Prueba este procedimiento anulando el pedido con el que se ha probado el apartado anterior. Compruebe que el procedimiento se ha ejecutado de la manera esperada.

## Procedimiento de entrega:

### 1. Comprimir ficheros

Cree un fichero `zip` que incluya los ficheros:

* `1.solucionCreacionTabla.sql`
* `2.solucionInsercionTabla.sql`
* `3.solucionConsultas.sql`
* `4.solucionTrigger.sql`
* `5.solucionProcedimiento.sql`

### 2. Subir fichero `zip`

Súba el `zip` como fichero de solución en el examen de enseñanza virtual. **No pulse aún en enviar.**

### 3. Avisar a profesor ANTES de realizar la entrega

Antes de realizar la entrega, levante la mano y muestre su DNI o similar al profesor del aula para la verificación de su identidad.

**Si usted entrega sin haber sido verificada su identidad no podrá ser evaluado.**
