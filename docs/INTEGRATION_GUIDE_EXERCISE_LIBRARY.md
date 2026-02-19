# Guide d'Intégration Exercise Library

Guide pas à pas pour intégrer le catalogue d'exercices Workout API dans votre application Apollon.

## 📋 Prérequis

- ✅ Firebase configuré (Firestore + Storage)
- ✅ Flutter SDK installé
- ✅ Fichier `workout_api_exercises_fr.json` présent dans `docs/`

## 🚀 Étapes d'installation

### Étape 1: Installation des dépendances

Les dépendances sont déjà ajoutées dans `pubspec.yaml`. Installez-les:

```bash
flutter pub get
```

### Étape 2: Configurer les règles Firestore

1. Ouvrez [Firebase Console](https://console.firebase.google.com)
2. Sélectionnez votre projet Apollon
3. Allez dans **Firestore Database** → **Règles**
4. Copiez le contenu de `docs/firestore-rules-exercise-library.rules`
5. Publiez les règles

**Règle clé pour exercises_library:**
```javascript
match /exercises_library/{exerciseId} {
  allow read: if true; // Lecture publique
  allow write: if request.auth != null && request.auth.token.admin == true;
}
```

### Étape 3: Configurer les règles Firebase Storage

1. Allez dans **Storage** → **Règles**
2. Copiez le contenu de `docs/storage-rules-exercise-library.rules`
3. Publiez les règles

**Règle clé pour exercise_images:**
```javascript
match /exercise_images/{imageId} {
  allow read: if true; // Lecture publique
  allow write: if request.auth != null; // Lazy loading
}
```

### Étape 4: Importer les données dans Firestore

Depuis la racine du projet:

```bash
dart scripts/import_workout_api_exercises.dart
```

**Sortie attendue:**
```
🚀 Import des exercices Workout API vers Firestore

📱 Initialisation Firebase...
✅ Firebase initialisé

📖 Lecture du fichier workout_api_exercises_fr.json...
✅ 94 exercices trouvés

📝 Import en cours...
   ✅ Batch de 94 exercices importé

==================================================
📊 RÉSUMÉ DE L'IMPORT
==================================================
✅ Succès: 94 exercices
❌ Erreurs: 0 exercices
📦 Total: 94 exercices
==================================================

🔍 Vérification dans Firestore...
✅ 94 documents présents dans Firestore

🎉 Import terminé avec succès!
```

### Étape 5: Intégrer le Provider dans main.dart

Modifiez votre `lib/main.dart` pour inclure le provider:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Providers existants
import 'core/providers/auth_provider.dart';
import 'core/providers/workout_provider.dart';
import 'core/providers/theme_provider.dart';

// NOUVEAU: Exercise Library Provider
import 'features/exercise_library/exercise_library.dart';

import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        // Providers existants
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        
        // NOUVEAU: Exercise Library Provider
        ChangeNotifierProvider(
          create: (_) => ExerciseLibraryProvider(
            ExerciseLibraryRepository(),
          ),
        ),
      ],
      child: const ApolloApp(),
    ),
  );
}
```

### Étape 6: Naviguer vers l'écran de sélection

Dans votre écran de création de séance, ajoutez la navigation:

```dart
import 'package:apollon/features/exercise_library/exercise_library.dart';

class WorkoutCreationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle séance')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => _selectExercise(context),
          icon: const Icon(Icons.add),
          label: const Text('Ajouter un exercice'),
        ),
      ),
    );
  }

  Future<void> _selectExercise(BuildContext context) async {
    final exercise = await Navigator.push<ExerciseLibrary>(
      context,
      MaterialPageRoute(
        builder: (_) => const ExerciseLibrarySelectionScreen(),
      ),
    );

    if (exercise != null) {
      print('✅ Exercice sélectionné: ${exercise.name}');
      // Ajouter à votre WorkoutProvider...
    }
  }
}
```

## ✅ Vérification

### 1. Vérifier Firestore

1. Ouvrez Firebase Console
2. Firestore Database → Data
3. Vous devriez voir la collection `exercises_library` avec 94 documents

### 2. Tester l'écran de sélection

```bash
flutter run
```

1. Lancez l'app
2. Naviguez vers l'écran de sélection d'exercice
3. Vérifiez que:
   - ✅ Les 94 exercices s'affichent
   - ✅ La recherche fonctionne
   - ✅ Les filtres fonctionnent
   - ✅ Le détail affiche la description complète

### 3. Tester le lazy loading des images

1. Sélectionnez un exercice pour la première fois
2. Observez le loader pendant téléchargement (~500ms)
3. Revenez en arrière et re-sélectionnez
4. L'image devrait s'afficher instantanément (cache)

### 4. Vérifier Firebase Storage

1. Firebase Console → Storage
2. Vous devriez voir le dossier `exercise_images/`
3. Les images téléchargées apparaissent au fur et à mesure

## 🎨 Personnalisation

### Option 1: Remplacer l'écran existant

Si vous avez déjà un `ExerciseSelectionScreen`, vous pouvez le remplacer:

```dart
// Avant
import '../../screens/workout/exercise_selection_screen.dart';

// Après
import 'package:apollon/features/exercise_library/exercise_library.dart';

// Utiliser ExerciseLibrarySelectionScreen au lieu de ExerciseSelectionScreen
```

### Option 2: Migration progressive

Gardez les deux systèmes en parallèle:

```dart
// Route vers ancien système
Navigator.push(context, MaterialPageRoute(
  builder: (_) => ExerciseSelectionScreen(), // Old system
));

// Route vers nouveau système
Navigator.push(context, MaterialPageRoute(
  builder: (_) => ExerciseLibrarySelectionScreen(), // New system
));
```

Ajoutez un toggle dans les paramètres pour tester.

### Option 3: Conversion des données

Créez un adaptateur pour convertir `ExerciseLibrary` → `Exercise`:

```dart
extension ExerciseLibraryExtension on ExerciseLibrary {
  Exercise toLegacyExercise() {
    return Exercise(
      id: id,
      name: name,
      muscleGroups: primaryMuscles.map((m) => m.name).toList(),
      type: categories.first.name,
      emoji: '🏋️',
      description: description,
    );
  }
}
```

## 🐛 Dépannage

### Erreur: "Permission denied on exercises_library"

**Solution:** Vérifiez les règles Firestore. La lecture doit être publique:
```javascript
allow read: if true;
```

### Erreur: "Object not found" sur les images

**Solution:** 
1. Vérifiez Firebase Storage est activé
2. Vérifiez les règles Storage permettent l'écriture authentifiée
3. Configurez votre clé API Workout dans `exercise_library_repository.dart`

### Les exercices ne se chargent pas

**Solution:**
1. Vérifiez que le script d'import a été exécuté
2. Vérifiez Firebase est initialisé avant le provider
3. Activez les logs de debug:

```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);

FirebaseFirestore.setLoggingEnabled(true); // Debug mode
```

### Performance lente

**Solution:**
1. Vérifiez le cache est activé (par défaut)
2. Activez la persistence Firestore
3. Limitez les filtres simultanés
4. Pré-chargez les images populaires:

```dart
final provider = context.read<ExerciseLibraryProvider>();
await provider.preloadVisibleImages();
```

## 📚 Ressources supplémentaires

- [README Feature](README.md) - Documentation complète
- [User Story US-003](../../docs/briefs/USER_STORY_WORKOUT_API_INTEGRATION.md)
- [Brief Technique](../../docs/briefs/BRIEF_TECHNIQUE_WORKOUT_API_INTEGRATION.md)
- [Firebase Firestore](https://firebase.google.com/docs/firestore)
- [Firebase Storage](https://firebase.google.com/docs/storage)
- [Provider Package](https://pub.dev/packages/provider)

## 🎯 Checklist finale

Avant de mettre en production:

- [ ] ✅ Script d'import exécuté (94 exercices dans Firestore)
- [ ] ✅ Règles Firestore configurées
- [ ] ✅ Règles Storage configurées
- [ ] ✅ Provider ajouté dans main.dart
- [ ] ✅ Navigation fonctionnelle
- [ ] ✅ Recherche testée
- [ ] ✅ Filtres testés
- [ ] ✅ Lazy loading images testé
- [ ] ✅ Performance < 1s validée
- [ ] ✅ Mode offline testé (cache)
- [ ] 🔲 Clé API Workout configurée (optionnel si pas de nouvelles images)
- [ ] 🔲 Analytics configurés (optionnel)
- [ ] 🔲 Tests unitaires écrits (optionnel)

## ✨ Félicitations !

Vous avez maintenant un catalogue professionnel de 94 exercices avec lazy loading et filtres avancés ! 🎉

Pour toute question, consultez le [README.md](README.md) ou les briefs techniques.

---

**Auteur:** Flutter Developer Expert  
**Date:** 17 février 2026
