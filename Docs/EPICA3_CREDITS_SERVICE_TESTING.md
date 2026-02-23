# Guía de pruebas - Épica 3: Gestión de créditos y energía (Credits Service)

## Resumen de implementación

| HU | Título | energy_credits_service | transaction_service | Frontend | Estado |
|----|--------|------------------------|---------------------|----------|--------|
| HU-10 | Consulta de saldo energético | ✅ | - | ✅ | Implementado |
| HU-11 | Historial de créditos de energía | Parcial | Parcial | Parcial | Ver detalles abajo |

---

## Requisitos previos

1. **energy_credits_service** corriendo (puerto 8002 por defecto)
2. **transaction_service** corriendo (para HU-11 historial)
3. **Token JWT** válido (login previo)
4. `.env` con `CREDITS_SERVICE_URL` y `TRADING_SERVICE_URL`

---

## HU-10: Consulta de saldo energético

### Endpoint
- `GET /credits/{user_id}` — Requiere `Authorization: Bearer <token>`
  - Usuario puede consultar solo su propio saldo
  - Admin (role=0) puede consultar cualquier saldo

### Criterios de aceptación y verificación

| # | Escenario | Pasos | Resultado esperado |
|---|-----------|-------|--------------------|
| **CA1** | Usuario consulta su saldo | 1. Login como usuario<br>2. Ir a Energía o sección de saldo<br>3. Ver pantalla | Muestra saldo actual en kWh |
| **CA2** | Saldo consistente con transacciones | 1. Ejecutar deposit o debit vía API<br>2. Consultar saldo | El saldo refleja el neto de depósitos y débitos |
| **CA3** | Usuario sin créditos | 1. Usuario nuevo sin registros en energy_credits<br>2. Consultar saldo | Se muestra "0 kWh" (o 0.0) |

### Pruebas con cURL

```bash
# Obtener token tras login
TOKEN="tu_token_jwt"

# Consultar saldo propio (user_id = 1)
curl -X GET "http://localhost:8002/credits/1" \
  -H "Authorization: Bearer $TOKEN"

# Respuesta esperada: {"success":true,"data":{"user_id":1,"balance":0.0},"message":"Saldo obtenido"}
# O si no hay registro: {"success":true,"data":{"user_id":1,"balance":0.0},"message":"Saldo no encontrado - se retorna 0 kWh"}
```

### Pruebas en la app
- **EnergyScreen**: Muestra el saldo en kWh del usuario logueado
- La app llama `CreditsRepository.getBalance(myUser.idUser)` con el token en headers

### Seguridad (recientemente corregido)
- Antes: GET sin autenticación (cualquiera podía consultar cualquier saldo)
- Ahora: Requiere token; solo propietario o admin pueden consultar

---

## HU-11: Historial de créditos de energía

### Arquitectura actual
- **HistorialScreen** usa `TransactionRepository.getEnergyRecords` → `POST /transactions/energy/query`
- Los datos vienen del **transaction_service** (energy_records: generación/consumo por período)
- NO existe un historial de "movimientos de créditos" en el **energy_credits_service** (depósito/débito/transferencia)

### Criterios de aceptación vs implementación

| # | Escenario | Estado | Notas |
|---|-----------|--------|-------|
| **CA1** | Lista de movimientos con fecha, tipo, kWh, saldo resultante, referencia | Parcial | transaction_service devuelve energy_generated, energy_consumed, period; no "tipo" generado/transferido/utilizado ni saldo_resultante |
| **CA2** | Filtro por rango de fechas | ✅ | HistorialScreen permite elegir fechas y recarga |
| **CA3** | Filtro por tipo (generado, transferido, utilizado) | Parcial | Filtro en frontend; los datos del backend no tienen campo "tipo" estándar |
| **CA4** | Exportar CSV | ✅ | HistorialScreen copia CSV al portapapeles |
| **CA5** | Exportar JSON | ✅ | HistorialScreen copia JSON al portapapeles |
| **CA6** | Usuario no propietario sin permisos | ❌ | POST /transactions/energy/query no tiene auth; cualquiera puede consultar cualquier user_id |
| **CA7** | Admin accede al historial de otro usuario | ❌ | Sin auth, no hay distinción admin/propietario |

### Gap principal
El HU-11 define "historial de **créditos** de energía" con tipos: generado, transferido, utilizado. Eso implica movimientos de la cuenta de créditos (depósito, transferencia P2P, consumo). El **energy_credits_service** no registra un log de movimientos; solo mantiene el saldo. El **transaction_service** devuelve registros de energía por período (generación/consumo), que es un concepto diferente.

Para cumplir HU-11 al 100% sería necesario:
1. **energy_credits_service** (o similar): tabla `credit_movements` con user_id, type (generado/transferido/utilizado), kwh, balance_after, reference, created_at
2. Registrar cada deposit/debit/transfer en esa tabla
3. Endpoint `GET /credits/{user_id}/history` con filtros fecha y tipo, auth (propietario o admin)
4. Endpoints de export CSV/JSON (o query params format=csv|json)

### Pruebas actuales (con lo implementado)

| Acción | Dónde | Cómo probar |
|--------|-------|-------------|
| Ver historial | HistorialScreen (menú historial) | Login → Historial → Ver lista |
| Filtrar por fechas | Icono calendario en AppBar | Elegir rango y recargar |
| Filtrar por tipo | Chips Generado/Transferido/Utilizado | El filtro funciona si los registros tienen type/source mapeable |
| Exportar CSV/JSON | Icono descarga → Copiar | Verifica que se copie al portapapeles |

### cURL para energy/query (transaction_service)

```bash
curl -X POST "http://localhost:8003/transactions/energy/query" \
  -H "Content-Type: application/json" \
  -d '{"user_id":1,"start":"2025-01-01T00:00:00","end":"2025-02-06T23:59:59"}'
```

---

## Checklist de pruebas rápidas

```
□ HU-10 CA1: Login → Energía → Ver saldo en kWh
□ HU-10 CA2: Deposit/Debit por API → Consultar saldo → Coincide
□ HU-10 CA3: Usuario sin registros → Saldo 0 kWh
□ HU-10: Consultar saldo de otro usuario (no admin) → 403
□ HU-11: HistorialScreen carga registros (si hay en transaction_service)
□ HU-11: Filtro por fechas
□ HU-11: Filtro por tipo
□ HU-11: Exportar CSV / JSON
```

---

## Endpoints relevantes

| Servicio | Método | Ruta | HU | Auth |
|----------|--------|------|-----|------|
| energy_credits | GET | /credits/{user_id} | HU-10 | ✅ Bearer (propietario o admin) |
| energy_credits | POST | /credits/deposit | - | ✅ |
| energy_credits | POST | /credits/debit | - | ✅ |
| energy_credits | POST | /credits/check | - | No |
| transaction | POST | /transactions/energy/query | HU-11 (parcial) | ❌ Falta |
