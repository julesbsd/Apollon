# Configuration Firebase pour Apollon

## Prérequis
1. Créer un projet Firebase: https://console.firebase.google.com
2. Installer Firebase CLI: `npm install -g firebase-tools`
3. Installer FlutterFire CLI: `dart pub global activate flutterfire_cli`

## Configuration Android

### 1. Générer le SHA-1 debug certificate
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### 2. Ajouter le SHA-1 dans Firebase Console
- Project Settings → General → Your apps (Android)
- Section "SHA certificate fingerprints" → Add fingerprint

### 3. Télécharger google-services.json
- Télécharger depuis Firebase Console
- Placer dans `android/app/google-services.json`

### 4. Générer firebase_options.dart
```bash
flutterfire configure
```
- Sélectionner le projet Firebase
- Choisir les plateformes (Android)
- Le fichier `lib/firebase_options.dart` sera généré

## Configuration Firestore

### 1. Activer Cloud Firestore
- Firebase Console → Firestore Database → Create Database
- Mode: Production
- Location: europe-west9 (ou autre)

### 2. Déployer les règles de sécurité
```bash
firebase init firestore
firebase deploy --only firestore:rules
```

### 3. Importer les exercices (seed data)
```bash
cd scripts
npm install
node seed_exercises_node.js
```

## Authentication Google Sign-In

### 1. Activer le provider
- Firebase Console → Authentication → Sign-in method
- Activer "Google"
- Configurer le support email

### 2. Vérifier la configuration
Les fichiers suivants ne doivent **jamais** être commités:
- `android/app/google-services.json` (contient API keys)
- `lib/firebase_options.dart` (contient config Firebase)

Des fichiers `.example` sont fournis comme template.

## Fichiers sensibles (ne JAMAIS commit)
```
android/app/google-services.json
lib/firebase_options.dart
**/*.keystore
**/*.jks
```

Utiliser les fichiers `.example` comme référence.
