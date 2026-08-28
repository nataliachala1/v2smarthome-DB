-- ============================================================
-- RLS: consumption.consumption
-- ============================================================
ALTER TABLE consumption.consumption ENABLE ROW LEVEL SECURITY;
ALTER TABLE consumption.consumption FORCE ROW LEVEL SECURITY;

-- Usuario final: solo lee lecturas de hogares donde es miembro activo
CREATE POLICY consumption_select_policy ON consumption.consumption
  FOR SELECT TO smarthome_app
  USING (
    homes.fn_is_home_member(id_home)
  );

-- Ingesta MQTT: ya acotada por GRANT a solo INSERT. La consistencia
-- id_device <-> id_home se valida en la capa de ingestión, no aquí.
CREATE POLICY consumption_ingest_insert_policy ON consumption.consumption
  FOR INSERT TO smarthome_ingest
  WITH CHECK (true);

-- Worker: necesita leer todas las lecturas de todos los hogares
-- para calcular agregados por lotes.
CREATE POLICY consumption_worker_select_policy ON consumption.consumption
  FOR SELECT TO smarthome_worker
  USING (true);

-- ============================================================
-- RLS: consumption.consumption_metric
-- ============================================================
ALTER TABLE consumption.consumption_metric ENABLE ROW LEVEL SECURITY;
ALTER TABLE consumption.consumption_metric FORCE ROW LEVEL SECURITY;

CREATE POLICY consumption_metric_select_policy ON consumption.consumption_metric
  FOR SELECT TO smarthome_app
  USING (
    homes.fn_is_home_member(id_home)
  );

CREATE POLICY consumption_metric_worker_select_policy ON consumption.consumption_metric
  FOR SELECT TO smarthome_worker
  USING (true);

CREATE POLICY consumption_metric_worker_insert_policy ON consumption.consumption_metric
  FOR INSERT TO smarthome_worker
  WITH CHECK (true);

CREATE POLICY consumption_metric_worker_update_policy ON consumption.consumption_metric
  FOR UPDATE TO smarthome_worker
  USING (true);

-- ============================================================
-- RLS: consumption.recommendation
-- ============================================================
ALTER TABLE consumption.recommendation ENABLE ROW LEVEL SECURITY;
ALTER TABLE consumption.recommendation FORCE ROW LEVEL SECURITY;

CREATE POLICY recommendation_select_policy ON consumption.recommendation
  FOR SELECT TO smarthome_app
  USING (
    homes.fn_is_home_member(id_home)
    AND deleted_at IS NULL
  );

-- El usuario final solo puede cambiar el estado (pendiente/implementada/
-- descartada) de una recomendación de su propio hogar; nunca crearla.
CREATE POLICY recommendation_update_policy ON consumption.recommendation
  FOR UPDATE TO smarthome_app
  USING (
    homes.fn_is_home_member(id_home)
    AND deleted_at IS NULL
  );

CREATE POLICY recommendation_worker_select_policy ON consumption.recommendation
  FOR SELECT TO smarthome_worker
  USING (true);

CREATE POLICY recommendation_worker_insert_policy ON consumption.recommendation
  FOR INSERT TO smarthome_worker
  WITH CHECK (true);

CREATE POLICY recommendation_worker_update_policy ON consumption.recommendation
  FOR UPDATE TO smarthome_worker
  USING (true);