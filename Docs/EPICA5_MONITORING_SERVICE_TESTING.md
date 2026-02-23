# Guía de verificación - Épica 5: Monitoreo energético (Monitoring Service)

**Nota:** Épica 5 es el **Monitoring Service**, no el Credits Service.

## Resumen de implementación

| HU | Título | Backend | Frontend | Estado |
|----|--------|---------|----------|--------|
| HU-18 | Visualización de consumo en tiempo real | ✅ | ✅ | Parcial (auth por dispositivo) |
| HU-19 | Alertas por consumo elevado | ✅ | ✅ | Parcial (sin auth JWT en reglas) |

---

## Requisitos previos

- **monitoring_service** corriendo (puerto 8004 por defecto)
- **Dispositivo provisionado** (POST /devices) para obtener device_id y device_token
- **Redis** (opcional) para pub/sub de actualizaciones en tiempo real
- **Celery** (opcional) para evaluación asíncrona de alertas; si no está, se usa evaluación síncrona
- `.env` con `MONITORING_SERVICE_URL`

---

## HU-18: Visualización de consumo en tiempo real

### Arquitectura
- Las mediciones provienen de **dispositivos medidores** (device_id + device_token).
- El usuario debe tener un dispositivo provisionado para ver su consumo.
- Endpoints de telemetría usan autenticación **por dispositivo** (X-Device-ID + Authorization: Device \<token\>).

### Endpoints

| Método | Ruta | Descripción | Auth |
|--------|------|-------------|------|
| POST | /telemetry | Ingestar medición del medidor | Device token |
| GET | /telemetry/latest | Última medición del dispositivo | Device token |
| GET | /telemetry/history | Histórico de mediciones | Device token |
| POST | /devices | Provisionar dispositivo | No |

### Criterios de aceptación vs implementación

| # | Escenario | Estado | Notas |
|---|-----------|--------|-------|
| CA1 | Visualizar última medición | ✅ | GET /telemetry/latest con device auth |
| CA2 | Histórico reciente | ✅ | GET /telemetry/history?limit=100 |
| CA3 | Actualización automática | Parcial | Redis pub/sub existe; el frontend no usa WebSocket ni polling automático |
| CA4 | Validación de firma/origen | ✅ | authenticate_device_header valida token del dispositivo |
| CA5 | Rechazo de medición con origen no confiable | ✅ | 401 si token inválido |

### Flujo para el usuario
1. **Provisionar dispositivo:** `POST /devices` con `{ "device_id": "medidor-001", "owner_user_id": 1 }` → devuelve `device_token`.
2. **Medidor envía datos:** `POST /telemetry` con headers `X-Device-ID`, `Authorization: Device <token>` y body `{ "energy_kwh": 10.5, "timestamp": "..." }`.
3. **Usuario consulta:** En ConsumptionScreen, ingresar device_id y device_token; pulsar "Última" o "Historial".

### Pruebas con cURL

```bash
# 1. Provisionar dispositivo
curl -X POST "http://localhost:8004/devices" \
  -H "Content-Type: application/json" \
  -d '{"device_id":"medidor-001","owner_user_id":1}'
# Respuesta: { "device_id", "owner_user_id", "community_id", "device_token" }
# Guardar device_token para siguientes pasos.

# 2. Ingestar medición (simular medidor)
curl -X POST "http://localhost:8004/telemetry" \
  -H "Content-Type: application/json" \
  -H "X-Device-ID: medidor-001" \
  -H "Authorization: Device TU_DEVICE_TOKEN" \
  -d '{"energy_kwh":5.2,"power_kw":1.5,"timestamp":"2025-02-06T12:00:00Z"}'

# 3. Última medición
curl -X GET "http://localhost:8004/telemetry/latest" \
  -H "X-Device-ID: medidor-001" \
  -H "Authorization: Device TU_DEVICE_TOKEN"

# 4. Historial
curl -X GET "http://localhost:8004/telemetry/history?limit=20" \
  -H "X-Device-ID: medidor-001" \
  -H "Authorization: Device TU_DEVICE_TOKEN"
```

### Gaps
- **CA3 (actualización automática):** El frontend no implementa WebSocket ni polling periódico. El usuario debe pulsar "Última" o "Historial" manualmente.
- **Vista por usuario (JWT):** No existe endpoint que acepte JWT de usuario y devuelva mediciones de sus dispositivos. El usuario debe conocer device_id y device_token.

---

## HU-19: Alertas por consumo elevado

### Endpoints

| Método | Ruta | Descripción | Auth |
|--------|------|-------------|------|
| POST | /alerts/rules | Crear regla de umbral | ❌ No |
| GET | /alerts/rules | Listar reglas | ❌ No |
| GET | /alerts | Listar alertas (histórico) | ❌ No |

### Criterios de aceptación vs implementación

| # | Escenario | Estado | Notas |
|---|-----------|--------|-------|
| CA1 | Usuario define/actualiza umbral | Parcial | POST /alerts/rules existe; no requiere JWT; cualquiera puede crear reglas para cualquier owner_user_id |
| CA2 | Admin actualiza umbral de otro usuario | ❌ | No hay endpoint PUT/PATCH para actualizar regla; no hay auth que permita solo admin |
| CA3 | Evaluación de métricas contra umbral | ✅ | Al ingestar medición, evaluate_alert_for_measurement compara valor vs threshold |
| CA4 | Emisión de alerta por consumo elevado | ✅ | Si métrica supera umbral, se crea registro en tabla alerts |

### Body para crear regla (HU-19)
```json
{
  "owner_user_id": 1,
  "device_id": "medidor-001",
  "metric": "power_kw",
  "operator": ">",
  "threshold": 2.0,
  "window_seconds": 0,
  "severity": "medium"
}
```
- `metric`: `power_kw` o `energy_kwh`
- `operator`: `>`, `<`, `>=`, `<=`
- `threshold`: número positivo

### Pruebas con cURL

```bash
# Crear regla de alerta
curl -X POST "http://localhost:8004/alerts/rules" \
  -H "Content-Type: application/json" \
  -d '{"owner_user_id":1,"device_id":"medidor-001","metric":"power_kw","operator":">","threshold":2.0}'

# Listar reglas del usuario
curl "http://localhost:8004/alerts/rules?owner_user_id=1"

# Listar alertas (histórico)
curl "http://localhost:8004/alerts?owner_user_id=1&start_date=2025-02-01T00:00:00&end_date=2025-02-07T23:59:59"
```

### Probar CA3 y CA4
1. Crear regla: `power_kw > 1.0`
2. Ingestar medición con `power_kw: 1.5` (supera umbral)
3. El sistema evalúa y crea alerta automáticamente
4. Listar alertas: debe aparecer la nueva alerta

### Gaps
- **CA1, CA2:** Sin autenticación JWT. Cualquiera puede crear/modificar reglas. Falta:
  - Validar que `owner_user_id` coincida con el usuario autenticado (o sea admin).
  - Endpoint para actualizar umbral (PUT /alerts/rules/{id}).

---

## Pruebas en la app

### HU-18 (ConsumptionScreen)
1. Provisionar dispositivo vía API o pantalla de administración (si existe).
2. Ingresar device_id y device_token en ConsumptionScreen.
3. Pulsar "Última" → debe mostrar potencia y energía.
4. Pulsar "Historial" → debe mostrar lista de mediciones.

### HU-19 (AlertsScreen)
1. Con usuario logueado (userId), ir a pestaña "Nueva regla".
2. Ingresar device_id, métrica (power_kw o energy_kwh), operador, umbral.
3. Crear regla → debe guardarse.
4. Pestaña "Reglas" → ver reglas creadas.
5. Pestaña "Historial" → elegir rango de fechas, ver alertas emitidas.
6. Para generar alerta: ingestar medición que supere el umbral vía POST /telemetry.

---

## Checklist de pruebas

```
□ HU-18 CA1: Provisionar dispositivo → Ingestar medición → Ver última medición
□ HU-18 CA2: Ver historial de mediciones
□ HU-18 CA4/CA5: Enviar medición con token inválido → 401
□ HU-19 CA1: Crear regla de umbral (owner_user_id, device_id, metric, operator, threshold)
□ HU-19 CA3/CA4: Ingestar medición que supere umbral → Verificar que se crea alerta
□ HU-19: Listar alertas por rango de fechas
```

---

## Endpoints del Monitoring Service

| Método | Ruta | HU | Auth |
|--------|------|-----|------|
| POST | /devices | - | ❌ |
| POST | /telemetry | HU-18 | Device token |
| GET | /telemetry/latest | HU-18 | Device token |
| GET | /telemetry/history | HU-18 | Device token |
| POST | /alerts/rules | HU-19 | ❌ |
| GET | /alerts/rules | HU-19 | ❌ |
| GET | /alerts | HU-19 | ❌ |

---

## Gaps para cumplir HUs al 100%

```
□ HU-18 CA3: Frontend con polling o WebSocket para actualización automática
□ HU-18: Endpoint alternativo para usuario con JWT que liste dispositivos del usuario y sus últimas mediciones
□ HU-19 CA1/CA2: Auth JWT en POST/GET /alerts/rules; validar owner_user_id = current user o admin
□ HU-19 CA2: Endpoint PUT /alerts/rules/{id} para que admin actualice umbral de otro usuario
```
