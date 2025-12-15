import 'package:flutter/material.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/utils/metodos.dart';

/// Modelo de Notificación
class NotificationItem {
  final int id;
  final String title;
  final String description;
  final DateTime date;
  final NotificationType type;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    this.isRead = false,
  });
}

enum NotificationType {
  p2p,        // Transacciones P2P
  energy,     // Energía
  system,     // Sistema
  community,  // Comunidad
}

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  // Fake Data - 2 notificaciones de ejemplo
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: 1,
      title: 'Nueva Oferta P2P Disponible',
      description: 'María García ha publicado una nueva oferta de 60 kWh a 475 COP/kWh. ¡Revisa el marketplace!',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.p2p,
      isRead: false,
    ),
    NotificationItem(
      id: 2,
      title: 'PDE Asignado - Diciembre 2025',
      description: 'Se te ha asignado 7 kWh de energía gratuita del Programa de Distribución de Excedentes (PDE).',
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.community,
      isRead: true,
    ),
  ];

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.p2p:
        return AppTokens.energyGreen;
      case NotificationType.energy:
        return Colors.orange;
      case NotificationType.system:
        return AppTokens.info;
      case NotificationType.community:
        return AppTokens.primaryPurple;
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.p2p:
        return Icons.swap_horiz_rounded;
      case NotificationType.energy:
        return Icons.bolt;
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.community:
        return Icons.groups;
    }
  }

  String _getTypeLabel(NotificationType type) {
    switch (type) {
      case NotificationType.p2p:
        return 'P2P';
      case NotificationType.energy:
        return 'Energía';
      case NotificationType.system:
        return 'Sistema';
      case NotificationType.community:
        return 'Comunidad';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      toolbarHeight: 60,
      elevation: 0.0,
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
      title: const Text(
        'Alertas',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: false,
      actions: [
        // Botón para marcar todas como leídas
        IconButton(
          icon: const Icon(Icons.done_all, color: Colors.white),
          tooltip: 'Marcar todas como leídas',
          onPressed: () {
            setState(() {
              for (var notification in _notifications) {
                notification.isRead;
              }
            });
            context.showInfoSnackbar('Todas las notificaciones marcadas como leídas');
          },
        ),
      ],
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    final typeColor = _getTypeColor(notification.type);
    final typeIcon = _getTypeIcon(notification.type);
    final typeLabel = _getTypeLabel(notification.type);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppTokens.space16,
        vertical: AppTokens.space8,
      ),
      decoration: BoxDecoration(
        color: notification.isRead
            ? context.colors.surface
            : typeColor.withValues(alpha: 0.05),
        borderRadius: AppTokens.borderRadiusMedium,
        border: Border.all(
          color: notification.isRead
              ? context.colors.outline.withValues(alpha: 0.1)
              : typeColor.withValues(alpha: 0.3),
          width: notification.isRead ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              notification.isRead;
            });
            // Aquí puedes navegar a la pantalla correspondiente
            context.showInfoSnackbar('Notificación: ${notification.title}');
          },
          borderRadius: AppTokens.borderRadiusMedium,
          child: Padding(
            padding: EdgeInsets.all(AppTokens.space16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono de tipo
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.15),
                    borderRadius: AppTokens.borderRadiusSmall,
                  ),
                  child: Icon(
                    typeIcon,
                    color: typeColor,
                    size: 24,
                  ),
                ),
                SizedBox(width: AppTokens.space12),
                // Contenido
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge de tipo y fecha
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppTokens.space8,
                              vertical: AppTokens.space4,
                            ),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.2),
                              borderRadius: AppTokens.borderRadiusSmall,
                            ),
                            child: Text(
                              typeLabel,
                              style: context.textStyles.bodySmall?.copyWith(
                                color: typeColor,
                                fontWeight: AppTokens.fontWeightBold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          SizedBox(width: AppTokens.space8),
                          Text(
                            _formatDate(notification.date),
                            style: context.textStyles.bodySmall?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppTokens.space8),
                      // Título
                      Text(
                        notification.title,
                        style: context.textStyles.titleMedium?.copyWith(
                          fontWeight: AppTokens.fontWeightBold,
                          color: notification.isRead
                              ? context.colors.onSurface
                              : context.colors.onSurface,
                        ),
                      ),
                      SizedBox(height: AppTokens.space4),
                      // Descripción
                      Text(
                        notification.description,
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Indicador de no leído
                if (!notification.isRead)
                  Container(
                    width: 10,
                    height: 10,
                    margin: EdgeInsets.only(left: AppTokens.space8),
                    decoration: BoxDecoration(
                      color: typeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: context.colors.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          SizedBox(height: AppTokens.space16),
          Text(
            'No tienes notificaciones',
            style: context.textStyles.titleLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
              fontWeight: AppTokens.fontWeightBold,
            ),
          ),
          SizedBox(height: AppTokens.space8),
          Text(
            'Aquí aparecerán tus alertas y actualizaciones',
            style: context.textStyles.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: context.colors.surfaceContainerLowest,
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: EdgeInsets.symmetric(vertical: AppTokens.space16),
              children: [
                // Header con contador
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTokens.space16,
                    vertical: AppTokens.space8,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Recientes',
                        style: context.textStyles.titleMedium?.copyWith(
                          fontWeight: AppTokens.fontWeightBold,
                        ),
                      ),
                      SizedBox(width: AppTokens.space8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTokens.space8,
                          vertical: AppTokens.space4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTokens.primaryRed.withValues(alpha: 0.2),
                          borderRadius: AppTokens.borderRadiusSmall,
                        ),
                        child: Text(
                          '${_notifications.where((n) => !n.isRead).length}',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: AppTokens.primaryRed,
                            fontWeight: AppTokens.fontWeightBold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Lista de notificaciones
                ..._notifications.map((notification) => _buildNotificationCard(notification)),
              ],
            ),
    );
  }
}
