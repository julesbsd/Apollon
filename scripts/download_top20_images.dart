import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// TOP 20 exercices les plus populaires (IDs depuis workout_api_exercises_fr.json)
const top20Ids = {
  'BARBELL_BENCH_PRESS': '7a6f9920-7d58-476d-8c34-9508b20d4dc6',
  'DEADLIFT': 'e7c2ba66-ff0a-4d9e-ba49-5ed54e411467',
  'BARBELL_SHOULDER_PRESS': 'e51e9549-d9b7-463e-a8e2-19b3d00ee8af',
  'LEG_PRESS': '85bddde0-fd5a-44dc-9ad0-7d11480df59f',
  'BARBELL_CURL': '90492bc2-1804-4a68-8179-cf62b2807f21',
  'SUPINATED_GRIP_PULL_UPS': 'd12de636-6dec-4cec-b55e-27079dd8cdd6',
  'PRONATED_GRIP_PULL_UPS': '418bd319-fa86-4773-a172-5273d950adb3',
  'DIPS': '244b7106-7d3d-42eb-bc1a-485578d2c235',
  'INCLINE_BARBELL_BENCH_PRESS': '5fcb938e-a4fa-4c9c-9f59-77e3ab1dfe98',
  'DECLINE_BARBELL_BENCH_PRESS': 'b9b45b9f-49ef-41ce-b038-3cba517aa275',
  'BENT_OVER_DUMBBELL_ROW': 'b8fadf63-943f-46c2-955a-d36adcec782b',
  'LEG_CURL': 'f75fb129-1f8d-4d11-96b3-02874c0c0833',
  'LEG_EXTENSION': 'c5c22898-23f4-4156-86d3-bda2177adae2',
  'LATERAL_RAISE_WITH_DUMBBELLS': '1548269e-bf89-4902-bf57-d988a1b4500d',
  'ARNOLD_DUMBBELL_PRESS': '04797c93-3325-4f79-9d30-7d56348796ca',
  'CRUNCHES': '87680ca6-38b0-4db1-9460-244c883816a0',
  'PLANK': '21c37b13-51b8-4590-bf7b-4ec9a45d53a7',
  'LUNGES': '611a0d2a-eee4-41bf-8371-5899e1d64f26',
  'STANDING_CALF_RAISES': 'd9850407-2961-4932-bd1b-679ccd3de7e2',
  'STIFF_LEG_DEADLIFT': '99148772-f963-47bc-8657-087f1b468a71',
};

const apiKey = 'WORKOUT_API_KEY';

Future<void> main() async {
  print('🚀 Téléchargement TOP 20 exercices images...\n');
  
  final outputDir = Directory('assets/exercise_images');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
    print('📁 Dossier créé: ${outputDir.path}\n');
  }
  
  final manifest = {
    'preseeded_exercises': <Map<String, String>>[],
  };
  
  int successCount = 0;
  int errorCount = 0;
  
  for (var entry in top20Ids.entries) {
    final code = entry.key;
    final id = entry.value;
    final filename = '${code.toLowerCase()}.svg';
    final filepath = '${outputDir.path}/$filename';
    
    print('📥 Downloading $code ($id)...');
    
    try {
      final response = await http.get(
        Uri.parse('https://api.workoutapi.com/exercises/$id/image'),
        headers: {
          'x-api-key': apiKey,
          'Accept': 'image/svg+xml',
        },
      );
      
      if (response.statusCode == 200) {
        await File(filepath).writeAsBytes(response.bodyBytes);
        print('   ✅ Saved to $filename (${(response.bodyBytes.length / 1024).toStringAsFixed(1)} KB)');
        
        manifest['preseeded_exercises']!.add({
          'id': id,
          'code': code,
          'filename': filename,
        });
        
        successCount++;
      } else {
        print('   ⚠️ Error ${response.statusCode}: ${response.body}');
        errorCount++;
      }
      
      // Rate limiting: attendre 500ms entre requêtes
      await Future.delayed(Duration(milliseconds: 500));
    } catch (e) {
      print('   ❌ Exception: $e');
      errorCount++;
    }
  }
  
  // Sauvegarder manifest
  final manifestFile = File('${outputDir.path}/manifest.json');
  await manifestFile.writeAsString(
    JsonEncoder.withIndent('  ').convert(manifest),
  );
  
  print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('🎉 Téléchargement terminé!');
  print('   ✅ Succès: $successCount');
  print('   ❌ Erreurs: $errorCount');
  print('   📄 Manifest: ${manifestFile.path}');
  print('\n💰 Quota API consommé: $successCount requêtes');
  print('   Restant: ${100 - 1 - successCount}/100');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}
