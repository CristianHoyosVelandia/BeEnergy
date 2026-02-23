# Guía de verificación - Épica 4: Gestión de transacciones P2P (Transaction Service)

## Resumen de implementación

| HU | Título | Backend | Frontend | Estado |
|----|--------|---------|----------|--------|
| HU-12 | Publicación de oferta | Parcial | ✅ | Falta auth, rol, saldo en backend |
| HU-13 | Visualización de ofertas | ❌ | ✅ | **No existe GET /contracts** |
| HU-14 | Cancelación de ofertas | Parcial | ✅ | Falta auth, validación estado |
| HU-15 | Emparejamiento automático | ❌ | N/A | No implementado |
| HU-16 | Liquidación y actualización | Parcial | N/A | No integra energy_credits |
| HU-17 | Prevención de duplicidad | Parcial | N/A | Sin locking ni validaciones |

---

## Requisitos previos

- **transaction_service** corriendo (puerto 8003)
- **energy_credits_service** (para saldo)
- Token JWT válido
- `.env` con `TRADING_SERVICE_URL`

---

## HU-12: Publicación de oferta de energía

### Endpoints actuales
- `POST /transactions/contracts` — Crear contrato P2P (oferta)
  - Body: `{ "seller_id", "buyer_id?", "community_id?", "agreed_price", "energy_committed" }`

### Criterios de aceptación vs implementación

| # | Escenario | Estado | Notas |
|---|-----------|--------|-------|
| CA1 | Prosumidor publica oferta válida con saldo suficiente | Parcial | Frontend verifica saldo; backend NO. Estado inicial "pending" (no "activa") |
| CA2 | Saldo insuficiente | Parcial | Frontend verifica; backend NO |
| CA3 | Datos incompletos | Parcial | Pydantic valida campos; backend rechaza si faltan |
| CA4 | Valores inválidos (≤0) | ✅ | `Field(gt=0.0)` en P2PContractCreate |
| CA5 | Persistencia de oferta | ✅ | Se guarda en p2p_contracts |
| CA6 | Usuario no prosumidor → 403 | ❌ | **Sin auth** en POST /contracts |

### Gaps principales
1. **Sin autenticación**: Cualquiera puede crear contratos.
2. **Sin verificación de rol prosumidor**: No se valida role=2.
3. **Sin verificación de saldo en backend**: Solo el frontend comprueba; el backend debería validar contra energy_credits_service.
4. **Estado inicial**: P2PContract usa "pending"; HUs usan "activa" (mapeable).

### Pruebas con cURL
```bash
curl -X POST "http://localhost:8003/transactions/contracts" \
  -H "Content-Type: application/json" \
  -d '{"seller_id":1,"agreed_price":150,"energy_committed":50}'
```

---

## HU-13: Visualización de ofertas disponibles

### Estado: **No implementado en backend**

El frontend llama `GET /transactions/contracts?status=active&seller_id=X`, pero **el transaction_service NO expone GET /contracts**. Solo existe POST /contracts. La pantalla OfertasP2PScreen fallará al listar.

### Criterios vs implementación

| # | Escenario | Estado | Notas |
|---|-----------|--------|-------|
| CA1 | Ofertas activas | ❌ | Falta endpoint GET /contracts |
| CA2 | Filtro por precio | Parcial | Frontend filtra en cliente; backend debe soportar query params |
| CA3 | Filtro por cantidad mínima | Parcial | Idem |
| CA4 | Filtro por oferente | Parcial | Frontend usa seller_id; necesita backend |
| CA5 | Filtro por fecha | Parcial | Necesita backend |

### Requerido
- Añadir `GET /transactions/contracts` con query params: `status`, `seller_id`, `buyer_id`, `min_price`, `max_price`, `min_kwh`, `start_date`, `end_date`
- Implementar `list_contracts` en ContractRepo y TransactionService

---

## HU-14: Cancelación de ofertas activas

### Endpoint actual
- `POST /transactions/contracts/{id}/action` — Body: `{ "action": "cancel", "buyer_id"?: null }`

### Criterios vs implementación

| # | Escenario | Estado | Notas |
|---|-----------|--------|-------|
| CA1 | Prosumidor cancela oferta activa | Parcial | act_on_contract con "cancel" existe; no valida estado previo |
| CA2 | Cancelar oferta no activa (emparejada/liquidada) | ❌ | No valida; permite cancelar cualquier estado |
| CA3 | Usuario intenta cancelar oferta ajena → 403 | ❌ | **Sin auth**; no verifica propietario |
| CA4 | Oferta cancelada persistida | ✅ | Status "cancelled" |
| CA5 | Liberación de kWh | ❌ | No hay bloqueo de kWh al publicar; no hay liberación |

### Gaps
- Sin autenticación
- Sin verificación de que el usuario sea el seller
- Sin validación de que el contrato esté en estado cancelable (pending/active)
- No hay concepto de "kWh bloqueados" en la oferta

---

## HU-15: Emparejamiento automático de ofertas y demandas

### Estado: **No implementado**

No existe entidad "demanda", ni motor de emparejamiento ni proceso automático.

### Requerido (referencia)
- Entidad Demand (buyer_id, max_price, quantity_kwh, status, created_at)
- Proceso/job que:
  1. Busque ofertas y demandas activas
  2. Empareje por precio (oferta ≤ max_price demanda) y cantidad (oferta ≥ demanda)
  3. Cree transacción con estado "pendiente"
  4. Marque oferta/demanda como "emparejada"
- Endpoint o comando para ejecutar el matching

---

## HU-16: Liquidación y actualización de transacciones

### Endpoints actuales
- `POST /transactions/record-transaction` — Registrar transacción manual
- `POST /transactions/liquidate` — Liquidar periodo (genera billing)

### Criterios vs implementación

| # | Escenario | Estado | Notas |
|---|-----------|--------|-------|
| CA1 | Descuento prosumidor, acreditación consumidor | ❌ | liquidate_period crea billing; **no actualiza energy_credits** |
| CA2 | Precio total registrado | Parcial | create_transaction calcula total_value |
| CA3 | Saldos actualizados inmediatamente | ❌ | No hay llamada a credits debit/deposit |
| CA4 | Transacción → "liquidada" | ❌ | No hay campo status en Transaction; liquidate crea Billing |
| CA5 | Error durante liquidación → rollback | ❌ | No hay transacción atómica con credits |
| CA6 | Registro en historial de créditos | ❌ | energy_credits_service no tiene historial de movimientos |

### Gap principal
**No hay integración con energy_credits_service**. La liquidación debería:
1. Debitar kWh del seller (credits/debit)
2. Acreditar kWh al buyer (credits/deposit)
3. Marcar transacción como liquidada
4. Registrar movimientos en historial de créditos (si existe)

---

## HU-17: Prevención de duplicidad

### Criterios vs implementación

| # | Escenario | Estado | Notas |
|---|-----------|--------|-------|
| CA1 | Oferta/demanda asociada a una sola transacción | Parcial | Modelo permite; no hay validación explícita |
| CA2 | Cambio de estado a "emparejada"/"cerrada" | Parcial | act_on_contract cambia status; flujo manual |
| CA3 | Rechazo al reutilizar oferta | ❌ | No se valida que contract no esté ya matched |
| CA4 | Prevención bajo concurrencia | ❌ | Sin locking; race condition posible |
| CA5 | Consistencia en BD | Parcial | SQLAlchemy commit; sin transacciones distribuidas |

---

## Endpoints del Transaction Service

| Método | Ruta | HU | Auth | Estado |
|--------|------|-----|------|--------|
| POST | /transactions/energy | - | ❌ | OK |
| POST | /transactions/energy/query | HU-11 parcial | ❌ | OK |
| POST | /transactions/pde | - | ❌ | OK |
| POST | /transactions/contracts | HU-12 | ❌ | OK (sin validaciones) |
| **GET** | **/transactions/contracts** | **HU-13** | ❌ | **No existe** |
| POST | /transactions/contracts/{id}/action | HU-14 | ❌ | OK (cancel/accept/reject) |
| POST | /transactions/record-transaction | HU-16 | ❌ | OK |
| POST | /transactions/liquidate | HU-16 | ❌ | OK (no actualiza credits) |

---

## Cómo probar lo que existe

### HU-12 (crear oferta)
```bash
# Crear contrato (oferta) - sin auth
curl -X POST "http://localhost:8003/transactions/contracts" \
  -H "Content-Type: application/json" \
  -d '{"seller_id":1,"agreed_price":150,"energy_committed":50}'
# Esperado: 201 con { "id": ... }
```

### HU-13 (listar ofertas)
```bash
# Actualmente falla - no hay GET
curl "http://localhost:8003/transactions/contracts?status=active"
# Esperado actual: 404 o 405
```

### HU-14 (cancelar)
```bash
curl -X POST "http://localhost:8003/transactions/contracts/1/action" \
  -H "Content-Type: application/json" \
  -d '{"action":"cancel"}'
# Esperado: 200
```

### HU-16 (liquidar)
```bash
curl -X POST "http://localhost:8003/transactions/liquidate" \
  -H "Content-Type: application/json" \
  -d '{"community_id":1,"period":"2025-02"}'
```

---

## Checklist de gaps para cumplir HUs al 100%

```
□ HU-12: Auth en POST /contracts; validar role=prosumidor; validar saldo con credits service
□ HU-13: Implementar GET /contracts con filtros (status, seller_id, precio, kwh, fecha)
□ HU-14: Auth; validar seller_id = current user; validar estado cancelable
□ HU-15: Implementar motor de emparejamiento (demandas + matching)
□ HU-16: Integrar liquidate con energy_credits (debit seller, deposit buyer); historial
□ HU-17: Validar oferta no reutilizada; locking para concurrencia
```
