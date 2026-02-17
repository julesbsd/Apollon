import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/providers/auth_provider.dart' as app_providers;
import 'core/providers/theme_provider.dart';
import 'core/providers/workout_provider.dart';
import 'core/services/workout_service.dart';
import 'app.dart';

/// Point d'entrée de l'application Apollon
/// Initialise Firebase et configure les Providers
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialiser le ThemeProvider
  final themeProvider = ThemeProvider();
  await themeProvider.init();

  // Initialiser les services
  final workoutService = WorkoutService();

  runApp(
    // Configuration des Providers
    MultiProvider(
      providers: [
        // AuthProvider pour gérer l'authentification (EPIC-1)
        ChangeNotifierProvider(create: (_) => app_providers.AuthProvider()),

        // ThemeProvider pour gérer le thème Dark/Light (EPIC-3.3)
        ChangeNotifierProvider.value(value: themeProvider),

        // WorkoutProvider pour gérer la séance en cours (EPIC-4.4)
        ChangeNotifierProvider(
          create: (_) => WorkoutProvider(workoutService: workoutService),
        ),

        // TODO: Ajouter ExerciseProvider (EPIC-4.2)
      ],
      child: const ApolloApp(),
    ),
  );
}
