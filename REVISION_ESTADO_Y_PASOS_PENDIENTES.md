# Revisión final y cambios pendientes — Base de datos Smart Home

**Proyecto:** Smart Home  
**Fecha de revisión:** 28 de agosto de 2026  
**Motor:** PostgreSQL  
**Migraciones:** Liquibase  
**Backend:** NestJS + Prisma  
**IoT:** MQTT  
**Tiempo real:** WebSocket  
**Documento de referencia funcional principal:** SRS Smart Home v2.0 — 26/08/2026

---

## 1. Veredicto

La base de datos ha mejorado de forma importante respecto a la auditoría inicial y **la dirección del modelo actual es correcta**, especialmente en:

- simplificación de autenticación;
- separación de roles globales y roles del hogar;
- uso de `home_member`;
- cambio de `area` a `zone`;
- separación entre potencia, energía acumulada y energía incremental;
- particionado de consumo;
- incorporación de telemetría eléctrica;
- RLS;
- eliminación progresiva de `DELETE` sobre históricos;
- uso de `gen_random_uuid()`;
- incorporación de Docker y changeSets de Liquibase.

Sin embargo, **todavía no recomiendo declarar la base como terminada ni aprobada para implementación final**.

El motivo principal ya no es el diseño conceptual. El problema pendiente es la **consistencia del repositorio completo y su ejecutabilidad real**: todavía existen referencias heredadas, objetos que no coinciden con las tablas actuales, DML/RLS/triggers/vistas que deben alinearse y una validación completa de Liquibase sobre una base limpia que aún debe cerrarse.

La conclusión correcta es:

> **Modelo conceptual: bien encaminado y mayormente alineado.**  
> **Implementación SQL/Liquibase: todavía requiere correcciones y una prueba completa desde cero.**

---

# 2. Sobre los cambios realizados en `auth.user`

## 2.1 La simplificación de `user` es correcta

De acuerdo con el SRS v2.0 vigente, el registro ya no requiere toda la información que aparecía en el SRS anterior.

El registro actual necesita principalmente:

- nombre;
- correo electrónico;
- contraseña;
- nombre de usuario únicamente si realmente se decide utilizar.

Por lo tanto, si se eliminaron campos como:

- tipo de documento;
- número de documento;
- fecha de nacimiento;
- MFA habilitado;
- refresh token;
- tokens JWT;
- datos de sesión persistente;
- campos de autenticación que no se van a implementar;

**el cambio es correcto y está alineado con el alcance actual**, siempre que también se eliminen las funciones, vistas, seeds, triggers, procedimientos y validaciones que todavía intenten utilizar esos campos.

No debe conservarse una columna solamente porque existía en una versión anterior del SRS.

---

## 2.2 Modelo mínimo recomendado para `auth.user`

No es obligatorio utilizar exactamente estos nombres, pero conceptualmente la tabla debería conservar como mínimo:

```text
id_user
name
email
password_hash

failed_login_attempts
locked_until
last_login_at

created_at
updated_at
deactivated_at
```

Opcional:

```text
username
```

Solo mantener `username` si realmente será visible o utilizado en autenticación/perfil. Si el sistema trabajará únicamente con correo, se puede eliminar.

### Reglas necesarias

`id_user`

- UUID.
- PK.
- `DEFAULT gen_random_uuid()`.

`email`

- `NOT NULL`.
- Debe ser único sin diferenciar mayúsculas/minúsculas.
- No basta con `UNIQUE(email)` si se quiere impedir:

```text
Usuario@correo.com
usuario@correo.com
```

Recomendación:

```sql
CREATE UNIQUE INDEX uq_user_email_ci
ON auth.user (LOWER(email));
```

`password_hash`

- `NOT NULL`.
- Nunca guardar contraseña original.
- NestJS genera y verifica el hash.
- Argon2id es una opción adecuada.
- No almacenar un `salt` separado.

`failed_login_attempts`

- `NOT NULL DEFAULT 0`.
- Recomendable:

```sql
CHECK (failed_login_attempts >= 0)
```

`locked_until`

- `TIMESTAMPTZ NULL`.
- El bloqueo actual acordado es de 15 minutos al alcanzar 5 intentos fallidos.

`last_login_at`

- Puede ser `NULL` hasta el primer login correcto.

`deactivated_at`

- Permite implementar soft delete.
- `NULL` significa que la cuenta no está desactivada.
- Una reactivación puede volver este campo a `NULL`.

`created_at` / `updated_at`

- `TIMESTAMPTZ`.
- Mantenerlos para trazabilidad técnica.

---

## 2.3 Lo que NO debe volver a `auth.user`

No recomiendo volver a agregar:

```text
mfa_enabled
access_token
refresh_token
session_token
recovery_token
recovery_code
document_type
document_number
birth_date
```

salvo que el alcance vuelva a cambiar explícitamente.

El token de recuperación no pertenece a `auth.user`. Debe mantenerse en una tabla independiente.

---

## 2.4 Recuperación de contraseña

Mantener una entidad similar a:

```text
auth.recovery_token
```

Campos conceptuales:

```text
id_recovery_token
id_user
token_hash
expires_at
used_at
created_at
```

Reglas:

- PostgreSQL almacena solo `token_hash`.
- El token original se entrega al usuario, pero no se persiste.
- Expiración inicial: 30 minutos.
- Un token usado no se puede reutilizar.
- FK hacia `auth.user`.
- No guardar JWT en esta tabla.

---

# 3. Autenticación: elementos que deben eliminarse del baseline

Si todavía existen en el árbol actual:

```text
auth.session
auth.mfa
auth.token_blacklist
```

deben retirarse del baseline actual.

También deben eliminarse todas sus referencias en:

- vistas;
- materialized views;
- funciones;
- procedimientos;
- triggers;
- DML;
- RLS;
- grants;
- rollbacks;
- documentación.

No basta con eliminar la tabla si luego una vista continúa haciendo `JOIN` contra ella.

---

# 4. Roles

## 4.1 Roles globales

El modelo vigente es:

```text
SYSTEM_ADMIN
USER
```

Estos son roles de plataforma.

No deben mezclarse con los permisos dentro del hogar.

## 4.2 Roles del hogar

La autorización contextual debe salir de:

```text
homes.home_member
```

Roles:

```text
OWNER
MEMBER
GUEST
```

Estados:

```text
PENDING
ACTIVE
REVOKED
LEFT
```

Campos recomendados:

```text
id_home_member
id_home
id_user
role
status
invited_by
invited_at
accepted_at
revoked_at
left_at
created_at
updated_at
```

No todos los timestamps tienen que ser obligatorios en todos los estados.

### Restricción importante

Debe impedirse tener dos membresías pendientes/activas equivalentes para el mismo usuario y hogar.

Una opción es un índice parcial sobre los estados que representan una relación vigente.

La autorización de un hogar debe resolverse mediante `home_member`.

`home.created_by`, si existe, significa quién creó el hogar; **no debe convertirse en la fuente de permisos**.

---

## 4.3 `permission` y `role_permission`

Hay dos alternativas válidas:

### Alternativa A — RBAC configurable

Mantener:

```text
permission
role_permission
```

pero utilizarlas realmente desde NestJS.

### Alternativa B — simplificar

Si únicamente existirán:

```text
SYSTEM_ADMIN
USER
```

y las reglas se programarán en NestJS, se pueden eliminar `permission` y `role_permission`.

No recomiendo conservar un sistema de permisos que no se vaya a utilizar.

---

# 5. Hogares y zonas

El modelo funcional vigente es:

```text
HOME
  -> ZONE
      -> DEVICE
```

Por lo tanto, el nombre correcto debe ser:

```text
homes.zone
```

y no:

```text
homes.area
```

Pendiente obligatorio:

- buscar `homes.area` en TODO el repositorio;
- reemplazar referencias heredadas;
- revisar forward migrations;
- revisar rollbacks;
- revisar vistas;
- revisar funciones;
- revisar triggers;
- revisar DML;
- revisar RLS;
- revisar índices.

Lo mismo aplica si todavía quedan referencias a:

```text
homes.tariff
```

cuando el nombre oficial elegido es:

```text
homes.electricity_tariff
```

Debe existir un único vocabulario técnico.

---

# 6. Integridad hogar → zona → dispositivo

Esta regla debe quedar protegida por PostgreSQL:

> Un dispositivo no puede pertenecer al hogar A y al mismo tiempo apuntar a una zona del hogar B.

Dos diseños son válidos.

## Opción más limpia

Guardar solamente:

```text
device.id_zone
```

y derivar el hogar desde la zona.

## Opción con `id_home` + `id_zone`

Si se conservan ambos por consultas, RLS o rendimiento, utilizar integridad compuesta.

Conceptualmente:

```text
homes.zone
UNIQUE (id_home, id_zone)

devices.device
FOREIGN KEY (id_home, id_zone)
REFERENCES homes.zone(id_home, id_zone)
```

El repositorio actual parece ir por esta segunda estrategia. Es válida, pero debe probarse con un caso cruzado entre dos hogares.

---

# 7. Dispositivos

## 7.1 Separar tres estados diferentes

No utilizar una única columna para mezclar:

- conectado/desconectado;
- activo/desactivado;
- encendido/apagado.

Son conceptos diferentes.

Modelo conceptual:

```text
deactivated_at / lifecycle_status
connection_status
power_state
last_seen_at
```

Ejemplo válido:

```text
dispositivo activo
+
dispositivo desconectado
+
último estado eléctrico OFF
```

---

## 7.2 Wi-Fi y MQTT tampoco son el mismo concepto

No deben estar en un único enum como si fueran opciones excluyentes.

Un Shelly puede usar:

```text
transport = WIFI
messaging_protocol = MQTT
```

al mismo tiempo.

---

## 7.3 `manufacturer_device_id`

Conviene conservar un identificador del fabricante como:

```text
manufacturer_device_id
```

para relacionar el registro interno con el dispositivo físico.

El modelo no debe depender exclusivamente de Shelly.

---

## 7.4 Horarios automáticos

**No recomiendo eliminar `devices.device_schedule`.**

El SRS v2.0 vigente mantiene RF3.2 y especifica que el OWNER puede configurar:

- umbrales;
- horarios;
- preferencias operativas compatibles.

Por tanto, la programación por horario continúa dentro del alcance actual.

No hace falta crear un motor excesivamente complejo.

Una tabla sencilla puede representar:

```text
id_device_schedule
id_device
days_of_week
start_time
action
is_active
created_at
updated_at
```

o un diseño equivalente.

Si se necesita encendido y apagado en la misma programación, puede modelarse como dos acciones o con hora inicial/hora final.

La validación de solapamientos y compatibilidad debe vivir principalmente en NestJS.

---

## 7.5 Umbrales

Tampoco recomiendo eliminar el concepto de:

```text
devices.threshold_rule
```

El SRS actual conserva la configuración de umbrales y la generación de alertas.

El backend debe evaluar las reglas a partir de la telemetría.

Evitar un trigger pesado en PostgreSQL por cada lectura IoT.

---

## 7.6 Historial de estados

`device_status_history` es evaluable.

Puede ser redundante si:

- la telemetría ya conserva estado operacional;
- la auditoría conserva cambios de ciclo de vida y control;
- no existe una consulta funcional que necesite otra tabla específica.

Antes de conservarla, definir qué dato único aporta.

Si no aporta información distinta, se puede eliminar para simplificar.

---

## 7.7 Alexa / asistente de voz

El SRS v2.0 todavía conserva la integración con asistente de voz como requerimiento de prioridad **Media**.

Por tanto:

- eliminar una tabla insegura como `voice_assistant_token` es correcto;
- eliminar toda la funcionalidad de voz solo sería correcto si también se modifica formalmente el SRS/alcance.

Si se implementa, los secretos/tokens no deben almacenarse en texto plano en tablas generales.

---

# 8. Consumo energético

El rediseño hacia:

```text
power_w
energy_total_kwh
energy_delta_kwh
read_at
```

es correcto.

También son apropiados, cuando el dispositivo los entrega:

```text
voltage_v
current_a
frequency_hz
temperature_c
```

## Regla crítica

Los resúmenes diarios/mensuales deben sumar:

```text
energy_delta_kwh
```

y NO sumar repetidamente:

```text
energy_total_kwh
```

porque `energy_total_kwh` representa el contador acumulativo del dispositivo.

---

## 8.1 Reinicios del Shelly

El backend debe definir qué ocurre si el contador acumulativo:

- se reinicia;
- disminuye;
- pierde sincronización;
- llega fuera de orden.

No asumir siempre:

```text
delta = total_actual - total_anterior
```

sin validar el resultado.

Nunca insertar un delta negativo de consumo por un simple reinicio del dispositivo.

---

## 8.2 `id_home` + `id_device`

Si las lecturas guardan ambos, PostgreSQL debe garantizar que corresponden.

Conceptualmente:

```text
devices.device
UNIQUE (id_home, id_device)

consumption.energy_reading
FOREIGN KEY (id_home, id_device)
REFERENCES devices.device(id_home, id_device)
```

Si `id_home` puede derivarse de forma eficiente desde el dispositivo y no es necesario duplicarlo, también se puede simplificar.

---

# 9. Particionado

Mantener el particionado mensual por:

```text
read_at
```

es una buena decisión.

Verificar obligatoriamente:

- que la PK/UNIQUE incluya la clave de partición cuando PostgreSQL lo requiera;
- partición del mes actual;
- partición siguiente creada con anticipación;
- partición `DEFAULT` solamente si se decide como protección;
- índices locales necesarios;
- consultas por rango de tiempo;
- estrategia de mantenimiento.

La creación mensual de nuevas particiones es un proceso recurrente.

**Liquibase no debe ejecutar cada mes una operación de negocio como si fuera una migración única.**

Liquibase puede crear la función/infraestructura necesaria. La ejecución recurrente debe realizarla:

- un cron de infraestructura;
- un scheduler del backend;
- un worker futuro;

según la arquitectura elegida.

---

# 10. Telemetría cruda

`device_telemetry_raw` puede mantenerse, pero como almacenamiento de diagnóstico.

No convertirla en la fuente funcional principal.

La información funcional debe ir normalizada a las columnas eléctricas necesarias.

Pendiente definir explícitamente:

```text
retención
frecuencia real de almacenamiento
política de purga
RLS
índices
```

No recomiendo guardar indefinidamente el JSON completo de cada lectura de 1–5 segundos.

Tampoco recomiendo un índice GIN sobre `payload` únicamente "por si se necesita".

Crear GIN solo si existen consultas JSON reales que lo justifican.

Una política corta de retención o muestreo puede ser suficiente para diagnóstico.

---

# 11. Alertas y notificaciones

Con el SRS v2.0 actual, sí tiene sentido conservar dos conceptos:

```text
notifications.alert
notifications.notification
```

### `alert`

Representa el evento detectado:

- umbral superado;
- estado anómalo;
- evento importante del dispositivo.

### `notification`

Representa lo que recibe/consulta el usuario.

Estados:

```text
UNREAD
READ
DISMISSED
```

Una notificación puede referenciar una alerta.

No debe utilizarse `DELETE` como comportamiento normal.

`DISMISSED` significa ocultarla para el usuario sin destruir el histórico.

La lógica que detecta la alerta debe estar principalmente en NestJS, no en un trigger pesado ejecutado por cada lectura.

---

# 12. Configuración y preferencias

No mezclar en una sola fila todos los ajustes globales y los del hogar.

## Preferencias globales del usuario

Ejemplos:

```text
language
theme
timezone
regional_format
```

Entidad conceptual:

```text
config.user_preference
```

## Preferencias por hogar

Ejemplos:

```text
recommendations_enabled
notification_preferences
quiet_hours
frequency
```

Entidad conceptual:

```text
config.home_preference
```

Esto evita que modificar las recomendaciones de Casa A cambie accidentalmente las de Casa B.

---

# 13. `sync` y modo offline

La cola de operaciones offline ya no pertenece al alcance actual.

Eliminar:

```text
offline_queue
```

y cualquier procedimiento asociado a:

- crear hogares offline;
- registrar dispositivos offline;
- reproducir comandos;
- resolución de conflictos offline.

El acceso desde varios clientes no requiere una "cola de sincronización" propia: PostgreSQL sigue siendo la fuente de verdad y los clientes consultan el backend.

## Backup y restore

El SRS actual sí conserva backup/restore para `SYSTEM_ADMIN`.

Pero:

- un backup real es una responsabilidad de infraestructura;
- una tabla que solo registra metadata no "restaura" la base;
- no debe simularse restauración con un stored procedure que no recupera datos.

Se puede conservar metadata de backups si aporta trazabilidad, pero el proceso real debe tener un runbook o automatización de infraestructura.

---

# 14. Auditoría

El esquema oficial debe ser uno solo:

```text
identity_audit
```

No deben quedar referencias a:

```text
audit.*
```

si `identity_audit` es el nombre definitivo.

La auditoría debe registrar **eventos semánticos sanitizados**, por ejemplo:

```text
AUTH_LOGIN_SUCCESS
AUTH_LOGIN_FAILED
AUTH_ACCOUNT_LOCKED
PASSWORD_CHANGED
HOME_CREATED
HOME_MEMBER_INVITED
HOME_MEMBER_ROLE_CHANGED
HOME_MEMBER_REVOKED
DEVICE_REGISTERED
DEVICE_UPDATED
DEVICE_DEACTIVATED
DEVICE_CONTROL_ON
DEVICE_CONTROL_OFF
TARIFF_CHANGED
SETTINGS_CHANGED
```

No copiar automáticamente filas completas de `OLD` y `NEW` para todos los cambios.

Nunca almacenar:

- contraseña;
- password hash;
- JWT;
- refresh token;
- token original de recuperación;
- credenciales MQTT;
- secretos de Alexa;
- payload sensible completo sin necesidad.

Retención acordada:

```text
mínimo 12 meses
```

La aplicación no debe tener permiso para borrar o modificar libremente eventos históricos.

---

# 15. RLS

RLS es correcta como segunda capa, pero debe usar la membresía del hogar.

Cadena conceptual:

```text
auth.user
  -> homes.home_member
      -> homes.home
          -> homes.zone
              -> devices.device
                  -> consumption / telemetry / alerts / notifications
```

Pendientes:

- `auth.fn_current_user_id()` o helper equivalente;
- lectura segura de `app.current_user_id`;
- `home_member.status = ACTIVE`;
- permisos según OWNER/MEMBER/GUEST;
- cobertura de todas las tablas multi-tenant;
- eliminar políticas `FOR DELETE` donde los históricos no se borran;
- verificar que el rol utilizado por NestJS tenga `NOBYPASSRLS`.

Con Prisma, el contexto debe establecerse dentro de la transacción con un mecanismo equivalente a:

```text
SET LOCAL app.current_user_id = ...
```

para evitar fugas de contexto entre conexiones del pool.

---

# 16. DCL y mínimo privilegio

La eliminación de grants explícitos con `DELETE` es un buen avance.

Aun así, hay que validar los **privilegios efectivos** en PostgreSQL, porque pueden heredarse por roles o `ALTER DEFAULT PRIVILEGES`.

Reglas:

- consumo: sin hard delete desde app;
- telemetría: sin hard delete desde app;
- alertas: sin hard delete normal;
- notificaciones: sin hard delete normal;
- auditoría: inmutable para la app;
- usuario/hogar/dispositivo/membresía: soft delete mediante `UPDATE`.

---

# 17. Tarifas eléctricas

La tarifa debe conservar historial de vigencia y no solaparse.

Modelo conceptual:

```text
id_tariff
id_home
price_per_kwh
currency
valid_from
valid_to
created_by
created_at
```

Recomendación:

- rango semiabierto `[valid_from, valid_to)`;
- `valid_to = NULL` significa vigencia abierta;
- usar una convención única en constraints y consultas;
- impedir periodos solapados.

Si se utiliza:

```text
EXCLUDE USING gist
```

con igualdad de UUID y rango temporal, habilitar explícitamente:

```text
btree_gist
```

antes de crear la restricción.

---

# 18. Procedures, functions y triggers

## Mantener en PostgreSQL

Funciones técnicas como:

```text
fn_current_user_id
fn_is_home_member
fn_is_home_owner
fn_can_access_device
fn_set_updated_at
```

y restricciones técnicas.

## Mover a NestJS + Prisma

Casos de uso como:

```text
registrar usuario
crear hogar
invitar miembro
transferir propiedad
registrar dispositivo
desactivar dispositivo
cambiar contraseña
controlar dispositivo
generar alertas de negocio
```

Las operaciones multi-tabla deben usar transacciones de Prisma.

No duplicar la misma lógica en NestJS y en stored procedures.

---

# 19. TCL

La estructura académica puede conservar una carpeta `04_tcl`, pero los scripts manuales o con placeholders no deben ejecutarse automáticamente por:

```text
liquibase update
```

Excluir del pipeline normal:

- recuperaciones manuales;
- ejemplos con parámetros;
- operaciones de negocio;
- transacciones que dependen de datos actuales;
- scripts de soporte humano.

Se pueden mantener como:

- runbooks;
- scripts administrativos;
- changelog separado;
- contexto Liquibase explícito no habilitado por defecto.

---

# 20. Liquibase

El documento `REVISION_ESTADO_Y_PASOS_PENDIENTES.md` contiene avances reales, pero también presenta contradicciones internas que deben corregirse.

## Contradicción 1 — includes

En una parte afirma que el problema de:

```text
0000changelog.yaml
```

ya fue corregido.

Más adelante vuelve a indicarlo como bloqueador y como paso pendiente.

Debe verificarse el repositorio real y dejar una única conclusión.

## Contradicción 2 — `device_schedule`

Una parte afirma que la PK utiliza una columna inexistente.

Otras secciones indican que:

```text
devices.device_schedule
id_device_schedule
```

ya fueron corregidos y son consistentes.

Debe eliminarse la afirmación que ya no corresponda al código actual.

## Contradicción 3 — Docker

El documento afirma en varias secciones que:

```text
docker-compose.yml
```

ya existe.

Pero después indica que no fue encontrado.

Debe corregirse el documento según el estado real del repositorio.

---

# 21. Docker y Liquibase: prueba obligatoria antes de aprobar

La base no debe darse por terminada hasta completar satisfactoriamente este ciclo sobre PostgreSQL limpio:

```bash
docker compose config
docker compose up -d postgres

liquibase validate
liquibase status
liquibase update-sql
liquibase update
liquibase history
```

Después verificar rollback controlado y reconstrucción:

```text
BD vacía
  -> update completo
  -> validación de objetos
  -> rollback controlado
  -> update nuevamente
```

También probar:

- FKs;
- UNIQUE;
- CHECK;
- RLS OWNER;
- RLS MEMBER;
- RLS GUEST;
- acceso cruzado entre hogares;
- soft delete;
- ausencia de DELETE sobre históricos;
- particiones;
- tarifa sin solapamiento;
- recuperación de contraseña;
- bloqueo 5 intentos / 15 minutos.

---

# 22. Revisión de `CAMBIOS_A_IMPLEMENTAR.md`

Ese documento de Shelly sigue siendo útil como referencia, pero algunas decisiones deben actualizarse para no reintroducir arquitectura antigua.

## Mantener

- `manufacturer_device_id`;
- normalización de voltaje;
- corriente;
- frecuencia;
- temperatura;
- telemetría;
- particionado;
- MQTT como fuente del estado de conexión.

## Ajustar

No mezclar nombres antiguos en español con el modelo nuevo en inglés.

Por ejemplo, si el baseline actual usa:

```text
power_w
energy_total_kwh
energy_delta_kwh
voltage_v
current_a
frequency_hz
temperature_c
read_at
```

no crear nuevos changesets con otra convención como:

```text
voltaje
corriente
fecha_captura
```

Elegir una convención y mantenerla.

## No recomiendo implementar

Un trigger de PostgreSQL que genere una alerta funcional por cada cambio/lectura del dispositivo.

El SRS actual asigna la evaluación de alertas a NestJS.

---

# 23. Prioridades de cambios pendientes

## P0 — Bloqueantes antes de aprobar la BD

- [ ] Determinar el estado real de los includes de Liquibase y corregir el MD de revisión.
- [ ] Determinar el estado real de Docker Compose y corregir el MD.
- [ ] Eliminar contradicción documental de `device_schedule`.
- [ ] Eliminar todas las referencias heredadas `homes.area`.
- [ ] Eliminar todas las referencias heredadas al nombre anterior de tarifa.
- [ ] Corregir alters que apuntan a columnas/tablas antiguas.
- [ ] Corregir vistas incompatibles.
- [ ] Corregir triggers sobre tablas eliminadas/renombradas.
- [ ] Alinear funciones de auditoría con las columnas reales.
- [ ] Corregir seeds/DML heredados.
- [ ] Eliminar `auth.session`, `auth.mfa`, `auth.token_blacklist` y dependencias.
- [ ] Eliminar lógica offline y sus dependencias.
- [ ] Habilitar `btree_gist` si la tarifa usa `EXCLUDE USING gist`.
- [ ] Sacar TCL operativo/manual del pipeline normal.
- [ ] Ejecutar `liquibase validate`.
- [ ] Ejecutar `liquibase update` completo en una BD vacía.

## P1 — Integridad y seguridad

- [ ] Confirmar modelo mínimo de `auth.user`.
- [ ] Índice único case-insensitive de email.
- [ ] Recovery token únicamente como hash.
- [ ] Roles globales `SYSTEM_ADMIN` / `USER`.
- [ ] Roles de hogar `OWNER` / `MEMBER` / `GUEST`.
- [ ] Ciclo `PENDING/ACTIVE/REVOKED/LEFT`.
- [ ] `home_member` como fuente de autorización.
- [ ] Integridad hogar-zona-dispositivo.
- [ ] Integridad hogar-dispositivo en consumo si se duplican ambos IDs.
- [ ] RLS completa por membresía.
- [ ] `NOBYPASSRLS` para el rol de aplicación.
- [ ] Revisar privilegios efectivos, no solo scripts GRANT.
- [ ] No hard delete de históricos.
- [ ] Auditoría sin secretos.

## P2 — Funcionalidad

- [ ] Mantener `device_schedule`.
- [ ] Mantener reglas de umbral.
- [ ] Definir si `device_status_history` realmente aporta valor.
- [ ] Mantener alert y notification con responsabilidades distintas.
- [ ] Separar preferencias globales y del hogar.
- [ ] Definir retención real de telemetría raw.
- [ ] Definir tratamiento de resets de `energy_total_kwh`.
- [ ] Validar particiones mensual actual/siguiente.
- [ ] Definir scheduler de creación de particiones.
- [ ] Implementar backup/restore como operación real de infraestructura.
- [ ] Decidir formalmente la entrega de asistente de voz, porque el SRS aún lo conserva con prioridad Media.

## P3 — Puede esperar

- [ ] Redis.
- [ ] BullMQ.
- [ ] Procesamiento distribuido.
- [ ] Escalamiento horizontal avanzado.
- [ ] Índices adicionales no respaldados por consultas reales.
- [ ] GIN sobre JSONB si todavía no existen consultas que lo necesiten.

---

# 24. Criterio de aprobación final

Consideraría la base de datos lista cuando se cumplan simultáneamente estas condiciones:

```text
[ ] Modelo alineado con SRS v2.0
[ ] Sin objetos heredados fuera de alcance
[ ] Sin nombres antiguos de tablas/columnas
[ ] Liquibase validate = OK
[ ] Liquibase update en BD limpia = OK
[ ] Rollback de prueba = OK
[ ] Segundo update = OK
[ ] FKs verificadas
[ ] RLS verificada con usuarios de hogares distintos
[ ] DCL de mínimo privilegio verificado
[ ] Históricos protegidos contra hard delete
[ ] Particionado funcionando
[ ] Alertas/notificaciones alineadas
[ ] Auth simplificada sin JWT/sesiones persistentes en PostgreSQL
[ ] Recovery token hasheado
[ ] Auditoría sanitizada
[ ] Docker reproducible
[ ] README permite levantar la BD desde cero
```

---

# 25. Recomendación final

No recomiendo volver a inflar la tabla `auth.user` con campos que el producto ya decidió no utilizar.

La simplificación que se hizo va en la dirección correcta.

El trabajo pendiente debe concentrarse ahora en **eliminar dependencias antiguas y hacer que todo el repositorio represente un solo modelo coherente**, en lugar de seguir agregando más tablas o más funcionalidades.

La prioridad inmediata es:

```text
1. cerrar el modelo final;
2. limpiar referencias heredadas;
3. validar Liquibase;
4. levantar PostgreSQL desde cero;
5. probar RLS e integridad;
6. corregir lo que falle;
7. recién entonces congelar el baseline.
```

---

## Nota de alcance de esta revisión

Esta revisión contrasta:

- el SRS v2.0 vigente;
- la documentación de alcance actualizada;
- la auditoría técnica anterior;
- el documento actual de revisión y pasos pendientes;
- la documentación de telemetría Shelly;
- las decisiones técnicas acordadas para NestJS, Prisma, PostgreSQL, MQTT, WebSocket, Liquibase y Docker.

Para certificar que **cada SQL actual** ya está correcto hace falta revisar/ejecutar el repositorio SQL vigente completo. El documento de revisión demuestra avances, pero la aprobación final debe basarse en la ejecución real de las migraciones y no únicamente en una inspección documental.
