# Import exercices avec Firebase Admin SDK (Node.js)

## Prérequis
- Node.js installé ✅
- Firebase CLI installé (`npm install -g firebase-tools`)

## Option 1 : Avec Firebase CLI (Recommandé - Plus simple)

```bash
cd scripts
npm install
firebase login
npm run seed
```

## Option 2 : Avec Service Account Key (Production)

### 1. Télécharger la clé de service

1. Aller sur Firebase Console : https://console.firebase.google.com
2. Sélectionner projet **apollon-fitness-app**
3. ⚙️ Paramètres du projet → **Comptes de service**
4. Cliquer **"Générer une nouvelle clé privée"**
5. Télécharger le fichier JSON
6. Renommer en `serviceAccountKey.json`
7. Placer dans le dossier `scripts/`

⚠️ **IMPORTANT:** Ajouter `serviceAccountKey.json` au `.gitignore` (ne JAMAIS commit!)

### 2. Exécuter le script

```bash
cd scripts
npm install
npm run seed
```

## Résultat attendu

```
🔥 Démarrage du script de seed data Firestore (Node.js)...

✅ Firebase initialisé avec Service Account Key

📄 Fichier chargé: 50 exercices

✅ [1/50] Créé: "Développé couché"
✅ [2/50] Créé: "Squat"
...

==================================================
✅ IMPORT TERMINÉ
✅ Créés:   50 exercices
⏭️  Ignorés: 0 exercices (existent déjà)
✅ Aucune erreur
==================================================
```

## Vérification

Aller sur Firebase Console → Firestore Database → Collection `exercises`
→ Vous devriez voir 50 documents
