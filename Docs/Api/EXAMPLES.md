# Ejemplos de Uso del API

Esta guía proporciona ejemplos prácticos de cómo usar el sistema de API implementado en Be Energy.

## 📋 Contenido

1. [Autenticación](#autenticación)
2. [Operaciones CRUD](#operaciones-crud)
3. [Manejo de Errores Avanzado](#manejo-de-errores-avanzado)
4. [Integración con BLoC](#integración-con-bloc)
5. [Respuestas Paginadas](#respuestas-paginadas)
6. [Upload de Archivos](#upload-de-archivos)
7. [Peticiones Concurrentes](#peticiones-concurrentes)

---

## 🔐 Autenticación

### Login Completo con Manejo de Estado

```dart
import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';
import '../core/api/api_exceptions.dart';
import '../data/database_Helper.dart';
import '../models/my_user.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authRepository = AuthRepository();
  final _dbHelper = DatabaseHelper();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      final response = await _authRepository.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.success && response.data != null) {
        // Guardar usuario en base de datos local
        final user = MyUser(
          idUser: int.parse(response.data!['idUser']),
          nombre: response.data!['nombre'],
          correo: response.data!['correo'],
          energia: response.data!['energia'],
          dinero: response.data!['dinero'],
          telefono: response.data!['telefono'],
          idCiudad: int.parse(response.data!['idCiudad']),
        );

        await _dbHelper.addUser(user);

        // Redirigir a home
        Navigator.pushReplacementNamed(context, 'home');
      } else {
        _showError('Error al iniciar sesión');
      }
    } on UnauthorizedException catch (e) {
      _showError('Correo o contraseña incorrectos');
    } on ApiException catch (e) {
      _showError(e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleLogin,
                    child: Text('Iniciar Sesión'),
                  ),
          ],
        ),
      ),
    );
  }
}
```

### Registro de Usuario

```dart
Future<void> registerUser() async {
  final authRepository = AuthRepository();

  try {
    final response = await authRepository.register(
      nombre: 'Juan Pérez',
      email: 'juan@example.com',
      password: 'password123',
      telefono: '3001234567',
      idCiudad: 4110,
    );

    if (response.success) {
      print('Usuario registrado exitosamente');
      // Redirigir a login o home
    }
  } on UnprocessableEntityException catch (e) {
    print('Error de validación: ${e.message}');
    // Mostrar errores específicos de campos
    if (e.data != null && e.data['errors'] != null) {
      final errors = e.data['errors'] as Map<String, dynamic>;
      errors.forEach((field, messages) {
        print('$field: $messages');
      });
    }
  } on ApiException catch (e) {
    print('Error al registrar: ${e.message}');
  }
}
```

### Cerrar Sesión

```dart
Future<void> handleLogout(BuildContext context) async {
  final authRepository = AuthRepository();
  final dbHelper = DatabaseHelper();

  try {
    // Llamar al API
    await authRepository.logout();

    // Limpiar base de datos local
    final user = await dbHelper.getUser();
    if (user.idUser != 0) {
      await dbHelper.deleteUserLocal(user.idUser);
    }

    // Redirigir a login
    Navigator.pushReplacementNamed(context, 'login');
  } on ApiException catch (e) {
    print('Error al cerrar sesión: ${e.message}');
  }
}
```

---

## 🔄 Operaciones CRUD

### Crear un Repository Completo (Trading)

```dart
// lib/repositories/trading_repository.dart

import '../core/api/api_client.dart';
import '../core/api/api_response.dart';
import '../core/api/api_exceptions.dart';
import '../core/constants/api_endpoints.dart';

class TradingRepository {
  final ApiClient _apiClient = ApiClient.instance;

  // CREATE
  Future<ApiResponse<Map<String, dynamic>>> createTransaction({
    required double amount,
    required String type,
    required int recipientId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.createTransaction,
        data: {
          'amount': amount,
          'type': type,
          'recipientId': recipientId,
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

  // READ (List)
  Future<ApiResponse<List<Map<String, dynamic>>>> getUserTransactions({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final response = await _apiClient.get(
        ApiEndpoints.userTransactions,
        queryParameters: queryParams,
      );

      return ApiResponse.fromJsonList(
        response.data,
        (data) => List<Map<String, dynamic>>.from(data),
      );
    } on ApiException {
      rethrow;
    }
  }

  // READ (Single)
  Future<ApiResponse<Map<String, dynamic>>> getTransactionById(String id) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.getTransactionById(id),
      );

      return ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
    } on ApiException {
      rethrow;
    }
  }

  // DELETE
  Future<ApiResponse<void>> cancelTransaction(String id) async {
    try {
      final response = await _apiClient.delete(
        ApiEndpoints.cancelTransaction(id),
      );

      return ApiResponse.fromJson(
        response.data,
        (_) => null,
      );
    } on ApiException {
      rethrow;
    }
  }
}
```

---

## ⚠️ Manejo de Errores Avanzado

### Widget con Manejo Completo de Errores

```dart
import 'package:flutter/material.dart';
import '../repositories/energy_repository.dart';
import '../core/api/api_exceptions.dart';

class EnergyDataWidget extends StatefulWidget {
  @override
  _EnergyDataWidgetState createState() => _EnergyDataWidgetState();
}

class _EnergyDataWidgetState extends State<EnergyDataWidget> {
  final _repository = EnergyRepository();
  Map<String, dynamic>? _energyData;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEnergyData();
  }

  Future<void> _loadEnergyData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _repository.getEnergyData();

      if (response.success && response.data != null) {
        setState(() {
          _energyData = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Error desconocido';
          _isLoading = false;
        });
      }
    } on UnauthorizedException catch (e) {
      setState(() {
        _errorMessage = 'Sesión expirada. Por favor, inicia sesión de nuevo.';
        _isLoading = false;
      });
      // Redirigir a login
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, 'login');
      });
    } on NotFoundException catch (e) {
      setState(() {
        _errorMessage = 'No se encontraron datos de energía.';
        _isLoading = false;
      });
    } on InternalServerException catch (e) {
      setState(() {
        _errorMessage = 'Error del servidor. Intenta más tarde.';
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });

      // Log para debugging
      print('Error Code: ${e.statusCode}');
      print('Error Data: ${e.data}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(_errorMessage!),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEnergyData,
              child: Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_energyData == null) {
      return Center(child: Text('No hay datos disponibles'));
    }

    return ListView(
      children: [
        ListTile(
          title: Text('Energía Disponible'),
          subtitle: Text('${_energyData!['energia']} kWh'),
        ),
        // ... más datos
      ],
    );
  }
}
```

---

## 🔄 Integración con BLoC

### Energy BLoC Completo

```dart
// lib/bloc/energy_bloc.dart

import 'package:bloc_provider/bloc_provider.dart';
import 'package:rxdart/rxdart.dart';
import '../repositories/energy_repository.dart';
import '../core/api/api_exceptions.dart';

class EnergyBloc extends Bloc {
  final EnergyRepository _repository = EnergyRepository();

  // Streams
  final _energyDataController = BehaviorSubject<Map<String, dynamic>?>();
  final _loadingController = BehaviorSubject<bool>.seeded(false);
  final _errorController = BehaviorSubject<String?>();

  // Getters de streams
  Stream<Map<String, dynamic>?> get energyDataStream => _energyDataController.stream;
  Stream<bool> get loadingStream => _loadingController.stream;
  Stream<String?> get errorStream => _errorController.stream;

  // Getters de valores actuales
  Map<String, dynamic>? get currentEnergyData => _energyDataController.valueOrNull;
  bool get isLoading => _loadingController.value;

  /// Carga los datos de energía
  Future<void> loadEnergyData() async {
    _loadingController.add(true);
    _errorController.add(null);

    try {
      final response = await _repository.getEnergyData();

      if (response.success && response.data != null) {
        _energyDataController.add(response.data);
      } else {
        _errorController.add(response.message ?? 'Error desconocido');
      }
    } on UnauthorizedException catch (e) {
      _errorController.add('Sesión expirada');
      // Aquí podrías emitir un evento para redirigir a login
    } on ApiException catch (e) {
      _errorController.add(e.message);
    } finally {
      _loadingController.add(false);
    }
  }

  /// Obtiene el historial de energía
  Future<void> loadEnergyHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _loadingController.add(true);
    _errorController.add(null);

    try {
      final response = await _repository.getEnergyHistory(
        startDate: startDate,
        endDate: endDate,
      );

      if (response.success && response.data != null) {
        // Procesar historial
        print('Historial cargado: ${response.data?.length} registros');
      }
    } on ApiException catch (e) {
      _errorController.add(e.message);
    } finally {
      _loadingController.add(false);
    }
  }

  @override
  void dispose() {
    _energyDataController.close();
    _loadingController.close();
    _errorController.close();
  }
}
```

### Uso del BLoC en Widget

```dart
import 'package:flutter/material.dart';
import 'package:bloc_provider/bloc_provider.dart';
import '../bloc/energy_bloc.dart';

class EnergyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<EnergyBloc>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Energía')),
      body: StreamBuilder<bool>(
        stream: bloc.loadingStream,
        builder: (context, loadingSnapshot) {
          if (loadingSnapshot.data == true) {
            return Center(child: CircularProgressIndicator());
          }

          return StreamBuilder<String?>(
            stream: bloc.errorStream,
            builder: (context, errorSnapshot) {
              if (errorSnapshot.hasData && errorSnapshot.data != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorSnapshot.data!),
                      ElevatedButton(
                        onPressed: () => bloc.loadEnergyData(),
                        child: Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              return StreamBuilder<Map<String, dynamic>?>(
                stream: bloc.energyDataStream,
                builder: (context, dataSnapshot) {
                  if (!dataSnapshot.hasData) {
                    return Center(child: Text('No hay datos'));
                  }

                  final data = dataSnapshot.data!;
                  return ListView(
                    children: [
                      ListTile(
                        title: Text('Energía'),
                        subtitle: Text('${data['energia']} kWh'),
                      ),
                      // ... más datos
                    ],
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => bloc.loadEnergyData(),
        child: Icon(Icons.refresh),
      ),
    );
  }
}
```

---

## 📄 Respuestas Paginadas

### Repository con Paginación

```dart
import '../core/api/api_client.dart';
import '../core/api/api_response.dart';
import '../core/api/api_exceptions.dart';

class NotificationsRepository {
  final ApiClient _apiClient = ApiClient.instance;

  Future<PaginatedResponse<Map<String, dynamic>>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/notifications',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      return PaginatedResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json,
      );
    } on ApiException {
      rethrow;
    }
  }
}
```

### Widget con Scroll Infinito

```dart
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _repository = NotificationsRepository();
  final _scrollController = ScrollController();

  List<Map<String, dynamic>> _notifications = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.8) {
        if (!_isLoading && _hasMore) {
          _loadMoreNotifications();
        }
      }
    });
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    try {
      final response = await _repository.getNotifications(page: 1);

      setState(() {
        _notifications = response.data.cast<Map<String, dynamic>>();
        _currentPage = 1;
        _hasMore = response.hasNextPage;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      print('Error: ${e.message}');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreNotifications() async {
    setState(() => _isLoading = true);

    try {
      final response = await _repository.getNotifications(
        page: _currentPage + 1,
      );

      setState(() {
        _notifications.addAll(response.data.cast<Map<String, dynamic>>());
        _currentPage++;
        _hasMore = response.hasNextPage;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      print('Error: ${e.message}');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notificaciones')),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _notifications.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= _notifications.length) {
              return Center(child: CircularProgressIndicator());
            }

            final notification = _notifications[index];
            return ListTile(
              title: Text(notification['title'] ?? ''),
              subtitle: Text(notification['message'] ?? ''),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

---

## 📤 Upload de Archivos

```dart
import 'package:dio/dio.dart';
import '../core/api/api_client.dart';

class ProfileRepository {
  final ApiClient _apiClient = ApiClient.instance;

  Future<void> uploadProfileImage(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: 'profile.jpg',
        ),
      });

      final response = await _apiClient.dio.post(
        '/user/upload-image',
        data: formData,
      );

      print('Imagen subida: ${response.data}');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
```

---

## 🔀 Peticiones Concurrentes

```dart
Future<void> loadDashboardData() async {
  try {
    // Ejecutar múltiples peticiones en paralelo
    final results = await Future.wait([
      _energyRepository.getEnergyData(),
      _tradingRepository.getUserTransactions(),
      _notificationsRepository.getNotifications(),
    ]);

    final energyData = results[0];
    final transactions = results[1];
    final notifications = results[2];

    print('Todos los datos cargados');
  } on ApiException catch (e) {
    print('Error: ${e.message}');
  }
}
```

---

## 🎯 Tips Adicionales

### Retry Logic

```dart
Future<T> retryRequest<T>(
  Future<T> Function() request, {
  int maxRetries = 3,
  Duration delay = const Duration(seconds: 2),
}) async {
  int attempts = 0;

  while (attempts < maxRetries) {
    try {
      return await request();
    } on ApiException catch (e) {
      attempts++;

      if (attempts >= maxRetries) {
        rethrow;
      }

      print('Intento $attempts falló. Reintentando en ${delay.inSeconds}s...');
      await Future.delayed(delay);
    }
  }

  throw Exception('Max retries reached');
}

// Uso
final response = await retryRequest(() => repository.getData());
```

### Timeout Personalizado

```dart
final response = await ApiClient.instance.dio.get(
  '/endpoint',
  options: Options(
    receiveTimeout: Duration(seconds: 10),
    sendTimeout: Duration(seconds: 10),
  ),
);
```

---

**Última actualización:** 2025-01-21
