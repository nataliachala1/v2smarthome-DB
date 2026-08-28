1. `devices.schedule` → sí debe existir
Aquí ya no hay ambigüedad.
El SRS actualizado establece en RF3.2:
El OWNER puede configurar parámetros compatibles como umbrales, horarios y preferencias operativas.
Y el caso de uso CU09 también establece que el OWNER puede modificar parámetros de configuración del dispositivo.
Por tanto, necesitamos persistir horarios.
Yo simplemente cambiaría el nombre por 
 devices.device_schedule

2. `devices.threshold_rule` → conservar la funcionalidad, pero moverla
También está claramente respaldada.
RF3.2 contempla umbrales y RF4.7 establece que el sistema debe generar alertas cuando se superen umbrales definidos, existan estados anómalos o eventos relevantes. El propio RF4.7 indica como entrada:

```

```


```
Telemetría
Umbrales
Estados
```

y NestJS debe evaluar esas reglas. al igual yo la moveria a notifications.alert_rule

3. `devices.device_status_history` → yo la eliminaría
Aquí sí considero correcta tu sospecha de redundancia.
El SRS actualizado establece que la telemetría normalizada puede contener: 4. `notifications.alert` y `notifications.notification` → aquí NO las unificaría
Aquí hay un detalle muy importante del SRS v2.
RF4.7 dice explícitamente:

```

```


```
Salidas:
Alerta persistente y evento para notificación.
```

y después:

```

```


```
NestJS evalúa reglas
→ registra la alerta
→ notifica al cliente
```


Eso indica que conceptualmente son dos cosas diferentes.


Confirmado: fuera de alcance

devices.voice_assistant_token (integración con Alexa/asistentes de voz) — el documento nuevo tiene una sección "IoT incluido" (§3) que enumera explícitamente todo lo que sí entra: registro, asociación a hogar/zona, MQTT, estado de conexión, telemetría, control remoto, alertas. No aparece ninguna mención a asistentes de voz en ningún punto del documento, ni siquiera en la sección §34 que lista los recortes frente al SRS anterior (MFA, refresh tokens, offline, agua/gas). Dado que es un documento bastante exhaustivo y no la menciona ni para incluirla ni para excluirla explícitamente, mi lectura es que quedó fuera simplemente por no ser parte del alcance actual. Si es así, no creamos esta tabla ni su RLS.

Ambiguo — necesito que confirmes

devices.schedule y devices.threshold_rule (horarios automáticos y umbrales de consumo con alertas, RF3.2 del SRS anterior): el documento no los menciona en ningún lugar, ni en §3 (IoT incluido) ni en §5.2 (donde OWNER solo dice "Registrar y configurar dispositivos" de forma genérica, sin detalle de horarios/umbrales).

devices.device_status_history: la nueva sección §13 (Telemetría) ya incluye un campo estado dentro de cada lectura de telemetría, lo que podría hacer redundante una tabla de historial de estados separada — pero no es un reemplazo explícito, es mi inferencia.

notifications.alert y notifications.reminder_notification: la sección §28 habla de "Alertas y notificaciones" como un solo concepto histórico con estados UNREAD/READ/DISMISSED, lo que sugiere una tabla unificada notifications.notification (con un campo tipo para distinguir alerta de umbral vs. informativa) en vez de dos tablas separadas. reminder_notification (recordatorios programados) no se menciona en absoluto.