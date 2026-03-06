/// Repositorio para transacciones P2P y PDE
/// Maneja historial de transacciones y movimientos de energía
library;

import 'package:be_energy/models/home_data_models.dart';

/// Interfaz abstracta para el repositorio de transacciones
abstract class TransactionRepository {
  /// Obtiene las transacciones recientes de un usuario
  ///
  /// [period] - Período en formato 'YYYY-MM'
  /// [userId] - ID del usuario
  /// [limit] - Número máximo de transacciones a retornar
  Future<List<TransactionItem>> getRecentTransactions({
    required String period,
    required int userId,
    int limit = 5,
  });

  /// Obtiene todas las transacciones de un usuario en un período
  ///
  /// [period] - Período en formato 'YYYY-MM'
  /// [userId] - ID del usuario
  Future<List<TransactionItem>> getAllTransactions({
    required String period,
    required int userId,
  });

  /// Obtiene el detalle de una transacción específica
  ///
  /// [transactionId] - ID de la transacción
  Future<TransactionItem?> getTransactionDetail({
    required int transactionId,
  });

  /// Obtiene el balance de transacciones (ingresos vs egresos)
  ///
  /// [period] - Período en formato 'YYYY-MM'
  /// [userId] - ID del usuario
  Future<Map<String, double>> getTransactionBalance({
    required String period,
    required int userId,
  });
}
