-- Insertar los dos envíos pedidos en el enunciado


-- Insertar los mismos pedidos que en el script de poblado de la base de datos, con los datos de envío pertinentes.


-- Inserciones de líneas pedidos copiadas del script de poblado de la base de datos
INSERT INTO LineasPedido (pedidoId, productoId, unidades, precio) VALUES
(1, 1, 1, 699.99),   -- Smartphone (permitido)
(1, 5, 2, 15.99),    -- Camiseta (permitido)
(1, 3, 1, 9.99),     -- Libro Electrónico (permitido)
(3, 2, 1, 1100.00),   -- Laptop (permitido)
(3, 8, 2, 29.99),    -- Audífono (permitido)
(3, 9, 1, 12.99);     -- Tableta (permitido)
