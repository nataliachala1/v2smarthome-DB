GRANT USAGE ON SCHEMA consumption
  TO smarthome_admin, smarthome_app, smarthome_readonly, smarthome_ingest, smarthome_worker;

-- smarthome_admin: acceso total
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA consumption TO smarthome_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA consumption TO smarthome_admin;

-- smarthome_app: solo lectura + marcar estado de recomendación
GRANT SELECT ON ALL TABLES IN SCHEMA consumption TO smarthome_app;
GRANT UPDATE (estado, updated_at) ON consumption.recommendation TO smarthome_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA consumption TO smarthome_app;

-- smarthome_ingest: solo inserta lecturas crudas
GRANT INSERT ON consumption.consumption TO smarthome_ingest;

-- smarthome_worker: calcula métricas, genera recomendaciones, mantiene particiones
GRANT SELECT ON consumption.consumption TO smarthome_worker;
GRANT SELECT, INSERT, UPDATE ON consumption.consumption_metric TO smarthome_worker;
GRANT SELECT, INSERT, UPDATE ON consumption.recommendation TO smarthome_worker;
GRANT EXECUTE ON FUNCTION consumption.fn_ensure_consumption_partitions(INT) TO smarthome_worker;

-- smarthome_readonly: solo lectura (reportes/BI)
GRANT SELECT ON ALL TABLES IN SCHEMA consumption TO smarthome_readonly;

-- Aplicar a tablas futuras
ALTER DEFAULT PRIVILEGES IN SCHEMA consumption
  GRANT SELECT ON TABLES TO smarthome_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA consumption
  GRANT SELECT ON TABLES TO smarthome_readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA consumption
  GRANT ALL PRIVILEGES ON TABLES TO smarthome_admin;