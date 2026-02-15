/// Système de thème complet Apollon avec effet Liquid Glass
/// 
/// Ce fichier exporte tous les éléments du Design System.
/// 
/// Composants exportés :
/// - AppColors : Palette de couleurs et ColorScheme Material 3
/// - AppTypography : Styles de texte avec Google Fonts
/// - AppDecorations : Décorations glassmorphisme et effets
/// - AppTheme : ThemeData complet (light/dark)
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
/// 
/// Usage dans widgets :
/// ```dart
/// import 'package:apollon/core/theme/app_colors.dart';
/// import 'package:apollon/core/theme/app_typography.dart';
/// import 'package:apollon/core/theme/app_decorations.dart';
/// 
/// Container(
///   decoration: AppDecorations.glass(context),
///   child: Text(
///     'Hello',
///     style: AppTypography.titleLarge(context),
///   ),
/// )
/// ```

library app_theme;

export 'app_colors.dart';
export 'app_typography.dart';
export 'app_decorations.dart';
export 'app_theme.dart';
