# 🚀 Quick Start - Exercise Library

Guide de démarrage rapide pour tester immédiatement le catalogue d'exercices.

## ⚡ Démarrage en 3 étapes

### 1️⃣ Installer les dépendances (30 sec)

```bash
flutter pub get
```

### 2️⃣ Importer les exercices dans Firestore (30 sec)

```bash
dart scripts/import_workout_api_exercises.dart
```

**Résultat attendu:**
```
🚀 Import des exercices Workout API vers Firestore
✅ Firebase initialisé
✅ 94 exercices trouvés
✅ 94 documents présents dans Firestore
🎉 Import terminé avec succès!
```

### 3️⃣ Lancer l'app (1 min)

```bash
flutter run
```

Le provider est déjà configuré dans `lib/main.dart` ✅

## 🧪 Test rapide

### Option A: Navigation directe

Ajoutez dans n'importe quel écran:

```dart
import 'package:apollon/features/exercise_library/exercise_library.dart';

// Dans votre widget
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ExerciseLibrarySelectionScreen(),
      ),
    );
  },
  child: const Text('Tester le catalogue'),
)
```

### Option B: Test avec sélection

```dart
import 'package:apollon/features/exercise_library/exercise_library.dart';

Future<void> _testExerciseLibrary() async {
  final exercise = await Navigator.push<ExerciseLibrary>(
    context,
    MaterialPageRoute(
      builder: (_) => const ExerciseLibrarySelectionScreen(),
    ),
  );

  if (exercise != null) {
    print('✅ Exercice sélectionné: ${exercise.name}');
    print('📝 Description: ${exercise.description}');
    print('💪 Muscles: ${exercise.primaryMusclesText}');
  }
}
```

## ✅ Checklist de vérification

Après lancement, vérifiez:

- [ ] ✅ 94 exercices s'affichent dans la liste
- [ ] ✅ La recherche fonctionne (tapez "développé")
- [ ] ✅ Les filtres muscles fonctionnent (tap sur un chip)
- [ ] ✅ Les filtres catégories fonctionnent
- [ ] ✅ Le détail s'affiche (tap sur un exercice)
- [ ] ✅ La description complète est visible
- [ ] ✅ Le pull-to-refresh fonctionne

## 🎯 Tests fonctionnels

### Test 1: Recherche

1. Lancez l'écran de sélection
2. Tapez "développé" dans la barre de recherche
3. **Attendu**: ~5-8 exercices affichés (développé couché, militaire, etc.)

### Test 2: Filtre par muscle

1. Tapez sur le chip "Pectoraux"
2. **Attendu**: ~10-15 exercices pour les pectoraux uniquement

### Test 3: Filtre combiné

1. Tapez "curl" dans la recherche
2. Tapez sur "Biceps"
3. **Attendu**: Uniquement les curls biceps

### Test 4: Détail exercice

1. Sélectionnez "Développé couché barre"
2. **Attendu**: 
   - Description complète (150+ mots)
   - Muscles primaires: Pectoraux
   - Muscles secondaires: Épaules, Triceps
   - Équipement: Poids libres

### Test 5: Performance

1. Changez de filtre rapidement
2. Tapez texte dans recherche
3. **Attendu**: Réponse instantanée (< 100ms)

## 🔥 Commandes utiles

### Réimporter les données

```bash
dart scripts/import_workout_api_exercises.dart
```

### Vérifier les erreurs

```bash
flutter analyze
```

### Lancer les tests

```bash
flutter test
```

### Build release

```bash
flutter build apk --release
flutter build ios --release
```

## 📱 Screenshots attendus

### Écran de sélection
- Barre de recherche en haut
- Chips de filtres horizontaux
- Compteur "94 exercices"
- Liste scrollable avec tiles
- Skeleton loader sur images

### Écran de détail
- Image en haut (placeceholder si pas encore téléchargée)
- Nom de l'exercice
- Chips "Muscles primaires", "Équipement"
- Description technique complète
- Bouton "Ajouter à ma séance"

## 🐛 Problèmes courants

### "No exercises found"

**Cause**: Les données ne sont pas importées  
**Solution**: Exécutez `dart scripts/import_workout_api_exercises.dart`

### "Permission denied"

**Cause**: Règles Firestore pas configurées  
**Solution**: Ajoutez dans Firebase Console → Firestore → Rules:
```javascript
match /exercises_library/{exerciseId} {
  allow read: if true;
}
```

### Erreur compilation

**Cause**: Dépendances pas installées  
**Solution**: `flutter pub get` puis `flutter clean`

## 📚 Documentation complète

Pour aller plus loin:

- [README Feature](../lib/features/exercise_library/README.md) - Documentation complète
- [Guide d'intégration](INTEGRATION_GUIDE_EXERCISE_LIBRARY.md) - Intégration détaillée
- [User Story US-003](briefs/USER_STORY_WORKOUT_API_INTEGRATION.md) - Spécifications
- [Brief Technique](briefs/BRIEF_TECHNIQUE_WORKOUT_API_INTEGRATION.md) - Architecture

## 💡 Prochaines étapes

Une fois que tout fonctionne:

1. **Intégrer avec WorkoutProvider** - Ajouter exercices à la séance en cours
2. **Configurer API Workout** - Pour le lazy loading des images
3. **Améliorer l'UI** - Adapter au Design System Liquid Glass
4. **Ajouter analytics** - Tracker les exercices consultés
5. **Implémenter favoris** - Sauvegarder exercices préférés

## 🎉 C'est tout !

Vous avez maintenant un catalogue professionnel de 94 exercices avec:
- ✅ Recherche instantanée
- ✅ Filtres avancés
- ✅ Descriptions complètes
- ✅ Performance optimisée
- ✅ Architecture propre

**Durée totale**: < 5 minutes ⚡

Bon développement ! 🚀

---

**Questions ?** Consultez la [documentation complète](../lib/features/exercise_library/README.md)
