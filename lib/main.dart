import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'core/providers/auth_provider.dart' as app_providers;
import 'core/providers/theme_provider.dart';
import 'core/providers/workout_provider.dart';
import 'core/services/workout_service.dart';
import 'core/models/exercise_image_manifest.dart';
import 'core/services/exercise_library_repository.dart';
import 'core/providers/exercise_library_provider.dart';
import 'app.dart';
import 'secrets.dart' as secrets;

/// Point d'entrée de l'application Apollon
/// Initialise Firebase, charge le manifest d'images et configure les Providers
void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  // Initialiser Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialiser les données de locale pour DateFormat
  await initializeDateFormatting('fr_FR', null);

  // Charger le manifest d'images d'exercices (top 20)
  final exerciseImageManifest = await ExerciseImageManifest.load();

  // Initialiser le ThemeProvider
  final themeProvider = ThemeProvider();
  await themeProvider.init();

  // Initialiser les services
  final workoutService = WorkoutService();
  
  // Créer le repository d'exercices (nécessaire pour les widgets d'images)
  final exerciseRepository = ExerciseLibraryRepository(
    manifest: exerciseImageManifest,
    apiKey: secrets.workoutApiKey,
  );

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

        // ExerciseLibraryRepository (requis pour ExerciseImageWidget)
        Provider<ExerciseLibraryRepository>.value(value: exerciseRepository),

        // ExerciseLibraryProvider pour catalogue Workout API (US-003)
        ChangeNotifierProvider(
          create: (_) => ExerciseLibraryProvider(exerciseRepository),
        ),
      ],
      child: const ApolloApp(),
    ),
  );
}
