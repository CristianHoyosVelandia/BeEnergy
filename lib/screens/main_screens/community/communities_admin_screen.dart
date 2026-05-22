import 'package:flutter/material.dart';
import 'package:be_energy/core/theme/app_tokens.dart';
import 'package:be_energy/core/extensions/context_extensions.dart';
import 'package:be_energy/models/my_user.dart';
import 'package:be_energy/models/community_models.dart';
import 'package:be_energy/services/community_service.dart';
import 'package:be_energy/core/utils/logger.dart';

/// Pantalla de Administración de Comunidades (solo para SuperAdmin - rol 4)
/// Permite crear, editar, ver y eliminar comunidades
class CommunitiesAdminScreen extends StatefulWidget {
  final MyUser myUser;

  const CommunitiesAdminScreen({
    super.key,
    required this.myUser,
  });

  @override
  State<CommunitiesAdminScreen> createState() => _CommunitiesAdminScreenState();
}

class _CommunitiesAdminScreenState extends State<CommunitiesAdminScreen> {
  static const String _tag = 'CommunitiesAdminScreen';
  final CommunityService _communityService = CommunityService();

  late Future<List<Community>> _communitiesFuture;

  @override
  void initState() {
    super.initState();
    _loadCommunities();
  }

  void _loadCommunities() {
    setState(() {
      _communitiesFuture = _fetchCommunities();
    });
  }

  Future<List<Community>> _fetchCommunities() async {
    try {
      final communities = await _communityService.getAllCommunities();
      return communities
          .map((data) => Community.fromJson(data))
          .toList();
    } catch (e) {
      AppLogger.error('Error loading communities', tag: _tag, error: e.toString());
      rethrow;
    }
  }

  void _showCreateCommunityDialog() {
    showDialog(
      context: context,
      builder: (context) => _CommunityFormDialog(
        onSave: (data) {
          AppLogger.debug('Creating community: $data', tag: _tag);
          _loadCommunities();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditCommunityDialog(Community community) {
    showDialog(
      context: context,
      builder: (context) => _CommunityFormDialog(
        community: community,
        onSave: (data) {
          AppLogger.debug('Updating community: $data', tag: _tag);
          _loadCommunities();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showDeleteConfirmation(Community community) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Comunidad'),
        content: Text('¿Estás seguro que deseas eliminar "${community.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              AppLogger.debug('Deleting community: ${community.id}', tag: _tag);
              Navigator.pop(context);
              _loadCommunities();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Comunidades'),
        elevation: 0,
        backgroundColor: AppTokens.primaryColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateCommunityDialog,
        backgroundColor: AppTokens.primaryColor,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Community>>(
        future: _communitiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  SizedBox(height: AppTokens.space16),
                  Text(
                    'Error al cargar comunidades',
                    style: context.textStyles.bodyLarge,
                  ),
                  SizedBox(height: AppTokens.space16),
                  ElevatedButton(
                    onPressed: _loadCommunities,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final communities = snapshot.data ?? [];

          if (communities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.apartment_outlined,
                    size: 64,
                    color: AppTokens.primaryColor.withValues(alpha: 0.3),
                  ),
                  SizedBox(height: AppTokens.space16),
                  Text(
                    'No hay comunidades',
                    style: context.textStyles.bodyLarge,
                  ),
                  SizedBox(height: AppTokens.space8),
                  Text(
                    'Presiona el botón + para crear una',
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(AppTokens.space16),
            itemCount: communities.length,
            itemBuilder: (context, index) {
              final community = communities[index];
              return _CommunityCard(
                community: community,
                onEdit: () => _showEditCommunityDialog(community),
                onDelete: () => _showDeleteConfirmation(community),
              );
            },
          );
        },
      ),
    );
  }
}

/// Widget para mostrar cada comunidad en la lista
class _CommunityCard extends StatelessWidget {
  final Community community;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CommunityCard({
    required this.community,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppTokens.space12),
      child: Padding(
        padding: EdgeInsets.all(AppTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _parseColor(community.primaryColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      community.name?.substring(0, 1).toUpperCase() ?? 'C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppTokens.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        community.name ?? 'Sin nombre',
                        style: context.textStyles.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppTokens.space4),
                      if (community.location != null)
                        Text(
                          community.location!,
                          style: context.textStyles.bodySmall?.copyWith(
                            color: context.colors.onSurface.withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (community.description != null && community.description!.isNotEmpty) ...[
              SizedBox(height: AppTokens.space12),
              Text(
                community.description!,
                style: context.textStyles.bodySmall?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: AppTokens.space16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text('Editar'),
                ),
                SizedBox(width: AppTokens.space8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_rounded, size: 18),
                  label: const Text('Eliminar'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return AppTokens.primaryColor;
    }
    try {
      // Espera formato como "0xFFxxxxxx"
      return Color(int.parse(colorString.replaceFirst('0x', '0xff')));
    } catch (e) {
      return AppTokens.primaryColor;
    }
  }
}

/// Dialog para crear/editar una comunidad
class _CommunityFormDialog extends StatefulWidget {
  final Community? community;
  final Function(Map<String, dynamic>) onSave;

  const _CommunityFormDialog({
    this.community,
    required this.onSave,
  });

  @override
  State<_CommunityFormDialog> createState() => _CommunityFormDialogState();
}

class _CommunityFormDialogState extends State<_CommunityFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _primaryColorController;
  late final TextEditingController _secondaryColorController;

  Color _selectedPrimaryColor = AppTokens.primaryColor;
  Color _selectedSecondaryColor = AppTokens.primaryColor;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.community?.name ?? '');
    _descriptionController = TextEditingController(text: widget.community?.description ?? '');
    _locationController = TextEditingController(text: widget.community?.location ?? '');
    _primaryColorController = TextEditingController(text: widget.community?.primaryColor ?? '0xFF891427');
    _secondaryColorController = TextEditingController(text: widget.community?.secondColor ?? '0xFF891427');

    final primaryColor = widget.community?.primaryColor;
    final secondColor = widget.community?.secondColor;
    if (primaryColor != null) {
      _selectedPrimaryColor = _parseColor(primaryColor);
    }
    if (secondColor != null) {
      _selectedSecondaryColor = _parseColor(secondColor);
    }
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('0x', '0xff')));
    } catch (e) {
      return AppTokens.primaryColor;
    }
  }

  void _showColorPicker(bool isPrimary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isPrimary ? 'Color Primario' : 'Color Secundario'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildColorGrid(isPrimary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorGrid(bool isPrimary) {
    final colors = [
      Color(0xFF891427),
      Color(0xFF1E88E5),
      Color(0xFF43A047),
      Color(0xFFFDD835),
      Color(0xFFF4511E),
      Color(0xFF6A1B9A),
      Color(0xFF00897B),
      Color(0xFF0097A7),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      children: colors.map((color) {
        return InkWell(
          onTap: () {
            setState(() {
              if (isPrimary) {
                _selectedPrimaryColor = color;
                _primaryColorController.text = '0x${color.value.toRadixString(16).toUpperCase().padLeft(8, '0')}';
              } else {
                _selectedSecondaryColor = color;
                _secondaryColorController.text = '0x${color.value.toRadixString(16).toUpperCase().padLeft(8, '0')}';
              }
            });
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: (isPrimary ? _selectedPrimaryColor : _selectedSecondaryColor) == color
                    ? Colors.white
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _primaryColorController.dispose();
    _secondaryColorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.community == null ? 'Crear Comunidad' : 'Editar Comunidad'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Nombre de la comunidad',
              ),
            ),
            SizedBox(height: AppTokens.space16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Descripción de la comunidad',
              ),
              maxLines: 3,
            ),
            SizedBox(height: AppTokens.space16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Ubicación',
                hintText: 'Ubicación de la comunidad',
              ),
            ),
            SizedBox(height: AppTokens.space16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _selectedPrimaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const SizedBox(height: 40),
                  ),
                ),
                SizedBox(width: AppTokens.space12),
                ElevatedButton(
                  onPressed: () => _showColorPicker(true),
                  child: const Text('Color Primario'),
                ),
              ],
            ),
            SizedBox(height: AppTokens.space16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _selectedSecondaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const SizedBox(height: 40),
                  ),
                ),
                SizedBox(width: AppTokens.space12),
                ElevatedButton(
                  onPressed: () => _showColorPicker(false),
                  child: const Text('Color Secundario'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final data = {
              'name': _nameController.text,
              'description': _descriptionController.text,
              'location': _locationController.text,
              'primary_color': _primaryColorController.text,
              'second_color': _secondaryColorController.text,
              'id': widget.community?.id,
            };
            widget.onSave(data);
          },
          child: Text(widget.community == null ? 'Crear' : 'Actualizar'),
        ),
      ],
    );
  }
}
