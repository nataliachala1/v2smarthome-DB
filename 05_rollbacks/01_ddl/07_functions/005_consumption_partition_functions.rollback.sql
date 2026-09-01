-- ============================================================
-- ROLLBACK - funcion de mantenimiento de particiones
--
-- Nota: elimina la funcion, NO elimina particiones ni datos ya
-- creados por ella. Borrar particiones con datos seria una
-- operacion destructiva y debe manejarse de forma explicita.
-- ============================================================

DROP FUNCTION IF EXISTS consumption.fn_ensure_consumption_partitions(INT);
