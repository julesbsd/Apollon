# DOCUMENTATION APOLLON - INDEX

Documentation complète du backend Firebase et de l'architecture Firestore pour le projet Apollon.

---

## DOCUMENTATION DISPONIBLE

### 📖 Documentation principale

1. **[README.md](../README.md)**
   - Vue d'ensemble du projet
   - Glossaire métier (6 concepts)
   - Règles de gestion (RG-001 à RG-006)
   - Processus métier (P1, P2, P3)
   - Roadmap V1 / V2

---

### 🔥 Firebase Backend

#### 2. **[Firebase Setup Guide](firebase-setup-guide.md)**
   📋 **Durée : 45-60 minutes**
   
   Guide complet étape par étape pour :
   - Créer projet Firebase
   - Configurer Authentication (Google Sign-In)
   - Configurer Firestore
   - Intégrer Flutter (Android + iOS)
   - Déployer Security Rules
   - Importer seed data
   - Créer indexes
   
   **👉 COMMENCER ICI pour setup initial**

#### 3. **[Firestore Architecture](firestore-architecture.md)**
   📐 **Documentation technique détaillée**
   
   - Structure collections (users, workouts, exercises)
   - Rationale dénormalisation (performances)
   - Hiérarchie des données
   - Requêtes optimisées
   - Modèles Dart recommandés
   - Stratégie offline
   - Monitoring et coûts
   
   **👉 LIRE pour comprendre l'architecture**

#### 4. **[Firestore Security Rules](firestore-security-rules.md)**
   🔒 **Sécurité et validation**
   
   - Règles de sécurité complètes (firestore.rules)
   - Explication helper functions
   - Validation RG-003 (reps > 0, weight >= 0)
   - Isolation utilisateur (RG-001)
   - Scénarios de validation
   - Tests avec Firebase Emulator
   
   **👉 CONSULTER pour validation et sécurité**

#### 5. **[Seed Data - Exercices](seed-data-exercises.md)**
   💪 **Base de données exercices**
   
   - Liste complète 50 exercices prédéfinis
   - Catégorisation (groupes musculaires, types)
   - Structure Firestore
   - Script d'import
   - Emojis par catégorie
   - Evolution V2
   
   **👉 RÉFÉRENCE pour les exercices**

---

### 🎨 Frontend et Design System

#### 6. **[Design System Material 3 Moderne](design-system.md)**
   ✨ **Documentation complète du style visuel**
   
   - Design System Material 3 épuré et moderne
   - Palette de couleurs (#1E88E5 primary, Dark/Light mode)
   - Typographie (Google Fonts Raleway + JetBrains Mono)
   - Widgets réutilisables (AppCard, AppButton, CircularProgressButton, ProfileDrawer, etc.)
   - Page transitions fluides (5 types disponibles)
   - Exemples d'utilisation complets
   - Bonnes pratiques performance et accessibilité
   
   **👉 CONSULTER pour implémenter l'UI**

---

### 🧪 Tests et Qualité

#### 7. **[Tests & Qualité Code](tests-and-quality.md)**
   ✅ **Documentation tests et standards qualité**
   
   - Tests unitaires (39/39 modèles ✅)
   - Tests widgets (stratégie mocking V2)
   - Qualité code (255 issues info)
   - Performance (optimisations appliquées)
   - Checklist qualité avant commit
   - Roadmap tests V2
   - Outils et commandes utiles
   
   **👉 RÉFÉRENCE pour développement qualité**

#### 8. **[AUDIT-PERFORMANCE-MVP-V1.md](../AUDIT-PERFORMANCE-MVP-V1.md)**
   📊 **Rapport audit complet EPIC-6**
   
   - Analyse tests (39/47 status)
   - Code quality audit détaillé
   - Performance analysis
   - Optimisations appliquées
   - Recommandations V2 priorisées
   
   **👉 CONSULTER pour état qualité projet**

---

### 📁 Fichiers techniques

#### 9. **[firestore.rules](../firestore.rules)**
   Fichier de Security Rules Firestore (à déployer)
   
   ```bash
   firebase deploy --only firestore:rules
   ```

#### 8. **[exercises.json](../assets/seed_data/exercises.json)**
   Données JSON des 50 exercices prédéfinis

#### 9. **[seed_exercises.dart](../scripts/seed_exercises.dart)**
   Script Dart pour importer les exercices dans Firestore
   
   ```bash
   dart run scripts/seed_exercises.dart
   ```

#### 10. **Design System - Fichiers theme/**
   Système de thème Flutter complet dans `lib/core/theme/`
   - `app_colors.dart` : Palette couleurs + Material 3 ColorScheme
   - `app_typography.dart` : Styles texte avec Google Fonts
   - `app_decorations.dart` : Décorations, borders, shadows, spacing
   - `app_theme.dart` : ThemeData complet (light/dark)

#### 11. **Design System - Widgets réutilisables**
   Widgets custom dans `lib/core/widgets/`
   - `glass_card.dart` : Cartes avec effet verre
   - `glass_button.dart` : Boutons (4 variantes)
   - `glass_text_field.dart` : Champs de saisie
   - `glass_bottom_sheet.dart` : Bottom sheets modaux
   - `glass_chip.dart` : Chips de sélection
   - `glass_widgets.dart` : Fichier d'export unique

---

## PARCOURS RECOMMANDÉS
Lire [Design System Material 3](design-system.md) - Style visuel et widgets
4. Référencer [Seed Data Exercices](seed-data-exercises.md) - Données
5. Implémenter modèles Dart et UI (voir exemples dans docs)

**Durée : 3-4ME.md](../README.md) - Vue d'ensemble
2. Suivre [Firebase Setup Guide](firebase-setup-guide.md) - Configuration complète
3. Exécuter script seed data - Import exercices
4. Valider avec checklist finale

**Durée totale : 1-2 heures**

---

### 🏗️ Pour développer (Comprendre l'architecture)

1. Lire [Firestore Architecture](firestore-architecture.md) - Structure données
2. Consulter [Firestore Security Rules](firestore-security-rules.md) - Règles sécurité
3. Référencer [Seed Data Exercices](seed-data-exercises.md) - Données
4. Implémenter modèles Dart (voir exemples dans architecture)

**Durée : 2-3 heures de lecture + implémentation**

---

### 🔧 Pour maintenir (Référence technique)

**Ajouter un exercice :**
→ [Seed Data - Section Maintenance](seed-data-exercises.md#maintenance-seed-data)

**Modifier Security Rules :**
→ [Security Rules - Déploiement](firestore-security-rules.md#déploiement)

**Créer un index :**
→ [Architecture - Indexes requis](firestore-architecture.md#indexes-requis)

**Résoudre erreur :**
→ [Setup Guide - Troubleshooting](firebase-setup-guide.md#troubleshooting)
**Implémenter un écran :**
→ [Design System - Exemples d'utilisation](design-system.md#exemples-dutilisation)

**Utiliser un widget Glass* :**
→ [Design System - Widgets réutilisables](design-system.md#widgets-réutilisables)


---

## ARCHITECTURE VISUELLE
├─ UI (Material 3 Design)
│    │   ├─ Theme System (colors, typography, decorations)
│    │   └─ Glass Widgets (cards, buttons, inputs, chips)
│    └─ Screens (login, workout, history
```
PROJET APOLLON
│
├─── Frontend (Flutter)
│    ├─ Authentication (Google Sign-In)
│    ├─ State Management (Provider)
│    └─ UI (Material 3 Design)
│
├─── Backend (Firebase)
│    ├─ Firebase Authentication
│    │   └─ Google Sign-In Provider
│    │
│    └─ Cloud Firestore
│        ├─ Collection: users
│        │   └─ Subcollection: workouts (séances)
│        │
│        └─ Collection: exercises (référentiel)
│            └─ 50 exercices prédéfinis
│
└─── Security
     ├─ Firestore Security Rules
     ├─ Validation côté serveur (RG-003)
     └─ Isolation utilisateur (RG-001)
```

---

## CHECKLIST COMPLÈTE

### Setup Firebase
- [ ] Projet Firebase créé
- [ ] Authentication activée (Google)
- [ ] Fhème appliqué (AppTheme.lightTheme/darkTheme)
- [ ] Tirestore Database créée
- [ ] Application Android configurée (SHA-1)
- [ ] Application iOS configurée (Bundle ID)
- [ ] `google-services.json` placé (Android)
- [ ] `GoogleService-Info.plist` placé (iOS)

### Configuration Flutter
- [ ] Dépendances installées (pubspec.yaml)
- [ ] Firebase initialisé (main.dart)
- [ ] Test connexion réussie

### Firestore
- [ ] Security Rules déployées
- [ ] Seed data importé (50 exercices)
- [ ] Indexes créés (4 indexes)
- [ ] Mode offline activé

### Validation
- [ ] Google Sign-In fonctionne
- [ ] Lecture Firestore fonctionne
- [ ] Mode offline fonctionne
- [ ] Security Rules testées

---

## RÈGLES DE GESTION COUVERTES

| RG | Description | Implémenté dans |
|----|-------------|-----------------|
| **RG-001** | Auth Google obligatoire | Security Rules + AuthService |
| **RG-002** | Unicité noms exercices | Seed script + Security Rules |
| **RG-003** | Validation série (reps > 0, weight >= 0) | Security Rules |
| **RG-004** | Persistance séance (draft) | Architecture Firestore + Offline |
| **RG-005** | Affichage historique | Requêtes optimisées |
| **RG-006** | Sauvegarde finale (completed) | Architecture Firestore |

---

## PROCESSUS MÉTIER SUPPORTÉS

| Processus | Documentation | Implémentation |
|-----------|---------------|----------------|
| **P1** : Connexion | Setup Guide | AuthService + Google Sign-In |
| **P2** : Enregistrer séance | Architecture Firestore | Workouts collection + draft/completed |
| **P3** : Consulter historique | Requêtes optimisées | Firestore queries |

---

## EDGE CASES GÉRÉS

| Edge Case | Solution | Documentation |
|-----------|----------|---------------|
| **EC-001** : 1ère utilisation exercice | Message "Pas de séance" | Architecture - Requêtes |
| **EC-002** : Brouillon abandonné | Status draft 24h | Architecture - Status |
| **EC-003** : Perte connexion | Firestore offline | Architecture - Offline |
| **EC-004** : Suppression données | Security Rules delete | Security Rules |

---

## RESSOURCES EXTERNES

### Firebase
- [Firebase Console](https://console.firebase.google.com)
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Docs](https://firebase.flutter.dev/)

### Outils
- [Firebase CLI](https://firebase.google.com/docs/cli)
- [Firebase Emulator](https://firebase.google.com/docs/emulator-suite)

### Support
- [Stack Overflow - Firebase](https://stackoverflow.com/questions/tagged/firebase)
- [FlutterFire GitHub](https://github.com/firebase/flutterfire)

---1.0

**Dernière mise à jour :** Janvier 2025

---

**Généré par :** Firebase Backend Specialist Agent + Flutter Developer Expervi musculation

**Timeline :** 3 mois (2-3h/semaine, ~36h total)

**Version documentation :** 1.0.0

**Dernière mise à jour :** 15 février 2026

---

**Généré par :** Firebase Backend Specialist Agent  
**Projet :** Apollon Fitness App
