# Changelog - Apollon

Historique des versions et modifications du projet Apollon.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

---

## [1.0.1] - 2026-02-17 🐛 Correctifs Historique

### 🐛 Corrigé

#### Bug #1: Temps de séance affiché à 0
- **Problème:** Le temps de séance s'affichait toujours à 0 dans l'historique
- **Cause:** Incohérence unités (minutes vs secondes) + initialisation incorrecte
- **Solution:** 
  - Harmonisé toutes les durées en **secondes**
  - Changé `duration: 0` → `duration: null` à l'initialisation
  - Mis à jour calcul dans `completeWorkout()`: `inMinutes` → `inSeconds`
  - Corrigé getter `displayDuration` pour gérer secondes (format: "1h23" ou "45min")
- **Fichiers:** `workout_provider.dart`, `workout.dart`
- **Impact:** ✅ Temps réel maintenant affiché correctement

#### Bug #2: Suppression séance sans rafraîchissement
- **Problème:** Après suppression, la séance restait visible jusqu'au refresh manuel
- **Cause:** Pas de signal de retour pour déclencher rechargement automatique
- **Solution:**
  - Ajout retour `Navigator.pop(context, true)` après suppression réussie
  - Capture résultat dans `HistoryScreen` avec `await Navigator.push<bool>()`
  - Auto-refresh via `_loadWorkouts(refresh: true)` si `deleted == true`
- **Fichiers:** `workout_detail_screen.dart`, `history_screen.dart`
- **Impact:** ✅ UX fluide, séance disparaît immédiatement

**Détails complets:** Voir [BUGFIX-HISTORIQUE.md](BUGFIX-HISTORIQUE.md)

---

## [1.0.0] - 2026-02-17 ✅ MVP V1 Complet

### 🎉 Release Initiale MVP V1

**Effort total:** 31.5h / 36h planifiées (87.5%)  
**Status:** Production-ready  
**Validation:** ✅ 6/6 EPICs, 39/39 tests, 6/6 RG, 3/3 CS

### ✨ Ajouté

#### EPIC-1: Authentication Google (3h)
- Connexion via Google Sign-In
- Auto-login au démarrage
- Gestion profil utilisateur Firestore
- Écran LoginScreen avec design Liquid Glass
- Déconnexion avec confirmation

#### EPIC-2: Models & Services (4h)
- Modèles métier: `Exercise`, `Workout`, `WorkoutSet`, `WorkoutExercise`
- Services Firebase: `AuthService`, `ExerciseService`, `WorkoutService`
- Validation RG-003 (reps > 0, poids ≥ 0) dans modèles
- Sérialisation JSON complète (toJson/fromJson)
- Providers: `AuthProvider`, `WorkoutProvider`, `ThemeProvider`

#### EPIC-3: Design System Liquid Glass (5h)
- ThemeData complet Dark + Light mode
- 17 widgets réutilisables premium:
  - `MeshGradientBackground` (animation breathing)
  - `FloatingGlassAppBar`
  - `AppCard`, `MarbleCard`, `ParallaxCard`
  - `AppButton`, `GlassOrbButton`, `CircularProgressButton`
  - `AppTextField`
  - `GoldenBadge`, `PulseIcon`
  - `ProfileDrawer`, `ThemeSwitcher`
- Palette couleurs Material 3 (#1E88E5 primary)
- Typographie Google Fonts (Raleway + JetBrains Mono)
- 5 types de page transitions animées

#### EPIC-4: Enregistrement Séance (10h)
- `HomePage` avec chronomètre séance enhanced
- `ExerciseSelectionScreen` avec:
  - Navigation par groupes musculaires (tabs)
  - Recherche temps réel
  - Filtrage par type exercice
  - ListView.builder optimisé (50 exercices)
- `WorkoutSessionScreen` avec:
  - Ajout séries dynamique
  - Affichage historique automatique dernière séance
  - Timer par exercice
  - Validation temps réel (RG-003)
  - Autosave toutes les 10s (RG-004)
- WorkoutProvider avec gestion état complet
- Respect processus P2 (CRITIQUE)

#### EPIC-5: Historique (6h)
- `HistoryScreen` avec:
  - Liste séances triée date décroissante
  - Recherche par exercice
  - Filtres par date
  - Empty state élégant
- `WorkoutDetailScreen` avec:
  - Détail complet séance
  - Statistiques (total exercices, séries, volume)
  - Navigation exercices
  - Actions (modifier, supprimer)
- Respect processus P3

#### EPIC-6: Tests & Polish + Audit Performance (3.5h)
- 39 tests unitaires modèles (100% passent)
- Tests validation RG-003 exhaustifs
- Code quality: 298 → 255 issues (-14%)
- 26 corrections automatiques (dart fix)
- 54 fichiers formatés (conventions Dart)
- Performance validée: 60fps maintenu
- Aucun memory leak détecté
- Documentation complète:
  - `AUDIT-PERFORMANCE-MVP-V1.md`
  - `docs/tests-and-quality.md`
  - `DOCUMENTATION.md`

### 📄 Documentation

#### Ajoutée
- `README.md` - Vue d'ensemble, glossaire, installation
- `docs/README.md` - Index documentation
- `docs/firebase-setup-guide.md` - Setup Firebase complet
- `docs/firestore-architecture.md` - Architecture base de données
- `docs/firestore-security-rules.md` - Sécurité Firestore
- `docs/seed-data-exercises.md` - Liste exercices prédéfinis
- `docs/design-system.md` - Design system complet
- `docs/tests-and-quality.md` - Standards tests et qualité
- `AUDIT-PERFORMANCE-MVP-V1.md` - Rapport audit EPIC-6
- `DOCUMENTATION.md` - Index navigation documentationmise à jour - `CHANGELOG.md` - Ce fichier

#### Backlog & Planification
- `_byan-output/bmb-creations/Backlog-MVP-V1.md` - Backlog Agile
- `_byan-output/bmb-creations/Backlog-V2-Roadmap.md` - Roadmap V2
- `_byan-output/bmb-creations/VALIDATION-FINALE-MVP-V1.md` - Validation MVP
- `_byan-output/bmb-creations/ProjectContext-Apollon.yaml` - Contexte projet

### 🔧 Technique

#### Configuration
- Firebase Authentication (Google Sign-In)
- Cloud Firestore avec Security Rules
- Firestore offline persistence activée
- 50 exercices seed data importés
- Provider state management
- Material 3 theming

#### Stack
- Flutter 3.x
- Dart 3.x
- Firebase Core 2.24.0
- Firebase Auth 4.16.0
- Cloud Firestore 4.14.0
- Google Sign In 6.1.6
- Provider 6.1.1
- Intl 0.19.0
- Google Fonts 6.1.0
- Shared Preferences 2.2.2

### ✅ Validation

#### Règles de Gestion (6/6)
- ✅ RG-001: Authentification Google obligatoire
- ✅ RG-002: Unicité noms exercices
- ✅ RG-003: Validation série (reps > 0, poids ≥ 0)
- ✅ RG-004: Persistance séance arrière-plan + autosave
- ✅ RG-005: Affichage historique texte simple
- ✅ RG-006: Sauvegarde finale sur "Terminer"

#### Processus Métier (3/3)
- ✅ P1: Connexion
- ✅ P2: Enregistrer séance (CRITIQUE)
- ✅ P3: Historique

#### Critères de Succès (3/3)
- ✅ CS-001: Saisir séance (5 exos) < 2 min (~1min40s)
- ✅ CS-002: Retrouver derniers poids < 1s (<500ms)
- ✅ CS-003: Interface fluide 60fps maintained

### 📊 Métriques

- **Tests unitaires:** 39/39 (100%)
- **Code quality:** 255 issues (info only)
- **Performance:** 60fps maintenu
- **Memory leaks:** 0
- **Architecture:** Clean (Models/Services/Providers/UI)
- **Formatage:** 100% conventions Dart

### 🐛 Problèmes Connus

- ⚠️ Tests widgets nécessitent Firebase mocks (prévu V2)
- ⚠️ ~200 warnings `deprecated_member_use` (withOpacity) - Attendre Flutter 4.x
- ⚠️ 13 `avoid_print` dans seed_service.dart (service one-time)

---

## [Unreleased] - V2 Roadmap

### 📋 Planifié V2 (~127h, 6-9 mois)

#### Priorité P0 (Haute valeur)
- **EPIC-V2-1:** Statistiques & Graphiques (18h) ⭐⭐⭐⭐⭐
  - Graphiques progression (fl_chart)
  - Records personnels
  - Calendrier visuel séances
  - Analyse volumes/charges

#### Priorité P1 (Forte utilité)
- **EPIC-V2-2:** Achievements & Gamification (12h) ⭐⭐⭐⭐
- **EPIC-V2-3:** Timer Avancé & Repos (8h) ⭐⭐⭐⭐
- **EPIC-V2-4:** Templates Séances (10h) ⭐⭐⭐⭐
- **EPIC-V2-11:** Podomètre Quotidien (14h) ⭐⭐⭐⭐

#### Priorité P2 (Amélioration)
- **EPIC-V2-5:** Images IA Exercices (12h) ⭐⭐⭐
- **EPIC-V2-6:** Social & Partage (15h) ⭐⭐⭐⭐
- **EPIC-V2-7:** Export & Backup (6h) ⭐⭐⭐
- **EPIC-V2-12:** Refactoring Database FR (8h) ⭐⭐⭐
- **EPIC-V2-13:** Extension Exercices 150+ (6h) ⭐⭐⭐

#### Priorité P3 (Nice-to-have)
- **EPIC-V2-8:** Calcul 1RM & Outils Pro (10h) ⭐⭐⭐
- **EPIC-V2-9:** Exercices Personnalisés (8h) ⭐⭐⭐

#### Tests & CI/CD V2
- Tests widgets avec Firebase mocks (3h)
- Tests services complets (4h)
- Tests providers (3h)
- Tests intégration E2E (5h)
- CI/CD Pipeline GitHub Actions (2h)
- Coverage ≥ 80% (2h)

---

## Conventions Versioning

Format: `MAJOR.MINOR.PATCH`

- **MAJOR:** Changements incompatibles API
- **MINOR:** Nouvelles fonctionnalités (compatibles)
- **PATCH:** Corrections bugs (compatibles)

### Types de changements

- **Ajouté** - Nouvelles fonctionnalités
- **Modifié** - Changements dans fonctionnalités existantes
- **Déprécié** - Fonctionnalités bientôt supprimées
- **Supprimé** - Fonctionnalités retirées
- **Corrigé** - Corrections de bugs
- **Sécurité** - Changements de sécurité

---

**Maintenu par:** apollon-project-assistant  
**Dernière mise à jour:** 17 février 2026
