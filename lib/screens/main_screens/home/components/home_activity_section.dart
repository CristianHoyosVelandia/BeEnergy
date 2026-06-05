import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

class HomeActivitySection extends StatelessWidget {
  final bool isAdminView;
  final VoidCallback onCommunityManagementTap;
  final VoidCallback onTransferTap;
  final VoidCallback onBolsaTap;
  final VoidCallback onLearnTap;

  const HomeActivitySection({
    super.key,
    required this.isAdminView,
    required this.onCommunityManagementTap,
    required this.onTransferTap,
    required this.onBolsaTap,
    required this.onLearnTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: AppTokens.space12),
            child: Text(
              'Actividades',
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: AppTokens.fontWeightSemiBold,
              ),
            ),
          ),
          if (isAdminView) ...[
            _CommunityManagementButton(onTap: onCommunityManagementTap),
            SizedBox(height: AppTokens.space12),
          ],
          Row(
            children: [
              _ActivityButton(
                label: 'Transferir',
                icon: Icons.swap_horiz_rounded,
                onTap: onTransferTap,
              ),
              SizedBox(width: AppTokens.space12),
              _ActivityButton(
                label: 'Bolsa',
                icon: Icons.account_balance_outlined,
                onTap: onBolsaTap,
              ),
              SizedBox(width: AppTokens.space12),
              _ActivityButton(
                label: 'Aprende',
                icon: Icons.bookmark_outline_rounded,
                onTap: onLearnTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActivityButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTokens.borderRadiusMedium,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: AppTokens.space16,
            horizontal: AppTokens.space12,
          ),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: AppTokens.borderRadiusMedium,
            border: Border.all(
              color: context.colors.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(AppTokens.space12),
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: AppTokens.borderRadiusSmall,
                ),
                child: Icon(icon, color: context.colors.primary, size: 24),
              ),
              SizedBox(height: AppTokens.space8),
              Text(
                label,
                style: context.textStyles.labelMedium,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommunityManagementButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CommunityManagementButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppTokens.borderRadiusMedium,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: AppTokens.space16,
          horizontal: AppTokens.space16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTokens.primaryColor,
              AppTokens.primaryColor.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppTokens.borderRadiusMedium,
          boxShadow: [
            BoxShadow(
              color: AppTokens.primaryColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.groups_rounded, color: Colors.white, size: 24),
            SizedBox(width: AppTokens.space12),
            Flexible(
              child: Text(
                'Gestión de comunidad',
                style: context.textStyles.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: AppTokens.fontWeightBold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
