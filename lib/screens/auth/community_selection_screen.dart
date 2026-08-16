import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/utils/logger.dart';
import '../../models/auth_models.dart';
import '../../models/community_models.dart';
import '../../services/community_service.dart';
import '../../services/community_theme_storage.dart';

/// Pantalla de selección de comunidad.
/// Se muestra cuando el usuario pertenece a múltiples comunidades.
class CommunitySelectionScreen extends StatefulWidget {
  final AuthUser? user;
  final Future<void> Function(Community) onCommunitySelected;

  const CommunitySelectionScreen({
    super.key,
    this.user,
    required this.onCommunitySelected,
  });

  @override
  State<CommunitySelectionScreen> createState() =>
      _CommunitySelectionScreenState();
}

class _CommunitySelectionScreenState extends State<CommunitySelectionScreen> {
  late final CommunityService _communityService;
  late final CommunityThemeStorage _themeStorage;
  List<Community> communities = [];
  bool isLoading = true;
  int? selectingCommunityId;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _communityService = CommunityService();
    _themeStorage = CommunityThemeStorage();
    _loadCommunities();
  }

  Future<void> _loadCommunities() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final loadedCommunities = await _communityService.getMyCommunities();

      if (!mounted) return;
      setState(() {
        communities = loadedCommunities;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      AppLogger.error('Error en _loadCommunities', error: e.toString());
    }
  }

  Future<void> _selectCommunity(Community community) async {
    try {
      setState(() => selectingCommunityId = community.id);

      final selectedCommunity =
          await _communityService.selectCommunity(community.id);

      await _themeStorage.saveCommunityTheme(
        primaryColor: selectedCommunity.primaryColor ??
            CommunityThemeStorage.defaultPrimaryColor,
        secondColor: selectedCommunity.secondColor ??
            CommunityThemeStorage.defaultSecondColor,
        urlImg: selectedCommunity.urlImg ?? CommunityThemeStorage.defaultUrlImg,
        topology: selectedCommunity.topologic ??
            CommunityThemeStorage.defaultTopology,
        communityId: selectedCommunity.id,
      );

      await widget.onCommunitySelected(selectedCommunity);
    } catch (e) {
      if (mounted) {
        setState(() => selectingCommunityId = null);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error seleccionando comunidad: $e'),
          backgroundColor: AppTokens.primaryColor,
        ),
      );
    }
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppTokens.space20,
        AppTokens.space24,
        AppTokens.space20,
        AppTokens.space12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecciona una comunidad',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTokens.grey900,
                  fontWeight: AppTokens.fontWeightBold,
                  height: 1.15,
                ),
          ),
          SizedBox(height: AppTokens.space8),
          Text(
            'Elige con qué comunidad quieres ingresar',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTokens.grey700,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTokens.space12,
              vertical: 8,
            ),
            margin: EdgeInsets.only(bottom: AppTokens.space12),
            decoration: BoxDecoration(
              color: AppTokens.primaryColor.withValues(alpha: 0.08),
              borderRadius: AppTokens.borderRadiusCircular,
            ),
            child: Text(
              'Tienes acceso a ${communities.length} comunidades',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTokens.primaryColor,
                    fontWeight: AppTokens.fontWeightSemiBold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppTokens.primaryColor),
          SizedBox(height: AppTokens.space16),
          Text(
            'Cargando tus comunidades...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTokens.grey700,
                ),
          ),
        ],
      ),
    );
  }

  Widget _errorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(AppTokens.space16),
              decoration: BoxDecoration(
                color: AppTokens.primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: AppTokens.iconSizeXLarge,
                color: AppTokens.primaryColor,
              ),
            ),
            SizedBox(height: AppTokens.space16),
            Text(
              'No pudimos cargar tus comunidades',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: AppTokens.fontWeightBold,
                    color: AppTokens.grey900,
                  ),
            ),
            SizedBox(height: AppTokens.space8),
            Text(
              errorMessage ?? 'Intenta nuevamente en unos segundos.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTokens.grey600,
                    height: 1.35,
                  ),
            ),
            SizedBox(height: AppTokens.space24),
            ElevatedButton.icon(
              onPressed: _loadCommunities,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTokens.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppTokens.space24,
                  vertical: AppTokens.space12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.apartment_rounded,
              size: AppTokens.iconSizeXXLarge,
              color: AppTokens.primaryColor.withValues(alpha: 0.7),
            ),
            SizedBox(height: AppTokens.space16),
            Text(
              'No tienes comunidades asignadas',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: AppTokens.fontWeightBold,
                  ),
            ),
            SizedBox(height: AppTokens.space8),
            Text(
              'Cuando una comunidad te asigne acceso, podrás ingresar desde aquí.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTokens.grey600,
                    height: 1.35,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    if (isLoading) return _loadingState(context);
    if (errorMessage != null) return _errorState(context);
    if (communities.isEmpty) return _emptyState(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(
              AppTokens.space16,
              0,
              AppTokens.space16,
              AppTokens.space32,
            ),
            itemCount: communities.length,
            itemBuilder: (context, index) {
              final community = communities[index];
              return _CommunityCard(
                community: community,
                isLoading: selectingCommunityId == community.id,
                isDisabled: selectingCommunityId != null,
                onSelected: () => _selectCommunity(community),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(child: _content(context)),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final Community community;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback onSelected;

  const _CommunityCard({
    required this.community,
    required this.isLoading,
    required this.isDisabled,
    required this.onSelected,
  });

  Color _communityColor() {
    return Color(
      CommunityThemeStorage.parseColorString(
        community.primaryColor ?? CommunityThemeStorage.defaultPrimaryColor,
      ),
    );
  }

  String _initial() {
    final name = community.name.trim();
    return name.isEmpty ? 'C' : name[0].toUpperCase();
  }

  String? _description() {
    final description = community.description.trim();
    final name = community.name.trim();

    if (description.isEmpty) return null;
    if (description.toLowerCase() == name.toLowerCase()) return null;

    return description;
  }

  String? _roleLabel() {
    final roleName = community.roleName?.trim();
    if (roleName != null && roleName.isNotEmpty) return roleName;

    switch (community.role) {
      case 1:
        return 'Consumidor';
      case 2:
        return 'Prosumidor';
      case 3:
        return 'Administrador';
      case 4:
        return 'Superadmin';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _communityColor();
    final description = _description();
    final roleLabel = _roleLabel();

    return Opacity(
      opacity: isDisabled && !isLoading ? 0.55 : 1,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        elevation: 1.5,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        shape:
            RoundedRectangleBorder(borderRadius: AppTokens.borderRadiusLarge),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isDisabled ? null : onSelected,
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 5, color: color),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTokens.space16,
                      vertical: AppTokens.space12,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: color,
                          backgroundImage: community.urlImg != null &&
                                  community.urlImg!.isNotEmpty
                              ? NetworkImage(community.urlImg!)
                              : null,
                          child: community.urlImg != null &&
                                  community.urlImg!.isNotEmpty
                              ? null
                              : Text(
                                  _initial(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                        ),
                        SizedBox(width: AppTokens.space12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                community.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: AppTokens.fontWeightBold,
                                      color: AppTokens.grey900,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (community.location.trim().isNotEmpty) ...[
                                SizedBox(height: AppTokens.space4),
                                Text(
                                  community.location,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: AppTokens.grey700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              if (description != null) ...[
                                SizedBox(height: AppTokens.space8),
                                Text(
                                  description,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppTokens.grey600),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              if (roleLabel != null) ...[
                                const SizedBox(height: 6),
                                _RoleChip(label: roleLabel, color: color),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(width: AppTokens.space12),
                        if (isLoading)
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          )
                        else
                          Icon(
                            Icons.chevron_right_rounded,
                            color: color,
                            size: 30,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final Color color;

  const _RoleChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTokens.space8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: AppTokens.borderRadiusCircular,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: AppTokens.fontWeightSemiBold,
            ),
      ),
    );
  }
}
