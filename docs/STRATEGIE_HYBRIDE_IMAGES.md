# STRATÉGIE HYBRIDE: Pre-seed + Lazy Loading Images

**Version:** 2.0 (Cache Local)  
**Date:** 2026-02-17  
**Type:** Optimisation Quota API + Performance

---

## VUE D'ENSEMBLE STRATÉGIE

### Principe Hybride

**Phase 1 - Pre-seed (Setup):** Télécharger TOP 20 exercices populaires → Embarquer dans assets app  
**Phase 2 - Lazy Loading (Runtime):** Télécharger autres exercices à la demande → Cache local automatique

### Avantages

✅ **Performance:** Top 20 exercices = chargement instantané (0 requête API)  
✅ **Quota optimisé:** 20 requêtes setup + ~10-15 lazy loading/user = 30-35 total max  
✅ **Offline-first:** Top 20 toujours disponibles hors ligne  
✅ **Simplicité:** Pas de Firebase Storage, juste `cached_network_image`  
✅ **UX:** Exercices populaires = zéro latence

---

## TOP 20 EXERCICES À PRE-SEED

### Liste Sélectionnée

Basée sur exercices les plus pratiqués en musculation:

| # | Nom Français | Code API | ID API |
|---|--------------|----------|--------|
| 1 | Développé couché à la barre | BARBELL_BENCH_PRESS | *(depuis JSON)* |
| 2 | Squat (Presse à cuisses) | LEG_PRESS | *(depuis JSON)* |
| 3 | Soulevé de terre | DEADLIFT | *(depuis JSON)* |
| 4 | Développé militaire barre | BARBELL_SHOULDER_PRESS | *(depuis JSON)* |
| 5 | Tractions pronation | PRONATED_GRIP_PULL_UPS | *(depuis JSON)* |
| 6 | Tractions supination | SUPINATED_GRIP_PULL_UPS | *(depuis JSON)* |
| 7 | Dips | DIPS | *(depuis JSON)* |
| 8 | Curl barre | BARBELL_CURL | *(depuis JSON)* |
| 9 | Développé incliné barre | INCLINE_BARBELL_BENCH_PRESS | *(depuis JSON)* |
| 10 | Rowing haltères | BENT_OVER_DUMBBELL_ROW | *(depuis JSON)* |
| 11 | Leg curl | LEG_CURL | *(depuis JSON)* |
| 12 | Extension jambes | LEG_EXTENSION | *(depuis JSON)* |
| 13 | Élévations latérales haltères | LATERAL_RAISE_WITH_DUMBBELLS | *(depuis JSON)* |
| 14 | Crunchs | CRUNCHES | *(depuis JSON)* |
| 15 | Planche | PLANK | *(depuis JSON)* |
| 16 | Fentes | LUNGES | *(depuis JSON)* |
| 17 | Développé Arnold | ARNOLD_DUMBBELL_PRESS | *(depuis JSON)* |
| 18 | Soulevé de terre jambes tendues | STIFF_LEG_DEADLIFT | *(depuis JSON)* |
| 19 | Élévations mollets debout | STANDING_CALF_RAISES | *(depuis JSON)* |
| 20 | Développé décliné barre | DECLINE_BARBELL_BENCH_PRESS | *(depuis JSON)* |

---

## ARCHITECTURE TECHNIQUE

### Structure Assets

```
apollon/
  ├── assets/
  │   └── exercise_images/
  │       ├── manifest.json                    # Mapping ID → filename
  │       ├── barbell_bench_press.jpg
  │       ├── leg_press.jpg
  │       ├── deadlift.jpg
  │       ├── barbell_shoulder_press.jpg
  │       ├── pronated_grip_pull_ups.jpg
  │       ├── supinated_grip_pull_ups.jpg
  │       ├── dips.jpg
  │       ├── barbell_curl.jpg
  │       ├── incline_barbell_bench_press.jpg
  │       ├── bent_over_dumbbell_row.jpg
  │       ├── leg_curl.jpg
  │       ├── leg_extension.jpg
  │       ├── lateral_raise_dumbbells.jpg
  │       ├── crunches.jpg
  │       ├── plank.jpg
  │       ├── lunges.jpg
  │       ├── arnold_dumbbell_press.jpg
  │       ├── stiff_leg_deadlift.jpg
  │       ├── standing_calf_raises.jpg
  │       └── decline_barbell_bench_press.jpg
```

### Manifest JSON

**Fichier:** `assets/exercise_images/manifest.json`

```json
{
  "preseeded_exercises": [
    {
      "id": "abc123...",
      "code": "BARBELL_BENCH_PRESS",
      "filename": "barbell_bench_press.jpg"
    },
    {
      "id": "def456...",
      "code": "LEG_PRESS",
      "filename": "leg_press.jpg"
    }
    // ... 18 autres
  ]
}
```

### Data Flow

```
User sélectionne exercice
       ↓
Repository.getImageProvider(exerciseId)
       ↓
[ID dans manifest.json?]
       ├─ OUI → AssetImage('assets/exercise_images/{filename}')
       │        └─> Chargement instantané (0 requête API) ⚡
       │
       └─ NON → CachedNetworkImageProvider(apiUrl)
                ├─> [Image en cache local?]
                │   ├─ OUI → Chargement instantané (0 requête API) ⚡
                │   └─ NON → Télécharge depuis API (1 requête)
                │            └─> Cache automatiquement pour toujours 💾
```

---

## IMPLÉMENTATION

### Phase 0: Setup Pre-seed (One-time, 20 requêtes API)

#### Script Téléchargement Images

**Fichier:** `scripts/download_top20_images.dart`

```dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// IDs des top 20 exercices (depuis workout_api_exercises_fr.json)
const top20Ids = {
  'BARBELL_BENCH_PRESS': 'e51e9549-d9b7-463e-a8e2-19b3d00ee8af',
  'LEG_PRESS': 'f1234567-1234-1234-1234-123456789012',
  'DEADLIFT': 'g2345678-2345-2345-2345-234567890123',
  'BARBELL_SHOULDER_PRESS': 'h3456789-3456-3456-3456-345678901234',
  'PRONATED_GRIP_PULL_UPS': 'i4567890-4567-4567-4567-456789012345',
  'SUPINATED_GRIP_PULL_UPS': 'j5678901-5678-5678-5678-567890123456',
  'DIPS': 'k6789012-6789-6789-6789-678901234567',
  'BARBELL_CURL': 'l7890123-7890-7890-7890-789012345678',
  'INCLINE_BARBELL_BENCH_PRESS': 'm8901234-8901-8901-8901-890123456789',
  'BENT_OVER_DUMBBELL_ROW': 'n9012345-9012-9012-9012-901234567890',
  'LEG_CURL': 'o0123456-0123-0123-0123-012345678901',
  'LEG_EXTENSION': 'p1234567-1234-1234-1234-123456789012',
  'LATERAL_RAISE_WITH_DUMBBELLS': 'q2345678-2345-2345-2345-234567890123',
  'CRUNCHES': 'r3456789-3456-3456-3456-345678901234',
  'PLANK': 's4567890-4567-4567-4567-456789012345',
  'LUNGES': 't5678901-5678-5678-5678-567890123456',
  'ARNOLD_DUMBBELL_PRESS': 'u6789012-6789-6789-6789-678901234567',
  'STIFF_LEG_DEADLIFT': 'v7890123-7890-7890-7890-789012345678',
  'STANDING_CALF_RAISES': 'w8901234-8901-8901-8901-890123456789',
  'DECLINE_BARBELL_BENCH_PRESS': 'x9012345-9012-9012-9012-901234567890',
};

const apiKey = 'WORKOUT_API_KEY';

Future<void> main() async {
  print('🚀 Téléchargement TOP 20 exercices images...\n');
  
  final outputDir = Directory('assets/exercise_images');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }
  
  final manifest = {
    'preseeded_exercises': <Map<String, String>>[],
  };
  
  int successCount = 0;
  int errorCount = 0;
  
  for (var entry in top20Ids.entries) {
    final code = entry.key;
    final id = entry.value;
    final filename = '${code.toLowerCase()}.jpg';
    final filepath = '${outputDir.path}/$filename';
    
    print('📥 Downloading $code ($id)...');
    
    try {
      final response = await http.get(
        Uri.parse('https://api.workoutapi.com/exercises/$id/visual'),
        headers: {'X-API-Key': apiKey},
      );
      
      if (response.statusCode == 200) {
        await File(filepath).writeAsBytes(response.bodyBytes);
        print('   ✅ Saved to $filename');
        
        manifest['preseeded_exercises']!.add({
          'id': id,
          'code': code,
          'filename': filename,
        });
        
        successCount++;
      } else {
        print('   ⚠️ Error ${response.statusCode}');
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
  
  print('\n🎉 Téléchargement terminé!');
  print('   ✅ Succès: $successCount');
  print('   ❌ Erreurs: $errorCount');
  print('   📄 Manifest: ${manifestFile.path}');
  print('\n💰 Quota API consommé: $successCount requêtes');
  print('   Restant: ${100 - 1 - successCount}/100');  // -1 pour récupération liste initiale
}
```

**Exécution:**

```bash
# Installer http si nécessaire
flutter pub add http

# Lancer script
dart scripts/download_top20_images.dart

# Résultat attendu:
# - 20 images JPG dans assets/exercise_images/
# - 1 fichier manifest.json
# - Quota: 21 requêtes consommées (1 liste + 20 images)
```

#### Déclarer Assets dans pubspec.yaml

```yaml
flutter:
  assets:
    - assets/exercise_images/
    - assets/exercise_images/manifest.json
```

---

### Phase 1: Modèle Manifest

**Fichier:** `lib/features/exercises/domain/models/exercise_image_manifest.dart`

```dart
import 'dart:convert';
import 'package:flutter/services.dart';

class ExerciseImageManifest {
  final Map<String, String> _idToFilename = {};
  
  ExerciseImageManifest._();
  
  static Future<ExerciseImageManifest> load() async {
    final manifest = ExerciseImageManifest._();
    
    try {
      final jsonString = await rootBundle.loadString(
        'assets/exercise_images/manifest.json',
      );
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final exercises = data['preseeded_exercises'] as List<dynamic>;
      
      for (var exercise in exercises) {
        final id = exercise['id'] as String;
        final filename = exercise['filename'] as String;
        manifest._idToFilename[id] = filename;
      }
      
      print('✅ Manifest loaded: ${manifest._idToFilename.length} preseeded images');
    } catch (e) {
      print('⚠️ Error loading manifest: $e');
    }
    
    return manifest;
  }
  
  /// Check si exercice a image pré-embarquée
  bool hasPreseededImage(String exerciseId) {
    return _idToFilename.containsKey(exerciseId);
  }
  
  /// Get asset path pour exercice
  String? getAssetPath(String exerciseId) {
    final filename = _idToFilename[exerciseId];
    return filename != null ? 'assets/exercise_images/$filename' : null;
  }
  
  /// Get tous les IDs pré-seedés
  List<String> get preseededIds => _idToFilename.keys.toList();
}
```

---

### Phase 2: Repository avec Stratégie Hybride

**Fichier:** `lib/features/exercises/data/repositories/exercise_library_repository.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ExerciseLibraryRepository {
  final FirebaseFirestore _firestore;
  final ExerciseImageManifest _manifest;
  final String _apiKey;
  
  // Cache mémoire
  List<ExerciseLibrary>? _cachedExercises;
  
  ExerciseLibraryRepository({
    required FirebaseFirestore firestore,
    required ExerciseImageManifest manifest,
    required String apiKey,
  })  : _firestore = firestore,
        _manifest = manifest,
        _apiKey = apiKey;
  
  /// Récupérer tous les exercices
  Future<List<ExerciseLibrary>> getAll() async {
    if (_cachedExercises != null) return _cachedExercises!;
    
    final snapshot = await _firestore
        .collection('exercises_library')
        .orderBy('name')
        .get();
    
    _cachedExercises = snapshot.docs
        .map((doc) => ExerciseLibrary.fromFirestore(doc.data()))
        .toList();
    
    return _cachedExercises!;
  }
  
  /// Get ImageProvider pour un exercice (hybride)
  ImageProvider getImageProvider(String exerciseId) {
    // Strategy 1: Check assets pré-seedés
    if (_manifest.hasPreseededImage(exerciseId)) {
      final assetPath = _manifest.getAssetPath(exerciseId)!;
      return AssetImage(assetPath);
    }
    
    // Strategy 2: Lazy load depuis API avec cache
    return CachedNetworkImageProvider(
      'https://api.workoutapi.com/exercises/$exerciseId/visual',
      headers: {'X-API-Key': _apiKey},
    );
  }
  
  /// Check si exercice a image disponible (local ou remote)
  bool hasImage(String exerciseId) {
    return _manifest.hasPreseededImage(exerciseId) || true; // API peut toujours fournir
  }
  
  /// Statistiques
  Map<String, int> getImageStats() {
    return {
      'preseeded': _manifest.preseededIds.length,
      'total_exercises': _cachedExercises?.length ?? 0,
    };
  }
  
  // ... autres méthodes (search, filter, etc.) identiques au brief précédent
}
```

---

### Phase 3: Widget Image Optimisé

**Fichier:** `lib/features/exercises/widgets/exercise_image_widget.dart`

```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

class ExerciseImageWidget extends StatelessWidget {
  final String exerciseId;
  final double size;
  final BoxFit fit;
  
  const ExerciseImageWidget({
    Key? key,
    required this.exerciseId,
    this.size = 50,
    this.fit = BoxFit.cover,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final repository = context.read<ExerciseLibraryRepository>();
    final imageProvider = repository.getImageProvider(exerciseId);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: imageProvider,
          fit: fit,
        ),
      ),
      child: imageProvider is CachedNetworkImageProvider
          ? _buildNetworkImageOverlay()
          : null, // AssetImage → pas de loader nécessaire
    );
  }
  
  Widget _buildNetworkImageOverlay() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: '', // URL déjà fournie via provider
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
          child: Center(
            child: SizedBox(
              width: size * 0.4,
              height: size * 0.4,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: Icon(
            Icons.fitness_center,
            size: size * 0.5,
            color: Colors.grey[400],
          ),
        ),
      ),
    );
  }
}

// Version simplifiée pour ListTile
class ExerciseImageAvatar extends StatelessWidget {
  final String exerciseId;
  
  const ExerciseImageAvatar({Key? key, required this.exerciseId}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final repository = context.read<ExerciseLibraryRepository>();
    final imageProvider = repository.getImageProvider(exerciseId);
    
    return CircleAvatar(
      radius: 25,
      backgroundImage: imageProvider,
      backgroundColor: Colors.grey[200],
      child: imageProvider is CachedNetworkImageProvider
          ? Icon(Icons.fitness_center, color: Colors.grey[400])
          : null,
    );
  }
}
```

---

### Phase 4: Initialisation App

**Fichier:** `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Firebase
  await Firebase.initializeApp();
  
  // 2. Environment variables (API key)
  await dotenv.load(fileName: ".env");
  
  // 3. Charger manifest images
  final manifest = await ExerciseImageManifest.load();
  
  runApp(MyApp(manifest: manifest));
}

class MyApp extends StatelessWidget {
  final ExerciseImageManifest manifest;
  
  const MyApp({required this.manifest});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repository
        Provider<ExerciseLibraryRepository>(
          create: (_) => ExerciseLibraryRepository(
            firestore: FirebaseFirestore.instance,
            manifest: manifest,
            apiKey: dotenv.env['WORKOUT_API_KEY'] ?? '',
          ),
        ),
        
        // Provider
        ChangeNotifierProvider<ExerciseLibraryProvider>(
          create: (context) => ExerciseLibraryProvider(
            context.read<ExerciseLibraryRepository>(),
          )..loadExercises(),
        ),
        
        // ... autres providers
      ],
      child: MaterialApp(
        title: 'Apollon',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: HomeScreen(),
      ),
    );
  }
}
```

---

## QUOTA API - ANALYSE DÉTAILLÉE

### Consommation Répartie

| Phase | Action | Requêtes | Cumulé |
|-------|--------|----------|--------|
| **Setup Initial** | Téléchargement liste exercices | 1 | 1 |
| **Setup Pre-seed** | Téléchargement top 20 images | 20 | 21 |
| **User 1** | Lazy loading ~15 exercices uniques | 15 | 36 |
| **User 2** | Lazy loading ~12 exercices uniques | 12 | 48 |
| **User 3** | Lazy loading ~10 exercices uniques | 10 | 58 |
| **User 4** | Lazy loading ~8 exercices uniques | 8 | 66 |
| **...** | ... | ... | ... |

**Conclusion:** Avec top 20 pre-seeded, tu supportes **4-5 users** avant d'atteindre quota.

### Optimisations Possibles

Si quota devient problème en production:

1. **Augmenter pre-seed à 30-40 exercices** (coût: +10-20 requêtes setup)
2. **Plan payant API** (vérifier pricing)
3. **Alternative images:** Scraper one-time ou stock photos

---

## TESTS

### Test 1: Images Pre-seeded

```dart
void testPreseededImages() async {
  final manifest = await ExerciseImageManifest.load();
  
  // Vérifier 20 exercices pré-seedés
  assert(manifest.preseededIds.length == 20);
  
  // Vérifier assets existent
  final assetPath = manifest.getAssetPath(manifest.preseededIds.first)!;
  final image = AssetImage(assetPath);
  // Image doit charger instantanément
}
```

### Test 2: Lazy Loading

```dart
void testLazyLoading() async {
  final repository = ExerciseLibraryRepository(...);
  
  // Exercice NON pré-seedé
  final randomExerciseId = 'abc123-not-in-top20';
  final imageProvider = repository.getImageProvider(randomExerciseId);
  
  // Doit être CachedNetworkImageProvider
  assert(imageProvider is CachedNetworkImageProvider);
}
```

### Test 3: Fallback

```dart
// Si API key invalide ou quota épuisé
// Widget doit afficher icône placeholder (pas de crash)
```

---

## MIGRATION DEPUIS ANCIENS BRIEFS

### Changements vs Brief Précédent

**❌ SUPPRIMER:**
- Firebase Storage configuration
- Storage Rules
- `_downloadAndCacheImage()` dans Repository
- Upload logic vers Storage

**✅ CONSERVER:**
- Import Firestore (exercices texte)
- Modèles Dart
- Provider state management
- UI screens & widgets

**✅ AJOUTER:**
- Script `download_top20_images.dart`
- Manifest JSON + modèle
- Assets declaration
- Stratégie hybride dans Repository

---

## CHECKLIST IMPLÉMENTATION

### Setup (One-time)

- [ ] Exécuter `dart scripts/download_top20_images.dart` (20 requêtes API)
- [ ] Vérifier 20 images JPG dans `assets/exercise_images/`
- [ ] Vérifier `manifest.json` créé
- [ ] Déclarer assets dans `pubspec.yaml`

### Code

- [ ] Créer modèle `ExerciseImageManifest`
- [ ] Adapter `ExerciseLibraryRepository` (méthode `getImageProvider`)
- [ ] Créer widget `ExerciseImageWidget`
- [ ] Charger manifest dans `main.dart`
- [ ] Tester pre-seed fonctionne (top 20)
- [ ] Tester lazy loading fonctionne (autres exercices)

### Validation

- [ ] Top 20 exercices → Chargement instantané
- [ ] Autres exercices → Loader puis cache
- [ ] Mode offline → Top 20 disponibles
- [ ] Quota API → Max 21 + (users × 10-15)

---

## RÉSUMÉ AVANTAGES

| Critère | Stratégie | Résultat |
|---------|-----------|----------|
| **Performance** | Top 20 pre-seeded | ⚡ Instantané (0ms) |
| **Quota** | Hybride | 🎯 Optimisé (21 + lazy) |
| **Offline** | Assets locaux | ✅ Top 20 toujours dispos |
| **Complexité** | Pas Firebase Storage | 🟢 Simple |
| **Coût** | Zéro Firebase | 💰 Gratuit |
| **UX** | Exercices populaires rapides | ⭐ Excellent |

---

**Auteur:** Apollon Project Assistant  
**Date:** 2026-02-17  
**Version:** 2.0 - Stratégie Hybride  
**Quota Consommé:** 1/100 (liste initiale)  
**Quota à Consommer:** 20/100 (setup pre-seed)  
**Quota Restant:** 79/100 (pour lazy loading)
