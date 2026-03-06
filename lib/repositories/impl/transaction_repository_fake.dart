/// Implementación fake del repositorio de transacciones
library;

import 'package:be_energy/data/fake_data.dart';
import 'package:be_energy/data/fake_data_phase2.dart';
import 'package:be_energy/models/home_data_models.dart';
import 'package:be_energy/repositories/domain/transaction_repository.dart';

/// Implementación con fake data para transacciones
class TransactionRepositoryFake implements TransactionRepository {
  @override
  Future<List<TransactionItem>> getRecentTransactions({
    required String period,
    required int userId,
    int limit = 5,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));

    // Enero 2026: ingreso por PDE del consumidor
    if (period == '2026-01') {
      final pde = FakeDataPhase2.pdeDec2025;
      final totalCost = pde.allocatedEnergy * FakeDataPhase2.precioP2P;
      final consumer = FakeDataPhase2.cristianHoyos;

      return [
        TransactionItem(
          id: 1,
          isIncome: true,
          counterpartyName: '${consumer.userName} ${consumer.userLastName}',
          amount: totalCost,
          energy: pde.allocatedEnergy,
          date: 'Ene 2026',
          source: TransactionSource.pde,
        ),
      ];
    }

    // Períodos históricos: mapear desde contratos
    List contracts;
    switch (period) {
      case '2025-12':
        contracts = FakeDataPhase2.allContracts.take(limit).toList();
        break;
      default:
        contracts = FakeData.p2pContracts.take(limit).toList();
    }

    return contracts.asMap().entries.map((entry) {
      final index = entry.key;
      final contract = entry.value;
      final isIncome = contract.sellerId == userId;
      final counterpartyName =
          isIncome ? contract.buyerName : contract.sellerName;

      final months = [
        'Ene',
        'Feb',
        'Mar',
        'Abr',
        'May',
        'Jun',
        'Jul',
        'Ago',
        'Sep',
        'Oct',
        'Nov',
        'Dic'
      ];
      final date =
          '${contract.createdAt.day}-${months[contract.createdAt.month - 1]}';

      return TransactionItem(
        id: index + 1,
        isIncome: isIncome,
        counterpartyName: counterpartyName,
        amount: contract.totalValue,
        energy: contract.energyCommitted,
        date: date,
        source: TransactionSource.p2p,
      );
    }).toList();
  }

  @override
  Future<List<TransactionItem>> getAllTransactions({
    required String period,
    required int userId,
  }) async {
    // Para fake data, retornamos las mismas que getRecentTransactions pero sin límite
    return getRecentTransactions(
      period: period,
      userId: userId,
      limit: 100,
    );
  }

  @override
  Future<TransactionItem?> getTransactionDetail({
    required int transactionId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    // Para fake data, simular un detalle básico
    // En producción, esto vendría del backend
    return null;
  }

  @override
  Future<Map<String, double>> getTransactionBalance({
    required String period,
    required int userId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final transactions = await getRecentTransactions(
      period: period,
      userId: userId,
      limit: 100,
    );

    double income = 0;
    double expense = 0;

    for (final transaction in transactions) {
      if (transaction.isIncome) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
    };
  }
}
