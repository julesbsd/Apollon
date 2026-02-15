# GUIDE DE CONFIGURATION FIREBASE - APOLLON

Guide complet pour configurer Firebase (Authentication + Firestore) pour le projet Apollon.

---

## VUE D'ENSEMBLE

Ce guide couvre :
1. Création du projet Firebase
2. Configuration Firebase Authentication (Google Sign-In)
3. Configuration Cloud Firestore
4. Intégration Flutter (Android + iOS)
5. Déploiement Security Rules
6. Import seed data exercices
7. Configuration indexes
8. Tests et validation

**Durée estimée :** 45-60 minutes

---

## PRÉREQUIS

- [ ] Compte Google
- [ ] Flutter SDK installé
- [ ] Android Studio / Xcode configuré
- [ ] Accès Internet
- [ ] Node.js installé (pour Firebase CLI)

---

## ÉTAPE 1 : CRÉER PROJET FIREBASE

### 1.1 Aller sur Firebase Console

🔗 https://console.firebase.google.com

### 1.2 Créer un nouveau projet

1. Cliquer sur **"Ajouter un projet"**
2. **Nom du projet :** `apollon-fitness-app` (ou nom de votre choix)
3. **Google Analytics :** Recommandé (activer)
4. **Compte Analytics :** Sélectionner compte existant ou créer nouveau
5. Cliquer sur **"Créer le projet"**

⏱️ Attendre 30-60 secondes pour la création

### 1.3 Vérifier création

✅ Vous devriez voir le tableau de bord Firebase avec :
- Overview
- Menu latéral (Authentication, Firestore, etc.)

---

## ÉTAPE 2 : CONFIGURER FIREBASE AUTHENTICATION

### 2.1 Activer Authentication

1. Menu latéral → **Authentication**
2. Cliquer **"Commencer"**
3. Onglet **"Sign-in method"**

### 2.2 Activer Google Sign-In

1. Cliquer sur **"Google"** dans la liste des providers
2. **Activer** le toggle
3. **Email d'assistance du projet :** Sélectionner votre email
4. Cliquer **"Enregistrer"**

✅ Google Sign-In est maintenant activé

### 2.3 Configurer domaines autorisés (optionnel)

1. Onglet **"Settings"** → **"Authorized domains"**
2. Par défaut : `localhost` et votre domaine Firebase sont autorisés
3. **Aucune action requise pour V1**

---

## ÉTAPE 3 : CONFIGURER CLOUD FIRESTORE

### 3.1 Créer base de données Firestore

1. Menu latéral → **Firestore Database**
2. Cliquer **"Créer une base de données"**

### 3.2 Choisir le mode

**Option 1 (Recommandée pour V1) :** Mode test

- ⏱️ Accès ouvert pendant 30 jours
- ⚠️ **IMPORTANT :** Passer en mode production avant expiration
- ✅ Pratique pour développement initial

**Option 2 (Production) :** Mode production

- 🔒 Accès sécurisé dès le début
- Nécessite déploiement Security Rules immédiatement

**Choix recommandé :** **Mode test** puis migration production

### 3.3 Sélectionner emplacement

**Recommandations par région :**

- 🇪🇺 Europe : `europe-west1` (Belgique) ou `europe-west3` (Allemagne)
- 🇺🇸 Amérique du Nord : `us-central1` (Iowa)
- 🌏 Asie : `asia-southeast1` (Singapour)

⚠️ **ATTENTION :** L'emplacement est DÉFINITIF (impossible de changer après)

**Pour France :** Choisir `europe-west1` (Belgique) ou `europe-west3` (Frankfurt)

### 3.4 Créer la base

1. Cliquer **"Activer"**
2. ⏱️ Attendre 1-2 minutes

✅ Firestore est maintenant créé

---

## ÉTAPE 4 : INTÉGRATION FLUTTER

### 4.1 Ajouter Firebase au projet Flutter

#### Option A : FlutterFire CLI (Recommandé)

```bash
# Installer FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurer Firebase pour Flutter
flutterfire configure
```

**Le CLI va :**
- Détecter votre projet Firebase
- Créer les fichiers de configuration Android/iOS
- Générer `firebase_options.dart`

#### Option B : Configuration manuelle

Continuer avec les étapes 4.2 (Android) et 4.3 (iOS) ci-dessous.

---

### 4.2 Configuration Android

#### 4.2.1 Ajouter application Android

1. Firebase Console → **Paramètres du projet** (icône ⚙️)
2. Onglet **"Vos applications"**
3. Cliquer sur l'icône **Android**
4. **Nom du package Android :** `com.example.apollon` (ou votre package défini dans `build.gradle`)
   - 📍 Trouver dans : `android/app/build.gradle` → `applicationId`
5. **Surnom de l'application :** `Apollon Android`
6. **Certificat de signature SHA-1 :** Requis pour Google Sign-In

#### 4.2.2 Obtenir SHA-1 (Debug)

```bash
# Depuis la racine du projet Flutter
cd android

# Générer SHA-1 debug
./gradlew signingReport

# Ou sur Windows
gradlew.bat signingReport
```

**Copier** la ligne commençant par `SHA1:` dans la section **Variant: debug**

**Exemple :**
```
SHA1: A1:B2:C3:D4:E5:F6:G7:H8:I9:J0:K1:L2:M3:N4:O5:P6:Q7:R8:S9:T0
```

Coller dans le champ **"Certificat de signature SHA-1"**

#### 4.2.3 Télécharger google-services.json

1. Cliquer **"Télécharger google-services.json"**
2. **Placer le fichier ici :**
   ```
   android/app/google-services.json
   ```

#### 4.2.4 Modifier android/build.gradle

Fichier : `android/build.gradle` (racine Android, PAS `app/build.gradle`)

```kotlin
buildscript {
    dependencies {
        // Ajouter cette ligne
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

#### 4.2.5 Modifier android/app/build.gradle

Fichier : `android/app/build.gradle`

**À la fin du fichier, ajouter :**

```kotlin
apply plugin: 'com.google.gms.google-services'
```

✅ Configuration Android terminée

---

### 4.3 Configuration iOS

#### 4.3.1 Ajouter application iOS

1. Firebase Console → **Paramètres du projet** (⚙️)
2. Onglet **"Vos applications"**
3. Cliquer sur l'icône **iOS**
4. **Identifiant du bundle iOS :**
   - 📍 Trouver dans : `ios/Runner.xcodeproj/project.pbxproj` ou Xcode
   - Exemple : `com.example.apollon`
5. **Surnom de l'application :** `Apollon iOS`
6. Cliquer **"Enregistrer l'application"**

#### 4.3.2 Télécharger GoogleService-Info.plist

1. Télécharger le fichier `GoogleService-Info.plist`
2. **Placer le fichier ici :**
   ```
   ios/Runner/GoogleService-Info.plist
   ```

#### 4.3.3 Configurer Xcode

1. Ouvrir Xcode :
   ```bash
   open ios/Runner.xcworkspace
   ```
2. Dans le navigateur de projet (à gauche), cliquer sur **"Runner"**
3. Onglet **"General"**
4. **Vérifier :**
   - Bundle Identifier correspond à celui entré dans Firebase
   - Signing & Capabilities configuré (sélectionner votre équipe)

#### 4.3.4 Configurer URL Schemes

1. Xcode → Runner → Onglet **"Info"**
2. Développer **"URL Types"**
3. Cliquer **"+"** pour ajouter
4. **URL Schemes :** Copier le `REVERSED_CLIENT_ID` depuis `GoogleService-Info.plist`
   - Ouvrir `GoogleService-Info.plist` avec éditeur texte
   - Chercher `<key>REVERSED_CLIENT_ID</key>`
   - Copier la valeur `<string>com.googleusercontent.apps.xxx</string>`
   - Coller dans URL Schemes

✅ Configuration iOS terminée

---

### 4.4 Ajouter dépendances Flutter

#### 4.4.1 Éditer pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  google_sign_in: ^6.1.6
  
  # State Management
  provider: ^6.1.1
```

#### 4.4.2 Installer les packages

```bash
flutter pub get
```

---

### 4.5 Initialiser Firebase dans l'app

#### Créer firebase_options.dart

Si non généré automatiquement par FlutterFire CLI, créer manuellement :

```dart
// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'apollon-fitness-app',
    storageBucket: 'apollon-fitness-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'apollon-fitness-app',
    storageBucket: 'apollon-fitness-app.appspot.com',
    iosBundleId: 'com.example.apollon',
  );
}
```

**Trouver les valeurs :**
- Firebase Console → ⚙️ Paramètres projet → Vos applications
- Cliquer sur Android/iOS → Configuration SDK

#### Modifier main.dart

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apollon',
      home: Scaffold(
        appBar: AppBar(title: Text('Apollon')),
        body: Center(child: Text('Firebase configuré !')),
      ),
    );
  }
}
```

---

## ÉTAPE 5 : DÉPLOYER SECURITY RULES

### 5.1 Installer Firebase CLI

```bash
npm install -g firebase-tools
```

### 5.2 Login Firebase

```bash
firebase login
```

### 5.3 Initialiser Firebase dans le projet

```bash
# Depuis la racine du projet Flutter
firebase init
```

**Sélectionner :**
- [x] Firestore (espace pour sélectionner)
- Navigation : Flèches + Entrée

**Configuration :**
- **Firebase project :** Sélectionner `apollon-fitness-app`
- **Firestore rules file :** `firestore.rules` (déjà créé)
- **Firestore indexes file :** `firestore.indexes.json` (accepter default)

### 5.4 Déployer les règles

```bash
firebase deploy --only firestore:rules
```

✅ **Résultat attendu :**
```
✔  Deploy complete!

Project Console: https://console.firebase.google.com/project/apollon-fitness-app/overview
```

### 5.5 Vérifier déploiement

1. Firebase Console → **Firestore Database**
2. Onglet **"Règles"**
3. Vérifier que les règles sont déployées

---

## ÉTAPE 6 : IMPORTER SEED DATA EXERCICES

### 6.1 Vérifier fichiers seed data

Fichiers requis :
- ✅ `assets/seed_data/exercises.json` (50 exercices)
- ✅ `scripts/seed_exercises.dart` (script d'import)

### 6.2 Exécuter le script

```bash
# Depuis la racine du projet
dart run scripts/seed_exercises.dart
```

✅ **Résultat attendu :**
```
✅ IMPORT TERMINÉ
✅ Créés:   50 exercices
⏭️  Ignorés: 0 exercices
❌ Erreurs: 0
```

### 6.3 Vérifier dans Firebase Console

1. Firestore Database → Collection **"exercises"**
2. Vérifier **50 documents** présents
3. Vérifier structure (name, muscleGroups, type, emoji)

---

## ÉTAPE 7 : CRÉER INDEXES COMPOSITES

### 7.1 Indexes requis

Firebase nécessite des indexes composites pour certaines requêtes.

#### Index 1 : Workouts par status et date

1. Firebase Console → **Firestore Database** → **Indexes**
2. Cliquer **"Créer un index"**
3. **Collection :** `workouts`
4. **Champs :**
   - `status` : Ascending
   - `date` : Descending
5. **Query scope :** Collection
6. Cliquer **"Créer"**

⏱️ Attendre 1-2 minutes (création d'index)

#### Index 2 : Exercises par muscleGroups et name

1. Créer un nouvel index
2. **Collection :** `exercises`
3. **Champs :**
   - `muscleGroups` : Array-contains
   - `name` : Ascending
4. Créer

#### Index 3 : Exercises par type et name

1. Créer un nouvel index
2. **Collection :** `exercises`
3. **Champs :**
   - `type` : Ascending
   - `name` : Ascending
4. Créer

#### Index 4 : Recherche textuelle

1. Créer un index
2. **Collection :** `exercises`
3. **Champ :**
   - `nameSearch` : Ascending (single field index)
4. Créer

### 7.2 Alternative : Indexes automatiques

Lors du premier lancement de l'app, si un index manque :
- Firebase génère une erreur avec lien pour créer l'index automatiquement
- Cliquer sur le lien dans les logs

---

## ÉTAPE 8 : TESTS ET VALIDATION

### 8.1 Test authentification

```dart
// Test rapide dans main.dart
import 'package:firebase_auth/firebase_auth.dart';

void testAuth() async {
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      print('❌ Utilisateur non connecté');
    } else {
      print('✅ Connecté: ${user.email}');
    }
  });
}
```

### 8.2 Test lecture Firestore

```dart
void testFirestore() async {
  final exercises = await FirebaseFirestore.instance
    .collection('exercises')
    .limit(5)
    .get();
  
  print('✅ Exercices trouvés: ${exercises.docs.length}');
}
```

### 8.3 Test offline

1. Activer mode avion sur téléphone
2. Lancer l'app
3. Vérifier que les données sont disponibles (cache)

### 8.4 Checklist finale

- [ ] Firebase initialisé (pas d'erreur au lancement)
- [ ] Google Sign-In fonctionne (test login)
- [ ] 50 exercices importés dans Firestore
- [ ] Security Rules déployées
- [ ] Indexes créés (4 indexes)
- [ ] Mode offline fonctionne
- [ ] Aucune erreur dans les logs

---

## CONFIGURATION AVANCÉE

### Mode offline Firestore

Ajouter dans `main.dart` après `Firebase.initializeApp()` :

```dart
// Activer persistence offline
FirebaseFirestore.instance.settings = Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

### Configurer SHA-256 (Production)

Pour la release Android, générer SHA-256 :

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Ajouter dans Firebase Console → Android app → Ajouter empreinte

---

## MIGRATION MODE TEST → PRODUCTION

Si vous avez démarré en mode test (30 jours) :

### Avant expiration (recommandé)

1. Firestore Database → **Règles**
2. Remplacer les règles test par les Security Rules complètes
3. Cliquer **"Publier"**

### Règles de test (à remplacer)

```javascript
// NE PAS GARDER EN PRODUCTION
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2026, 3, 15);  // ⚠️ EXPIRE
    }
  }
}
```

### Règles de production (utiliser firestore.rules)

Déployer avec :

```bash
firebase deploy --only firestore:rules
```

---

## TROUBLESHOOTING

### Erreur : "Default FirebaseApp is not initialized"

**Solution :**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // ← IMPORTANT
  await Firebase.initializeApp();
  runApp(MyApp());
}
```

---

### Erreur : "Permission denied" (Firestore)

**Causes possibles :**
1. Security Rules pas déployées
2. Utilisateur non authentifié
3. Tentative d'accès aux données d'un autre user

**Solution :**
- Vérifier déploiement rules : `firebase deploy --only firestore:rules`
- Vérifier authentification : `FirebaseAuth.instance.currentUser`

---

### Erreur : "SHA-1 certificate fingerprint missing" (Android)

**Solution :**
1. Générer SHA-1 : `./gradlew signingReport`
2. Ajouter dans Firebase Console → Android app

---

### Google Sign-In ne fonctionne pas (iOS)

**Vérifier :**
1. `GoogleService-Info.plist` bien placé dans `ios/Runner/`
2. URL Schemes configuré dans Xcode (REVERSED_CLIENT_ID)
3. Bundle ID correct dans Firebase Console

---

### Index manquant (Firestore)

**Symptôme :** Erreur "The query requires an index"

**Solution :**
- Cliquer sur le lien dans l'erreur console
- OU créer manuellement l'index (voir Étape 7)

---

## COÛTS FIREBASE (PLAN GRATUIT)

### Quotas Spark Plan

| Ressource | Quota gratuit | Usage estimé Apollon V1 |
|-----------|---------------|------------------------|
| Firestore reads | 50,000/jour | 5,000-10,000/jour |
| Firestore writes | 20,000/jour | 2,000-5,000/jour |
| Stockage | 1 GB | < 100 MB |
| Authentification | Illimité | OK |

### Alertes recommandées

1. Firebase Console → **Usage and billing**
2. Configurer **Budget alerts** (ex: 80% quota)

✅ **Apollon V1 reste largement dans le quota gratuit**

---

## NEXTRIX STEPS

Après configuration complète :

1. ✅ Implémenter AuthService (Google Sign-In)
2. ✅ Créer modèles Dart (Workout, Exercise)
3. ✅ Implémenter écrans UI
4. ✅ Tester end-to-end

---

## RESSOURCES

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)

---

**Document généré par:** Firebase Backend Specialist Agent  
**Version:** 1.0.0  
**Date:** 15 février 2026  
**Projet:** Apollon - Application Flutter de suivi musculation
