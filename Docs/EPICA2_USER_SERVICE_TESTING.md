# Guía de pruebas - Épica 2: Gestión de perfiles y roles (User Service)

## Resumen de implementación

| HU | Título | Backend | Frontend | Estado |
|----|--------|---------|----------|--------|
| HU-08 | Edición de datos personales | ✅ | ✅ | Implementado |
| HU-09 | Cambio de rol por administrador | ✅ | ✅ | Implementado |

---

## Requisitos previos

1. **User Service** corriendo (puerto configurado, ej. 8001)
2. **Auth Service** y base de datos compartida
3. **Token JWT** válido (obtener tras login)
4. **App Flutter** con `USER_SERVICE_URL` configurado en `.env`

---

## HU-08: Edición de datos personales

### Endpoints
- `GET /users/{user_id}` — Obtener perfil
- `PUT /users/{user_id}` — Actualizar perfil (Authorization: Bearer \<token\>)

### Criterios de aceptación y cómo probar

| # | Escenario | Pasos | Resultado esperado |
|---|-----------|-------|--------------------|
| **CA1** | Usuario edita sus propios datos | 1. Login como usuario consumidor<br>2. Ir a Mi Cuenta → Editar Perfil<br>3. Cambiar teléfono a 3001234567 y/o correo<br>4. Guardar | "Cambios guardados correctamente", datos actualizados |
| **CA2** | Administrador edita datos de otro usuario | 1. Login como admin (role=0)<br>2. Llamar `PUT /users/{ID_OTRO}` con body `{"phone":"3001234567"}` y header Authorization<br>3. Verificar respuesta | 200, mensaje "Perfil actualizado" |
| **CA3** | Correo duplicado | 1. Usuario A con correo a@test.com<br>2. Usuario B intenta cambiar su correo a a@test.com<br>3. Guardar | 400, mensaje "El correo ya está registrado" |
| **CA4** | Formato inválido | 1. Ingresar correo sin @ (ej. "correo.invalido")<br>2. O teléfono con menos de 10 dígitos (ej. "123")<br>3. Guardar | 422 (correo) o mensaje de validación (teléfono) |

### Pruebas con cURL

```bash
# Obtener perfil (reemplazar TOKEN y USER_ID)
curl -X GET "http://localhost:8001/users/1" \
  -H "Authorization: Bearer TOKEN"

# Actualizar teléfono y correo
curl -X PUT "http://localhost:8001/users/1" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"phone":"3001234567","email":"nuevo@correo.com"}'
```

### Validaciones backend
- **Email**: Pydantic `EmailStr` + unicidad en BD
- **Teléfono**: 10 dígitos (Colombia)
- **Permisos**: Solo el propio usuario o admin (role=0) puede editar

---

## HU-09: Cambio de rol por administrador

### Endpoint
- `PATCH /users/{user_id}/role` — Cambiar rol (solo admin)

Body: `{"role": 0|1|2}` — 0=Administrador, 1=Consumidor, 2=Prosumidor

### Criterios de aceptación y cómo probar

| # | Escenario | Pasos | Resultado esperado |
|---|-----------|-------|--------------------|
| **CA1** | Admin cambia rol de usuario | 1. Login como admin<br>2. Cambiar rol: ID usuario X, nuevo rol Prosumidor (2)<br>3. Guardar | "Rol actualizado", datos con role=2 |
| **CA2** | Usuario no-admin intenta cambiar rol | 1. Login como consumidor (role=1)<br>2. Llamar `PATCH /users/5/role` con body `{"role":2}` | 403 Forbidden |
| **CA3** | Último admin intenta dejar de ser admin | 1. Solo 1 usuario con role=0 activo<br>2. Admin intenta cambiar su propio rol a Consumidor (1)<br>3. Enviar | 400, "Debe existir al menos un administrador activo" |
| **CA4** | Asignar el mismo rol actual | 1. Usuario tiene role=2 (Prosumidor)<br>2. Admin intenta asignar role=2 nuevamente | 200, mensaje "El rol ya está asignado", sin cambios en BD |

### Pruebas con cURL

```bash
# Cambiar rol (solo con token de admin)
curl -X PATCH "http://localhost:8001/users/5/role" \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"role": 2}'

# Intentar como no-admin → debe dar 403
curl -X PATCH "http://localhost:8001/users/5/role" \
  -H "Authorization: Bearer USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"role": 2}'
```

### Frontend
- **Pantalla**: `ChangeRoleScreen` (accesible desde menú admin)
- **Roles en dropdown**: 0=Administrador, 1=Consumidor, 2=Prosumidor

---

## Checklist de pruebas rápidas

```
□ HU-08 CA1: Usuario edita teléfono/correo propio → éxito
□ HU-08 CA2: Admin edita perfil de otro usuario → éxito
□ HU-08 CA3: Actualizar a correo existente → "El correo ya está registrado"
□ HU-08 CA4: Correo inválido o teléfono < 10 dígitos → rechazo
□ HU-09 CA1: Admin cambia rol a Prosumidor/Consumidor → éxito
□ HU-09 CA2: Consumidor intenta cambiar rol → 403
□ HU-09 CA3: Último admin intenta cambiar su rol → "Debe existir al menos un administrador activo"
□ HU-09 CA4: Asignar mismo rol → "El rol ya está asignado"
```

---

## Preparación para CA3 (HU-09)

Para probar el escenario "único administrador":
1. Tener exactamente 1 usuario con `role=0` y `is_active=1` en la tabla `users`
2. Como ese admin, ir a Cambiar rol
3. Ingresar su propio ID, seleccionar Consumidor
4. Debe aparecer "Debe existir al menos un administrador activo"

---

## Nota sobre auditoría (HU-08 CA2)

El criterio "registra la acción como modificación por administrador" requiere integración con el **audit_service**. Si existe ese servicio, se puede añadir un evento de auditoría cuando `current_user_id != target_user_id` y `current_role == 0`.
