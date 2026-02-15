import { readFile } from 'fs/promises';
import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';

/**
 * Script Node.js pour importer les exercices dans Firestore
 * Utilise Firebase Admin SDK (pas de dépendance Flutter)
 * 
 * Configuration requise:
 * 1. Télécharger service account key depuis Firebase Console
 * 2. Placer dans scripts/serviceAccountKey.json
 * 
 * Usage:
 *   cd scripts
 *   npm install
 *   npm run seed
 */

async function main() {
  console.log('🔥 Démarrage du script de seed data Firestore (Node.js)...\n');

  try {
    // Initialiser Firebase Admin SDK
    // Option 1: Avec service account key (recommandé)
    let serviceAccount;
    try {
      const serviceAccountData = await readFile('./serviceAccountKey.json', 'utf8');
      serviceAccount = JSON.parse(serviceAccountData);
      
      initializeApp({
        credential: cert(serviceAccount)
      });
      console.log('✅ Firebase initialisé avec Service Account Key\n');
    } catch (error) {
      // Option 2: Avec Application Default Credentials (si firebase login déjà fait)
      console.log('⚠️  Service Account Key non trouvé, tentative avec ADC...');
      console.log('   (Exécuter: firebase login si nécessaire)\n');
      
      initializeApp({
        projectId: 'apollon-fitness-app'
      });
      console.log('✅ Firebase initialisé avec Default Credentials\n');
    }

    const db = getFirestore();

    // Lire le fichier JSON des exercices
    const exercisesJson = await readFile('../assets/seed_data/exercises.json', 'utf8');
    const exercisesData = JSON.parse(exercisesJson);
    console.log(`📄 Fichier chargé: ${exercisesData.length} exercices\n`);

    // Compteurs pour statistiques
    let created = 0;
    let skipped = 0;
    let errors = 0;

    // Référence collection exercises
    const exercisesCollection = db.collection('exercises');

    // Importer chaque exercice
    for (let i = 0; i < exercisesData.length; i++) {
      const exercise = exercisesData[i];
      const name = exercise.name;

      try {
        // Vérifier si l'exercice existe déjà
        const existingDocs = await exercisesCollection
          .where('name', '==', name)
          .limit(1)
          .get();

        if (!existingDocs.empty) {
          console.log(`⏭️  [${i + 1}/${exercisesData.length}] Ignoré: "${name}" (existe déjà)`);
          skipped++;
          continue;
        }

        // Créer l'exercice avec champ de recherche
        const exerciseData = {
          ...exercise,
          nameSearch: name.toLowerCase(),
          createdAt: FieldValue.serverTimestamp()
        };

        await exercisesCollection.add(exerciseData);
        
        console.log(`✅ [${i + 1}/${exercisesData.length}] Créé: "${name}"`);
        created++;
        
      } catch (error) {
        console.log(`❌ [${i + 1}/${exercisesData.length}] Erreur: "${name}" - ${error.message}`);
        errors++;
      }
    }

    // Afficher statistiques finales
    console.log('\n' + '='.repeat(50));
    console.log('✅ IMPORT TERMINÉ');
    console.log(`✅ Créés:   ${created} exercices`);
    console.log(`⏭️  Ignorés: ${skipped} exercices (existent déjà)`);
    if (errors > 0) {
      console.log(`❌ Erreurs: ${errors}`);
    } else {
      console.log('✅ Aucune erreur');
    }
    console.log('='.repeat(50));

    process.exit(0);
    
  } catch (error) {
    console.error('\n❌ ERREUR FATALE:', error.message);
    console.error('\n💡 SOLUTIONS:');
    console.error('   1. Vérifier que serviceAccountKey.json existe dans scripts/');
    console.error('   2. OU exécuter: firebase login');
    console.error('   3. Vérifier les permissions Firestore du compte utilisé');
    process.exit(1);
  }
}

main();
