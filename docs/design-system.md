# Design System Apollon - "Marbre & Lumière"

**Version :** 1.2.0 (2026-08-06)
**Source de vérité :** `lib/core/theme/app_theme.dart` - ce document est un résumé de
référence, pas une copie autonome. En cas d'écart entre ce fichier et le code, le code a
raison ; corrigez ce document, pas l'inverse.

Ce design remplace deux systèmes précédents, tous deux retirés du dépôt :
1. "Liquid Glass" (`AppColors`/`AppTypography`/`AppDecorations`, seed `#1E88E5`, Cinzel/
   Raleway/JetBrains Mono).
2. "Design Moderne Épuré Bleu" V2 (`AppTheme` v1, Inter, seed `#4A90E2`).

Direction artistique produite par Claude Design (projet `Marbre & Lumière`, fichier
`Apollon DA Finale.dc.html`) à partir de `docs/DIRECTION-ARTISTIQUE-BRIEF.md`.

---

## Table des matières

1. [Principes](#principes)
2. [Palette de couleurs](#palette-de-couleurs)
3. [Groupes musculaires](#groupes-musculaires-14)
4. [Typographie](#typographie)
5. [Rayons et ombres](#rayons-et-ombres)
6. [Composants signature](#composants-signature)
7. [Composants standards](#composants-standards)
8. [Bonnes pratiques](#bonnes-pratiques)

---

## Principes

Apollon est le dieu grec de la lumière : la direction artistique traduit ça par une
matière plutôt qu'un décor - marbre chaud en mode clair, nuit minérale en mode sombre,
un filet d'or réservé aux éléments qui portent un sens (série validée, record, arc de
progression), et un geste lumineux unique répété d'écran en écran ("Le Rayon",
`RayonSweep`).

Trois règles dures, non négociables côté implémentation :

- **Cinzel est réservé à l'identité** (wordmark, titre d'écran, nom d'exercice, symbole de
  marque) : plancher dur de 20px, exclu du corps de texte. Manrope couvre le reste de
  l'interface, JetBrains Mono a le monopole des chiffres (séries, minuteur, statistiques).
- **"Le Rayon" ne boucle pas.** `RayonSweep` joue un seul passage à l'apparition ou à la
  validation d'une surface - `AnimationController.repeat()` n'est appelé nulle part dans
  son implémentation actuelle.
- **`BackdropFilter` (flou de fond) est exclu des composants signature.** `GlassOrbButton`
  et `MarbleCard` sont des matières (dégradés + bordure + ombre), pas du glassmorphism -
  coûteux en performance et écarté par le brief.

---

## Palette de couleurs

### Couleurs d'action (bleu)

Constantes "bare" = valeur sombre (consommées sans branchement de luminosité par des
écrans préexistants hors périmètre de cette DA - graphiques de statistiques, calendrier
d'assiduité). Les variantes `light*` portent la valeur claire correcte, utilisées par le
`ColorScheme` Material et les composants réécrits (`RayonSweep`, `PictogramPlinth`,
`EmptyStateCard`, `CriticalCta`, `FloatingWorkoutTimer`, `PRCelebrationOverlay`, écran de
connexion, accueil, session).

| Rôle | Sombre (bare) | Clair (`light*`) |
|------|---------------|-------------------|
| Primaire | `primaryBlue` `#4E92CF` | `lightPrimaryBlue` `#17568C` |
| Primaire foncé | `primaryBlueDark` `#255F97` | `lightPrimaryBlueDark` `#0E3A62` |
| Primaire clair | `primaryBlueLight` `#7FB6E8` | `lightPrimaryBlueLight` `#4E92CF` |

### Couleurs sémantiques

| Rôle | Sombre | Clair |
|------|--------|-------|
| Succès | `successGreen` `#35D9A6` | `lightSuccessGreen` `#0E7A5F` |
| Erreur | `errorRed` `#FF6B5A` | `lightErrorRed` `#C0392B` |
| Avertissement | `warningOrange` `#F2A93B` | `lightWarningOrange` `#9A6410` |

### Or Apollon - réservé au mérite, pas un aplat décoratif

| Rôle | Sombre | Clair | Usage |
|------|--------|-------|-------|
| `accentGold` | `#D9B978` | `lightAccentGold` `#8A6A2F` | Texte or (compteurs de records, libellés d'accomplissement) |
| `accentGoldLine` | `#D9B978` | `lightAccentGoldLine` `#B08D57` | Traits 1-2px (série validée, onglet actif, arête du CTA critique, arc de l'orbe) |
| `accentGoldGlow*` | `accentGoldGlowDark` `#F0D9A2` | `accentGoldGlowLight` `#C7A96B` | "Le Rayon" et halo de célébration de record - role decoratif, pas porteur de sens |

### Surfaces - "Nuit minérale" (sombre) / "Marbre chaud" (clair)

| Rôle | Sombre | Clair |
|------|--------|-------|
| Fond | `darkBackground` `#0A0E16` | `lightBackground` `#F6F3EC` |
| Surface | `darkSurface` `#121826` | `lightSurface` `#FDFBF7` |
| Surface variante | `darkSurfaceVariant` `#1C2432` | `lightSurfaceVariant` `#EDE8DE` |
| Texte principal | `darkOnBackground` `#F2EFE9` | `lightOnBackground` `#141B2B` |
| Texte secondaire | `darkOnSurface` `#DCD8D0` | `lightOnSurface` `#2B3444` |
| Texte atténué | `darkOnSurfaceMuted` `#98A1B0` | `lightOnSurfaceMuted` `#5C6577` |
| Bordure de carte | `outlineSubtleDark` (blanc 8%) | `outlineSubtleLight` (`#141B2B` 9%) |

Une seule opacité de bordure par mode - pas de dégradé de bordures.

### Socle pictogramme - dégradé ardoise

Les silhouettes SVG du catalogue d'exercices (`#EEEEEE`/`#CCCCCC`) sont illisibles posées
directement sur une surface claire - `PictogramPlinth` corrige ce défaut avec un socle
dégradé dédié, identique à un ton près dans les deux modes :

| Rôle | Sombre | Clair |
|------|--------|-------|
| Haut du dégradé | `pictogramPlinthTopDark` `#26313F` | `pictogramPlinthTopLight` `#2A3949` |
| Bas du dégradé | `pictogramPlinthBottomDark` `#0F151F` | `pictogramPlinthBottomLight` `#141B2B` |

### Mesh gradient (fonds animés)

Amplitude volontairement faible - le mesh reste en retrait derrière le contenu, il respire
en arrière-plan (cycle de 18s, voir `MeshGradientBackground`).

- `lightMeshGradient` : `#F8F5EF`, `#EDF0F4`, `#F2ECE0`, `#FBF9F5`
- `darkMeshGradient` : `#0A0E16`, `#101A2A`, `#16202E`, `#0C1119`

---

## Groupes musculaires (14)

Chaque groupe a une paire de couleurs clair/sombre distincte, la teinte tournant du rouge
au magenta en suivant le corps de l'avant vers l'arrière puis du haut vers le bas. Chaque
paire est vérifiée à un contraste minimum de 4.5:1 sur son fond de référence
(`test/core/theme/contrast_test.dart`).

| Groupe | Clair (`muscleGroupColorsLight`) | Sombre (`muscleGroupColorsDark`) |
|--------|-----------------------------------|-------------------------------------|
| Pectoraux | `#AC3D4D` | `#FF98A1` |
| Épaules | `#A94608` | `#FDA075` |
| Abdominaux | `#985800` | `#E9AE57` |
| Lombaires | `#6F6E00` | `#BFC15C` |
| Quadriceps | `#337C20` | `#8ECE80` |
| Ischio-jambiers | `#008153` | `#60D4A7` |
| Triceps | `#008274` | `#3ED4C5` |
| Mollets | `#007E90` | `#34D1E0` |
| Dorsaux | `#0073AF` | `#5FC7FF` |
| Trapèzes | `#2369BA` | `#82BEFF` |
| Avant-bras | `#535EBB` | `#A3B4FF` |
| Biceps | `#7751AF` | `#C7A8FF` |
| Fessiers | `#8C489C` | `#DEA0EC` |
| Cardio | `#9D4183` | `#F09AD4` |

`AppTheme.colorForMuscleCode(code)` résout la couleur de pastille par code muscle API
(table `muscleGroupColors`, séparée des 14 groupes FR ci-dessus), avec repli sur
`primaryBlue` pour tout code non référencé.

---

## Typographie

Trois polices, un rôle chacune (Google Fonts, chargées à l'exécution) :

| Police | Rôle | Restriction |
|--------|------|-------------|
| **Cinzel** | Identité (wordmark, titre d'écran, nom d'exercice, symbole de marque) | Réservé à l'identité : plancher dur de 20px, exclu du corps de texte |
| **Manrope** | Interface (labels, boutons, corps de texte) | - |
| **JetBrains Mono** | Chiffres (séries, minuteur, statistiques) | - |

### Helpers `AppTheme` (à utiliser plutôt que `GoogleFonts.*` directement)

| Helper | Police | Taille | Usage |
|--------|--------|--------|-------|
| `screenTitle(color)` | Cinzel | 27px / w500 | Titre d'écran, nom d'exercice |
| `wordmark(color, {fontSize: 17, trackingEm: 0.30})` | Cinzel | 17px par défaut (paramétrable) | Marque "APOLLON" - seule exception au plancher de 20px car c'est la marque elle-même |
| `markGlyph(color)` | Cinzel | 106px / w600 | Glyphe du symbole de marque (écran de connexion) |
| `seriesNumber(color, {active: false})` | JetBrains Mono | 30px / 34px si actif | Chiffres de série - posés sur `surface`, pas sur un fond coloré |
| `timerNumber(color)` | JetBrains Mono | 19px, chasse fixe | Minuteur - les chiffres ne bougent pas d'un pixel entre deux secondes |
| `labelSecondary(color)` | Manrope | 11px / w600, capitales | Libellés secondaires ("DERNIÈRE SÉANCE", unités) |
| `buttonLabel(color)` | Manrope | 15px / w700 | Libellé de bouton |

Le `TextTheme` Material générique (`displayLarge`, `bodyMedium`, etc.) est entièrement en
Manrope - Cinzel en est absent, précisément pour empêcher un usage accidentel sous le
plancher de 20px.

---

## Rayons et ombres

### Rayons (resserrés depuis la V2, qui généralisait 24px)

| Token | Valeur | Usage |
|-------|--------|-------|
| `radiusS` | 6px | Badges, pastilles, puces carrées |
| `radiusM` | 10px | Champs de saisie, petits boutons |
| `radiusL` | 12px | Boutons principaux, pods de statistiques |
| `radiusXL` | 14px | Cartes, tuiles, minuteur, CTA critique |
| `radiusXXL` | 20px | Bottom sheets et dialogs uniquement |
| `radiusPill` | 999px | Puces de filtre exclusivement |

### Ombres à deux niveaux (`shadowElev1`/`shadowElev2`, prennent un `Brightness`)

En mode sombre, l'élévation ne passe pas seulement par l'ombre : une surface plus claire
plus un filet de lumière haut de 1px (implémenté via une bordure, pas via `BoxShadow` qui
ne supporte pas l'inset en Flutter).

- `shadowElev1` : élévation standard (cartes au repos).
- `shadowElev2` : élévation forte (`MarbleCard`, cartes actives).

---

## Composants signature

Composants réécrits pour cette direction artistique, sous `lib/core/widgets/` :

### `RayonSweep` (`rayon_sweep.dart`)

"Le Rayon" : fait traverser une bande lumineuse inclinée (18°) sur son enfant, un seul
passage par activation du paramètre `trigger` (pas de répétition automatique - la
consigne "pas de boucle par défaut" se traduit par l'absence d'appel à `repeat()` sur
l'`AnimationController`). Respecte `MediaQuery.disableAnimations`.

Implémenté via `ShaderMask` en `BlendMode.plus` : ce mode est additif et **ignore l'alpha
du fond en dehors de la forme visible de l'enfant**. Sur un enfant non rectangulaire
(l'orbe circulaire de `GlassOrbButton`), le reflet déborde dans les coins du carré
englobant si l'appelant ne pose pas lui-même un `ClipOval` (ou une forme équivalente)
autour du `RayonSweep` - c'est un piège d'intégration réel, pas hypothétique (corrigé en
v1.2.0 sur `GlassOrbButton`).

### `MarbleCard` (`marble_card.dart`)

Veinage marbre par deux dégradés linéaires superposés à très basse opacité (112° et 24°),
sans image ni texture bitmap. **Garde-fou de spec : réservée à une seule carte par écran**
- celle qui porte le sens (progression, record, bilan de séance, accroche du login). Pour
des listes ou tuiles répétitives, utiliser `AppCard` standard.

### `PictogramPlinth` (`pictogram_plinth.dart`)

Socle en dégradé ardoise pour poser un pictogramme SVG d'exercice - corrige leur
illisibilité sur `surface`/`surfaceVariant` clairs (défaut réel du catalogue).

### `GlassOrbButton` (`glass_orb_button.dart`)

Orbe circulaire "Nouvelle séance" - malgré son nom historique, ce n'est pas du
glassmorphism : dégradé radial à 3 arrêts (source de lumière à 30%/18%), bordure 1px,
filet interne haut, arc de progression 3px en or, ombre portée colorée. Sans flou de fond
(`BackdropFilter` proscrit). Diamètre 212px (168px minimum sur petit écran). Le
`RayonSweep` de l'orbe est enveloppé dans un `ClipOval`.

### `CriticalCta` (`critical_cta.dart`)

CTA pleine largeur pour l'action critique d'un écran (ex. "Terminer la séance").

### `EmptyStateCard` (`empty_state_card.dart`)

État vide standard (ex. "Pas de séance pour l'instant").

---

## Composants standards

| Composant | Rôle |
|-----------|------|
| `AppCard` | Carte générique animée (pression = surface légèrement plus claire, 120ms) - `AppCardVariant.standard`/`elevated`/`outlined` |
| `AppButton` | Bouton standard animé |
| `AppTextField` | Champ de saisie |
| `AppBarWidget` | AppBar Material 3 |
| `MeshGradientBackground` | Fond en dégradé animé (4 couleurs, cycle 18s) |
| `FloatingWorkoutTimer` | Minuteur global flottant type Dynamic Island, lit `WorkoutProvider` |
| `ProfileDrawer` | Tiroir de navigation (lit `AuthProvider` + `WorkoutProvider`) |
| `ThemeSwitcher` | Bascule de thème (`Consumer<ThemeProvider>`) |
| `PRCelebrationOverlay` (`showPrCelebration()`) | Popup de célébration animée (confetti) au nouveau record |

---

## Bonnes pratiques

1. **Éviter d'appeler `GoogleFonts.*` directement dans un écran.** Passer par les helpers
   `AppTheme` (`screenTitle`, `wordmark`, `seriesNumber`...) pour que le plancher de 20px
   sur Cinzel et la cohérence des tailles restent centralisés.
2. **Une seule `MarbleCard` par écran.** Le garde-fou de spec est documenté dans le widget
   lui-même - respectez-le, ne le contournez pas pour un effet visuel ponctuel.
3. **`RayonSweep` sur une forme non rectangulaire → un `Clip*` autour est nécessaire.**
   C'est le bug réel corrigé en v1.2.0 sur `GlassOrbButton` ; il se reproduira sur tout
   futur composant circulaire ou à coins très arrondis qui oublierait ce clip.
4. **`PictogramPlinth`, pas `surface`/`surfaceVariant` nu, sous un pictogramme SVG.** Les
   silhouettes du catalogue sont conçues pour un fond sombre.
5. **Couleurs bare vs `light*` :** dans du code neuf, préférez résoudre la couleur selon
   `Theme.of(context).brightness` (`isDark ? X : lightX`) plutôt que consommer une
   constante bare brute - ces dernières existent pour la compatibilité d'écrans
   préexistants hors périmètre, pas comme modèle à reproduire.
6. **Éviter `BackdropFilter` dans les composants signature.** Si un nouvel écran a besoin
   d'un effet de matière, partez de `MarbleCard`/`GlassOrbButton` comme référence plutôt
   que de réintroduire du flou de fond.

---

**Dernière mise à jour :** 6 août 2026
**Voir aussi :** [CHANGELOG.md](../CHANGELOG.md#120---2026-08-06-refonte-visuelle-marbre--lumière), [CLAUDE.md](../CLAUDE.md)
