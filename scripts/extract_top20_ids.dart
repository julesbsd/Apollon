import 'dart:convert';
import 'dart:io';

void main() async {
  // Lire JSON exercices
  final file = File('docs/workout_api_exercises_fr.json');
  final jsonString = await file.readAsString();
  final List<dynamic> exercises = jsonDecode(jsonString);
  
  // Codes recherchés (exercices les plus courants)
  final searchCodes = [
    'BARBELL_BENCH_PRESS',
    'LEG_PRESS',
    'DEADLIFT',
    'BARBELL_SHOULDER_PRESS',
    'PRONATED_GRIP_PULL_UPS',
    'SUPINATED_GRIP_PULL_UPS',
    'DIPS',
    'BARBELL_CURL',
    'INCLINE_BARBELL_BENCH_PRESS',
    'BENT_OVER_DUMBBELL_ROW',
    'LEG_CURL',
    'LEG_EXTENSION',
    'LATERAL_RAISE',
    'CRUNCHES',
    'PLANK',
    'LUNGES',
    'ARNOLD',
    'STIFF_LEG_DEADLIFT',
    'STANDING_CALF_RAISES',
    'DECLINE_BARBELL_BENCH_PRESS',
  ];
  
  print('const top20Ids = {');
  
  int found = 0;
  for (var exercise in exercises) {
    final code = exercise['code'] as String;
    final id = exercise['id'] as String;
    final name = exercise['name'] as String;
    
    // Check si code match un des exercices recherchés
    if (searchCodes.any((search) => code.contains(search))) {
      print("  '$code': '$id', // $name");
      found++;
    }
  }
  
  print('};');
  print('\n// Total trouvés: $found exercices');
}
