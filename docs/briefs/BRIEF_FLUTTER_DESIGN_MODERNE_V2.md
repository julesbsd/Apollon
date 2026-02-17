# BRIEF: Migration Design Moderne - Style Épuré Bleu

**Version:** 1.0  
**Date:** 2026-02-17  
**Destinataire:** Flutter Developer Expert  
**Émetteur:** Apollon Project Assistant  
**Priorité:** Haute  
**Estimation:** 12-16 heures

---

## CONTEXTE MÉTIER

### Vue d'Ensemble Apollon

Apollon est une application mobile Flutter de suivi de musculation permettant aux utilisateurs d'enregistrer leurs séances d'entraînement avec gestion d'historique.

### Glossaire Métier Pertinent

- **EXERCICE:** Mouvement lié à un équipement spécifique (ex: Développé couché barre)
- **GROUPE MUSCULAIRE:** Zone anatomique ciblée (pectoraux, biceps, etc.)
- **TYPE EXERCICE:** Nature équipement (poids libres, machine, poids corporel, cardio)
- **SÉRIE:** Ensemble répétitions continues (attributs: reps > 0, poids >= 0 kg)
- **SÉANCE:** Session complète salle (attributs: date, durée, liste exercices)

Hiérarchie: UTILISATEUR → SÉANCES → EXERCICES → SÉRIES

### Règles de Gestion Concernées

- **RG-002:** Unicité noms exercices (pas de doublons)
- **RG-005:** Affichage historique texte simple V1 (dernière séance par exercice)

### Processus Métier Impactés

- **P2 (Enregistrer séance - CRITIQUE):** Nouvelle séance → Sélection exercice (catégorie/nom) → Affichage auto historique → Ajout séries → Terminer → Save Firestore
- **P3 (Historique):** Accès → Liste séances → Détail séance

### Critères de Succès Métier

- **CS-001:** Saisir séance complète (5 exos) en < 2 min
- **CS-002:** Retrouver derniers poids en < 1s
- **CS-003:** Interface fluide, belle, intuitive (60fps, sans frustration)

---

## OBJECTIF

### Objectif Principal

**Migrer le Design System Apollon d'un style "Liquid Glass Violet" vers un style "Moderne Épuré Bleu"** en s'inspirant d'une image de référence fitness moderne, tout en conservant toutes les fonctionnalités existantes et en améliorant l'expérience utilisateur.

### Objectifs Spécifiques

1. **Remplacer la couleur primaire Violet par Bleu** (#4A90E2)
2. **Abandonner le style Liquid Glass** (glassmorphisme, blur, transparence)
3. **Adopter des composants modernes épurés** (cards plates, borders subtiles)
4. **Créer de nouveaux composants clés:**
   - ImageCard (cards avec images en arrière-plan)
   - ModernCategoryIcon (icônes catégories simplifiées)
   - CircularProgressCard (cercles de progression avec pourcentage)
   - SimpleBarChart (graphiques en barres minimalistes)
5. **Refondre les layouts principaux** (Home, Historique, Statistiques)
6. **Maintenir les performances** (60fps, aucune régression)

### Livrables Attendus

- [ ] Fichier `app_theme.dart` mis à jour avec palette bleue
- [ ] Nouveau fichier `lib/core/widgets/modern_components.dart` avec exports
- [ ] Composants individuels créés et testés:
  - `lib/core/widgets/modern_image_card.dart`
  - `lib/core/widgets/modern_category_icon.dart`
  - `lib/core/widgets/modern_circular_progress.dart`
  - `lib/core/widgets/modern_bar_chart.dart`
- [ ] Layouts écrans principaux refondus:
  - `lib/features/home/screens/home_screen.dart`
  - `lib/features/workout/screens/workout_history_screen.dart`
  - `lib/features/stats/screens/stats_screen.dart` (si existe)
- [ ] Documentation inline (commentaires Dart) pour nouveaux composants
- [ ] Aucune breaking change fonctionnelle

---

## CONTRAINTES

### Contraintes Techniques

#### Stack Technique (à respecter)

- **Framework:** Flutter 3.x (stable)
- **Langage:** Dart 3.x
- **State Management:** Provider (existant, ne pas changer)
- **Backend:** Firebase (Firestore + Auth)
- **Fonts:** Google Fonts - Inter (conserver)
- **Images:** cached_network_image (optimisation)

#### Architecture Existante

- **Structure dossiers:** `lib/core/`, `lib/features/`, `lib/shared/`
- **Theme management:** `ThemeProvider` existant (ne pas casser)
- **Navigation:** Système actuel (Navigator 2.0 ou standard)

#### Compatibilité

- **Android:** Prioritaire (min SDK 21)
- **iOS:** Secondaire (min iOS 12)
- **Dark/Light mode:** Les deux modes OBLIGATOIRES
- **Responsive:** Support téléphones uniquement (pour l'instant)

### Contraintes Design

#### Référence Image

**Fichier:** `C:\Users\Jules\Downloads\design.webp`

**Éléments clés à reproduire:**
- Fond blanc/gris clair uniforme (pas de dégradés)
- Cards épurées avec grandes images photographiques
- Overlay sombre (0.4-0.5 opacity) sur images pour lisibilité texte
- Icônes simples + labels en dessous
- Typographie claire avec forte hiérarchie
- Layouts spacieux et aérés
- Coins arrondis importants (16-20px)

#### Palette Couleurs Imposée

```dart
// COULEUR PRINCIPALE - BLEU (remplace Violet)
static const Color primaryBlue = Color(0xFF4A90E2);
static const Color primaryBlueDark = Color(0xFF2E5C8A);
static const Color primaryBlueLight = Color(0xFF7BB5F0);

// NEUTRALS (base design moderne)
static const Color neutralGray50 = Color(0xFFFAFAFA);
static const Color neutralGray100 = Color(0xFFF5F5F5);
static const Color neutralGray200 = Color(0xFFEEEEEE);
static const Color neutralGray800 = Color(0xFF2C2C3A);
static const Color neutralGray900 = Color(0xFF1A1A24);

// ACCENTS (conservés)
static const Color successGreen = Color(0xFF00D9A3);
static const Color warningOrange = Color(0xFFFF9F43);
static const Color errorRed = Color(0xFFE74C3C);
```

#### Design Tokens

**Spacing:**
```dart
static const double spacingXS = 4.0;
static const double spacingS = 8.0;
static const double spacingM = 16.0;
static const double spacingL = 24.0;
static const double spacingXL = 32.0;
static const double spacingXXL = 48.0;
```

**Border Radius:**
```dart
static const double radiusS = 8.0;   // Badges
static const double radiusM = 12.0;  // Boutons secondaires
static const double radiusL = 16.0;  // Boutons principaux, inputs
static const double radiusXL = 20.0; // Cards
static const double radiusXXL = 24.0; // Bottom sheets
```

**Elevations:**
```dart
static const double elevation0 = 0;  // Défaut (flat design)
// Pas d'ombres - utiliser borders subtiles à la place
```

#### Typographie (Inter)

```dart
// TITRES
headlineLarge: 32px, Bold (w700)
headlineMedium: 28px, SemiBold (w600)
headlineSmall: 24px, SemiBold (w600)

// CARDS/SECTIONS
titleLarge: 22px, SemiBold (w600)
titleMedium: 16px, SemiBold (w600)
titleSmall: 14px, SemiBold (w600)

// CORPS
bodyLarge: 16px, Regular (w400)
bodyMedium: 14px, Regular (w400)
bodySmall: 12px, Regular (w400)

// LABELS
labelLarge: 14px, SemiBold (w600)
labelMedium: 12px, Medium (w500)
labelSmall: 11px, Medium (w500)
```

### Contraintes Performance

- **Framerate:** 60fps OBLIGATOIRE (aucune régression)
- **Build time:** Ne pas augmenter significativement
- **Memory:** Pas de memory leak (attention aux images)
- **Network:** Optimiser chargement images (cache, compression)

### Contraintes UX

- **Accessibilité:**
  - Touch targets >= 48x48px
  - Contrastes conformes WCAG 2.1 AA minimum
  - Support lecteurs d'écran (Semantics)
- **Animations:**
  - Durée: 200-300ms (fluides, pas trop lentes)
  - Curves: Curves.easeInOut ou Curves.fastOutSlowIn
- **Feedback:**
  - Feedback visuel sur toutes interactions (splash, hover)
  - Loaders clairs pendant chargements
  - Messages d'erreur explicites

---

## SPÉCIFICATIONS DÉTAILLÉES

### 1. Mise à Jour Theme (`app_theme.dart`)

#### Actions Requises

1. **Remplacer toutes les occurrences de `primaryViolet`:**
   - `static const Color primaryViolet = Color(0xFF6C63FF);` → SUPPRIMER
   - Ajouter: `static const Color primaryBlue = Color(0xFF4A90E2);`
   - Ajouter: `static const Color primaryBlueDark = Color(0xFF2E5C8A);`
   - Ajouter: `static const Color primaryBlueLight = Color(0xFF7BB5F0);`

2. **Mettre à jour ColorScheme (dark et light):**
   ```dart
   // AVANT
   primary: primaryViolet,
   
   // APRÈS
   primary: primaryBlue,
   ```

3. **Mettre à jour backgrounds Light Mode:**
   ```dart
   // AVANT
   static const Color lightBackground = Color(0xFFF8F9FA);
   
   // APRÈS
   static const Color lightBackground = Color(0xFFFAFAFA);
   ```

4. **Simplifier CardTheme (supprimer effet glass):**
   ```dart
   CardTheme(
     elevation: 0,  // Pas d'ombre
     color: lightSurface (light) / darkSurface (dark),
     shape: RoundedRectangleBorder(
       borderRadius: BorderRadius.circular(20),
       side: BorderSide(
         color: Colors.black.withOpacity(0.06),  // Border subtile
         width: 1,
       ),
     ),
   )
   ```

5. **Mettre à jour ElevatedButtonTheme:**
   ```dart
   ElevatedButton.styleFrom(
     backgroundColor: primaryBlue,  // Remplacer primaryViolet
     elevation: 0,  // Pas d'ombre
     shadowColor: Colors.transparent,
     shape: RoundedRectangleBorder(
       borderRadius: BorderRadius.circular(16),  // Réduit de 24 à 16
     ),
   )
   ```

6. **Mettre à jour InputDecorationTheme:**
   ```dart
   InputDecorationTheme(
     filled: true,
     fillColor: neutralGray100,  // Opaque, pas transparent
     borderRadius: BorderRadius.circular(16),  // Réduit de 24 à 16
     focusedBorder: BorderSide(color: primaryBlue, width: 2),  // Bleu
   )
   ```

### 2. Nouveau Composant: `ModernImageCard`

**Fichier:** `lib/core/widgets/modern_image_card.dart`

#### Spécifications

**Props:**
```dart
class ModernImageCard extends StatelessWidget {
  final String imageUrl;           // URL image (network ou asset)
  final String title;               // Titre principal
  final String? subtitle;           // Sous-titre optionnel
  final VoidCallback? onTap;        // Action au tap
  final double height;              // Hauteur card (défaut: 180)
  final Widget? badge;              // Badge optionnel (ex: "15%")
  final Widget? actionButton;       // Bouton action (ex: "Start workout")
  
  const ModernImageCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.onTap,
    this.height = 180,
    this.badge,
    this.actionButton,
  }) : super(key: key);
}
```

**Layout:**
```
┌─────────────────────────────────┐
│  [Image Background - cover]     │
│  ┌──────────────────────────┐   │
│  │ Dark Overlay (0.45)      │   │
│  │                          │   │
│  │  [Badge?]                │   │ ← Badge top-right si fourni
│  │                          │   │
│  │                          │   │
│  │  Title (white, 22px)     │   │ ← Titre en bas
│  │  Subtitle? (white, 14px) │   │
│  │  [Action Button?]        │   │ ← Bouton si fourni
│  └──────────────────────────┘   │
└─────────────────────────────────┘
```

**Implémentation clé:**
- Container avec `BoxDecoration` + `DecorationImage` (BoxFit.cover)
- Stack avec overlay sombre: `Container(color: Colors.black.withOpacity(0.45))`
- Texte blanc en position bottom-left (padding 16px)
- BorderRadius: 20px
- Tap avec InkWell ou GestureDetector
- Image: CachedNetworkImage si network, AssetImage si local
- Badge: Positioned top-right (12px padding)
- Action Button: Positioned bottom-center ou intégré dans Column

**Exemple Usage:**
```dart
ModernImageCard(
  imageUrl: 'https://example.com/chest-workout.jpg',
  title: 'Chest Muscle Exercise',
  height: 200,
  badge: Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text('15%', style: TextStyle(color: Colors.white)),
  ),
  actionButton: FilledButton.tonal(
    onPressed: () {},
    child: Text('Start workout'),
  ),
  onTap: () => Navigator.push(...),
)
```

### 3. Nouveau Composant: `ModernCategoryIcon`

**Fichier:** `lib/core/widgets/modern_category_icon.dart`

#### Spécifications

**Props:**
```dart
class ModernCategoryIcon extends StatelessWidget {
  final IconData icon;             // Icône Material ou custom
  final String label;               // Label en dessous
  final bool isSelected;            // État sélectionné
  final VoidCallback onTap;         // Action au tap
  final Color? activeColor;         // Couleur active (défaut: primaryBlue)
  
  const ModernCategoryIcon({
    Key? key,
    required this.icon,
    required this.label,
    this.isSelected = false,
    required this.onTap,
    this.activeColor,
  }) : super(key: key);
}
```

**Layout:**
```
┌─────────────┐
│             │
│   ┌─────┐   │
│   │ Icon│   │ ← Container 64x64, icon 28x28
│   └─────┘   │
│             │
│   Label     │ ← Texte 12px Medium
│             │
└─────────────┘
```

**Implémentation clé:**
- Column (children: [Container (icône), SizedBox (gap 8px), Text (label)])
- Container icône: 64x64px, borderRadius 16px
- Background: neutralGray100 (inactif) / primaryBlue (actif)
- Icône: 28x28px, color: neutralGray800 (inactif) / white (actif)
- Label: 12px Medium, color: neutralGray800
- Tap: InkWell avec feedback
- Transition: AnimatedContainer (200ms) pour background et icône color

**Exemple Usage:**
```dart
ModernCategoryIcon(
  icon: Icons.fitness_center,
  label: 'Yoga',
  isSelected: selectedCategory == 'yoga',
  onTap: () => setState(() => selectedCategory = 'yoga'),
)
```

### 4. Nouveau Composant: `CircularProgressCard`

**Fichier:** `lib/core/widgets/modern_circular_progress.dart`

#### Spécifications

**Props:**
```dart
class CircularProgressCard extends StatelessWidget {
  final double percentage;          // 0.0 à 1.0
  final String label;               // Texte principal (ex: "25%")
  final String? subtitle;           // Sous-titre (ex: "Complete")
  final double size;                // Diamètre cercle (défaut: 100)
  final double strokeWidth;         // Épaisseur stroke (défaut: 8)
  final Color? progressColor;       // Couleur progression (défaut: primaryBlue)
  
  const CircularProgressCard({
    Key? key,
    required this.percentage,
    required this.label,
    this.subtitle,
    this.size = 100,
    this.strokeWidth = 8,
    this.progressColor,
  }) : super(key: key);
}
```

**Layout:**
```
┌───────────────┐
│               │
│   ┌───────┐   │
│   │  25%  │   │ ← CircularProgressIndicator
│   │Complete│   │    + texte centré
│   └───────┘   │
│               │
└───────────────┘
```

**Implémentation clé:**
- SizedBox (size x size) avec Stack
- CircularProgressIndicator customisé:
  - value: percentage
  - strokeWidth: strokeWidth
  - backgroundColor: neutralGray200
  - valueColor: AlwaysStoppedAnimation(progressColor ?? primaryBlue)
- Center avec Column:
  - Text label (24px Bold)
  - Text subtitle (12px Regular) si fourni
- Pas de Card wrapper (composant réutilisable dans Card si besoin)

**Exemple Usage:**
```dart
CircularProgressCard(
  percentage: 0.25,
  label: '25%',
  subtitle: 'Complete',
  size: 100,
  strokeWidth: 10,
)
```

### 5. Nouveau Composant: `SimpleBarChart`

**Fichier:** `lib/core/widgets/modern_bar_chart.dart`

#### Spécifications

**Props:**
```dart
class SimpleBarChart extends StatelessWidget {
  final List<double> values;        // Valeurs (0.0 à 1.0 normalisées)
  final List<String> labels;        // Labels (ex: ['S', 'M', 'T', ...])
  final int? activeIndex;           // Index barre active (optionnel)
  final Color? activeColor;         // Couleur barre active (défaut: primaryBlue)
  final Color? inactiveColor;       // Couleur barres inactives (défaut: gray)
  final double height;              // Hauteur chart (défaut: 150)
  final double barWidth;            // Largeur barre (défaut: 24)
  
  const SimpleBarChart({
    Key? key,
    required this.values,
    required this.labels,
    this.activeIndex,
    this.activeColor,
    this.inactiveColor,
    this.height = 150,
    this.barWidth = 24,
  }) : assert(values.length == labels.length),
       super(key: key);
}
```

**Layout:**
```
┌─────────────────────────────────┐
│  ║   ║   ║   ███   ║   ║   ║   │ ← Barres verticales
│  ║   ║   ║   ███   ║   ║   ║   │
│  ║   ║   ║   ███   ║   ║   ║   │
│  S   M   T   W   T   F   S      │ ← Labels
└─────────────────────────────────┘
```

**Implémentation clé:**
- Column: [Row (barres), Row (labels)]
- Row barres:
  - Children: List.generate barres individuelles
  - mainAxisAlignment: MainAxisAlignment.spaceEvenly
  - crossAxisAlignment: CrossAxisAlignment.end
- Barre individuelle:
  - Container avec:
    - width: barWidth
    - height: values[i] * height (proportionnel)
    - decoration: BoxDecoration (
        color: i == activeIndex ? activeColor : inactiveColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(8))
      )
- Row labels:
  - Children: List.generate textes
  - mainAxisAlignment: MainAxisAlignment.spaceEvenly
  - Text: 12px Medium, color: neutralGray800

**Exemple Usage:**
```dart
SimpleBarChart(
  values: [0.3, 0.4, 0.5, 1.0, 0.6, 0.7, 0.8],
  labels: ['S', 'M', 'T', 'W', 'T', 'F', 'S'],
  activeIndex: 3,  // Mercredi (Wed)
  height: 120,
  barWidth: 28,
)
```

### 6. Fichier Export `modern_components.dart`

**Fichier:** `lib/core/widgets/modern_components.dart`

```dart
/// Modern Components - Design System Apollon V2
/// 
/// Collection de composants épurés style moderne.
/// 
/// Composants exportés:
/// - ModernImageCard: Card avec image en background et overlay
/// - ModernCategoryIcon: Icône catégorie simplifiée avec label
/// - CircularProgressCard: Cercle de progression avec pourcentage
/// - SimpleBarChart: Graphique en barres minimaliste

library modern_components;

export 'modern_image_card.dart';
export 'modern_category_icon.dart';
export 'modern_circular_progress.dart';
export 'modern_bar_chart.dart';
```

### 7. Refonte Layout: `home_screen.dart`

**Fichier:** `lib/features/home/screens/home_screen.dart` (ou équivalent)

#### Structure Cible

```dart
Scaffold(
  appBar: AppBar(
    title: Text('Full Strength'),  // Ou "Accueil"
    actions: [
      IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
    ],
  ),
  body: SingleChildScrollView(
    padding: EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SECTION 1: Progression du jour
        _buildProgressSection(),
        SizedBox(height: 32),
        
        // SECTION 2: Catégories (horizontal scroll)
        _buildCategoriesSection(),
        SizedBox(height: 32),
        
        // SECTION 3: Workouts populaires
        _buildPopularWorkoutsSection(),
      ],
    ),
  ),
  floatingActionButton: FloatingActionButton.extended(
    onPressed: () => _startNewWorkout(),
    icon: Icon(Icons.add),
    label: Text('Nouvelle séance'),
  ),
)
```

#### Section 1: Progression

```dart
Widget _buildProgressSection() {
  return Card(
    child: Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mon Plan Aujourd\'hui',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 4),
              Text(
                '1/7 Complete',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          CircularProgressCard(
            percentage: 0.25,
            label: '25%',
            size: 80,
          ),
        ],
      ),
    ),
  );
}
```

#### Section 2: Catégories

```dart
Widget _buildCategoriesSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Catégories',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      SizedBox(height: 16),
      SizedBox(
        height: 100,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            ModernCategoryIcon(
              icon: Icons.self_improvement,
              label: 'Yoga',
              isSelected: selectedCategory == 'yoga',
              onTap: () => _selectCategory('yoga'),
            ),
            SizedBox(width: 16),
            ModernCategoryIcon(
              icon: Icons.directions_run,
              label: 'Running',
              isSelected: selectedCategory == 'running',
              onTap: () => _selectCategory('running'),
            ),
            // Autres catégories...
          ],
        ),
      ),
    ],
  );
}
```

#### Section 3: Workouts Populaires

```dart
Widget _buildPopularWorkoutsSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Popular workout',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          TextButton(
            onPressed: () {},
            child: Text('See All'),
          ),
        ],
      ),
      SizedBox(height: 16),
      ModernImageCard(
        imageUrl: 'assets/images/chest_workout.jpg',
        title: 'Chest Muscle Exercise',
        height: 200,
        badge: _buildBadge('15%'),
        actionButton: FilledButton.tonal(
          onPressed: () {},
          child: Text('Start workout'),
        ),
        onTap: () => _openWorkoutDetail('chest'),
      ),
      SizedBox(height: 16),
      ModernImageCard(
        imageUrl: 'assets/images/full_body.jpg',
        title: 'Full Body Exercise',
        height: 200,
        onTap: () => _openWorkoutDetail('full_body'),
      ),
    ],
  );
}
```

### 8. Refonte Layout: `workout_history_screen.dart`

**Fichier:** `lib/features/workout/screens/workout_history_screen.dart`

#### Structure Cible

```dart
Scaffold(
  appBar: AppBar(
    title: Text('Historique'),
  ),
  body: ListView.separated(
    padding: EdgeInsets.all(20),
    itemCount: workouts.length,
    separatorBuilder: (_, __) => SizedBox(height: 16),
    itemBuilder: (context, index) {
      final workout = workouts[index];
      return ModernImageCard(
        imageUrl: workout.imageUrl ?? 'assets/images/default_workout.jpg',
        title: workout.name,
        subtitle: '${workout.date} • ${workout.duration} min',
        height: 160,
        onTap: () => _openWorkoutDetail(workout),
      );
    },
  ),
)
```

---

## CRITÈRES D'ACCEPTATION

### Critères Fonctionnels

- [ ] L'application compile sans erreurs
- [ ] Aucune breaking change: toutes les fonctionnalités existantes fonctionnent
- [ ] Navigation fluide entre écrans
- [ ] Provider / State Management fonctionne correctement
- [ ] Firebase Auth et Firestore non impactés
- [ ] RG-001 à RG-006 toujours respectées
- [ ] Processus P2 (enregistrer séance) fonctionne end-to-end

### Critères Visuels

- [ ] Couleur bleue (#4A90E2) utilisée comme primaire partout
- [ ] Aucune trace de violet restant
- [ ] Aucun effet Liquid Glass (blur, transparency, backdrop filter)
- [ ] Cards modernes avec borders subtiles (pas d'ombres)
- [ ] ImageCards affichent correctement images avec overlay
- [ ] Icônes catégories simples et fonctionnelles
- [ ] Progress circles affichent pourcentage correct
- [ ] Bar charts proportionnels et lisibles
- [ ] Dark mode et Light mode cohérents et beaux

### Critères Performance

- [ ] 60fps maintenu sur tous les écrans (Flutter DevTools)
- [ ] Aucune régression de performance vs version actuelle
- [ ] Pas de memory leak (images bien disposées)
- [ ] Temps de chargement images acceptable (< 1s)
- [ ] Build time non significativement augmenté

### Critères UX

- [ ] Lisibilité texte excellente (contrastes suffisants)
- [ ] Touch targets >= 48x48px minimum
- [ ] Animations fluides (200-300ms)
- [ ] Feedback visuel sur toutes interactions
- [ ] Messages d'erreur clairs si problèmes

### Critères Code Quality

- [ ] Code propre et idiomatique Dart
- [ ] Commentaires inline pour logique complexe
- [ ] Composants réutilisables et paramétrables
- [ ] Pas de code dupliqué
- [ ] Respect conventions nommage Flutter
- [ ] Tests unitaires pour nouveaux composants (si temps)

---

## RESSOURCES

### Documentation Référence

- **Spec Design Complète:** `docs/DESIGN_MODERNE_SPECIFICATION.md`
- **Image Référence:** `C:\Users\Jules\Downloads\design.webp`
- **Theme Actuel:** `lib/core/theme/app_theme.dart`
- **Widgets Existants:** `lib/core/widgets/`

### Assets Images (à créer ou récupérer)

- `assets/images/chest_workout.jpg` (exemple workout pectoraux)
- `assets/images/full_body.jpg` (exemple full body)
- `assets/images/default_workout.jpg` (placeholder par défaut)

Si images manquantes: utiliser placeholders ou images libres de droits (Unsplash, Pexels).

### Dépendances Utiles

**Déjà installées (vérifier `pubspec.yaml`):**
- `provider` (state management)
- `google_fonts` (typographie Inter)
- `cached_network_image` (optimisation images)
- `firebase_core` et `cloud_firestore`

**Potentiellement nécessaires:**
- Si images depuis réseau: `cached_network_image` déjà présent
- Si charts complexes: `fl_chart` (mais simple bar chart custom suffit)

### Contacts et Support

- **Product Owner / Context:** Apollon Project Assistant
- **Questions métier:** Référer aux RG-001 à RG-006 et processus P1-P3
- **Questions techniques Flutter:** Autonomie du Flutter Expert
- **Validation design:** Screenshots avant/après pour review

---

## PLAN D'IMPLÉMENTATION SUGGÉRÉ

### Phase 1: Fondations (2-3h)

1. **Backup:** Créer branche Git `feature/design-moderne-v2`
2. **Theme Update:**
   - Modifier `app_theme.dart` (palette bleue)
   - Tester app avec nouveau theme (vérifier pas de crash)
3. **Validation:** Build et run sur device/emulator

### Phase 2: Nouveaux Composants (4-5h)

1. **ModernImageCard:** Créer + tester isolément
2. **ModernCategoryIcon:** Créer + tester isolément
3. **CircularProgressCard:** Créer + tester isolément
4. **SimpleBarChart:** Créer + tester isolément
5. **Export:** Créer `modern_components.dart`

**Validation:** Créer screen de démo montrant tous les composants.

### Phase 3: Refonte Home Screen (2-3h)

1. Remplacer composants existants par nouveaux
2. Implémenter layout sections (progression, catégories, workouts)
3. Connecter aux données existantes (Provider)
4. Tester navigation et interactions

### Phase 4: Refonte Historique (1-2h)

1. Adapter layout liste workouts avec ModernImageCard
2. Tester affichage et navigation

### Phase 5: Polish et Tests (2-3h)

1. Dark mode: vérifier cohérence
2. Animations: ajouter transitions fluides
3. Edge cases: tester sans données, erreurs réseau, etc.
4. Performance: profiler avec Flutter DevTools
5. Screenshots: avant/après pour validation

### Phase 6: Documentation (1h)

1. Commenter code nouveaux composants
2. Mettre à jour README.md si nécessaire
3. Créer CHANGELOG.md entry

---

## VALIDATION ET LIVRAISON

### Checklist Avant Livraison

- [ ] Code compilé sans warnings
- [ ] App testée sur Android (minimum)
- [ ] Dark et Light mode validés
- [ ] Screenshots avant/après fournis
- [ ] Commit Git avec message descriptif
- [ ] PR créé avec description détaillée

### Format Livraison

**Pull Request Git avec:**
- **Titre:** `feat: Migration Design Moderne V2 - Style Épuré Bleu`
- **Description:** Résumé changements + screenshots
- **Reviewers:** Apollon Project Assistant (validation métier)

**Screenshots Requis:**
- Home screen (light mode)
- Home screen (dark mode)
- Historique (light mode)
- Nouveaux composants (démo screen si créé)

---

## QUESTIONS / CLARIFICATIONS

Si doutes pendant implémentation:

1. **Ambiguïté design:** Référer à `design.webp` et `DESIGN_MODERNE_SPECIFICATION.md`
2. **Ambiguïté métier:** Respecter RG et processus P1-P3
3. **Choix technique:** Privilégier simplicité et performance
4. **Blocage:** Documenter et signaler pour déblocage

---

**Auteur:** Apollon Project Assistant  
**Date Création:** 2026-02-17  
**Version:** 1.0  
**Status:** Ready for Implementation
