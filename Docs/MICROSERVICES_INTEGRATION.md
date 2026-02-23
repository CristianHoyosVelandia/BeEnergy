# Guía de Integración de Microservicios - BeEnergy

Esta guía explica cómo integrar los microservicios del backend con el frontend Flutter, alineados con las Historias de Usuario (HU-01 a HU-22).

## Microservicios y HU cubiertas (Arquitectura Hexagonal)

| Servicio | HU | Estructura | Repositorio Frontend |
|----------|-----|------------|---------------------|
| **auth_service** | HU-01 a HU-07 | domain/ports, adapters/http, adapters/persistence | AuthRepository |
| **user_service** | HU-08, HU-09 | domain/ports, adapters | UserRepository |
| **energy_credits_service** | HU-10, HU-11 | domain/entities, domain/ports, CreditsRepositorySQL | CreditsRepository |
| **transaction_service** | HU-12 a HU-17 | domain/entities, domain/ports, repos implementan ports | TransactionRepository |
| **monitoring_service** | HU-18, HU-19 | domain/entities, ports/repository, SQLAlchemyRepository | - |
| **audit_service** | HU-20, HU-21, HU-22 | domain/entities, domain/ports, AuditRepositorySQL | AuditRepository |

## Resumen de la arquitectura

El frontend soporta **dos modos** de integración:

| Modo | Descripción | Configuración |
|------|-------------|---------------|
| **API Gateway** | Un solo punto de entrada que enruta a todos los microservicios | `GATEWAY_URL` en `.env` |
| **Microservicios directos** | Cada servicio tiene su propia URL | `AUTH_SERVICE_URL`, `USER_SERVICE_URL`, etc. |

---

## Paso 1: Configurar las URLs

Copia `.env.example` a `.env` y configura según tu arquitectura.

### Opción A: Con API Gateway

```env
GATEWAY_URL=https://api.beenergy.com

# Opcional: Empresas puede ser externo (ej: Kupi)
EMPRESAS_SERVICE_URL=https://kupi.com.co/ws

APP_CODE=0
APP_VERSION=6.5.5
DEFAULT_CITY_CODE=4110
```

### Opción B: Microservicios independientes

```env
AUTH_SERVICE_URL=https://auth.beenergy.com
USER_SERVICE_URL=https://user.beenergy.com
ENERGY_SERVICE_URL=https://energy.beenergy.com
TRADING_SERVICE_URL=https://trading.beenergy.com
NOTIFICATIONS_SERVICE_URL=https://notifications.beenergy.com
LOCATION_SERVICE_URL=https://location.beenergy.com
PAYMENT_SERVICE_URL=https://payment.beenergy.com
EMPRESAS_SERVICE_URL=https://kupi.com.co/ws

APP_CODE=0
APP_VERSION=6.5.5
DEFAULT_CITY_CODE=4110
```

### Opción C: Desarrollo local (puertos diferentes)

```env
AUTH_SERVICE_URL=http://localhost:3001
ENERGY_SERVICE_URL=http://localhost:3002
TRADING_SERVICE_URL=http://localhost:3003
EMPRESAS_SERVICE_URL=https://kupi.com.co/ws
```

---

## Paso 2: Mapeo de Repositorios → Microservicios

| Repositorio | Microservicio | Endpoints principales |
|-------------|---------------|------------------------|
| `AuthRepository` | `auth` | `/auth/login`, `/auth/register` |
| `EnergyRepository` | `energy` | `/energy/data`, `/energy/history` |
| `EmpresasRepository` | `empresas` | `/getEmpresas` (Kupi) |

---

## Paso 3: Crear un nuevo Repositorio para tu microservicio

1. **Agregar la URL** en `.env`:
   ```env
   MI_SERVICIO_URL=https://mi-servicio.com
   ```

2. **Agregar el microservicio** en `lib/core/constants/microservice_config.dart`:
   ```dart
   enum Microservice {
     // ... existentes
     miServicio,  // nuevo
   }

   // En getBaseUrl(), agregar:
   case Microservice.miServicio:
     return _ensureNoTrailingSlash(
       dotenv.env['MI_SERVICIO_URL'] ?? _defaultBase,
     );
   ```

3. **Crear el Repositorio** en `lib/repositories/`:
   ```dart
   // lib/repositories/mi_servicio_repository.dart

   import '../core/api/api_client.dart';
   import '../core/constants/microservice_config.dart';

   class MiServicioRepository {
     final ApiClient _apiClient = ApiClient.instance;

     Future<Response> getDatos() async {
       return _apiClient.getFromService(
         Microservice.miServicio,
         '/ruta/del/endpoint',
         queryParameters: {'param': 'valor'},
       );
     }

     Future<Response> crearRecurso(Map<String, dynamic> data) async {
       return _apiClient.postFromService(
         Microservice.miServicio,
         '/ruta/crear',
         data: data,
       );
     }
   }
   ```

---

## Paso 4: Métodos disponibles en ApiClient

Para cada microservicio puedes usar:

- `getFromService(service, endpoint, {...})`
- `postFromService(service, endpoint, data: {...}, {...})`
- `putFromService(service, endpoint, data: {...}, {...})`
- `patchFromService(service, endpoint, data: {...}, {...})`
- `deleteFromService(service, endpoint, {...})`

Todos heredan el token de autenticación (`setAuthToken`) y los headers del interceptor (`codApp`, `codVersion`, `codCiudad`).

---

## Paso 5: CORS y autenticación

### CORS
Si los microservicios están en dominios distintos, asegúrate de configurar CORS en cada uno para aceptar requests desde el origen de tu app.

### Token JWT
Después del login, el `AuthRepository` llama a `ApiClient.instance.setAuthToken(token)`. Ese token se envía automáticamente en **todas** las peticiones a **todos** los microservicios.

---

## Migración desde el código legacy

El código legacy (`ApiBe`, `RespositoryBe`) ha sido reemplazado por `EmpresasRepository`, que usa la nueva arquitectura. Si tienes más APIs legacy:

1. Crea un repositorio que use `getFromService` / `postFromService`
2. Actualiza el BLoC o pantalla para usar el nuevo repositorio
3. Elimina el código legacy cuando todo funcione

---

## Estructura de archivos relacionada

```
lib/
├── core/
│   ├── api/
│   │   └── api_client.dart       # getFromService, postFromService, etc.
│   └── constants/
│       ├── api_endpoints.dart    # Rutas de endpoints
│       └── microservice_config.dart  # Configuración de URLs
└── repositories/
    ├── auth_repository.dart
    ├── energy_repository.dart
    └── empresas_repository.dart
```

---

## Próximos pasos sugeridos

1. Crear repositorios para Trading, Notificaciones y User si aún no existen
2. Implementar refresh token automático en el interceptor
3. Agregar retry logic para peticiones fallidas
4. Configurar diferentes `.env` para desarrollo/staging/producción
