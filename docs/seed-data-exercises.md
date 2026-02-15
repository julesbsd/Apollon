# SEED DATA - EXERCICES PRÉDÉFINIS

Documentation des exercices prédéfinis intégrés dans Apollon V1.

---

## VUE D'ENSEMBLE

L'application Apollon V1 est livrée avec **50 exercices populaires** pré-enregistrés dans Firestore, couvrant tous les groupes musculaires principaux.

**Objectif :** Permettre aux utilisateurs de démarrer immédiatement sans avoir à créer manuellement des exercices.

---

## CATÉGORISATION

### Par Groupe Musculaire

| Groupe | Nombre d'exercices |
|--------|-------------------|
| Pectoraux | 8 |
| Dorsaux | 7 |
| Épaules | 5 |
| Biceps | 4 |
| Triceps | 4 |
| Quadriceps | 6 |
| Ischio-jambiers | 2 |
| Fessiers | 2 |
| Mollets | 2 |
| Abdominaux | 5 |
| Lombaires | 2 |
| Cardio | 6 |

### Par Type d'Exercice

| Type | Nombre d'exercices |
|------|-------------------|
| Poids libres | 23 |
| Machine | 11 |
| Poids de corps | 11 |
| Cardio | 5 |

---

## LISTE COMPLÈTE DES EXERCICES

### PECTORAUX (8 exercices)

| Nom | Type | Muscles secondaires |
|-----|------|---------------------|
| Développé couché barre | Poids libres | Triceps, Épaules |
| Développé couché haltères | Poids libres | Triceps, Épaules |
| Développé incliné barre | Poids libres | Triceps, Épaules |
| Développé décliné barre | Poids libres | Triceps |
| Écarté haltères | Poids libres | - |
| Pec deck (Butterfly) | Machine | - |
| Pompes | Poids de corps | Triceps, Épaules |
| Dips pectoraux | Poids de corps | Triceps |

---

### DORSAUX (7 exercices)

| Nom | Type | Muscles secondaires |
|-----|------|---------------------|
| Tractions | Poids de corps | Biceps |
| Rowing barre | Poids libres | Biceps |
| Rowing haltère (unilatéral) | Poids libres | Biceps |
| Tirage poitrine poulie haute | Machine | Biceps |
| Tirage horizontal poulie basse | Machine | Biceps |
| Soulevé de terre | Poids libres | Lombaires, Fessiers, Ischio-jambiers |
| Extensions lombaires | Poids de corps | Lombaires |

---

### ÉPAULES (5 exercices)

| Nom | Type | Muscles secondaires |
|-----|------|---------------------|
| Développé militaire barre | Poids libres | Triceps |
| Développé épaules haltères | Poids libres | Triceps |
| Élévations latérales | Poids libres | - |
| Élévations frontales | Poids libres | - |
| Oiseau haltères | Poids libres | Dorsaux |

---

### BRAS - BICEPS (4 exercices)

| Nom | Type | Muscles secondaires |
|-----|------|---------------------|
| Curl barre | Poids libres | - |
| Curl haltères | Poids libres | - |
| Curl marteau | Poids libres | Avant-bras |
| Curl pupitre (Larry Scott) | Poids libres | - |

---

### BRAS - TRICEPS (4 exercices)

| Nom | Type | Muscles secondaires |
|-----|------|---------------------|
| Dips triceps | Poids de corps | - |
| Extension triceps poulie haute | Machine | - |
| Extension nuque haltère | Poids libres | - |
| Barre au front | Poids libres | - |

---

### JAMBES - QUADRICEPS (6 exercices)

| Nom | Type | Muscles secondaires |
|-----|------|---------------------|
| Squat barre | Poids libres | Fessiers, Ischio-jambiers |
| Squat avant | Poids libres | Fessiers |
| Presse à cuisses | Machine | Fessiers |
| Hack squat | Machine | Fessiers |
| Fentes avant | Poids libres | Fessiers |
| Leg extension | Machine | - |

---

### JAMBES - ISCHIO-JAMBIERS & FESSIERS

| Nom | Type | Groupes principaux |
|-----|------|--------------------|
| Leg curl | Machine | Ischio-jambiers |
| Soulevé de terre jambes tendues | Poids libres | Ischio-jambiers, Fessiers, Lombaires |
| Hip thrust | Poids libres | Fessiers, Ischio-jambiers |

---

### MOLLETS (2 exercices)

| Nom | Type |
|-----|------|
| Mollets debout | Machine |
| Mollets assis | Machine |

---

### ABDOMINAUX (5 exercices)

| Nom | Type | Muscles secondaires |
|-----|------|---------------------|
| Crunch | Poids de corps | - |
| Relevé de jambes | Poids de corps | - |
| Planche (gainage) | Poids de corps | Lombaires |
| Russian twist | Poids de corps | Obliques |
| Mountain climbers | Poids de corps | Cardio |

---

### CARDIO (6 exercices)

| Nom | Type |
|-----|------|
| Tapis de course | Cardio |
| Vélo elliptique | Cardio |
| Vélo stationnaire | Cardio |
| Rameur | Cardio |
| Burpees | Poids de corps |
| Corde à sauter | Cardio |

---

## STRUCTURE FIRESTORE

Chaque exercice est stocké dans la collection `/exercises` avec la structure suivante :

```typescript
{
  name: string,                     // "Développé couché barre"
  nameSearch: string,               // "développé couché barre" (minuscules)
  muscleGroups: string[],           // ["pectoraux", "triceps", "epaules"]
  type: 'free_weights' | 'machine' | 'bodyweight' | 'cardio',
  emoji: string,                    // "💪"
  description: string,              // Description de l'exercice
  createdAt: timestamp              // Date d'import
}
```

---

## IMPORT DANS FIRESTORE

### Méthode automatique (recommandée)

Utiliser le script Dart fourni :

```bash
# Depuis la racine du projet
dart run scripts/seed_exercises.dart
```

**Le script :**
- ✅ Vérifie les doublons (RG-002: Unicité des noms)
- ✅ Utilise batch writes pour optimiser les écritures
- ✅ Génère le champ `nameSearch` automatiquement
- ✅ Affiche statistiques d'import

**Résultat attendu :**

```
✅ IMPORT TERMINÉ
✅ Créés:   50 exercices
⏭️  Ignorés: 0 exercices (doublons)
❌ Erreurs: 0
📊 Total:   50 exercices traités
```

---

### Méthode manuelle (Firebase Console)

Si le script ne fonctionne pas :

1. Aller sur [Firebase Console](https://console.firebase.google.com)
2. Firestore Database → Démarrer la collection
3. Collection ID : `exercises`
4. Ajouter manuellement chaque exercice depuis [exercises.json](../assets/seed_data/exercises.json)

**⚠️ Attention :** Très fastidieux (50 exercices), préférer le script.

---

## EMOJIS PAR CATÉGORIE

Les emojis permettent une navigation visuelle rapide dans l'UI.

| Groupe musculaire | Emoji | Code |
|-------------------|-------|------|
| Pectoraux | 💪 | `:muscle:` |
| Dorsaux | 🦍 | `:gorilla:` |
| Épaules | 🏋️ | `:weight_lifter:` |
| Bras (biceps/triceps) | 💪 | `:muscle:` |
| Jambes | 🦵 | `:leg:` |
| Fessiers | 🍑 | `:peach:` |
| Abdominaux | 💥 | `:boom:` |
| Cardio | 🏃 / 🚴 / 🚣 | `:runner:` / `:cyclist:` / `:rowing:` |

---

## ÉVOLUTION V2

### Ajout exercices personnalisés utilisateur

**V2 :** Permettre aux utilisateurs d'ajouter leurs propres exercices.

**Modifications requises :**

1. **Structure document exercice :**

```typescript
{
  name: string,
  isCustom: boolean,                // false = seed, true = user custom
  createdBy?: string,               // userId si custom
  visibility: 'public' | 'private', // public = seed, private = user
  ...
}
```

2. **Security Rules :**

```javascript
allow create: if isAuthenticated()
              && validateExercise(request.resource.data)
              && request.resource.data.createdBy == request.auth.uid
              && request.resource.data.isCustom == true;
```

3. **UI :** Bouton "Créer exercice personnalisé" avec formulaire.

---

### Images IA générées

**V2 :** Remplacer emojis par images générées par IA.

**Workflow :**

1. Générer images avec Midjourney/DALL-E
2. Stocker dans Firebase Storage
3. Ajouter champ `imageUrl` aux exercices
4. Fallback emoji si image non disponible

---

## MAINTENANCE SEED DATA

### Ajouter de nouveaux exercices

1. Éditer [exercises.json](../assets/seed_data/exercises.json)
2. Ajouter l'exercice au format JSON
3. Relancer le script d'import

**Le script détecte automatiquement les doublons.**

### Modifier un exercice existant

**Option 1 (recommandée) :** Firebase Console

1. Firestore → Collection `exercises`
2. Chercher l'exercice par nom
3. Éditer le document

**Option 2 :** Script de migration (à créer si modifications massives)

---

## VÉRIFICATION POST-IMPORT

### Checklist

- [ ] Vérifier que 50 exercices sont présents dans Firebase Console
- [ ] Tester recherche par nom dans l'app
- [ ] Tester filtrage par groupe musculaire
- [ ] Tester filtrage par type
- [ ] Vérifier que les emojis s'affichent correctement
- [ ] Confirmer que les exercices sont accessibles hors ligne (mode avion)

### Requête de vérification

```dart
// Compter le nombre d'exercices
final count = await FirebaseFirestore.instance
  .collection('exercises')
  .get()
  .then((snapshot) => snapshot.size);

print('Nombre d\'exercices: $count'); // Attendu: 50
```

---

## INDEXES FIRESTORE REQUIS

Après import, créer les indexes composites suivants dans Firebase Console :

### Index 1 : Filtrage par groupe musculaire

```
Collection: exercises
Fields:
  - muscleGroups (Array-contains)
  - name (Ascending)
```

**Permet :** `exercises.where('muscleGroups', arrayContains: 'pectoraux').orderBy('name')`

---

### Index 2 : Filtrage par type

```
Collection: exercises
Fields:
  - type (Ascending)
  - name (Ascending)
```

**Permite :** `exercises.where('type', isEqualTo: 'free_weights').orderBy('name')`

---

### Index 3 : Recherche textuelle

```
Collection: exercises
Fields:
  - nameSearch (Ascending)
```

**Permet :** `exercises.where('nameSearch', isGreaterThanOrEqualTo: search)`

---

## SOURCES ET INSPIRATION

Les 50 exercices ont été sélectionnés selon :
- **Popularité** : Exercices classiques pratiqués en salle
- **Couverture** : Tous les groupes musculaires représentés
- **Diversité** : Mix poids libres / machines / poids de corps
- **Équilibre** : Focus sur exercices polyarticulaires + isolation

**Références :**
- Programmes de musculation classiques (Push/Pull/Legs)
- Exercices recommandés par coaches FFHM
- Applications concurrentes (analyse benchmark)

---

## STATISTIQUES

| Métrique | Valeur |
|----------|--------|
| **Total exercices** | 50 |
| **Groupes musculaires couverts** | 12 |
| **Types d'exercices** | 4 |
| **Exercices polyarticulaires** | 18 |
| **Exercices d'isolation** | 32 |
| **Poids estimé Firestore** | ~15 KB |
| **Coût lectures (1 load complet)** | 50 reads (1% quota gratuit) |

---

**Document généré par:** Firebase Backend Specialist Agent  
**Version:** 1.0.0  
**Date:** 15 février 2026  
**Projet:** Apollon - Application Flutter de suivi musculation
