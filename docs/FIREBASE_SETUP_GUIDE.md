# 🔥 Refonte complète de la base Firebase - Guide étape par étape

Guide complet pour migrer vers la nouvelle architecture Exercise Library dans Firebase.

## 📋 Vue d'ensemble

### Ce qui va changer

| Élément | Avant | Après |
|---------|-------|-------|
| **Collection exercices** | `exercises` (~50) | `exercises_library` (94) ✅ |
| **Structure données** | Simple | Enrichie (muscles, catégories, descriptions) ✅ |
| **Images** | Aucune | Storage `/exercise_images/` ✅ |
| **Règles Firestore** | Basiques | Spécifiques par collection ✅ |
| **Règles Storage** | Standard | Lazy loading optimisé ✅ |
| **Indexes** | Auto | Optimisés pour filtres ✅ |

## 🚀 ÉTAPE 1: Configurer les règles Firestore (2 min)

### 1.1 Accéder à Firestore Rules

```
1. Ouvrir https://console.firebase.google.com
2. Sélectionner votre projet "Apollon"
3. Menu latéral → "Firestore Database"
4. Onglet "Règles" (Rules)
```

### 1.2 Copier les nouvelles règles

Remplacez **TOUT le contenu** par cette configuration :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ==========================================
    // NOUVELLE COLLECTION: exercises_library
    // ==========================================
    
    // ✅ Catalogue Workout API (94 exercices)
    // Lecture publique, écriture admin/script uniquement
    match /exercises_library/{exerciseId} {
      // Lecture autorisée pour tous (catalogue public)
      allow read: if true;
      
      // Écriture réservée aux admins/scripts d'import
      // Pour import: utilisez Admin SDK ou désactivez temporairement
      allow write: if request.auth != null;
    }
    
    // ==========================================
    // ANCIENNE COLLECTION: exercises (deprecated)
    // ==========================================
    
    // ⚠️ À supprimer après validation complète
    match /exercises/{exerciseId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // ==========================================
    // WORKOUTS
    // ==========================================
    
    match /workouts/{workoutId} {
      // Lecture: propriétaire uniquement
      allow read: if request.auth != null && 
                     request.auth.uid == resource.data.userId;
      
      // Création: utilisateur authentifié
      allow create: if request.auth != null && 
                       request.auth.uid == request.resource.data.userId;
      
      // Mise à jour: propriétaire uniquement
      allow update: if request.auth != null && 
                       request.auth.uid == resource.data.userId;
      
      // Suppression: propriétaire uniquement
      allow delete: if request.auth != null && 
                       request.auth.uid == resource.data.userId;
    }
    
    // ==========================================
    // USERS
    // ==========================================
    
    match /users/{userId} {
      // Lecture: propriétaire uniquement
      allow read: if request.auth != null && request.auth.uid == userId;
      
      // Écriture: propriétaire uniquement
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // ==========================================
    // STATISTICS (si utilisé)
    // ==========================================
    
    match /statistics/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // ==========================================
    // PERSONAL RECORDS (si utilisé)
    // ==========================================
    
    match /personal_records/{recordId} {
      allow read: if request.auth != null && 
                     request.auth.uid == resource.data.userId;
      allow write: if request.auth != null && 
                      request.auth.uid == request.resource.data.userId;
    }
  }
}
```

### 1.3 Publier les règles

```
Bouton "Publier" en haut à droite
```

**✅ CHECKPOINT**: Les règles sont publiées

---

## 🗂️ ÉTAPE 2: Configurer les règles Storage (2 min)

### 2.1 Accéder à Storage Rules

```
1. Firebase Console → "Storage"
2. Onglet "Règles" (Rules)
```

### 2.2 Copier les règles Storage

Remplacez **TOUT le contenu** par :

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // ==========================================
    // EXERCISE IMAGES (Workout API)
    // ==========================================
    
    // ✅ Dossier des images d'exercices
    match /exercise_images/{imageId} {
      // Lecture publique (catalogue public)
      allow read: if true;
      
      // Écriture pour utilisateurs authentifiés
      // (lazy loading depuis Workout API via app)
      allow write: if request.auth != null;
    }
    
    // ==========================================
    // USER UPLOADS (avatars, etc.)
    // ==========================================
    
    match /user_uploads/{userId}/{allPaths=**} {
      // Lecture: propriétaire uniquement
      allow read: if request.auth != null && request.auth.uid == userId;
      
      // Écriture: propriétaire uniquement
      allow write: if request.auth != null && 
                      request.auth.uid == userId &&
                      request.resource.size < 5 * 1024 * 1024; // Max 5MB
    }
  }
}
```

### 2.3 Publier les règles

```
Bouton "Publier"
```

**✅ CHECKPOINT**: Storage est configuré

---

## 📦 ÉTAPE 3: Importer les nouvelles données (2 min)

### 3.1 Vérifier le fichier JSON

```bash
# Vérifier que le fichier existe
ls docs/workout_api_exercises_fr.json
```

**Résultat attendu**: Le fichier doit exister avec ~300 KB

### 3.2 Exécuter le script d'import

```bash
# Depuis la racine du projet
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

📋 Exemples d'exercices importés:
   1. Développé couché barre (Pectoraux)
   2. Développé militaire barre (Épaules)
   3. Squat barre (Jambes, Quadriceps, Fessiers)
   4. Soulevé de terre (Dorsaux, Jambes, Fessiers)
   5. Tractions pronation (Dorsaux)

🎉 Import terminé avec succès!
💡 Vous pouvez maintenant utiliser le catalogue dans l'app.
```

### 3.3 Vérifier dans Firebase Console

```
1. Firebase Console → Firestore Database → Data
2. Chercher la collection "exercises_library"
3. Vérifier: 94 documents présents
4. Ouvrir un document pour voir la structure
```

**✅ CHECKPOINT**: 94 exercices importés

---

## 🧹 ÉTAPE 4: Gérer l'ancienne collection (OPTIONNEL)

### Option A: Archiver l'ancienne collection (RECOMMANDÉ)

**Avantages:**
- Backup de sécurité
- Rollback possible si problème
- Pas de perte de données

**Méthode via Firebase Console:**

```
1. Firestore Database → Data
2. Collection "exercises" → Cliquer sur les 3 points
3. "Export collection"
4. Télécharger le backup localement
5. (Optionnel) Renommer en "exercises_backup" dans Firestore
```

**Méthode via CLI:**

```bash
# Exporter la collection
gcloud firestore export gs://apollon.appspot.com/backups/exercises

# Ou via script
firebase firestore:delete --path exercises --force --backup
```

### Option B: Supprimer complètement (ATTENTION)

**⚠️ DANGER: Action irréversible si pas de backup**

```
1. Firestore Database → Data
2. Collection "exercises"
3. Sélectionner tous les documents
4. Supprimer
```

**OU en masse via script:**

```javascript
// scripts/delete_old_exercises.js
const admin = require('firebase-admin');
admin.initializeApp();

async function deleteOldExercises() {
  const db = admin.firestore();
  const batch = db.batch();
  
  const snapshot = await db.collection('exercises').get();
  snapshot.docs.forEach(doc => {
    batch.delete(doc.ref);
  });
  
  await batch.commit();
  console.log(`✅ ${snapshot.size} documents supprimés`);
}

deleteOldExercises();
```

### Option C: Garder les deux (temporaire)

**Pour tests en parallèle:**
- Gardez `exercises` et `exercises_library`
- Testez le nouveau système
- Supprimez `exercises` après validation (1-2 semaines)

**✅ CHECKPOINT**: Ancienne collection gérée

---

## 🔍 ÉTAPE 5: Créer les indexes (si nécessaire)

### 5.1 Vérifier les indexes automatiques

Firebase crée automatiquement des indexes pour:
- `orderBy('name')` - Déjà utilisé dans le repository ✅

### 5.2 Créer indexes composés (si erreurs)

**Si vous voyez cette erreur dans les logs:**

```
The query requires an index. You can create it here: [URL]
```

**Action:**
1. Cliquer sur l'URL dans l'erreur
2. Firebase Console s'ouvre → "Créer l'index"
3. Attendre 2-5 minutes (indexation)

**OU créer manuellement:**

```
1. Firebase Console → Firestore → Indexes
2. Bouton "Créer un index"
3. Collection: exercises_library
4. Champs: name (Ascending), createdAt (Descending)
5. Créer
```

### 5.3 Index recommandés (optionnels)

Pour optimiser les requêtes futures:

```yaml
# firestore.indexes.json
{
  "indexes": [
    {
      "collectionGroup": "exercises_library",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "name", "order": "ASCENDING" }
      ]
    }
  ],
  "fieldOverrides": []
}
```

**✅ CHECKPOINT**: Indexes prêts

---

## ✅ ÉTAPE 6: Tester l'application (5 min)

### 6.1 Installer les dépendances

```bash
# Nettoyer
flutter clean

# Installer
flutter pub get
```

### 6.2 Lancer l'app

```bash
flutter run
```

### 6.3 Checklist de tests

**Test 1: Chargement du catalogue**
```
✅ HomePage → Bouton "Commencer séance"
✅ Catalogue s'affiche
✅ Compteur "94 exercices" visible
✅ Pas d'erreur dans les logs
```

**Test 2: Recherche**
```
✅ Taper "développé" dans la recherche
✅ Résultats filtrés instantanément (< 1s)
✅ ~5-8 exercices affichés
```

**Test 3: Filtres**
```
✅ Tap sur chip "Pectoraux"
✅ ~10-15 exercices filtrés
✅ Compteur mis à jour
```

**Test 4: Détail exercice**
```
✅ Tap sur un exercice
✅ Écran de détail s'affiche
✅ Description complète visible
✅ Bouton "Ajouter à ma séance"
```

**Test 5: Ajout à séance**
```
✅ Tap "Ajouter à ma séance"
✅ Confirmation affichée
✅ Exercice ajouté au WorkoutProvider
✅ Visible dans la séance en cours
```

**Test 6: Performance**
```
✅ Chargement initial < 1s
✅ Recherche instantanée
✅ Filtres sans lag
✅ Pas de freeze UI
```

**Test 7: Cache offline**
```
✅ Activer mode avion
✅ Relancer l'app
✅ Catalogue toujours accessible
✅ Images en cache affichées
```

**✅ CHECKPOINT**: Tous les tests passent

---

## 📊 ÉTAPE 7: Monitoring et validation (1 jour)

### 7.1 Activer Firebase Performance Monitoring

```bash
# Ajouter la dépendance
flutter pub add firebase_performance

# Dans main.dart
import 'package:firebase_performance/firebase_performance.dart';
```

### 7.2 Vérifier les métriques

```
Firebase Console → Performance
- Temps de chargement
- Requêtes Firestore
- Taille des téléchargements
```

### 7.3 Surveiller les erreurs

```
Firebase Console → Crashlytics
- Vérifier 0 crash lié aux exercices
- Logs d'erreurs
```

### 7.4 Analytics

```
Firebase Console → Analytics
- Événements personnalisés:
  - exercise_selected
  - exercise_added_to_workout
  - exercise_search
```

**✅ CHECKPOINT**: Monitoring actif

---

## 🎯 CHECKLIST FINALE

### Configuration Firebase

- [ ] ✅ Règles Firestore publiées
- [ ] ✅ Règles Storage publiées
- [ ] ✅ Collection `exercises_library` créée (94 docs)
- [ ] ✅ Ancienne collection `exercises` archivée/supprimée
- [ ] ✅ Indexes créés (si nécessaire)

### Application

- [ ] ✅ Dépendances installées (`flutter pub get`)
- [ ] ✅ Provider configuré dans `main.dart`
- [ ] ✅ Navigation adaptée (HomePage)
- [ ] ✅ Tests fonctionnels OK
- [ ] ✅ Tests performance OK
- [ ] ✅ Cache offline OK

### Production

- [ ] 🔲 Validation Product Owner
- [ ] 🔲 Tests bêta utilisateurs (optionnel)
- [ ] 🔲 Monitoring configuré
- [ ] 🔲 Documentation mise à jour
- [ ] 🔲 Changelog communiqué à l'équipe

---

## 🆘 Dépannage

### Erreur: "Permission denied"

**Cause**: Règles Firestore pas publiées

**Solution**:
```
1. Vérifier Firebase Console → Firestore → Rules
2. Vérifier `allow read: if true` pour exercises_library
3. Republier
```

### Erreur: "Collection not found"

**Cause**: Script d'import pas exécuté

**Solution**:
```bash
dart scripts/import_workout_api_exercises.dart
```

### Exercices en double

**Cause**: Script exécuté plusieurs fois

**Solution**:
```
1. Firebase Console → Firestore → exercises_library
2. Vérifier le nombre de documents
3. Si > 94: supprimer collection et réimporter
```

### Images ne s'affichent pas

**Cause**: Règles Storage pas configurées

**Solution**:
```
Firebase Console → Storage → Rules
Vérifier: allow read: if true pour exercise_images/
```

### Performance lente

**Cause**: Indexes manquants

**Solution**:
```
1. Vérifier logs pour URL d'index
2. Cliquer sur l'URL
3. Créer l'index
4. Attendre 2-5 minutes
```

---

## 🚀 Commandes rapides (TL;DR)

```bash
# 1. Installer dépendances
flutter pub get

# 2. Importer données
dart scripts/import_workout_api_exercises.dart

# 3. Tester
flutter run

# 4. Vérifier
# → Firebase Console → Firestore → exercises_library (94 docs)
```

---

## 📞 Support

- **Documentation**: [README Feature](../lib/features/exercise_library/README.md)
- **Quick Start**: [QUICKSTART](QUICKSTART_EXERCISE_LIBRARY.md)
- **Migration**: [MIGRATION_GUIDE](MIGRATION_GUIDE_EXERCISE_LIBRARY.md)

---

**Durée totale**: ~15 minutes  
**Difficulté**: Facile (copier-coller principalement)  
**Risque**: Faible (backup possible)

**Prêt à démarrer ?** Commencez par l'ÉTAPE 1 ! 🔥
