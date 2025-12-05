# Integración de Autenticación con Volt Platform Services API

## Resumen

Se ha implementado la integración completa del sistema de autenticación con la API **Volt Platform Services** (OpenAPI 3.1, v1.0.0) para las pantallas de Login, Registro y Recuperación de Contraseña.

## Arquitectura Implementada

### 1. Configuración del Entorno (.env)

**Archivo**: [.env](../../.env)

```env
# API Base URL - Volt Platform Services
BASE_URL=http://127.0.0.1:8000

# API Version
API_VERSION=1.0.0
OAS_VERSION=3.1
```

**Importante**: Para cambiar entre entornos (local, staging, production), solo necesitas modificar `BASE_URL` en el archivo `.env`.

### 2. Endpoints del API

**Archivo**: [lib/core/constants/api_endpoints.dart](../../lib/core/constants/api_endpoints.dart)

Endpoints configurados según la API Volt Platform Services:

```dart
class ApiEndpoints {
  // Auth Endpoints
  static const String ping = '/auth/ping';
  static const String login = '/auth/log-in';
  static const String signUp = '/auth/sign-up';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyToken = '/auth/verify-token';
  static const String logout = '/auth/logout';
}
```

### 3. Servicio de Autenticación

**Archivo**: [lib/core/services/auth_service.dart](../../lib/core/services/auth_service.dart)

Servicio centralizado que maneja todas las operaciones de autenticación:

#### Métodos Disponibles

##### `ping()` - Verificar Conexión
```dart
final bool isOnline = await authService.ping();
```

##### `login()` - Iniciar Sesión
```dart
final response = await authService.login(
  email: 'user@example.com',
  password: 'password123',
);

if (response['success']) {
  final userData = response['data'];
  final token = response['token'];
  // El token se guarda automáticamente
}
```

##### `signUp()` - Registrar Usuario
```dart
final response = await authService.signUp(
  email: 'user@example.com',
  password: 'password123',
  name: 'John Doe',        // Opcional
  phone: '3001234567',     // Opcional
);
```

##### `forgotPassword()` - Recuperar Contraseña
```dart
final response = await authService.forgotPassword(
  email: 'user@example.com',
);
```

##### `resetPassword()` - Resetear Contraseña
```dart
final response = await authService.resetPassword(
  token: 'recovery-token',
  newPassword: 'newPassword123',
);
```

##### `logout()` - Cerrar Sesión
```dart
final response = await authService.logout();
// El token se elimina automáticamente
```

### 4. Cliente HTTP (ApiClient)

**Archivo**: [lib/core/api/api_client.dart](../../lib/core/api/api_client.dart)

- Patrón Singleton
- Basado en Dio
- Manejo automático de tokens JWT
- Interceptores para logging
- Timeouts configurables (30 segundos)

```dart
// Obtener instancia
final apiClient = ApiClient.instance;

// Métodos disponibles
await apiClient.get('/endpoint');
await apiClient.post('/endpoint', data: {...});
await apiClient.put('/endpoint', data: {...});
await apiClient.delete('/endpoint');

// Manejo de tokens
apiClient.setAuthToken('jwt-token');
apiClient.removeAuthToken();
```

## Pantallas Integradas

### 1. Login Screen

**Archivo**: [lib/screens/main_screens/Login/login_screen.dart](../../lib/screens/main_screens/Login/login_screen.dart)

**Características**:
- ✅ Validación de email y contraseña
- ✅ Indicador de carga durante el login
- ✅ Manejo de errores con mensajes al usuario
- ✅ Navegación automática al dashboard tras login exitoso
- ✅ Guardado automático del token JWT
- ✅ Sincronización con base de datos local

**Flujo**:
1. Usuario ingresa email y contraseña
2. Se validan los campos localmente
3. Se llama a `authService.login()`
4. Si es exitoso:
   - Se guarda el token JWT en ApiClient
   - Se crea el usuario local en SQLite
   - Se navega a la pantalla principal (NavPages)
5. Si falla:
   - Se muestra mensaje de error al usuario

### 2. Register Screen

**Archivo**: [lib/screens/main_screens/Login/register_screen.dart](../../lib/screens/main_screens/Login/register_screen.dart)

**Características**:
- ✅ Registro con nombre, email y contraseña
- ✅ Validación de campos
- ✅ Indicador de carga durante el registro
- ✅ Navegación directa al dashboard tras registro exitoso
- ✅ Manejo de errores (email duplicado, etc.)

**Flujo**:
1. Usuario ingresa nombre, email y contraseña
2. Se validan los campos
3. Se llama a `authService.signUp()`
4. Si es exitoso:
   - Se guarda el token JWT
   - Se crea el usuario local
   - Se navega directamente a la app (login automático)
5. Si falla:
   - Se muestra mensaje de error

### 3. Forgot Password Screen

**Archivo**: [lib/screens/main_screens/Login/noRecuerdomiClave_screen.dart](../../lib/screens/main_screens/Login/noRecuerdomiClave_screen.dart)

**Características**:
- ✅ Envío de correo de recuperación
- ✅ Validación de email
- ✅ Indicador de carga
- ✅ Retorno automático al login tras envío exitoso

**Flujo**:
1. Usuario ingresa su email
2. Se valida el formato del email
3. Se llama a `authService.forgotPassword()`
4. Si es exitoso:
   - Se muestra mensaje de confirmación
   - Se retorna al login después de 2 segundos
5. Si falla:
   - Se muestra mensaje de error

## Estructura de Respuestas del API

Todas las respuestas del AuthService siguen esta estructura:

```dart
{
  'success': bool,           // true si la operación fue exitosa
  'message': String,         // Mensaje descriptivo
  'data': Map<String, dynamic>?,  // Datos del usuario (si aplica)
  'token': String?,          // JWT token (si aplica)
}
```

### Ejemplo de respuesta exitosa (Login/SignUp):
```dart
{
  'success': true,
  'message': 'Login exitoso',
  'data': {
    'id': 1,
    'name': 'John Doe',
    'email': 'user@example.com',
    'phone': '3001234567',
    'energy': '90',
    'balance': '100000',
    'city_id': 4110,
  },
  'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
}
```

### Ejemplo de respuesta con error:
```dart
{
  'success': false,
  'message': 'Email o contraseña incorrectos',
  'data': null,
  'token': null,
}
```

## Manejo de Errores

### Tipos de Errores Manejados

1. **Errores de Validación** (Local):
   - Email inválido
   - Contraseña muy corta
   - Campos vacíos

2. **Errores de API**:
   - Credenciales incorrectas
   - Usuario no encontrado
   - Email ya registrado
   - Token inválido o expirado

3. **Errores de Conexión**:
   - Sin internet
   - Servidor no disponible
   - Timeout

### Ejemplo de Manejo:
```dart
try {
  final response = await authService.login(email: email, password: password);

  if (response['success']) {
    // Login exitoso
  } else {
    // Error del servidor (credenciales incorrectas, etc.)
    showError(response['message']);
  }
} catch (e) {
  // Error de conexión
  showError('Error de conexión. Verifica tu internet.');
}
```

## Estados de Carga (Loading States)

Todas las pantallas implementan estados de carga:

```dart
bool _isLoading = false;

ElevatedButton(
  onPressed: _isLoading ? null : () async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Llamada al API
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  },
  child: _isLoading
    ? CircularProgressIndicator()
    : Text('Iniciar Sesión'),
)
```

**Características**:
- ✅ Botón deshabilitado durante la carga
- ✅ Spinner visible al usuario
- ✅ Previene múltiples envíos

## Sincronización con Base de Datos Local

Todas las operaciones de autenticación se sincronizan con SQLite:

```dart
// Después de login/signUp exitoso
MyUser usuario = MyUser(
  idUser: userData['id'] ?? 0,
  nombre: userData['name'] ?? '',
  correo: userData['email'] ?? '',
  // ... otros campos
);

// Guardar en SQLite
DatabaseHelper().addUser(usuario);
```

**Ventajas**:
- Persistencia de datos offline
- Acceso rápido a información del usuario
- Fallback si falla la conexión

## Seguridad

### Token JWT

El token JWT se maneja automáticamente:

1. **Almacenamiento**:
   - Se guarda en memoria en el `ApiClient`
   - Se incluye automáticamente en todas las peticiones

2. **Header**:
   ```
   Authorization: Bearer <token>
   ```

3. **Eliminación**:
   - Al cerrar sesión (`logout()`)
   - Automáticamente si el token expira

### Buenas Prácticas Implementadas

✅ Tokens nunca se muestran en consola (en producción)
✅ Contraseñas nunca se guardan sin cifrar (se envían al servidor para validación)
✅ HTTPS recomendado para producción
✅ Validación de inputs antes de enviar al servidor
✅ Timeouts configurados para prevenir bloqueos

## Testing de la Integración

### 1. Verificar Servidor Local

```dart
final authService = AuthService();
final isOnline = await authService.ping();
print('Server online: $isOnline');
```

### 2. Test de Login

```dart
final response = await authService.login(
  email: 'test@example.com',
  password: 'password123',
);

print('Success: ${response['success']}');
print('Message: ${response['message']}');
print('Token: ${response['token']}');
```

### 3. Test de Registro

```dart
final response = await authService.signUp(
  email: 'newuser@example.com',
  password: 'password123',
  name: 'New User',
);
```

## Configuración para Diferentes Entornos

### Local (Desarrollo)
```env
BASE_URL=http://127.0.0.1:8000
```

### Staging
```env
BASE_URL=https://staging-api.beeenergy.com
```

### Production
```env
BASE_URL=https://api.beeenergy.com
```

## Troubleshooting

### Problema: "Error de conexión" en todas las peticiones

**Solución**:
1. Verificar que el servidor esté corriendo en `http://127.0.0.1:8000`
2. Verificar el archivo `.env` tenga la URL correcta
3. Ejecutar `flutter clean && flutter pub get`
4. Reiniciar la app

### Problema: "Token inválido" después de un tiempo

**Solución**:
- El token JWT tiene un tiempo de expiración
- Implementar refresh token (próxima versión)
- Por ahora, el usuario debe hacer login nuevamente

### Problema: Datos del usuario no coinciden con la API

**Solución**:
- Verificar el mapeo de campos en cada pantalla
- La API puede retornar campos diferentes
- Ajustar el código según la respuesta real del servidor

## Próximas Mejoras

1. **Refresh Token**: Renovación automática de tokens expirados
2. **Biometría**: Login con huella digital / Face ID
3. **Remember Me**: Guardar credenciales de forma segura
4. **Social Login**: Login con Google, Facebook, etc.
5. **Two-Factor Authentication**: Seguridad adicional

## Conclusión

La integración está completa y lista para funcionar con la API Volt Platform Services. Todas las pantallas de autenticación están conectadas al backend y manejan correctamente:

✅ Login
✅ Registro
✅ Recuperación de contraseña
✅ Manejo de tokens JWT
✅ Sincronización con SQLite
✅ Estados de carga
✅ Manejo de errores
✅ Validación de datos

Para comenzar a usar, solo asegúrate de que el servidor esté corriendo en `http://127.0.0.1:8000` y que el archivo `.env` esté configurado correctamente.
