# Design System Liquid Glass - Apollon

Documentation complète du Design System avec effet glassmorphisme pour l'application Apollon.

## 📋 Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Installation](#installation)
3. [Palette de couleurs](#palette-de-couleurs)
4. [Typographie](#typographie)
5. [Widgets réutilisables](#widgets-réutilisables)
6. [Exemples d'utilisation](#exemples-dutilisation)
7. [Bonnes pratiques](#bonnes-pratiques)

---

## Vue d'ensemble

Le Design System Liquid Glass d'Apollon repose sur le principe du **glassmorphisme** : effet de verre semi-transparent avec flou d'arrière-plan, bordures arrondies prononcées, et ombres subtiles.

### Caractéristiques principales

- ✨ **Effet glassmorphisme** : Opacité 60-70% avec flou BackdropFilter
- 🌓 **Support Dark/Light mode** : Gestion automatique des deux modes
- 🎨 **Material 3** : Utilise ColorScheme.fromSeed pour harmonie des couleurs
- ⚡ **Performance 60fps** : Optimisé pour animations fluides
- 📱 **Responsive** : Adaptation automatique aux différentes tailles d'écran

### Structure des fichiers

```
lib/core/
├── theme/
│   ├── app_colors.dart         # Palette de couleurs et ColorScheme
│   ├── app_typography.dart     # Styles de texte (Google Fonts)
│   ├── app_decorations.dart    # Décorations glassmorphisme
│   └── app_theme.dart          # ThemeData complet
└── widgets/
    ├── glass_card.dart         # Cartes avec effet verre
    ├── glass_button.dart       # Boutons (4 variantes)
    ├── glass_text_field.dart   # Champs de saisie
    ├── glass_bottom_sheet.dart # Bottom sheets modaux
    ├── glass_chip.dart         # Chips de sélection
    └── glass_widgets.dart      # Fichier d'export
```

---

## Installation

### 1. Configuration du thème

Dans votre [main.dart](../main.dart), importez et appliquez le thème :

```dart
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apollon',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Suit les préférences système
      home: const HomeScreen(),
    );
  }
}
```

### 2. Import des widgets

Pour utiliser les widgets glassmorphisme :

```dart
import 'package:apollon/core/widgets/glass_widgets.dart';
```

### 3. Dépendances requises

Ajoutez dans [pubspec.yaml](../pubspec.yaml) :

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.1.0  # Pour les polices Inter et JetBrains Mono
```

Puis exécutez :
```bash
flutter pub get
```

---

## Palette de couleurs

### Couleurs principales

Le Design System utilise **Material 3 ColorScheme** généré depuis deux couleurs seed :

```dart
// Couleur primaire : Bleu électrique
Primary: #4A90E2

// Couleur secondaire : Orange énergique
Secondary: #FF6B35
```

### Couleurs de groupe musculaire

14 couleurs mappées aux groupes musculaires pour visualisation :

| Groupe | Couleur | Usage |
|--------|---------|-------|
| **Pectoraux** | `#E74C3C` Rouge | Chips, cartes d'exercices |
| **Dorsaux** | `#3498DB` Bleu | Identification visuelle |
| **Épaules** | `#F39C12` Orange | Chips, graphiques |
| **Biceps** | `#9B59B6` Violet | Catégorisation |
| **Triceps** | `#1ABC9C` Turquoise | Filtres |
| **Avant-bras** | `#34495E` Gris bleuté | Chips secondaires |
| **Quadriceps** | `#E67E22` Orange foncé | Jambes |
| **Ischio-jambiers** | `#C0392B` Rouge foncé | Jambes |
| **Mollets** | `#16A085` Vert eau | Jambes |
| **Fessiers** | `#D35400` Orange brûlé | Jambes |
| **Abdominaux** | `#27AE60` Vert | Core |
| **Lombaires** | `#8E44AD` Violet foncé | Core |
| **Trapèzes** | `#2980B9` Bleu foncé | Dos supérieur |
| **Full body** | `#7F8C8D` Gris | Exercices complets |

### Usage des couleurs

```dart
import 'package:apollon/core/theme/app_colors.dart';

// Utiliser une couleur de groupe musculaire
final muscleColor = AppColors.muscleGroupColors['pectoraux'];

// Utiliser les couleurs glassmorphisme
Container(
  color: AppColors.glassLightBackground, // En mode clair
  // ou
  color: AppColors.glassDarkBackground,  // En mode sombre
)
```

### Opacités glassmorphisme

```dart
// Opacité pour surfaces vitrées
const glassOpacityLight = 0.70; // Mode clair
const glassOpacityDark = 0.60;  // Mode sombre

// Opacité pour overlays
const overlayOpacityLight = 0.15;
const overlayOpacityDark = 0.25;
```

---

## Typographie

### Polices utilisées

- **Google Fonts Inter** : Police principale pour l'UI
- **JetBrains Mono** : Nombres (poids, répétitions, statistiques)

### Styles de texte

```dart
import 'package:apollon/core/theme/app_typography.dart';

// Titres
Text('Grand titre', style: AppTypography.displayLarge(context))
Text('Titre de section', style: AppTypography.headlineMedium(context))
Text('Titre de carte', style: AppTypography.titleLarge(context))

// Corps de texte
Text('Texte principal', style: AppTypography.bodyLarge(context))
Text('Texte secondaire', style: AppTypography.bodyMedium(context))
Text('Légende', style: AppTypography.bodySmall(context))

// Labels
Text('Label', style: AppTypography.labelLarge(context))

// Styles spéciaux
Text('12', style: AppTypography.numberStyle(context)) // Nombres avec JetBrains Mono
Text('💪', style: AppTypography.emojiStyle(context))  // Emojis uniformes
```

### Hiérarchie typographique

| Style | Taille | Poids | Usage |
|-------|---------|-------|-------|
| Display Large | 57px | 400 | Splash screen, hero |
| Headline Large | 32px | 600 | Titres de page |
| Title Large | 22px | 600 | Titres de section |
| Body Large | 16px | 400 | Texte principal |
| Body Medium | 14px | 400 | Texte secondaire |
| Label Large | 14px | 500 | Labels de champs |

---

## Widgets réutilisables

### 1. GlassCard

Carte avec effet glassmorphisme pour contenir du contenu.

#### Propriétés

| Propriété | Type | Description |
|-----------|------|-------------|
| `child` | `Widget` | Contenu de la carte |
| `borderRadius` | `BorderRadius?` | Rayon de bordure (défaut: large 24px) |
| `backgroundColor` | `Color?` | Couleur de fond personnalisée |
| `padding` | `EdgeInsets?` | Padding interne |
| `margin` | `EdgeInsets?` | Marge externe |
| `onTap` | `VoidCallback?` | Callback au tap |
| `showShadow` | `bool` | Affiche ombre portée (défaut: true) |

#### Exemples

```dart
// Card simple
GlassCard(
  padding: EdgeInsets.all(16),
  child: Text('Contenu de la carte'),
)

// Card interactive
GlassCard(
  padding: EdgeInsets.all(20),
  margin: EdgeInsets.all(16),
  onTap: () => print('Tapped!'),
  child: Column(
    children: [
      Text('Développé couché', style: AppTypography.titleMedium(context)),
      SizedBox(height: 8),
      Text('4 séries • 12 reps', style: AppTypography.bodyMedium(context)),
    ],
  ),
)

// Card animée
AnimatedGlassCard(
  scaleFactor: 1.05, // Échelle au hover
  onTap: () => navigateToExercise(),
  child: ListTile(
    leading: Text('💪', style: AppTypography.emojiStyle(context)),
    title: Text('Curl biceps'),
    subtitle: Text('Biceps'),
  ),
)
```

### 2. GlassButton

Boutons avec effet glassmorphisme en 4 variantes.

#### Variantes

1. **Primary** : Bouton principal (fond coloré)
2. **Secondary** : Bouton secondaire (fond coloré secondaire)
3. **Outlined** : Bouton avec bordure uniquement
4. **Text** : Bouton texte transparent

#### Propriétés

| Propriété | Type | Description |
|-----------|------|-------------|
| `label` | `String` | Texte du bouton |
| `onPressed` | `VoidCallback?` | Callback au tap |
| `type` | `GlassButtonType` | Type de bouton |
| `leadingIcon` | `IconData?` | Icône à gauche |
| `trailingIcon` | `IconData?` | Icône à droite |
| `isLoading` | `bool` | Affiche indicateur de chargement |
| `height` | `double` | Hauteur (défaut: 56px) |

#### Exemples

```dart
// Bouton primary
GlassButton.primary(
  label: 'Confirmer',
  leadingIcon: Icons.check,
  onPressed: () => confirmAction(),
)

// Bouton secondary
GlassButton.secondary(
  label: 'Annuler',
  onPressed: () => Navigator.pop(context),
)

// Bouton outlined
GlassButton.outlined(
  label: 'Voir détails',
  trailingIcon: Icons.arrow_forward,
  onPressed: () => showDetails(),
)

// Bouton avec chargement
GlassButton.primary(
  label: 'Enregistrer',
  isLoading: isSubmitting,
  onPressed: isSubmitting ? null : () => submitWorkout(),
)

// Icon button
GlassIconButton(
  icon: Icons.add,
  type: GlassButtonType.primary,
  onPressed: () => addExercise(),
)
```

### 3. GlassTextField

Champs de saisie avec effet glassmorphisme.

#### Propriétés

| Propriété | Type | Description |
|-----------|------|-------------|
| `controller` | `TextEditingController?` | Controller du champ |
| `label` | `String?` | Label au-dessus du champ |
| `hintText` | `String?` | Texte d'indication |
| `prefixIcon` | `IconData?` | Icône de préfixe |
| `suffixIcon` | `IconData?` | Icône de suffixe |
| `keyboardType` | `TextInputType` | Type de clavier |
| `obscureText` | `bool` | Masque le texte (mot de passe) |
| `errorText` | `String?` | Message d'erreur |
| `helperText` | `String?` | Texte d'aide |

#### Constructeurs spécialisés

```dart
// Champ nombre entier
GlassTextField.number(
  label: 'Répétitions',
  hintText: 'Ex: 12',
  controller: repsController,
)

// Champ poids (décimal avec suffixe "kg")
GlassTextField.weight(
  label: 'Poids',
  hintText: 'Ex: 80.5',
  controller: weightController,
)

// Champ texte multiligne
GlassTextArea(
  label: 'Notes',
  hintText: 'Ajoutez vos observations...',
  lines: 5,
  controller: notesController,
)
```

#### Exemples

```dart
// Champ de texte simple
GlassTextField(
  label: 'Nom de l\'exercice',
  hintText: 'Ex: Développé couché',
  prefixIcon: Icons.fitness_center,
  controller: nameController,
)

// Champ de nombre avec validation
GlassTextField.number(
  label: 'Répétitions',
  hintText: 'Entrez le nombre de répétitions',
  controller: repsController,
  errorText: repsError, // Affiche erreur si RG-003 violé
  helperText: 'Minimum 1 répétition',
)

// Champ de poids
GlassTextField.weight(
  label: 'Poids utilisé',
  hintText: '0',
  controller: weightController,
  helperText: 'Laissez vide si poids de corps',
)
```

### 4. GlassBottomSheet

Modal bottom sheet avec effet glassmorphisme.

#### Propriétés

| Propriété | Type | Description |
|-----------|------|-------------|
| `child` | `Widget` | Contenu du bottom sheet |
| `title` | `String?` | Titre affiché en haut |
| `actions` | `List<Widget>?` | Actions (boutons) en haut à droite |
| `maxHeight` | `double?` | Hauteur max (défaut: 80% écran) |
| `showDragHandle` | `bool` | Affiche poignée de glissement |
| `scrollable` | `bool` | Contenu scrollable |

#### Exemples

```dart
// Bottom sheet simple
GlassBottomSheet.show(
  context: context,
  title: 'Sélectionner un exercice',
  child: ExerciseListWidget(),
)

// Bottom sheet avec recherche
GlassSelectionBottomSheet.show<Exercise>(
  context: context,
  title: 'Exercices',
  searchHint: 'Rechercher un exercice...',
  items: exercises,
  itemBuilder: (context, exercise) => ListTile(
    leading: Text(exercise.emoji),
    title: Text(exercise.name),
    subtitle: Text(exercise.muscleGroups.join(', ')),
  ),
  searchFilter: (exercise, query) =>
      exercise.name.toLowerCase().contains(query),
  onItemSelected: (exercise) =>
      print('Selected: ${exercise.name}'),
)
```

### 5. GlassChip

Chips avec effet glassmorphisme pour tags et filtres.

#### Propriétés

| Propriété | Type | Description |
|-----------|------|-------------|
| `label` | `String` | Texte du chip |
| `onTap` | `VoidCallback?` | Callback au tap |
| `isSelected` | `bool` | Chip sélectionné |
| `leadingIcon` | `IconData?` | Icône à gauche |
| `onDeleted` | `VoidCallback?` | Callback suppression |
| `backgroundColor` | `Color?` | Couleur de fond |

#### Variantes

```dart
// Chip simple
GlassChip(
  label: 'Pectoraux',
  onTap: () => filterByMuscle('pectoraux'),
)

// Chip sélectionné
GlassChip(
  label: 'Dorsaux',
  isSelected: true,
  leadingIcon: Icons.check,
  backgroundColor: AppColors.muscleGroupColors['dorsaux'],
)

// Chip filtrable
GlassFilterChip<String>(
  label: 'Force',
  value: 'force',
  selectedValue: currentFilter,
  onSelected: (value) => setState(() => currentFilter = value),
)

// Chip de statut
GlassStatusChip(
  label: 'Complété',
  statusColor: Colors.green,
)

// Groupe de chips
GlassChipGroup<String>(
  items: ['Pectoraux', 'Dorsaux', 'Épaules'],
  selectedValues: selectedMuscles,
  multipleSelection: true,
  onSelected: (muscle) => toggleMuscle(muscle),
  chipBuilder: (context, muscle, isSelected) => GlassChip(
    label: muscle,
    isSelected: isSelected,
    backgroundColor: AppColors.muscleGroupColors[muscle.toLowerCase()],
  ),
)
```

---

## Exemples d'utilisation

### Écran de sélection d'exercice

```dart
class ExerciseSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sélectionner exercice'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Barre de recherche
            GlassTextField(
              hintText: 'Rechercher...',
              prefixIcon: Icons.search,
              onChanged: (value) => searchExercises(value),
            ),
            
            SizedBox(height: 16),
            
            // Filtres par groupe musculaire
            GlassChipGroup(
              items: muscleGroups,
              selectedValues: selectedGroups,
              multipleSelection: true,
              onSelected: (group) => toggleGroup(group),
              chipBuilder: (context, group, isSelected) => GlassChip(
                label: group,
                isSelected: isSelected,
                backgroundColor: AppColors.muscleGroupColors[group],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Liste d'exercices
            Expanded(
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: AnimatedGlassCard(
                      onTap: () => selectExercise(exercise),
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text(
                            exercise.emoji,
                            style: AppTypography.emojiStyle(context),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exercise.name,
                                  style: AppTypography.titleMedium(context),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  exercise.muscleGroups.join(', '),
                                  style: AppTypography.bodySmall(context),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Écran d'enregistrement de série

```dart
class SetInputScreen extends StatefulWidget {
  @override
  _SetInputScreenState createState() => _SetInputScreenState();
}

class _SetInputScreenState extends State<SetInputScreen> {
  final repsController = TextEditingController();
  final weightController = TextEditingController();
  String? repsError;
  
  void validateAndSubmit() {
    final reps = int.tryParse(repsController.text);
    final weight = double.tryParse(weightController.text) ?? 0;
    
    // RG-003: Validation répétitions > 0
    if (reps == null || reps <= 0) {
      setState(() => repsError = 'Les répétitions doivent être > 0');
      return;
    }
    
    // RG-003: Validation poids >= 0
    if (weight < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Le poids doit être ≥ 0')),
      );
      return;
    }
    
    // Soumission
    submitSet(reps, weight);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter série'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Carte d'exercice
            GlassCard(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Text('💪', style: AppTypography.emojiStyle(context)),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Développé couché',
                          style: AppTypography.titleLarge(context),
                        ),
                        SizedBox(height: 4),
                        GlassChip(
                          label: 'Pectoraux',
                          backgroundColor: AppColors.muscleGroupColors['pectoraux'],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Champ répétitions
            GlassTextField.number(
              label: 'Répétitions',
              hintText: 'Ex: 12',
              controller: repsController,
              errorText: repsError,
              helperText: 'Minimum 1 répétition (RG-003)',
            ),
            
            SizedBox(height: 16),
            
            // Champ poids
            GlassTextField.weight(
              label: 'Poids',
              hintText: '0',
              controller: weightController,
              helperText: 'Laissez vide si poids de corps',
            ),
            
            Spacer(),
            
            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: GlassButton.outlined(
                    label: 'Annuler',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: GlassButton.primary(
                    label: 'Ajouter',
                    leadingIcon: Icons.check,
                    onPressed: validateAndSubmit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Bonnes pratiques

### 1. Performance

#### ✅ Faire
- Limiter l'usage du `BackdropFilter` (coûteux en GPU)
- Utiliser `const` pour les widgets statiques
- Préférer `AnimatedGlassCard` pour interactions fréquentes

#### ❌ Éviter
- Imbriquer plusieurs `BackdropFilter` (< 2 niveaux)
- Utiliser `BackdropFilter` dans des `ListView` avec beaucoup d'items
- Animer le `sigmaX/Y` du blur en continu

### 2. Accessibilité

#### ✅ Faire
- Assurer contraste de 4.5:1 minimum pour texte
- Fournir feedback tactile (vibration) sur interactions
- Supporter tailles de police dynamiques

```dart
// Bon contraste
Text(
  'Label',
  style: AppTypography.bodyLarge(context).copyWith(
    color: Theme.of(context).colorScheme.onSurface, // Contraste garanti
  ),
)
```

### 3. Cohérence visuelle

#### ✅ Faire
- Utiliser les widgets Glass* plutôt que créer custom
- Respecter les espacements définis (AppDecorations.spacing*)
- Utiliser les bordures arrondies standard (borderRadius*)

```dart
// Utiliser les constantes du Design System
Padding(
  padding: EdgeInsets.all(AppDecorations.spacingMedium), // 16px
  child: GlassCard(
    borderRadius: AppDecorations.borderRadiusLarge, // 24px
    child: content,
  ),
)
```

### 4. États interactifs

#### ✅ Faire
- Toujours fournir feedback visuel au tap
- Désactiver boutons pendant chargement (`isLoading: true`)
- Afficher messages d'erreur avec `errorText`

```dart
// Bon feedback utilisateur
GlassButton.primary(
  label: 'Soumettre',
  isLoading: isSubmitting,
  onPressed: isSubmitting ? null : () => submit(),
)
```

### 5. Validation des formulaires

#### ✅ Faire
- Valider côté client pour feedback immédiat
- Afficher messages d'erreur clairs et contextuels
- Bloquer soumission si validation échoue

```dart
// Validation RG-003
void validateReps() {
  final reps = int.tryParse(repsController.text);
  if (reps == null || reps <= 0) {
    setState(() => repsError = 'Les répétitions doivent être > 0 (RG-003)');
  } else {
    setState(() => repsError = null);
  }
}
```

---

## Support

Pour toute question sur le Design System :

1. Consulter les exemples dans ce document
2. Lire les commentaires dans les fichiers source
3. Référencer les règles de gestion (RG-*) dans [README.md](../README.md)

---

**Version** : 1.0.0  
**Dernière mise à jour** : Janvier 2025  
**Mainteneur** : Équipe Apollon
