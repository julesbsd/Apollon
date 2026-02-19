# 🎯 Commandes de Déploiement - Exercise Library

Liste des commandes essentielles pour déployer et tester l'intégration du catalogue d'exercices.

## 📋 Prérequis

```bash
# Vérifier Flutter
flutter doctor

# Vérifier Firebase CLI (optionnel)
firebase --version
```

## 🚀 Déploiement initial

### 1. Installer les dépendances

```bash
flutter pub get
```

### 2. Configurer Firebase (si pas déjà fait)

```bash
# Option A: Via Firebase Console
# 1. Aller sur https://console.firebase.google.com
# 2. Firestore Rules → Coller docs/firestore-rules-exercise-library.rules
# 3. Storage Rules → Coller docs/storage-rules-exercise-library.rules

# Option B: Via Firebase CLI
firebase deploy --only firestore:rules
firebase deploy --only storage:rules
```

### 3. Importer les exercices

```bash
dart scripts/import_workout_api_exercises.dart
```

**Résultat attendu:**
```
🚀 Import des exercices Workout API vers Firestore
✅ Firebase initialisé
✅ 94 exercices trouvés
✅ Batch de 94 exercices importé
✅ 94 documents présents dans Firestore
🎉 Import terminé avec succès!
```

### 4. Vérifier l'implémentation

```bash
# Analyser le code
flutter analyze

# Vérifier qu'il n'y a pas d'erreurs
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🧪 Tests

### Tests manuels

```bash
# Lancer l'app en mode debug
flutter run

# Lancer avec logs détaillés
flutter run --verbose

# Lancer sur un device spécifique
flutter devices
flutter run -d <device_id>
```

### Tests automatisés (à implémenter)

```bash
# Tests unitaires
flutter test

# Tests d'intégration
flutter drive --target=test_driver/app.dart

# Coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 🔍 Vérifications

### Vérifier Firestore

```bash
# Via Firebase CLI
firebase firestore:indexes
firebase firestore:get /exercises_library --limit 5

# Via Console
# https://console.firebase.google.com → Firestore Database → Data
```

### Vérifier Storage

```bash
# Via Firebase CLI
firebase storage:ls gs://apollon.appspot.com/exercise_images

# Via Console
# https://console.firebase.google.com → Storage
```

### Vérifier les performances

```bash
# Profile mode (performance)
flutter run --profile

# Release mode (production)
flutter run --release
```

## 📱 Build de production

### Android

```bash
# Debug
flutter build apk --debug

# Release
flutter build apk --release

# App Bundle (Google Play)
flutter build appbundle --release

# Fichier généré
open build/app/outputs/flutter-apk/app-release.apk
```

### iOS

```bash
# Debug
flutter build ios --debug

# Release
flutter build ios --release --no-codesign

# Archive (App Store)
flutter build ipa --release
```

### Web

```bash
# Build web
flutter build web --release

# Servir localement
flutter run -d web-server --web-port 8080
```

## 🐛 Debugging

### Logs Firebase

```bash
# Logs Firestore
flutter run --verbose 2>&1 | grep Firestore

# Logs Storage
flutter run --verbose 2>&1 | grep Storage
```

### Clear cache

```bash
# Clear Flutter cache
flutter clean
flutter pub get

# Clear app data (Android)
adb shell pm clear com.example.apollon

# Clear app data (iOS)
# Settings → General → iPhone Storage → Apollon → Delete App
```

### Reset Firestore (DEV ONLY)

```bash
# ATTENTION: Supprime toutes les données!
firebase firestore:delete --all-collections --force
dart scripts/import_workout_api_exercises.dart
```

## 📊 Monitoring

### Performance monitoring

```bash
# Activer Performance Monitoring
flutter pub add firebase_performance

# Build avec monitoring
flutter run --profile
```

### Crashlytics

```bash
# Activer Crashlytics
flutter pub add firebase_crashlytics

# Test crash
throw Exception('Test crash');
```

## 🔧 Maintenance

### Mise à jour des exercices

```bash
# 1. Télécharger nouveau JSON depuis Workout API
# 2. Remplacer docs/workout_api_exercises_fr.json
# 3. Réimporter
dart scripts/import_workout_api_exercises.dart
```

### Mise à jour des dépendances

```bash
# Vérifier versions outdated
flutter pub outdated

# Mettre à jour
flutter pub upgrade

# Mettre à jour versions majeures
flutter pub upgrade --major-versions
```

### Optimisation images

```bash
# Pré-charger images populaires (à implémenter)
# Script à créer: scripts/preload_popular_images.dart
dart scripts/preload_popular_images.dart --top 20
```

## 📦 CI/CD (à configurer)

### GitHub Actions

```yaml
# .github/workflows/flutter.yml
name: Flutter CI

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      - run: flutter build apk --release
```

### Firebase Hosting (Web)

```bash
# Initialiser
firebase init hosting

# Déployer
flutter build web --release
firebase deploy --only hosting
```

## 🎯 Checklist de déploiement

### Développement

- [ ] `flutter pub get` ✅
- [ ] `dart scripts/import_workout_api_exercises.dart` ✅
- [ ] `flutter run` ✅
- [ ] Tester recherche
- [ ] Tester filtres
- [ ] Tester navigation

### Staging

- [ ] `flutter build apk --debug`
- [ ] Tests manuels complets
- [ ] Vérifier performance
- [ ] Vérifier offline mode
- [ ] Tests sur plusieurs devices

### Production

- [ ] `flutter analyze` (0 issues)
- [ ] `flutter test` (100% pass)
- [ ] Règles Firebase configurées
- [ ] `flutter build apk --release`
- [ ] `flutter build ios --release`
- [ ] Tests bêta (TestFlight / Internal Testing)
- [ ] Monitoring activé
- [ ] Crashlytics configuré

## 📞 Support

### Problèmes courants

| Problème | Commande de résolution |
|----------|------------------------|
| Dépendances manquantes | `flutter pub get` |
| Cache corrompu | `flutter clean && flutter pub get` |
| Exercices vides | `dart scripts/import_workout_api_exercises.dart` |
| Compilation échoue | `flutter clean && flutter run` |
| Permission Firebase | Vérifier règles dans Console |

### Logs utiles

```bash
# Logs complets
flutter run --verbose > logs.txt 2>&1

# Logs spécifiques
flutter logs | grep -i "exercise"
flutter logs | grep -i "firebase"
flutter logs | grep -i "error"
```

## 🚀 Commandes rapides

```bash
# Setup complet
flutter pub get && dart scripts/import_workout_api_exercises.dart && flutter run

# Clean rebuild
flutter clean && flutter pub get && flutter run

# Build production Android
flutter build apk --release --split-per-abi

# Build production iOS
flutter build ios --release && flutter build ipa

# Profile performance
flutter run --profile --trace-startup --verbose
```

## 📚 Ressources

- [Flutter Docs](https://docs.flutter.dev)
- [Firebase Docs](https://firebase.google.com/docs)
- [Flutter DevTools](https://docs.flutter.dev/development/tools/devtools/overview)
- [Dart Docs](https://dart.dev/guides)

---

**Auteur**: Flutter Developer Expert  
**Dernière mise à jour**: 17 février 2026  
**Version**: 1.0.0
