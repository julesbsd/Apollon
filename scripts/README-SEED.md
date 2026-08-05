# Import exercices avec Firebase Admin SDK (Node.js)

## Prerequis
- Node.js installe
- Firebase CLI installe (`npm install -g firebase-tools`)

## Fichiers sources

Le script `import_exercise_library.js` importe les exercices depuis deux sources JSON, localisees dans le dossier `docs/` a la racine du projet :

1. **`docs/workout_api_exercises_fr.json`** (obligatoire)
   - Exercices de l'API WorkoutAPI (environ 94 exercices)
   - Source persistante locale (car les IDs de l'API sont regeneres periodiquement)
   - Format : tableau JSON avec champs `id`, `code`, `name`, `description`, `primaryMuscles`, `secondaryMuscles`, `types`, `categories`, `hasImage`, etc.

2. **`docs/custom_exercises_fr.json`** (optionnel)
   - Exercices supplementaires : machines Fitness Park absentes du catalogue API, autres equipements
   - IDs prefixes `custom_` pour distinguer des exercices API (ex: `custom_low_row`, `custom_seated_dip`)
   - Evite les collisions lors des rotations futures d'IDs WorkoutAPI
   - Si ce fichier est absent, le script poursuit l'import avec un message informatif (pas d'erreur)

**Collision d'IDs** : si deux fichiers contiennent un meme ID, le script stoppe avant tout acces Firestore (detection locale, pas d'ecriture incomplete).

## Option 1 : Avec Firebase CLI (Recommande - Plus simple)

```bash
cd scripts
npm install
firebase login
npm run seed
```

## Option 2 : Avec Service Account Key (Production)

### 1. Telecharger la cle de service

1. Aller sur Firebase Console : https://console.firebase.google.com
2. Selectionner projet **apollon-fitness-app**
3. Parametres du projet → **Comptes de service**
4. Cliquer **"Generer une nouvelle cle privee"**
5. Telecharger le fichier JSON
6. Renommer en `serviceAccountKey.json`
7. Placer dans le dossier `scripts/`

Recommandation : ajouter `serviceAccountKey.json` au `.gitignore` pour securite

### 2. Executer le script

```bash
cd scripts
npm install
npm run seed
```

## Resultat attendu

```
INFO Demarrage du script d'import du catalogue d'exercices (Node.js)...

INFO Firebase initialise avec Service Account Key

INFO Fichier charge: docs/workout_api_exercises_fr.json (94 exercices)

INFO Fichier optionnel docs/custom_exercises_fr.json absent - poursuite sans exercices custom.

INFO Detection des collisions d'IDs... OK

IMPORT du fichier principal:
[1/94] Cree: "Developpe couche"
[2/94] Cree: "Squat"
...

==================================================
IMPORT TERMINE
Crees: 94 exercices
Deja existants (ignore): 0
Erreurs: 0
==================================================
```

Si `docs/custom_exercises_fr.json` est present, le resultat attendu montre egalement l'import des exercices custom :

```
INFO Fichier charge: docs/custom_exercises_fr.json (15 exercices custom)
...
IMPORT du fichier supplementaire (custom):
[1/15] Cree: "Rowing bas a la machine assis"
[2/15] Cree: "Dips assis a la machine"
...

Crees: 94 + 15 exercices (total: 109)
```

## Verification

Aller sur Firebase Console → Firestore Database → Collection `exercises_library`
→ Vous devriez voir les documents importes (94 + N custom, si present)

## Rollback des exercices custom

Pour retirer de Firestore les exercices importes depuis `docs/custom_exercises_fr.json`
(les fichiers JSON locaux ne sont pas touches, l'operation est rejouable) :

```bash
cd scripts
node -e "
import('firebase-admin/app').then(async ({ initializeApp, cert }) => {
  const { getFirestore } = await import('firebase-admin/firestore');
  const { readFile } = await import('fs/promises');
  const key = JSON.parse(await readFile('./serviceAccountKey.json', 'utf8'));
  initializeApp({ credential: cert(key) });
  const db = getFirestore();
  const customs = JSON.parse(await readFile('../docs/custom_exercises_fr.json', 'utf8'));
  for (const ex of customs) {
    await db.collection('exercises_library').doc(ex.id).delete();
    console.log('[SUPPRIME]', ex.id);
  }
  console.log('[OK]', customs.length, 'exercices custom supprimes de Firestore');
});
"
```

Le rollback supprime exactement les IDs listes dans `docs/custom_exercises_fr.json`
(pas de motif generique) : seuls ces documents custom sont vises, les documents
API restent hors perimetre par construction.
Pour re-importer ensuite : `npm run seed`.
