-- 1: Smartphone
-- 2: Laptop 
-- 3: Libro Electrónico
-- 4: Videojuego
-- 7: Película
-- 9: Tableta gráfica

CALL insertarPromocion(	1, 0.20, '2025-06-01', '2025-06-30'); -- Ya ha pasado
CALL insertarPromocion(	2, 0.20, '2025-07-01', '2025-07-31'); -- Activo
CALL insertarPromocion(	3, 0.10, '2025-07-01', '2025-07-31'); -- Activo
CALL insertarPromocion(	4, 0.40, '2025-08-01', '2025-08-31'); -- Próximamente
CALL insertarPromocion(	7, 0.05, '2025-06-01', '2025-06-30'); -- Ya ha pasado
CALL insertarPromocion(	9, 0.10, '2025-07-01', '2025-07-31'); -- Activo
