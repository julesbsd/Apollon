import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider pour gérer le thème de l'app (Dark/Light mode)
/// Persist le choix de l'utilisateur avec SharedPreferences
class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  /// Initialise le provider en chargeant le thème depuis le stockage
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);

      if (savedTheme != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == savedTheme,
          orElse: () => ThemeMode.system,
        );
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('[ThemeProvider] Erreur lors du chargement du thème: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Change le thème et persist le choix
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, mode.toString());
    } catch (e) {
      debugPrint('[ThemeProvider] Erreur lors de la sauvegarde du thème: $e');
    }
  }

  /// Toggle entre Dark et Light mode (ignores system)
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    await setThemeMode(newMode);
  }

  /// Set Dark mode
  Future<void> setDarkMode() async {
    await setThemeMode(ThemeMode.dark);
  }

  /// Set Light mode
  Future<void> setLightMode() async {
    await setThemeMode(ThemeMode.light);
  }

  /// Set System mode (suit les paramètres système)
  Future<void> setSystemMode() async {
    await setThemeMode(ThemeMode.system);
  }
}
