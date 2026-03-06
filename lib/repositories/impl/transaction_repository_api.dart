/// Implementación API del repositorio de transacciones
/// Consume endpoints reales del backend
library;

import 'package:be_energy/core/api/api_client.dart';
import 'package:be_energy/core/constants/api_endpoints.dart';
import 'package:be_energy/models/home_data_models.dart';
import 'package:be_energy/repositories/domain/transaction_repository.dart';

/// Implementación con API real para transacciones
class TransactionRepositoryApi implements TransactionRepository {
  final ApiClient _client = ApiClient.instance;

  @override
  Future<List<TransactionItem>> getRecentTransactions({
    required String period,
    required int userId,
    int limit = 5,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.userTransactions,
        queryParameters: {
          'period': period,
          'user_id': userId,
          'limit': limit,
        },
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => TransactionItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<TransactionItem>> getAllTransactions({
    required String period,
    required int userId,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.userTransactions,
        queryParameters: {
          'period': period,
          'user_id': userId,
        },
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => TransactionItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TransactionItem?> getTransactionDetail({
    required int transactionId,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.getTransactionById(transactionId.toString()),
      );

      if (response.data == null) {
        return null;
      }

      return TransactionItem.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Map<String, double>> getTransactionBalance({
    required String period,
    required int userId,
  }) async {
    try {
      final response = await _client.get(
        '${ApiEndpoints.userTransactions}/balance',
        queryParameters: {
          'period': period,
          'user_id': userId,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return {
        'income': (data['income'] as num).toDouble(),
        'expense': (data['expense'] as num).toDouble(),
        'balance': (data['balance'] as num).toDouble(),
      };
    } catch (e) {
      rethrow;
    }
  }
}
