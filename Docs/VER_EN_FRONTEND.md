# Cómo ver los microservicios en el frontend BeEnergy

## 1. Configurar el archivo `.env`

Copia `.env.example` a `.env` y ajusta las URLs según dónde corran tus microservicios:

```bash
# En la carpeta Frontend/BeEnergy
copy .env.example .env
# (o: cp .env.example .env en Linux/Mac)
```

Edita `.env` y configura las URLs. **Importante**: si ejecutas Flutter en **emulador Android** o **dispositivo físico**, `localhost` no funcionará porque se refiere al dispositivo, no a tu PC.

| Entorno        | Host a usar                          |
|----------------|--------------------------------------|
| Emulador Android | `10.0.2.2` (alias del host)        |
| iOS Simulator  | `localhost` o `127.0.0.1`           |
| Dispositivo físico | IP de tu PC en la red (ej: `192.168.1.100`) |

**Ejemplo para emulador Android** (microservicios en tu PC en puertos 8000-8005):

```env
AUTH_SERVICE_URL=http://10.0.2.2:8000
USER_SERVICE_URL=http://10.0.2.2:8001
CREDITS_SERVICE_URL=http://10.0.2.2:8002
TRADING_SERVICE_URL=http://10.0.2.2:8003
MONITORING_SERVICE_URL=http://10.0.2.2:8004
AUDIT_SERVICE_URL=http://10.0.2.2:8005
EMPRESAS_SERVICE_URL=https://kupi.com.co/ws
BASE_URL=http://10.0.2.2:8000
APP_CODE=0
APP_VERSION=6.5.5
DEFAULT_CITY_CODE=4110
```

**Ejemplo para dispositivo físico** (reemplaza `192.168.1.100` por la IP de tu PC):

```env
AUTH_SERVICE_URL=http://192.168.1.100:8000
USER_SERVICE_URL=http://192.168.1.100:8001
# ... resto igual
```

---

## 2. Levantar los microservicios

En terminales separadas, ejecuta cada microservicio en su puerto:

```bash
# Terminal 1 - Auth (puerto 8000)
cd Backend/auth_service
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000

# Terminal 2 - User (puerto 8001)
cd Backend/user_service
python -m uvicorn app.main:app --host 0.0.0.0 --port 8001

# Terminal 3 - Credits (puerto 8002)
cd Backend/energy_credits_service
python -m uvicorn app.main:app --host 0.0.0.0 --port 8002

# Terminal 4 - Trading/Transacciones (puerto 8003)
cd Backend/transaction_service
python -m uvicorn app.main:app --host 0.0.0.0 --port 8003

# Terminal 5 - Monitoring (puerto 8004)
cd Backend/monitoring_service
python -m uvicorn app.main:app --host 0.0.0.0 --port 8004

# Terminal 6 - Audit (puerto 8005)
cd Backend/audit_service
python -m uvicorn app.main:app --host 0.0.0.0 --port 8005
```

Usa `--host 0.0.0.0` para que acepten peticiones desde la red (emulador/dispositivo).

---

## 3. Ejecutar el frontend Flutter

```bash
cd Frontend/BeEnergy
flutter pub get
flutter run
```

---

## 4. Dónde se usa cada microservicio en la app

| Pantalla / Funcionalidad | Microservicio | Repositorio | Qué ves |
|--------------------------|---------------|-------------|---------|
| **Login** | auth_service | AuthRepository | Login, registro, recuperar clave |
| **Mi cuenta / Perfil** | user_service | UserRepository | Datos del usuario |
| **Energía** | energy_credits_service | CreditsRepository | Saldo en kWh |
| **Trading / Intercambios** | transaction_service | TransactionRepository | Ofertas, transacciones P2P |
| **Empresas** | Kupi (empresas) | EmpresasRepository | Lista de empresas |
| **Auditoría** | audit_service | AuditRepository | Logs y reportes (admin) |
| **Monitoreo** | monitoring_service | - | Telemetría y alertas (HU-18, HU-19) |

La pantalla **Energía** (`EnergyScreen`) ya consume el saldo de créditos del `energy_credits_service`. El **Login** usa `auth_service` y **Mi cuenta** usa `user_service`.

---

## 5. Verificar que todo responde

Antes de abrir la app, prueba en el navegador o con curl que los servicios responden:

- `http://10.0.2.2:8000/docs` (Auth - Swagger)
- `http://10.0.2.2:8002/docs` (Credits)
- etc.

Si usas emulador Android, sustituye `10.0.2.2` por la IP de tu PC cuando lo ejecutes en el navegador del PC.

---

## 6. Si algo no carga

1. **CORS**: Todos los microservicios BeEnergy ya tienen CORS habilitado (allow_origins=["*"]) para desarrollo. Si ves errores de CORS en Flutter Web, reinicia los microservicios tras actualizar el código.
2. **Firewall**: Asegúrate de que el firewall de Windows no bloquea los puertos 8000–8005.
3. **Misma red**: Si usas dispositivo físico, el teléfono y la PC deben estar en la misma red Wi‑Fi.
4. **Token**: Tras el login, el token se envía automáticamente en todas las peticiones. Si no hay usuario logueado, algunas rutas fallarán.
5. **.env no se carga**: Si ves URLs vacías o fallos, verifica que existe el archivo `.env` en `Frontend/BeEnergy` y que está en `pubspec.yaml` en assets. Tras cambiar `.env`, ejecuta `flutter clean && flutter pub get`.

---

## 7. Próximos pasos

Para ver **monitoreo** (telemetría, alertas) y **auditoría** (logs, reportes) en la app:

1. Crear `MonitoringRepository` que llame a `monitoring_service` (`/telemetry/latest`, `/alerts`, etc.).
2. Crear pantallas o secciones en Configuración/Admin que usen `AuditRepository` para mostrar logs y reportes.
3. Conectar la pantalla de **Notificaciones** con alertas del `monitoring_service` si aplica.
