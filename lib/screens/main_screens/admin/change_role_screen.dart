// ignore_for_file: file_names
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/repositories/user_repository.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';

class ChangeRoleScreen extends StatefulWidget {
  const ChangeRoleScreen({super.key});

  @override
  State<ChangeRoleScreen> createState() => _ChangeRoleScreenState();
}

class _ChangeRoleScreenState extends State<ChangeRoleScreen> {
  final UserRepository _repo = UserRepository();
  final _userIdController = TextEditingController();
  int _selectedRole = 1; // 0=admin, 1=consumidor, 2=prosumidor (según backend)
  bool _saving = false;

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  Future<void> _changeRole() async {
    final userId = int.tryParse(_userIdController.text.trim());
    if (userId == null) {
      Metodos.flushbarNegativo(context, 'Ingresa un ID de usuario válido');
      return;
    }
    setState(() => _saving = true);
    try {
      final resp = await _repo.changeRole(userId, role: _selectedRole);
      if (resp.success && mounted) {
        Metodos.flushbarPositivo(context, 'Rol actualizado correctamente');
        _userIdController.clear();
      } else {
        if (mounted) Metodos.flushbarNegativo(context, resp.message ?? 'No se pudo cambiar el rol');
      }
    } catch (e) {
      if (mounted) Metodos.flushbarNegativo(context, 'Error de conexión');
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cambiar rol de usuario',
          style: context.textStyles.titleLarge?.copyWith(
            color: context.colors.onSurface,
            fontWeight: AppTokens.fontWeightBold,
          ),
        ),
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Solo administradores pueden cambiar roles. No dejes el sistema sin al menos un administrador activo.',
              style: context.textStyles.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTokens.space24),
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'ID del usuario',
                hintText: 'Ej: 5',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppTokens.space16),
            Text(
              'Nuevo rol',
              style: context.textStyles.titleSmall?.copyWith(
                color: context.colors.onSurface,
              ),
            ),
            const SizedBox(height: AppTokens.space8),
            DropdownButtonFormField<int>(
              value: _selectedRole,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 0, child: Text('Administrador')),
                DropdownMenuItem(value: 1, child: Text('Consumidor')),
                DropdownMenuItem(value: 2, child: Text('Prosumidor')),
              ],
              onChanged: (v) => setState(() => _selectedRole = v ?? 1),
            ),
            const SizedBox(height: AppTokens.space32),
            FilledButton(
              onPressed: _saving ? null : _changeRole,
              child: Text(_saving ? 'Guardando...' : 'Cambiar rol'),
            ),
          ],
        ),
      ),
    );
  }
}
