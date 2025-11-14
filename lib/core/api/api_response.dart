/// Clase genérica para manejar respuestas del API
/// Proporciona una estructura consistente para todas las respuestas
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final List<String>? errors;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.statusCode,
  });

  /// Constructor para respuestas exitosas
  factory ApiResponse.success({
    required T data,
    String? message,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message ?? 'Operación exitosa',
      statusCode: statusCode ?? 200,
    );
  }

  /// Constructor para respuestas con error
  factory ApiResponse.error({
    required String message,
    List<String>? errors,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
      statusCode: statusCode,
    );
  }

  /// Constructor desde JSON genérico
  /// Espera una estructura como:
  /// {
  ///   "status": true,
  ///   "message": "Success",
  ///   "data": {...}
  /// }
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    final success = json['status'] ?? json['success'] ?? false;
    final message = json['message'] ?? json['msg'];
    final data = json['data'];
    final errors = json['errors'] != null
        ? List<String>.from(json['errors'])
        : null;
    final statusCode = json['statusCode'];

    return ApiResponse<T>(
      success: success,
      message: message,
      data: fromJsonT != null && data != null ? fromJsonT(data) : data,
      errors: errors,
      statusCode: statusCode,
    );
  }

  /// Constructor para listas desde JSON
  /// Útil cuando la respuesta es una lista de elementos
  factory ApiResponse.fromJsonList(
    Map<String, dynamic> json,
    T Function(List<dynamic>) fromJsonT,
  ) {
    final success = json['status'] ?? json['success'] ?? false;
    final message = json['message'] ?? json['msg'];
    final data = json['data'];
    final errors = json['errors'] != null
        ? List<String>.from(json['errors'])
        : null;
    final statusCode = json['statusCode'];

    return ApiResponse<T>(
      success: success,
      message: message,
      data: data is List ? fromJsonT(data) : null,
      errors: errors,
      statusCode: statusCode,
    );
  }

  /// Convierte la respuesta a JSON
  Map<String, dynamic> toJson([Map<String, dynamic> Function(T)? toJsonT]) {
    return {
      'success': success,
      'message': message,
      'data': toJsonT != null && data != null ? toJsonT(data as T) : data,
      'errors': errors,
      'statusCode': statusCode,
    };
  }

  /// Verifica si la respuesta tiene datos
  bool get hasData => data != null;

  /// Verifica si la respuesta tiene errores
  bool get hasErrors => errors != null && errors!.isNotEmpty;

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, data: $data, errors: $errors, statusCode: $statusCode)';
  }
}

/// Clase para respuestas paginadas
class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  /// Constructor desde JSON
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final dataList = json['data'] as List? ?? [];
    final currentPage = json['currentPage'] ?? json['current_page'] ?? 1;
    final totalPages = json['totalPages'] ?? json['total_pages'] ?? 1;
    final totalItems = json['totalItems'] ?? json['total_items'] ?? 0;
    final itemsPerPage = json['itemsPerPage'] ?? json['items_per_page'] ?? 10;

    return PaginatedResponse<T>(
      data: dataList.map((item) => fromJsonT(item as Map<String, dynamic>)).toList(),
      currentPage: currentPage,
      totalPages: totalPages,
      totalItems: totalItems,
      itemsPerPage: itemsPerPage,
      hasNextPage: currentPage < totalPages,
      hasPreviousPage: currentPage > 1,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'data': data.map((item) => toJsonT(item)).toList(),
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalItems': totalItems,
      'itemsPerPage': itemsPerPage,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
    };
  }

  @override
  String toString() {
    return 'PaginatedResponse(data: ${data.length} items, currentPage: $currentPage/$totalPages, totalItems: $totalItems)';
  }
}
