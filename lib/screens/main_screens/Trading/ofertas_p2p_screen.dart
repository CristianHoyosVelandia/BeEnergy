// ignore_for_file: file_names

import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/utils/formatters.dart';
import 'package:be_energy/repositories/credits_repository.dart';
import 'package:be_energy/repositories/transaction_repository.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';
import '../../../models/callmodels.dart';

class OfertasP2PScreen extends StatefulWidget {
  final MyUser? myUser;

  const OfertasP2PScreen({super.key, this.myUser});

  @override
  State<OfertasP2PScreen> createState() => _OfertasP2PScreenState();
}

class _OfertasP2PScreenState extends State<OfertasP2PScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TransactionRepository _repo = TransactionRepository();
  final CreditsRepository _creditsRepo = CreditsRepository();
  final _kwhController = TextEditingController();
  final _priceController = TextEditingController();
  List<dynamic> _myOffers = [];
  List<dynamic> _availableOffers = [];
  bool _loadingOffers = false;
  bool _loadingAvailable = false;
  bool _sending = false;
  // Filtros para ofertas disponibles (precio, cantidad mínima, orden)
  double? _filterPriceMin;
  double? _filterPriceMax;
  double? _filterMinKwh;
  String _sortBy = 'precio'; // precio | cantidad | fecha

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMyOffers();
    _loadAvailableOffers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _kwhController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadMyOffers() async {
    final userId = widget.myUser?.idUser ?? 0;
    if (userId <= 0) return;
    setState(() => _loadingOffers = true);
    try {
      final resp = await _repo.listContracts(sellerId: userId, status: 'active');
      if (resp.success && resp.data != null) {
        setState(() => _myOffers = resp.data is List ? resp.data as List<dynamic> : []);
      } else {
        setState(() => _myOffers = []);
      }
    } catch (_) {
      setState(() => _myOffers = []);
    }
    setState(() => _loadingOffers = false);
  }

  /// Ofertas disponibles para consumidores (solo estado activa)
  Future<void> _loadAvailableOffers() async {
    setState(() => _loadingAvailable = true);
    try {
      final resp = await _repo.listContracts(status: 'active');
      if (resp.success && resp.data != null) {
        setState(() => _availableOffers = resp.data is List ? resp.data as List<dynamic> : []);
      } else {
        setState(() => _availableOffers = []);
      }
    } catch (_) {
      setState(() => _availableOffers = []);
    }
    setState(() => _loadingAvailable = false);
  }

  Future<void> _acceptOffer(int contractId) async {
    final buyerId = widget.myUser?.idUser ?? 0;
    if (buyerId <= 0) {
      Metodos.flushbarNegativo(context, 'Inicia sesión para aceptar');
      return;
    }
    try {
      final resp = await _repo.actOnContract(contractId: contractId, action: 'accept', buyerId: buyerId);
      if (resp.success && mounted) {
        Metodos.flushbarPositivo(context, 'Oferta aceptada');
        _loadAvailableOffers();
      } else if (mounted) {
        Metodos.flushbarNegativo(context, resp.message ?? 'No se pudo aceptar');
      }
    } catch (e) {
      if (mounted) Metodos.flushbarNegativo(context, 'Error al aceptar');
    }
  }

  Future<void> _publishOffer() async {
    final sellerId = widget.myUser?.idUser ?? 0;
    if (sellerId <= 0) {
      Metodos.flushbarNegativo(context, 'Inicia sesión para publicar');
      return;
    }
    final kwhStr = _kwhController.text.trim();
    final priceStr = _priceController.text.trim();
    if (kwhStr.isEmpty || priceStr.isEmpty) {
      Metodos.flushbarNegativo(context, 'Indique cantidad de kWh y precio por kWh (campos obligatorios)');
      return;
    }
    final kwh = double.tryParse(kwhStr.replaceAll(',', '.'));
    final price = double.tryParse(priceStr.replaceAll(',', '.'));
    if (kwh == null || kwh <= 0 || price == null || price <= 0) {
      Metodos.flushbarNegativo(context, 'Ingrese valores válidos: kWh y precio deben ser mayores a cero');
      return;
    }
    setState(() => _sending = true);
    try {
      final balanceResp = await _creditsRepo.getBalance(sellerId);
      double balance = 0;
      if (balanceResp.success && balanceResp.data != null) {
        final d = balanceResp.data!;
        final b = d['balance'] ?? d['kwh'] ?? d['energy'] ?? 0;
        balance = b is num ? b.toDouble() : 0;
      }
      if (balance < kwh) {
        if (mounted) Metodos.flushbarNegativo(context, 'Saldo energético insuficiente');
        setState(() => _sending = false);
        return;
      }
      final resp = await _repo.createContract(
        sellerId: sellerId,
        agreedPrice: price,
        energyCommitted: kwh,
      );
      if (resp.success && mounted) {
        Metodos.flushbarPositivo(context, 'Oferta publicada');
        _kwhController.clear();
        _priceController.clear();
        _loadMyOffers();
        _tabController.animateTo(1);
      } else if (mounted) {
        final msg = (resp.message ?? '').toLowerCase();
        String show = resp.message ?? 'Error al publicar';
        if (msg.contains('403') || msg.contains('forbidden') || msg.contains('prosumidor')) show = 'Solo prosumidores pueden publicar ofertas';
        Metodos.flushbarNegativo(context, show);
      }
    } catch (e) {
      if (mounted) Metodos.flushbarNegativo(context, 'Error de conexión');
    }
    if (mounted) setState(() => _sending = false);
  }

  Future<void> _cancelOffer(int contractId) async {
    try {
      final resp = await _repo.actOnContract(contractId: contractId, action: 'cancel');
      if (resp.success && mounted) {
        Metodos.flushbarPositivo(context, 'Oferta cancelada');
        _loadMyOffers();
      } else if (mounted) {
        final msg = (resp.message ?? '').toLowerCase();
        String show = resp.message ?? 'No se pudo cancelar';
        if (msg.contains('estado') || msg.contains('emparejada') || msg.contains('liquidada')) show = 'La oferta no puede cancelarse en su estado actual';
        Metodos.flushbarNegativo(context, show);
      }
    } catch (e) {
      if (mounted) Metodos.flushbarNegativo(context, 'Error al cancelar');
    }
  }

  /// Filtros por rango de precio, cantidad mínima y ordenamiento
  List<dynamic> get _filteredAvailableOffers {
    List<dynamic> list = List.from(_availableOffers);
    list = list.where((e) {
      final o = e is Map ? e as Map<String, dynamic> : <String, dynamic>{};
      final priceVal = o['agreed_price'] ?? o['price'] ?? 0.0;
      final price = priceVal is num ? priceVal.toDouble() : 0.0;
      final kwhVal = o['energy_committed'] ?? o['kwh'] ?? 0.0;
      final kwh = kwhVal is num ? kwhVal.toDouble() : 0.0;
      if (_filterPriceMin != null && price < _filterPriceMin!) return false;
      if (_filterPriceMax != null && price > _filterPriceMax!) return false;
      if (_filterMinKwh != null && kwh < _filterMinKwh!) return false;
      return true;
    }).toList();
    list.sort((a, b) {
      final oa = a is Map ? a as Map<String, dynamic> : <String, dynamic>{};
      final ob = b is Map ? b as Map<String, dynamic> : <String, dynamic>{};
      final pav = oa['agreed_price'] ?? oa['price'] ?? 0.0;
      final pbv = ob['agreed_price'] ?? ob['price'] ?? 0.0;
      final pa = pav is num ? pav.toDouble() : 0.0;
      final pb = pbv is num ? pbv.toDouble() : 0.0;
      final kav = oa['energy_committed'] ?? oa['kwh'] ?? 0.0;
      final kbv = ob['energy_committed'] ?? ob['kwh'] ?? 0.0;
      final ka = kav is num ? kav.toDouble() : 0.0;
      final kb = kbv is num ? kbv.toDouble() : 0.0;
      final ta = oa['created_at'] ?? oa['date'] ?? '';
      final tb = ob['created_at'] ?? ob['date'] ?? '';
      if (_sortBy == 'precio') return pa.compareTo(pb);
      if (_sortBy == 'cantidad') return ka.compareTo(kb);
      return (ta.toString()).compareTo(tb.toString());
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ofertas P2P',
          style: context.textStyles.titleLarge?.copyWith(
            color: context.colors.onSurface,
            fontWeight: AppTokens.fontWeightBold,
          ),
        ),
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.onSurface,
        bottom: TabBar(
          controller: _tabController,
          labelColor: context.colors.primary,
          unselectedLabelColor: context.colors.onSurfaceVariant,
          tabs: const [
            Tab(text: 'Publicar'),
            Tab(text: 'Mis ofertas'),
            Tab(text: 'Disponibles'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPublishTab(),
          _buildMyOffersTab(),
          _buildAvailableOffersTab(),
        ],
      ),
    );
  }

  Widget _buildPublishTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTokens.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Cantidad de kWh y precio por kWh',
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTokens.space24),
          TextField(
            controller: _kwhController,
            decoration: const InputDecoration(
              labelText: 'kWh a vender',
              hintText: 'Ej: 50',
              prefixIcon: Icon(Icons.bolt),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: AppTokens.space16),
          TextField(
            controller: _priceController,
            decoration: const InputDecoration(
              labelText: 'Precio por kWh',
              hintText: 'Ej: 150',
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: AppTokens.space32),
          ElevatedButton(
            onPressed: _sending ? null : _publishOffer,
            child: Text(_sending ? 'Publicando...' : 'Publicar oferta'),
          ),
        ],
      ),
    );
  }

  Widget _buildMyOffersTab() {
    if (_loadingOffers) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: context.colors.primary),
            const SizedBox(height: AppTokens.space16),
            Text(
              'Cargando ofertas...',
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    if (_myOffers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sell_outlined, size: 64, color: context.colors.outline),
            const SizedBox(height: AppTokens.space16),
            Text(
              'No tienes ofertas activas.\nPublica una en la pestaña "Publicar oferta".',
              textAlign: TextAlign.center,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadMyOffers,
      color: context.colors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTokens.space16),
        itemCount: _myOffers.length,
        itemBuilder: (context, i) {
          final o = _myOffers[i] is Map ? _myOffers[i] as Map<String, dynamic> : <String, dynamic>{};
          final id = o['id'] ?? o['contract_id'] ?? i;
          final kwhVal = o['energy_committed'] ?? o['kwh'] ?? 0.0;
          final kwh = kwhVal is num ? kwhVal.toDouble() : 0.0;
          final priceVal = o['agreed_price'] ?? o['price'] ?? 0.0;
          final price = priceVal is num ? priceVal.toDouble() : 0.0;
          final status = o['status'] ?? 'activa';
          return Card(
            margin: const EdgeInsets.only(bottom: AppTokens.space12),
            child: ListTile(
              title: Text(
                '${Formatters.formatEnergy(kwh)} · \$${price.toStringAsFixed(0)}/kWh',
                style: context.textStyles.titleMedium?.copyWith(
                  color: context.colors.onSurface,
                  fontWeight: AppTokens.fontWeightSemiBold,
                ),
              ),
              subtitle: Text(
                'Estado: $status',
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              trailing: status == 'active' || status == 'activa'
                  ? TextButton(
                      onPressed: () => _cancelOffer(id is int ? id : int.tryParse(id.toString()) ?? 0),
                      child: const Text('Cancelar'),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  /// Ofertas disponibles para consumidores
  Widget _buildAvailableOffersTab() {
    if (_loadingAvailable) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: context.colors.primary),
            const SizedBox(height: AppTokens.space16),
            Text(
              'Cargando ofertas...',
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    if (_availableOffers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_outlined, size: 64, color: context.colors.outline),
            const SizedBox(height: AppTokens.space16),
            Text(
              'No hay ofertas activas en este momento.',
              textAlign: TextAlign.center,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    final displayList = _filteredAvailableOffers;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.space16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _sortBy,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'precio', child: Text('Orden: Precio')),
                    DropdownMenuItem(value: 'cantidad', child: Text('Orden: Cantidad')),
                    DropdownMenuItem(value: 'fecha', child: Text('Orden: Fecha')),
                  ],
                  onChanged: (v) => setState(() => _sortBy = v ?? 'precio'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await _loadAvailableOffers();
              await _loadMyOffers();
            },
            color: context.colors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTokens.space16),
              itemCount: displayList.length,
              itemBuilder: (context, i) {
                final o = displayList[i] is Map
                    ? displayList[i] as Map<String, dynamic>
                    : <String, dynamic>{};
          final id = o['id'] ?? o['contract_id'] ?? i;
          final sellerId = o['seller_id'] ?? 0;
          final myId = widget.myUser?.idUser ?? 0;
          final isMine = sellerId == myId;
          final kwhVal = o['energy_committed'] ?? o['kwh'] ?? 0.0;
          final kwh = kwhVal is num ? kwhVal.toDouble() : 0.0;
          final priceVal = o['agreed_price'] ?? o['price'] ?? 0.0;
          final price = priceVal is num ? priceVal.toDouble() : 0.0;
          return Card(
            margin: const EdgeInsets.only(bottom: AppTokens.space12),
            child: ListTile(
              title: Text(
                '${Formatters.formatEnergy(kwh)} · \$${price.toStringAsFixed(0)}/kWh',
                style: context.textStyles.titleMedium?.copyWith(
                  color: context.colors.onSurface,
                  fontWeight: AppTokens.fontWeightSemiBold,
                ),
              ),
              subtitle: Text(
                isMine ? 'Tu oferta' : 'Oferta disponible',
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              trailing: !isMine && myId > 0
                  ? FilledButton(
                      onPressed: () => _acceptOffer(id is int ? id : int.tryParse(id.toString()) ?? 0),
                      child: const Text('Aceptar'),
                    )
                  : null,
            ),
          );
        },
      ),
    ),
        ),
      ],
    );
  }
}
