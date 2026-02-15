# Design System Apollon - Moderne Material 3

Documentation complète du Design System moderne pour l'application Apollon.

## ✨ Design System Moderne et Clean

Le Design System Apollon utilise **Material 3** avec un style moderne et épuré, sans effets de glassmorphisme.

**Caractéristiques :**
- 🎨 **Material 3 pur** : Design moderne et cohérent
- 🌓 **Dark/Light mode** : Support complet des deux thèmes
- ⚡ **Performance** : Pas de blur, animations fluides 60fps
- 📱 **Responsive** : Adaptation automatique
- 🔄 **Border radius 24px** : Arrondis consistants partout

### Widgets disponibles

**AppCard** - 3 variants :
- `standard` : Card avec subtle shadow (défaut)
- `elevated` : Card avec shadow prononcée et élévation 8
- `outlined` : Card avec bordure uniquement

**AppButton** - 4 variants :
- `primary` : Bouton principal coloré avec shadow
- `secondary` : Bouton secondaire avec surface container
- `outlined` : Bordure uniquement, fond transparent
- `text` : Texte uniquement, pas de fond

**CircularProgressButton** :
- Bouton circulaire FAB avec arc de progression
- Affiche pourcentage d'avancement de la séance (0-100%)
- Dual shadow (primary glow + black drop)
- Border 3px, stroke width 14px

**ProfileDrawer** :
- Side drawer élégant pour profil utilisateur
- Gradient header avec avatar/nom/email
- Options de navigation et déconnexion
- ThemeSwitcher intégré
- Context-safe logout avec gestion workout actif

**Page Transitions** :
- 5 types de transitions réutilisables
- `fadeSlide`, `slideRight`, `slideUp`, `fade`, `scale`
- Utilisation via `AppPageRoute.fadeSlide(builder: ...)`

**AppTextField** :
- Input Material 3 standard
- `AppNumberField` variant pour saisie numérique

**AppBackground** :
- Gradient subtil entre background et surface

**ThemeSwitcher** :
- Widget complet pour changer Dark/Light/System
- Intégration avec ThemeProvider

**Utilisation :**
```dart
import 'package:apollon/core/widgets/widgets.dart';

// Card
AppCard(
  child: Text('Contenu'),
)

// Bouton
AppButton(
  text: 'Action',
  variant: AppButtonVariant.primary,
  onPressed: () {},
)

// TextField
AppTextField(
  labelText: 'Label',
  hintText: 'Hint',
)

// Background
Scaffold(
  body: AppBackground(
    child: YourContent(),
  ),
)
```

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

Le Design System Apollon utilise **Material 3** avec un style moderne et épuré, privilégiant les ombres et élévations plutôt que les effets de blur pour une meilleure performance et lisibilité.

### Caractéristiques principales

- 🎨 **Material 3 pur** : Design moderne cohérent avec les guidelines Google
- 🌓 **Support Dark/Light mode** : Gestion automatique des deux modes
- 🔄 **Border radius 24px** : Arrondis consistants sur tous les widgets
- ⚡ **Performance 60fps** : Sans blur, animations ultra-fluides
- 📱 **Responsive** : Adaptation automatique aux différentes tailles d'écran
- ♿ **Accessible** : Contraste optimisé, tailles de text adaptatives

### Structure des fichiers

```
lib/core/
├── theme/
│   ├── app_theme.dart          # ThemeData complet Dark/Light avec Material 3
│   ├── app_colors.dart         # ColorScheme et couleurs muscle groups
│   ├── app_typography.dart     # TextTheme avec Raleway + JetBrains Mono
│   └── app_decorations.dart    # Border radius, shadows, spacing
├── providers/
│   ├── auth_provider.dart      # Authentification Google
│   ├── theme_provider.dart     # Gestion du thème (Dark/Light/System)
│   └── workout_provider.dart   # Gestion workout + timer
├── utils/
│   └── page_transitions.dart   # 5 types de transitions réutilisables
└── widgets/
    ├── app_bar.dart            # AppBar et SliverAppBar modernes
    ├── app_background.dart     # Background avec gradient subtil
    ├── app_button.dart         # Boutons (4 variants) + animations
    ├── app_card.dart           # Cards (3 variants) + élévations
    ├── app_text_field.dart     # Input fields Material 3
    ├── circular_progress_button.dart  # Bouton FAB avec progress arc
    ├── profile_drawer.dart     # Side drawer profil utilisateur
    ├── theme_switcher.dart     # Widget pour changer le thème
    ├── workout_timer_app_bar.dart  # AppBar avec chrono workout
    └── widgets.dart            # Barrel export file
```

---

## Installation

### 1. Configuration du thème avec ThemeProvider

Dans votre [main.dart](../main.dart), initialisez le ThemeProvider :

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/providers/theme_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialiser le ThemeProvider
  final themeProvider = ThemeProvider();
  await themeProvider.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        // ... autres providers
      ],
      child: const ApolloApp(),
    ),
  );
}
```

Dans votre [app.dart](../lib/app.dart) :

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';

class ApolloApp extends StatelessWidget {
  const ApolloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Apollon',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode, // Géré par le provider
          home: const HomeScreen(),
        );
      },
    );
  }
}
```

### 2. Import des widgets

Pour utiliser les widgets Apollon :

```dart
// Import global de tous les widgets
import 'package:apollon/core/widgets/widgets.dart';

// Ou imports individuels
import 'package:apollon/core/widgets/app_button.dart';
import 'package:apollon/core/widgets/app_card.dart';
import 'package:apollon/core/widgets/app_text_field.dart';
import 'package:apollon/core/widgets/app_bar.dart';
import 'package:apollon/core/widgets/app_background.dart';
import 'package:apollon/core/widgets/theme_switcher.dart';
```

### 3. Dépendances requises

Ajoutez dans [pubspec.yaml](../pubspec.yaml) :

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  google_sign_in: ^6.1.6
  
  # State Management
  provider: ^6.1.1
  
  # Persistence (pour ThemeProvider)
  shared_preferences: ^2.2.2
  
  # Google Fonts pour le Design System
  google_fonts: ^6.1.0
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
// Couleur primaire : Bleu Material Design moderne
Primary: #1E88E5

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

// Utiliser les couleurs du thème
Container(
  color: Theme.of(context).colorScheme.surface,
  // ou
  color: Theme.of(context).colorScheme.primary,
)
```

### Opacités Material 3

```dart
// Opacités pour états interactifs (Material 3)
const hoverOpacity = 0.08;   // Hover
const pressOpacity = 0.12;   // Press
const focusOpacity = 0.12;   // Focus
const selectedOpacity = 0.12; // Selected
```

---

## Typographie

### Polices utilisées

- **Google Fonts Raleway** : Police principale pour l'UI (poids 100-900)
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

### 1. AppCard

Carte moderne Material 3 pour contenir du contenu.

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
AppCard(
  padding: EdgeInsets.all(16),
  child: Text('Contenu de la carte'),
)

// Card interactive
AppCard(
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
AppCard(
  scaleFactor: 1.05, // Échelle au hover
  onTap: () => navigateToExercise(),
  child: ListTile(
    leading: Text('💪', style: AppTypography.emojiStyle(context)),
    title: Text('Curl biceps'),
    subtitle: Text('Biceps'),
  ),
)
```

### 2. AppButton

Boutons moderne Material 3 en 4 variantes.

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
| `type` | `AppButtonType` | Type de bouton |
| `leadingIcon` | `IconData?` | Icône à gauche |
| `trailingIcon` | `IconData?` | Icône à droite |
| `isLoading` | `bool` | Affiche indicateur de chargement |
| `height` | `double` | Hauteur (défaut: 56px) |

#### Exemples

```dart
// Bouton primary
AppButton.primary(
  label: 'Confirmer',
  leadingIcon: Icons.check,
  onPressed: () => confirmAction(),
)

// Bouton secondary
AppButton.secondary(
  label: 'Annuler',
  onPressed: () => Navigator.pop(context),
)

// Bouton outlined
AppButton.outlined(
  label: 'Voir détails',
  trailingIcon: Icons.arrow_forward,
  onPressed: () => showDetails(),
)

// Bouton avec chargement
AppButton.primary(
  label: 'Enregistrer',
  isLoading: isSubmitting,
  onPressed: isSubmitting ? null : () => submitWorkout(),
)

// Icon button
AppButton(
  icon: Icons.add,
  type: AppButtonType.primary,
  onPressed: () => addExercise(),
)
```

### 3. AppTextField

Champs de saisie moderne Material 3.

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
// Champ nombre entier (répétitions)
AppNumberField(
  label: 'Répétitions',
  hintText: 'Ex: 12',
  controller: repsController,
)

// Champ poids (décimal)
AppNumberField(
  label: 'Poids (kg)',
  hintText: 'Ex: 80.5',
  controller: weightController,
  allowDecimal: true,
)
```

#### Exemples

```dart
// Champ de texte simple
AppTextField(
  label: 'Nom de l\'exercice',
  hintText: 'Ex: Développé couché',
  prefixIcon: Icons.fitness_center,
  controller: nameController,
)

// Champ de nombre avec validation
AppNumberField(
  label: 'Répétitions',
  hintText: 'Entrez le nombre de répétitions',
  controller: repsController,
  helperText: 'Minimum 1 répétition (RG-003)',
)

// Champ de poids
AppNumberField(
  label: 'Poids utilisé (kg)',
  hintText: '0',
  controller: weightController,
  allowDecimal: true,
  helperText: 'Laissez vide si poids de corps',
)
```

### 4. CircularProgressButton

Bouton circulaire (FAB) avec arc de progression pour afficher l'avancement d'une séance.

#### Propriétés

| Propriété | Type | Description |
|-----------|------|-------------|
| `progress` | `double` | Progression 0.0 à 1.0 |
| `size` | `double` | Taille du bouton (défaut: 120px) |
| `icon` | `IconData` | Icône centrale |
| `onPressed` | `VoidCallback?` | Callback au tap |
| `label` | `String?` | Label sous l'icône |

#### Exemples

```dart
// Bouton avec progress pour workout
CircularProgressButton(
  progress: elapsedMinutes / 60, // 0-100% sur 60 min
  icon: Icons.fitness_center,
  label: 'NOUVELLE\nSÉANCE',
  onPressed: () => startWorkout(),
)

// Bouton sans progress (début de séance)
CircularProgressButton(
  progress: 0.0,
  icon: Icons.play_arrow,
  onPressed: () => beginWorkout(),
)

// Bouton avec progress à 75%
CircularProgressButton(
  progress: 0.75,
  icon: Icons.fitness_center,
  label: '45 min',
  onPressed: () => continueWorkout(),
)
```

### 5. ProfileDrawer

Side drawer élégant pour le profil utilisateur avec gestion du thème et déconnexion.

#### Caractéristiques

- **Header gradient** : Avatar, nom, email avec dégradé primary
- **ThemeSwitcher intégré** : Dark/Light/System mode
- **Options navigation** : Paramètres, Historique, Statistiques, etc.
- **Déconnexion sécurisée** : Capture des providers avant fermeture du drawer
- **Gestion workout actif** : Annule automatiquement workout en cours avant logout

#### Exemples

```dart
// Dans le Scaffold
Scaffold(
  appBar: AppBar(
    title: Text('Apollon'),
  ),
  endDrawer: ProfileDrawer(), // Drawer à droite
  body: YourContent(),
)

// Ouvrir le drawer programmatiquement
Scaffold.of(context).openEndDrawer();

// Le drawer gère automatiquement :
// - Affichage info utilisateur (authProvider)
// - Switch de thème (themeProvider)
// - Annulation workout si actif (workoutProvider)
// - Déconnexion sécurisée
```

### 6. Page Transitions

Système de transitions réutilisables pour navigation fluide.

#### Types disponibles

1. **fadeSlide** : Fade + slide from bottom (défaut)
2. **slideRight** : Slide depuis la droite
3. **slideUp** : Slide depuis le bas
4. **fade** : Simple fade
5. **scale** : Scale + fade

#### Propriétés

| Propriété | Type | Description |
|-----------|------|-------------|
| `builder` | `WidgetBuilder` | Builder de la page destination |
| `duration` | `Duration?` | Durée de l'animation (défaut: 300ms) |
| `curve` | `Curve?` | Courbe d'animation (défaut: easeInOut) |

#### Exemples

```dart
import 'package:apollon/core/utils/page_transitions.dart';

// Transition fadeSlide (recommandée pour pages principales)
Navigator.of(context).push(
  AppPageRoute.fadeSlide(
    builder: (context) => ExerciseSelectionScreen(),
  ),
);

// Transition slideRight (retour arrière, drill-down)
Navigator.of(context).push(
  AppPageRoute.slideRight(
    builder: (context) => WorkoutSessionScreen(exercise: exercise),
    duration: Duration(milliseconds: 250),
  ),
);

// Transition slideUp (modals, overlays)
Navigator.of(context).push(
  AppPageRoute.slideUp(
    builder: (context) => SettingsScreen(),
  ),
);

// Transition fade (changements subtils)
Navigator.of(context).push(
  AppPageRoute.fade(
    builder: (context) => ProfileScreen(),
  ),
);

// Transition scale (focus attention)
Navigator.of(context).push(
  AppPageRoute.scale(
    builder: (context) => WorkoutCompletedScreen(),
  ),
);
```

### 7. WorkoutTimerAppBar

AppBar spécialisée affichant le chrono de workout en cours.

#### Caractéristiques

- Affiche durée écoulée (HH:MM:SS)
- Mise à jour automatique chaque seconde
- Action "Terminer" la séance
- Dialog de confirmation avant annulation

#### Exemples

```dart
// Dans un Scaffold pendant workout
Scaffold(
  appBar: WorkoutTimerAppBar(
    title: 'Séance en cours',
  ),
  body: WorkoutContent(),
)

// Le timer s'affiche automatiquement si workout actif
// Format : "1:23:45" (heures:minutes:secondes)
```

### 8. AppTextField

Champs de saisie moderne Material 3.

#### Propriétés

### 8. AppNumberField

Champ spécialisé pour la saisie de nombres (répétitions, poids).

#### Propriétés

| Propriété | Type | Description |
|-----------|------|-------------|
| `controller` | `TextEditingController?` | Controller du champ |
| `label` | `String?` | Label au-dessus du champ |
| `hintText` | `String?` | Texte d'indication |
| `allowDecimal` | `bool` | Autorise les décimales (défaut: false) |
| `helperText` | `String?` | Texte d'aide |

---

## Exemples d'utilisation

### Écran de sélection d'exercice

```dart
class ExerciseSelectionScreen extends StatefulWidget {
  @override
  _ExerciseSelectionScreenState createState() => _ExerciseSelectionScreenState();
}

class _ExerciseSelectionScreenState extends State<ExerciseSelectionScreen> {
  final searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sélectionner exercice'),
      ),
      body: AppBackground(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Barre de recherche
              AppTextField(
                controller: searchController,
                hintText: 'Rechercher...',
                prefixIcon: Icons.search,
                onChanged: (value) => setState(() => searchQuery = value),
              ),
              
              SizedBox(height: 16),
              
              // Liste d'exercices
              Expanded(
                child: ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    
                    // Filtre par recherche
                    if (searchQuery.isNotEmpty &&
                        !exercise.name.toLowerCase().contains(searchQuery.toLowerCase())) {
                      return SizedBox.shrink();
                    }
                    
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        variant: AppCardVariant.standard,
                        onTap: () {
                          Navigator.of(context).push(
                            AppPageRoute.slideRight(
                              builder: (context) => WorkoutSessionScreen(
                                exercise: exercise,
                              ),
                            ),
                          );
                        },
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Icône circulaire avec couleur du groupe musculaire
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.muscleGroupColors[
                                  exercise.primaryMuscleGroup.toLowerCase()
                                ]?.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.fitness_center,
                                color: AppColors.muscleGroupColors[
                                  exercise.primaryMuscleGroup.toLowerCase()
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise.name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    exercise.muscleGroups.join(', '),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
      ),
    );
  }
}
```

### Page d'accueil avec CircularProgressButton

```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Apollon'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.person),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: ProfileDrawer(),
      body: AppBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bouton principal avec progress
              CircularProgressButton(
                progress: workoutProvider.hasActiveWorkout
                    ? workoutProvider.elapsedMinutes / 60
                    : 0.0,
                icon: Icons.fitness_center,
                label: workoutProvider.hasActiveWorkout
                    ? 'CONTINUER\nSÉANCE'
                    : 'NOUVELLE\nSÉANCE',
                size: 140,
                onPressed: () {
                  if (!workoutProvider.hasActiveWorkout) {
                    workoutProvider.startNewWorkout();
                  }
                  
                  Navigator.of(context).push(
                    AppPageRoute.fadeSlide(
                      builder: (context) => ExerciseSelectionScreen(),
                    ),
                  );
                },
              ),
              
              SizedBox(height: 32),
              
              // Statistiques rapides
              if (workoutProvider.hasActiveWorkout)
                AppCard(
                  variant: AppCardVariant.standard,
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer, color: Theme.of(context).colorScheme.primary),
                      SizedBox(width: 12),
                      Text(
                        workoutProvider.formattedElapsedTime,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontFamily: 'JetBrainsMono',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Écran d'enregistrement de série

```dart
class WorkoutSessionScreen extends StatefulWidget {
  final Exercise exercise;
  
  const WorkoutSessionScreen({required this.exercise});
  
  @override
  _WorkoutSessionScreenState createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  final repsController = TextEditingController();
  final weightController = TextEditingController();
  bool isSubmitting = false;
  
  Future<void> _addSet() async {
    final reps = int.tryParse(repsController.text);
    final weight = double.tryParse(weightController.text) ?? 0;
    
    // RG-003: Validation répétitions > 0
    if (reps == null || reps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Les répétitions doivent être > 0 (RG-003)')),
      );
      return;
    }
    
    // RG-003: Validation poids >= 0
    if (weight < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Le poids doit être ≥ 0 (RG-003)')),
      );
      return;
    }
    
    // Soumission
    setState(() => isSubmitting = true);
    
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    await workoutProvider.addSet(
      widget.exercise.id,
      reps,
      weight,
      exerciseName: widget.exercise.name,
    );
    
    setState(() => isSubmitting = false);
    
    // Reset des champs
    repsController.clear();
    weightController.clear();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Série ajoutée !')),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WorkoutTimerAppBar(
        title: widget.exercise.name,
      ),
      body: AppBackground(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Card info exercice
              AppCard(
                variant: AppCardVariant.elevated,
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Icône avec couleur groupe musculaire
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.muscleGroupColors[
                          widget.exercise.primaryMuscleGroup.toLowerCase()
                        ]?.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        size: 28,
                        color: AppColors.muscleGroupColors[
                          widget.exercise.primaryMuscleGroup.toLowerCase()
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.exercise.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            widget.exercise.muscleGroups.join(', '),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Champs de saisie
              AppCard(
                variant: AppCardVariant.standard,
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Nouvelle série',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Champ répétitions
                    AppNumberField(
                      label: 'Répétitions',
                      hintText: '12',
                      controller: repsController,
                      helperText: 'Minimum 1 répétition (RG-003)',
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Champ poids
                    AppNumberField(
                      label: 'Poids (kg)',
                      hintText: '0',
                      controller: weightController,
                      allowDecimal: true,
                      helperText: 'Laissez vide si poids de corps',
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Bouton ajouter
                    AppButton(
                      text: 'Ajouter série',
                      variant: AppButtonVariant.primary,
                      icon: Icons.add,
                      isLoading: isSubmitting,
                      onPressed: isSubmitting ? null : _addSet,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Historique des séries (si disponible)
              Expanded(
                child: Consumer<WorkoutProvider>(
                  builder: (context, workoutProvider, child) {
                    final sets = workoutProvider.getCurrentExerciseSets(
                      widget.exercise.id,
                    );
                    
                    if (sets.isEmpty) {
                      return Center(
                        child: Text(
                          'Aucune série enregistrée',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      itemCount: sets.length,
                      itemBuilder: (context, index) {
                        final set = sets[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: AppCard(
                            variant: AppCardVariant.outlined,
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  child: Text('${index + 1}'),
                                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    '${set.reps} reps',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                                Text(
                                  '${set.weight.toStringAsFixed(1)} kg',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontFamily: 'JetBrainsMono',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
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
- Utiliser `const` pour les widgets statiques
- Préférer `AppCard` avec variants appropriés
- Limiter les rebuilds avec `Consumer` ciblé
- Utiliser les page transitions pour navigation fluide

#### ❌ Éviter
- Reconstruire inutilement des widgets lourds
- Animer trop d'éléments simultanément
- Imbriquer trop de niveaux de widgets

```dart
// Bon : Consumer ciblé
Consumer<WorkoutProvider>(
  builder: (context, workoutProvider, child) {
    return Text(workoutProvider.formattedElapsedTime);
  },
)

// Éviter : Consumer trop large qui rebuild tout
Consumer<WorkoutProvider>(
  builder: (context, workoutProvider, child) {
    return EntireScreen(); // Trop de rebuilds
  },
)
```

### 2. Accessibilité

#### ✅ Faire
- Assurer contraste de 4.5:1 minimum pour texte
- Utiliser les couleurs du thème (Dark/Light mode compatible)
- Supporter tailles de police dynamiques
- Fournir feedback visuel clair sur interactions

```dart
// Bon contraste automatique avec Material 3
Text(
  'Label',
  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
    color: Theme.of(context).colorScheme.onSurface,
  ),
)

// Bon : Utiliser les couleurs du ColorScheme
Container(
  color: Theme.of(context).colorScheme.primaryContainer,
  child: Text(
    'Important',
    style: TextStyle(
      color: Theme.of(context).colorScheme.onPrimaryContainer,
    ),
  ),
)
```

### 3. Cohérence visuelle

#### ✅ Faire
- Utiliser les widgets du Design System (AppCard, AppButton, etc.)
- Respecter les espacements définis (8, 12, 16, 20, 24px)
- Utiliser les border radius standard (16px ou 24px)
- Suivre les conventions de variants (standard, elevated, outlined)

```dart
// Bon : Utiliser les widgets du système
AppCard(
  variant: AppCardVariant.elevated,
  padding: EdgeInsets.all(20),
  child: content,
)

// Éviter : Créer des composants custom non standardisés
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(13), // Valeur non standard
    // ...
  ),
)
```

### 4. États interactifs

#### ✅ Faire
- Toujours fournir feedback visuel au tap
- Désactiver boutons pendant chargement (`isLoading: true`)
- Afficher messages d'erreur avec SnackBar
- Utiliser les page transitions pour navigation

```dart
// Bon feedback utilisateur
AppButton(
  text: 'Soumettre',
  variant: AppButtonVariant.primary,
  isLoading: isSubmitting,
  onPressed: isSubmitting ? null : () => submit(),
)

// Navigation avec transition
Navigator.of(context).push(
  AppPageRoute.fadeSlide(
    builder: (context) => NextScreen(),
  ),
)
```

### 5. Validation des formulaires

#### ✅ Faire
- Valider côté client pour feedback immédiat (RG-003)
- Afficher messages d'erreur clairs et contextuels
- Bloquer soumission si validation échoue
- Utiliser AppNumberField pour saisie numérique

```dart
// Validation RG-003 - Répétitions > 0, Poids >= 0
Future<void> _addSet() async {
  final reps = int.tryParse(repsController.text);
  final weight = double.tryParse(weightController.text) ?? 0;
  
  if (reps == null || reps <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Les répétitions doivent être > 0 (RG-003)')),
    );
    return;
  }
  
  if (weight < 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Le poids doit être ≥ 0 (RG-003)')),
    );
    return;
  }
  
  // Validation OK, soumettre
  await workoutProvider.addSet(exerciseId, reps, weight);
}
```

### 6. Navigation et drawer

#### ✅ Faire
- Utiliser ProfileDrawer pour menu utilisateur
- Capturer providers avant fermeture du drawer (context-safe)
- Utiliser AppPageRoute pour transitions cohérentes
- Gérer workout actif lors de la déconnexion

```dart
// Bon : Ouvrir drawer depuis AppBar
Scaffold(
  appBar: AppBar(
    actions: [
      Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.person),
          onPressed: () => Scaffold.of(context).openEndDrawer(),
        ),
      ),
    ],
  ),
  endDrawer: ProfileDrawer(),
)

// ProfileDrawer gère automatiquement :
// - Capture des providers avant fermeture
// - Annulation workout si actif
// - Déconnexion sécurisée
```

---

## Support

Pour toute question sur le Design System :

1. Consulter les exemples dans ce document
2. Lire les commentaires dans les fichiers source
3. Référencer les règles de gestion (RG-*) dans [README.md](../README.md)
4. Voir la documentation Firebase : [Firebase Setup Guide](firebase-setup-guide.md)

---

**Version** : 2.0.0  
**Dernière mise à jour** : Février 2026  
**Design System** : Material 3 moderne avec Raleway  
**Couleur primaire** : #1E88E5  
**Mainteneur** : Équipe Apollon
