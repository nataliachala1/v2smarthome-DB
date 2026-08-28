-- ============================================================
-- VISTA MATERIALIZADA — Resumen Mensual de Consumo por Hogar
-- Archivo: 01_ddl/05_materialized_views/002_mv_resumen_mensual_hogar.sql
-- Descripción: Resumen mensual de consumo por hogar, usado
--              en reportes y proyecciones de facturación
--              mensual (RF2.5, RF4.1)
-- Autor: Karen Daniela Holguín Cruz, Natalia Chala Chala,
--        Kevin Stiven López Amaya
-- Institución: SENA — Análisis y Desarrollo de Software
-- Ficha: 3145555
-- Versión: 1.0.0
-- Fecha: 2025
-- Dependencias: 03_tables/003_create_homes_tables.sql,
--               03_tables/005_create_consumption_tables.sql
--
-- NOTA IMPORTANTE: esta vista NO es para tiempo real (RF4.2).
-- Para monitoreo en tiempo real usar la vista normal
-- consumption.vw_consumo_tiempo_real.
-- ============================================================

-- ============================================================
-- VISTA MATERIALIZADA: consumption.mv_resumen_mensual_hogar
-- Referencia SRS: RF2.5, RF4.1
-- Frecuencia de refresco recomendada: 1 vez al día
-- ============================================================

CREATE MATERIALIZED VIEW IF NOT EXISTS consumption.mv_resumen_mensual_hogar AS
SELECT
  h.id_home,
  h.nombre                          AS nombre_hogar,
  DATE_TRUNC('month', c.read_at)::DATE AS mes,
  SUM(c.energy_delta_kwh)           AS kwh_total_mes,
  SUM(c.costo_estimado) FILTER (WHERE c.costo_estimado IS NOT NULL) AS costo_total_mes,
  COUNT(*) FILTER (WHERE c.costo_estimado IS NULL)  AS lecturas_sin_costo,
  AVG(c.power_w)                    AS watts_promedio,
  MAX(c.power_w)                    AS watts_maximo,
  COUNT(DISTINCT DATE(c.read_at))   AS dias_con_datos
FROM consumption.consumption c
JOIN homes.home               h ON h.id_home = c.id_home
                                 AND h.deleted_at IS NULL
GROUP BY h.id_home, h.nombre, DATE_TRUNC('month', c.read_at);

-- ============================================================
-- COMANDO DE REFRESCO
-- ============================================================

-- REFRESH MATERIALIZED VIEW CONCURRENTLY consumption.mv_resumen_mensual_hogar;

-- ============================================================
-- OPCIÓN A — Programación con pg_cron (recomendada)
-- Requiere la extensión pg_cron instalada en el contenedor
-- PostgreSQL (no viene en la imagen oficial 'postgres').
-- Descomentar si pg_cron está disponible.
-- ============================================================

-- CREATE EXTENSION IF NOT EXISTS pg_cron;
--
-- SELECT cron.schedule(
--   'refresh_mv_resumen_mensual_hogar',
--   '0 1 * * *',  -- todos los días a la 1:00 AM
--   $$REFRESH MATERIALIZED VIEW CONCURRENTLY consumption.mv_resumen_mensual_hogar$$
-- );

-- ============================================================
-- OPCIÓN B — Programación desde el backend (alternativa)
-- Si pg_cron no está disponible, programar un job
-- (node-cron, Celery, APScheduler) que ejecute diariamente:
--
--   REFRESH MATERIALIZED VIEW CONCURRENTLY consumption.mv_resumen_mensual_hogar;
--
-- Mismo comando que en la Opción A; solo cambia el disparador.
-- ============================================================