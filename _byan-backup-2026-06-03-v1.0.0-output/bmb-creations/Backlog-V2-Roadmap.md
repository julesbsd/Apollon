# BACKLOG APOLLON - V2 (POST-MVP)
# Fonctionnalités Avancées et Evolution Premium

**Projet:** Apollon - Application mobile de suivi de musculation  
**Version:** V2 (Post-MVP)  
**Timeline:** 6-9 mois (à ajuster selon disponibilité)  
**Effort total estimé:** ~80-100h  
**Date:** 15 février 2026  

---

## 🎯 VISION V2

Transformer Apollon d'un **tracker simple** en une **plateforme complète de progression sportive** avec :
- 📊 **Statistiques avancées** (graphiques, records, progression)
- 🏆 **Gamification** (achievements, challenges, motivation)
- 🎨 **Design premium++** (images IA, animations, thèmes)
- 🚀 **Features avancées** (templates, timer repos, calcul 1RM)
- 🌐 **Social** (partage, comparaisons, communauté)

---

## 📊 DISTRIBUTION EFFORT V2

| Epic | Effort estimé | Priorité | Sprint recommandé | ROI |
|------|--------------|----------|-------------------|-----|
| EPIC-V2-1: Statistiques & Graphiques | 18h | P0 (Haute valeur) | Sprint 1-2 | ⭐⭐⭐⭐⭐ |
| EPIC-V2-2: Achievements & Gamification | 12h | P1 (Forte rétention) | Sprint 2-3 | ⭐⭐⭐⭐ |
| EPIC-V2-3: Timer Avancé & Repos | 8h | P1 (Haute utilité) | Sprint 3 | ⭐⭐⭐⭐ |
| EPIC-V2-4: Templates Séances | 10h | P1 (Gain temps) | Sprint 4 | ⭐⭐⭐⭐ |
| EPIC-V2-5: Images IA Exercices | 12h | P2 (Esthétique) | Sprint 4-5 | ⭐⭐⭐ |
| EPIC-V2-6: Social & Partage | 15h | P2 (Communauté) | Sprint 5-6 | ⭐⭐⭐⭐ |
| EPIC-V2-7: Export & Backup | 6h | P2 (Sécurité données) | Sprint 6 | ⭐⭐⭐ |
| EPIC-V2-8: Calcul 1RM & Outils Pro | 10h | P3 (Powerlifters) | Sprint 7 | ⭐⭐⭐ |
| EPIC-V2-9: Exercices Personnalisés | 8h | P3 (Flexibilité) | Sprint 7 | ⭐⭐⭐ |
| EPIC-V2-11: Podomètre Quotidien | 14h | P1 (Santé globale) | Sprint 3-4 | ⭐⭐⭐⭐ |
| EPIC-V2-12: Refactoring Database FR | 8h | P2 (Dette technique) | Sprint 2 | ⭐⭐⭐ |
| EPIC-V2-13: Extension Exercices (150+) | 6h | P2 (Contenu) | Sprint 1 | ⭐⭐⭐ |
| **TOTAL** | **~127h** | | **7 sprints** | |

---

# EPIC-V2-11 : PODOMÈTRE QUOTIDIEN 🚶

**Priorité:** P1 (Santé globale et engagement quotidien)  
**Effort:** 14h  
**Sprint:** 3-4  
**Dépendances:** MVP V1  
**ROI:** ⭐⭐⭐⭐ (Engagement quotidien, santé globale)

## Objectif

Tracker les pas de l'utilisateur tout au long de la journée avec enregistrement automatique en fin de journée dans Firestore et visualisation dans un calendrier mensuel.

## User Stories

### US-V2-11.1: Service Podomètre Background
**Effort:** 5h

**Critères d'acceptation:**
- [ ] Intégration capteur podomètre natif (iOS/Android)
- [ ] Service background permanent comptant les pas
- [ ] Démarre automatiquement au boot du téléphone
- [ ] Fonctionne même quand app fermée
- [ ] Gestion économie batterie (iOS Core Motion, Android SensorManager)
- [ ] Reset compteur à minuit quotidien
- [ ] Notification persistante (Android) : "👟 X pas aujourd'hui"

**Packages requis:**
```yaml
dependencies:
  pedometer: ^4.0.2              # Compteur pas iOS/Android
  workmanager: ^0.5.2            # Background tasks
  flutter_local_notifications: ^17.0.0  # Notifications
  permission_handler: ^11.3.0    # Permissions capteurs
```

**Spécifications techniques:**
- Service: `lib/core/services/pedometer_service.dart`
- Background task: Enregistrement à 23:59 chaque jour
- Permissions: Activity Recognition (Android), Motion & Fitness (iOS)

**Code structure:**
```dart
class PedometerService {
  Stream<StepCount> get stepCountStream;
  
  // Démarre le tracking au lancement app
  Future<void> startTracking();
  
  // Sauvegarde quotidienne automatique à 23:59
  Future<void> saveDailySteps(int steps, DateTime date);
  
  // Récupère historique
  Future<List<DailySteps>> getStepHistory(DateTime start, DateTime end);
  
  // Stats
  int getTodaySteps();
  int getWeeklyAverage();
  int getMonthlyTotal();
}
```

---

### US-V2-11.2: Modèle et Stockage Firestore
**Effort:** 2h

**Critères d'acceptation:**
- [ ] Nouvelle collection Firestore: `users/{userId}/daily_steps/{date}`
- [ ] Structure document:
  ```json
  {
    "date": "2026-02-15",
    "steps": 8543,
    "distance_km": 6.12,
    "calories": 315,
    "active_minutes": 87,
    "created_at": "2026-02-15T23:59:00Z"
  }
  ```
- [ ] Calcul automatique distance (pas × 0.75m moyenne)
- [ ] Calcul automatique calories (0.04 cal/pas)
- [ ] Index Firestore pour queries rapides

**Spécifications techniques:**
- Modèle: `lib/core/models/daily_steps.dart`
- Collection: `users/{userId}/daily_steps/`
- Index: `date` (descendant)

---

### US-V2-11.3: Widget Compteur HomePage
**Effort:** 3h

**Critères d'acceptation:**
- [ ] Card glassmorphism sur HomePage affichant:
  - Nombre de pas aujourd'hui (temps réel)
  - Objectif quotidien (défaut: 10 000 pas)
  - Barre de progression circulaire
  - Distance parcourue (km)
  - Calories brûlées
- [ ] Animation incrémentale du compteur (nombre qui monte)
- [ ] Icône emoji 🚶 / 🏃 selon rythme (< 5000 = 🚶, > 10000 = 🏃)
- [ ] Clic sur card → Navigation vers calendrier pas

**Exemple UI:**
```
┌─────────────────────────────────────┐
│ 🚶 Pas Aujourd'hui                 │
│                                     │
│         ╱────────╲                 │
│        │  8,543  │   🎯 10,000    │
│         ╲────────╱                 │
│           85%                       │
│                                     │
│ 📏 6.1 km  🔥 315 kcal             │
└─────────────────────────────────────┘
```

**Spécifications techniques:**
- Widget: `lib/core/widgets/daily_steps_card.dart`
- Provider: `lib/core/providers/pedometer_provider.dart`
- Animation: AnimatedSwitcher pour compteur

---

### US-V2-11.4: Calendrier Pas Mensuel
**Effort:** 3h

**Critères d'acceptation:**
- [ ] Nouvel écran "Calendrier Pas" accessible depuis HomePage
- [ ] Calendrier mensuel avec nombre de pas par jour
- [ ] Coloration cellules selon objectif:
  - Gris: < 5000 pas
  - Jaune: 5000-7499 pas
  - Orange: 7500-9999 pas
  - Vert: 10000+ pas ✅
  - Or: 15000+ pas 🏆
- [ ] Clic sur jour → Détail (pas, distance, calories)
- [ ] Stats mois:
  - Total pas mois
  - Moyenne quotidienne
  - Jours objectif atteint
  - Record journalier
- [ ] Navigation mois précédent/suivant

**Package recommandé:**
```yaml
dependencies:
  table_calendar: ^3.0.9  # Calendrier interactif
```

**Exemple UI:**
```
┌─────────────────────────────────────┐
│ 🗓️ Février 2026                    │
│                                     │
│ L   M   M   J   V   S   D          │
│         1   2   3   4   5          │
│     [8k][9k][12k][6k][15k]        │
│ 6   7   8   9   10  11  12         │
│ [11k][8k][7k][10k][9k][13k][14k]  │
│ 13  14  15  ...                    │
│ [8k][10k][8.5k]                    │
│                                     │
│ 📊 Stats Février:                  │
│ Total: 245,000 pas                 │
│ Moyenne: 11,250 pas/jour           │
│ Objectif atteint: 18/28 jours      │
│ Record: 15,430 pas (5 fév)        │
└─────────────────────────────────────┘
```

**Spécifications techniques:**
- Écran: `lib/screens/pedometer/steps_calendar_screen.dart`
- Service: Méthode `getMonthlySteps(DateTime month)`

---

### US-V2-11.5: Paramètres Objectif
**Effort:** 1h

**Critères d'acceptation:**
- [ ] Option dans Paramètres: "Objectif quotidien pas"
- [ ] Slider 5000 - 20000 pas (incréments 1000)
- [ ] Valeur par défaut: 10 000 pas (recommandation OMS)
- [ ] Sauvegarde dans `users/{userId}/settings`
- [ ] Toggle "Activer/Désactiver podomètre"
- [ ] Toggle "Notifications quotidiennes" (rappel 20h si < objectif)

---

## Livrables EPIC-V2-11

- [ ] Service podomètre background fonctionnel
- [ ] Enregistrement automatique quotidien Firestore
- [ ] Widget compteur temps réel HomePage
- [ ] Calendrier mensuel avec codes couleur
- [ ] Paramètres objectif et notifications
- [ ] Tests service podomètre
- [ ] Documentation permissions iOS/Android

---

# EPIC-V2-12 : REFACTORING DATABASE FRANÇAIS 🇫🇷

**Priorité:** P2 (Dette technique, qualité code)  
**Effort:** 8h  
**Sprint:** 2  
**Dépendances:** MVP V1  
**ROI:** ⭐⭐⭐ (Maintenabilité, cohérence)

## Objectif

Refactoriser toute la structure Firestore et les modèles Dart pour utiliser des noms français cohérents, éliminer le franglais et améliorer la maintenabilité du code.

## User Stories

### US-V2-12.1: Audit et Mapping Noms
**Effort:** 2h

**Critères d'acceptation:**
- [ ] Document de mapping complet Anglais → Français:

**Collections Firestore:**
```
users → utilisateurs
workouts → seances
exercises → exercices
daily_steps → pas_quotidiens
templates → modeles
achievements → realisations
friends → amis
```

**Champs (exemples):**
```
userId → utilisateurId
workoutId → seanceId
exerciseId → exerciceId
muscleGroups → groupesMusculaires
reps → repetitions
weight → poids
createdAt → creeA
updatedAt → modifieA
```

**Variables code Dart:**
```dart
// Avant
final workout = Workout(...);
workout.exercises
workout.createdAt

// Après
final seance = Seance(...);
seance.exercices
seance.creeA
```

- [ ] Liste exhaustive à valider avant migration
- [ ] Document: `docs/migration-fr-v2.md`

---

### US-V2-12.2: Migration Modèles Dart
**Effort:** 3h

**Critères d'acceptation:**
- [ ] Renommer tous les modèles:
  - `Workout` → `Seance`
  - `WorkoutExercise` → `ExerciceSeance`
  - `WorkoutSet` → `Serie`
  - `Exercise` → `Exercice`
  - `DailySteps` → `PasQuotidiens`
  - `PersonalRecord` → `RecordPersonnel`
  - `Achievement` → `Realisation`
  - `Challenge` → `Defi`

- [ ] Renommer tous les champs dans les modèles
- [ ] Adapter méthodes `toFirestore()` et `fromFirestore()`
- [ ] Mettre à jour tous les imports dans le projet
- [ ] Compatibilité rétroactive: Support ancien + nouveau format pendant migration

**Exemple migration:**
```dart
// lib/core/models/seance.dart
class Seance {
  final String? id;
  final String utilisateurId;
  final DateTime date;
  final StatutSeance statut;
  final List<ExerciceSeance> exercices;
  final int? duree;
  final DateTime creeA;
  final DateTime modifieA;

  // Méthode de migration pour support rétrocompatibilité
  factory Seance.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Seance(
      id: doc.id,
      // Support ancien format (userId) et nouveau (utilisateurId)
      utilisateurId: data['utilisateurId'] ?? data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      statut: StatutSeance.fromString(
        data['statut'] ?? data['status'] ?? 'draft'
      ),
      // ...
    );
  }
}
```

---

### US-V2-12.3: Migration Services et Providers
**Effort:** 2h

**Critères d'acceptation:**
- [ ] Renommer tous les services:
  - `WorkoutService` → `SeanceService`
  - `ExerciseService` → `ExerciceService`
  - `PedometerService` → reste `PedometerService` (OK)
  - `StatisticsService` → `StatistiquesService`

- [ ] Renommer providers:
  - `WorkoutProvider` → `SeanceProvider`
  - `ThemeProvider` → reste (OK)
  - `AuthProvider` → `AuthentificationProvider`

- [ ] Mettre à jour toutes les méthodes
- [ ] Adapter queries Firestore (noms collections)
- [ ] Tests unitaires à jour

---

### US-V2-12.4: Migration Data Firestore (Script)
**Effort:** 1h

**Critères d'acceptation:**
- [ ] Script Node.js/Dart pour migration données existantes:
  ```javascript
  // scripts/migrate_to_french.js
  
  // 1. Backup complet avant migration
  // 2. Pour chaque user:
  //    - Copier workouts → seances
  //    - Renommer champs (userId → utilisateurId, etc.)
  //    - Vérifier intégrité
  // 3. Rollback possible si erreurs
  ```

- [ ] Mode dry-run (test sans écriture)
- [ ] Logs détaillés migration
- [ ] Validation post-migration
- [ ] Suppression anciennes collections après validation

**Note importante:** Migration à faire en production uniquement quand tous les utilisateurs ont mis à jour l'app.

---

## Livrables EPIC-V2-12

- [ ] Document mapping complet EN→FR
- [ ] Tous modèles Dart renommés
- [ ] Tous services/providers renommés
- [ ] Script migration Firestore
- [ ] Tests validant compatibilité rétroactive
- [ ] Documentation migration dans `docs/`
- [ ] Mise à jour README avec noms français

---

# EPIC-V2-13 : EXTENSION EXERCICES (150+) 💪

**Priorité:** P2 (Contenu essentiel)  
**Effort:** 6h  
**Sprint:** 1  
**Dépendances:** MVP V1  
**ROI:** ⭐⭐⭐ (Complétude base de données)

## Objectif

Étendre la base d'exercices de ~50 à 150-200 exercices couvrant tous les groupes musculaires et modalités d'entraînement pour offrir une bibliothèque complète.

## User Stories

### US-V2-13.1: Recherche et Catégorisation Exercices
**Effort:** 2h

**Critères d'acceptation:**
- [ ] Recherche exhaustive exercices par catégorie:
  
**Pectoraux (15-20 exercices):**
- Développé couché (barre, haltères, incliné, décliné)
- Écarté (haltères, poulie, pec deck)
- Pompes (variantes: diamant, archer, pliométrique)
- Dips pectoraux
- Pull-over
- Chest press machine
- Cable cross

**Dos (20-25 exercices):**
- Tractions (pronation, supination, neutre, lestées)
- Rowing (barre, haltère, T-bar, machine, poulie)
- Tirage vertical (devant, nuque, prise large/serrée)
- Tirage horizontal
- Pull-over dos
- Deadlift (soulevé de terre, roumain, sumo)
- Shrugs (trapèzes)
- Face pull

**Jambes (25-30 exercices):**
- Squat (libre, guidé, sumo, bulgare, pistol)
- Presse à cuisses (standard, 45°, hack squat)
- Fentes (avant, arrière, latérales, marchées)
- Leg curl (couché, assis, debout)
- Leg extension
- Soulevé de terre jambes tendues
- Hip thrust
- Mollets (standing, seated, leg press)
- Adducteurs/Abducteurs machine

**Épaules (15-20 exercices):**
- Développé militaire (barre, haltères, nuque)
- Élévations latérales (haltères, poulie, machine)
- Élévations frontales
- Oiseau (rear delt fly)
- Rowing menton (upright row)
- Arnold press
- Face pull épaules

**Bras (20-25 exercices):**

*Biceps:*
- Curl barre (EZ, droite)
- Curl haltères (alterné, simultané, marteau)
- Curl pupitre (preacher curl)
- Curl concentré
- Curl poulie (haute, basse)
- Tractions supination

*Triceps:*
- Dips triceps
- Extension nuque (barre, haltère, poulie)
- Barre au front (skullcrusher)
- Extension poulie (corde, barre)
- Kickback haltère
- Diamond push-ups

**Abdominaux & Core (15-20 exercices):**
- Crunch (sol, décliné, poulie)
- Relevé de jambes (suspendu, banc, sol)
- Planche (frontale, latérale, dynamique)
- Russian twist
- Mountain climbers
- Ab wheel
- Cable crunch
- Bicycle crunch

**Cardio (10-15 exercices):**
- Course (tapis, extérieur, intervalles)
- Vélo (stationnaire, elliptique)
- Rameur
- Corde à sauter
- Burpees
- Jumping jacks
- Battle rope

**Full Body / Fonctionnel (10-15 exercices):**
- Clean & jerk
- Snatch
- Thruster
- Box jump
- Kettlebell swing
- Turkish get-up
- Man makers

- [ ] Total: **150-180 exercices minimum**
- [ ] Fichier CSV: `assets/seed_data/exercices_complets.csv`

---

### US-V2-13.2: Génération JSON Seed Data
**Effort:** 3h

**Critères d'acceptation:**
- [ ] Fichier JSON structuré: `assets/seed_data/exercices_v2.json`
- [ ] Structure par exercice:
  ```json
  {
    "id": "exercice_001",
    "nom": "Développé couché barre",
    "nomAnglais": "Barbell Bench Press",
    "groupesMusculaires": ["pectoraux", "triceps", "epaules"],
    "type": "poids_libres",
    "difficulte": "intermediaire",
    "equipement": "barre",
    "emoji": "💪",
    "description": "Exercice de base pour les pectoraux. Allongé sur un banc, descendre la barre jusqu'à la poitrine puis pousser.",
    "conseils": [
      "Garder les omoplates serrées",
      "Pieds au sol",
      "Barre au niveau des tétons"
    ],
    "variantes": [
      "Développé incliné",
      "Développé décliné",
      "Close grip bench press"
    ],
    "muscles_primaires": ["grand_pectoral"],
    "muscles_secondaires": ["triceps", "deltoide_anterieur"]
  }
  ```

- [ ] Champs obligatoires: id, nom, groupesMusculaires, type, emoji
- [ ] Champs optionnels: description, conseils, variantes
- [ ] Validation: Pas de doublons, noms uniques
- [ ] Emojis variés et pertinents par catégorie

**Mapping emojis:**
```
Pectoraux: 💪
Dos: 🦾
Jambes: 🦵
Épaules: 🏋️
Bras: 💪
Abdos: 🔥
Cardio: 🏃
Full Body: ⚡
```

---

### US-V2-13.3: Script Seed Amélioré
**Effort:** 1h

**Critères d'acceptation:**
- [ ] Améliorer `scripts/seed_exercises.dart`:
  - Lire nouveau fichier JSON v2
  - Détecter exercices déjà existants (skip)
  - Batch write optimisé (500 exercices max par batch)
  - Logs détaillés: "153 exercices ajoutés, 2 doublons skippés"
  - Dry-run mode pour test
- [ ] Script de vérification intégrité:
  - Tous exercices ont emoji
  - Pas de groupeMusculaire inconnu
  - Tous types valides (poids_libres, machine, corporel, cardio)

**Commande:**
```bash
# Seed production
dart run scripts/seed_exercises.dart

# Dry-run (test)
dart run scripts/seed_exercises.dart --dry-run

# Vérification intégrité
dart run scripts/validate_exercises.dart
```

---

## Livrables EPIC-V2-13

- [ ] Base 150-180 exercices catégorisés
- [ ] Fichier JSON structuré avec descriptions
- [ ] Script seed amélioré avec validation
- [ ] Script vérification intégrité
- [ ] Documentation exercices dans `docs/exercices.md`
- [ ] Tests validation données

---

# EPIC-V2-1 : STATISTIQUES & GRAPHIQUES 📊

**Priorité:** P0 (Haute valeur utilisateur)  
**Effort:** 18h  
**Sprint:** 1-2  
**Dépendances:** MVP V1  
**ROI:** ⭐⭐⭐⭐⭐ (Feature la plus demandée)

## Objectif

Fournir des insights visuels sur la progression de l'utilisateur avec graphiques interactifs et statistiques détaillées.

## User Stories

### US-V2-1.1: Dashboard Statistiques Global
**Effort:** 4h

**Critères d'acceptation:**
- [ ] Nouvel écran "Statistiques" accessible depuis HomePage
- [ ] KPIs affichés:
  - Nombre total de séances (all time)
  - Nombre de séances ce mois
  - Volume total levé (somme poids × reps) ce mois
  - Exercice le plus fréquent
  - Record personnel (PR) récent
  - Streak (jours consécutifs avec séance)
- [ ] Cards glassmorphism avec animations
- [ ] Période sélectionnable (Semaine / Mois / Année / Tout)
- [ ] Design cohérent avec MVP V1 (MarbleCard + GoldenBadge pour records)

**Packages requis:**
```yaml
dependencies:
  fl_chart: ^0.68.0  # Graphiques Flutter
  intl: ^0.19.0      # Formatage dates/nombres
```

**Spécifications techniques:**
- Écran: `lib/screens/statistics/statistics_screen.dart`
- Service: `lib/core/services/statistics_service.dart`
- Modèle: `lib/core/models/statistics.dart`

---

### US-V2-1.2: Graphique Progression par Exercice
**Effort:** 6h

**Critères d'acceptation:**
- [ ] Graphique courbe (LineChart) poids × temps pour un exercice
- [ ] Sélection exercice via dropdown/autocomplete
- [ ] Axe X: Dates des séances
- [ ] Axe Y: Poids maximal levé par séance
- [ ] Points cliquables → Affichage détail séance
- [ ] Zoom et pan pour navigation
- [ ] Toggle entre "Poids max" et "Volume total" (poids × reps)
- [ ] Affichage tendance (ligne de régression linéaire)
- [ ] Légendes et tooltips

**Exemple UI:**
```
┌─────────────────────────────────────┐
│ Progression - Développé Couché     │
│ [Dropdown exercices]                │
│                                     │
│  100kg ┐                           │
│   90kg ┤       ●──●──●             │
│   80kg ┤   ●──●                    │
│   70kg ┤●──●                       │
│   60kg └─────────────────────────  │
│         Jan  Fev  Mar              │
│                                     │
│ 📈 +15kg en 3 mois (+23%)          │
│ 🏆 Record: 95kg (12/03/2026)       │
└─────────────────────────────────────┘
```

**Spécifications techniques:**
- Widget: `lib/screens/statistics/exercise_progress_chart.dart`
- Service: Méthode `getExerciseProgressData(exerciseId, period)`
- Package: `fl_chart` (LineChart)

---

### US-V2-1.3: Graphique Volume Total (Bar Chart)
**Effort:** 3h

**Critères d'acceptation:**
- [ ] Bar chart volume total (poids × reps) par semaine/mois
- [ ] Période sélectionnable (4 semaines / 3 mois / 6 mois / 1 an)
- [ ] Bars colorées (gradient selon volume)
- [ ] Tooltip sur hover → Détail volume par groupe musculaire
- [ ] Comparaison avec période précédente (% variation)
- [ ] Design glassmorphism

**Exemple calcul volume:**
```
Séance du 15/02:
- Développé couché: 3 séries (10×80kg + 8×85kg + 6×90kg) = 2420kg
- Squat: 4 séries (12×100kg + 10×110kg + 8×120kg + 6×130kg) = 4580kg
Volume total séance: 7000kg
```

**Spécifications techniques:**
- Widget: `lib/screens/statistics/volume_bar_chart.dart`
- Service: Méthode `getVolumeByPeriod(period)`

---

### US-V2-1.4: Records Personnels (PR Tracking)
**Effort:** 3h

**Critères d'acceptation:**
- [ ] Page "Records Personnels" listant tous les PR
- [ ] Par exercice: Poids max levé + Date + Nombre reps
- [ ] Badge doré (GoldenBadge) pour nouveau record
- [ ] Animation célébration quand nouveau PR battu
- [ ] Historique des PR (ancien vs nouveau)
- [ ] Filtrage par groupe musculaire
- [ ] Tri par date ou poids

**Détection automatique PR:**
- PR = Poids max levé pour un exercice (toutes séances confondues)
- Notification in-app lors d'un nouveau PR
- Badge "New PR!" animé avec confettis

**Spécifications techniques:**
- Écran: `lib/screens/statistics/personal_records_screen.dart`
- Service: `statistics_service.dart` (méthode `detectNewPR()`)
- Widget: `lib/core/widgets/pr_celebration_animation.dart`

---

### US-V2-1.5: Calendrier Heatmap Séances
**Effort:** 2h

**Critères d'acceptation:**
- [ ] Calendrier annuel type GitHub contribution graph
- [ ] Carrés colorés selon intensité (nombre exercices ou volume)
- [ ] Clic sur jour → Détail séance
- [ ] Affichage streak (jours consécutifs)
- [ ] Tooltips sur hover
- [ ] Légende gradient couleur

**Package recommandé:**
```yaml
dependencies:
  flutter_heatmap_calendar: ^1.0.5
```

**Exemple UI:**
```
┌─────────────────────────────────────┐
│ Calendrier 2026                    │
│                                     │
│ Jan [█░█░░█████░█░]                │
│ Fév [████████░░█░]                 │
│ Mar [█░█████░░░░]                  │
│                                     │
│ 🔥 Streak actuel: 7 jours          │
│ 🏆 Meilleur streak: 21 jours       │
└─────────────────────────────────────┘
```

---

## Livrables EPIC-V2-1

- [ ] 5 écrans statistiques complets
- [ ] Service statistics_service.dart avec calculs optimisés
- [ ] Modèles Statistics et PersonalRecord
- [ ] 3 types de graphiques (Line, Bar, Heatmap)
- [ ] Animations célébration PR
- [ ] Tests unitaires calculs stats

---

# EPIC-V2-2 : ACHIEVEMENTS & GAMIFICATION 🏆

**Priorité:** P1 (Forte rétention utilisateur)  
**Effort:** 12h  
**Sprint:** 2-3  
**Dépendances:** EPIC-V2-1 (Statistiques)  
**ROI:** ⭐⭐⭐⭐ (Motivation et engagement)

## Objectif

Gamifier l'expérience avec achievements, challenges et système de motivation pour augmenter l'engagement et la rétention.

## User Stories

### US-V2-2.1: Système d'Achievements (Trophées)
**Effort:** 5h

**Critères d'acceptation:**
- [ ] Collection d'achievements prédéfinis (30-50 trophées)
- [ ] Catégories:
  - **Débutant:** "Première séance", "10 séances", "1 mois continu"
  - **Volume:** "10 000kg levés", "100 000kg levés", "1 million kg"
  - **Streak:** "7 jours consécutifs", "30 jours", "100 jours"
  - **Spécialiste:** "50 séances pectoraux", "100 squats"
  - **Records:** "Premier PR", "10 PR battus", "PR 100kg+"
  - **Explorateur:** "Testé 20 exercices", "Tous groupes musculaires"
- [ ] Écran "Achievements" avec progression
- [ ] Notification in-app lors d'unlock
- [ ] Design avec GoldenBadge + animations unlock
- [ ] Barre de progression par catégorie
- [ ] Partage achievements (optionnel)

**Exemple achievements:**
```json
{
  "id": "achievement_first_pr",
  "title": "Premier Record",
  "description": "Battre votre premier PR",
  "icon": "🏆",
  "category": "records",
  "requirement": {
    "type": "pr_count",
    "value": 1
  },
  "reward": {
    "xp": 100,
    "badge": "golden"
  }
}
```

**Spécifications techniques:**
- Écran: `lib/screens/achievements/achievements_screen.dart`
- Modèle: `lib/core/models/achievement.dart`
- Service: `lib/core/services/achievements_service.dart`
- Widget: `lib/core/widgets/achievement_unlock_dialog.dart`

---

### US-V2-2.2: Challenges Hebdomadaires
**Effort:** 4h

**Critères d'acceptation:**
- [ ] Challenges générés automatiquement chaque lundi
- [ ] Types de challenges:
  - "Effectue 5 séances cette semaine"
  - "Lève 30 000kg de volume total"
  - "Travaille tous les groupes musculaires"
  - "Bats un nouveau PR"
  - "Effectue 10 exercices différents"
- [ ] Progression affichée sur HomePage (widget)
- [ ] Notification push le lundi matin (optionnel)
- [ ] Récompense: Badge spécial + XP bonus
- [ ] Historique challenges complétés

**Exemple UI HomePage:**
```
┌─────────────────────────────────────┐
│ 🎯 Challenge de la semaine         │
│                                     │
│ "Effectue 5 séances"               │
│ [████░░░░░░] 3/5 séances           │
│                                     │
│ Récompense: 🏆 +500 XP             │
└─────────────────────────────────────┘
```

**Spécifications techniques:**
- Widget: `lib/core/widgets/weekly_challenge_card.dart`
- Service: `challenges_service.dart` (génération + vérification)
- Modèle: `lib/core/models/challenge.dart`

---

### US-V2-2.3: Système XP et Niveaux
**Effort:** 3h

**Critères d'acceptation:**
- [ ] Système de points d'expérience (XP)
- [ ] Calcul XP par action:
  - Terminer séance: +50 XP
  - Ajouter exercice: +10 XP
  - Battre PR: +100 XP
  - Unlock achievement: +50-500 XP (selon rareté)
  - Compléter challenge: +500 XP
- [ ] Niveaux de 1 à 100 (progression exponentielle)
- [ ] Affichage niveau utilisateur dans ProfileDrawer
- [ ] Barre de progression XP vers niveau suivant
- [ ] Titre de prestige selon niveau:
  - 1-10: "Débutant"
  - 11-25: "Intermédiaire"
  - 26-50: "Avancé"
  - 51-75: "Expert"
  - 76-99: "Maître"
  - 100: "Légende"

**Exemple calcul niveau:**
```dart
int getRequiredXP(int level) {
  return 100 * level * level; // Exponentiel
}

// Niveau 1 → 2: 100 XP
// Niveau 2 → 3: 400 XP
// Niveau 10 → 11: 10 000 XP
```

**Spécifications techniques:**
- Modèle: Ajouter fields `xp` et `level` dans `User`
- Service: `gamification_service.dart`
- Widget: `lib/core/widgets/level_progress_bar.dart`

---

## Livrables EPIC-V2-2

- [ ] 30-50 achievements prédéfinis
- [ ] Système challenges hebdomadaires
- [ ] Système XP et niveaux (1-100)
- [ ] Écran Achievements complet
- [ ] Animations unlock premium
- [ ] Tests logique gamification

---

# EPIC-V2-3 : TIMER AVANCÉ & REPOS ⏱️

**Priorité:** P1 (Haute utilité)  
**Effort:** 8h  
**Sprint:** 3  
**Dépendances:** MVP V1  
**ROI:** ⭐⭐⭐⭐ (Améliore qualité entraînement)

## Objectif

Ajouter timer de repos entre séries et chronomètre par exercice pour suivre précisément les temps de repos et d'exécution.

## User Stories

### US-V2-3.1: Timer de Repos Entre Séries
**Effort:** 4h

**Critères d'acceptation:**
- [ ] Après ajout d'une série, affichage automatique timer repos
- [ ] Durées prédéfinies configurables:
  - Repos court: 30s-1min (cardio, endurance)
  - Repos moyen: 1-2min (hypertrophie)
  - Repos long: 3-5min (force max)
- [ ] Timer compte à rebours avec progression circulaire
- [ ] Notification sonore + vibration à la fin
- [ ] Boutons: "Skip", "Add 30s", "Reset"
- [ ] Continuer même si app en background (notification)
- [ ] Paramètres globaux: durées par défaut par type exercice

**Exemple UI:**
```
┌─────────────────────────────────────┐
│     ⏱️ Repos en cours               │
│                                     │
│         ╱────────╲                 │
│        │   1:23   │   [Skip]       │
│         ╲────────╱                 │
│                                     │
│ [+30s]    [Reset]    [Suivant]     │
└─────────────────────────────────────┘
```

**Spécifications techniques:**
- Dialog: `lib/core/widgets/rest_timer_dialog.dart`
- Service: `lib/core/services/timer_service.dart`
- Provider: Ajouter gestion timer dans `WorkoutProvider`
- Package: `flutter_local_notifications` pour background

---

### US-V2-3.2: Chronomètre par Exercice
**Effort:** 2h

**Critères d'acceptation:**
- [ ] Dans WorkoutSessionScreen, afficher temps passé sur exercice actuel
- [ ] Démarre automatiquement à la sélection exercice
- [ ] Pause si retour en arrière
- [ ] Sauvegarde durée dans WorkoutExercise
- [ ] Affichage historique: "Durée moyenne exercice: 8min 30s"
- [ ] Statistiques: temps par exercice, exercice le plus long

**Spécifications techniques:**
- Modèle: Ajouter field `duration` dans `WorkoutExercise`
- Widget: Intégrer dans `WorkoutTimerAppBar`

---

### US-V2-3.3: Paramètres Timer
**Effort:** 2h

**Critères d'acceptation:**
- [ ] Écran Paramètres accessible depuis ProfileDrawer
- [ ] Configuration:
  - Durées repos par défaut (court/moyen/long)
  - Activer/désactiver notifications sonores
  - Activer/désactiver vibrations
  - Auto-démarrage timer après série
  - Personnalisation durées par exercice (optionnel)
- [ ] Sauvegarde dans SharedPreferences
- [ ] Design cohérent avec V1

**Spécifications techniques:**
- Écran: `lib/screens/settings/settings_screen.dart`
- Modèle: `lib/core/models/settings.dart`
- Provider: `lib/core/providers/settings_provider.dart`

---

## Livrables EPIC-V2-3

- [ ] Timer repos automatique entre séries
- [ ] Chronomètre par exercice
- [ ] Écran paramètres complet
- [ ] Notifications background
- [ ] Tests timer service

---

# EPIC-V2-4 : TEMPLATES SÉANCES 📋

**Priorité:** P1 (Gain de temps significatif)  
**Effort:** 10h  
**Sprint:** 4  
**Dépendances:** MVP V1  
**ROI:** ⭐⭐⭐⭐ (Économie temps 50%)

## Objectif

Permettre la sauvegarde et réutilisation de séances types (split routines) pour accélérer la saisie et standardiser les entraînements.

## User Stories

### US-V2-4.1: Créer Template depuis Séance Complétée
**Effort:** 4h

**Critères d'acceptation:**
- [ ] Bouton "Sauvegarder comme template" dans WorkoutDetailScreen
- [ ] Dialog de création template:
  - Nom du template (ex: "Push Day", "Leg Day", "Full Body")
  - Description (optionnel)
  - Icône/emoji
  - Couleur tag
- [ ] Template sauvegarde:
  - Liste exercices (sans séries ni poids)
  - Ordre des exercices
  - Notes éventuelles
- [ ] Collection Firestore: `users/{userId}/templates/`

**Spécifications techniques:**
- Modèle: `lib/core/models/workout_template.dart`
- Service: `lib/core/services/template_service.dart`
- Dialog: `lib/core/widgets/create_template_dialog.dart`

---

### US-V2-4.2: Démarrer Séance depuis Template
**Effort:** 3h

**Critères d'acceptation:**
- [ ] Sur HomePage, option "Démarrer depuis template"
- [ ] Liste templates disponibles (grille avec cards)
- [ ] Clic sur template → Nouvelle séance pré-remplie avec exercices
- [ ] Historique auto-chargé pour chaque exercice (comme V1)
- [ ] Possibilité ajouter/supprimer exercices
- [ ] Gain de temps: pas de sélection exercices manuelle

**Exemple UI:**
```
┌─────────────────────────────────────┐
│ 📋 Mes Templates                   │
│                                     │
│ ┌──────┐  ┌──────┐  ┌──────┐      │
│ │ 💪   │  │ 🦵   │  │ 🔥   │      │
│ │ Push │  │ Legs │  │ Full │      │
│ │ Day  │  │ Day  │  │ Body │      │
│ └──────┘  └──────┘  └──────┘      │
│                                     │
│ [+ Nouveau template]               │
└─────────────────────────────────────┘
```

---

### US-V2-4.3: Gestion Templates (CRUD)
**Effort:** 2h

**Critères d'acceptation:**
- [ ] Écran "Mes Templates" accessible depuis menu
- [ ] Actions:
  - Modifier template (nom, exercices, ordre)
  - Dupliquer template
  - Supprimer template (confirmation)
  - Réorganiser par drag & drop
- [ ] Statistiques par template:
  - Nombre d'utilisations
  - Dernière utilisation
  - Durée moyenne

---

### US-V2-4.4: Templates Prédéfinis (Seed)
**Effort:** 1h

**Critères d'acceptation:**
- [ ] Templates populaires pré-créés lors du premier lancement:
  - "Push Day" (Pectoraux, Épaules, Triceps)
  - "Pull Day" (Dos, Biceps)
  - "Leg Day" (Quadriceps, Ischio, Mollets, Fessiers)
  - "Upper Body" (Haut du corps complet)
  - "Lower Body" (Bas du corps complet)
  - "Full Body" (Tout le corps)
- [ ] Option "Importer templates populaires" dans paramètres

---

## Livrables EPIC-V2-4

- [ ] Système templates complet (CRUD)
- [ ] 6 templates prédéfinis
- [ ] Écran gestion templates
- [ ] Démarrage rapide séance depuis template
- [ ] Tests service templates

---

# EPIC-V2-5 : IMAGES IA EXERCICES 🎨

**Priorité:** P2 (Esthétique premium)  
**Effort:** 12h  
**Sprint:** 4-5  
**Dépendances:** MVP V1  
**ROI:** ⭐⭐⭐ (Design premium mais non critique)

## Objectif

Remplacer les emojis par des images générées par IA pour chaque exercice, augmentant l'aspect premium et visuel de l'application.

## User Stories

### US-V2-5.1: Génération Images IA (Batch)
**Effort:** 6h

**Critères d'acceptation:**
- [ ] Script Python/Node pour générer images via API IA:
  - **Stable Diffusion** (open-source, gratuit)
  - **DALL-E 3** (API OpenAI, payant)
  - **Midjourney** (via Discord bot, semi-auto)
- [ ] Prompt template pour cohérence:
  ```
  "Professional fitness illustration of [EXERCISE_NAME],
   clean minimalist style, exercise equipment visible,
   proper form demonstration, dark background with blue accent,
   digital art, high quality"
  ```
- [ ] Génération pour ~50 exercices existants
- [ ] Format: PNG 512×512, optimisé poids < 100KB
- [ ] Stockage: Firebase Storage ou CDN
- [ ] Fallback emoji si image non disponible

**Spécifications techniques:**
- Script: `scripts/generate_exercise_images.py`
- Storage: Firebase Storage `exercises/{exerciseId}.png`
- Modèle: Ajouter field `imageUrl` dans `Exercise`

---

### US-V2-5.2: Affichage Images dans UI
**Effort:** 3h

**Critères d'acceptation:**
- [ ] Remplacer emoji par image dans:
  - ExerciseSelectionScreen (liste exercices)
  - WorkoutSessionScreen (header exercice)
  - HistoryScreen (détail séances)
  - StatisticsScreen (graphiques)
- [ ] Image avec border-radius 16px
- [ ] Effet glassmorphism sur image (overlay subtil)
- [ ] Shimmer loading pendant chargement
- [ ] Cache images localement (persistent_cache)

**Package recommandé:**
```yaml
dependencies:
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
```

---

### US-V2-5.3: Upload Images Personnalisées (Bonus)
**Effort:** 3h

**Critères d'acceptation:**
- [ ] Option "Personnaliser image" dans détail exercice
- [ ] Upload depuis galerie ou appareil photo
- [ ] Crop et redimensionnement automatique
- [ ] Stockage Firebase Storage avec path unique
- [ ] Limite taille: 5MB max, 1024×1024 recommandé

**Package recommandé:**
```yaml
dependencies:
  image_picker: ^1.0.7
  image_cropper: ^5.0.1
```

---

## Livrables EPIC-V2-5

- [ ] 50+ images IA générées
- [ ] Script génération automatisé
- [ ] Affichage images dans toute l'app
- [ ] Cache et optimisation loading
- [ ] Upload images personnalisées (bonus)

---

# EPIC-V2-6 : SOCIAL & PARTAGE 🌐

**Priorité:** P2 (Communauté et engagement)  
**Effort:** 15h  
**Sprint:** 5-6  
**Dépendances:** EPIC-V2-1, EPIC-V2-2  
**ROI:** ⭐⭐⭐⭐ (Viralité et rétention)

## Objectif

Ajouter dimension sociale avec partage de séances, comparaisons entre amis et leaderboards pour créer une communauté.

## User Stories

### US-V2-6.1: Partage Séance (Image)
**Effort:** 5h

**Critères d'acceptation:**
- [ ] Bouton "Partager" dans WorkoutDetailScreen
- [ ] Génération image stylisée (workout card) contenant:
  - Logo Apollon
  - Date et durée séance
  - Liste exercices + séries
  - Volume total levé
  - Nouveau PR (si applicable)
  - QR code vers app (optionnel)
- [ ] Design premium avec gradient, glassmorphism
- [ ] Export image vers:
  - Galerie locale
  - Instagram Stories (deeplink)
  - WhatsApp / Messages
  - Clipboard
- [ ] Watermark discret "Made with Apollon"

**Package recommandé:**
```yaml
dependencies:
  screenshot: ^2.3.0
  share_plus: ^7.2.2
  path_provider: ^2.1.2
```

**Exemple workout card:**
```
┌─────────────────────────────────────┐
│  🏛️ APOLLON                         │
│                                     │
│  Séance du 15 Février 2026         │
│  ⏱️ Durée: 1h 23min                 │
│                                     │
│  💪 Développé Couché                │
│     10×80kg, 8×85kg, 6×90kg        │
│                                     │
│  🏋️ Squat                            │
│     12×100kg, 10×110kg, 8×120kg    │
│                                     │
│  📊 Volume total: 7,240kg          │
│  🏆 Nouveau PR: Squat 120kg        │
│                                     │
│  Made with Apollon 💪              │
└─────────────────────────────────────┘
```

---

### US-V2-6.2: Système Amis
**Effort:** 6h

**Critères d'acceptation:**
- [ ] Recherche utilisateurs par email/pseudo
- [ ] Envoi demande d'ami
- [ ] Acceptation/refus demandes
- [ ] Liste amis dans écran "Social"
- [ ] Voir profil ami:
  - Niveau et XP
  - Nombre séances total
  - Records personnels (si partagés)
  - Dernière activité
- [ ] Comparaison stats avec amis:
  - Volume total ce mois
  - Nombre séances ce mois
  - Streak
- [ ] Leaderboard amis (classement par XP ou volume)

**Spécifications techniques:**
- Collection Firestore: `users/{userId}/friends/`
- Modèle: `lib/core/models/friend.dart`
- Service: `lib/core/services/social_service.dart`
- Écran: `lib/screens/social/social_screen.dart`

---

### US-V2-6.3: Leaderboard Global (Optionnel)
**Effort:** 4h

**Critères d'acceptation:**
- [ ] Leaderboard global top 100 par:
  - XP total
  - Volume levé ce mois
  - Streak actuel
  - Nombre séances total
- [ ] Filtres:
  - Global
  - Pays
  - Ville (via géolocalisation optionnelle)
- [ ] Anonymat: Pseudo ou "Utilisateur ###"
- [ ] Actualisation quotidienne (pas temps réel)
- [ ] Design MarbleCard + GoldenBadge pour podium

**Note privacy:**
- Opt-in obligatoire (demander permission)
- Possibilité masquer son profil
- RGPD compliant

---

## Livrables EPIC-V2-6

- [ ] Partage séances (workout cards)
- [ ] Système amis complet
- [ ] Leaderboards privés (amis)
- [ ] Leaderboard global (optionnel)
- [ ] Tests social service

---

# EPIC-V2-7 : EXPORT & BACKUP 💾

**Priorité:** P2 (Sécurité données utilisateur)  
**Effort:** 6h  
**Sprint:** 6  
**Dépendances:** MVP V1  
**ROI:** ⭐⭐⭐ (Confiance utilisateur)

## Objectif

Permettre export des données personnelles et backup pour sécurité et portabilité.

## User Stories

### US-V2-7.1: Export CSV
**Effort:** 3h

**Critères d'acceptation:**
- [ ] Option "Exporter données" dans Paramètres
- [ ] Format CSV avec colonnes:
  ```
  date,exercice,groupe_musculaire,serie_numero,reps,poids_kg,volume,duree_exercice
  ```
- [ ] Génération fichier `apollon_export_YYYYMMDD.csv`
- [ ] Sauvegarde dans dossier Downloads
- [ ] Compatible Excel, Google Sheets, Numbers
- [ ] Encoding UTF-8 avec BOM

**Package recommandé:**
```yaml
dependencies:
  csv: ^6.0.0
  path_provider: ^2.1.2
  permission_handler: ^11.3.0
```

---

### US-V2-7.2: Export PDF (Rapport)
**Effort:** 2h

**Critères d'acceptation:**
- [ ] Génération rapport PDF stylisé contenant:
  - Profil utilisateur (nom, niveau, XP)
  - Statistiques clés (séances total, volume, PR)
  - Historique séances (derniers 3 mois)
  - Graphique progression (image exportée)
  - Records personnels
- [ ] Design premium cohérent avec app
- [ ] Logo Apollon
- [ ] Nom fichier: `apollon_rapport_YYYYMMDD.pdf`

**Package recommandé:**
```yaml
dependencies:
  pdf: ^3.10.8
  printing: ^5.12.0
```

---

### US-V2-7.3: Backup Cloud Automatique
**Effort:** 1h

**Critères d'acceptation:**
- [ ] Backup automatique quotidien dans Firestore
- [ ] Indicateur "Dernière sauvegarde: il y a X heures"
- [ ] Option "Sauvegarder maintenant" manuelle
- [ ] Restauration depuis cloud en cas de réinstall
- [ ] Conservation 90 jours de backups

**Note:** Déjà partiellement couvert par Firestore, mais ajouter redondance explicite.

---

## Livrables EPIC-V2-7

- [ ] Export CSV complet
- [ ] Export PDF rapport stylisé
- [ ] Backup cloud automatique
- [ ] Écran gestion données (export/backup)
- [ ] Tests export service

---

# EPIC-V2-8 : CALCUL 1RM & OUTILS PRO 🎯

**Priorité:** P3 (Niche powerlifters/strength)  
**Effort:** 10h  
**Sprint:** 7  
**Dépendances:** MVP V1  
**ROI:** ⭐⭐⭐ (Audience spécifique)

## Objectif

Ajouter outils avancés pour powerlifters et athlètes force : calcul 1RM, planification cycles, recommandations progression.

## User Stories

### US-V2-8.1: Calculatrice 1RM (One Rep Max)
**Effort:** 3h

**Critères d'acceptation:**
- [ ] Écran "Calculatrice 1RM" accessible depuis outils
- [ ] Input: Poids levé + Nombre de répétitions
- [ ] Output: 1RM estimé avec formules multiples:
  - **Epley:** 1RM = poids × (1 + reps/30)
  - **Brzycki:** 1RM = poids × 36 / (37 - reps)
  - **Lander:** 1RM = 100 × poids / (101.3 - 2.67123 × reps)
  - **Moyenne des 3**
- [ ] Affichage pourcentages 1RM (85%, 90%, 95%)
- [ ] Historique calculs
- [ ] Suggestion: "Pour augmenter ton 1RM, travaille à 85% pendant 4 semaines"

**Exemple UI:**
```
┌─────────────────────────────────────┐
│ 🎯 Calculatrice 1RM                │
│                                     │
│ Poids levé: [____] kg              │
│ Répétitions: [____]                │
│                                     │
│ [Calculer]                         │
│                                     │
│ 📊 Résultats:                      │
│ 1RM Epley:    120kg               │
│ 1RM Brzycki:  118kg               │
│ 1RM Lander:   119kg               │
│ ──────────────────────            │
│ 1RM Estimé:   119kg ±2kg          │
│                                     │
│ 💪 Pourcentages:                   │
│ 85% = 101kg                        │
│ 90% = 107kg                        │
│ 95% = 113kg                        │
└─────────────────────────────────────┘
```

---

### US-V2-8.2: Tracking 1RM Historique
**Effort:** 3h

**Critères d'acceptation:**
- [ ] Calcul automatique 1RM pour chaque série effectuée
- [ ] Graphique évolution 1RM par exercice
- [ ] Comparaison 1RM théorique vs effectif (si testé)
- [ ] Prédiction 1RM dans 1 mois (machine learning basique)
- [ ] Affichage dans StatisticsScreen

---

### US-V2-8.3: Recommandations Progression (IA Simple)
**Effort:** 4h

**Critères d'acceptation:**
- [ ] Analyse automatique des séances passées
- [ ] Recommandations personnalisées:
  - "Tu devrais augmenter le poids de 2.5kg au développé couché"
  - "Baisse tes répétitions et augmente le poids pour gagner en force"
  - "Tu stagnes sur squat depuis 3 semaines, essaye un deload"
  - "Tu travailles trop les pectoraux vs le dos (déséquilibre)"
- [ ] Algorithme basé sur:
  - Progression/stagnation poids
  - Volume vs intensité
  - Fréquence par groupe musculaire
  - Ratio push/pull
- [ ] Card "Conseil du jour" sur HomePage
- [ ] Snooze conseil (pas intéressé)

**Exemple logique:**
```dart
if (lastWorkoutWeight == currentWeight && sameReps && sessions >= 3) {
  return "Tu stagnes. Essaye d'augmenter le poids de 2.5kg.";
}

if (pushVolume / pullVolume > 1.5) {
  return "Déséquilibre détecté: travaille plus ton dos !";
}
```

---

## Livrables EPIC-V2-8

- [ ] Calculatrice 1RM multi-formules
- [ ] Tracking 1RM historique + graphique
- [ ] Recommandations progression (IA simple)
- [ ] Écran "Outils Pro"
- [ ] Tests calculs 1RM

---

# EPIC-V2-9 : EXERCICES PERSONNALISÉS ✏️

**Priorité:** P3 (Flexibilité avancée)  
**Effort:** 8h  
**Sprint:** 7  
**Dépendances:** MVP V1  
**ROI:** ⭐⭐⭐ (Utilisateurs avancés)

## Objectif

Permettre aux utilisateurs de créer leurs propres exercices personnalisés pour couvrir cas spécifiques non inclus dans la base prédéfinie.

## User Stories

### US-V2-9.1: Créer Exercice Personnalisé
**Effort:** 4h

**Critères d'acceptation:**
- [ ] Option "Créer exercice" dans ExerciseSelectionScreen
- [ ] Formulaire création:
  - Nom exercice (obligatoire, unique)
  - Description (optionnel)
  - Groupe(s) musculaire(s) ciblé(s)
  - Type (poids libres/machine/corporel/cardio)
  - Emoji ou upload image
  - Notes personnelles
- [ ] Validation unicité nom (scope: utilisateur uniquement)
- [ ] Sauvegarde dans `users/{userId}/custom_exercises/`
- [ ] Visible uniquement pour l'utilisateur créateur
- [ ] Apparaît dans liste exercices (badge "Personnalisé")

**Spécifications techniques:**
- Collection: `users/{userId}/custom_exercises/`
- Modèle: `CustomExercise extends Exercise`
- Service: Merger exercices globaux + custom dans `ExerciseService`

---

### US-V2-9.2: Modifier/Supprimer Exercice Personnalisé
**Effort:** 2h

**Critères d'acceptation:**
- [ ] Long press sur exercice custom → Menu contextuel
- [ ] Actions: Modifier / Supprimer / Dupliquer
- [ ] Modification: Réouvre formulaire pré-rempli
- [ ] Suppression: Confirmation + vérification utilisation dans séances
- [ ] Si exercice utilisé dans historique: Option "Masquer" au lieu de supprimer

---

### US-V2-9.3: Import Exercices depuis Communauté (Bonus)
**Effort:** 2h

**Critères d'acceptation:**
- [ ] Base exercices communautaires (contributeurs anonymes)
- [ ] Browse exercices partagés
- [ ] Import dans sa propre liste
- [ ] Vote/like exercices populaires
- [ ] Modération (flag exercices inappropriés)

**Note:** Feature avancée, nécessite modération. À évaluer selon succès app.

---

## Livrables EPIC-V2-9

- [ ] CRUD exercices personnalisés complet
- [ ] Merge exercices globaux + custom
- [ ] Gestion conflits noms
- [ ] Import communautaire (bonus)
- [ ] Tests custom exercises service

---

# EPIC-V2-10 : OPTIMISATIONS & POLISH 🚀

**Priorité:** P1 (Qualité et performance)  
**Effort:** Variable (5-10h)  
**Sprint:** Continu  

## Objectif

Optimisations performance, animations avancées, mode offline amélioré, et polish général.

## Tasks Continues

### Optimisation Performance
- [ ] Profiling app avec Flutter DevTools
- [ ] Optimisation requêtes Firestore (indexes composites)
- [ ] Lazy loading images et données
- [ ] Pagination historique (infinite scroll)
- [ ] Cache agressif données statiques (exercices)
- [ ] Réduction taille app (tree shaking, obfuscation)

### Mode Offline Avancé
- [ ] Sync manager intelligent (retry exponentiel)
- [ ] Indicateur sync status persistant
- [ ] Queue d'actions offline → replay au retour connexion
- [ ] Conflict resolution séances modifiées offline

### Animations Premium++
- [ ] Hero animations entre écrans
- [ ] Parallax effects
- [ ] Confettis célébration PR/achievements
- [ ] Micro-interactions (ripple, scale, fade)
- [ ] Skeleton loaders élégants
- [ ] Page transitions custom (slide, fade, scale)

### Accessibilité
- [ ] Support lecteurs d'écran
- [ ] Contraste couleurs WCAG AA
- [ ] TalkBack / VoiceOver
- [ ] Tailles texte scalables

---

# EPIC-V2-11 : PODOMÈTRE QUOTIDIEN 🚶

**Priorité:** P1 (Santé globale et engagement quotidien)  
**Effort:** 14h  
**Sprint:** 3-4  
**Dépendances:** MVP V1  
**ROI:** ⭐⭐⭐⭐ (Engagement quotidien, santé globale)

## Objectif

Tracker les pas de l'utilisateur tout au long de la journée avec enregistrement automatique en fin de journée dans Firestore et visualisation dans un calendrier mensuel.

## User Stories

### US-V2-11.1: Service Podomètre Background
**Effort:** 5h

**Critères d'acceptation:**
- [ ] Intégration capteur podomètre natif (iOS/Android)
- [ ] Service background permanent comptant les pas
- [ ] Démarre automatiquement au boot du téléphone
- [ ] Fonctionne même quand app fermée
- [ ] Gestion économie batterie (iOS Core Motion, Android SensorManager)
- [ ] Reset compteur à minuit quotidien
- [ ] Notification persistante (Android) : "👟 X pas aujourd'hui"

**Packages requis:**
```yaml
dependencies:
  pedometer: ^4.0.2              # Compteur pas iOS/Android
  workmanager: ^0.5.2            # Background tasks
  flutter_local_notifications: ^17.0.0  # Notifications
  permission_handler: ^11.3.0    # Permissions capteurs
```

**Spécifications techniques:**
- Service: `lib/core/services/pedometer_service.dart`
- Background task: Enregistrement à 23:59 chaque jour
- Permissions: Activity Recognition (Android), Motion & Fitness (iOS)

**Code structure:**
```dart
class PedometerService {
  Stream<StepCount> get stepCountStream;
  
  // Démarre le tracking au lancement app
  Future<void> startTracking();
  
  // Sauvegarde quotidienne automatique à 23:59
  Future<void> saveDailySteps(int steps, DateTime date);
  
  // Récupère historique
  Future<List<DailySteps>> getStepHistory(DateTime start, DateTime end);
  
  // Stats
  int getTodaySteps();
  int getWeeklyAverage();
  int getMonthlyTotal();
}
```

---

### US-V2-11.2: Modèle et Stockage Firestore
**Effort:** 2h

**Critères d'acceptation:**
- [ ] Nouvelle collection Firestore: `users/{userId}/daily_steps/{date}`
- [ ] Structure document:
  ```json
  {
    "date": "2026-02-15",
    "steps": 8543,
    "distance_km": 6.12,
    "calories": 315,
    "active_minutes": 87,
    "created_at": "2026-02-15T23:59:00Z"
  }
  ```
- [ ] Calcul automatique distance (pas × 0.75m moyenne)
- [ ] Calcul automatique calories (0.04 cal/pas)
- [ ] Index Firestore pour queries rapides

**Spécifications techniques:**
- Modèle: `lib/core/models/daily_steps.dart`
- Collection: `users/{userId}/daily_steps/`
- Index: `date` (descendant)

---

### US-V2-11.3: Widget Compteur HomePage
**Effort:** 3h

**Critères d'acceptation:**
- [ ] Card glassmorphism sur HomePage affichant:
  - Nombre de pas aujourd'hui (temps réel)
  - Objectif quotidien (défaut: 10 000 pas)
  - Barre de progression circulaire
  - Distance parcourue (km)
  - Calories brûlées
- [ ] Animation incrémentale du compteur (nombre qui monte)
- [ ] Icône emoji 🚶 / 🏃 selon rythme (< 5000 = 🚶, > 10000 = 🏃)
- [ ] Clic sur card → Navigation vers calendrier pas

**Exemple UI:**
```
┌─────────────────────────────────────┐
│ 🚶 Pas Aujourd'hui                 │
│                                     │
│         ╱────────╲                 │
│        │  8,543  │   🎯 10,000    │
│         ╲────────╱                 │
│           85%                       │
│                                     │
│ 📏 6.1 km  🔥 315 kcal             │
└─────────────────────────────────────┘
```

**Spécifications techniques:**
- Widget: `lib/core/widgets/daily_steps_card.dart`
- Provider: `lib/core/providers/pedometer_provider.dart`
- Animation: AnimatedSwitcher pour compteur

---

### US-V2-11.4: Calendrier Pas Mensuel
**Effort:** 3h

**Critères d'acceptation:**
- [ ] Nouvel écran "Calendrier Pas" accessible depuis HomePage
- [ ] Calendrier mensuel avec nombre de pas par jour
- [ ] Coloration cellules selon objectif:
  - Gris: < 5000 pas
  - Jaune: 5000-7499 pas
  - Orange: 7500-9999 pas
  - Vert: 10000+ pas ✅
  - Or: 15000+ pas 🏆
- [ ] Clic sur jour → Détail (pas, distance, calories)
- [ ] Stats mois:
  - Total pas mois
  - Moyenne quotidienne
  - Jours objectif atteint
  - Record journalier
- [ ] Navigation mois précédent/suivant

**Package recommandé:**
```yaml
dependencies:
  table_calendar: ^3.0.9  # Calendrier interactif
```

**Exemple UI:**
```
┌─────────────────────────────────────┐
│ 🗓️ Février 2026                    │
│                                     │
│ L   M   M   J   V   S   D          │
│         1   2   3   4   5          │
│     [8k][9k][12k][6k][15k]        │
│ 6   7   8   9   10  11  12         │
│ [11k][8k][7k][10k][9k][13k][14k]  │
│ 13  14  15  ...                    │
│ [8k][10k][8.5k]                    │
│                                     │
│ 📊 Stats Février:                  │
│ Total: 245,000 pas                 │
│ Moyenne: 11,250 pas/jour           │
│ Objectif atteint: 18/28 jours      │
│ Record: 15,430 pas (5 fév)        │
└─────────────────────────────────────┘
```

**Spécifications techniques:**
- Écran: `lib/screens/pedometer/steps_calendar_screen.dart`
- Service: Méthode `getMonthlySteps(DateTime month)`

---

### US-V2-11.5: Paramètres Objectif
**Effort:** 1h

**Critères d'acceptation:**
- [ ] Option dans Paramètres: "Objectif quotidien pas"
- [ ] Slider 5000 - 20000 pas (incréments 1000)
- [ ] Valeur par défaut: 10 000 pas (recommandation OMS)
- [ ] Sauvegarde dans `users/{userId}/settings`
- [ ] Toggle "Activer/Désactiver podomètre"
- [ ] Toggle "Notifications quotidiennes" (rappel 20h si < objectif)

---

## Livrables EPIC-V2-11

- [ ] Service podomètre background fonctionnel
- [ ] Enregistrement automatique quotidien Firestore
- [ ] Widget compteur temps réel HomePage
- [ ] Calendrier mensuel avec codes couleur
- [ ] Paramètres objectif et notifications
- [ ] Tests service podomètre
- [ ] Documentation permissions iOS/Android

---

# EPIC-V2-12 : REFACTORING DATABASE FRANÇAIS 🇫🇷

**Priorité:** P2 (Dette technique, qualité code)  
**Effort:** 8h  
**Sprint:** 2  
**Dépendances:** MVP V1  
**ROI:** ⭐⭐⭐ (Maintenabilité, cohérence)

## Objectif

Refactoriser toute la structure Firestore et les modèles Dart pour utiliser des noms français cohérents, éliminer le franglais et améliorer la maintenabilité du code.

## User Stories

### US-V2-12.1: Audit et Mapping Noms
**Effort:** 2h

**Critères d'acceptation:**
- [ ] Document de mapping complet Anglais → Français

**Collections Firestore:**
```
users → utilisateurs
workouts → seances
exercises → exercices
daily_steps → pas_quotidiens
templates → modeles
achievements → realisations
friends → amis
```

**Champs (exemples):**
```
userId → utilisateurId
workoutId → seanceId
exerciseId → exerciceId
muscleGroups → groupesMusculaires
reps → repetitions
weight → poids
createdAt → creeA
updatedAt → modifieA
status → statut
```

**Variables code Dart:**
```dart
// Avant
final workout = Workout(...);
workout.exercises
workout.createdAt

// Après
final seance = Seance(...);
seance.exercices
seance.creeA
```

- [ ] Liste exhaustive à valider avant migration
- [ ] Document: `docs/migration-fr-v2.md`

---

### US-V2-12.2: Migration Modèles Dart
**Effort:** 3h

**Critères d'acceptation:**
- [ ] Renommer tous les modèles:
  - `Workout` → `Seance`
  - `WorkoutExercise` → `ExerciceSeance`
  - `WorkoutSet` → `Serie`
  - `Exercise` → `Exercice`
  - `DailySteps` → `PasQuotidiens`
  - `PersonalRecord` → `RecordPersonnel`
  - `Achievement` → `Realisation`
  - `Challenge` → `Defi`

- [ ] Renommer tous les champs dans les modèles
- [ ] Adapter méthodes `toFirestore()` et `fromFirestore()`
- [ ] Mettre à jour tous les imports dans le projet
- [ ] Compatibilité rétroactive: Support ancien + nouveau format pendant migration

**Exemple migration:**
```dart
// lib/core/models/seance.dart
class Seance {
  final String? id;
  final String utilisateurId;
  final DateTime date;
  final StatutSeance statut;
  final List<ExerciceSeance> exercices;
  final int? duree;
  final DateTime creeA;
  final DateTime modifieA;

  // Méthode de migration pour support rétrocompatibilité
  factory Seance.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Seance(
      id: doc.id,
      // Support ancien format (userId) et nouveau (utilisateurId)
      utilisateurId: data['utilisateurId'] ?? data['userId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      statut: StatutSeance.fromString(
        data['statut'] ?? data['status'] ?? 'draft'
      ),
      // ...
    );
  }
}
```

---

### US-V2-12.3: Migration Services et Providers
**Effort:** 2h

**Critères d'acceptation:**
- [ ] Renommer tous les services:
  - `WorkoutService` → `SeanceService`
  - `ExerciseService` → `ExerciceService`
  - `PedometerService` → `ServicePodometre`
  - `StatisticsService` → `ServiceStatistiques`

- [ ] Renommer providers:
  - `WorkoutProvider` → `FournisseurSeance`
  - `ThemeProvider` → `FournisseurTheme`
  - `AuthProvider` → `FournisseurAuthentification`

- [ ] Mettre à jour toutes les méthodes
- [ ] Adapter queries Firestore (noms collections)
- [ ] Tests unitaires à jour

---

### US-V2-12.4: Migration Data Firestore (Script)
**Effort:** 1h

**Critères d'acceptation:**
- [ ] Script Node.js/Dart pour migration données existantes:
  ```javascript
  // scripts/migrate_to_french.js
  
  // 1. Backup complet avant migration
  // 2. Pour chaque user:
  //    - Copier workouts → seances
  //    - Renommer champs (userId → utilisateurId, etc.)
  //    - Vérifier intégrité
  // 3. Rollback possible si erreurs
  ```

- [ ] Mode dry-run (test sans écriture)
- [ ] Logs détaillés migration
- [ ] Validation post-migration
- [ ] Suppression anciennes collections après validation

**Note importante:** Migration à faire en production uniquement quand tous les utilisateurs ont mis à jour l'app.

---

## Livrables EPIC-V2-12

- [ ] Document mapping complet EN→FR
- [ ] Tous modèles Dart renommés
- [ ] Tous services/providers renommés
- [ ] Script migration Firestore
- [ ] Tests validant compatibilité rétroactive
- [ ] Documentation migration dans `docs/`
- [ ] Mise à jour README avec noms français

---

# EPIC-V2-13 : EXTENSION EXERCICES (150+) 💪

**Priorité:** P2 (Contenu essentiel)  
**Effort:** 6h  
**Sprint:** 1  
**Dépendances:** MVP V1  
**ROI:** ⭐⭐⭐ (Complétude base de données)

## Objectif

Étendre la base d'exercices de ~50 à 150-200 exercices couvrant tous les groupes musculaires et modalités d'entraînement pour offrir une bibliothèque complète.

## User Stories

### US-V2-13.1: Recherche et Catégorisation Exercices
**Effort:** 2h

**Critères d'acceptation:**
- [ ] Recherche exhaustive exercices par catégorie:
  
**Pectoraux (15-20 exercices):**
- Développé couché (barre, haltères, incliné, décliné)
- Écarté (haltères, poulie, pec deck)
- Pompes (variantes: diamant, archer, pliométrique)
- Dips pectoraux
- Pull-over
- Chest press machine
- Cable cross

**Dos (20-25 exercices):**
- Tractions (pronation, supination, neutre, lestées)
- Rowing (barre, haltère, T-bar, machine, poulie)
- Tirage vertical (devant, nuque, prise large/serrée)
- Tirage horizontal
- Pull-over dos
- Deadlift (soulevé de terre, roumain, sumo)
- Shrugs (trapèzes)
- Face pull

**Jambes (25-30 exercices):**
- Squat (libre, guidé, sumo, bulgare, pistol)
- Presse à cuisses (standard, 45°, hack squat)
- Fentes (avant, arrière, latérales, marchées)
- Leg curl (couché, assis, debout)
- Leg extension
- Soulevé de terre jambes tendues
- Hip thrust
- Mollets (standing, seated, leg press)
- Adducteurs/Abducteurs machine

**Épaules (15-20 exercices):**
- Développé militaire (barre, haltères, nuque)
- Élévations latérales (haltères, poulie, machine)
- Élévations frontales
- Oiseau (rear delt fly)
- Rowing menton (upright row)
- Arnold press
- Face pull épaules

**Bras (20-25 exercices):**

*Biceps:*
- Curl barre (EZ, droite)
- Curl haltères (alterné, simultané, marteau)
- Curl pupitre (preacher curl)
- Curl concentré
- Curl poulie (haute, basse)
- Tractions supination

*Triceps:*
- Dips triceps
- Extension nuque (barre, haltère, poulie)
- Barre au front (skullcrusher)
- Extension poulie (corde, barre)
- Kickback haltère
- Diamond push-ups

**Abdominaux & Core (15-20 exercices):**
- Crunch (sol, décliné, poulie)
- Relevé de jambes (suspendu, banc, sol)
- Planche (frontale, latérale, dynamique)
- Russian twist
- Mountain climbers
- Ab wheel
- Cable crunch
- Bicycle crunch

**Cardio (10-15 exercices):**
- Course (tapis, extérieur, intervalles)
- Vélo (stationnaire, elliptique)
- Rameur
- Corde à sauter
- Burpees
- Jumping jacks
- Battle rope

**Full Body / Fonctionnel (10-15 exercices):**
- Clean & jerk
- Snatch
- Thruster
- Box jump
- Kettlebell swing
- Turkish get-up
- Man makers

- [ ] Total: **150-180 exercices minimum**
- [ ] Fichier CSV: `assets/seed_data/exercices_complets.csv`

---

### US-V2-13.2: Génération JSON Seed Data
**Effort:** 3h

**Critères d'acceptation:**
- [ ] Fichier JSON structuré: `assets/seed_data/exercices_v2.json`
- [ ] Structure par exercice:
  ```json
  {
    "id": "exercice_001",
    "nom": "Développé couché barre",
    "nomAnglais": "Barbell Bench Press",
    "groupesMusculaires": ["pectoraux", "triceps", "epaules"],
    "type": "poids_libres",
    "difficulte": "intermediaire",
    "equipement": "barre",
    "emoji": "💪",
    "description": "Exercice de base pour les pectoraux. Allongé sur un banc, descendre la barre jusqu'à la poitrine puis pousser.",
    "conseils": [
      "Garder les omoplates serrées",
      "Pieds au sol",
      "Barre au niveau des tétons"
    ],
    "variantes": [
      "Développé incliné",
      "Développé décliné",
      "Close grip bench press"
    ],
    "muscles_primaires": ["grand_pectoral"],
    "muscles_secondaires": ["triceps", "deltoide_anterieur"]
  }
  ```

- [ ] Champs obligatoires: id, nom, groupesMusculaires, type, emoji
- [ ] Champs optionnels: description, conseils, variantes
- [ ] Validation: Pas de doublons, noms uniques
- [ ] Emojis variés et pertinents par catégorie

**Mapping emojis:**
```
Pectoraux: 💪
Dos: 🦾
Jambes: 🦵
Épaules: 🏋️
Bras: 💪
Abdos: 🔥
Cardio: 🏃
Full Body: ⚡
```

---

### US-V2-13.3: Script Seed Amélioré
**Effort:** 1h

**Critères d'acceptation:**
- [ ] Améliorer `scripts/seed_exercises.dart`:
  - Lire nouveau fichier JSON v2
  - Détecter exercices déjà existants (skip)
  - Batch write optimisé (500 exercices max par batch)
  - Logs détaillés: "153 exercices ajoutés, 2 doublons skippés"
  - Dry-run mode pour test
- [ ] Script de vérification intégrité:
  - Tous exercices ont emoji
  - Pas de groupeMusculaire inconnu
  - Tous types valides (poids_libres, machine, corporel, cardio)

**Commande:**
```bash
# Seed production
dart run scripts/seed_exercises.dart

# Dry-run (test)
dart run scripts/seed_exercises.dart --dry-run

# Vérification intégrité
dart run scripts/validate_exercises.dart
```

---

## Livrables EPIC-V2-13

- [ ] Base 150-180 exercices catégorisés
- [ ] Fichier JSON structuré avec descriptions
- [ ] Script seed amélioré avec validation
- [ ] Script vérification intégrité
- [ ] Documentation exercices dans `docs/exercices.md`
- [ ] Tests validation données

---

# 📋 ORDRE D'IMPLÉMENTATION RECOMMANDÉ V2

## Phase 0 : Fondations & Contenu (Sprint 1) - **PRIORITAIRE**
1. **EPIC-V2-13:** Extension Exercices 150+ (6h) → BASE DE DONNÉES ESSENTIELLE
2. **EPIC-V2-12:** Refactoring Database FR (8h) → QUALITÉ CODE

## Phase 1 : Valeur Utilisateur Core (Sprint 1-3)
3. **EPIC-V2-1:** Statistiques & Graphiques (18h) → Feature #1 demandée
4. **EPIC-V2-2:** Achievements & Gamification (12h) → Rétention
5. **EPIC-V2-3:** Timer Repos (8h) → Utilité quotidienne
6. **EPIC-V2-11:** Podomètre Quotidien (14h) → Engagement quotidien & santé

## Phase 2 : Efficacité & Premium (Sprint 4-5)
7. **EPIC-V2-4:** Templates Séances (10h) → Gain temps 50%
8. **EPIC-V2-5:** Images IA (12h) → Design premium

## Phase 3 : Social & Community (Sprint 5-6)
9. **EPIC-V2-6:** Social & Partage (15h) → Viralité
10. **EPIC-V2-7:** Export & Backup (6h) → Confiance

## Phase 4 : Niche & Avancé (Sprint 7)
11. **EPIC-V2-8:** Calcul 1RM & Outils Pro (10h) → Powerlifters
12. **EPIC-V2-9:** Exercices Personnalisés (8h) → Flexibilité

## Continu : Polish
13. **EPIC-V2-10:** Optimisations & Polish → Toujours

---

## 🎯 MVP V2 RECOMMANDÉ (48-58h)

Pour maximiser la valeur avec budget limité, commencer par :

1. **EPIC-V2-13:** Exercices 150+ (6h) ⭐⭐⭐
2. **EPIC-V2-12:** Database FR (8h) ⭐⭐⭐
3. **EPIC-V2-1:** Statistiques (18h) ⭐⭐⭐⭐⭐
4. **EPIC-V2-11:** Podomètre (14h) ⭐⭐⭐⭐
5. **EPIC-V2-2:** Achievements (12h) ⭐⭐⭐⭐

**Total MVP V2:** 58h  
**Valeur délivrée:** 80% features les plus importantes

---

## 🎯 CRITÈRES DE SUCCÈS V2

### Métriques Engagement
- [ ] **Rétention D7:** > 40% (vs 25% MVP)
- [ ] **Rétention D30:** > 20% (vs 10% MVP)
- [ ] **Sessions/utilisateur/semaine:** > 4 (vs 2.5 MVP)
- [ ] **Durée session moyenne:** 15-20 min (vs 10 min MVP)

### Métriques Fonctionnelles
- [ ] **Utilisation templates:** 60% séances démarrées depuis template
- [ ] **Partages sociaux:** 10% utilisateurs partagent >= 1 séance/mois
- [ ] **Achievements unlockés:** Moyenne 15 par utilisateur après 3 mois
- [ ] **Pages vues Statistiques:** 2-3x par semaine minimum

### Métriques Qualité
- [ ] **Crash-free rate:** > 99.5%
- [ ] **Performance:** < 2s chargement écrans lourds (graphiques)
- [ ] **Satisfaction:** 4.5+ stars sur stores

---

## 💰 MONÉTISATION V2 (Optionnel)

Si décision de monétiser l'app, modèles possibles :

### Freemium (Recommandé)
- **Free:**
  - Toutes features MVP V1
  - Statistiques basiques
  - 3 templates max
  - Export CSV
- **Premium ($4.99/mois ou $29.99/an):**
  - Statistiques avancées + graphiques illimités
  - Templates illimités
  - Export PDF rapports
  - Images IA exercices
  - Outils Pro (1RM, recommandations)
  - Priorité support
  - Badge Premium dans profil

### One-Time Purchase
- **Lifetime Premium:** $49.99 (acheter une fois, garder pour toujours)

### Ads (Non recommandé pour fitness)
- Ads disruptives nuisent à l'expérience entraînement

---

## 📞 CONTACTS & SUPPORT

**Besoin d'aide pour implémenter la V2 ? Je suis là pour :**
- Briefer les agents Flutter/Firebase sur chaque EPIC
- Valider cohérence métier et design
- Prioriser features selon feedback utilisateurs
- Ajuster roadmap selon timeline réelle

---

**Généré par:** Apollon Project Assistant 📋  
**Date:** 15 février 2026  
**Version:** V2 - ROADMAP  
**Statut:** 🔄 PLANIFIÉ

---

## 🎯 PROCHAINE ÉTAPE

**Commencer par EPIC-V2-1 (Statistiques) ?**

C'est la feature la plus demandée et celle avec le meilleur ROI. Je peux vous créer un brief détaillé pour l'agent Flutter Developer Expert si vous êtes prêt à démarrer ! 🚀
