# Guía de verificación - Épica 6: Auditoría y trazabilidad (Audit Service)

## Resumen de implementación

| HU | Título | Backend | Frontend | Estado |
|----|--------|---------|----------|--------|
| HU-20 | Registro de acciones relevantes | ⚠️ Parcial | N/A | Solo monitoring; otros servicios no envían |
| HU-21 | Consulta de registros por administradores | ✅ | ✅ | Sin auth admin (403) |
| HU-22 | Generación de reportes de auditoría | ✅ | ✅ | Sin auth admin; export CSV/JSON/PDF OK |

---

## Requisitos previos

- **audit_service** corriendo (puerto 8005 por defecto)
- Base de datos PostgreSQL con tabla `audit_logs`
- `.env` con `AUDIT_SERVICE_URL` o `GATEWAY_URL`

---

## HU-20: Registro de acciones relevantes del sistema

### Endpoints

| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | /audit/logs | Crear registro de auditoría (uso por otros servicios) |

### Criterios de aceptación vs implementación

| # | Escenario | Estado | Notas |
|---|-----------|--------|-------|
| CA1 | Registro de eventos (registro, login, oferta, demanda, transacción, liquidación) | ⚠️ Parcial | Solo **monitoring_service** registra eventos (telemetría, alertas, dispositivos). Auth, user, transaction, energy_credits **no envían** a audit_service |
| CA2 | Estructura mínima (usuario, acción, fecha, hora, datos adicionales) | ✅ | Campos: actor_user_id, action, created_at, resource_type, resource_id, details |
| CA3 | Identificadores de dominio (oferta, demanda, transacción) | ✅ | resource_id almacena ID de oferta/demanda/transacción |
| CA4 | Registro inmutable | ✅ | No existe API UPDATE ni DELETE; solo create y query |
| CA5 | Formato estructurado | ✅ | JSON en DB; lectura y procesamiento automático posible |

### Estructura del registro (POST /audit/logs)

```json
{
  "action": "login",
  "actor_user_id": 1,
  "actor_device_id": null,
  "resource_type": "auth",
  "resource_id": null,
  "details": { "ip": "192.168.1.1" },
  "ip": "192.168.1.1"
}
```

### Gap crítico
Los servicios **auth_service**, **user_service**, **transaction_service** y **energy_credits_service** **no llaman** a audit_service. Solo el monitoring_service tiene `create_audit`, y escribe en su **propia base de datos** (no en audit_service).

Para cumplir HU-20 CA1 al 100%, los demás servicios deben enviar eventos a audit_service vía `POST /audit/logs` o integrar una llamada HTTP al audit_service.

---

## HU-21: Consulta de registros por parte de administradores

### Endpoint

```
GET /audit/logs?user_id=&transaction_id=&start_date=&end_date=&action=&page=1&limit=50
```

### Criterios de aceptación vs implementación

| # | Escenario | Estado | Notas |
|---|-----------|--------|-------|
| CA1 | Administrador consulta con filtros (user_id, transaction_id, rango fechas) | ✅ | Query params soportados |
| CA2 | Visualización ordenada cronológicamente | ✅ | Orden por `created_at` descendente |
| CA3 | Respuesta en menos de 5 segundos (hasta 10.000 registros) | ⚠️ | Límite `limit=10000`; sin garantía explícita de SLA |
| CA4 | Paginación | ✅ | page, limit; botones Anterior/Siguiente en frontend |
| CA5 | Usuario no administrador → 403 | ❌ | **No hay validación de rol admin**. Cualquier usuario autenticado (o incluso sin auth) podría consultar si no hay middleware |

### Respuesta típica

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "actor_user_id": 1,
      "actor_device_id": null,
      "action": "telemetry.ingest",
      "resource_type": "measurement",
      "resource_id": "42",
      "details": {},
      "created_at": "2025-02-06T12:00:00"
    }
  ],
  "total": 1,
  "page": 1,
  "limit": 50
}
```

### Pruebas con cURL

```bash
# Consulta sin filtros
curl "http://localhost:8005/audit/logs?page=1&limit=50"

# Filtros por usuario y fechas
curl "http://localhost:8005/audit/logs?user_id=1&start_date=2025-02-01T00:00:00&end_date=2025-02-07T23:59:59&page=1&limit=50"

# Por transaction_id (resource_id)
curl "http://localhost:8005/audit/logs?transaction_id=abc-123&page=1&limit=50"
```

---

## HU-22: Generación de reportes de auditoría

### Endpoint

```
GET /audit/reports?start_date=&end_date=&event_types=login,registro&user_ids=1,2&format=json|csv|pdf
```

### Criterios de aceptación vs implementación

| # | Escenario | Estado | Notas |
|---|-----------|--------|-------|
| CA1 | Solo administradores pueden generar reportes | ❌ | No hay validación de rol admin |
| CA2 | Parámetros: fechas, tipos de evento, usuarios | ✅ | start_date, end_date, event_types, user_ids |
| CA3 | Reporte con agregaciones | ✅ | total_events, by_action, by_user |
| CA4 | Reporte con detalle de eventos | ✅ | Campo `detail` con listado de eventos |
| CA5 | Exportación CSV, JSON, PDF | ✅ | format=json|csv|pdf |
| CA6 | Auditoría de generación de reporte | ✅ | Se llama `create_log` con action `audit_report.generated` |

### Respuesta (JSON)

```json
{
  "success": true,
  "report": {
    "summary": {
      "total_events": 10,
      "by_action": { "telemetry.ingest": 5, "alert_rule.create": 2 },
      "by_user": { "1": 7, "0": 3 }
    },
    "period": { "start": "2025-02-01", "end": "2025-02-07" },
    "detail": [
      { "id": 1, "actor_user_id": 1, "action": "telemetry.ingest", "resource_type": "measurement", "resource_id": "42", "created_at": "2025-02-06T12:00:00" }
    ]
  }
}
```

### Pruebas con cURL

```bash
# JSON
curl "http://localhost:8005/audit/reports?start_date=2025-02-01T00:00:00&end_date=2025-02-07T23:59:59&format=json"

# CSV (descarga)
curl -o report.csv "http://localhost:8005/audit/reports?start_date=2025-02-01T00:00:00&end_date=2025-02-07T23:59:59&format=csv"

# PDF
curl -o report.pdf "http://localhost:8005/audit/reports?start_date=2025-02-01T00:00:00&end_date=2025-02-07T23:59:59&format=pdf"
```

---

## Pruebas en la app Flutter

### HU-21 (AuditLogsScreen)
1. Navegar a la pantalla de registros de auditoría (menú admin).
2. Aplicar filtros: ID usuario, ID transacción, rango de fechas.
3. Verificar que se muestran los registros paginados.
4. Usar botones Anterior/Siguiente para navegar entre páginas.

**Nota:** El frontend busca `user_id` o `userId` para mostrar en la lista; el backend devuelve `actor_user_id`. Si no aparece el usuario, ajustar el mapeo en el frontend.

### HU-22 (AuditReportsScreen)
1. Seleccionar rango de fechas.
2. Opcional: tipos de evento (registro, login, oferta, etc.).
3. Opcional: IDs de usuarios (separados por coma).
4. Elegir formato: JSON, CSV o PDF.
5. Pulsar "Generar reporte".

---

## Poblar audit_service para pruebas

Como auth/transaction/credits no envían eventos al audit_service, para probar consultas y reportes se puede:

1. **POST directo a /audit/logs:**
   ```bash
   curl -X POST "http://localhost:8005/audit/logs" \
     -H "Content-Type: application/json" \
     -d '{"action":"login","actor_user_id":1,"resource_type":"auth","details":{"ip":"127.0.0.1"}}'
   ```

2. **Usar monitoring_service:** Al provisionar dispositivos, ingestar telemetría o crear reglas de alerta, el monitoring_service escribe en su propia BD. Para que aparezcan en audit_service habría que unificar fuentes o que monitoring_service también POSTee a audit_service.

---

## Checklist de pruebas

```
□ HU-20: Crear registro vía POST /audit/logs
□ HU-20: Verificar que no existe UPDATE ni DELETE
□ HU-21: Consultar logs con filtros (user_id, transaction_id, fechas)
□ HU-21: Verificar paginación (Anterior/Siguiente)
□ HU-21: Verificar orden cronológico (más recientes primero)
□ HU-22: Generar reporte JSON
□ HU-22: Generar reporte CSV y verificar descarga
□ HU-22: Generar reporte PDF y verificar descarga
□ HU-22: Verificar que se registra evento audit_report.generated
```

---

## Gaps para cumplimiento completo

| HU | Gap | Acción sugerida |
|----|-----|-----------------|
| HU-20 | Auth, user, transaction, credits no envían eventos | Integrar llamadas HTTP a POST /audit/logs en cada servicio |
| HU-20 | monitoring_service escribe en su propia BD | Decidir: unificar en audit_service o replicar vía POST |
| HU-21 CA5 | Sin validación de rol admin | Añadir middleware/dependency que verifique JWT y rol admin; devolver 403 si no es admin |
| HU-22 CA1 | Sin validación de rol admin | Misma solución que HU-21 |

---

## Endpoints del Audit Service

| Método | Ruta | HU | Auth |
|--------|------|-----|------|
| POST | /audit/logs | HU-20 | No (llamada interna desde otros servicios) |
| GET | /audit/logs | HU-21 | No (debería requerir admin) |
| GET | /audit/reports | HU-22 | No (debería requerir admin) |
