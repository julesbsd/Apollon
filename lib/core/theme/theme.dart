/// Système de thème Apollon
///
/// Ce fichier exporte le Design System.
///
/// Composant exporté :
/// - AppTheme : ThemeData complet (light/dark), palette de couleurs,
///   typographie (Inter) et tokens spacing/radius du design "Moderne
///   Épuré Bleu" V2 (seed 0xFF4A90E2), seul système de thème consommé
///   par MaterialApp.
///
/// Le systeme legacy "Liquid Glass" (AppColors, AppTypography,
/// AppDecorations) a ete decommissionne : plus aucun usage ne subsistait
/// hors de ces fichiers eux-memes (voir CLAUDE.md, section Conventions).
///
/// Usage dans main.dart :
/// ```dart
/// import 'package:apollon/core/theme/app_theme.dart';
///
/// MaterialApp(
///   theme: AppTheme.lightTheme,
///   darkTheme: AppTheme.darkTheme,
///   themeMode: ThemeMode.system,
/// )
/// ```

library;

export 'app_theme.dart';
