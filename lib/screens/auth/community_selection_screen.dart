import 'package:flutter/material.dart';
import '../../models/auth_models.dart';
import '../../models/community_models.dart';
import '../../services/community_theme_storage.dart';
import '../../services/community_service.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/logger.dart';

/// Pantalla de selección de comunidad
/// Se muestra cuando el usuario pertenece a múltiples comunidades
class CommunitySelectionScreen extends StatefulWidget {
  final AuthUser user;
  final Function(Community) onCommunitySelected;

  const CommunitySelectionScreen({
    Key? key,
    required this.user,
    required this.onCommunitySelected,
  }) : super(key: key);

  @override
  State<CommunitySelectionScreen> createState() =>
      _CommunitySelectionScreenState();
}

class _CommunitySelectionScreenState extends State<CommunitySelectionScreen> {
  late CommunityService _communityService;
  late CommunityThemeStorage _themeStorage;
  List<Community> communities = [];
  bool isLoading = true;
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

      final communityIds = widget.user.communities ?? [];

      // Cargar datos de cada comunidad
      final loadedCommunities = <Community>[];
      for (int id in communityIds) {
        try {
          final data = await _communityService.getCommunityData(id);
          loadedCommunities.add(Community.fromJson({...data, 'id': id}));
        } catch (e) {
          AppLogger.error(
            'Error cargando comunidad $id',
            error: e.toString(),
          );
        }
      }

      setState(() {
        communities = loadedCommunities;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar comunidades: ${e.toString()}';
        isLoading = false;
      });
      AppLogger.error('Error en _loadCommunities', error: e.toString());
    }
  }

  Future<void> _selectCommunity(Community community) async {
    try {
      // Guardar datos de tema en storage
      await _themeStorage.saveCommunityTheme(
        primaryColor:
            community.primaryColor ?? CommunityThemeStorage.defaultPrimaryColor,
        secondColor:
            community.secondColor ?? CommunityThemeStorage.defaultSecondColor,
        urlImg: community.urlImg ?? CommunityThemeStorage.defaultUrlImg,
        topology:
            community.topologic ?? CommunityThemeStorage.defaultTopology,
        communityId: community.id,
      );

      // Callback al parent
      widget.onCommunitySelected(community);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error seleccionando comunidad: $e'),
          backgroundColor: AppTokens.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: AppTokens.primaryColor,
                ),
              )
            : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppTokens.error,
                        ),
                        SizedBox(height: AppTokens.space16),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTokens.error,
                              ),
                        ),
                        SizedBox(height: AppTokens.space24),
                        ElevatedButton(
                          onPressed: _loadCommunities,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(AppTokens.space16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selecciona una comunidad',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            SizedBox(height: AppTokens.space8),
                            Text(
                              'Perteneces a ${communities.length} comunidad(es)',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTokens.space16,
                          ),
                          itemCount: communities.length,
                          itemBuilder: (context, index) {
                            final community = communities[index];
                            return _CommunityCard(
                              community: community,
                              onSelected: () => _selectCommunity(community),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

/// Widget de tarjeta para cada comunidad
class _CommunityCard extends StatelessWidget {
  final Community community;
  final VoidCallback onSelected;

  const _CommunityCard({
    Key? key,
    required this.community,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppTokens.space12),
      child: InkWell(
        onTap: onSelected,
        child: Padding(
          padding: EdgeInsets.all(AppTokens.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen y nombre
              Row(
                children: [
                  if (community.urlImg != null && community.urlImg!.isNotEmpty)
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: NetworkImage(community.urlImg!),
                      backgroundColor: Color(
                        CommunityThemeStorage.parseColorString(
                          community.primaryColor ??
                              CommunityThemeStorage.defaultPrimaryColor,
                        ),
                      ),
                    )
                  else
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Color(
                        CommunityThemeStorage.parseColorString(
                          community.primaryColor ??
                              CommunityThemeStorage.defaultPrimaryColor,
                        ),
                      ),
                      child: Text(
                        community.name.isNotEmpty
                            ? community.name[0].toUpperCase()
                            : 'C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  SizedBox(width: AppTokens.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          community.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: AppTokens.space4),
                        Text(
                          community.location,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Descripción
              if (community.description.isNotEmpty) ...[
                SizedBox(height: AppTokens.space12),
                Text(
                  community.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: AppTokens.space12),
              // Botón de selección
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onSelected,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(
                      CommunityThemeStorage.parseColorString(
                        community.primaryColor ??
                            CommunityThemeStorage.defaultPrimaryColor,
                      ),
                    ),
                  ),
                  child: const Text('Seleccionar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
