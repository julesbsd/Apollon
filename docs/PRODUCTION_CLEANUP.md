# Checklist de Nettoyage pour Production

Ce document liste toutes les modifications à effectuer pour passer de l'environnement de développement/debug à la production.

**⚠️ IMPORTANT** : Ces modifications doivent être appliquées AVANT de créer un build release pour déploiement.

---

## 🔴 Code de Debug à Supprimer

### 1. ExerciseLibraryDetailScreen

**Fichier** : `lib/features/exercise_library/screens/exercise_library_detail_screen.dart`

#### Modification 1 : Retirer emoji debug dans AppBar

**Ligne ~45**

**Avant (DEBUG)** :
```dart
AppBar(
  title: Text('🔥 DEBUG MODE - ${exercise.name}'),
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => Navigator.pop(context),
  ),
)
```

**Après (PRODUCTION)** :
```dart
AppBar(
  title: Text(exercise.name),
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => Navigator.pop(context),
  ),
)
```

#### Modification 2 : Supprimer méthode _buildDebugInfo()

**Lignes ~180-210**

**Action** : Supprimer ENTIÈREMENT la méthode `_buildDebugInfo()` et toutes ses références.

**Code à supprimer** :
```dart
Widget _buildDebugInfo() {
  return FutureBuilder<ImageSource>(
    future: context.read<ExerciseLibraryRepository>().getImageSource(exercise.id),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const SizedBox.shrink();
      }

      final source = snapshot.data!;
      Color bgColor;
      String text;

      switch (source.type) {
        case ImageSourceType.asset:
          bgColor = Colors.green;
          text = 'ASSET (préchargé): ${source.path}';
          break;
        case ImageSourceType.local:
          bgColor = Colors.blue;
          text = 'LOCAL (téléchargé): ${source.path}';
          break;
        case ImageSourceType.remote:
          bgColor = Colors.orange;
          text = 'REMOTE (API): ${source.url}';
          break;
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        color: bgColor.withOpacity(0.8),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    },
  );
}
```

#### Modification 3 : Retirer appel à _buildDebugInfo()

**Ligne ~150**

**Avant (DEBUG)** :
```dart
Column(
  children: [
    _buildHeroImage(),
    if (kDebugMode) _buildDebugInfo(), // ❌ Supprimer cette ligne
    _buildContent(),
  ],
)
```

**Après (PRODUCTION)** :
```dart
Column(
  children: [
    _buildHeroImage(),
    _buildContent(),
  ],
)
```

#### Modification 4 : Supprimer print() statements

**Rechercher et supprimer** :
```dart
print('ExerciseLibraryDetailScreen: Building hero image for ${exercise.name}');
```

---

### 2. ExerciseImageWidget

**Fichier** : `lib/features/exercise_library/widgets/exercise_image_widget.dart`

#### Modification 1 : Supprimer barre de statut debug

**Lignes ~280-320**

**Action** : Supprimer ENTIÈREMENT les méthodes suivantes :
- `_buildDebugStatusBar()`
- `_getDebugColor()`
- `_getDebugText()`

**Code à supprimer** :
```dart
Widget _buildDebugStatusBar() {
  if (_imageSource == null && !_isLoading) {
    return const SizedBox.shrink();
  }

  return Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: _getDebugColor().withOpacity(0.9),
      child: Text(
        _getDebugText(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}

Color _getDebugColor() {
  if (_isLoading) return Colors.orange;
  if (_imageSource == null) return Colors.red;
  
  return switch (_imageSource!.type) {
    ImageSourceType.asset => Colors.green,
    ImageSourceType.local => Colors.blue,
    ImageSourceType.remote => Colors.purple,
  };
}

String _getDebugText() {
  if (_isLoading) return '📥 Downloading...';
  if (_imageSource == null) return '❌ No source';
  
  return switch (_imageSource!.type) {
    ImageSourceType.asset => '✅ ASSET: ${_imageSource!.path}',
    ImageSourceType.local => '💾 LOCAL: ${_imageSource!.path}',
    ImageSourceType.remote => '🌐 REMOTE: ${_imageSource!.url}',
  };
}
```

#### Modification 2 : Retirer barre de statut dans build()

**Ligne ~250**

**Avant (DEBUG)** :
```dart
Widget build(BuildContext context) {
  // ... code initial ...
  
  return Stack(
    children: [
      _buildImage(),
      if (kDebugMode) _buildDebugStatusBar(), // ❌ Supprimer cette ligne
    ],
  );
}
```

**Après (PRODUCTION)** :
```dart
Widget build(BuildContext context) {
  // ... code initial ...
  
  return _buildImage();
}
```

#### Modification 3 : Supprimer TOUS les print() statements

**Rechercher et supprimer dans tout le fichier** :
```dart
print('ExerciseImageWidget: didChangeDependencies called');
print('ExerciseImageWidget: Loading image source for $_exerciseId');
print('ExerciseImageWidget: Image source loaded: $_imageSource');
print('ExerciseImageWidget: Downloading image...');
print('ExerciseImageWidget: Download started for $_exerciseId');
print('ExerciseImageWidget: Download complete. New path: $localPath');
print('ExerciseImageWidget: Download failed: $e');
print('ExerciseImageWidget: Building image for source: ${_imageSource?.type}');
```

**Action** : Supprimer toutes les lignes commençant par `print('ExerciseImageWidget:` dans le fichier.

---

### 3. ExerciseLibrarySelectionScreen

**Fichier** : `lib/features/exercise_library/screens/exercise_library_selection_screen.dart`

#### Modification : Restaurer navigation vers WorkoutSessionScreen

**Ligne ~420**

**Avant (DEBUG - Navigation vers détail pour tests)** :
```dart
void _onExerciseSelected(ExerciseLibrary exercise) async {
  // Navigation temporaire vers détail pour tester images
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ExerciseLibraryDetailScreen(exercise: exercise),
    ),
  );
}
```

**Après (PRODUCTION - Navigation vers séance)** :
```dart
void _onExerciseSelected(ExerciseLibrary exercise) async {
  // Navigation vers écran ajout exercice dans séance
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => WorkoutSessionScreen(selectedExercise: exercise),
    ),
  );
}
```

**⚠️ Note** : Vérifiez que l'import `WorkoutSessionScreen` est présent en haut du fichier :
```dart
import 'package:apollon/screens/workout_session_screen.dart';
```

---

## ✅ Checklist de Validation

Avant de créer le build release, vérifiez que **TOUS** les points suivants ont été complétés :

### Code

- [ ] **ExerciseLibraryDetailScreen** :
  - [ ] Retirer "🔥 DEBUG MODE" de l'AppBar title
  - [ ] Supprimer méthode `_buildDebugInfo()`
  - [ ] Retirer appel `_buildDebugInfo()` dans le build
  - [ ] Supprimer print() statements

- [ ] **ExerciseImageWidget** :
  - [ ] Supprimer méthode `_buildDebugStatusBar()`
  - [ ] Supprimer méthode `_getDebugColor()`
  - [ ] Supprimer méthode `_getDebugText()`
  - [ ] Retirer `_buildDebugStatusBar()` du build (Stack → simple widget)
  - [ ] Supprimer TOUS les print() statements (environ 8-10)

- [ ] **ExerciseLibrarySelectionScreen** :
  - [ ] Restaurer navigation vers `WorkoutSessionScreen`
  - [ ] Vérifier import `WorkoutSessionScreen` présent

- [ ] **Recherche globale** :
  - [ ] Aucune référence restante à `kDebugMode` dans les fichiers modifiés (sauf si légitime)
  - [ ] Aucun print() pour debug d'images (grep: `print.*Exercise.*Image`)
  - [ ] Aucun "DEBUG MODE" dans le code (grep: `DEBUG MODE`)

### Build & Tests

- [ ] **Compilation** :
  - [ ] `flutter clean` exécuté
  - [ ] `flutter pub get` exécuté
  - [ ] `flutter analyze` ne montre aucune erreur (warnings OK)
  - [ ] `flutter test` : tous les tests passent

- [ ] **Build Release** :
  - [ ] `flutter build apk --release` réussi
  - [ ] Taille APK vérifiée (~50 MB + 371 KB images)
  - [ ] Aucun warning "kDebugMode" dans les logs de build

- [ ] **Test sur Device Physique** :
  - [ ] Installation APK réussie
  - [ ] Lancement app réussi
  - [ ] Navigation vers liste exercices fonctionne
  - [ ] Affichage des 20 images préchargées (instantané)
  - [ ] Clic sur exercice → Navigation vers WorkoutSessionScreen (PAS vers détail)
  - [ ] Aucun titre "🔥 DEBUG MODE" visible
  - [ ] Aucune barre de couleur debug visible

### Images

- [ ] **Système d'images** :
  - [ ] 20 images préchargées présentes dans APK (`assets/exercise_images/`)
  - [ ] Manifeste `manifest.json` présent dans APK
  - [ ] Première ouverture : 20 images s'affichent instantanément
  - [ ] Mode avion : 20 images préchargées fonctionnent
  - [ ] Téléchargement d'une nouvelle image fonctionne (test 1 exercice)
  - [ ] Redémarrage app : image téléchargée toujours présente
  - [ ] Vérifier quota API : 21/100 (ou 22 si 1 test) max

### Documentation

- [ ] **Mise à jour README** :
  - [ ] [docs/IMAGE_SYSTEM.md](IMAGE_SYSTEM.md) créé et complet
  - [ ] [lib/features/exercise_library/README.md](../lib/features/exercise_library/README.md) mis à jour
  - [ ] [README.md](../README.md) principal mis à jour
  - [ ] Ce fichier (PRODUCTION_CLEANUP.md) créé

---

## 🚀 Commandes de Déploiement

Une fois la checklist complétée, exécutez ces commandes pour le build final :

```bash
# 1. Nettoyer le projet
flutter clean

# 2. Récupérer les dépendances
flutter pub get

# 3. Analyser le code
flutter analyze

# 4. Exécuter les tests
flutter test

# 5. Build APK release
flutter build apk --release

# 6. Build App Bundle (pour Play Store)
flutter build appbundle --release
```

**Fichiers générés** :
- APK : `build/app/outputs/flutter-apk/app-release.apk`
- App Bundle : `build/app/outputs/bundle/release/app-release.aab`

---

## 📊 Métriques de Validation

### Taille APK

**Attendu** :
- APK base : ~48-50 MB (Flutter + Firebase + app code)
- Images préchargées : +371 KB (20 SVG)
- **Total estimé** : ~50.4 MB

**Vérification** :
```bash
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

### Performance

**Temps de chargement** :
- Liste exercices : < 200ms
- Image préchargée : 0ms (instantané)
- Première image téléchargée : ~500ms (HTTP + stockage)
- Image déjà téléchargée : 0ms (instantané)

**Mémoire** :
- Utilisation normale : ~80-120 MB
- Avec images en cache : +5-10 MB max

### Tests Utilisateur

**Scénarios critiques** :
1. ✅ Lancer l'app → Liste s'affiche rapidement
2. ✅ Exercices préchargés montrent images instantanément
3. ✅ Exercices non préchargés montrent émojis
4. ✅ Clic exercice → Navigation vers WorkoutSessionScreen
5. ✅ Pas de titre "DEBUG MODE" visible
6. ✅ Pas de barre colorée debug visible
7. ✅ Mode avion → Images préchargées fonctionnent

---

## 🐛 Troubleshooting Build Release

### Problème : APK trop volumineux (> 55 MB)

**Diagnostic** :
```bash
# Analyser la taille de l'APK
flutter build apk --release --analyze-size
```

**Solutions** :
- Vérifier que seules 20 images sont dans `assets/exercise_images/`
- Utiliser App Bundle au lieu d'APK pour Play Store (taille optimisée)

### Problème : Images ne s'affichent pas en release

**Causes possibles** :
1. Asset path incorrect → Vérifier `pubspec.yaml` : `- assets/exercise_images/`
2. Manifeste non chargé → Vérifier `main.dart` : `ExerciseImageManifest.load()`
3. flutter_svg non inclus → Vérifier `pubspec.yaml` : `flutter_svg: ^2.0.9`

**Solution** :
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### Problème : Erreur de compilation après suppression code debug

**Cause** : Import inutilisé ou variable référencée

**Solution** :
```bash
# Analyser les erreurs
flutter analyze

# Corriger automatiquement
dart fix --apply
```

### Problème : Navigation ne fonctionne pas vers WorkoutSessionScreen

**Vérifications** :
1. Import présent : `import 'package:apollon/screens/workout_session_screen.dart';`
2. Paramètre correct : `WorkoutSessionScreen(selectedExercise: exercise)`
3. WorkoutSessionScreen accepte ce paramètre dans son constructeur

---

## 📚 Ressources

- [Documentation système d'images](IMAGE_SYSTEM.md)
- [README Exercise Library](../lib/features/exercise_library/README.md)
- [Guide déploiement Flutter](https://docs.flutter.dev/deployment/android)
- [Guide Play Store](https://support.google.com/googleplay/android-developer/answer/9859152)

---

## 📝 Notes

### Pourquoi retirer le code de debug ?

1. **Performance** : Les print() peuvent ralentir l'app en production
2. **Sécurité** : Éviter d'exposer des chemins internes ou API keys dans les logs
3. **UX** : Pas de UI debug visible pour les utilisateurs finaux
4. **Taille** : Moins de code = APK légèrement plus petit
5. **Professionnalisme** : Build production propre et optimisé

### Que faire si je veux ré-activer le debug ?

Utilisez `kDebugMode` (déjà présent en Flutter) :

```dart
if (kDebugMode) {
  print('Debug info...');
}
```

Le code dans `if (kDebugMode)` est **automatiquement supprimé** en build release par le tree-shaking de Dart.

---

**Dernière mise à jour** : 18 février 2026  
**Version** : 1.0.0
