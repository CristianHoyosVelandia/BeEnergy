/// Servicio de Almacenamiento para Datos de Tema de Comunidad
///
/// Gestiona la persistencia de colores, imágenes y topología de comunidad.
/// Estos datos son la "fuente de verdad" para personalizar el tema de la app.
library;

import 'package:shared_preferences/shared_preferences.dart';

class CommunityThemeStorage {
  static const String _keyPrimaryColor = 'community_primary_color';
  static const String _keySecondColor = 'community_second_color';
  static const String _keyUrlImg = 'community_url_img';
  static const String _keyTopology = 'community_topology';
  static const String _keyCurrentCommunityId = 'current_community_id';

  /// Colores por defecto
  static const String defaultPrimaryColor = '0xFF891427';
  static const String defaultSecondColor = '0xFF891427';
  static const String defaultUrlImg = '';
  static const int defaultTopology = 2;

  /// Guarda los datos del tema de comunidad en storage
  Future<void> saveCommunityTheme({
    required String primaryColor,
    required String secondColor,
    required String urlImg,
    required int topology,
    required int communityId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_keyPrimaryColor, primaryColor),
      prefs.setString(_keySecondColor, secondColor),
      prefs.setString(_keyUrlImg, urlImg),
      prefs.setInt(_keyTopology, topology),
      prefs.setInt(_keyCurrentCommunityId, communityId),
    ]);
  }

  /// Obtiene el color primario guardado
  Future<String> getPrimaryColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPrimaryColor) ?? defaultPrimaryColor;
  }

  /// Obtiene el color secundario guardado
  Future<String> getSecondColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySecondColor) ?? defaultSecondColor;
  }

  /// Obtiene la URL de imagen guardada
  Future<String> getUrlImg() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUrlImg) ?? defaultUrlImg;
  }

  /// Obtiene la topología guardada
  Future<int> getTopology() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTopology) ?? defaultTopology;
  }

  /// Obtiene la comunidad actual
  Future<int?> getCurrentCommunityId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCurrentCommunityId);
  }

  /// Obtiene todos los datos del tema
  Future<Map<String, dynamic>> getThemeData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'primaryColor': prefs.getString(_keyPrimaryColor) ?? defaultPrimaryColor,
      'secondColor': prefs.getString(_keySecondColor) ?? defaultSecondColor,
      'urlImg': prefs.getString(_keyUrlImg) ?? defaultUrlImg,
      'topology': prefs.getInt(_keyTopology) ?? defaultTopology,
      'currentCommunityId': prefs.getInt(_keyCurrentCommunityId),
    };
  }

  /// Inicializa los datos por defecto si no existen
  Future<void> initializeDefaults() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(_keyPrimaryColor)) {
      await prefs.setString(_keyPrimaryColor, defaultPrimaryColor);
    }
    if (!prefs.containsKey(_keySecondColor)) {
      await prefs.setString(_keySecondColor, defaultSecondColor);
    }
    if (!prefs.containsKey(_keyUrlImg)) {
      await prefs.setString(_keyUrlImg, defaultUrlImg);
    }
    if (!prefs.containsKey(_keyTopology)) {
      await prefs.setInt(_keyTopology, defaultTopology);
    }
  }

  /// Limpia los datos del tema (útil para logout)
  Future<void> clearThemeData() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_keyPrimaryColor),
      prefs.remove(_keySecondColor),
      prefs.remove(_keyUrlImg),
      prefs.remove(_keyTopology),
      prefs.remove(_keyCurrentCommunityId),
    ]);
  }

  /// Convierte string de color (ej: "0xFF891427") a Color
  static int parseColorString(String colorString) {
    try {
      return int.parse(colorString);
    } catch (_) {
      return int.parse(defaultPrimaryColor);
    }
  }
}
