// ignore_for_file: depend_on_referenced_packages

import 'package:dio/dio.dart';

/// Clase base para todas las excepciones del API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  /// Crea una ApiException desde un DioException
  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(
          message: 'No se pudo conectar al servidor (timeout). Comprueba: 1) Backend en marcha con uvicorn --host 0.0.0.0 --port 8000. 2) Firewall permite el puerto 8000. 3) Dispositivo y PC en la misma red.',
          statusCode: null,
        );

      case DioExceptionType.sendTimeout:
        return ApiException(
          message: 'Tiempo de envío agotado. Por favor, intenta de nuevo.',
          statusCode: null,
        );

      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Tiempo de respuesta agotado. El servidor está tardando mucho en responder.',
          statusCode: null,
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);

      case DioExceptionType.cancel:
        return ApiException(
          message: 'La petición fue cancelada.',
          statusCode: null,
        );

      case DioExceptionType.connectionError:
        return ApiException(
          message: 'No se pudo conectar al servidor. Verifica que el servicio esté en marcha y que la URL en .env sea correcta (en emulador Android usa 10.0.2.2 en lugar de localhost).',
          statusCode: null,
        );

      case DioExceptionType.unknown:
        final msg = error.message ?? '';
        if (msg.contains('SocketException') ||
            msg.contains('Connection refused') ||
            msg.contains('Failed host lookup') ||
            msg.contains('Network is unreachable')) {
          return ApiException(
            message: 'No se pudo conectar al servidor. ¿Está el backend en marcha? Revisa la URL en .env (en Android emulador usa 10.0.2.2).',
            statusCode: null,
          );
        }
        return ApiException(
          message: msg.isNotEmpty ? 'Error: $msg' : 'Error inesperado. Verifica tu configuración.',
          statusCode: null,
        );

      default:
        return ApiException(
          message: 'Error desconocido. Por favor, intenta de nuevo.',
          statusCode: null,
        );
    }
  }

  /// Maneja respuestas con errores HTTP
  static ApiException _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    switch (statusCode) {
      case 400:
        return BadRequestException(
          message: _extractMessage(data) ?? 'Petición incorrecta.',
          statusCode: statusCode,
          data: data,
        );

      case 401:
        return UnauthorizedException(
          message: _extractMessage(data) ?? 'No autorizado. Por favor, inicia sesión.',
          statusCode: statusCode,
          data: data,
        );

      case 403:
        return ForbiddenException(
          message: _extractMessage(data) ?? 'Acceso prohibido. No tienes permisos para realizar esta acción.',
          statusCode: statusCode,
          data: data,
        );

      case 404:
        return NotFoundException(
          message: _extractMessage(data) ?? 'Recurso no encontrado.',
          statusCode: statusCode,
          data: data,
        );

      case 422:
        return UnprocessableEntityException(
          message: _extractMessage(data) ?? 'Datos no válidos.',
          statusCode: statusCode,
          data: data,
        );

      case 500:
        return InternalServerException(
          message: _extractMessage(data) ?? 'Error interno del servidor.',
          statusCode: statusCode,
          data: data,
        );

      case 503:
        return ServiceUnavailableException(
          message: _extractMessage(data) ?? 'Servicio no disponible. Por favor, intenta más tarde.',
          statusCode: statusCode,
          data: data,
        );

      default:
        return ApiException(
          message: _extractMessage(data) ?? 'Error del servidor (${statusCode ?? 'Desconocido'}).',
          statusCode: statusCode,
          data: data,
        );
    }
  }

  /// Extrae el mensaje de error desde la respuesta del servidor
  static String? _extractMessage(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      // Intenta extraer el mensaje de diferentes estructuras comunes
      return data['message'] ??
             data['error'] ??
             data['msg'] ??
             data['detail'];
    }

    if (data is String) {
      return data;
    }

    return null;
  }

  @override
  String toString() {
    return 'ApiException: $message ${statusCode != null ? '(Status: $statusCode)' : ''}';
  }
}

/// Excepción para errores 400 - Bad Request
class BadRequestException extends ApiException {
  BadRequestException({
    required super.message,
    super.statusCode,
    super.data,
  });
}


/// Excepción para errores 401 - Unauthorized
class UnauthorizedException extends ApiException {
  UnauthorizedException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

/// Excepción para errores 403 - Forbidden
class ForbiddenException extends ApiException {
  ForbiddenException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

/// Excepción para errores 404 - Not Found
class NotFoundException extends ApiException {
  NotFoundException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

/// Excepción para errores 422 - Unprocessable Entity
class UnprocessableEntityException extends ApiException {
  UnprocessableEntityException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

/// Excepción para errores 500 - Internal Server Error
class InternalServerException extends ApiException {
  InternalServerException({
    required super.message,
    super.statusCode,
    super.data,
  });
}

/// Excepción para errores 503 - Service Unavailable
class ServiceUnavailableException extends ApiException {
  ServiceUnavailableException({
    required super.message,
    super.statusCode,
    super.data,
  });
}
