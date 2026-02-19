# BRIEF TECHNIQUE: Intégration Workout API - Stratégie Hybride Images

**Version:** 2.0 (Cache Local)  
**Date:** 2026-02-17  
**Destinataire:** Flutter Developer Expert  
**Priorité:** Haute  
**Estimation:** 12-16 heures

---

## RÉSUMÉ EXÉCUTIF

Intégrer catalogue de **94 exercices** avec système **hybride images:**
- **Top 20 exercices populaires:** Pre-seed dans assets (images embarquées)
- **74 autres exercices:** Lazy loading avec cache local automatique

**Objectif:** Optimiser quota API (100 requêtes) + performance maximale pour exercices populaires.

---

## DOCUMENTS RÉFÉRENCE

**Lire obligatoirement:**
- ✅ `docs/STRATEGIE_HYBRIDE_IMAGES.md` - Architecture complète
- ✅ `docs/workout_api_exercises_fr.json` - 94 exercices téléchargés

---

## PLAN D'IMPLÉMENTATION

### PHASE 0: Setup Pre-seed Images (2-3h)

#### 0.1 Extraire IDs Top 20

**Fichier temporaire:** `scripts/extract_top20_ids.dart`

```dart
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
  
  for (var exercise in exercises) {
    final code = exercise['code'] as String;
    final id = exercise['id'] as String;
    final name = exercise['name'] as String;
    
    // Check si code match un des exercices recherchés
    if (searchCodes.any((search) => code.contains(search))) {
      print("  '$code': '$id', // $name");
    }
  }
  
  print('};');
}
```

**Exécution:**
```bash
dart scripts/extract_top20_ids.dart > scripts/top20_ids.txt
# Copier les IDs dans script suivant
```

#### 0.2 Télécharger Images Top 20

**Fichier:** `scripts/download_top20_images.dart`

**(Code complet dans `STRATEGIE_HYBRIDE_IMAGES.md`)**

**Résumé:**
- Télécharge 20 images depuis `https://api.workoutapi.com/exercises/{id}/visual`
- Sauvegarde dans `assets/exercise_images/{code}.jpg`
- Génère `manifest.json` avec mapping ID → filename
- **Coût:** 20 requêtes API

**Exécution:**
```bash
flutter pub add http
dart scripts/download_top20_images.dart

# Vérification
ls assets/exercise_images/  # 20 JPG + manifest.json
```

#### 0.3 Déclarer Assets

**Modifier:** `pubspec.yaml`

```yaml
flutter:
  assets:
    - assets/exercise_images/
```

---

### PHASE 1: Import Exercices Firestore (1h)

**Script:** `scripts/import_exercises_to_firestore.dart`

**(Identique au brief v1.0, pas de changement)**

```dart
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  await Firebase.initializeApp();
  
  final file = File('docs/workout_api_exercises_fr.json');
  final jsonString = await file.readAsString();
  final List<dynamic> exercises = jsonDecode(jsonString);
  
  final firestore = FirebaseFirestore.instance;
  final collection = firestore.collection('exercises_library');
  
  WriteBatch batch = firestore.batch();
  int count = 0;
  
  for (var exerciseJson in exercises) {
    final data = {
      'id': exerciseJson['id'],
      'code': exerciseJson['code'],
      'name': exerciseJson['name'],
      'description': exerciseJson['description'] ?? '',
      'primaryMuscles': exerciseJson['primaryMuscles'] ?? [],
      'secondaryMuscles': exerciseJson['secondaryMuscles'] ?? [],
      'types': exerciseJson['types'] ?? [],
      'categories': exerciseJson['categories'] ?? [],
      'syncedAt': FieldValue.serverTimestamp(),
      'source': 'workout-api',
    };
    
    final docRef = collection.doc(exerciseJson['id']);
    batch.set(docRef, data);
    
    count++;
    if (count % 500 == 0) {
      await batch.commit();
      batch = firestore.batch();
      print('✅ Imported $count exercises...');
    }
  }
  
  await batch.commit();
  print('🎉 Total: $count exercises imported');
}
```

**Exécution:**
```bash
dart scripts/import_exercises_to_firestore.dart
```

---

### PHASE 2: Modèles Dart (2h)

#### 2.1 Modèle ExerciseLibrary

**Fichier:** `lib/features/exercises/domain/models/exercise_library.dart`

**(Code complet dans brief v1.0, identique)**

**Classes:**
- `ExerciseLibrary`
- `MuscleInfo`
- `TypeInfo`
- `CategoryInfo`

#### 2.2 Modèle Manifest

**Fichier:** `lib/features/exercises/domain/models/exercise_image_manifest.dart`

```dart
import 'dart:convert';
import 'package:flutter/services.dart';

class ExerciseImageManifest {
  final Map<String, String> _idToFilename = {};
  
  ExerciseImageManifest._();
  
  /// Charger manifest depuis assets
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
  
  /// Check si exercice a image embarquée
  bool hasPreseededImage(String exerciseId) {
    return _idToFilename.containsKey(exerciseId);
  }
  
  /// Get chemin asset
  String? getAssetPath(String exerciseId) {
    final filename = _idToFilename[exerciseId];
    return filename != null ? 'assets/exercise_images/$filename' : null;
  }
  
  /// Liste IDs pré-seedés
  List<String> get preseededIds => _idToFilename.keys.toList();
}
```

---

### PHASE 3: Repository avec Stratégie Hybride (3h)

**Fichier:** `lib/features/exercises/data/repositories/exercise_library_repository.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ExerciseLibraryRepository {
  final FirebaseFirestore _firestore;
  final ExerciseImageManifest _manifest;
  final String _apiKey;
  
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
  
  /// Recherche textuelle
  Future<List<ExerciseLibrary>> search(String query) async {
    final all = await getAll();
    if (query.trim().isEmpty) return all;
    
    final lower = query.toLowerCase();
    return all.where((ex) =>
      ex.name.toLowerCase().contains(lower) ||
      ex.description.toLowerCase().contains(lower)
    ).toList();
  }
  
  /// Filtrer par muscle
  Future<List<ExerciseLibrary>> filterByMuscle(String muscleCode) async {
    final all = await getAll();
    return all.where((ex) =>
      ex.primaryMuscles.any((m) => m.code == muscleCode)
    ).toList();
  }
  
  /// Filtrer par catégorie
  Future<List<ExerciseLibrary>> filterByCategory(String categoryCode) async {
    final all = await getAll();
    return all.where((ex) =>
      ex.categories.any((c) => c.code == categoryCode)
    ).toList();
  }
  
  /// 🔑 MÉTHODE CLÉ: Get ImageProvider (stratégie hybride)
  ImageProvider getImageProvider(String exerciseId) {
    // Strategy 1: Asset pré-seedé (top 20)
    if (_manifest.hasPreseededImage(exerciseId)) {
      final assetPath = _manifest.getAssetPath(exerciseId)!;
      return AssetImage(assetPath);
    }
    
    // Strategy 2: Lazy load depuis API avec cache automatique
    return CachedNetworkImageProvider(
      'https://api.workoutapi.com/exercises/$exerciseId/visual',
      headers: {'X-API-Key': _apiKey},
    );
  }
  
  /// Check si image disponible
  bool hasImage(String exerciseId) => true; // Toujours true (assets ou API)
  
  /// Statistiques
  Map<String, dynamic> getStats() {
    return {
      'total_exercises': _cachedExercises?.length ?? 0,
      'preseeded_images': _manifest.preseededIds.length,
    };
  }
  
  /// Invalider cache
  void clearCache() {
    _cachedExercises = null;
  }
}
```

---

### PHASE 4: Widget Image (1-2h)

**Fichier:** `lib/features/exercises/widgets/exercise_image_widget.dart`

```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

/// Widget image exercice avec stratégie hybride
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
    
    // Si AssetImage → chargement instantané, pas de loader
    if (imageProvider is AssetImage) {
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
      );
    }
    
    // Si CachedNetworkImageProvider → avec loader
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: 'https://api.workoutapi.com/exercises/$exerciseId/visual',
        httpHeaders: {'X-API-Key': context.read<String>()}, // API key from provider
        width: size,
        height: size,
        fit: fit,
        placeholder: (context, url) => Container(
          width: size,
          height: size,
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
          width: size,
          height: size,
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

/// Variante pour ListTile (avatar circulaire)
class ExerciseImageAvatar extends StatelessWidget {
  final String exerciseId;
  final double radius;
  
  const ExerciseImageAvatar({
    Key? key,
    required this.exerciseId,
    this.radius = 25,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final repository = context.read<ExerciseLibraryRepository>();
    final imageProvider = repository.getImageProvider(exerciseId);
    
    return CircleAvatar(
      radius: radius,
      backgroundImage: imageProvider,
      backgroundColor: Colors.grey[200],
    );
  }
}
```

---

### PHASE 5: Provider (2h)

**Fichier:** `lib/features/exercises/providers/exercise_library_provider.dart`

**(Identique au brief v1.0, pas de changement dans la logique filtres)**

```dart
import 'package:flutter/foundation.dart';

class ExerciseLibraryProvider extends ChangeNotifier {
  final ExerciseLibraryRepository _repository;
  
  List<ExerciseLibrary> _allExercises = [];
  List<ExerciseLibrary> _filteredExercises = [];
  bool _isLoading = false;
  String? _error;
  
  String _searchQuery = '';
  String? _selectedMuscleCode;
  String? _selectedCategoryCode;
  
  ExerciseLibraryProvider(this._repository);
  
  // Getters
  List<ExerciseLibrary> get exercises => _filteredExercises;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Charger exercices
  Future<void> loadExercises() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _allExercises = await _repository.getAll();
      _applyFilters();
    } catch (e) {
      _error = 'Erreur chargement: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Rechercher
  void search(String query) {
    _searchQuery = query;
    _applyFilters();
  }
  
  /// Filtrer par muscle
  void filterByMuscle(String? muscleCode) {
    _selectedMuscleCode = muscleCode;
    _applyFilters();
  }
  
  /// Filtrer par catégorie
  void filterByCategory(String? categoryCode) {
    _selectedCategoryCode = categoryCode;
    _applyFilters();
  }
  
  /// Reset
  void clearFilters() {
    _searchQuery = '';
    _selectedMuscleCode = null;
    _selectedCategoryCode = null;
    _applyFilters();
  }
  
  /// Appliquer filtres
  void _applyFilters() {
    _filteredExercises = _allExercises;
    
    if (_searchQuery.isNotEmpty) {
      final lower = _searchQuery.toLowerCase();
      _filteredExercises = _filteredExercises.where((ex) =>
        ex.name.toLowerCase().contains(lower) ||
        ex.description.toLowerCase().contains(lower)
      ).toList();
    }
    
    if (_selectedMuscleCode != null) {
      _filteredExercises = _filteredExercises.where((ex) =>
        ex.primaryMuscles.any((m) => m.code == _selectedMuscleCode)
      ).toList();
    }
    
    if (_selectedCategoryCode != null) {
      _filteredExercises = _filteredExercises.where((ex) =>
        ex.categories.any((c) => c.code == _selectedCategoryCode)
      ).toList();
    }
    
    notifyListeners();
  }
  
  /// Get muscles disponibles
  List<MuscleInfo> get availableMuscles {
    final musclesMap = <String, MuscleInfo>{};
    for (var ex in _allExercises) {
      for (var muscle in ex.primaryMuscles) {
        musclesMap[muscle.code] = muscle;
      }
    }
    return musclesMap.values.toList();
  }
  
  /// Get catégories disponibles
  List<CategoryInfo> get availableCategories {
    final categoriesMap = <String, CategoryInfo>{};
    for (var ex in _allExercises) {
      for (var category in ex.categories) {
        categoriesMap[category.code] = category;
      }
    }
    return categoriesMap.values.toList();
  }
}
```

---

### PHASE 6: Initialisation App (1h)

**Fichier:** `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Firebase
  await Firebase.initializeApp();
  
  // 2. Environment variables
  await dotenv.load(fileName: ".env");
  final apiKey = dotenv.env['WORKOUT_API_KEY'] ?? '';
  
  // 3. Charger manifest images
  final manifest = await ExerciseImageManifest.load();
  
  runApp(MyApp(
    apiKey: apiKey,
    manifest: manifest,
  ));
}

class MyApp extends StatelessWidget {
  final String apiKey;
  final ExerciseImageManifest manifest;
  
  const MyApp({
    required this.apiKey,
    required this.manifest,
  });
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // API Key accessible partout
        Provider<String>.value(value: apiKey),
        
        // Repository
        Provider<ExerciseLibraryRepository>(
          create: (_) => ExerciseLibraryRepository(
            firestore: FirebaseFirestore.instance,
            manifest: manifest,
            apiKey: apiKey,
          ),
        ),
        
        // Provider
        ChangeNotifierProvider<ExerciseLibraryProvider>(
          create: (context) => ExerciseLibraryProvider(
            context.read<ExerciseLibraryRepository>(),
          )..loadExercises(),
        ),
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

### PHASE 7: UI Écran Sélection (2-3h)

**Fichier:** `lib/features/exercises/screens/exercise_selection_screen.dart`

```dart
class ExerciseSelectionScreen extends StatefulWidget {
  @override
  _ExerciseSelectionScreenState createState() => _ExerciseSelectionScreenState();
}

class _ExerciseSelectionScreenState extends State<ExerciseSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExerciseLibraryProvider>().loadExercises();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sélectionner un exercice'),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilters(),
          Expanded(child: _buildExerciseList()),
        ],
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher un exercice...',
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (query) {
          context.read<ExerciseLibraryProvider>().search(query);
        },
      ),
    );
  }
  
  Widget _buildFilters() {
    // TODO: Chips filtres muscles/catégories
    return SizedBox.shrink();
  }
  
  Widget _buildExerciseList() {
    return Consumer<ExerciseLibraryProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (provider.error != null) {
          return Center(child: Text(provider.error!));
        }
        
        final exercises = provider.exercises;
        
        if (exercises.isEmpty) {
          return Center(child: Text('Aucun exercice trouvé'));
        }
        
        return ListView.builder(
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            return ExerciseLibraryTile(exercise: exercise);
          },
        );
      },
    );
  }
}

class ExerciseLibraryTile extends StatelessWidget {
  final ExerciseLibrary exercise;
  
  const ExerciseLibraryTile({required this.exercise});
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ExerciseImageAvatar(exerciseId: exercise.id),
      title: Text(exercise.name),
      subtitle: Text(
        exercise.primaryMuscles.map((m) => m.name).join(', '),
      ),
      trailing: Icon(Icons.chevron_right),
      onTap: () => Navigator.pop(context, exercise),
    );
  }
}
```

---

## DEPENDENCIES

**Ajouter à `pubspec.yaml`:**

```yaml
dependencies:
  # Firebase
  firebase_core: ^2.24.0
  cloud_firestore: ^4.13.0
  
  # State
  provider: ^6.1.0
  
  # Images
  cached_network_image: ^3.3.0
  
  # HTTP & Env
  http: ^1.1.0
  flutter_dotenv: ^5.1.0
```

---

## CONFIGURATION

### Environment Variables

**Créer:** `.env` (ajouter à `.gitignore`)

```
WORKOUT_API_KEY=WORKOUT_API_KEY
```

### Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /exercises_library/{exerciseId} {
      allow read: if request.auth != null;
      allow write: if false;
    }
  }
}
```

---

## TESTS & VALIDATION

### Checklist Fonctionnel

- [ ] 94 exercices visibles dans app
- [ ] Recherche "développé" retourne résultats
- [ ] Filtre "Pectoraux" fonctionne
- [ ] **Top 20 exercices:** Images instantanées (< 100ms)
- [ ] **Autres exercices:** Loader puis cache
- [ ] Mode offline: Top 20 disponibles

### Checklist Performance

- [ ] Recherche < 1s
- [ ] Filtrage < 1s
- [ ] 60fps maintenu
- [ ] Pas de memory leak images

### Checklist Quota

- [ ] Setup: 21 requêtes (1 liste + 20 images)
- [ ] Runtime: ~10-15 requêtes/user
- [ ] Total: < 80 requêtes pour 4-5 users

---

## QUOTA API FINAL

| Action | Requêtes | Cumulé |
|--------|----------|--------|
| Liste exercices | 1 | 1 |
| Download top 20 images | 20 | 21 |
| **Restant pour lazy loading** | - | **79** |

**Conclusion:** 79 requêtes pour lazy loading = ~5-6 users complets supportés.

---

**Auteur:** Apollon Project Assistant  
**Date:** 2026-02-17  
**Version:** 2.0 - Stratégie Hybride  
**Estimation:** 12-16 heures  
**Status:** Ready for Development 🚀
