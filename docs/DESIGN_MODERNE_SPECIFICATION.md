# SPECIFICATION DESIGN MODERNE - APOLLON

**Version:** 2.0  
**Date:** 2026-02-17  
**Type:** Évolution Design System  
**Status:** Proposition

---

## CONTEXTE ET OBJECTIF

### Analyse Image de Référence

L'image de référence montre un design fitness moderne avec :
- Style épuré et contemporain (Clean Modern)
- Cards avec grandes images photographiques
- Fond blanc/gris clair uniforme
- Couleur accent rouge-orange vif (#FF5733)
- Coins arrondis importants (20-24px)
- Typographie claire avec hiérarchie forte
- Layouts spacieux et aérés

### Objectif Adaptation Apollon

**Transformer le design Apollon actuel (Liquid Glass + Violet) vers un style Moderne Épuré avec Bleu comme couleur principale.**

**Contraintes:**
- Conserver la couleur BLEUE existante (remplacer le violet)
- Abandonner progressivement le style "Liquid Glass"
- Adopter un style plus moderne, épuré et professionnel
- Améliorer la lisibilité et l'ergonomie
- Maintenir la performance (60fps)

---

## PALETTE COULEURS - NOUVELLE VERSION

### Couleur Principale: BLEU

```dart
// BLEU PRIMAIRE (remplace le violet actuel)
static const Color primaryBlue = Color(0xFF4A90E2);  // Bleu moderne et dynamique
static const Color primaryBlueDark = Color(0xFF2E5C8A);  // Bleu foncé pour variations
static const Color primaryBlueLight = Color(0xFF7BB5F0);  // Bleu clair pour hover/disabled

// VARIANTES BLEU
static const Color blueTint = Color(0xFFE8F4FD);  // Fond bleu très clair (light mode)
static const Color blueShade = Color(0xFF1A3A5C);  // Bleu très foncé (dark mode accents)
```

### Couleurs Secondaires et Accents

```dart
// VERT SUCCÈS (pour progression, validation)
static const Color successGreen = Color(0xFF00D9A3);

// ORANGE WARNING (pour alertes, focus)
static const Color warningOrange = Color(0xFFFF9F43);

// ROUGE ERREUR
static const Color errorRed = Color(0xFFE74C3C);

// GRIS NEUTRES (base du design moderne)
static const Color neutralGray50 = Color(0xFFFAFAFA);   // Fond light mode
static const Color neutralGray100 = Color(0xFFF5F5F5);  // Surface light mode
static const Color neutralGray200 = Color(0xFFEEEEEE);  // Borders light
static const Color neutralGray800 = Color(0xFF2C2C3A);  // Texte dark mode
static const Color neutralGray900 = Color(0xFF1A1A24);  // Fond dark mode
```

### Backgrounds

```dart
// LIGHT MODE (fond blanc/gris clair comme référence)
static const Color lightBackground = Color(0xFFFAFAFA);     // #FAFAFA (gris très clair)
static const Color lightSurface = Color(0xFFFFFFFF);        // #FFFFFF (blanc pur)
static const Color lightSurfaceVariant = Color(0xFFF5F5F5); // #F5F5F5 (gris clair cards)

// DARK MODE
static const Color darkBackground = Color(0xFF0F1419);      // Bleu-gris très foncé
static const Color darkSurface = Color(0xFF1A1F28);         // Bleu-gris foncé
static const Color darkSurfaceVariant = Color(0xFF252B36);  // Bleu-gris moyen
```

---

## TYPOGRAPHIE - ÉVOLUTION

### Police: Inter (conservée)

**Bonne décision:** Inter est excellent pour un design moderne.

### Hiérarchie Simplifiée

```dart
// TITRES PRINCIPAUX (écrans)
headlineLarge: 32px, Bold (w700)      // Ex: "Full Strength", "Statistiques"
headlineMedium: 28px, SemiBold (w600) // Ex: "My Plan For Today"
headlineSmall: 24px, SemiBold (w600)  // Ex: "Categories", "Popular workout"

// TITRES CARDS/SECTIONS
titleLarge: 22px, SemiBold (w600)     // Ex: "Chest Muscle Exercise"
titleMedium: 16px, SemiBold (w600)    // Ex: Boutons, labels importants
titleSmall: 14px, SemiBold (w600)     // Ex: Catégories, métadonnées

// CORPS DE TEXTE
bodyLarge: 16px, Regular (w400)       // Ex: Descriptions longues
bodyMedium: 14px, Regular (w400)      // Ex: Texte courant (défaut)
bodySmall: 12px, Regular (w400)       // Ex: Métadonnées, timestamps

// LABELS/BOUTONS
labelLarge: 14px, SemiBold (w600)     // Ex: Boutons CTA
labelMedium: 12px, Medium (w500)      // Ex: Badges, chips
labelSmall: 11px, Medium (w500)       // Ex: Hints, helper text
```

---

## COMPOSANTS VISUELS - REFONTE

### 1. CARDS - Style Moderne

**ABANDON:** Effet Liquid Glass (glassmorphisme)  
**ADOPTION:** Cards modernes épurées

```dart
// CARD STANDARD (remplace GlassCard)
CardTheme(
  elevation: 0,  // Pas d'ombre portée (flat design)
  color: lightSurface (light) / darkSurface (dark),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),  // Augmenté de 24 à 20px
    side: BorderSide(
      color: Colors.black.withOpacity(0.06),  // Border subtile
      width: 1,
    ),
  ),
)

// CARD AVEC IMAGE (nouveau composant clé)
class ImageCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final double height;
  
  // Spécificités:
  // - Image en arrière-plan (BoxFit.cover)
  // - Overlay sombre (0.4-0.5 opacity) pour lisibilité texte
  // - Texte blanc en overlay
  // - Coins arrondis 20px
  // - Badge optionnel dans un coin
}
```

**Exemples d'usage:**
- Cards "Popular workout" (Chest Muscle, Full Body, etc.)
- Cards exercices dans historique
- Cards catégories avec preview image

### 2. BOUTONS - Modernisation

```dart
// BOUTON PRIMAIRE (CTA principal)
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: primaryBlue,  // Bleu au lieu de violet
    foregroundColor: Colors.white,
    elevation: 0,  // Pas d'ombre
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),  // Légèrement moins arrondi
    ),
    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    minimumSize: Size(double.infinity, 56),  // Hauteur standard 56px
  ),
)

// BOUTON SECONDAIRE
OutlinedButton(
  style: OutlinedButton.styleFrom(
    foregroundColor: primaryBlue,
    side: BorderSide(color: primaryBlue, width: 2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    minimumSize: Size(double.infinity, 56),
  ),
)

// PETIT BOUTON (ex: "Start workout")
FilledButton.tonal(
  style: FilledButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  ),
)
```

### 3. INPUTS - Simplification

```dart
InputDecoration(
  filled: true,
  fillColor: neutralGray100,  // Fond gris clair (pas transparent)
  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),  // Réduit de 24 à 16px
    borderSide: BorderSide(color: Colors.black.withOpacity(0.08), width: 1),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: primaryBlue, width: 2),  // Bleu au focus
  ),
)
```

### 4. ICÔNES CATÉGORIES - Nouveaux Styles

**Référence:** Icônes simples + label en dessous (Yoga, Running, Treadmill, etc.)

```dart
class CategoryIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  
  // Spécificités:
  // - Container carré 64x64px
  // - Background: gris clair (inactif) / bleu (actif)
  // - Icône centrée 28x28px
  // - Label en dessous (12px Medium)
  // - Border radius: 16px
  // - Pas d'effet glass
}
```

### 5. PROGRESS INDICATORS - Cercles de Progression

**Référence:** Cercle "25% Complete" avec texte centré

```dart
class CircularProgressCard extends StatelessWidget {
  final double percentage;
  final String label;
  final String? subtitle;
  
  // Spécificités:
  // - Cercle avec stroke 8px
  // - Couleur: primaryBlue pour progression
  // - Background: gris clair
  // - Taille: 80-100px diamètre
  // - Texte centré (pourcentage + label)
}
```

### 6. CHARTS - Barres Simples

**Référence:** Bar chart simple (calories par jour de la semaine)

```dart
class SimpleBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final Color activeColor;
  
  // Spécificités:
  // - Barres verticales arrondies (top)
  // - Hauteur proportionnelle
  // - Couleur: primaryBlue (jour actif) / gris (inactif)
  // - Labels en dessous (S M T W T F S)
  // - Padding entre barres: 8px
}
```

---

## LAYOUTS - REFONTE ÉCRANS

### Écran Principal (Home)

**Référence:** Écran "Full Strength"

```
┌─────────────────────────────────┐
│  ← Full Strength            ⋮   │ ← AppBar épurée
├─────────────────────────────────┤
│                                 │
│  My Plan For Today       ⭕25%  │ ← Card progression
│  1/7 Complete                   │
│                                 │
│  Categories                     │ ← Section catégories
│  [Yoga] [Running] [Treadmill]…  │    (horizontal scroll)
│                                 │
│  Popular workout       See All  │ ← Section workouts
│  ┌─────────────────────────┐   │
│  │  [Image Background]     │   │ ← ImageCard
│  │  Chest Muscle Exercise  │   │
│  │  [Start workout]        │   │
│  └─────────────────────────┘   │
│  ┌─────────────────────────┐   │
│  │  Full Body Exercise     │   │
│  └─────────────────────────┘   │
│                                 │
└─────────────────────────────────┘
```

**Spacings:**
- Padding écran: 20px (horizontal), 24px (vertical)
- Gap entre sections: 32px
- Gap entre cards: 16px

### Écran Statistiques

**Référence:** Écran "Statistics"

```
┌─────────────────────────────────┐
│  ← Statistics            👤     │
├─────────────────────────────────┤
│                                 │
│  Calories Burnt 🔥              │
│  1000 Kcal                      │
│                                 │
│  [   Bar Chart (7 jours)   ]   │ ← SimpleBarChart
│  Sun Mon Tue Wed Thu Fri Sat    │
│                                 │
│  [User Metric Card 1]           │
│  [User Metric Card 2]           │
│                                 │
│  Course Fee          See More   │
│  [Pricing Card: Month - $100]   │
│  [Pricing Card: Year - $500]    │
│                                 │
│  [Buy Now Button - Bleu]        │
│                                 │
└─────────────────────────────────┘
```

---

## CHANGEMENTS TECHNIQUES

### 1. Fichier `app_theme.dart` - Modifications Requises

```dart
// AVANT (actuel)
static const Color primaryViolet = Color(0xFF6C63FF);

// APRÈS (nouveau)
static const Color primaryBlue = Color(0xFF4A90E2);
static const Color primaryBlueDark = Color(0xFF2E5C8A);
static const Color primaryBlueLight = Color(0xFF7BB5F0);

// Changer toutes les références:
// - ColorScheme.primary: primaryViolet → primaryBlue
// - ElevatedButton backgroundColor: primaryViolet → primaryBlue
// - focusedBorder color: primaryViolet → primaryBlue
// - Etc.
```

### 2. Nouveau Fichier: `modern_components.dart`

Créer un fichier contenant les nouveaux composants:

```dart
// lib/core/widgets/modern_components.dart

export 'modern_image_card.dart';
export 'modern_category_icon.dart';
export 'modern_circular_progress.dart';
export 'modern_bar_chart.dart';
export 'modern_metric_card.dart';
```

### 3. Migration Progressive

**Phase 1:** Mise à jour palette couleurs (Violet → Bleu)
**Phase 2:** Remplacement composants Liquid Glass par Modern Cards
**Phase 3:** Refonte layouts écrans principaux
**Phase 4:** Tests UX et ajustements finaux

---

## DESIGN TOKENS - RÉFÉRENCE RAPIDE

### Spacing System

```dart
// PADDING/MARGIN
static const double spacingXS = 4.0;
static const double spacingS = 8.0;
static const double spacingM = 16.0;
static const double spacingL = 24.0;
static const double spacingXL = 32.0;
static const double spacingXXL = 48.0;

// GAP ENTRE ÉLÉMENTS
static const double gapSmall = 8.0;   // Entre items serrés
static const double gapMedium = 16.0; // Entre cards
static const double gapLarge = 32.0;  // Entre sections
```

### Border Radius

```dart
// COINS ARRONDIS
static const double radiusS = 8.0;   // Petits éléments (badges)
static const double radiusM = 12.0;  // Boutons secondaires
static const double radiusL = 16.0;  // Boutons principaux, inputs
static const double radiusXL = 20.0; // Cards
static const double radiusXXL = 24.0; // Bottom sheets, dialogs
```

### Elevations (simplifiées)

```dart
// ABANDON DES OMBRES COMPLEXES
// Utiliser borders subtiles au lieu d'élévations
static const double elevation0 = 0;  // Défaut (flat design)
static const double elevation1 = 1;  // Rare (dialogs si nécessaire)
```

---

## CRITÈRES ACCEPTATION

### Visuel

- [ ] Couleur bleue (#4A90E2) utilisée comme primaire partout
- [ ] Abandon complet effet Liquid Glass
- [ ] Cards modernes avec borders subtiles (pas d'ombre)
- [ ] ImageCards fonctionnelles avec overlay texte
- [ ] Icônes catégories simples + labels
- [ ] Progress circles avec pourcentage
- [ ] Bar charts simples fonctionnels

### Performance

- [ ] 60fps maintenu sur tous les écrans
- [ ] Aucune régression de performance vs version actuelle
- [ ] Temps de chargement images optimisé (cached_network_image)

### UX

- [ ] Lisibilité texte améliorée (contraste suffisant)
- [ ] Touch targets ≥ 48x48px (accessibilité)
- [ ] Animations fluides (200-300ms)
- [ ] Feedback visuel sur toutes les interactions

### Code

- [ ] Aucune breaking change pour utilisateurs existants
- [ ] Migration progressive sans interruption
- [ ] Tests visuels (Golden tests) mis à jour
- [ ] Documentation design system complète

---

## NEXT STEPS

1. **Validation:** Review de cette spec avec équipe/stakeholders
2. **Prototypage:** Mockups Figma des écrans principaux
3. **Implémentation:** Développement en sprints (prioriser écran Home)
4. **Tests:** A/B testing si possible (Violet vs Bleu)
5. **Déploiement:** Release progressive avec feature flag

---

**Auteur:** Apollon Project Assistant  
**Validé par:** _En attente_  
**Implémenté par:** _À définir_
