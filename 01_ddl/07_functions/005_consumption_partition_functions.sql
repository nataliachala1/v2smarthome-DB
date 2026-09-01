-- ============================================================
-- FUNCIONES — Mantenimiento de particiones de consumption
-- Archivo: 01_ddl/07_functions/005_consumption_partition_functions.sql
-- Descripción: Función idempotente que garantiza la existencia
--              de la partición del mes actual y de los próximos
--              N meses de consumption.consumption. Se ejecuta:
--                1) una vez desde Liquibase al desplegar (bootstrap)
--                2) periódicamente desde un scheduler de NestJS
-- Dependencias: 03_tables/005_create_consumption_tables.sql
-- ============================================================

CREATE OR REPLACE FUNCTION consumption.fn_ensure_consumption_partitions(
  meses_adelante INT DEFAULT 3
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, consumption
AS $$
DECLARE
  i           INT;
  inicio_mes  DATE;
  fin_mes     DATE;
  nombre_part TEXT;
BEGIN

  IF meses_adelante < 0 OR meses_adelante > 24 THEN
    RAISE EXCEPTION
      'meses_adelante debe estar entre 0 y 24';
  END IF;

  FOR i IN 0..meses_adelante LOOP

    inicio_mes :=
      date_trunc('month', NOW())::date
      + (i || ' months')::interval;

    fin_mes :=
      inicio_mes + INTERVAL '1 month';

    nombre_part :=
      'consumption_' || to_char(inicio_mes, 'YYYY_MM');

    IF NOT EXISTS (
      SELECT 1
      FROM pg_catalog.pg_class c
      JOIN pg_catalog.pg_namespace n
        ON n.oid = c.relnamespace
      WHERE n.nspname = 'consumption'
        AND c.relname = nombre_part
    ) THEN

      EXECUTE format(
        'CREATE TABLE consumption.%I
         PARTITION OF consumption.consumption
         FOR VALUES FROM (%L) TO (%L)',
        nombre_part,
        inicio_mes,
        fin_mes
      );

    END IF;

  END LOOP;
END;
$$;

COMMENT ON FUNCTION consumption.fn_ensure_consumption_partitions(INT)
  IS 'Crea, si no existen, las particiones mensuales de consumption.consumption desde el mes actual hasta N meses adelante. Idempotente: segura de ejecutar repetidamente. Invocada por Liquibase al desplegar y por el scheduler de NestJS.';

-- ============================================================
-- BOOTSTRAP: crear la partición del mes actual + próximos 3
-- (se ejecuta una sola vez al aplicar este changeset)
-- ============================================================
SELECT consumption.fn_ensure_consumption_partitions(3);