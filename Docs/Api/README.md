# Documentación API - Be Energy

Esta carpeta contiene la documentación completa de la implementación del patrón de diseño para la conexión con el API del proyecto Be Energy.

## 📋 Tabla de Contenidos

1. [Arquitectura del API](#arquitectura-del-api)
2. [Configuración Inicial](#configuración-inicial)
3. [Estructura de Carpetas](#estructura-de-carpetas)
4. [Componentes Principales](#componentes-principales)
5. [Guía de Uso](#guía-de-uso)
6. [Ejemplos de Implementación](#ejemplos-de-implementación)
7. [Manejo de Errores](#manejo-de-errores)
8. [Mejores Prácticas](#mejores-prácticas)

---

## 🏗️ Arquitectura del API

El patrón de diseño implementado sigue una arquitectura en capas que separa las responsabilidades:

```
┌─────────────────────────────────────────┐
│         UI Layer (Screens/Widgets)      │
│  Presenta datos y captura eventos       │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│         BLoC/State Management Layer     │
│  Maneja el estado de la aplicación     │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│         Repository Layer                │
│  Abstrae la fuente de datos            │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│         API Client Layer                │
│  Cliente HTTP (Dio) con interceptores   │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│         External API                    │
│  Servidor backend                       │
└─────────────────────────────────────────┘
```

---

## ⚙️ Configuración Inicial

### 1. Instalar Dependencias

Ejecuta el siguiente comando para instalar las dependencias necesarias:

```bash
flutter pub get
```

### 2. Configurar Variables de Entorno

Edita el archivo [.env](.env) en la raíz del proyecto:

```env
BASE_URL=https://tu-api.com
API_VERSION=v1
APP_CODE=0
APP_VERSION=6.5.5
DEFAULT_CITY_CODE=4110
```

### 3. Inicializar dotenv en main.dart

Actualiza tu archivo [lib/main.dart](lib/main.dart):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}
```

---

## 📁 Estructura de Carpetas

```
lib/
├── core/
│   ├── api/
│   │   ├── api_client.dart          # Cliente HTTP principal (Singleton)
│   │   ├── api_response.dart        # Modelos de respuesta genéricos
│   │   └── api_exceptions.dart      # Manejo de excepciones
│   ├── network/
│   │   └── api_interceptor.dart     # Interceptor personalizado
│   └── constants/
│       └── api_endpoints.dart       # Constantes de endpoints
└── repositories/
    ├── auth_repository.dart         # Repositorio de autenticación
    └── energy_repository.dart       # Repositorio de energía (ejemplo)
```

---

## 🔧 Componentes Principales

### 1. ApiClient ([lib/core/api/api_client.dart](lib/core/api/api_client.dart))

Cliente HTTP Singleton que maneja todas las peticiones al API.

**Características:**
- ✅ Patrón Singleton (una sola instancia)
- ✅ Basado en Dio para peticiones HTTP
- ✅ Timeout configurable (30 segundos)
- ✅ Interceptores personalizados
- ✅ Métodos para GET, POST, PUT, PATCH, DELETE
- ✅ Manejo de tokens de autenticación

**Métodos principales:**
```dart
ApiClient.instance.get(endpoint, queryParameters, headers)
ApiClient.instance.post(endpoint, data, queryParameters, headers)
ApiClient.instance.put(endpoint, data, queryParameters, headers)
ApiClient.instance.patch(endpoint, data, queryParameters, headers)
ApiClient.instance.delete(endpoint, data, queryParameters, headers)
ApiClient.instance.setAuthToken(token)
ApiClient.instance.removeAuthToken()
```

### 2. ApiInterceptor ([lib/core/network/api_interceptor.dart](lib/core/network/api_interceptor.dart))

Interceptor que procesa todas las peticiones y respuestas.

**Funcionalidades:**
- ✅ Agrega headers personalizados automáticamente (`codApp`, `codVersion`, `codCiudad`)
- ✅ Logging de peticiones y respuestas
- ✅ Manejo centralizado de errores (401, 403, 500, etc.)
- ✅ Hook para refresh token

### 3. ApiException ([lib/core/api/api_exceptions.dart](lib/core/api/api_exceptions.dart))

Sistema robusto de manejo de excepciones.

**Tipos de excepciones:**
- `BadRequestException` (400)
- `UnauthorizedException` (401)
- `ForbiddenException` (403)
- `NotFoundException` (404)
- `UnprocessableEntityException` (422)
- `InternalServerException` (500)
- `ServiceUnavailableException` (503)

### 4. ApiResponse ([lib/core/api/api_response.dart](lib/core/api/api_response.dart))

Modelo genérico para respuestas del API.

**Estructura:**
```dart
ApiResponse<T> {
  bool success;
  String? message;
  T? data;
  List<String>? errors;
  int? statusCode;
}
```

**Incluye también:**
- `PaginatedResponse<T>` para respuestas paginadas

### 5. ApiEndpoints ([lib/core/constants/api_endpoints.dart](lib/core/constants/api_endpoints.dart))

Centraliza todas las rutas de los endpoints del API.

**Categorías:**
- 🔐 Autenticación (login, register, logout, etc.)
- 👤 Usuario (profile, update, change-password)
- 🏢 Empresas (getEmpresas, getEmpresaById)
- ⚡ Energía (data, history, stats)
- 💱 Trading (create, transactions, etc.)
- 🔔 Notificaciones
- 📍 Ubicación
- 💳 Pagos

### 6. Repositories ([lib/repositories/](lib/repositories/))

Capa de abstracción que encapsula la lógica de acceso a datos.

**Ejemplos incluidos:**
- `AuthRepository`: Operaciones de autenticación
- `EnergyRepository`: Operaciones relacionadas con energía

---

## 📖 Guía de Uso

### Realizar una petición GET

```dart
import '../core/api/api_client.dart';
import '../core/constants/api_endpoints.dart';

Future<void> fetchData() async {
  try {
    final response = await ApiClient.instance.get(
      ApiEndpoints.energyData,
      queryParameters: {'period': 'month'},
    );

    print('Datos recibidos: ${response.data}');
  } on ApiException catch (e) {
    print('Error: ${e.message}');
  }
}
```

### Realizar una petición POST

```dart
import '../core/api/api_client.dart';
import '../core/constants/api_endpoints.dart';

Future<void> createTransaction() async {
  try {
    final response = await ApiClient.instance.post(
      ApiEndpoints.createTransaction,
      data: {
        'amount': 100,
        'type': 'compra',
      },
    );

    print('Transacción creada: ${response.data}');
  } on ApiException catch (e) {
    print('Error: ${e.message}');
  }
}
```

### Usar un Repository

```dart
import '../repositories/auth_repository.dart';

Future<void> loginUser() async {
  final repository = AuthRepository();

  try {
    final response = await repository.login(
      email: 'user@example.com',
      password: 'password123',
    );

    if (response.success) {
      print('Login exitoso: ${response.data}');
      // Guardar token, redirigir, etc.
    }
  } on UnauthorizedException catch (e) {
    print('Credenciales incorrectas');
  } on ApiException catch (e) {
    print('Error: ${e.message}');
  }
}
```

---

## 💡 Ejemplos de Implementación

### Ejemplo 1: Login con BLoC

```dart
// En tu BLoC
class AuthBloc extends Bloc {
  final AuthRepository _authRepository = AuthRepository();

  Future<void> login(String email, String password) async {
    try {
      final response = await _authRepository.login(
        email: email,
        password: password,
      );

      if (response.success) {
        // Actualizar estado, guardar token, etc.
        final token = response.data?['token'];
        // Guardar token en almacenamiento local
      }
    } on UnauthorizedException {
      // Mostrar error de credenciales incorrectas
    } on ApiException catch (e) {
      // Mostrar error genérico
    }
  }
}
```

### Ejemplo 2: Crear un nuevo Repository

```dart
// lib/repositories/trading_repository.dart

import '../core/api/api_client.dart';
import '../core/api/api_response.dart';
import '../core/api/api_exceptions.dart';
import '../core/constants/api_endpoints.dart';

class TradingRepository {
  final ApiClient _apiClient = ApiClient.instance;

  Future<ApiResponse<Map<String, dynamic>>> createTransaction({
    required double amount,
    required String type,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.createTransaction,
        data: {
          'amount': amount,
          'type': type,
        },
      );

      return ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
    } on ApiException {
      rethrow;
    }
  }
}
```

### Ejemplo 3: Manejo de Respuestas Paginadas

```dart
import '../core/api/api_response.dart';

Future<void> fetchPaginatedData() async {
  try {
    final response = await ApiClient.instance.get(
      '/api/items',
      queryParameters: {'page': 1, 'limit': 20},
    );

    final paginatedResponse = PaginatedResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json,
    );

    print('Página ${paginatedResponse.currentPage} de ${paginatedResponse.totalPages}');
    print('Total de items: ${paginatedResponse.totalItems}');
    print('¿Tiene siguiente página?: ${paginatedResponse.hasNextPage}');
  } on ApiException catch (e) {
    print('Error: ${e.message}');
  }
}
```

---

## ⚠️ Manejo de Errores

### Tipos de Errores

1. **Errores de Conexión**
   - `ConnectionTimeout`: Tiempo de conexión agotado
   - `SocketException`: Sin conexión a internet

2. **Errores HTTP**
   - `400`: Bad Request (datos incorrectos)
   - `401`: Unauthorized (no autenticado)
   - `403`: Forbidden (sin permisos)
   - `404`: Not Found (recurso no encontrado)
   - `422`: Unprocessable Entity (validación fallida)
   - `500`: Internal Server Error
   - `503`: Service Unavailable

### Capturar Errores Específicos

```dart
try {
  await repository.someMethod();
} on UnauthorizedException catch (e) {
  // Token expirado o credenciales incorrectas
  // Redirigir a login
} on NotFoundException catch (e) {
  // Recurso no encontrado
  // Mostrar mensaje apropiado
} on ApiException catch (e) {
  // Error genérico
  print('Error: ${e.message}');
  print('Status Code: ${e.statusCode}');
}
```

---

## ✅ Mejores Prácticas

### 1. Siempre usa Repositories

❌ **Incorrecto:**
```dart
// En un BLoC o Widget
final response = await ApiClient.instance.get('/users');
```

✅ **Correcto:**
```dart
// En un BLoC o Widget
final response = await userRepository.getUsers();
```

### 2. Maneja Excepciones Específicas

❌ **Incorrecto:**
```dart
try {
  await repository.login(email, password);
} catch (e) {
  print('Error: $e');
}
```

✅ **Correcto:**
```dart
try {
  await repository.login(email, password);
} on UnauthorizedException catch (e) {
  // Manejo específico para credenciales incorrectas
} on ApiException catch (e) {
  // Manejo genérico de errores del API
}
```

### 3. Usa ApiResponse para Respuestas Consistentes

```dart
Future<ApiResponse<MyModel>> getData() async {
  try {
    final response = await _apiClient.get(endpoint);

    return ApiResponse.fromJson(
      response.data,
      (data) => MyModel.fromJson(data),
    );
  } on ApiException {
    rethrow;
  }
}
```

### 4. Centraliza los Endpoints

❌ **Incorrecto:**
```dart
await _apiClient.get('/api/users/profile');
```

✅ **Correcto:**
```dart
await _apiClient.get(ApiEndpoints.userProfile);
```

### 5. Usa el Interceptor para Operaciones Comunes

El interceptor ya agrega automáticamente:
- `codApp`
- `codVersion`
- `codCiudad` (si no está presente)

No es necesario agregarlos manualmente en cada petición.

### 6. Logs en Desarrollo

El `LogInterceptor` de Dio está habilitado por defecto. En producción, considera deshabilitarlo:

```dart
// En api_client.dart
if (kDebugMode) {
  _dio.interceptors.add(LogInterceptor(...));
}
```

### 7. Actualiza el Token Después del Login

```dart
if (response.data['token'] != null) {
  ApiClient.instance.setAuthToken(response.data['token']);
}
```

### 8. Remueve el Token al Cerrar Sesión

```dart
await authRepository.logout();
ApiClient.instance.removeAuthToken();
```

---

## 🔄 Flujo Completo de una Petición

```
1. UI Layer (Widget/Screen)
   │
   ├─> Llama al método del BLoC
   │
2. BLoC Layer
   │
   ├─> Llama al método del Repository
   │
3. Repository Layer
   │
   ├─> Llama al ApiClient con el endpoint
   │
4. ApiClient
   │
   ├─> Ejecuta interceptor onRequest
   │   (Agrega headers, logs)
   │
   ├─> Envía petición HTTP (Dio)
   │
   ├─> Recibe respuesta
   │
   ├─> Ejecuta interceptor onResponse
   │   (Logs, procesamiento)
   │
   ├─> Si hay error, ejecuta interceptor onError
   │   (Convierte a ApiException)
   │
   └─> Retorna Response o lanza ApiException
   │
5. Repository procesa respuesta
   │
   └─> Retorna ApiResponse<T>
   │
6. BLoC actualiza estado
   │
7. UI actualiza vista
```

---

## 📝 Notas Adicionales

### Agregar Nuevos Endpoints

1. Agrega la constante en [api_endpoints.dart](lib/core/constants/api_endpoints.dart)
2. Crea o actualiza el repository correspondiente
3. Implementa el método en el repository usando `ApiClient`

### Personalizar Headers por Petición

```dart
final response = await ApiClient.instance.get(
  ApiEndpoints.someEndpoint,
  headers: {
    'Custom-Header': 'value',
  },
);
```

### Cambiar Base URL Dinámicamente

```dart
ApiClient.instance.updateBaseUrl('https://new-api.com');
```

### Debugging

- Los logs del interceptor muestran:
  - ⬆️ Peticiones salientes
  - ⬇️ Respuestas recibidas
  - ❌ Errores

---

## 🚀 Próximos Pasos

1. Implementar manejo de refresh token automático
2. Agregar caché de respuestas
3. Implementar retry logic para peticiones fallidas
4. Agregar tests unitarios para repositories
5. Implementar mockeo del API client para testing

---

## 📞 Contacto y Soporte

Para dudas o problemas con la implementación del API, contacta al equipo de desarrollo.

---

**Última actualización:** 2025-01-21
