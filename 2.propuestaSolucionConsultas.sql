-- 2.1
SELECT
    p.nombre AS nombre_producto,
    tp.nombre AS nombre_tipo_producto,
    lp.precio AS precio_unitario
FROM
    LineasPedido lp
JOIN
    Productos p ON lp.productoId = p.id
JOIN
    TiposProducto tp ON p.tipoProductoId = tp.id
WHERE
    tp.nombre = 'Digitales';


-- 2.2
SELECT 
    u.nombre AS nombre_empleado,
    COUNT(DISTINCT p.id) AS numero_pedidos_mas_de_500,
    SUM(lp.precio * lp.unidades) AS importe_total
FROM 
    Empleados e
LEFT JOIN 
    Usuarios u ON e.usuarioId = u.id
LEFT JOIN 
    Pedidos p ON e.id = p.empleadoId
LEFT JOIN 
    LineasPedido lp ON p.id = lp.pedidoId
GROUP BY 
    u.nombre
HAVING 
    SUM(lp.precio * lp.unidades) > 500 OR numero_pedidos_mas_de_500 = 0 -- Incluye empleados con pedidos > 500
ORDER BY 
    importe_total DESC;



SELECT SUM(lp2.precio * lp2.unidades) as totalPedido, lp2.pedidoId
         FROM LineasPedido lp2 
         group by lp2.pedidoId
         having totalPedido>500
         
