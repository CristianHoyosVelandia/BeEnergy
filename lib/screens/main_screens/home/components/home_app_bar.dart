import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/utils/metodos.dart';
import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final bool canToggleAdminView;
  final bool isAdminView;
  final VoidCallback onToggleAdminView;
  final VoidCallback onNotificationsTap;

  const HomeAppBar({
    super.key,
    required this.userName,
    required this.canToggleAdminView,
    required this.isAdminView,
    required this.onToggleAdminView,
    required this.onNotificationsTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 60,
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
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.18),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                userName.isEmpty ? 'U' : userName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '¡Hola,',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$userName!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
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
          tooltip: 'Notificaciones',
          icon: Icons.notifications,
          onPressed: onNotificationsTap,
          marginRight: 15,
        ),
      ],
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final double marginRight;

  const _RoundActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.marginRight = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 45,
      margin: EdgeInsets.only(top: 7.5, bottom: 7.5, right: marginRight),
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
    );
  }
}
