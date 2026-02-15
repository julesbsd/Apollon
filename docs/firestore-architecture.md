# ARCHITECTURE FIRESTORE - APOLLON

Documentation complète de l'architecture base de données Firestore pour le projet Apollon.

---

## VUE D'ENSEMBLE

Architecture **dénormalisée partielle** optimisée pour :
- Performance de lecture (1 requête = 1 séance complète)
- Mode offline (données complètes localement)
- Coût réduit (quota Firebase gratuit préservé)
- Respect du glossaire métier (6 concepts)

---

## STRUCTURE DES COLLECTIONS

### 1. Collection `users`

Collection top-level contenant les profils utilisateurs authentifiés via Google Sign-In.

```
/users/{userId}
```

**Document Structure:**

```typescript
{
  email: string,                    // Email Google Account
  displayName: string,              // Nom affiché
  photoURL?: string,                // Avatar Google (optionnel)
  createdAt: timestamp,             // Date création compte
  lastLoginAt: timestamp,           // Dernière connexion
  preferences?: {                   // V2 - Préférences utilisateur
    theme: 'dark' | 'light',
    units: 'kg' | 'lbs',
    language: 'fr' | 'en'
  }
}
```

**Règles de gestion appliquées:**
- RG-001: Création automatique au premier login Google

**Indexes requis:** Aucun (lecture par `userId` uniquement)

---

### 2. Subcollection `workouts` (Séances)

Collection imbriquée dans chaque utilisateur contenant l'historique des séances.

```
/users/{userId}/workouts/{workoutId}
```

**Document Structure:**

```typescript
{
  date: timestamp,                  // Date/heure de la séance
  status: 'draft' | 'completed',    // Statut séance (RG-004, RG-006)
  duration?: number,                // Durée en minutes (V2 avec chrono)
  createdAt: timestamp,             // Date création (auto)
  updatedAt: timestamp,             // Dernière modification (auto)
  
  // DÉNORMALISATION: Exercices + séries embarqués
  exercises: [
    {
      exerciseId: string,           // Référence /exercises/{id}
      exerciseName: string,         // NOM DÉNORMALISÉ (performance)
      muscleGroups: string[],       // Groupes musculaires (dénormalisé)
      type: string,                 // Type exercice (dénormalisé)
      emoji: string,                // Emoji pour UI (dénormalisé)
      
      sets: [
        {
          reps: number,             // Répétitions (> 0, RG-003)
          weight: number,           // Poids en kg (≥ 0, RG-003)
          order: number             // Ordre série (1, 2, 3...)
        }
      ]
    }
  ]
}
```

**Règles de gestion appliquées:**
- RG-003: Validation `reps > 0` et `weight >= 0`
- RG-004: Status `draft` pour séance en cours (persistance)
- RG-006: Status `completed` après clic "Terminer séance"

**Edge cases couverts:**
- EC-002: Brouillons (`status: 'draft'`) conservés 24h
- EC-004: Suppression séance complète avec confirmation

**Indexes requis:**

```javascript
// Index composite 1: Requête séances complétées triées par date
Collection: workouts
Fields: 
  - status (Ascending)
  - date (Descending)
Query: workouts.where('status', '==', 'completed').orderBy('date', 'desc')
```

```javascript
// Index composite 2: Brouillons récents
Collection: workouts  
Fields:
  - status (Ascending)
  - createdAt (Descending)
Query: workouts.where('status', '==', 'draft').orderBy('createdAt', 'desc')
```

---

### 3. Collection `exercises` (Exercices de référence)

Collection top-level contenant la base de données des exercices pré-enregistrés (seed data).

```
/exercises/{exerciseId}
```

**Document Structure:**

```typescript
{
  name: string,                     // Nom unique (RG-002)
  nameSearch: string,               // Nom en minuscules (recherche)
  muscleGroups: string[],           // ['pectoraux', 'triceps']
  type: 'free_weights' | 'machine' | 'bodyweight' | 'cardio',
  emoji: string,                    // Emoji catégorie (V1)
  description?: string,             // Description exercice (optionnel)
  imageUrl?: string,                // Image IA (V2)
  instructions?: string,            // Guide exécution (V2)
  videoUrl?: string,                // Vidéo démo (V2)
  createdAt: timestamp,
  popularity?: number               // Compteur usage (V2 analytics)
}
```

**Valeurs enum `muscleGroups`:**

```typescript
type MuscleGroup = 
  | 'pectoraux'
  | 'dorsaux'
  | 'epaules'
  | 'biceps'
  | 'triceps'
  | 'avant_bras'
  | 'abdominaux'
  | 'obliques'
  | 'lombaires'
  | 'quadriceps'
  | 'ischio_jambiers'
  | 'fessiers'
  | 'mollets'
  | 'cardio';
```

**Valeurs enum `type`:**

```typescript
type ExerciseType = 
  | 'free_weights'    // Poids libres (barres, haltères)
  | 'machine'         // Machines guidées
  | 'bodyweight'      // Poids de corps
  | 'cardio';         // Cardio
```

**Règles de gestion appliquées:**
- RG-002: Unicité du champ `name` (enforced par Security Rules + UI)

**Indexes requis:**

```javascript
// Index composite 3: Filtrage par groupe musculaire
Collection: exercises
Fields:
  - muscleGroups (Array-contains)
  - name (Ascending)
Query: exercises.where('muscleGroups', 'array-contains', 'pectoraux').orderBy('name')
```

```javascript
// Index composite 4: Filtrage par type
Collection: exercises
Fields:
  - type (Ascending)
  - name (Ascending)
Query: exercises.where('type', '==', 'free_weights').orderBy('name')
```

```javascript
// Index composite 5: Recherche textuelle
Collection: exercises
Fields:
  - nameSearch (Ascending)
Query: exercises.where('nameSearch', '>=', searchTerm).orderBy('nameSearch')
```

---

## RATIONALE: DÉNORMALISATION

### Choix architectural : Exercices dénormalisés dans workouts

**Option 1 (Normalisée - REJETÉE):**

```typescript
// Structure normalisée (non retenue)
workout.exercises = [
  {
    exerciseId: 'abc123',  // Référence uniquement
    sets: [...]
  }
]

// Nécessite JOIN manuel:
// 1 lecture workout + N lectures exercises (1 par exercice)
// Exemple: 5 exercices = 6 lectures Firestore
```

**Option 2 (Dénormalisée - CHOISIE):**

```typescript
// Structure dénormalisée (retenue)
workout.exercises = [
  {
    exerciseId: 'abc123',
    exerciseName: 'Développé couché',  // DUPLIQUÉ
    muscleGroups: ['pectoraux'],       // DUPLIQUÉ
    type: 'free_weights',              // DUPLIQUÉ
    emoji: '💪',                       // DUPLIQUÉ
    sets: [...]
  }
]

// Bénéfice: 1 seule lecture pour séance complète
```

### Analyse coûts/bénéfices

| Critère | Normalisé | Dénormalisé |
|---------|-----------|-------------|
| **Lectures par séance** | 1 + N (5-8 en moyenne) | 1 |
| **Coût quota gratuit** | Élevé (6-9 reads) | Faible (1 read) |
| **Performance offline** | Lente (attente N reads) | Instantanée |
| **Cohérence données** | Parfaite (source unique) | Risque duplication |
| **Maintenance** | Simple | Complexe si update exercice |

### Décision finale : DÉNORMALISER

**Justifications:**

1. **Performance critique** (CS-002): Affichage historique < 1s
2. **Expérience offline** (EC-003): Séance complète disponible immédiatement
3. **Économie coûts**: Préservation quota gratuit Firebase (50K reads/jour)
4. **Stabilité référentiel**: Exercices seed changent rarement (pas de maintenance fréquente)

**Trade-off accepté:**
- Si un exercice change de nom dans `/exercises`, les anciennes séances conservent l'ancien nom
- **Acceptable** car l'historique reflète ce qui était fait à l'époque
- Solution V2 si problème: Migration batch avec Cloud Functions

---

## HIÉRARCHIE DES DONNÉES

Représentation visuelle de l'architecture:

```
FIRESTORE ROOT
│
├─ users (collection)
│   └─ {userId} (document)
│       ├─ email: string
│       ├─ displayName: string
│       ├─ createdAt: timestamp
│       │
│       └─ workouts (subcollection)
│           └─ {workoutId} (document)
│               ├─ date: timestamp
│               ├─ status: 'draft' | 'completed'
│               └─ exercises: array
│                   └─ [
│                       {
│                         exerciseId: string,
│                         exerciseName: string,
│                         sets: [
│                           { reps: number, weight: number }
│                         ]
│                       }
│                     ]
│
└─ exercises (collection)
    └─ {exerciseId} (document)
        ├─ name: string (unique)
        ├─ muscleGroups: array
        ├─ type: string
        └─ emoji: string
```

**Alignement glossaire métier:**

```
UTILISATEUR ─────► users/{userId}
    │
    └─ SÉANCE ───► workouts/{workoutId}
           │
           └─ EXERCICE ──► exercises array (dénormalisé)
                  │
                  └─ SÉRIE ──► sets array
```

---

## STRATÉGIE OFFLINE

### Configuration Firestore Persistence

```dart
// main.dart - Configuration globale
await Firebase.initializeApp();

// Activer persistence offline (Android/iOS uniquement)
FirebaseFirestore.instance.settings = Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,  // Cache illimité
);
```

### Comportement offline par collection

| Collection | Lecture offline | Écriture offline | Sync auto |
|------------|----------------|------------------|-----------|
| `users` | ✅ Cache | ❌ Non | ✅ Oui |
| `workouts` | ✅ Cache | ✅ Oui (queue) | ✅ Oui |
| `exercises` | ✅ Cache | ❌ Non | ✅ Oui |

### Gestion EC-003: Perte connexion

**Scénario utilisateur:**
1. Utilisateur démarre séance (online)
2. Perte connexion réseau
3. Continue saisie exercices/séries
4. Retour connexion

**Comportement Firestore:**
```dart
// Écriture automatiquement mise en queue
await workoutRef.update({
  'status': 'draft',
  'exercises': updatedExercises,
  'updatedAt': FieldValue.serverTimestamp(),
});
// ✅ Réussit offline, sync dès retour connexion
```

**Indicateur UI (optionnel):**
```dart
// Écouter statut connexion
FirebaseFirestore.instance
  .snapshotsInSync()
  .listen((_) {
    // Appelé quand sync complète
    setState(() => _isSynced = true);
  });
```

---

## REQUÊTES OPTIMISÉES

### Récupérer dernière séance pour un exercice (P2 - Étape 3)

**Besoin métier:** Afficher historique exercice lors de saisie (RG-005)

```dart
Future<Workout?> getLastWorkoutForExercise(String userId, String exerciseId) async {
  final snapshot = await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('workouts')
    .where('status', isEqualTo: 'completed')
    .where('exercises', arrayContains: {'exerciseId': exerciseId}) // ❌ NE MARCHE PAS!
    .orderBy('date', descending: true)
    .limit(1)
    .get();
  
  return snapshot.docs.isNotEmpty 
    ? Workout.fromFirestore(snapshot.docs.first)
    : null;
}
```

**⚠️ LIMITATION FIRESTORE:** `arrayContains` ne supporte pas les objets complexes!

**Solution V1 (côté client):**

```dart
Future<Workout?> getLastWorkoutForExercise(String userId, String exerciseId) async {
  // Récupérer les dernières séances (ex: 20 dernières)
  final snapshot = await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('workouts')
    .where('status', isEqualTo: 'completed')
    .orderBy('date', descending: true)
    .limit(20)  // Limite raisonnable
    .get();
  
  // Filtrer côté client
  for (final doc in snapshot.docs) {
    final workout = Workout.fromFirestore(doc);
    if (workout.exercises.any((e) => e.exerciseId == exerciseId)) {
      return workout;
    }
  }
  
  return null; // EC-001: Pas de séance pour cet exercice
}
```

**Impact performance:**
- Lectures: Max 20 documents (acceptable pour quota gratuit)
- Cache: Séances récentes déjà en cache offline
- UX: Temps < 1s même avec filtrage client (CS-002)

**Solution V2 (optimale avec dénormalisation supplémentaire):**

Ajouter un champ `exerciseIds: string[]` à la racine du workout:

```typescript
workout = {
  date: timestamp,
  exerciseIds: ['abc123', 'def456'],  // NOUVEAU CHAMP
  exercises: [...]
}
```

Requête optimisée:

```dart
final snapshot = await FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .collection('workouts')
  .where('status', isEqualTo: 'completed')
  .where('exerciseIds', arrayContains: exerciseId)  // ✅ Fonctionne!
  .orderBy('date', descending: true)
  .limit(1)
  .get();
```

**Décision V1:** Filtrage client (plus simple, performance acceptable)

---

### Liste séances complétées triées par date (P3)

```dart
Stream<List<Workout>> getCompletedWorkouts(String userId) {
  return FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('workouts')
    .where('status', isEqualTo: 'completed')
    .orderBy('date', descending: true)
    .limit(50)  // Pagination V2
    .snapshots()
    .map((snapshot) => 
      snapshot.docs.map((doc) => Workout.fromFirestore(doc)).toList()
    );
}
```

**Index requis:** Composite `status (ASC) + date (DESC)`

---

### Recherche exercices par nom (P2 - Étape 2)

```dart
Future<List<Exercise>> searchExercisesByName(String query) async {
  final lowerQuery = query.toLowerCase();
  
  final snapshot = await FirebaseFirestore.instance
    .collection('exercises')
    .where('nameSearch', isGreaterThanOrEqualTo: lowerQuery)
    .where('nameSearch', isLessThan: lowerQuery + 'z')
    .orderBy('nameSearch')
    .limit(20)
    .get();
  
  return snapshot.docs.map((doc) => Exercise.fromFirestore(doc)).toList();
}
```

**Note:** Recherche full-text limitée. Solution V2: Algolia ou FlutterFire UI.

---

### Filtrage exercices par groupe musculaire (P2 - Étape 2)

```dart
Future<List<Exercise>> getExercisesByMuscleGroup(String muscleGroup) async {
  final snapshot = await FirebaseFirestore.instance
    .collection('exercises')
    .where('muscleGroups', arrayContains: muscleGroup)
    .orderBy('name')
    .get();
  
  return snapshot.docs.map((doc) => Exercise.fromFirestore(doc)).toList();
}
```

**Index requis:** Composite `muscleGroups (array-contains) + name (ASC)`

---

## MODÈLES DART RECOMMANDÉS

### Workout Model

```dart
class Workout {
  final String id;
  final DateTime date;
  final WorkoutStatus status;
  final List<WorkoutExercise> exercises;
  final int? duration;  // V2
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Constructor, factory, toMap, etc.
  
  factory Workout.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Workout(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      status: WorkoutStatus.fromString(data['status']),
      exercises: (data['exercises'] as List)
        .map((e) => WorkoutExercise.fromMap(e))
        .toList(),
      duration: data['duration'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
  
  Map<String, dynamic> toFirestore() => {
    'date': Timestamp.fromDate(date),
    'status': status.value,
    'exercises': exercises.map((e) => e.toMap()).toList(),
    if (duration != null) 'duration': duration,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

enum WorkoutStatus {
  draft('draft'),
  completed('completed');
  
  final String value;
  const WorkoutStatus(this.value);
  
  static WorkoutStatus fromString(String value) {
    return WorkoutStatus.values.firstWhere((e) => e.value == value);
  }
}
```

### Exercise Model

```dart
class Exercise {
  final String id;
  final String name;
  final List<MuscleGroup> muscleGroups;
  final ExerciseType type;
  final String emoji;
  final String? description;
  final DateTime createdAt;
  
  factory Exercise.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Exercise(
      id: doc.id,
      name: data['name'],
      muscleGroups: (data['muscleGroups'] as List)
        .map((g) => MuscleGroup.fromString(g))
        .toList(),
      type: ExerciseType.fromString(data['type']),
      emoji: data['emoji'],
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
```

---

## MONITORING ET COÛTS

### Quota Firebase gratuit (Spark Plan)

| Ressource | Limite gratuite | Usage estimé Apollon |
|-----------|----------------|---------------------|
| Lectures documents | 50,000/jour | 5,000-10,000/jour (100 utilisateurs actifs) |
| Écritures | 20,000/jour | 2,000-5,000/jour |
| Stockage | 1 GB | < 100 MB (V1) |
| Transfert réseau | 10 GB/mois | < 1 GB/mois |

**Estimation réaliste V1:**
- 100 utilisateurs actifs/jour
- 2 séances/utilisateur/semaine
- Moyenne 5 exercices/séance
- Consultation historique: 10 lectures/session

**Calcul lectures journalières:**
```
- Login (profil user): 1 read
- Liste exercices (cache 1x/jour): 1 read
- Nouvelle séance (load dernière séance): 1 read
- Consultation historique: 10 reads
Total: ~13 reads/utilisateur/jour
→ 1,300 reads/jour pour 100 users (2.6% du quota)
```

**✅ Largement dans le quota gratuit**

### Alertes recommandées (Firebase Console)

1. **Budget Alert**: Notification si approche limite gratuite
2. **Read/Write spikes**: Détection pics anormaux (bug app)
3. **Error rate**: Monitoring Security Rules rejections

---

## MIGRATIONS ET MAINTENANCE

### Stratégie seed data exercices

**V1 - Import initial:**

```dart
// scripts/seed_exercises.dart
Future<void> seedExercises() async {
  final batch = FirebaseFirestore.instance.batch();
  
  for (final exercise in seedDataExercises) {
    final docRef = FirebaseFirestore.instance
      .collection('exercises')
      .doc();
    
    batch.set(docRef, {
      'name': exercise.name,
      'nameSearch': exercise.name.toLowerCase(),
      'muscleGroups': exercise.muscleGroups,
      'type': exercise.type,
      'emoji': exercise.emoji,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  
  await batch.commit();
}
```

**V2 - Ajout exercices utilisateur:**

Si fonctionnalité ajout exercices personnalisés activée:

```typescript
// Nouveau champ pour distinguer seed vs custom
exercise = {
  name: string,
  isCustom: boolean,         // false = seed, true = user custom
  createdBy?: string,        // userId si custom
  visibility: 'public' | 'private',  // public = seed, private = user only
  ...
}
```

### Maintenance dénormalisation

**Scénario:** Correction nom exercice dans `/exercises`

**Impact:** Anciennes séances conservent l'ancien nom (comportement normal)

**Si synchronisation requise:**

```dart
// Cloud Function (déclenchée manuellement ou sur update exercise)
Future<void> propagateExerciseNameChange(
  String exerciseId,
  String oldName,
  String newName,
) async {
  // Batch update de toutes les séances contenant l'exercice
  // ⚠️ Coûteux en lectures/écritures
  // → Utiliser uniquement si critique
}
```

**Décision V1:** Ne pas propager (historique = photo du passé)

---

## VALIDATION ET TESTS

### Tests Security Rules (Firebase Emulator)

```javascript
// tests/firestore.rules.test.js
describe('Workout Security Rules', () => {
  it('should deny read to other user workouts', async () => {
    await firebase.assertFails(
      db.collection('users/userA/workouts').get()
    );
  });
  
  it('should allow owner to read own workouts', async () => {
    await firebase.assertSucceeds(
      authDb('userA').collection('users/userA/workouts').get()
    );
  });
  
  it('should reject invalid workout (reps <= 0)', async () => {
    await firebase.assertFails(
      authDb('userA')
        .collection('users/userA/workouts')
        .add({
          date: new Date(),
          status: 'draft',
          exercises: [{
            exerciseId: 'ex1',
            sets: [{ reps: 0, weight: 50 }]  // ❌ Invalid
          }]
        })
    );
  });
});
```

### Tests modèles Dart

```dart
test('Workout.fromFirestore should parse correctly', () {
  final doc = MockDocumentSnapshot(data: {
    'date': Timestamp.now(),
    'status': 'completed',
    'exercises': [
      {
        'exerciseId': 'ex1',
        'exerciseName': 'Squat',
        'sets': [
          {'reps': 10, 'weight': 100.0, 'order': 1}
        ]
      }
    ],
    'createdAt': Timestamp.now(),
    'updatedAt': Timestamp.now(),
  });
  
  final workout = Workout.fromFirestore(doc);
  
  expect(workout.status, WorkoutStatus.completed);
  expect(workout.exercises.length, 1);
  expect(workout.exercises[0].sets[0].reps, 10);
});
```

---

## CHECKLIST IMPLÉMENTATION

### Phase 1: Setup Firebase

- [ ] Créer projet Firebase Console
- [ ] Activer Authentication (Google Sign-In)
- [ ] Activer Firestore Database (mode production)
- [ ] Configurer SHA fingerprints Android
- [ ] Télécharger `google-services.json` et `GoogleService-Info.plist`
- [ ] Ajouter dépendances Flutter (`firebase_core`, `firebase_auth`, `cloud_firestore`)

### Phase 2: Architecture Firestore

- [ ] Créer collections `users` et `exercises`
- [ ] Importer seed data exercices (~50 exercices)
- [ ] Créer indexes composites (4 indexes requis)
- [ ] Valider structure documents (tests manuels)

### Phase 3: Security Rules

- [ ] Déployer `firestore.rules`
- [ ] Tester avec Firebase Emulator
- [ ] Valider isolation utilisateurs
- [ ] Valider validation données (RG-003)

### Phase 4: Modèles Dart

- [ ] Créer `models/workout.dart`
- [ ] Créer `models/exercise.dart`
- [ ] Créer converters Firestore ↔ Dart
- [ ] Tests unitaires modèles

### Phase 5: Offline & Sync

- [ ] Activer Firestore persistence
- [ ] Tester mode offline (avion)
- [ ] Tester synchronisation retour connexion
- [ ] Implémenter indicateur UI (optionnel)

---

## RESSOURCES ET RÉFÉRENCES

- [Firestore Data Modeling Best Practices](https://firebase.google.com/docs/firestore/manage-data/structure-data)
- [Security Rules Reference](https://firebase.google.com/docs/firestore/security/get-started)
- [Offline Data Persistence](https://firebase.google.com/docs/firestore/manage-data/enable-offline)
- [Firestore Pricing Calculator](https://firebase.google.com/pricing)

---

**Document généré par:** Firebase Backend Specialist Agent  
**Version:** 1.0.0  
**Date:** 15 février 2026  
**Projet:** Apollon - Application Flutter de suivi musculation
