# Système d'Images des Exercices

Documentation technique complète du système hybride de gestion des images d'exercices avec stratégie à trois niveaux (assets/local/remote).

---

## 📋 Vue d'ensemble

Le système d'images d'exercices implémente une **stratégie hybride à trois niveaux** pour optimiser les performances, minimiser l'utilisation du quota API, et garantir une expérience utilisateur fluide :

1. **Assets préchargés** (20 exercices) : Images SVG compilées dans l'APK
2. **Téléchargements permanents** (74 exercices max) : Images SVG stockées dans le stockage privé de l'app
3. **Téléchargement à la demande** : Images récupérées via Workout API au premier affichage

### Caractéristiques clés

- ✅ **20 images instantanées** : Top exercices préchargés dans l'APK (zéro latence)
- ✅ **Téléchargement au clic** : Images chargées uniquement en écran détail (pas lors du scroll de liste)
- ✅ **Persistance permanente** : Les images téléchargées restent disponibles hors ligne indéfiniment
- ✅ **Quota optimisé** : Maximum 100 images (limite API), 21/100 utilisées actuellement
- ✅ **Format SVG** : Qualité parfaite à toutes les tailles sans compression
- ✅ **Fallback émoji** : Affichage gracieux si image non disponible

---

## 🏗️ Architecture à trois niveaux

### Diagramme de flux

```
Affichage exercice
    │
    ├─> Liste (ExerciseImageThumbnail)
    │   ├─> Vérifier assets ──> ✅ Afficher SVG asset
    │   ├─> Vérifier local ───> ✅ Afficher SVG stocké
    │   └─> Sinon ────────────> 💡 Afficher emoji (pas de téléchargement)
    │
    └─> Détail (ExerciseImageWidget)
        ├─> Vérifier assets ──> ✅ Afficher SVG asset
        ├─> Vérifier local ───> ✅ Afficher SVG stocké
        └─> Sinon ────────────> 📥 Télécharger depuis API + Stocker + Afficher
```

### Niveau 1 : Assets préchargés (Read-Only)

**Emplacement physique** : `assets/exercise_images/`  
**Quantité** : 20 exercices (les plus populaires)  
**Format** : SVG (371 KB total)  
**Compilation** : Intégrés dans l'APK Flutter lors du build  
**Accès** : Instantané via `SvgPicture.asset()`

**Manifeste** : `assets/exercise_images/manifest.json`

```json
{
  "metadata": {
    "total_count": 20,
    "format": "svg",
    "total_size_kb": 371,
    "source": "workoutapi.com"
  },
  "preseeded_exercises": [
    {
      "id": "f2a4b9d2-41ac-4c5c-bae0-97fc42b6b4c1",
      "code": "BARBELL_SQUAT",
      "filename": "f2a4b9d2-41ac-4c5c-bae0-97fc42b6b4c1.svg"
    },
    // ... 19 autres exercices
  ]
}
```

**Chargement** : Au démarrage de l'app via `ExerciseImageManifest.load()`

**Avantages** :
- Zéro latence (déjà dans l'APK)
- Zéro consommation quota API
- Fonctionnement hors ligne garanti

**Limitations** :
- Dossier `assets/` en lecture seule (compile-time)
- Impossible d'ajouter des images au runtime
- Taille APK augmentée de 371 KB

### Niveau 2 : Téléchargements permanents (Read-Write)

**Emplacement physique** : Application Documents Directory  
**Chemin Android** : `/data/user/0/com.apollon.fitness/app_flutter/exercise_images/`  
**Chemin iOS** : `<App Documents>/exercise_images/`  
**Quantité max** : 74 exercices additionnels (100 - 20 préchargés - 6 réserve)  
**Format** : SVG (taille variable, ~5 KB moyenne)  
**Accès** : Via `path_provider` + `SvgPicture.file()`

**Manifeste** : SharedPreferences clé `downloaded_exercise_images_manifest`

```json
{
  "f8e9c7b3-2d1a-4f6e-9b8c-3a5d7e1f4c2b": "/data/user/0/.../exercise_images/f8e9c7b3-2d1a-4f6e-9b8c-3a5d7e1f4c2b.svg",
  "a3c5e7b9-4f2d-6a8c-1e3b-9d7f5c3a1e2b": "/data/user/0/.../exercise_images/a3c5e7b9-4f2d-6a8c-1e3b-9d7f5c3a1e2b.svg"
}
```

**Stockage** : JSON encodé dans SharedPreferences (persistent)

**Workflow de téléchargement** :

1. Utilisateur ouvre écran détail d'un exercice non préchargé
2. `ExerciseImageWidget` détecte source = `remote`
3. Appel `ExerciseImageDownloader.downloadAndSave(exerciseId)`
4. Requête HTTP GET vers Workout API avec headers SVG
5. Sauvegarde fichier `{exerciseId}.svg` dans `/exercise_images/`
6. Mise à jour manifeste SharedPreferences
7. Rechargement widget avec source = `local`

**Avantages** :
- Persistance permanente (survit aux redémarrages)
- Téléchargement unique par exercice (économie quota)
- Accès hors ligne après premier téléchargement
- Stockage privé (protection données utilisateur)

**Limitations** :
- Supprimé lors de désinstallation app
- Ne peut pas être intégré dans l'APK (runtime uniquement)
- Consomme quota API au premier téléchargement

### Niveau 3 : API remote (Workout API)

**Endpoint** : `https://api.workoutapi.com/exercises/{exerciseId}/image`  
**Méthode** : GET  
**Headers** :
```
x-api-key: WORKOUT_API_KEY
Accept: image/svg+xml
```

**Quota** : 100 requêtes totales (21/100 utilisées, 79 disponibles)

**Format retourné** : SVG uniquement (le header `Accept: image/png` est ignoré par l'API)

**Usage** :
- Fallback pour exercices non préchargés et non téléchargés
- Déclenchement automatique en écran détail uniquement
- Jamais appelé lors du scroll de liste (optimisation)

**Exemple de réponse** :

```xml
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <!-- Contenu SVG de l'exercice -->
</svg>
```

**Taille moyenne** : 5 KB par image

---

## 📁 Structure des fichiers

```
apollon/
├── assets/
│   └── exercise_images/                    # Niveau 1 : Assets (read-only)
│       ├── manifest.json                   # Manifeste préchargés
│       ├── f2a4b9d2-41ac-4c5c-bae0-97fc42b6b4c1.svg  # Barbell Squat
│       ├── e8d7c6b5-3a2f-4e1d-9c8b-7a6f5e4d3c2b.svg  # Bench Press
│       └── ... (18 autres SVG)
│
├── lib/
│   ├── main.dart                           # Initialisation système images
│   └── features/exercise_library/
│       ├── models/
│       │   └── exercise_image_manifest.dart   # Modèle manifeste préchargés
│       ├── data/
│       │   ├── models/
│       │   │   └── image_source.dart       # ImageSource(type, path, url)
│       │   └── repositories/
│       │       └── exercise_library_repository.dart  # Routage triple-check
│       ├── services/
│       │   └── exercise_image_downloader.dart  # Téléchargement + stockage
│       └── widgets/
│           └── exercise_image_widget.dart  # Affichage intelligent
│
└── /data/user/0/com.apollon.fitness/
    ├── app_flutter/exercise_images/        # Niveau 2 : Local (read-write)
    │   └── {exerciseId}.svg                # Images téléchargées au runtime
    └── shared_prefs/
        └── FlutterSharedPreferences.xml    # Manifeste téléchargés (JSON)
            └── Key: downloaded_exercise_images_manifest
```

---

## 🔧 Composants techniques

### 1. ExerciseImageManifest (Niveau 1)

**Fichier** : `lib/features/exercise_library/models/exercise_image_manifest.dart`

**Responsabilité** : Charger et interroger le manifeste des images préchargées

**API publique** :

```dart
class ExerciseImageManifest {
  final int totalCount;
  final List<PreseededExercise> exercises;
  
  /// Charge le manifeste depuis assets/exercise_images/manifest.json
  static Future<ExerciseImageManifest> load()
  
  /// Vérifie si un exercice est préchargé dans les assets
  bool hasPreseededImage(String exerciseId)
  
  /// Retourne le chemin asset d'un exercice préchargé
  String? getAssetPath(String exerciseId)
}
```

**Initialisation** (dans `main.dart`) :

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Charger manifeste préchargés
  final manifest = await ExerciseImageManifest.load();
  
  // Créer repository avec manifeste
  final repository = ExerciseLibraryRepository(
    imageManifest: manifest,
    apiKey: 'WORKOUT_API_KEY',
  );
  
  runApp(
    MultiProvider(
      providers: [
        Provider<ExerciseLibraryRepository>.value(value: repository),
        // ...
      ],
      child: const MyApp(),
    ),
  );
}
```

### 2. ExerciseImageDownloader (Niveau 2)

**Fichier** : `lib/features/exercise_library/services/exercise_image_downloader.dart`

**Responsabilité** : Télécharger et stocker de façon permanente les images d'exercices

**API publique** :

```dart
class ExerciseImageDownloader {
  /// Télécharge une image depuis l'API et la sauvegarde localement
  /// Retourne le chemin du fichier sauvegardé
  Future<String> downloadAndSave(String exerciseId)
  
  /// Vérifie si une image existe déjà localement
  Future<bool> isDownloaded(String exerciseId)
  
  /// Retourne le chemin local d'une image téléchargée
  Future<String?> getLocalPath(String exerciseId)
  
  /// Retourne les statistiques de téléchargement
  Future<Map<String, dynamic>> getStats()
  
  /// Supprime toutes les images téléchargées (maintenance)
  Future<void> clearAll()
}
```

**Détail `downloadAndSave()` workflow** :

```dart
Future<String> downloadAndSave(String exerciseId) async {
  // 1. Vérifier si déjà téléchargé (optimisation)
  if (await isDownloaded(exerciseId)) {
    return (await getLocalPath(exerciseId))!;
  }
  
  // 2. HTTP GET vers API avec headers SVG
  final response = await http.get(
    Uri.parse('https://api.workoutapi.com/exercises/$exerciseId/image'),
    headers: {
      'x-api-key': _apiKey,
      'Accept': 'image/svg+xml',
    },
  );
  
  // 3. Obtenir répertoire stockage app
  final appDir = await getApplicationDocumentsDirectory();
  final imagesDir = Directory('${appDir.path}/exercise_images');
  await imagesDir.create(recursive: true);
  
  // 4. Écrire fichier SVG
  final file = File('${imagesDir.path}/$exerciseId.svg');
  await file.writeAsBytes(response.bodyBytes);
  
  // 5. Mettre à jour manifeste SharedPreferences
  _downloadedManifest[exerciseId] = file.path;
  await _saveDownloadedManifest();
  
  return file.path;
}
```

**Stockage manifeste** :

```dart
Future<void> _saveDownloadedManifest() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = jsonEncode(_downloadedManifest);
  await prefs.setString('downloaded_exercise_images_manifest', jsonString);
}
```

**Exemple `getStats()` retour** :

```json
{
  "downloaded_count": 3,
  "total_size_kb": 14.2,
  "storage_path": "/data/user/0/com.apollon.fitness/app_flutter/exercise_images"
}
```

### 3. ExerciseLibraryRepository (Routage)

**Fichier** : `lib/features/exercise_library/data/repositories/exercise_library_repository.dart`

**Responsabilité** : Router les requêtes d'images vers la bonne source (assets/local/remote)

**API publique** :

```dart
class ExerciseLibraryRepository {
  /// Détermine la source d'image pour un exercice donné
  /// Vérifie dans l'ordre: assets -> local -> remote
  Future<ImageSource> getImageSource(String exerciseId)
  
  /// Déclenche le téléchargement d'une image (wrapper)
  Future<String> downloadImage(String exerciseId)
  
  /// Retourne les statistiques globales du système d'images
  Future<Map<String, dynamic>> getStats()
}
```

**Logique `getImageSource()` (triple-check)** :

```dart
Future<ImageSource> getImageSource(String exerciseId) async {
  // 1. Check assets préchargés
  if (_manifest.hasPreseededImage(exerciseId)) {
    final assetPath = _manifest.getAssetPath(exerciseId)!;
    return ImageSource.asset(assetPath);
  }
  
  // 2. Check stockage local
  if (await _downloader.isDownloaded(exerciseId)) {
    final localPath = await _downloader.getLocalPath(exerciseId);
    return ImageSource.local(localPath!);
  }
  
  // 3. Fallback remote API
  final apiUrl = 'https://api.workoutapi.com/exercises/$exerciseId/image';
  return ImageSource.remote(apiUrl);
}
```

**Modèle `ImageSource`** :

```dart
enum ImageSourceType { asset, local, remote }

class ImageSource {
  final ImageSourceType type;
  final String? path;    // Pour asset et local
  final String? url;     // Pour remote
  
  bool get isAsset => type == ImageSourceType.asset;
  bool get isLocal => type == ImageSourceType.local;
  bool get isRemote => type == ImageSourceType.remote;
  
  factory ImageSource.asset(String path);
  factory ImageSource.local(String path);
  factory ImageSource.remote(String url);
}
```

**Exemple `getStats()` retour** :

```json
{
  "total_exercises": 94,
  "preseeded_images": 20,
  "downloaded_images": 3,
  "storage_size_kb": 14.2,
  "remote_images": 71,
  "quota_used": 23,
  "quota_remaining": 77
}
```

### 4. ExerciseImageWidget (Affichage intelligent)

**Fichier** : `lib/features/exercise_library/widgets/exercise_image_widget.dart`

**Responsabilité** : Afficher images avec téléchargement automatique si nécessaire

**Variants** :

1. **ExerciseImageWidget** : Widget principal avec auto-download
2. **ExerciseImageThumbnail** : Variante liste sans auto-download

**API publique** :

```dart
class ExerciseImageWidget extends StatefulWidget {
  final String exerciseId;
  final double width;
  final double height;
  final String? fallbackEmoji;
  final BorderRadius? borderRadius;
  
  const ExerciseImageWidget({
    required this.exerciseId,
    this.width = double.infinity,
    this.height = 250,
    this.fallbackEmoji,
    this.borderRadius,
  });
}
```

**Lifecycle avec auto-download** :

```dart
class _ExerciseImageWidgetState extends State<ExerciseImageWidget> {
  ImageSource? _imageSource;
  bool _isLoading = false;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadImageSource();
    });
  }
  
  Future<void> _loadImageSource() async {
    final repo = context.read<ExerciseLibraryRepository>();
    final source = await repo.getImageSource(widget.exerciseId);
    
    setState(() => _imageSource = source);
    
    // Auto-téléchargement si remote
    if (source.isRemote) {
      await _downloadImage();
    }
  }
  
  Future<void> _downloadImage() async {
    setState(() => _isLoading = true);
    
    final repo = context.read<ExerciseLibraryRepository>();
    final localPath = await repo.downloadImage(widget.exerciseId);
    
    setState(() {
      _imageSource = ImageSource.local(localPath);
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoadingPlaceholder();
    if (_imageSource == null) return _buildEmojiPlaceholder();
    
    return switch (_imageSource!.type) {
      ImageSourceType.asset => _buildAssetImage(_imageSource!.path!),
      ImageSourceType.local => _buildLocalImage(_imageSource!.path!),
      ImageSourceType.remote => _buildEmojiPlaceholder(), // Ne devrait jamais arriver
    };
  }
  
  Widget _buildAssetImage(String path) {
    return SvgPicture.asset(
      path,
      width: widget.width == double.infinity ? null : widget.width,
      height: widget.height == double.infinity ? null : widget.height,
      fit: BoxFit.cover,
    );
  }
  
  Widget _buildLocalImage(String path) {
    return SvgPicture.file(
      File(path),
      width: widget.width == double.infinity ? null : widget.width,
      height: widget.height == double.infinity ? null : widget.height,
      fit: BoxFit.cover,
    );
  }
}
```

**ExerciseImageThumbnail (variante liste)** :

```dart
class ExerciseImageThumbnail extends StatelessWidget {
  final String exerciseId;
  final double size;
  final String fallbackEmoji;
  
  const ExerciseImageThumbnail({
    required this.exerciseId,
    this.size = 50,
    this.fallbackEmoji = '💪',
  });
  
  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ExerciseLibraryRepository>();
    
    return FutureBuilder<ImageSource>(
      future: repo.getImageSource(exerciseId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildEmojiPlaceholder();
        }
        
        final source = snapshot.data!;
        
        // IMPORTANT: Ne télécharge PAS si remote (évite API calls lors du scroll)
        if (source.isRemote) {
          return _buildEmojiPlaceholder();
        }
        
        return switch (source.type) {
          ImageSourceType.asset => _buildAssetThumbnail(source.path!),
          ImageSourceType.local => _buildLocalThumbnail(source.path!),
          _ => _buildEmojiPlaceholder(),
        };
      },
    );
  }
}
```

---

## 📊 Gestion du quota API

### Limites

- **Quota total** : 100 requêtes par clé API
- **Quota utilisé** : 21/100 (20 préchargés + 1 test)
- **Quota disponible** : 79/100

### Stratégie d'optimisation

1. **Préchargement des top 20** : Consommation unique de 20 requêtes lors du développement
2. **Téléchargement unique** : Chaque exercice consomme 1 requête maximum (persistance permanente)
3. **Liste sans download** : `ExerciseImageThumbnail` n'appelle jamais l'API
4. **Cache permanent** : Les images téléchargées ne consomment plus de quota

### Calcul capacité maximale

```
Capacité totale = 100 exercices max
Préchargés      = 20 exercices (déjà payés)
Disponibles     = 80 exercices téléchargeables
Réserve sécurité = 6 exercices (pour tests/erreurs)
────────────────────────────────────────────
Utilisables     = 74 exercices additionnels
```

**Total système** : 20 (assets) + 74 (téléchargeables) = **94 exercices supportés** ✅

### Monitoring du quota

**Via Repository** :

```dart
final repo = context.read<ExerciseLibraryRepository>();
final stats = await repo.getStats();

print('Quota utilisé: ${stats['quota_used']}/100');
print('Images téléchargées: ${stats['downloaded_images']}');
print('Stockage: ${stats['storage_size_kb']} KB');
```

**Via Downloader** :

```dart
final downloader = ExerciseImageDownloader(apiKey: '...');
final stats = await downloader.getStats();

print('Images téléchargées: ${stats['downloaded_count']}');
print('Taille totale: ${stats['total_size_kb']} KB');
```

**Alertes recommandées** :

```dart
if (stats['quota_remaining'] < 10) {
  // Alerter l'administrateur
  // Considérer augmentation quota ou nettoyage manuel
}
```

### En cas de dépassement quota

1. **Court terme** : Contacter Workout API pour augmentation quota
2. **Long terme** : Migrer vers Firebase Storage ou CDN
3. **Alternative** : Héberger SVG sur serveur propre

---

## 🧪 Tests et validation

### Test unitaire Repository

```dart
void main() {
  group('ExerciseLibraryRepository', () {
    test('getImageSource retourne asset pour exercice préchargé', () async {
      final repo = ExerciseLibraryRepository(/* ... */);
      final source = await repo.getImageSource('f2a4b9d2-41ac-4c5c-bae0-97fc42b6b4c1');
      
      expect(source.type, ImageSourceType.asset);
      expect(source.path, 'assets/exercise_images/f2a4b9d2-41ac-4c5c-bae0-97fc42b6b4c1.svg');
    });
    
    test('getImageSource retourne local après téléchargement', () async {
      final repo = ExerciseLibraryRepository(/* ... */);
      final exerciseId = 'test-exercise-id';
      
      await repo.downloadImage(exerciseId);
      final source = await repo.getImageSource(exerciseId);
      
      expect(source.type, ImageSourceType.local);
      expect(source.path, contains('/exercise_images/'));
    });
  });
}
```

### Test d'intégration Downloader

```dart
void main() {
  group('ExerciseImageDownloader', () {
    late ExerciseImageDownloader downloader;
    
    setUp(() {
      downloader = ExerciseImageDownloader(apiKey: 'test-key');
    });
    
    test('downloadAndSave crée fichier SVG localement', () async {
      final path = await downloader.downloadAndSave('curl-spider-id');
      final file = File(path);
      
      expect(await file.exists(), true);
      expect(path, endsWith('.svg'));
      expect(await file.length(), greaterThan(0));
    });
    
    test('isDownloaded retourne true après téléchargement', () async {
      await downloader.downloadAndSave('curl-spider-id');
      final exists = await downloader.isDownloaded('curl-spider-id');
      
      expect(exists, true);
    });
  });
}
```

### Test manuel (checklist)

- [ ] Liste affiche émojis pour exercices non préchargés
- [ ] Liste affiche images pour exercices préchargés (instantané)
- [ ] Clic sur exercice sans image → Téléchargement + Affichage
- [ ] Retour à la liste → Image maintenant visible dans thumbnail
- [ ] Redémarrage app → Images téléchargées toujours présentes
- [ ] Mode avion → Images préchargées/téléchargées fonctionnent
- [ ] Mode avion → Exercices non téléchargés affichent émoji

---

## 🚀 Production : retrait du code de debug

### Fichiers à nettoyer

#### 1. `exercise_library_detail_screen.dart`

**Ligne ~45** : Retirer emoji debug dans AppBar

```dart
// AVANT (DEBUG)
AppBar(
  title: Text('🔥 DEBUG MODE - ${exercise.name}'),
)

// APRÈS (PRODUCTION)
AppBar(
  title: Text(exercise.name),
)
```

**Lignes ~180-210** : Supprimer `_buildDebugInfo()`

```dart
// SUPPRIMER ENTIÈREMENT
Widget _buildDebugInfo() {
  return FutureBuilder<ImageSource>(
    // ... tout le bloc
  );
}
```

**Ligne ~150** : Retirer appel à `_buildDebugInfo()`

```dart
// AVANT (DEBUG)
Column(
  children: [
    _buildHeroImage(),
    if (kDebugMode) _buildDebugInfo(), // ❌ Supprimer cette ligne
    _buildContent(),
  ],
)

// APRÈS (PRODUCTION)
Column(
  children: [
    _buildHeroImage(),
    _buildContent(),
  ],
)
```

#### 2. `exercise_image_widget.dart`

**Lignes ~280-320** : Supprimer barre de statut debug

```dart
// SUPPRIMER ENTIÈREMENT
Widget _buildDebugStatusBar() {
  return Container(
    // ... tout le bloc
  );
}

Color _getDebugColor() { /* ... */ }
String _getDebugText() { /* ... */ }
```

**Ligne ~250** : Retirer barre de statut dans `build()`

```dart
// AVANT (DEBUG)
Stack(
  children: [
    _buildImage(),
    if (kDebugMode) _buildDebugStatusBar(), // ❌ Supprimer cette ligne
  ],
)

// APRÈS (PRODUCTION)
_buildImage()
```

**Toutes les lignes** : Supprimer tous les `print()` statements

```dart
// ❌ Supprimer tous ces logs
print('ExerciseImageWidget: Loading image source...');
print('ExerciseImageWidget: Image source loaded: $_imageSource');
print('ExerciseImageWidget: Starting download...');
print('ExerciseImageWidget: Download complete');
```

#### 3. `exercise_library_selection_screen.dart`

**Ligne ~420** : Restaurer navigation originale

```dart
// AVANT (DEBUG - Navigation vers détail)
void _onExerciseSelected(ExerciseLibrary exercise) async {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ExerciseLibraryDetailScreen(exercise: exercise),
    ),
  );
}

// APRÈS (PRODUCTION - Navigation vers séance)
void _onExerciseSelected(ExerciseLibrary exercise) async {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => WorkoutSessionScreen(selectedExercise: exercise),
    ),
  );
}
```

### Checklist de déploiement

- [ ] Retirer emoji "🔥 DEBUG MODE" de l'AppBar
- [ ] Supprimer méthode `_buildDebugInfo()` dans detail_screen
- [ ] Supprimer méthode `_buildDebugStatusBar()` dans image_widget
- [ ] Supprimer tous les `print()` dans image_widget
- [ ] Restaurer navigation vers `WorkoutSessionScreen`
- [ ] Vérifier aucune référence à `kDebugMode` restante
- [ ] Tester build release : `flutter build apk --release`
- [ ] Vérifier taille APK (~50 MB + 371 KB images)
- [ ] Tester installation APK sur device physique
- [ ] Vérifier 20 images préchargées instantanées
- [ ] Tester téléchargement d'un nouvel exercice
- [ ] Vérifier persistance après redémarrage
- [ ] Tester mode avion (images préchargées/téléchargées OK)

---

## 🐛 Troubleshooting

### Problème : Image ne s'affiche pas (écran blanc)

**Diagnostic** :

1. Vérifier que l'exercice est bien dans le manifeste (si préchargé)
2. Vérifier le chemin du fichier dans logs
3. Tester si le fichier existe physiquement

**Solution** :

```dart
// Ajouter logs temporaires
final source = await repo.getImageSource(exerciseId);
print('Image source: ${source.type}');
print('Image path: ${source.path}');

if (source.isLocal) {
  final file = File(source.path!);
  print('File exists: ${await file.exists()}');
  print('File size: ${await file.length()} bytes');
}
```

### Problème : "Failed to create image decoder 'unimplemented'"

**Cause** : Tentative d'affichage PNG alors que l'API retourne SVG

**Solution** : Vérifier que tous les widgets utilisent `SvgPicture` et non `Image`

```dart
// ❌ INCORRECT
Image.file(File(path))

// ✅ CORRECT
SvgPicture.file(File(path))
```

### Problème : Erreur "double.infinity"

**Cause** : `SvgPicture` ne supporte pas `double.infinity` pour width/height

**Solution** : Utiliser `null` au lieu de `double.infinity`

```dart
// ❌ INCORRECT
SvgPicture.asset(
  path,
  width: double.infinity,
  height: double.infinity,
)

// ✅ CORRECT
SvgPicture.asset(
  path,
  width: null,  // Prend toute la largeur disponible
  height: null,
)
```

### Problème : Quota API dépassé (HTTP 429)

**Diagnostic** :

```dart
final stats = await repo.getStats();
print('Quota utilisé: ${stats['quota_used'+ ]}/100');
```

**Solutions** :

1. **Court terme** : Supprimer images téléchargées non essentielles

```dart
final downloader = ExerciseImageDownloader(apiKey: '...');
await downloader.clearAll(); // ⚠️ Supprime TOUTES les images téléchargées
```

2. **Moyen terme** : Contacter Workout API pour augmentation quota

3. **Long terme** : Migrer vers stockage propre (Firebase Storage, CDN)

### Problème : Images disparaissent après redémarrage

**Cause** : Utilisation de `getTemporaryDirectory()` au lieu de `getApplicationDocumentsDirectory()`

**Vérification** :

```dart
// Vérifier dans exercise_image_downloader.dart ligne ~80
final appDir = await getApplicationDocumentsDirectory(); // ✅ CORRECT
// PAS getTemporaryDirectory() // ❌ INCORRECT
```

### Problème : Navigation ne va pas sur détail exercice

**Cause** : Code debug redirige vers `WorkoutSessionScreen`

**Solution** : Vérifier restauration navigation production (voir section cleanup)

---

## 📚 Ressources

### Documentation officielle

- [flutter_svg Package](https://pub.dev/packages/flutter_svg)
- [path_provider Package](https://pub.dev/packages/path_provider)
- [shared_preferences Package](https://pub.dev/packages/shared_preferences)
- [Workout API Documentation](https://workoutapi.com/docs)

### Fichiers du projet

- Architecture Firestore : [firestore-architecture.md](firestore-architecture.md)
- Setup Firebase : [firebase-setup-guide.md](firebase-setup-guide.md)
- Tests & Qualité : [tests-and-quality.md](tests-and-quality.md)
- README Exercise Library : [../lib/features/exercise_library/README.md](../lib/features/exercise_library/README.md)

### API Reference interne

- `ExerciseImageManifest` : [exercise_image_manifest.dart](../lib/features/exercise_library/models/exercise_image_manifest.dart)
- `ExerciseImageDownloader` : [exercise_image_downloader.dart](../lib/features/exercise_library/services/exercise_image_downloader.dart)
- `ExerciseLibraryRepository` : [exercise_library_repository.dart](../lib/features/exercise_library/data/repositories/exercise_library_repository.dart)
- `ExerciseImageWidget` : [exercise_image_widget.dart](../lib/features/exercise_library/widgets/exercise_image_widget.dart)

---

## 📝 Changelog

### v1.0.0 (2026-02-18)

- ✅ Système hybride à trois niveaux (assets/local/remote)
- ✅ 20 images SVG préchargées (371 KB)
- ✅ Téléchargement permanent via Application Documents
- ✅ Manifeste SharedPreferences pour tracking
- ✅ Auto-download en écran détail uniquement
- ✅ Optimisation liste avec `ExerciseImageThumbnail`
- ✅ Support format SVG exclusif
- ✅ Gestion quota API (21/100 utilisés)
- ✅ Mode debug avec indicateurs visuels (à retirer en production)

---

**Maintenu par** : Flutter Developer Expert  
**Dernière mise à jour** : 18 février 2026  
**Version** : 1.0.0
