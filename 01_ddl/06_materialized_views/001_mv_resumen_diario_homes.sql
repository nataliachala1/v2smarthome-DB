-- ============================================================
-- VISTA MATERIALIZADA — Resumen Diario de Consumo por Hogar
-- Archivo: 01_ddl/05_materialized_views/001_mv_resumen_diario_hogar.sql
-- Descripción: Resumen diario de consumo por hogar,
--              agregando todas las lecturas del día.
--              Base para gráficos diarios y semanales (RF4.3)
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
-- VISTA MATERIALIZADA: consumption.mv_resumen_diario_hogar
-- Referencia SRS: RF4.1, RF4.3
-- Frecuencia de refresco recomendada: 1 vez al día (madrugada)
-- ============================================================
CREATE MATERIALIZED VIEW IF NOT EXISTS consumption.mv_resumen_diario_hogar AS
SELECT
  h.id_home,
  h.nombre                          AS nombre_hogar,
  DATE(c.read_at)                   AS fecha,
  SUM(c.energy_delta_kwh)           AS kwh_total_dia,
  SUM(c.estimated_cost) FILTER (WHERE c.estimated_cost IS NOT NULL) AS costo_total_dia,
  COUNT(*) FILTER (WHERE c.estimated_cost IS NULL) AS lecturas_sin_costo,
  AVG(c.power_w)                    AS average_watts,
  MAX(c.power_w)                    AS max_watts,
  MIN(c.power_w)                    AS min_watts,
  COUNT(DISTINCT c.id_device)       AS dispositivos_con_lectura
FROM consumption.consumption c
JOIN homes.home               h ON h.id_home = c.id_home
                                 AND h.deleted_at IS NULL
GROUP BY h.id_home, h.nombre, DATE(c.read_at);