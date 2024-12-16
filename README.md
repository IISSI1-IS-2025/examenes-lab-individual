# Enunciado Evaluación Individual de Laboratorio - Modelo A
**Si usted entrega sin haber sido verificada su identidad no podrá ser evaluado.**

## Tienda Online

Partiendo de la `tiendaOnline` vista durante los laboratorios descrita en el modelado conceptual siguiente:

![tiendaOnlineModeladoConceptual](https://github.com/user-attachments/assets/92eb4ba8-1ed8-488b-bb5b-448c0836fee6)

Las tablas y datos de prueba iniciales se encuentran en los ficheros `0.creacionTablas.sql` y `0.poblarBd.sql`.

Realice los siguientes ejercicios:

### 1. Creación de tabla. (1,5 puntos)

Incluya su solución en el fichero `1.solucionCreacionTabla.sql`.

Necesitamos conocer la garantía de nuestros productos. Para ello se propone la creación de una nueva tabla llamada `Garantias`. Cada producto tendrá como máximo una garantía (no todos los productos tienen garantía), y cada garantía estará relacionada con un producto.

Para cada garantía necesitamos conocer la fecha de inicio de la garantía, la fecha de fin de la garantía, si tiene garantía extendida o no.

Asegure que la fecha de fin de la garantía es posterior a la fecha de inicio.

### 2. Consultas SQL (DQL). (3 puntos)

Incluya su solución en el fichero `2.solucionConsultas.sql`.

#### 2.1. Devuelva el nombre del producto, nombre del tipo de producto, y precio unitario al que se vendieron los productos digitales (1 punto)

#### 2.2. Consulta que devuelva el nombre del empleado, el número de pedidos de más de 500 euros gestionados en este año y el importe total de cada uno de ellos, ordenados de mayor a menor importe gestionado. Los empleados que no hayan gestionado ningún pedido, también deben aparecer. (2 puntos)

### 3. Procedimiento. Actualizar precio de un producto y líneas de pedido no enviadas. (3,5 puntos)

Incluya su solución en el fichero `3.solucionProcedimiento.sql`.

Cree un procedimiento que permita actualizar el precio de un producto dado y que modifique los precios de las líneas de pedido asociadas al producto dado solo en aquellos pedidos que aún no hayan sido enviados. (1,5 puntos)

Asegure que el nuevo precio no sea un 50% menor que el precio actual y lance excepción si se da el caso con el siguiente mensaje: (1 punto)

`No se permite rebajar el precio más del 50%`.

Garantice que o bien se realizan todas las operaciones o bien no se realice ninguna. (1 punto)

### 4. Trigger. 2 puntos.

Incluya su solución en el fichero `4.solucionTrigger.sql`.

Cree un trigger llamado `t_asegurar_mismo_tipo_producto_en_pedidos` que impida que, a partir de ahora, un mismo pedido incluya productos físicos y digitales.

## Procedimiento de entrega:

### 1. Comprimir ficheros

Cree un fichero `zip` que incluya los ficheros:

* `1.solucionCreacionTabla.sql`
* `2.solucionConsultas.sql`
* `3.solucionProcedimiento.sql`
* `4.solucionTrigger.sql`

### 2. Subir fichero `zip`

Súba el `zip` como fichero de solución en el examen de enseñanza virtual. **No pulse aún en enviar.**

### 3. Avisar a profesor ANTES de realizar la entrega

Antes de realizar la entrega, levante la mano y muestre su DNI o similar al profesor del aula para la verificación de su identidad.

**Si usted entrega sin haber sido verificada su identidad no podrá ser evaluado.**
