import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

class LogoutConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const LogoutConfirmationDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(AppTokens.space24),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close_rounded,
                  color: context.colors.onSurface.withValues(alpha: 0.65),
                ),
                tooltip: 'Cerrar',
              ),
            ),
            Container(
              padding: EdgeInsets.all(AppTokens.space16),
              decoration: BoxDecoration(
                color: AppTokens.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout_rounded,
                size: 40,
                color: AppTokens.primaryColor,
              ),
            ),
            SizedBox(height: AppTokens.space20),
            Text(
              'Cerrar Sesión',
              style: context.textStyles.titleLarge?.copyWith(
                fontWeight: AppTokens.fontWeightBold,
                color: AppTokens.primaryColor,
              ),
            ),
            SizedBox(height: AppTokens.space12),
            Text(
              '¿Estás seguro que deseas\ncerrar tu sesión?',
              textAlign: TextAlign.center,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
            SizedBox(height: AppTokens.space24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: AppTokens.space16),
                      side: BorderSide(
                        color: context.colors.outline.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: context.textStyles.bodyLarge?.copyWith(
                        fontWeight: AppTokens.fontWeightSemiBold,
                        color: context.colors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppTokens.space12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTokens.primaryColor,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(vertical: AppTokens.space16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cerrar Sesión',
                      style: context.textStyles.bodyLarge?.copyWith(
                        fontWeight: AppTokens.fontWeightBold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SessionExpiredDialog extends StatelessWidget {
  const SessionExpiredDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(AppTokens.space24),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(AppTokens.space16),
              decoration: BoxDecoration(
                color: AppTokens.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_clock_rounded,
                size: 40,
                color: AppTokens.primaryColor,
              ),
            ),
            SizedBox(height: AppTokens.space20),
            Text(
              'Sesión Expirada',
              style: context.textStyles.titleLarge?.copyWith(
                fontWeight: AppTokens.fontWeightBold,
                color: AppTokens.primaryColor,
              ),
            ),
            SizedBox(height: AppTokens.space12),
            Text(
              'Tu sesión ha expirado.\nPor favor inicia sesión nuevamente.',
              textAlign: TextAlign.center,
              style: context.textStyles.bodyMedium?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
            SizedBox(height: AppTokens.space24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTokens.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: AppTokens.space16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Aceptar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
