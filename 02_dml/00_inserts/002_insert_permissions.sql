-- ============================================================
-- INSERT — Permisos del sistema
-- Archivo: 02_dml/00_inserts/002_insert_permisos.sql
-- Descripción: Inserta todos los permisos del sistema
--              organizados por módulo y acción. Cada permiso
--              habilita una funcionalidad específica del SRS.
-- Autor: Karen Daniela Holguín Cruz, Natalia Chala Chala,
--        Kevin Stiven López Amaya
-- Institución: SENA — Análisis y Desarrollo de Software
-- Ficha: 3145555
-- Versión: 1.0.0
-- Fecha: 2025
-- Referencia SRS: RF1.3
-- Dependencias: 01_ddl/03_tables/001_create_auth_tables.sql
-- ============================================================

INSERT INTO auth.permission (id_permission, nombre, modulo, accion, descripcion, created_at, updated_at)
VALUES
  -- --------------------------------------------------------
  -- Módulo 1 — Gestión de Usuarios y Autenticación
  -- --------------------------------------------------------
  (gen_random_uuid(), 'usuarios:leer',      'usuarios', 'leer',    'Ver listado y detalle de usuarios',            NOW(), NOW()),
  (gen_random_uuid(), 'usuarios:crear',     'usuarios', 'crear',   'Registrar nuevos usuarios',                    NOW(), NOW()),
  (gen_random_uuid(), 'usuarios:editar',    'usuarios', 'editar',  'Modificar datos de usuarios',                  NOW(), NOW()),
  (gen_random_uuid(), 'usuarios:eliminar',  'usuarios', 'eliminar','Desactivar cuentas de usuarios',               NOW(), NOW()),
  (gen_random_uuid(), 'roles:asignar',      'usuarios', 'editar',  'Asignar y modificar roles de usuarios',        NOW(), NOW()),
  (gen_random_uuid(), 'usuarios:ver_todos', 'usuarios', 'leer',    'Ver todos los usuarios del sistema',           NOW(), NOW()),

  -- --------------------------------------------------------
  -- Módulo 2 — Gestión de Hogares y Espacios
  -- --------------------------------------------------------
  (gen_random_uuid(), 'hogares:leer',       'hogares',  'leer',    'Ver hogares propios',                          NOW(), NOW()),
  (gen_random_uuid(), 'hogares:crear',      'hogares',  'crear',   'Registrar nuevos hogares',                     NOW(), NOW()),
  (gen_random_uuid(), 'hogares:editar',     'hogares',  'editar',  'Modificar datos del hogar',                    NOW(), NOW()),
  (gen_random_uuid(), 'hogares:desactivar', 'hogares',  'eliminar','Desactivar hogares',                           NOW(), NOW()),
  (gen_random_uuid(), 'zonas:crear',        'hogares',  'crear',   'Crear zonas dentro de un hogar',               NOW(), NOW()),
  (gen_random_uuid(), 'zonas:editar',       'hogares',  'editar',  'Editar zonas existentes',                      NOW(), NOW()),
  (gen_random_uuid(), 'zonas:eliminar',     'hogares',  'eliminar','Eliminar zonas del hogar',                     NOW(), NOW()),
  (gen_random_uuid(), 'tarifas:configurar', 'hogares',  'editar',  'Configurar tarifas eléctricas',                NOW(), NOW()),

  -- --------------------------------------------------------
  -- Módulo 3 — Gestión de Dispositivos
  -- --------------------------------------------------------
  (gen_random_uuid(), 'dispositivos:leer',               'dispositivos', 'leer',    'Ver dispositivos registrados',              NOW(), NOW()),
  (gen_random_uuid(), 'dispositivos:crear',              'dispositivos', 'crear',   'Registrar nuevos dispositivos',             NOW(), NOW()),
  (gen_random_uuid(), 'dispositivos:editar',             'dispositivos', 'editar',  'Modificar configuración de dispositivos',   NOW(), NOW()),
  (gen_random_uuid(), 'dispositivos:desactivar',         'dispositivos', 'eliminar','Desactivar dispositivos',                   NOW(), NOW()),
  (gen_random_uuid(), 'dispositivos:controlar',          'dispositivos', 'editar',  'Encender/apagar dispositivos remotamente',  NOW(), NOW()),
  (gen_random_uuid(), 'dispositivos:configurar_horarios','dispositivos', 'editar',  'Configurar horarios automáticos',           NOW(), NOW()),
  (gen_random_uuid(), 'dispositivos:configurar_umbrales','dispositivos', 'editar',  'Configurar umbrales de consumo',            NOW(), NOW()),
  (gen_random_uuid(), 'asistente_voz:vincular',          'dispositivos', 'crear',   'Vincular asistentes de voz',               NOW(), NOW()),

  -- --------------------------------------------------------
  -- Módulo 4 — Monitoreo y Consumo Energético
  -- --------------------------------------------------------
  (gen_random_uuid(), 'consumo:leer',               'consumo', 'leer',  'Ver consumo en tiempo real',                        NOW(), NOW()),
  (gen_random_uuid(), 'consumo:reportes',           'consumo', 'leer',  'Generar y ver reportes de consumo',                 NOW(), NOW()),
  (gen_random_uuid(), 'consumo:graficos',           'consumo', 'leer',  'Ver gráficos de consumo',                           NOW(), NOW()),
  (gen_random_uuid(), 'recomendaciones:leer',       'consumo', 'leer',  'Ver recomendaciones de ahorro',                     NOW(), NOW()),
  (gen_random_uuid(), 'recomendaciones:configurar', 'consumo', 'editar','Configurar recomendaciones automáticas',             NOW(), NOW()),
  (gen_random_uuid(), 'notificaciones:leer',        'consumo', 'leer',  'Ver notificaciones',                                NOW(), NOW()),
  (gen_random_uuid(), 'notificaciones:configurar',  'consumo', 'editar','Configurar preferencias de notificaciones',          NOW(), NOW()),

  -- --------------------------------------------------------
  -- Módulo 5 — Sincronización de Plataforma
  -- --------------------------------------------------------
  (gen_random_uuid(), 'sync:manual',       'sync', 'editar','Forzar sincronización manual',            NOW(), NOW()),
  (gen_random_uuid(), 'backups:restaurar', 'sync', 'editar','Restaurar información desde backup',      NOW(), NOW()),
  (gen_random_uuid(), 'backups:leer',      'sync', 'leer',  'Ver backups disponibles',                 NOW(), NOW()),

  -- --------------------------------------------------------
  -- Módulo 6 — Personalización e Internacionalización
  -- --------------------------------------------------------
  (gen_random_uuid(), 'config:leer',  'config', 'leer',  'Ver configuración personal',        NOW(), NOW()),
  (gen_random_uuid(), 'config:editar','config', 'editar','Modificar configuración personal',   NOW(), NOW()),

  -- --------------------------------------------------------
  -- Módulo 7 — Auditoría y Trazabilidad
  -- --------------------------------------------------------
  (gen_random_uuid(), 'auditoria:leer',    'auditoria', 'leer','Consultar logs de auditoría',      NOW(), NOW()),
  (gen_random_uuid(), 'auditoria:exportar','auditoria', 'leer','Exportar registros de auditoría',  NOW(), NOW())

ON CONFLICT (nombre) DO NOTHING;