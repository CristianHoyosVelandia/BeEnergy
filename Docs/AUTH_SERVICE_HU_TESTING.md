# Guía de pruebas - Auth Service (Épica 1)

## Resumen de implementación por HU

| HU | Título | Backend | Frontend | Notas |
|----|--------|---------|----------|-------|
| HU-01 | Registro de usuario | ✅ | ✅ | Implementado |
| HU-02 | Inicio de sesión | ✅ | ✅ | Implementado |
| HU-03 | Generación de token JWT | ✅ | ✅ | Implementado |
| HU-04 | Validación de token | ✅ | Parcial | Endpoint existe; no se usa en guards |
| HU-05 | Recuperación de contraseña | ✅ | ✅ | Implementado |
| HU-06 | Autenticación 2FA | ✅ | ✅ | Implementado con OTP por correo |
| HU-07 | Renovación de token | ✅ | ✅ | Endpoint /auth/refresh + interceptor 401 |

---

## Cómo ejecutar las pruebas

### Requisitos previos
1. **Auth Service** corriendo en la URL configurada en `.env` (ej. `http://10.238.80.155:8000`)
2. **Base de datos** del auth_service inicializada
3. **Configuración de correo** (opcional para HU-05): Si `MAIL_SERVER` no está configurado, el OTP se imprime en consola del backend
4. **App Flutter** en modo debug o release

---

## HU-01: Registro de usuario

### Escenarios a probar

| # | Escenario | Pasos | Resultado esperado |
|---|-----------|-------|--------------------|
| 1 | Registro exitoso | 1. Ir a Registrarse<br>2. Ingresar nombre, apellido, teléfono, correo nuevo, contraseña<br>3. Seleccionar perfil (consumidor/prosumidor)<br>4. Enviar | Mensaje "Registro exitoso" / "Usuario registrado exitosamente" |
| 2 | Correo ya existente | 1. Intentar registrar con un correo ya usado | Mensaje "El correo ya está registrado" |
| 3 | Campos inválidos | 1. Correo sin @, teléfono inválido, etc.<br>2. Enviar | Mensajes de validación por campo |
| 4 | Perfil inválido | 1. Seleccionar un perfil no permitido (si la UI lo permite) | "Perfil inválido" o validación equivalente |

### Dónde probar en la app
- **Pantalla:** `RegisterScreen` (ruta `register`)
- **Desde login:** enlace "Regístrate" o similar

### Backend
- **Endpoint:** `POST /auth/sign-up`
- **Body:** `{ "name", "lastname", "email", "password", "phone?", "role": 1|2 }`
- **Respuesta 201:** `{ "success": true, "message": "Usuario registrado exitosamente", "data": {...} }`

---

## HU-02: Inicio de sesión

### Escenarios a probar

| # | Escenario | Pasos | Resultado esperado |
|---|-----------|-------|--------------------|
| 1 | Login exitoso | 1. Ingresar correo y contraseña válidos<br>2. Presionar "Iniciar sesión" | Acceso a la plataforma, redirección al panel |
| 2 | Correo no registrado | 1. Ingresar correo que no existe | "El correo no está registrado" *(backend devuelve "Credenciales inválidas")* |
| 3 | Contraseña incorrecta | 1. Correo válido, contraseña incorrecta | "Contraseña incorrecta" *(backend devuelve "Credenciales inválidas")* |
| 4 | Datos incompletos | 1. Dejar correo o contraseña vacíos<br>2. O correo con formato inválido | "Ingrese correo y contraseña válidos" |

### Dónde probar en la app
- **Pantalla:** `LoginScreen` (ruta inicial si no hay sesión guardada)
- **Backend:** `POST /auth/log-in`

---

## HU-03: Generación de token de acceso (JWT)

### Verificación (automática en login)

| # | Criterio | Cómo verificar |
|---|----------|----------------|
| 1 | Token en respuesta | Tras login exitoso, la respuesta incluye `access_token` |
| 2 | Claims: sub/userId, role | Decodificar JWT en [jwt.io](https://jwt.io) y revisar payload |
| 3 | Claim exp | El token incluye fecha de expiración |
| 4 | Token firmado | Verificación con SECRET_KEY del servidor |
| 5 | No token si credenciales incorrectas | Login fallido no devuelve token |
| 6 | Sin datos sensibles | Payload no contiene contraseña ni PII innecesaria |

### Prueba manual
1. Login exitoso
2. En DevTools o logs, inspeccionar respuesta del login: debe incluir `data.access_token`
3. Pegar token en jwt.io y revisar claims

---

## HU-04: Validación de token

### Escenarios a probar

| # | Escenario | Pasos | Resultado esperado |
|---|-----------|-------|--------------------|
| 1 | Token válido | 1. Login exitoso<br>2. Llamar `GET /auth/verify-token` con header `Authorization: Bearer <token>` | 200, datos del usuario |
| 2 | Token expirado | 1. Usar token antiguo/expirado | 401 "Token inválido o expirado" |
| 3 | Token inválido/manipulado | 1. Modificar el token o usar uno falso | 401 "Token inválido" |
| 4 | Sin token | 1. Llamar endpoint protegido sin header Authorization | 401 "Token requerido" o "Formato de token inválido" |

### Prueba con cURL (con token válido)
```bash
curl -X GET "http://TU_URL:8000/auth/verify-token" \
  -H "Authorization: Bearer TU_TOKEN_AQUI"
```

### Nota
El frontend no usa `verifyToken` para proteger rutas; usa datos locales (DB). Para cumplir HU-04 en la app, se podría llamar `verifyToken` al iniciar y ante 401 cerrar sesión.

---

## HU-05: Recuperación de contraseña

### Escenarios a probar

| # | Escenario | Pasos | Resultado esperado |
|---|-----------|-------|--------------------|
| 1 | Solicitud con correo registrado | 1. Ir a "¿Olvidaste la contraseña?"<br>2. Ingresar correo registrado<br>3. Enviar | Mensaje genérico "Si existe una cuenta asociada, se ha enviado un correo" |
| 2 | Correo no registrado | 1. Ingresar correo que no existe | Mismo mensaje genérico (no revelar si existe o no) |
| 3 | Restablecer con OTP válido | 1. Recibir OTP (correo o consola del backend)<br>2. Ir a pantalla de nueva contraseña<br>3. Ingresar OTP + nueva contraseña + confirmar<br>4. Enviar | Contraseña actualizada, mensaje de éxito |
| 4 | OTP expirado | 1. Usar OTP después del tiempo de validez (ej. 30 min) | "El enlace ha expirado. Solicite uno nuevo." |
| 5 | Token/OTP ya utilizado | 1. Reutilizar un OTP que ya se usó para cambiar contraseña | "Token inválido o ya utilizado" |

### Dónde probar en la app
- **Olvidé contraseña:** `NoRecuerdomiclaveScreen` (desde login)
- **Cambiar clave (logueado):** `CambiarClavePerfilScreen` (Mi cuenta → Cambiar contraseña)
- **Nueva contraseña:** `ResetPasswordScreen` (correo + OTP + nueva contraseña)

### Backend
- `POST /auth/forgot-password` — Body: `{ "email": "..." }` o `{ "document": "..." }`
- `POST /auth/reset-password` — Body: `{ "email": "...", "otp": "123456", "new_password": "..." }`

---

## HU-06: Autenticación de dos factores (2FA)

### Estado: **Implementado**

- Tras validar credenciales, si 2FA está activo, se envía OTP al correo y se solicita verificación.
- Endpoint `POST /auth/verify-2fa` para verificar OTP y obtener token final.
- Configuración por variables de entorno (ver abajo).

### Escenarios a probar

| # | Escenario | Pasos | Resultado esperado |
|---|-----------|-------|--------------------|
| 1 | Login con 2FA activo | 1. Activar `TWO_FACTOR_ENABLED=true` o `TWO_FACTOR_ROLES=0` en backend<br>2. Login con credenciales válidas | Respuesta `otp_required: true`, navegación a pantalla OTP |
| 2 | Verificar OTP correcto | 1. Tras login 2FA, revisar correo o consola backend (modo dev)<br>2. Ingresar código de 6 dígitos<br>3. Verificar | Acceso a la app, token JWT guardado |
| 3 | OTP incorrecto | 1. Ingresar código equivocado | "Código OTP inválido" |
| 4 | Sesión expirada | 1. Esperar 5+ min tras login 2FA<br>2. Ingresar OTP | "La sesión expiró. Inicia sesión de nuevo." |
| 5 | Cancelar 2FA | 1. En pantalla OTP, pulsar "Cancelar" | Vuelta a pantalla de login |

### Configuración backend (.env)

```env
# Activar 2FA para todos los usuarios
TWO_FACTOR_ENABLED=true

# O activar solo para ciertos roles (coma-separado, ej. 0=admin, 1=consumidor)
TWO_FACTOR_ROLES=0,1

# Opcional: expiración OTP 2FA en minutos (default 5)
OTP_2FA_EXPIRE_MINUTES=5

# Opcional: intentos máximos antes de invalidar (default 5)
OTP_2FA_MAX_ATTEMPTS=5
```

### Backend
- `POST /auth/log-in` — Si 2FA activo: devuelve `{ otp_required: true, temp_session, email, user_id }`
- `POST /auth/verify-2fa` — Body: `{ "temp_session": "...", "otp": "123456" }` → devuelve `access_token`

### Migración BD
Ejecutar en MySQL: `migrations/001_otp_2fa.sql` (crea tabla `otp_2fa`)

---

## HU-07: Renovación de token

### Estado: **Implementado**

- Backend: `POST /auth/refresh` acepta token en body (`access_token` o `refreshToken`) y devuelve nuevo JWT.
- Frontend: Ante 401, el `ApiInterceptor` llama a `refreshAuthToken`, actualiza el token y repite la petición.

### Escenarios a probar

| # | Escenario | Pasos | Resultado esperado |
|---|-----------|-------|--------------------|
| 1 | Token renovado tras 401 | 1. Hacer una petición con token expirado (o mockear 401)<br>2. Interceptor llama refresh | Nueva petición con token fresco, respuesta exitosa |
| 2 | Refresh con token inválido | 1. Usar token corrupto o revocado en refresh | 401, no se repite la petición |
| 3 | Sin token | 1. Petición protegida sin Authorization | 401 sin intento de refresh |

### Backend
- `POST /auth/refresh` — Body: `{ "refreshToken": "..." }` o `{ "access_token": "..." }` → devuelve `{ "access_token": "..." }`

---

## Checklist de pruebas rápidas (Frontend)

```
□ HU-01: Registrar usuario nuevo → éxito
□ HU-01: Registrar con correo existente → error
□ HU-02: Login con credenciales correctas → acceso
□ HU-02: Login con correo inexistente → mensaje error
□ HU-02: Login con contraseña incorrecta → mensaje error
□ HU-02: Login con campos vacíos → validación
□ HU-03: Tras login, verificar que hay token en respuesta
□ HU-04: Llamar verify-token con token válido (cURL o Postman)
□ HU-05: Solicitar recuperación con correo → mensaje genérico
□ HU-05: Restablecer contraseña con OTP válido → éxito
□ HU-05: Restablecer con OTP expirado/usado → error
□ HU-06: Login con 2FA → pantalla OTP → verificar código → acceso
```

---

## Endpoints del Auth Service

| Método | Ruta | HU | Descripción |
|--------|------|-----|-------------|
| GET | /auth/ping | - | Health check |
| POST | /auth/sign-up | HU-01 | Registro |
| POST | /auth/log-in | HU-02, HU-03, HU-06 | Login + JWT (o otp_required si 2FA) |
| POST | /auth/verify-2fa | HU-06 | Verificar OTP 2FA |
| POST | /auth/forgot-password | HU-05 | Solicitar OTP |
| POST | /auth/reset-password | HU-05 | Restablecer con OTP |
| GET | /auth/verify-token | HU-04 | Verificar token |
| GET | /auth/cities | - | Listar ciudades |
| POST | /auth/refresh | HU-07 | Renovar token |
