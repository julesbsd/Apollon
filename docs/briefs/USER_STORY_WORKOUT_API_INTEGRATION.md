# USER STORY: Intégration Catalogue Exercices Workout API

**ID:** US-003  
**Epic:** Catalogue Exercices  
**Priorité:** Haute  
**Estimation:** 8-13 points (Fibonacci)  
**Sprint:** À définir

---

## CONTEXTE UTILISATEUR

### Persona
**Marc, 28 ans, pratiquant musculation intermédiaire**
- Va en salle 3x/semaine
- Connaît ~30-40 exercices différents
- Veut tracker précisément ses performances
- Frustré quand il ne trouve pas l'exercice exact dans l'app

### Problème Actuel
- Liste exercices limitée (~50 exercices)
- Noms parfois imprécis ou anglicisés
- Manque de descriptions (comment faire l'exercice?)
- Pas de classification claire (muscles, équipements)

---

## USER STORY

### En tant que
Utilisateur d'Apollon

### Je veux
Accéder à un catalogue professionnel de **94+ exercices** en français avec noms standardisés, descriptions détaillées et classification par muscles/équipements

### Afin de
- Trouver rapidement l'exercice exact que je fais en salle
- Comprendre la technique si je découvre un nouvel exercice
- Filtrer intelligemment par groupe musculaire ou type d'équipement
- Avoir une app professionnelle avec données de qualité

---

## CRITÈRES D'ACCEPTATION

### Fonctionnels

#### ✅ CA-1: Catalogue Complet Disponible
**Donné** que je lance l'app pour la première fois  
**Quand** j'accède à l'écran "Sélection Exercice"  
**Alors** je vois au moins 90 exercices disponibles en français

#### ✅ CA-2: Recherche Textuelle
**Donné** que je suis sur l'écran sélection exercice  
**Quand** je tape "développé" dans la barre de recherche  
**Alors** je vois tous les exercices contenant "développé" (couché, militaire, incliné, etc.)

#### ✅ CA-3: Filtrage par Muscle
**Donné** que je veux cibler mes pectoraux  
**Quand** je sélectionne filtre "Pectoraux"  
**Alors** seuls les exercices avec pectoraux en muscle primaire s'affichent

#### ✅ CA-4: Filtrage par Équipement
**Donné** que je travaille avec barre uniquement  
**Quand** je sélectionne filtre "Poids libres"  
**Alors** seuls les exercices avec équipement "Poids libres" s'affichent

#### ✅ CA-5: Description Détaillée
**Donné** que je ne connais pas un exercice  
**Quand** je tape sur l'exercice  
**Alors** je vois une description complète de la technique (100-200 mots)

#### ✅ CA-6: Images Lazy Loading
**Donné** que je consulte un exercice pour la première fois  
**Quand** l'image n'est pas en cache  
**Alors** l'app télécharge automatiquement l'image et la stocke localement  
**Et** les prochaines fois, l'image s'affiche instantanément (< 0.5s)

#### ✅ CA-7: Mode Offline
**Donné** que j'ai déjà utilisé l'app  
**Quand** je n'ai plus de connexion internet  
**Alors** je peux toujours accéder aux exercices (catalogue + images déjà téléchargées)

#### ✅ CA-8: Performance
**Donné** que je suis sur l'écran sélection  
**Quand** je filtre ou recherche  
**Alors** les résultats s'affichent en < 1 seconde (respect CS-002)

---

## ARCHITECTURE TECHNIQUE

### Vue d'Ensemble

```
┌─────────────────────────────────────────────┐
│  FLUTTER APP                                │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │ UI: Exercise Selection Screen       │   │
│  │ - Search bar                        │   │
│  │ - Filters (muscle, equipment)       │   │
│  │ - Exercise list                     │   │
│  └──────────┬──────────────────────────┘   │
│             │                               │
│  ┌──────────▼──────────────────────────┐   │
│  │ ExerciseRepository                  │   │
│  │ - getAll() → Firestore              │   │
│  │ - search(query)                     │   │
│  │ - filterByMuscle(muscle)            │   │
│  │ - getImageUrl(exerciseId)           │   │
│  └──────────┬──────────────────────────┘   │
│             │                               │
└─────────────┼───────────────────────────────┘
              │
   ┌──────────▼────────────────────┐
   │ FIRESTORE                     │
   │                               │
   │ Collection: exercises_library │
   │ - 94 documents                │
   │ - Source: Workout API         │
   │ - Refresh: Manuel V1          │
   └──────────┬────────────────────┘
              │
   ┌──────────▼────────────────────┐
   │ FIREBASE STORAGE              │
   │                               │
   │ /exercise_images/{id}.jpg     │
   │ - Lazy loading                │
   │ - Cache permanent             │
   └───────────────────────────────┘
```

### Data Flow: Chargement Exercice

```
User selects exercise
       ↓
1. Repository checks Firestore cache
       ↓
2. Exercise data loaded (instant)
       ↓
3. UI displays name + description
       ↓
4. Repository checks if image exists in Storage
       ↓
   [Image exists?]
       ├─ YES → Load from Storage (instant)
       └─ NO  → Call Workout API /exercises/{id}/visual
                ↓
                Download image
                ↓
                Store in Firebase Storage
                ↓
                Display image
```

---

## MODÈLES DE DONNÉES

### Firestore: `exercises_library` Collection

```dart
class ExerciseLibrary {
  final String id;              // UUID from Workout API
  final String code;            // Unique code (ex: 'BARBELL_BENCH_PRESS')
  final String name;            // "Développé couché barre"
  final String description;     // Description technique complète
  
  // Muscles
  final List<MuscleInfo> primaryMuscles;   
  final List<MuscleInfo> secondaryMuscles;
  
  // Classification
  final List<TypeInfo> types;              
  final List<CategoryInfo> categories;     
  
  // Metadata
  final DateTime syncedAt;      // Date import depuis API
  final String source;          // "workout-api"
  final bool hasImage;          // Image téléchargée?
  
  // Méthodes
  Map<String, dynamic> toFirestore();
  factory ExerciseLibrary.fromFirestore(Map<String, dynamic> data);
}

class MuscleInfo {
  final String id;
  final String code;   // 'CHEST', 'BICEPS'
  final String name;   // 'Pectoraux', 'Biceps'
}

class TypeInfo {
  final String id;
  final String code;   // 'ISOLATION', 'COMPOUND'
  final String name;   // 'Isolation', 'Polyarticulaire'
}

class CategoryInfo {
  final String id;
  final String code;   // 'FREE_WEIGHT', 'MACHINE'
  final String name;   // 'Poids libres', 'Machine'
}
```

### Firebase Storage: Structure

```
gs://apollon.appspot.com/
  └── exercise_images/
      ├── 0a432495-4bcf-4146-952f-ba6ee263c44c.jpg  (Haussements épaules)
      ├── e51e9549-d9b7-463e-a8e2-19b3d00ee8af.jpg  (Shoulder Press)
      └── ...
```

---

## SPÉCIFICATIONS TECHNIQUES

### 1. Import Initial Données (Setup)

**Script One-Time:** `scripts/import_exercises_to_firestore.dart`

```dart
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> importExercises() async {
  // Lire JSON téléchargé
  final file = File('docs/workout_api_exercises_fr.json');
  final jsonString = await file.readAsString();
  final List<dynamic> exercises = jsonDecode(jsonString);
  
  // Firestore instance
  final firestore = FirebaseFirestore.instance;
  final collection = firestore.collection('exercises_library');
  
  // Batch write (plus performant)
  WriteBatch batch = firestore.batch();
  int count = 0;
  
  for (var exerciseJson in exercises) {
    final exercise = ExerciseLibrary.fromWorkoutApi(exerciseJson);
    final docRef = collection.doc(exercise.id);
    batch.set(docRef, exercise.toFirestore());
    
    count++;
    if (count % 500 == 0) {
      await batch.commit();
      batch = firestore.batch();
      print('✅ Imported $count exercises...');
    }
  }
  
  // Commit dernier batch
  await batch.commit();
  print('🎉 Total imported: $count exercises');
}
```

### 2. Repository: `ExerciseLibraryRepository`

**Fichier:** `lib/features/exercises/data/repositories/exercise_library_repository.dart`

```dart
class ExerciseLibraryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  
  // Cache en mémoire pour performance
  List<ExerciseLibrary>? _cachedExercises;
  
  ExerciseLibraryRepository(this._firestore, this._storage);
  
  /// Récupérer tous les exercices (avec cache)
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
    final allExercises = await getAll();
    final lowerQuery = query.toLowerCase();
    
    return allExercises.where((ex) =>
      ex.name.toLowerCase().contains(lowerQuery) ||
      ex.description.toLowerCase().contains(lowerQuery)
    ).toList();
  }
  
  /// Filtrer par muscle primaire
  Future<List<ExerciseLibrary>> filterByMuscle(String muscleCode) async {
    final allExercises = await getAll();
    
    return allExercises.where((ex) =>
      ex.primaryMuscles.any((m) => m.code == muscleCode)
    ).toList();
  }
  
  /// Filtrer par catégorie (équipement)
  Future<List<ExerciseLibrary>> filterByCategory(String categoryCode) async {
    final allExercises = await getAll();
    
    return allExercises.where((ex) =>
      ex.categories.any((c) => c.code == categoryCode)
    ).toList();
  }
  
  /// Récupérer image (lazy loading)
  Future<String?> getImageUrl(String exerciseId) async {
    try {
      // Vérifier si image existe dans Storage
      final ref = _storage.ref('exercise_images/$exerciseId.jpg');
      
      try {
        final url = await ref.getDownloadURL();
        return url; // Image déjà en cache
      } catch (e) {
        // Image pas encore téléchargée → appeler Workout API
        return await _downloadAndCacheImage(exerciseId);
      }
    } catch (e) {
      print('Error getting image: $e');
      return null;
    }
  }
  
  /// Télécharger image depuis Workout API et la cacher
  Future<String?> _downloadAndCacheImage(String exerciseId) async {
    try {
      // Appeler Workout API
      final response = await http.get(
        Uri.parse('https://api.workoutapi.com/exercises/$exerciseId/visual'),
        headers: {
          'X-API-Key': 'YOUR_API_KEY', // À sécuriser (env variable)
        },
      );
      
      if (response.statusCode == 200) {
        // Upload vers Firebase Storage
        final ref = _storage.ref('exercise_images/$exerciseId.jpg');
        await ref.putData(response.bodyBytes);
        
        // Récupérer URL
        final url = await ref.getDownloadURL();
        
        // Mettre à jour Firestore (flag hasImage)
        await _firestore
            .collection('exercises_library')
            .doc(exerciseId)
            .update({'hasImage': true});
        
        return url;
      }
      
      return null;
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }
}
```

### 3. Provider: `ExerciseLibraryProvider`

**Fichier:** `lib/features/exercises/providers/exercise_library_provider.dart`

```dart
class ExerciseLibraryProvider extends ChangeNotifier {
  final ExerciseLibraryRepository _repository;
  
  List<ExerciseLibrary> _exercises = [];
  List<ExerciseLibrary> _filteredExercises = [];
  bool _isLoading = false;
  String? _error;
  
  // Filtres actifs
  String _searchQuery = '';
  String? _selectedMuscle;
  String? _selectedCategory;
  
  ExerciseLibraryProvider(this._repository);
  
  // Getters
  List<ExerciseLibrary> get exercises => _filteredExercises;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Charger tous les exercices
  Future<void> loadExercises() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _exercises = await _repository.getAll();
      _applyFilters();
      _error = null;
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
    _selectedMuscle = muscleCode;
    _applyFilters();
  }
  
  /// Filtrer par catégorie
  void filterByCategory(String? categoryCode) {
    _selectedCategory = categoryCode;
    _applyFilters();
  }
  
  /// Réinitialiser filtres
  void clearFilters() {
    _searchQuery = '';
    _selectedMuscle = null;
    _selectedCategory = null;
    _applyFilters();
  }
  
  /// Appliquer tous les filtres
  void _applyFilters() {
    _filteredExercises = _exercises;
    
    // Filtre recherche
    if (_searchQuery.isNotEmpty) {
      final lower = _searchQuery.toLowerCase();
      _filteredExercises = _filteredExercises.where((ex) =>
        ex.name.toLowerCase().contains(lower) ||
        ex.description.toLowerCase().contains(lower)
      ).toList();
    }
    
    // Filtre muscle
    if (_selectedMuscle != null) {
      _filteredExercises = _filteredExercises.where((ex) =>
        ex.primaryMuscles.any((m) => m.code == _selectedMuscle)
      ).toList();
    }
    
    // Filtre catégorie
    if (_selectedCategory != null) {
      _filteredExercises = _filteredExercises.where((ex) =>
        ex.categories.any((c) => c.code == _selectedCategory)
      ).toList();
    }
    
    notifyListeners();
  }
  
  /// Récupérer image exercice
  Future<String?> getImageUrl(String exerciseId) async {
    return await _repository.getImageUrl(exerciseId);
  }
}
```

### 4. UI: `ExerciseSelectionScreen` (Refonte)

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
    // Charger exercices au démarrage
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
          // Barre de recherche
          _buildSearchBar(),
          
          // Filtres (muscles, équipements)
          _buildFilters(),
          
          // Liste exercices
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
    // TODO: Chips pour muscles, catégories
    return Container();
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
```

### 5. Widget: `ExerciseLibraryTile`

```dart
class ExerciseLibraryTile extends StatelessWidget {
  final ExerciseLibrary exercise;
  
  const ExerciseLibraryTile({required this.exercise});
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: FutureBuilder<String?>(
        future: context.read<ExerciseLibraryProvider>().getImageUrl(exercise.id),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return CachedNetworkImage(
              imageUrl: snapshot.data!,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              placeholder: (_, __) => CircularProgressIndicator(),
            );
          }
          return Icon(Icons.fitness_center, size: 50);
        },
      ),
      title: Text(exercise.name),
      subtitle: Text(
        exercise.primaryMuscles.map((m) => m.name).join(', '),
        style: TextStyle(fontSize: 12),
      ),
      trailing: Icon(Icons.chevron_right),
      onTap: () => _onExerciseSelected(context, exercise),
    );
  }
  
  void _onExerciseSelected(BuildContext context, ExerciseLibrary exercise) {
    // Naviguer vers détail ou ajouter à séance
    Navigator.pop(context, exercise);
  }
}
```

---

## PLAN D'IMPLÉMENTATION

### Phase 1: Setup Données (1-2h)

- [ ] Exécuter script import Firestore (94 exercices)
- [ ] Vérifier données dans Firebase Console
- [ ] Créer indexes Firestore si nécessaire

### Phase 2: Modèles et Repository (2-3h)

- [ ] Créer modèles Dart (`ExerciseLibrary`, `MuscleInfo`, etc.)
- [ ] Implémenter `ExerciseLibraryRepository`
- [ ] Tester méthodes (getAll, search, filter)

### Phase 3: Provider et State Management (1-2h)

- [ ] Implémenter `ExerciseLibraryProvider`
- [ ] Intégrer avec Provider existant
- [ ] Tester réactivité filtres

### Phase 4: UI Refonte (3-4h)

- [ ] Refondre `ExerciseSelectionScreen`
- [ ] Ajouter barre recherche
- [ ] Ajouter filtres (chips muscles/catégories)
- [ ] Créer `ExerciseLibraryTile` widget

### Phase 5: Lazy Loading Images (2-3h)

- [ ] Implémenter `_downloadAndCacheImage()`
- [ ] Intégrer Firebase Storage
- [ ] Tester téléchargement + cache
- [ ] Gérer états (loading, error)

### Phase 6: Tests et Polish (1-2h)

- [ ] Tests performance (< 1s filtrage)
- [ ] Tests offline mode
- [ ] Tests lazy loading images
- [ ] Gérer edge cases (pas d'image disponible)

---

## TESTS D'ACCEPTATION

### Test 1: Catalogue Complet
1. Supprimer cache app
2. Lancer app
3. Aller sur sélection exercice
4. **Vérifié:** Au moins 90 exercices visibles

### Test 2: Recherche
1. Taper "développé" dans recherche
2. **Vérifié:** 5+ exercices contenant "développé" affichés

### Test 3: Filtre Muscle
1. Sélectionner filtre "Pectoraux"
2. **Vérifié:** Seuls exercices pectoraux visibles

### Test 4: Image Lazy Loading
1. Sélectionner exercice jamais consulté
2. **Vérifié:** Loader s'affiche, puis image apparaît
3. Revenir en arrière, re-sélectionner exercice
4. **Vérifié:** Image s'affiche instantanément (< 0.5s)

### Test 5: Offline Mode
1. Utiliser app normalement
2. Activer mode avion
3. Accéder sélection exercice
4. **Vérifié:** Liste exercices toujours accessible

### Test 6: Performance
1. Taper recherche rapide
2. Changer filtres rapidement
3. **Vérifié:** Aucun lag, réponse < 1s

---

## QUOTA API MANAGEMENT

### Consommation Estimée

| **Action** | **Coût** | **Fréquence** |
|------------|---------|---------------|
| Import initial | 1 requête | Une fois (fait ✅) |
| Image par exercice | 1 requête | À la demande |
| **Estimation 1 user** | ~20-30 requêtes | Lifetime user |
| **Quota total** | 100 requêtes | Limite |
| **Users supportés** | ~3-4 users complets | Avec images |

### Optimisations Futures

- **Plan Payant API:** Si scaling nécessaire
- **Pre-cache Top 20:** Télécharger images exercices populaires au setup
- **Alternative Images:** Fallback vers images gratuites (Unsplash)

---

## DOCUMENTATION

### README Section à Ajouter

```markdown
## Catalogue Exercices

Apollon utilise l'API Workout API pour fournir un catalogue professionnel de 94+ exercices.

### Features
- Noms en français
- Descriptions détaillées
- Classification par muscles et équipements
- Images haute qualité (lazy loading)

### Données Sources
- API: https://workoutapi.com
- Langue: Français (fr-FR)
- Refresh: Manuel (1x au setup)
```

---

## DEPENDENCIES

### Ajouter à `pubspec.yaml`

```yaml
dependencies:
  # Existantes
  firebase_core: ^latest
  cloud_firestore: ^latest
  firebase_storage: ^latest
  provider: ^latest
  
  # Nouvelles (si pas déjà présentes)
  cached_network_image: ^latest  # Cache images
  http: ^latest                  # Appels API
```

---

## CRITÈRES DE SUCCÈS BUSINESS

- [ ] Temps sélection exercice réduit de 50% (mesurer avec analytics)
- [ ] Satisfaction utilisateur: 4.5+/5 sur feature
- [ ] Zéro feedback "exercice manquant" après release
- [ ] 60fps maintenu sur écrans sélection

---

**Auteur:** Apollon Project Assistant  
**Date Création:** 2026-02-17  
**Status:** Ready for Development  
**Requêtes API Consommées:** 1/100
