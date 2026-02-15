import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/providers/auth_provider.dart' as app_providers;
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_page.dart';

/// Widget principal de l'application Apollon
/// Implémente US-1.2: Auto-login au démarrage
/// Implémente US-3.3: Theme switcher Dark/Light
/// Gère la navigation entre LoginScreen et HomePage selon l'état d'authentification
class ApolloApp extends StatelessWidget {
  const ApolloApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Utilise le ThemeProvider pour gérer le thème
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Apollon',
          debugShowCheckedModeBanner: false,
          
          // Utilise les thèmes définis dans app_theme.dart (US-3.1)
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          
          // StreamBuilder pour gérer l'auto-login (US-1.2)
          home: Consumer<app_providers.AuthProvider>(
            builder: (context, authProvider, child) {
              return StreamBuilder<User?>(
                stream: authProvider.authStateChanges,
                builder: (context, snapshot) {
                  // Attendre la vérification de l'état d'authentification
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingScreen(context);
                  }
                  
                  // Si utilisateur connecté → HomePage
                  // Si non connecté → LoginScreen
                  final user = snapshot.data;
                  return user != null ? const HomePage() : const LoginScreen();
                },
              );
            },
          ),
        );
      },
    );
  }

  /// Écran de chargement pendant vérification auth
  /// Utilise le thème pour afficher le loader avec les bonnes couleurs
  Widget _buildLoadingScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
