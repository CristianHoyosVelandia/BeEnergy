import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String communityName;
  final bool canToggleAdminView;
  final bool isAdminView;
  final VoidCallback onToggleAdminView;
  final VoidCallback onLogoutTap;

  const HomeAppBar({
    super.key,
    required this.userName,
    required this.communityName,
    required this.canToggleAdminView,
    required this.isAdminView,
    required this.onToggleAdminView,
    required this.onLogoutTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 68,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              color: Color(0x4B1A1F24),
              offset: Offset(0, 2),
            )
          ],
          gradient: Metodos.gradientClasic(context),
        ),
      ),
      backgroundColor: Colors.transparent,
      title: Row(
        children: [
          SizedBox(
            width: 55,
            height: 55,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'assets/img/logo.png',
                fit: BoxFit.contain,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '¡Hola, $userName!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (communityName.trim().isNotEmpty)
                  Text(
                    communityName.trim(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (canToggleAdminView)
          _RoundActionButton(
            tooltip: isAdminView ? 'Vista Usuario' : 'Vista Administrador',
            icon: isAdminView ? Icons.person : Icons.admin_panel_settings,
            onPressed: onToggleAdminView,
          ),
        _RoundActionButton(
          tooltip: 'Cerrar sesión',
          label: 'Salir',
          icon: Icons.logout_rounded,
          onPressed: onLogoutTap,
          marginRight: 15,
        ),
      ],
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  final String tooltip;
  final String? label;
  final IconData icon;
  final VoidCallback onPressed;
  final double marginRight;

  const _RoundActionButton({
    required this.tooltip,
    this.label,
    required this.icon,
    required this.onPressed,
    this.marginRight = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: marginRight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppTokens.primaryColor,
              border: Border.all(width: 2, color: Colors.white),
              borderRadius: BorderRadius.circular(25),
            ),
            child: IconButton(
              icon: Icon(icon, size: 22),
              color: Colors.white,
              tooltip: tooltip,
              onPressed: onPressed,
            ),
          ),
          if (label != null)
            Text(
              label!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
