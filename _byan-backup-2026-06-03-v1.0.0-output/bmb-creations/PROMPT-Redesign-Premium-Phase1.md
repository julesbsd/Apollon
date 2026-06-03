# 🎨 PROMPT AGENT FLUTTER - REDESIGN PREMIUM PHASE 1

@agent flutter-developer-expert

Redesigne l'interface pour un rendu premium "Apollon" :

## 🎯 OBJECTIF
Transformer l'app d'un design basique à un design premium avec identité forte "Grèce antique + Modernité".

## 📦 TÂCHES À RÉALISER

### **TÂCHE 1 : Fondations visuelles premium (1.5h)**

#### 1.1 - Typographie CINZEL + MANROPE
Remplace dans `lib/core/theme/app_typography.dart` :

**CINZEL pour les grands titres :**
- `displayLarge`, `displayMedium`, `displaySmall` → `GoogleFonts.cinzel(...)`
- `headlineLarge` → `GoogleFonts.cinzel(...)`
- Poids : 700-800 (bold/extra-bold)

**MANROPE pour le reste :**
- `headlineMedium`, `headlineSmall` → `GoogleFonts.manrope(...)`
- `titleLarge`, `titleMedium`, `titleSmall` → `GoogleFonts.manrope(...)`
- `bodyLarge`, `bodyMedium`, `bodySmall` → `GoogleFonts.manrope(...)`
- `labelLarge`, `labelMedium`, `labelSmall` → `GoogleFonts.manrope(...)`

**Garde JetBrains Mono pour chiffres** (déjà ok)

#### 1.2 - Couleur primaire Bleu Égée
Dans `lib/core/theme/app_colors.dart` :
```dart
static const Color primarySeed = Color(0xFF1E88E5); // Bleu Égée méditerranéen
```

Ajoute aussi :
```dart
// Accents dorés pour highlights/achievements
static const Color accentGold = Color(0xFFFFD700);
static const Color accentGoldLight = Color(0xFFFFE57F);
static const Color accentGoldDark = Color(0xFFFFA000);
```

#### 1.3 - Background Mesh Gradient Animé
Remplace `lib/core/widgets/app_background.dart` par un **Mesh Gradient animé** :

**Specs :**
- Mode clair : Gradient Bleu Égée → Violet léger → Blanc
- Mode sombre : Gradient Bleu nuit → Violet sombre → Noir profond
- Animation breathing (10-15s loop)
- Utilise `AnimatedContainer` + `TweenAnimationBuilder`
- Minimum 3 couleurs qui se fondent organiquement

**Exemple structure :**
```dart
class MeshGradientBackground extends StatefulWidget {
  // Animation qui change begin/end du gradient
  // Loop infini avec reverse
  // Colors: [primary, secondary, tertiary]
}
```

---

### **TÂCHE 2 : Bouton "Nouvelle Séance" Glass Orb 3D (1.5h)**

#### 2.1 - Créer GlassOrbButton widget
Fichier : `lib/core/widgets/glass_orb_button.dart`

**Specs visuelles :**
- Forme : Cercle (200x200 minimum)
- Glassmorphism : `BackdropFilter` avec blur 20-30
- Background : Couleur primaire 10% opacité
- Bordure : Gradient circulaire (Bleu Égée → Or)
- Shadow : Interne (effet creux 3D) + externe (élévation)
- Glow : Couleur primaire 20% opacité, spread 10
- Icône : Centre, taille 48, couleur primaire
- Texte principal : Cinzel 20pt, bold
- Texte secondaire (chrono) : Manrope 16pt

**Effets interactifs :**
- Hover : Scale 1.05 + glow plus intense
- Tap : Scale 0.95 + haptic feedback medium
- Animation pulse subtile (1.5s loop) si séance active
- Ripple effect au tap

**Props :**
```dart
GlassOrbButton({
  required String text,
  String? subtitle,      // Pour chrono "01:23:45"
  required IconData icon,
  double progress = 0.0, // 0.0 à 1.0 pour arc de progression
  bool isActive = false, // true = pulse animation
  required VoidCallback onPressed,
})
```

**Progress arc :**
- Arc circulaire autour du bouton
- Épaisseur 6px
- Gradient Bleu → Or
- Animé de 0 à 360° selon `progress`

#### 2.2 - Intégrer dans HomePage
Dans `lib/screens/home/home_page.dart` :

Remplace `_buildMainActionButton` pour utiliser `GlassOrbButton` :
```dart
Center(
  child: GlassOrbButton(
    text: hasActiveWorkout ? 'Séance en cours' : 'Nouvelle séance',
    subtitle: hasActiveWorkout ? workoutProvider.elapsedTimeFormatted : null,
    icon: hasActiveWorkout ? Icons.fitness_center : Icons.add_circle,
    progress: progress, // Calculé sur 60 min
    isActive: hasActiveWorkout,
    onPressed: () { /* ... */ },
  ),
)
```

---

## 🎨 RÉSULTAT ATTENDU

### **Avant :**
- Typo Inter (générique)
- Couleur bleu basique
- Background gradient plat
- Bouton circulaire simple

### **Après :**
- Typo CINZEL (titres) = Identité grecque immédiate ✨
- Bleu Égée méditerranéen = Premium
- Background mesh gradient animé = Modernité
- Bouton Glass Orb 3D = Wow factor 🔮

### **Impression utilisateur :**
"Whoa, cette app respire la qualité !"

---

## ✅ CHECKLIST DE VALIDATION

**Fondations :**
- [ ] Tous les titres en CINZEL (bold)
- [ ] Corps de texte en MANROPE
- [ ] Couleur primaire #1E88E5 appliquée partout
- [ ] Accents or disponibles (mais pas encore utilisés)

**Background :**
- [ ] Mesh gradient animé visible (breathing effect)
- [ ] Transition fluide entre couleurs
- [ ] Fonctionne en mode clair ET sombre
- [ ] Animation loop sans à-coups

**Bouton Glass Orb :**
- [ ] Glassmorphism avec blur visible
- [ ] Bordure gradient Bleu → Or
- [ ] Shadow 3D (creux + élévation)
- [ ] Glow bleu autour
- [ ] Arc de progression si séance active
- [ ] Pulse animation si `isActive = true`
- [ ] Haptic feedback au tap
- [ ] Scale animation (hover + tap)
- [ ] Chrono visible au centre si séance active

**Test sur device :**
- [ ] Test sur téléphone physique (c871bd80)
- [ ] Vérifier performance animations (60 fps)
- [ ] Tester mode clair/sombre
- [ ] Vérifier contraste textes (accessibilité)

---

## 📝 NOTES IMPORTANTES

**Performance :**
- Animations mesh gradient : Utilise `RepaintBoundary` pour optimiser
- Blur glassmorphism : Limiter à 1-2 widgets max par écran
- Pas de blur sur scroll (CPU intensif)

**Accessibilité :**
- Contraste texte/background : Minimum WCAG AA (4.5:1)
- Bordure gradient : Ajouter fallback solid color si gradient fail
- Haptic : Respecter les préférences système (accessibilité)

**Style :**
- Bordures arrondies : 20px minimum
- Spacing : Généreux (24-32px)
- Animations : Durée 200-400ms (fluide mais rapide)

---

## 🚀 ORDRE D'IMPLÉMENTATION RECOMMANDÉ

1. **Couleur + Typo** (30 min)
   - Change primarySeed
   - Ajoute accents or
   - Replace Inter → Cinzel/Manrope

2. **Background mesh gradient** (45 min)
   - Créer widget MeshGradientBackground
   - Tester animation breathing
   - Intégrer dans app_background.dart

3. **GlassOrbButton** (1h)
   - Créer widget avec tous les effets
   - Progress arc
   - Animations pulse + interactions

4. **Integration HomePage** (15 min)
   - Remplacer ancien bouton
   - Tester avec WorkoutProvider
   - Vérifier chrono display

5. **Tests & Polish** (15 min)
   - Test device physique
   - Vérifier performance
   - Ajuster timings animations

**Temps total estimé : 3h**

---

## 📄 FICHIERS À CRÉER/MODIFIER

**À créer :**
- `lib/core/widgets/glass_orb_button.dart`
- Optionnel : `lib/core/widgets/mesh_gradient_background.dart` (si tu sépares)

**À modifier :**
- `lib/core/theme/app_typography.dart` (Cinzel + Manrope)
- `lib/core/theme/app_colors.dart` (Bleu Égée + Or)
- `lib/core/widgets/app_background.dart` (Mesh gradient animé)
- `lib/screens/home/home_page.dart` (Utiliser GlassOrbButton)

**Dépendances (vérifier pubspec.yaml) :**
- `google_fonts` ✅ (déjà présent)
- Ajoute `cinzel` et `manrope` dans fonts (auto-téléchargé)

---

## 💡 INSPIRATION VISUELLE

**Mesh Gradient :**
- iOS 18 widgets background
- Notion app background
- Stripe website gradients

**Glass Orb Button :**
- Apple Watch activity rings (pour progress arc)
- macOS Big Sur icons (glassmorphism)
- Dribbble : "glass morphism button 3D"

**Typographie :**
- Google Arts & Culture app (Serif élégant pour culture)
- British Museum app (Classique + moderne)

---

🏛️ **Commence et crée une app digne d'Apollon !** ✨

Lis d'abord le fichier `_byan-output/bmb-creations/DA-Premium-Apollon.md` pour contexte complet.
