import { readFile } from 'fs/promises';
import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';

/**
 * 🔥 Script d'import du catalogue Exercise Library (94 exercices Workout API)
 * 
 * Utilise Firebase Admin SDK - PAS de dépendance Flutter
 * 
 * Prérequis:
 * 1. Avoir Node.js installé (https://nodejs.org)
 * 2. (Optionnel) Service Account Key dans scripts/serviceAccountKey.json
 * 
 * Installation:
 *   cd scripts
 *   npm install
 * 
 * Usage:
 *   npm run import-library
 * 
 * OU directement:
 *   node import_exercise_library.js
 */

async function main() {
  console.log('🚀 Import du catalogue Exercise Library vers Firestore\n');
  console.log('Collection cible: exercises_library');
  console.log('Source: docs/workout_api_exercises_fr.json\n');

  try {
    // ==========================================
    // 1. Initialiser Firebase Admin SDK
    // ==========================================
    
    console.log('🔐 Initialisation Firebase Admin...');
    
    // Essayer d'abord avec Service Account Key
    let initSuccess = false;
    try {
      const serviceAccountData = await readFile('./serviceAccountKey.json', 'utf8');
      const serviceAccount = JSON.parse(serviceAccountData);
      
      initializeApp({
        credential: cert(serviceAccount)
      });
      
      console.log('✅ Firebase initialisé avec Service Account Key\n');
      initSuccess = true;
    } catch (error) {
      console.log('⚠️  Service Account Key non trouvé');
    }

    // Sinon utiliser Application Default Credentials
    if (!initSuccess) {
      try {
        console.log('🔄 Tentative avec Application Default Credentials...');
        
        // Essayer avec le projectId extrait des firebase_options.dart
        initializeApp({
          projectId: 'YOUR_PROJECT_ID' // Sera auto-détecté si GOOGLE_APPLICATION_CREDENTIALS est défini
        });
        
        console.log('✅ Firebase initialisé avec Default Credentials\n');
      } catch (error) {
        console.error('\n❌ ERREUR D\'INITIALISATION FIREBASE');
        console.error('\nSolutions:');
        console.error('1. Télécharger Service Account Key:');
        console.error('   - Firebase Console → Paramètres projet → Comptes de service');
        console.error('   - Générer nouvelle clé privée → Télécharger JSON');
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
    // 2. Lire le fichier JSON
    // ==========================================
    
    console.log('📖 Lecture du fichier workout_api_exercises_fr.json...');
    
    const jsonPath = '../docs/workout_api_exercises_fr.json';
    const jsonString = await readFile(jsonPath, 'utf8');
    const exercisesData = JSON.parse(jsonString);
    
    console.log(`✅ ${exercisesData.length} exercices chargés\n`);

    // ==========================================
    // 3. Transformer et valider les données
    // ==========================================
    
    console.log('🔄 Transformation des données...');
    
    const exercises = exercisesData.map((exercise) => {
      // Extraire les données de l'exercice
      const id = exercise.id || exercise.exerciseId || `ex_${Math.random().toString(36).substr(2, 9)}`;
      
      return {
        id: id,
        code: exercise.code || id,
        name: exercise.name || exercise.exerciseName || 'Sans nom',
        description: exercise.description || '',
        
        // Conserver la structure complète des muscles
        primaryMuscles: exercise.primaryMuscles || [],
        secondaryMuscles: exercise.secondaryMuscles || [],
        
        // Conserver la structure complète des types et catégories
        types: exercise.types || [],
        categories: exercise.categories || [],
        
        // Métadonnées
        syncedAt: FieldValue.serverTimestamp(),
        source: 'workout-api',
        hasImage: false,
      };
    });

    console.log(`✅ ${exercises.length} exercices transformés\n`);

    // ==========================================
    // 4. Import dans Firestore (batch)
    // ==========================================
    
    console.log('💾 Import dans Firestore...');
    console.log('Collection: exercises_library');
    console.log(`Nombre d'exercices: ${exercises.length}\n`);

    const BATCH_SIZE = 500; // Limite Firestore
    let totalImported = 0;
    let totalErrors = 0;

    // Traiter par batches
    for (let i = 0; i < exercises.length; i += BATCH_SIZE) {
      const batch = db.batch();
      const batchExercises = exercises.slice(i, i + BATCH_SIZE);

      for (const exercise of batchExercises) {
        const docRef = db.collection('exercises_library').doc(exercise.id);
        batch.set(docRef, exercise, { merge: true });
      }

      try {
        await batch.commit();
        totalImported += batchExercises.length;
        console.log(`   ✅ Batch ${Math.floor(i / BATCH_SIZE) + 1}: ${batchExercises.length} exercices importés`);
      } catch (error) {
        totalErrors += batchExercises.length;
        console.error(`   ❌ Erreur batch ${Math.floor(i / BATCH_SIZE) + 1}:`, error.message);
      }
    }

    // ==========================================
    // 5. Vérification finale
    // ==========================================
    
    console.log('\n🔍 Vérification dans Firestore...');
    const snapshot = await db.collection('exercises_library').count().get();
    const count = snapshot.data().count;
    console.log(`✅ ${count} documents présents dans Firestore\n`);

    // ==========================================
    // 6. Résumé
    // ==========================================
    
    console.log('==================================================');
    console.log('📊 RÉSUMÉ DE L\'IMPORT');
    console.log('==================================================');
    console.log(`✅ Succès: ${totalImported} exercices`);
    console.log(`❌ Erreurs: ${totalErrors} exercices`);
    console.log(`📦 Total: ${exercises.length} exercices`);
    console.log('==================================================\n');

    // Afficher quelques exemples
    if (count > 0) {
      console.log('📋 Exemples d\'exercices importés:');
      const sampleSnapshot = await db.collection('exercises_library').limit(5).get();
      sampleSnapshot.docs.forEach((doc, index) => {
        const data = doc.data();
        const musclesStr = data.muscles?.slice(0, 2).join(', ') || 'N/A';
        console.log(`   ${index + 1}. ${data.name} (${musclesStr})`);
      });
      console.log('');
    }

    console.log('🎉 Import terminé avec succès!');
    console.log('💡 Vous pouvez maintenant lancer l\'app: flutter run\n');

    process.exit(0);

  } catch (error) {
    console.error('\n❌ ERREUR FATALE');
    console.error(error);
    console.error('\nVérifiez:');
    console.error('- Le fichier docs/workout_api_exercises_fr.json existe');
    console.error('- Firebase est correctement configuré');
    console.error('- Vous avez les droits d\'écriture sur Firestore\n');
    process.exit(1);
  }
}

// Lancer le script
main();
