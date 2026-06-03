# Apollon - Memoire projet Claude Code

## Vue d'ensemble

Apollon est une application Flutter de suivi de musculation (strength-training). L'utilisateur enregistre ses seances de salle (exercices, series reps x poids), consulte son historique et visualise sa progression (statistiques, records personnels, heatmap). Le backend est Firebase (Authentification Google, Cloud Firestore avec persistance offline, Firebase Storage). La gestion d'etat repose sur `package:provider` + `ChangeNotifier`. L'UI suit un design system "Liquid Glass" (glassmorphism, Material 3, coins arrondis 24px, themes Dark/Light, cible 60fps). Le code shippe correspond au MVP V1 (version `pubspec.yaml` 1.0.0+1, jalon documente 1.0.1) et inclut deja des fonctionnalites V2 (statistiques, records personnels, bibliotheque d'exercices a images hybrides).

## Commandes essentielles

```bash
# Dependances
flutter pub get

# Lancer l'app
flutter run

# Tests (modeles + widgets, mocks mocktail)
flutter test

# Analyse statique / lint
flutter analyze

# Build Android
flutter build apk

# Deploiement Firebase (cibles definies dans firebase.json)
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
firebase deploy --only firestore          # rules + indexes
firebase deploy --only storage            # storage.rules
firebase deploy                           # firestore (rules+indexes) + storage

# Scripts d'import du catalogue (Node.js, dossier scripts/)
cd scripts; npm install; npm run seed          # -> seed_exercises_node.js
cd scripts; npm install; npm run import-library # -> import_exercise_library.js
```

Note: `firebase.json` ne definit PAS de cible `hosting` ni `functions`. `firebase deploy --only hosting` / `--only functions` ne sont donc PAS valides pour ce projet.

## Architecture

L'application est structuree en `lib/core/` (logique transverse) et `lib/screens/<feature>/` (ecrans par fonctionnalite).

```
lib/
  main.dart                         # Bootstrap (voir ci-dessous)
  app.dart                          # ApolloApp (MaterialApp + auth gate) - PAS dans main.dart
  firebase_options.dart             # Config Firebase generee
  secrets.dart                      # workoutApiKey (gitignore)

  core/
    models/                         # Modeles de domaine (barrel: models.dart)
      workout.dart                  # Workout = seance complete (users/{userId}/workouts), enum WorkoutStatus {draft, completed}
      workout_exercise.dart         # WorkoutExercise = un exercice + sa liste de series dans une seance
      workout_set.dart              # WorkoutSet = une serie (int reps, double weight), valide reps>0 et weight>=0 (RG-003)
      exercise_library.dart         # ExerciseLibrary = exercice du catalogue (collection exercises_library)
      muscle_info.dart              # MuscleInfo (code + nom muscle cible)
      type_info.dart                # TypeInfo (type d'exercice, ex ISOLATION/COMPOUND)
      category_info.dart            # CategoryInfo (categorie equipement, ex FREE_WEIGHT/MACHINE)
      statistics.dart              # Statistics + ProgressDataPoint + VolumeDataPoint
      personal_record.dart          # PersonalRecord (PR poids max, users/{userId}/personal_records)
      exercise_image_manifest.dart  # Charge assets/exercise_images/manifest.json (images top-20 pre-seedees)
      # NB: pas de modele User dedie - l'objet firebase_auth User est utilise directement

    providers/                      # Etat (ChangeNotifier)
      auth_provider.dart            # AuthProvider (wrappe AuthService): user, isAuthenticated, signInWithGoogle/signOut
      workout_provider.dart         # WorkoutProvider: seance draft en cours, addExercise/addSet, Timer auto-save 10s (RG-004), Timer chrono 1s, completeWorkout
      theme_provider.dart           # ThemeProvider: ThemeMode persiste via shared_preferences ('app_theme_mode')
      exercise_library_provider.dart # ExerciseLibraryProvider: catalogue + recherche/filtres muscle/categorie/type cote client

    services/                       # Acces Firebase (barrel: services.dart)
      auth_service.dart             # FirebaseAuth + GoogleSignIn + Firestore, ecrit le profil users/{uid} (Map brute)
      workout_service.dart          # CRUD Firestore users/{userId}/workouts (createWorkout, updateWorkout, getWorkouts stream, getCurrentDraft, getLastWorkoutForExercise RG-005, cleanupOldDrafts, pagination)
      statistics_service.dart       # Calcul Statistics + graphes, streaks, detectAndSaveNewPR (users/{userId}/personal_records)
      exercise_library_repository.dart # Firestore exercises_library, cache memoire 30 min, strategie image triple (asset/local/remote), enum ImageSourceType, classe ImageSource
      exercise_image_downloader.dart # Telecharge SVG depuis api.workoutapi.com (http), stocke dans app docs dir, manifest shared_preferences

    theme/                          # Design system (barrel: theme.dart)
      app_colors.dart               # AppColors (ColorScheme.fromSeed, seed 0xFF1E88E5, accents or, palettes mesh-gradient)
      app_typography.dart           # AppTypography (Google Fonts: Cinzel titres, Raleway corps, JetBrains Mono nombres)
      app_decorations.dart          # AppDecorations (BoxDecorations glassmorphism, blur ImageFilters)
      app_theme.dart                # AppTheme "Design Moderne Epure Bleu" V2 (Inter, primaryBlue 0xFF4A90E2), lightTheme/darkTheme + tokens spacing/radius

    utils/
      page_transitions.dart         # AppPageRoute (slideUp/slideRight/fade/scale/fadeSlide), enum AppPageTransitionType

    widgets/                        # Widgets reutilisables (barrel: widgets.dart)
      app_background.dart           # AppBackground (fond degrade)
      app_bar.dart                  # AppBarWidget (Material3 AppBar)
      app_button.dart               # AppButton (anime) + AppButtonVariant
      app_card.dart                 # AppCard (anime) + AppCardVariant
      app_text_field.dart           # AppTextField
      theme_switcher.dart           # ThemeSwitcher (Consumer<ThemeProvider>)
      glass_orb_button.dart         # GlassOrbButton (bouton glassmorphism avec progress)
      profile_drawer.dart           # ProfileDrawer (lit AuthProvider + WorkoutProvider)
      mesh_gradient_background.dart # MeshGradientBackground (mesh 4 couleurs anime)
      floating_workout_timer.dart   # FloatingWorkoutTimer (timer global type Dynamic Island, lit WorkoutProvider)
      marble_card.dart              # MarbleCard (carte texture marbre)
      modern_circular_progress.dart # CircularProgressCard
      pr_celebration_overlay.dart   # showPrCelebration() + popup confetti (package:confetti)

  screens/
    auth/login_screen.dart          # LoginScreen - connexion Google (US-1.1), MeshGradientBackground
    home/home_page.dart             # HomePage - dashboard, navigue vers selection / historique / stats / records
    workout/workout_session_screen.dart # WorkoutSessionScreen(ExerciseLibrary exercise) - saisie series + historique + auto-save (US-4.3)
    exercise_library/
      exercise_library_selection_screen.dart # ExerciseLibrarySelectionScreen - recherche + TabBar muscles + FilterChips equipement
      widgets/exercise_image_widget.dart      # ExerciseImageWidget/Avatar/Container/Thumbnail (lazy loading)
      widgets/exercise_library_tile.dart      # ExerciseLibraryTile (tuile catalogue)
      widgets/exercise_history_graph_panel.dart # ExerciseHistoryGraphPanel (historique + graphe progression)
    history/
      history_screen.dart           # HistoryScreen - liste seances (US-5.1), pagination/filtres/recherche
      workout_detail_screen.dart    # WorkoutDetailScreen(Workout) - detail seance + suppression confirmee (US-5.2)
    statistics/
      statistics_screen.dart        # StatisticsScreen - dashboard graphes (EPIC-V2-1)
      personal_records_screen.dart  # PersonalRecordsScreen(String userId) - liste des records, tri date/poids
      widgets/exercise_progress_chart.dart   # ExerciseProgressChart
      widgets/volume_bar_chart.dart          # VolumeBarChart
      widgets/workout_heatmap_calendar.dart  # WorkoutHeatmapCalendar
```

### Bootstrap (lib/main.dart)

`main()` est async et execute, dans l'ordre: `WidgetsFlutterBinding.ensureInitialized()` ; `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` ; `initializeDateFormatting('fr_FR', null)` ; `ExerciseImageManifest.load()` ; instanciation et `init()` du `ThemeProvider` ; instanciation de `WorkoutService` et `ExerciseLibraryRepository(manifest, apiKey: secrets.workoutApiKey)`. Puis `runApp` enveloppe un `MultiProvider` (5 providers) autour de `const ApolloApp()`.

`main.dart` ne fait QUE le bootstrap + cablage des providers. Le widget racine `ApolloApp` (MaterialApp + auth gate) vit dans `lib/app.dart`.

### Flux d'etat (Provider / ChangeNotifier)

`MultiProvider` enregistre 5 entrees :
- `ChangeNotifierProvider(AuthProvider)`
- `ChangeNotifierProvider.value(themeProvider)` (ThemeProvider, deja initialise)
- `ChangeNotifierProvider(WorkoutProvider(workoutService))`
- `Provider<ExerciseLibraryRepository>.value(exerciseRepository)` (Provider simple, pas ChangeNotifier)
- `ChangeNotifierProvider(ExerciseLibraryProvider(exerciseRepository))`

`ApolloApp` construit un `Consumer<ThemeProvider>` autour de `MaterialApp` (`theme: AppTheme.lightTheme`, `darkTheme: AppTheme.darkTheme`, `themeMode: themeProvider.themeMode`). Le `builder` superpose un `FloatingWorkoutTimer` global via un `Stack`. L'`auth gate` est un `Consumer<AuthProvider>` + `StreamBuilder<User?>(stream: authProvider.authStateChanges)` : spinner pendant `waiting`, sinon `HomePage` si connecte, sinon `LoginScreen`.

Navigation : 100% imperative (`Navigator.of(context).push(...)`) avec les transitions custom de `core/utils/page_transitions.dart`. Pas de table de routes nommees, pas d'`onGenerateRoute`, pas de GoRouter.

## Stack & dependances

Contrainte SDK : `environment.sdk: ^3.11.0` (Dart 3.11+).

Dependances runtime (versions exactes `pubspec.yaml`) :
- `cupertino_icons: ^1.0.8`
- `google_fonts: ^6.1.0`
- `firebase_core: ^2.24.0`, `firebase_auth: ^4.16.0`, `cloud_firestore: ^4.14.0`, `firebase_storage: ^11.5.6`
- `google_sign_in: ^6.1.6`
- `provider: ^6.1.1`
- `http: ^1.1.0`, `cached_network_image: ^3.3.0`, `flutter_svg: ^2.2.3`
- `fl_chart: ^0.68.0`, `confetti: ^0.7.0`, `flutter_heatmap_calendar: ^1.0.5`
- `intl: ^0.19.0`
- `shared_preferences: ^2.2.2`, `path_provider: ^2.1.5`

Dev : `flutter_test` (sdk), `flutter_lints: ^6.0.0`, `mocktail: any`.

Note structurelle : `mocktail: any` est mal indente dans `pubspec.yaml` (ligne 84, apres le bloc `dev_dependencies`, juste avant la section `flutter:`). Il resout malgre tout, mais la structure du fichier est irreguliere.

## Backend Firebase

Projet Firebase : `apollon-fitness-app`. Firestore : base `(default)`, region `europe-west9`.

Auth : Google Sign-In uniquement (firebase_auth + google_sign_in). Aucune donnee n'est accessible sans connexion (RG-001).

Collections Firestore (d'apres `firestore.rules`, `rules_version '2'`) :
- `users/{userId}` - lecture/ecriture proprietaire uniquement. `create` exige `email`, `displayName`, `createdAt`.
- `users/{userId}/workouts/{workoutId}` - proprietaire uniquement. Document valide : cles `date`, `status`, `exercises`, `createdAt`, `updatedAt` ; `status` dans `['draft','completed']`. Chaque exercice : `exerciseId`(string), `exerciseName`(string), `sets`(list non vide). Chaque serie : `reps`(int>0), `weight`(number>=0) (RG-003). La validation detaillee des exercices/series est deleguee au client.
- `users/{userId}/personal_records/{recordId}` - proprietaire uniquement. `create` exige `userId`, `exerciseId`, `exerciseName`, `weight>0`, `reps>0`, `achievedAt`.
- `exercises_library/{exerciseId}` - lecture publique (`if true`), ecriture `if isAuthenticated()` (import via script Admin SDK).
- `/{document=**}` - deny all par defaut.

Fichiers de configuration :
- Regles : `firestore.rules` et `storage.rules`.
- Index : `firestore.indexes.json` - un index composite (queryScope `COLLECTION`) sur la sous-collection `workouts` : `status` ASC + `createdAt` DESC. Il sert la requete paginee `getUserWorkouts` (`workout_service.dart`) ; le code n'utilise aucune requete `collectionGroup()`.
- Storage (`storage.rules`) : `exercise_images/{imageId}` lecture publique / ecriture authentifiee ; `user_uploads/{userId}/{allPaths=**}` proprietaire, ecriture < 5 Mo ; deny all par defaut.

Scripts d'import (dossier `scripts/`, Node.js + firebase-admin) : `npm run seed` (seed_exercises_node.js) et `npm run import-library` (import_exercise_library.js). L'auth se fait via `serviceAccountKey.json` (ne JAMAIS committer cette cle).

Divergence connue : le rule definit le catalogue public `exercises_library`, mais `seed_exercises_node.js` ecrit dans une collection nommee `exercises`. Le code applicatif lit `exercises_library`.

## Conventions

- Lint : `analysis_options.yaml` inclut `package:flutter_lints/flutter.yaml`. La section `linter.rules:` ne contient que des exemples commentes (`avoid_print`, `prefer_single_quotes`) : AUCUNE regle custom active. Ruleset = `flutter_lints` standard.
- ZERO emoji dans le code, les messages de commit et les documents techniques (dont ce fichier).
- Commentaires en francais, identifiants (classes, methodes, variables) en anglais.
- Design "Liquid Glass" : glassmorphism, coins arrondis 24px, themes Dark et Light, cible de fluidite 60fps.
- Attention : deux systemes de theme coexistent dans `lib/core/theme/`. Le systeme legacy "Liquid Glass" (`AppColors` + `AppTypography` Cinzel/Raleway/JetBrains Mono + `AppDecorations`, seed `0xFF1E88E5`) ET le plus recent `AppTheme` (`app_theme.dart`, "Design Moderne Epure Bleu" V2, police Inter, `0xFF4A90E2`). `MaterialApp` consomme `AppTheme` ; le barrel `theme.dart` exporte les deux, ce qui peut produire un styling incoherent.

## Regles metier

Glossaire (hierarchie UTILISATEUR -> SEANCES -> EXERCICES -> SERIES) :
- EXERCICE : mouvement lie a une variante d'equipement/machine, nom unique, appartient a 1+ groupes musculaires, possede un Type, contient des Series dans une Seance.
- GROUPE MUSCULAIRE : zone anatomique ciblee (Pectoraux, Biceps, Triceps, Abdominaux, Quadriceps, Fessiers, Dorsaux, Epaules) ; systeme de navigation principal.
- TYPE EXERCICE : nature de l'equipement/execution (Poids libres, Machine guidee, Poids corporel, Cardio) ; filtre secondaire.
- SERIE : repetitions continues sans pause ; `reps` (int > 0) et `poids` kg (decimal >= 0, ou 0 = poids corporel) ; liee a UN exercice dans UNE seance.
- SEANCE : session complete ; `date` (obligatoire, ISO 8601) + `duree` (optionnelle) ; workflow Nouvelle seance -> ajouter -> Terminer.
- UTILISATEUR : pratiquant ; auth Google obligatoire ; isolation totale de ses donnees.

Regles de gestion :
- RG-001 (Critique) : authentification Google obligatoire ; ecran de login affiche si non authentifie.
- RG-002 (Haute) : unicite des noms d'exercices (pas de doublon).
- RG-003 (Haute) : validation des series - `reps` entier strictement positif (> 0), `poids` decimal >= 0 (0 kg = poids corporel) ; valide cote client ET cote serveur (Firestore Rules).
- RG-004 (Haute) : persistance de la seance en cours - reste active en arriere-plan/verrouillage ; auto-save continu (draft local + Firestore) ; draft conserve 24h max ; notification persistante "Seance en cours" = V2.
- RG-005 (Moyenne) : affichage de l'historique d'un exercice - en V1, texte simple (date + series reps x poids de la derniere seance) ; graphes de progression = V2.
- RG-006 (Critique) : enregistrement final - la seance n'est finalisee et sauvee definitivement qu'au clic "Terminer la seance" ; avant cela elle reste un draft.

Processus critique P2 - Enregistrer une seance (processus principal, criticite CRITIQUE) :
1. "Nouvelle seance".
2. Selectionner un exercice (par Groupe Musculaire OU Type OU recherche par nom).
3. Affichage automatique de l'historique de la derniere seance de cet exercice (ou "Pas de seance pour l'instant").
4. Ajouter des series (`reps` int > 0, `poids` decimal >= 0), repeter.
5. Repeter pour d'autres exercices.
6. "Terminer la seance" = sauvegarde definitive Firestore.
Applique RG-002 a RG-006 ; couvre les cas limites EC-001 a EC-004. (P1 = premiere connexion / login Google ; P3 = consulter l'historique, tri date descendante.)

Cas limites :
- EC-001 : premiere utilisation d'un exercice -> "Pas de seance pour l'instant".
- EC-002 : draft abandonne -> conserve 24h ; au-dela, suppression auto OU dialogue "Reprendre seance du XX/XX ?".
- EC-003 : perte de connexion -> mode offline natif Firestore, cache local, sync auto a la reconnexion.
- EC-004 : suppression a 3 niveaux avec confirmation (serie, exercice, seance) ; V1 = suppression definitive (pas d'annulation).

## Documentation existante

Pour le contexte detaille, voir :
- `README.md` - presentation, glossaire, modele de donnees.
- `DOCUMENTATION.md` - documentation technique.
- `STATUS.md` - etat du projet (jalon 1.0.1, MVP V1 production-ready).
- `CHANGELOG.md` - historique des versions.
- `AUDIT-PERFORMANCE-MVP-V1.md` - audit de performance et dette technique.
- `BUGFIX-HISTORIQUE.md` - historique des corrections (Bug#1 duree seance, Bug#2 refresh apres suppression).
- `_byan-output/bmb-creations/` - contexte projet (ProjectContext-Apollon.yaml, VALIDATION-FINALE-MVP-V1.md).
