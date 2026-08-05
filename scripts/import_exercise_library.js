import { readFile } from 'fs/promises';
import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';

/**
 * Script d'import du catalogue Exercise Library vers Firestore.
 *
 * Sources (importees dans cet ordre) :
 *   1. docs/workout_api_exercises_fr.json (obligatoire, catalogue Workout API)
 *   2. docs/custom_exercises_fr.json (optionnel, exercices ajoutes manuellement,
 *      ids prefixes "custom_") - si absent, le script logue un message clair et
 *      poursuit l'import sans erreur.
 *
 * Utilise Firebase Admin SDK - pas de dependance Flutter.
 *
 * Avant toute ecriture Firestore, le script verifie :
 *   - zero collision d'id, au sein de chaque fichier ET entre les deux fichiers ;
 *   - zero doublon de nom normalise (accents/casse ignores) entre les deux fichiers.
 * Si un conflit est detecte, l'import est abandonne (aucune ecriture Firestore
 * n'est effectuee) et la liste exacte des conflits est affichee.
 *
 * Installation:
 *   cd scripts
 *   npm install
 *
 * Usage:
 *   npm run import-library
 * OU directement:
 *   node import_exercise_library.js
 */

const PRIMARY_PATH = '../docs/workout_api_exercises_fr.json';
const PRIMARY_LABEL = 'workout_api_exercises_fr.json';
const SECONDARY_PATH = '../docs/custom_exercises_fr.json';
const SECONDARY_LABEL = 'custom_exercises_fr.json';
const COLLECTION = 'exercises_library';
const BATCH_SIZE = 500; // Limite Firestore par batch

/**
 * Normalise un nom pour comparaison : decompose les caracteres accentues
 * (Unicode NFD), retire les diacritiques combinants, met en minuscules et
 * retire les espaces superflus en tete/queue. Ignore uniquement accents et
 * casse, pas la ponctuation.
 */
function normalizeName(name) {
  return (name || '')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .trim();
}

/**
 * Charge un fichier JSON obligatoire (tableau d'exercices). Erreur fatale
 * si le fichier est absent, illisible ou n'est pas un tableau JSON.
 */
async function loadRequiredJson(path, label) {
  const raw = await readFile(path, 'utf8');
  const data = JSON.parse(raw);
  if (!Array.isArray(data)) {
    throw new Error(`${label} : le contenu n'est pas un tableau JSON`);
  }
  return data;
}

/**
 * Charge un fichier JSON optionnel (tableau d'exercices). Si le fichier est
 * absent (ENOENT), logue un message clair et retourne un tableau vide sans
 * lever d'erreur. Toute autre erreur (JSON invalide, droits d'acces, etc.)
 * reste fatale.
 */
async function loadOptionalJson(path, label) {
  let raw;
  try {
    raw = await readFile(path, 'utf8');
  } catch (error) {
    if (error.code === 'ENOENT') {
      console.log(`[INFO] ${label} absent (${path}) - poursuite de l'import sans exercices custom.\n`);
      return [];
    }
    throw error;
  }
  const data = JSON.parse(raw);
  if (!Array.isArray(data)) {
    throw new Error(`${label} : le contenu n'est pas un tableau JSON`);
  }
  return data;
}

/**
 * Verifie l'integrite des deux jeux de donnees avant toute ecriture Firestore :
 *   - ids dupliques au sein de chaque fichier ;
 *   - ids en collision entre les deux fichiers ;
 *   - noms normalises (accents/casse ignores) dupliques entre les deux fichiers.
 * Retourne la liste des messages de conflit (vide = aucun conflit).
 */
function detectConflicts(primary, primaryLabel, secondary, secondaryLabel) {
  const conflicts = [];

  const findInternalIdDuplicates = (list, label) => {
    const seen = new Map();
    for (let i = 0; i < list.length; i++) {
      const id = list[i].id;
      if (seen.has(id)) {
        conflicts.push(
          `Collision d'id au sein de ${label} : id "${id}" present aux positions ${seen.get(id)} et ${i}`
        );
      } else {
        seen.set(id, i);
      }
    }
  };

  findInternalIdDuplicates(primary, primaryLabel);
  findInternalIdDuplicates(secondary, secondaryLabel);

  const primaryIdIndex = new Map(primary.map((e, i) => [e.id, i]));
  for (let j = 0; j < secondary.length; j++) {
    const id = secondary[j].id;
    if (primaryIdIndex.has(id)) {
      conflicts.push(
        `Collision d'id entre les deux fichiers : id "${id}" present dans ${primaryLabel} ` +
        `(position ${primaryIdIndex.get(id)}) et ${secondaryLabel} (position ${j})`
      );
    }
  }

  const primaryNameIndex = new Map(primary.map((e, i) => [normalizeName(e.name), i]));
  for (let j = 0; j < secondary.length; j++) {
    const normalized = normalizeName(secondary[j].name);
    if (primaryNameIndex.has(normalized)) {
      const i = primaryNameIndex.get(normalized);
      conflicts.push(
        `Doublon de nom normalise entre les deux fichiers : "${normalized}" -> ` +
        `"${primary[i].name}" (${primaryLabel}, id=${primary[i].id}) vs ` +
        `"${secondary[j].name}" (${secondaryLabel}, id=${secondary[j].id})`
      );
    }
  }

  return conflicts;
}

/**
 * Transforme un exercice source (JSON) en document Firestore.
 */
function transformExercise(exercise, source) {
  const id = exercise.id || exercise.exerciseId || `ex_${Math.random().toString(36).substr(2, 9)}`;

  return {
    id,
    code: exercise.code || id,
    name: exercise.name || exercise.exerciseName || 'Sans nom',
    description: exercise.description || '',

    // Conserver la structure complete des muscles
    primaryMuscles: exercise.primaryMuscles || [],
    secondaryMuscles: exercise.secondaryMuscles || [],

    // Conserver la structure complete des types et categories
    types: exercise.types || [],
    categories: exercise.categories || [],

    // Metadonnees
    syncedAt: FieldValue.serverTimestamp(),
    source,
    // Propage la valeur du JSON source (les customs avec pictogramme embarque
    // declarent hasImage:true) ; false si absent, pour ne pas pointer vers une
    // image qui n'existe pas.
    hasImage: exercise.hasImage === true,
  };
}

/**
 * Ecrit une liste d'exercices dans Firestore par batches de BATCH_SIZE,
 * avec merge:true et doc id = exercise.id. Retourne le nombre d'exercices
 * importes avec succes et le nombre d'erreurs.
 */
async function writeBatch(db, exercises, label) {
  let imported = 0;
  let errors = 0;

  for (let i = 0; i < exercises.length; i += BATCH_SIZE) {
    const batch = db.batch();
    const chunk = exercises.slice(i, i + BATCH_SIZE);

    for (const exercise of chunk) {
      const docRef = db.collection(COLLECTION).doc(exercise.id);
      batch.set(docRef, exercise, { merge: true });
    }

    try {
      await batch.commit();
      imported += chunk.length;
      console.log(`   [OK] ${label} - batch ${Math.floor(i / BATCH_SIZE) + 1} : ${chunk.length} exercices importes`);
    } catch (error) {
      errors += chunk.length;
      console.error(`   [ERREUR] ${label} - batch ${Math.floor(i / BATCH_SIZE) + 1} :`, error.message);
    }
  }

  return { imported, errors };
}

async function main() {
  console.log('Import du catalogue Exercise Library vers Firestore\n');
  console.log(`Collection cible: ${COLLECTION}`);
  console.log('Source 1 (obligatoire): docs/workout_api_exercises_fr.json');
  console.log('Source 2 (optionnelle): docs/custom_exercises_fr.json\n');

  try {
    // ==========================================
    // 1. Lecture des fichiers sources
    //    (avant tout acces Firebase - lecture pure)
    // ==========================================

    console.log('Lecture des fichiers sources...');
    const primaryData = await loadRequiredJson(PRIMARY_PATH, PRIMARY_LABEL);
    console.log(`   ${primaryData.length} exercices charges depuis ${PRIMARY_LABEL}`);

    const secondaryData = await loadOptionalJson(SECONDARY_PATH, SECONDARY_LABEL);
    if (secondaryData.length > 0) {
      console.log(`   ${secondaryData.length} exercices charges depuis ${SECONDARY_LABEL}`);
    }
    console.log('');

    // ==========================================
    // 2. Verification d'integrite AVANT toute ecriture
    // ==========================================

    console.log("Verification d'integrite (collisions d'id + doublons de nom normalise)...");
    const conflicts = detectConflicts(primaryData, PRIMARY_LABEL, secondaryData, SECONDARY_LABEL);

    if (conflicts.length > 0) {
      console.error('\n[ABANDON] Conflits detectes - aucune ecriture Firestore effectuee.\n');
      conflicts.forEach((conflict, index) => console.error(`   ${index + 1}. ${conflict}`));
      console.error(`\nTotal: ${conflicts.length} conflit(s).\n`);
      process.exit(1);
    }
    console.log('   Aucun conflit detecte.\n');

    // ==========================================
    // 3. Initialiser Firebase Admin SDK
    // ==========================================

    console.log('Initialisation Firebase Admin...');

    // Essayer d'abord avec Service Account Key
    let initSuccess = false;
    try {
      const serviceAccountData = await readFile('./serviceAccountKey.json', 'utf8');
      const serviceAccount = JSON.parse(serviceAccountData);

      initializeApp({
        credential: cert(serviceAccount)
      });

      console.log('   Firebase initialise avec Service Account Key\n');
      initSuccess = true;
    } catch (error) {
      console.log('   Service Account Key non trouve');
    }

    // Sinon utiliser Application Default Credentials
    if (!initSuccess) {
      try {
        console.log('   Tentative avec Application Default Credentials...');

        initializeApp({
          projectId: 'YOUR_PROJECT_ID' // Sera auto-detecte si GOOGLE_APPLICATION_CREDENTIALS est defini
        });

        console.log('   Firebase initialise avec Default Credentials\n');
      } catch (error) {
        console.error('\n[ERREUR] Initialisation Firebase');
        console.error('\nSolutions:');
        console.error('1. Telecharger Service Account Key:');
        console.error('   - Firebase Console -> Parametres projet -> Comptes de service');
        console.error('   - Generer nouvelle cle privee -> Telecharger JSON');
        console.error('   - Placer dans scripts/serviceAccountKey.json\n');
        console.error('2. OU installer Firebase CLI et se connecter:');
        console.error('   npm install -g firebase-tools');
        console.error('   firebase login');
        console.error('   firebase projects:list\n');
        throw error;
      }
    }

    const db = getFirestore();

    // ==========================================
    // 4. Compte de la collection AVANT import
    // ==========================================

    const beforeSnapshot = await db.collection(COLLECTION).count().get();
    const countBefore = beforeSnapshot.data().count;
    console.log(`Documents presents dans ${COLLECTION} avant import: ${countBefore}\n`);

    // ==========================================
    // 5. Transformer les donnees
    // ==========================================

    console.log('Transformation des donnees...');
    const primaryExercises = primaryData.map((exercise) => transformExercise(exercise, 'workout-api'));
    const secondaryExercises = secondaryData.map((exercise) => transformExercise(exercise, 'custom'));
    console.log(`   ${primaryExercises.length + secondaryExercises.length} exercices transformes\n`);

    // ==========================================
    // 6. Import dans Firestore (batch), fichier par fichier
    // ==========================================

    console.log(`Import ${PRIMARY_LABEL} (${primaryExercises.length} exercices)...`);
    const resultPrimary = await writeBatch(db, primaryExercises, PRIMARY_LABEL);

    let resultSecondary = { imported: 0, errors: 0 };
    if (secondaryExercises.length > 0) {
      console.log(`\nImport ${SECONDARY_LABEL} (${secondaryExercises.length} exercices)...`);
      resultSecondary = await writeBatch(db, secondaryExercises, SECONDARY_LABEL);
    } else {
      console.log(`\n${SECONDARY_LABEL} absent ou vide - aucun exercice custom a importer.`);
    }

    // ==========================================
    // 7. Compte de la collection APRES import
    // ==========================================

    console.log('\nVerification dans Firestore...');
    const afterSnapshot = await db.collection(COLLECTION).count().get();
    const countAfter = afterSnapshot.data().count;
    console.log(`${countAfter} documents presents dans ${COLLECTION}\n`);

    // ==========================================
    // 8. Resume
    // ==========================================

    console.log('==================================================');
    console.log("RESUME DE L'IMPORT");
    console.log('==================================================');
    console.log(`${PRIMARY_LABEL}: ${resultPrimary.imported} importes / ${resultPrimary.errors} erreurs (sur ${primaryExercises.length})`);
    console.log(`${SECONDARY_LABEL}: ${resultSecondary.imported} importes / ${resultSecondary.errors} erreurs (sur ${secondaryExercises.length})`);
    console.log(`Documents dans ${COLLECTION} avant import: ${countBefore}`);
    console.log(`Documents dans ${COLLECTION} apres import: ${countAfter}`);
    console.log('==================================================\n');

    if (secondaryExercises.length > 0) {
      console.log("Ids custom_ ecrits (issus de custom_exercises_fr.json):");
      secondaryExercises.forEach((exercise) => console.log(`   - ${exercise.id}`));
      console.log('');
    }

    // Afficher quelques exemples
    if (countAfter > 0) {
      console.log("Exemples d'exercices importes:");
      const sampleSnapshot = await db.collection(COLLECTION).limit(5).get();
      sampleSnapshot.docs.forEach((doc, index) => {
        const data = doc.data();
        const musclesStr = (data.primaryMuscles || []).map((m) => m.name).slice(0, 2).join(', ') || 'N/A';
        console.log(`   ${index + 1}. ${data.name} (${musclesStr})`);
      });
      console.log('');
    }

    console.log('Import termine avec succes.');
    console.log("Vous pouvez maintenant lancer l'app: flutter run\n");

    process.exit(0);

  } catch (error) {
    console.error('\n[ERREUR FATALE]');
    console.error(error);
    console.error('\nVerifiez:');
    console.error('- Le fichier docs/workout_api_exercises_fr.json existe');
    console.error('- Firebase est correctement configure');
    console.error("- Vous avez les droits d'ecriture sur Firestore\n");
    process.exit(1);
  }
}

// Lancer le script
main();
