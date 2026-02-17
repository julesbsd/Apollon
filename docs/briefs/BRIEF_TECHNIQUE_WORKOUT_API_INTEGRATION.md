# BRIEF TECHNIQUE: Intégration Catalogue Exercices + Lazy Loading Images

**Version:** 1.0  
**Date:** 2026-02-17  
**Destinataire:** Flutter Developer Expert  
**Émetteur:** Apollon Project Assistant  
**Priorité:** Haute  
**Estimation:** 10-15 heures

---

## RÉSUMÉ EXÉCUTIF

Intégrer catalogue de **94 exercices professionnels** depuis Workout API avec système de **lazy loading pour images**. Objectif: améliorer UX sélection exercices avec données riches (noms FR, descriptions, classifications) tout en optimisant quota API limité (100 requêtes).

**Fichiers Fournis:**
- ✅ `docs/workout_api_exercises_fr.json` (94 exercices téléchargés)
- ✅ `docs/ANALYSE_WORKOUT_API.md` (analyse complète API)
- ✅ `docs/briefs/USER_STORY_WORKOUT_API_INTEGRATION.md` (user story)

---

## OBJECTIF

### Objectif Principal

Remplacer la liste manuelle d'exercices par un **catalogue professionnel Firestore** avec images lazy-loadées depuis Workout API.

### Objectifs Spécifiques

1. **Importer 94 exercices** dans Firestore collection `exercises_library`
2. **Créer architecture lazy loading** pour images (Firebase Storage)
3. **Refondre UI sélection** avec recherche + filtres intelligents
4. **Optimiser quota API:** 1 requête initial (fait ✅), puis 1 requête/image à la demande
5. **Maintenir performances:** < 1s recherche/filtrage (CS-002)

---

## CONTEXTE MÉTIER

### Règles de Gestion Concernées

- **RG-002:** Unicité noms exercices (garantie par UUIDs API)
- **RG-005:** Affichage historique (amélioration avec noms standardisés)

### Processus Métier Impacté

- **P2 (Enregistrer séance - CRITIQUE):**  
  `Nouvelle séance → **[AMÉLIORATION]** Sélection exercice enrichie → Affichage historique → Ajout séries → Terminer`

### Critères de Succès

- **CS-002:** Retrouver exercice en < 1s (optimisé par cache Firestore)
- **CS-003:** Interface fluide (60fps maintenu)

---

## ARCHITECTURE DONNÉES

### 1. Firestore Collection: `exercises_library`

**Structure Document:**

```dart
{
  "id": "0a432495-4bcf-4146-952f-ba6ee263c44c",
  "code": "DUMBBELL_SHRUGS",
  "name": "Haussements d'épaules avec haltères",
  "description": "Tenez-vous droit avec un haltère...",
  "primaryMuscles": [
    {
      "id": "8c22ec68-1538-40d7-8be4-2e0b4b94fb3d",
      "code": "TRAPEZIUS",
      "name": "Trapèzes"
    }
  ],
  "secondaryMuscles": [],
  "types": [
    {
      "id": "ffd48b1f-84e9-4487-9ece-2103f7ddfcd4",
      "code": "ISOLATION",
      "name": "Isolation"
    }
  ],
  "categories": [
    {
      "id": "cb62959e-0f58-436c-a7f4-a6430d92fc3f",
      "code": "FREE_WEIGHT",
      "name": "Poids libres"
    }
  ],
  "syncedAt": "2026-02-17T17:10:00Z",
  "source": "workout-api",
  "hasImage": false
}
```

**Indexes Firestore Requis:**

```
Collection: exercises_library
- Index composite: (name ASC, syncedAt DESC)
- Index simple: code ASC
- Index simple: hasImage ASC
```

### 2. Firebase Storage: Images

**Path Structure:**

```
gs://apollon.appspot.com/
  └── exercise_images/
      ├── {exerciseId}.jpg  (ex: 0a432495-4bcf-4146-952f-ba6ee263c44c.jpg)
      └── ...
```

**Metadata:**
- Content-Type: `image/jpeg`
- Cache-Control: `public, max-age=31536000` (1 an)

---

## STACK TECHNIQUE

### Dependencies Requises

**`pubspec.yaml`:**

```yaml
dependencies:
  # Firebase (déjà installé)
  firebase_core: ^2.24.0
  cloud_firestore: ^4.13.0
  firebase_storage: ^11.5.0
  
  # State Management (déjà installé)
  provider: ^6.1.0
  
  # HTTP & Images
  http: ^1.1.0                      # Appels Workout API
  cached_network_image: ^3.3.0     # Cache images optimisé
  
  # Utils
  intl: ^0.18.0                    # Formatage dates
```

### Configuration Firebase

**`android/app/google-services.json`:** ✅ Déjà configuré  
**`ios/Runner/GoogleService-Info.plist`:** ✅ Déjà configuré

**Vérifier Firestore Rules:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Exercices library: lecture publique, écriture admin only
    match /exercises_library/{exerciseId} {
      allow read: if request.auth != null;  // Users authentifiés
      allow write: if false;                 // Admin only (console)
    }
  }
}
```

**Vérifier Storage Rules:**

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /exercise_images/{imageId} {
      allow read: if request.auth != null;  // Users authentifiés
      allow write: if false;                 // Backend only
    }
  }
}
```

---

## IMPLÉMENTATION DÉTAILLÉE

### Phase 1: Import Initial Firestore (1-2h)

#### 1.1 Script Import

**Fichier:** `scripts/import_exercises_to_firestore.dart`

```dart
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  // Initialiser Firebase
  await Firebase.initializeApp();
  
  print('🚀 Démarrage import exercices...\n');
  
  // Lire JSON
  final file = File('docs/workout_api_exercises_fr.json');
  if (!file.existsSync()) {
    print('❌ Fichier JSON introuvable: ${file.path}');
    exit(1);
  }
  
  final jsonString = await file.readAsString();
  final List<dynamic> exercises = jsonDecode(jsonString);
  print('📄 ${exercises.length} exercices trouvés dans JSON\n');
  
  // Firestore
  final firestore = FirebaseFirestore.instance;
  final collection = firestore.collection('exercises_library');
  
  // Batch write (max 500 par batch)
  WriteBatch batch = firestore.batch();
  int count = 0;
  
  for (var exerciseJson in exercises) {
    try {
      // Préparer document
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
        'hasImage': false,
      };
      
      // Ajouter au batch
      final docRef = collection.doc(exerciseJson['id']);
      batch.set(docRef, data);
      
      count++;
      
      // Commit tous les 500 (limite Firestore)
      if (count % 500 == 0) {
        await batch.commit();
        batch = firestore.batch();
        print('✅ Imported $count exercices...');
      }
    } catch (e) {
      print('⚠️ Erreur exercice ${exerciseJson['code']}: $e');
    }
  }
  
  // Commit dernier batch
  if (count % 500 != 0) {
    await batch.commit();
  }
  
  print('\n🎉 Import terminé: $count exercices importés avec succès!');
}
```

**Exécution:**

```bash
# Depuis racine projet
flutter pub get
dart scripts/import_exercises_to_firestore.dart
```

#### 1.2 Vérification Import

1. Ouvrir Firebase Console: https://console.firebase.google.com
2. Aller dans Firestore Database
3. Vérifier collection `exercises_library`: 94 documents
4. Vérifier un document sample: tous les champs présents

---

### Phase 2: Modèles Dart (2h)

#### 2.1 Modèle `ExerciseLibrary`

**Fichier:** `lib/features/exercises/domain/models/exercise_library.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseLibrary {
  final String id;
  final String code;
  final String name;
  final String description;
  final List<MuscleInfo> primaryMuscles;
  final List<MuscleInfo> secondaryMuscles;
  final List<TypeInfo> types;
  final List<CategoryInfo> categories;
  final DateTime? syncedAt;
  final String source;
  final bool hasImage;
  
  const ExerciseLibrary({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.types,
    required this.categories,
    this.syncedAt,
    this.source = 'workout-api',
    this.hasImage = false,
  });
  
  /// Factory depuis Firestore
  factory ExerciseLibrary.fromFirestore(Map<String, dynamic> data) {
    return ExerciseLibrary(
      id: data['id'] as String,
      code: data['code'] as String,
      name: data['name'] as String,
      description: data['description'] as String? ?? '',
      primaryMuscles: (data['primaryMuscles'] as List<dynamic>?)
          ?.map((m) => MuscleInfo.fromMap(m as Map<String, dynamic>))
          .toList() ?? [],
      secondaryMuscles: (data['secondaryMuscles'] as List<dynamic>?)
          ?.map((m) => MuscleInfo.fromMap(m as Map<String, dynamic>))
          .toList() ?? [],
      types: (data['types'] as List<dynamic>?)
          ?.map((t) => TypeInfo.fromMap(t as Map<String, dynamic>))
          .toList() ?? [],
      categories: (data['categories'] as List<dynamic>?)
          ?.map((c) => CategoryInfo.fromMap(c as Map<String, dynamic>))
          .toList() ?? [],
      syncedAt: (data['syncedAt'] as Timestamp?)?.toDate(),
      source: data['source'] as String? ?? 'workout-api',
      hasImage: data['hasImage'] as bool? ?? false,
    );
  }
  
  /// Convertir vers Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'primaryMuscles': primaryMuscles.map((m) => m.toMap()).toList(),
      'secondaryMuscles': secondaryMuscles.map((m) => m.toMap()).toList(),
      'types': types.map((t) => t.toMap()).toList(),
      'categories': categories.map((c) => c.toMap()).toList(),
      'syncedAt': syncedAt != null ? Timestamp.fromDate(syncedAt!) : FieldValue.serverTimestamp(),
      'source': source,
      'hasImage': hasImage,
    };
  }
  
  /// Copie avec modifications
  ExerciseLibrary copyWith({bool? hasImage}) {
    return ExerciseLibrary(
      id: id,
      code: code,
      name: name,
      description: description,
      primaryMuscles: primaryMuscles,
      secondaryMuscles: secondaryMuscles,
      types: types,
      categories: categories,
      syncedAt: syncedAt,
      source: source,
      hasImage: hasImage ?? this.hasImage,
    );
  }
}

class MuscleInfo {
  final String id;
  final String code;
  final String name;
  
  const MuscleInfo({
    required this.id,
    required this.code,
    required this.name,
  });
  
  factory MuscleInfo.fromMap(Map<String, dynamic> map) {
    return MuscleInfo(
      id: map['id'] as String,
      code: map['code'] as String,
      name: map['name'] as String,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {'id': id, 'code': code, 'name': name};
  }
}

class TypeInfo {
  final String id;
  final String code;
  final String name;
  
  const TypeInfo({
    required this.id,
    required this.code,
    required this.name,
  });
  
  factory TypeInfo.fromMap(Map<String, dynamic> map) {
    return TypeInfo(
      id: map['id'] as String,
      code: map['code'] as String,
      name: map['name'] as String,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {'id': id, 'code': code, 'name': name};
  }
}

class CategoryInfo {
  final String id;
  final String code;
  final String name;
  
  const CategoryInfo({
    required this.id,
    required this.code,
    required this.name,
  });
  
  factory CategoryInfo.fromMap(Map<String, dynamic> map) {
    return CategoryInfo(
      id: map['id'] as String,
      code: map['code'] as String,
      name: map['name'] as String,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {'id': id, 'code': code, 'name': name};
  }
}
```

---

### Phase 3: Repository (3h)

**Fichier:** `lib/features/exercises/data/repositories/exercise_library_repository.dart`

```dart
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

class ExerciseLibraryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final String _apiKey;
  
  // Cache en mémoire pour performance
  List<ExerciseLibrary>? _cachedExercises;
  final Map<String, String> _imageUrlCache = {};
  
  ExerciseLibraryRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    required String apiKey,
  })  : _firestore = firestore,
        _storage = storage,
        _apiKey = apiKey;
  
  /// Récupérer tous les exercices
  Future<List<ExerciseLibrary>> getAll() async {
    if (_cachedExercises != null) {
      return _cachedExercises!;
    }
    
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
    final lowerQuery = query.toLowerCase().trim();
    
    if (lowerQuery.isEmpty) return all;
    
    return all.where((ex) {
      return ex.name.toLowerCase().contains(lowerQuery) ||
             ex.description.toLowerCase().contains(lowerQuery) ||
             ex.code.toLowerCase().contains(lowerQuery);
    }).toList();
  }
  
  /// Filtrer par muscle primaire
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
  
  /// Récupérer URL image (lazy loading)
  Future<String?> getImageUrl(String exerciseId) async {
    // Check cache mémoire
    if (_imageUrlCache.containsKey(exerciseId)) {
      return _imageUrlCache[exerciseId];
    }
    
    try {
      // Check Firebase Storage
      final ref = _storage.ref('exercise_images/$exerciseId.jpg');
      
      try {
        final url = await ref.getDownloadURL();
        _imageUrlCache[exerciseId] = url;
        return url;
      } on FirebaseException catch (e) {
        if (e.code == 'object-not-found') {
          // Image pas encore téléchargée → fetch depuis API
          return await _downloadAndCacheImage(exerciseId);
        }
        rethrow;
      }
    } catch (e) {
      print('❌ Error getting image for $exerciseId: $e');
      return null;
    }
  }
  
  /// Télécharger image depuis Workout API et la cacher
  Future<String?> _downloadAndCacheImage(String exerciseId) async {
    try {
      print('📥 Downloading image for $exerciseId from Workout API...');
      
      // Appel API
      final response = await http.get(
        Uri.parse('https://api.workoutapi.com/exercises/$exerciseId/visual'),
        headers: {'X-API-Key': _apiKey},
      );
      
      if (response.statusCode != 200) {
        print('⚠️ API returned ${response.statusCode} for $exerciseId');
        return null;
      }
      
      // Upload vers Firebase Storage
      final ref = _storage.ref('exercise_images/$exerciseId.jpg');
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public, max-age=31536000',
      );
      
      await ref.putData(response.bodyBytes, metadata);
      print('✅ Image uploaded to Firebase Storage');
      
      // Mettre à jour Firestore
      await _firestore
          .collection('exercises_library')
          .doc(exerciseId)
          .update({'hasImage': true});
      
      // Récupérer URL
      final url = await ref.getDownloadURL();
      _imageUrlCache[exerciseId] = url;
      
      return url;
    } catch (e) {
      print('❌ Error downloading/caching image: $e');
      return null;
    }
  }
  
  /// Invalider cache (pour refresh)
  void clearCache() {
    _cachedExercises = null;
    _imageUrlCache.clear();
  }
}
```

---

### Phase 4: Provider (2h)

**Fichier:** `lib/features/exercises/providers/exercise_library_provider.dart`

```dart
import 'package:flutter/foundation.dart';

class ExerciseLibraryProvider extends ChangeNotifier {
  final ExerciseLibraryRepository _repository;
  
  List<ExerciseLibrary> _allExercises = [];
  List<ExerciseLibrary> _filteredExercises = [];
  bool _isLoading = false;
  String? _error;
  
  // Filtres actifs
  String _searchQuery = '';
  String? _selectedMuscleCode;
  String? _selectedCategoryCode;
  
  ExerciseLibraryProvider(this._repository);
  
  // Getters
  List<ExerciseLibrary> get exercises => _filteredExercises;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedMuscle => _selectedMuscleCode;
  String? get selectedCategory => _selectedCategoryCode;
  
  /// Charger exercices
  Future<void> loadExercises() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _allExercises = await _repository.getAll();
      _applyFilters();
    } catch (e) {
      _error = 'Erreur chargement exercices: $e';
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
  
  /// Reset filtres
  void clearFilters() {
    _searchQuery = '';
    _selectedMuscleCode = null;
    _selectedCategoryCode = null;
    _applyFilters();
  }
  
  /// Appliquer filtres combinés
  void _applyFilters() {
    _filteredExercises = _allExercises;
    
    // Filtre recherche
    if (_searchQuery.isNotEmpty) {
      final lower = _searchQuery.toLowerCase();
      _filteredExercises = _filteredExercises.where((ex) =>
        ex.name.toLowerCase().contains(lower) ||
        ex.description.toLowerCase().contains(lower)
      ).toList();
    }
    
    // Filtre muscle
    if (_selectedMuscleCode != null) {
      _filteredExercises = _filteredExercises.where((ex) =>
        ex.primaryMuscles.any((m) => m.code == _selectedMuscleCode)
      ).toList();
    }
    
    // Filtre catégorie
    if (_selectedCategoryCode != null) {
      _filteredExercises = _filteredExercises.where((ex) =>
        ex.categories.any((c) => c.code == _selectedCategoryCode)
      ).toList();
    }
    
    notifyListeners();
  }
  
  /// Get image URL
  Future<String?> getImageUrl(String exerciseId) async {
    return await _repository.getImageUrl(exerciseId);
  }
  
  /// Get liste muscles disponibles
  List<MuscleInfo> get availableMuscles {
    final musclesSet = <String, MuscleInfo>{};
    for (var ex in _allExercises) {
      for (var muscle in ex.primaryMuscles) {
        musclesSet[muscle.code] = muscle;
      }
    }
    return musclesSet.values.toList();
  }
  
  /// Get liste catégories disponibles
  List<CategoryInfo> get availableCategories {
    final categoriesSet = <String, CategoryInfo>{};
    for (var ex in _allExercises) {
      for (var category in ex.categories) {
        categoriesSet[category.code] = category;
      }
    }
    return categoriesSet.values.toList();
  }
}
```

---

### Phase 5: UI Refonte (3-4h)

**Fichier:** `lib/features/exercises/screens/exercise_library_screen.dart`

**(Voir User Story document pour code complet UI)**

**Points clés:**
- SearchBar avec debounce (500ms)
- Filtres chips (muscles, catégories)
- ListView.builder avec ExerciseLibraryTile
- Pull-to-refresh pour reload

---

## SÉCURITÉ

### API Key Management

**❌ NE JAMAIS hardcoder l'API key dans le code!**

**✅ Solution: Environment Variables**

**Fichier:** `.env` (ajouter à `.gitignore`)

```
WORKOUT_API_KEY=WORKOUT_API_KEY
```

**Dependency:** `flutter_dotenv: ^5.1.0`

**Usage:**

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

// main.dart
await dotenv.load(fileName: ".env");

// Repository
final apiKey = dotenv.env['WORKOUT_API_KEY'] ?? '';
```

---

## TESTS

### Tests Unitaires Repository

```dart
// test/features/exercises/repositories/exercise_library_repository_test.dart

void main() {
  group('ExerciseLibraryRepository', () {
    test('getAll returns exercises from Firestore', () async {
      // TODO: Mock Firestore
    });
    
    test('search filters by name', () async {
      // TODO: Test recherche
    });
    
    test('getImageUrl downloads and caches image', () async {
      // TODO: Mock API + Storage
    });
  });
}
```

---

## CHECKLIST PRÉ-LIVRAISON

### Fonctionnel
- [ ] 94 exercices importés dans Firestore
- [ ] Recherche textuelle fonctionne
- [ ] Filtres muscles fonctionnent
- [ ] Filtres catégories fonctionnent
- [ ] Images lazy loading fonctionne
- [ ] Cache images persiste

### Performance
- [ ] Recherche < 1s
- [ ] Filtrage < 1s
- [ ] 60fps maintenu
- [ ] Pas de memory leak

### Sécurité
- [ ] API key en environment variable
- [ ] Firestore rules configurées
- [ ] Storage rules configurées

### Documentation
- [ ] Code commenté
- [ ] README mis à jour

---

## RESSOURCES

- **JSON Exercices:** `docs/workout_api_exercises_fr.json`
- **API Docs:** https://docs.workoutapi.com
- **Firebase Console:** https://console.firebase.google.com

---

**Auteur:** Apollon Project Assistant  
**Date:** 2026-02-17  
**Status:** Ready for Development
