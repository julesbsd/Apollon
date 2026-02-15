# FIRESTORE SECURITY RULES - APOLLON

Documentation détaillée des règles de sécurité Firestore pour le projet Apollon.

---

## VUE D'ENSEMBLE

Les Security Rules Firestore assurent :
- **RG-001** : Authentification Google obligatoire pour tout accès
- **RG-002** : Unicité des noms d'exercices (enforced par logique métier)
- **RG-003** : Validation côté serveur des données de série (reps > 0, weight >= 0)
- **Isolation utilisateur** : Aucun accès aux données des autres utilisateurs
- **Protection référentiel** : Collection `exercises` en lecture seule (seed data)

---

## STRUCTURE DES RÈGLES

Le fichier `firestore.rules` est organisé en 4 sections :

1. **Helper Functions** : Fonctions réutilisables de validation
2. **Collection `users`** : Profils utilisateurs et leurs séances (`workouts` subcollection)
3. **Collection `exercises`** : Référentiel exercices (lecture seule)
4. **Règle par défaut** : Deny all pour toute autre ressource

---

## HELPER FUNCTIONS

### `isAuthenticated()`

```javascript
function isAuthenticated() {
  return request.auth != null;
}
```

**Rôle :** Vérifie que l'utilisateur est connecté via Firebase Auth.

**Utilisé pour :** RG-001 (authentification obligatoire)

---

### `isOwner(userId)`

```javascript
function isOwner(userId) {
  return isAuthenticated() && request.auth.uid == userId;
}
```

**Rôle :** Vérifie que l'utilisateur authentifié est le propriétaire de la ressource.

**Utilisé pour :** Isolation des données utilisateur (RG-001)

---

### `validateWorkout(workout)`

```javascript
function validateWorkout(workout) {
  return workout.keys().hasAll(['date', 'status', 'exercises', 'createdAt', 'updatedAt'])
      && workout.status in ['draft', 'completed']
      && workout.date is timestamp
      && workout.exercises is list
      && workout.exercises.size() >= 0;
}
```

**Rôle :** Valide la structure d'un document `workout`.

**Validations :**
- Champs obligatoires : `date`, `status`, `exercises`, `createdAt`, `updatedAt`
- `status` doit être `'draft'` ou `'completed'` (RG-004, RG-006)
- `date` doit être un timestamp
- `exercises` doit être une liste (peut être vide pour draft)

---

### `validateWorkoutExercise(exercise)`

```javascript
function validateWorkoutExercise(exercise) {
  return exercise.keys().hasAll(['exerciseId', 'exerciseName', 'sets'])
      && exercise.exerciseId is string
      && exercise.exerciseName is string
      && exercise.sets is list
      && exercise.sets.size() > 0;
}
```

**Rôle :** Valide la structure d'un exercice dans un workout.

**Validations :**
- Champs obligatoires : `exerciseId`, `exerciseName`, `sets`
- Au moins 1 série par exercice

---

### `validateSet(set)`

```javascript
function validateSet(set) {
  return set.keys().hasAll(['reps', 'weight'])
      && set.reps is int 
      && set.reps > 0                    // RG-003
      && set.weight is number 
      && set.weight >= 0;                // RG-003
}
```

**Rôle :** Valide la structure d'une série (RG-003).

**Validations :**
- Champs obligatoires : `reps`, `weight`
- **RG-003** : `reps` doit être un entier strictement positif (> 0)
- **RG-003** : `weight` doit être un nombre positif ou nul (≥ 0, où 0 = poids corporel)

**Exemples valides :**
```javascript
{ reps: 12, weight: 80.0 }    // ✅ OK
{ reps: 10, weight: 0 }       // ✅ OK (poids corporel)
{ reps: 1, weight: 100.5 }    // ✅ OK
```

**Exemples invalides :**
```javascript
{ reps: 0, weight: 80 }       // ❌ REJETÉ (reps <= 0)
{ reps: -5, weight: 50 }      // ❌ REJETÉ (reps < 0)
{ reps: 10, weight: -10 }     // ❌ REJETÉ (weight < 0)
{ reps: 10 }                  // ❌ REJETÉ (weight manquant)
```

---

### `validateAllExercisesAndSets(exercises)`

```javascript
function validateAllExercisesAndSets(exercises) {
  return exercises.size() == 0  // Draft vide OK
      || exercises.hasAll(function(ex) {
           return validateWorkoutExercise(ex)
               && ex.sets.hasAll(function(set) {
                    return validateSet(set);
                  });
         });
}
```

**Rôle :** Valide récursivement tous les exercices et séries d'un workout.

**Comportement :**
- Si `exercises` est vide → valide (draft sans exercices, RG-004)
- Sinon, TOUS les exercices doivent être valides
- Pour chaque exercice, TOUTES les séries doivent être valides (RG-003)

---

### `validateExercise(exercise)`

```javascript
function validateExercise(exercise) {
  return exercise.keys().hasAll(['name', 'muscleGroups', 'type', 'emoji'])
      && exercise.name is string
      && exercise.name.size() > 0
      && exercise.muscleGroups is list
      && exercise.muscleGroups.size() > 0
      && exercise.type in ['free_weights', 'machine', 'bodyweight', 'cardio']
      && exercise.emoji is string;
}
```

**Rôle :** Valide la structure d'un document `exercise` (non utilisé en V1 car écriture désactivée).

---

## RÈGLES PAR COLLECTION

### Collection `users`

#### Lecture du profil utilisateur

```javascript
match /users/{userId} {
  allow read: if isOwner(userId);
}
```

**Autorisé si :**
- L'utilisateur est authentifié (RG-001)
- L'utilisateur demande ses propres données (`request.auth.uid == userId`)

**Bloqué si :**
- Utilisateur non authentifié
- Tentative d'accès aux données d'un autre utilisateur

**Exemples :**

```dart
// ✅ Autorisé
final myProfile = await FirebaseFirestore.instance
  .collection('users')
  .doc(currentUser.uid)  // Mes propres données
  .get();

// ❌ Rejeté (tentative d'accès aux données de 'otherUserId')
final otherProfile = await FirebaseFirestore.instance
  .collection('users')
  .doc('otherUserId')
  .get();  // Permission denied!
```

---

#### Création du profil utilisateur

```javascript
allow create: if isOwner(userId)
              && request.resource.data.keys().hasAll(['email', 'displayName', 'createdAt'])
              && request.resource.data.email is string
              && request.resource.data.displayName is string;
```

**Autorisé si :**
- Création de son propre profil (`isOwner(userId)`)
- Champs obligatoires présents : `email`, `displayName`, `createdAt`

**Utilisation :** Lors du premier login Google Sign-In.

---

#### Mise à jour du profil

```javascript
allow update: if isOwner(userId);
```

**Autorisé si :** L'utilisateur met à jour son propre profil.

**Cas d'usage :** Mise à jour `lastLoginAt`, modification `preferences` (V2).

---

### Subcollection `workouts`

#### Lecture des séances

```javascript
match /workouts/{workoutId} {
  allow read: if isOwner(userId);
}
```

**Autorisé si :**
- L'utilisateur lit ses propres séances (isolation complète RG-001)

**Exemples :**

```dart
// ✅ Autorisé
final myWorkouts = await FirebaseFirestore.instance
  .collection('users')
  .doc(currentUser.uid)
  .collection('workouts')
  .get();

// ❌ Rejeté
final otherWorkouts = await FirebaseFirestore.instance
  .collection('users')
  .doc('otherUserId')
  .collection('workouts')
  .get();  // Permission denied!
```

---

#### Création d'une séance

```javascript
allow create: if isOwner(userId)
              && validateWorkout(request.resource.data)
              && validateAllExercisesAndSets(request.resource.data.exercises);
```

**Autorisé si :**
- Création dans sa propre subcollection
- Structure `workout` valide (champs obligatoires, status correct)
- Tous les exercices et séries valides (RG-003)

**Règles appliquées :**
- **RG-003** : Validation `reps > 0`, `weight >= 0` pour chaque série
- **RG-004** : Status `'draft'` accepté (persistance séance en cours)

**Exemple valide :**

```dart
await FirebaseFirestore.instance
  .collection('users')
  .doc(currentUser.uid)
  .collection('workouts')
  .add({
    'date': Timestamp.now(),
    'status': 'draft',  // RG-004: Brouillon
    'exercises': [
      {
        'exerciseId': 'ex123',
        'exerciseName': 'Développé couché',
        'sets': [
          {'reps': 12, 'weight': 80.0, 'order': 1},  // ✅ Valide
          {'reps': 10, 'weight': 82.5, 'order': 2},  // ✅ Valide
        ]
      }
    ],
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
```

**Exemple invalide (rejeté par RG-003) :**

```dart
await FirebaseFirestore.instance
  .collection('users')
  .doc(currentUser.uid)
  .collection('workouts')
  .add({
    'date': Timestamp.now(),
    'status': 'draft',
    'exercises': [
      {
        'exerciseId': 'ex123',
        'exerciseName': 'Squat',
        'sets': [
          {'reps': 0, 'weight': 100},  // ❌ REJETÉ (reps <= 0)
        ]
      }
    ],
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
// Erreur: Permission denied (validation échouée)
```

---

#### Mise à jour d'une séance

```javascript
allow update: if isOwner(userId)
              && validateWorkout(request.resource.data)
              && validateAllExercisesAndSets(request.resource.data.exercises);
```

**Autorisé si :**
- Mise à jour de sa propre séance
- Structure valide (mêmes validations que création)

**Règles appliquées :**
- **RG-004** : Mise à jour draft (ajout exercices/séries en cours de séance)
- **RG-006** : Finalisation via changement `status: 'draft'` → `'completed'`
- **RG-003** : Validation continue des séries

**Cas d'usage :**

```dart
// Draft → Ajout d'un exercice supplémentaire
await workoutRef.update({
  'exercises': FieldValue.arrayUnion([newExercise]),
  'updatedAt': FieldValue.serverTimestamp(),
});

// Finalisation séance (RG-006)
await workoutRef.update({
  'status': 'completed',
  'updatedAt': FieldValue.serverTimestamp(),
});
```

---

#### Suppression d'une séance

```javascript
allow delete: if isOwner(userId);
```

**Autorisé si :** L'utilisateur supprime sa propre séance.

**Cas d'usage :** EC-004 (suppression avec confirmation UI).

---

### Collection `exercises`

#### Lecture des exercices

```javascript
match /exercises/{exerciseId} {
  allow read: if isAuthenticated();
}
```

**Autorisé si :**
- Utilisateur authentifié (RG-001)

**Raison :** Les exercices sont un référentiel commun accessible à tous les utilisateurs authentifiés.

**Exemples :**

```dart
// ✅ Autorisé (utilisateur authentifié)
final exercises = await FirebaseFirestore.instance
  .collection('exercises')
  .where('muscleGroups', arrayContains: 'pectoraux')
  .get();

// ❌ Rejeté (utilisateur non authentifié)
// → Erreur: Permission denied
```

---

#### Écriture des exercices

```javascript
allow write: if false;  // Désactivé V1
```

**Bloqué** : Aucun utilisateur ne peut créer/modifier/supprimer des exercices en V1.

**Raison :**
- V1 : Seed data uniquement (50 exercices prédéfinis)
- Import via script admin (pas d'UI utilisateur)

**V2 (si ajout exercices personnalisés activé) :**

```javascript
// Règle V2 (non déployée)
allow create: if isAuthenticated() 
              && validateExercise(request.resource.data)
              && request.resource.data.createdBy == request.auth.uid;
```

---

## RÈGLE PAR DÉFAUT

```javascript
match /{document=**} {
  allow read, write: if false;
}
```

**Bloque** toute collection/document non explicitement autorisé.

**Principe de sécurité :** Deny by default, allow explicitly.

---

## SCÉNARIOS DE VALIDATION

### Scénario 1 : Création séance valide

```dart
// ✅ RÉUSSIT
await FirebaseFirestore.instance
  .collection('users/${currentUser.uid}/workouts')
  .add({
    'date': Timestamp.now(),
    'status': 'draft',
    'exercises': [
      {
        'exerciseId': 'ex1',
        'exerciseName': 'Squat',
        'sets': [
          {'reps': 10, 'weight': 100.0, 'order': 1},
          {'reps': 8, 'weight': 110.0, 'order': 2},
        ]
      }
    ],
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
```

**Validation :**
- ✅ `isOwner(userId)` → OK (propre collection)
- ✅ `validateWorkout` → OK (structure complète)
- ✅ `validateAllExercisesAndSets` → OK (toutes séries valides)

---

### Scénario 2 : Série invalide (reps = 0)

```dart
// ❌ ÉCHOUE
await FirebaseFirestore.instance
  .collection('users/${currentUser.uid}/workouts')
  .add({
    'date': Timestamp.now(),
    'status': 'draft',
    'exercises': [
      {
        'exerciseId': 'ex1',
        'exerciseName': 'Pompes',
        'sets': [
          {'reps': 0, 'weight': 0}  // ❌ reps = 0 invalide (RG-003)
        ]
      }
    ],
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
// Erreur: PERMISSION_DENIED
```

**Validation :**
- ✅ `isOwner(userId)` → OK
- ✅ `validateWorkout` → OK
- ❌ `validateSet` → ÉCHOUE (`reps` doit être > 0)

---

### Scénario 3 : Tentative d'accès aux données d'autrui

```dart
// ❌ ÉCHOUE
await FirebaseFirestore.instance
  .collection('users/otherUserId/workouts')
  .get();
// Erreur: PERMISSION_DENIED
```

**Validation :**
- ❌ `isOwner('otherUserId')` → ÉCHOUE (`request.auth.uid != 'otherUserId'`)

---

### Scénario 4 : Draft vide (séance démarrée sans exercices)

```dart
// ✅ RÉUSSIT (RG-004)
await FirebaseFirestore.instance
  .collection('users/${currentUser.uid}/workouts')
  .add({
    'date': Timestamp.now(),
    'status': 'draft',
    'exercises': [],  // ✅ Vide accepté pour draft
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
```

**Validation :**
- ✅ `validateWorkout` → OK (`exercises.size() >= 0`)
- ✅ `validateAllExercisesAndSets` → OK (`exercises.size() == 0` est valide)

---

## TESTS AVEC FIREBASE EMULATOR

### Installation

```bash
npm install -g firebase-tools
firebase login
firebase init emulators
```

Sélectionner : **Firestore**, **Authentication**

### Lancer l'émulateur

```bash
firebase emulators:start
```

URL : http://localhost:4000 (Emulator UI)

### Tests manuels

1. **Créer utilisateur test** dans Authentication Emulator
2. **Tester règles** dans Firestore Rules Playground

**Exemple test Read :**

```
Collection: users/testUserId/workouts
Path: users/testUserId/workouts
Auth UID: testUserId
Result: ✅ Allowed
```

**Exemple test Read interdit :**

```
Collection: users/otherUserId/workouts
Path: users/otherUserId/workouts
Auth UID: testUserId
Result: ❌ Permission denied
```

---

## DÉPLOIEMENT

### Déployer les règles

```bash
firebase deploy --only firestore:rules
```

### Vérifier déploiement

1. Aller sur [Firebase Console](https://console.firebase.google.com)
2. Firestore Database → Rules
3. Vérifier version déployée

---

## MONITORING

### Firebase Console - Usage Tab

Surveiller :
- **Denied requests** : Pics anormaux = bug UI (requêtes non autorisées)
- **Security rule evaluations** : Coût evaluations complexes

### Alerts recommandés

```javascript
// Firebase Console → Monitoring → Alerts
Alert 1: "Denied Requests Spike" (> 100 rejections/minute)
  → Indique bug ou tentative accès non autorisé

Alert 2: "Rule Evaluation Latency" (> 500ms)
  → Règles trop complexes, optimisation requise
```

---

## CHECKLIST DÉPLOIEMENT

### Avant production

- [ ] Tester toutes les règles avec Firebase Emulator
- [ ] Valider isolation utilisateurs (test cross-user access)
- [ ] Valider RG-003 (reps > 0, weight >= 0)
- [ ] Vérifier status draft/completed fonctionne (RG-004, RG-006)
- [ ] Tester CRUD complet workouts
- [ ] Vérifier exercices en lecture seule

### Après déploiement

- [ ] Vérifier aucun denied request légitime
- [ ] Monitorer premiers utilisateurs réels
- [ ] Confirmer latence evaluation < 100ms

---

## MAINTENANCE ET ÉVOLUTION

### V2 : Ajout exercices personnalisés

Modifier règle `exercises` :

```javascript
match /exercises/{exerciseId} {
  allow read: if isAuthenticated();
  
  // Autoriser création exercices custom
  allow create: if isAuthenticated()
                && validateExercise(request.resource.data)
                && request.resource.data.createdBy == request.auth.uid
                && request.resource.data.isCustom == true;
  
  // Autoriser modification uniquement de ses exercices custom
  allow update: if isAuthenticated()
                && resource.data.createdBy == request.auth.uid
                && resource.data.isCustom == true;
  
  // Autoriser suppression uniquement de ses exercices custom
  allow delete: if isAuthenticated()
                && resource.data.createdBy == request.auth.uid
                && resource.data.isCustom == true;
}
```

### V2 : Soft delete (corbeille)

Ajouter champ `deletedAt` et modifier règle read :

```javascript
allow read: if isOwner(userId)
            && (!resource.data.keys().hasAny(['deletedAt']) 
                || request.query.showDeleted == true);  // Afficher corbeille
```

---

## RÉFÉRENCES

- [Firestore Security Rules Documentation](https://firebase.google.com/docs/firestore/security/rules-structure)
- [Security Rules Testing](https://firebase.google.com/docs/rules/unit-tests)
- [Common Security Patterns](https://firebase.google.com/docs/firestore/security/rules-conditions)

---

**Document généré par:** Firebase Backend Specialist Agent  
**Version:** 1.0.0  
**Date:** 15 février 2026  
**Projet:** Apollon - Application Flutter de suivi musculation
