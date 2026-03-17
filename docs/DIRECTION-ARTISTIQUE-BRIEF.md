f# DIRECTION ARTISTIQUE - BRIEF COMPLET
# Application Apollon

**Document a destination de:** Expert Direction Artistique / Designer UI-UX  
**Version:** 1.0  
**Statut:** Brief de travail  
**Langue:** Francais  

---

## TABLE DES MATIERES

1. [Presentation du projet](#1-presentation-du-projet)
2. [Contexte et problematique utilisateur](#2-contexte-et-problematique-utilisateur)
3. [Profil utilisateur cible](#3-profil-utilisateur-cible)
4. [Positionnement de marque](#4-positionnement-de-marque)
5. [Architecture de l'application](#5-architecture-de-lapplication)
6. [Description detaillee des ecrans](#6-description-detaillee-des-ecrans)
7. [Design System existant](#7-design-system-existant)
8. [Etat actuel et points de friction identifies](#8-etat-actuel-et-points-de-friction-identifies)
9. [Attentes vis-a-vis de la Direction Artistique](#9-attentes-vis-a-vis-de-la-direction-artistique)
10. [Contraintes techniques](#10-contraintes-techniques)
11. [References et inspirations](#11-references-et-inspirations)
12. [Criteres de succes](#12-criteres-de-succes)

---

## 1. PRESENTATION DU PROJET

### Qu'est-ce qu'Apollon ?

**Apollon** est une application mobile Flutter de suivi de progression en musculation, destinee aux pratiquants de salle de sport. L'application permet a un utilisateur de :

- Enregistrer ses seances d'entrainement en temps reel (exercices + series + poids)
- Retrouver immediatement les poids utilises lors de sa derniere seance pour chaque exercice
- Consulter l'historique complet de ses entrainements

### Origine du nom

"Apollon" est une reference directe au dieu grec de la beaute, de la perfection physique et des arts. Ce choix n'est pas anodin : il ancre l'application dans une ambition **premium, esthetique et elitiste** — celle d'une app qui merite autant la beaute que la performance.

### Stade de developpement

- Application fonctionnelle en cours de developpement (MVP V1)
- Stack technique : Flutter + Firebase (Firestore + Google Auth)
- Plateforme cible principale : Android, iOS secondaire
- Developpeur solo, profil intermediaire Flutter / debutant Firebase
- Timeline : 3 mois, 36 heures de developpement total

---

## 2. CONTEXTE ET PROBLEMATIQUE UTILISATEUR

### Le probleme reel

**"A combien j'avais fait au dernier entrainement ?"**

C'est la question que se pose chaque pratiquant de musculation au moment de s'installer sur un appareil ou une barre. Sans reponse rapide, l'utilisateur tatonne, sous-performe, ou perd du temps. La progression en musculation est directement liee a la **surcharge progressive** — augmenter les charges et les repetitions au fil du temps — ce qui necessite de connaitre son point de depart.

### Pourquoi les apps existantes ne satisfont pas

Les applications de tracking musculation du marche (Hevy, Strong, MyFitnessPal, etc.) souffrent d'un probleme commun : **elles ont ete congues pour etre completes, pas pour etre belles.** Leur UX est fonctionnelle mais leur design est generique, peu inspire, voire repoussant pour un utilisateur sensible a l'esthetique.

### La promesse d'Apollon

Apollon doit etre **l'app qu'on a envie d'ouvrir** — pas juste celle qu'on utilise parce qu'on n'a pas le choix. Elle doit faire sentir a l'utilisateur qu'il utilise un outil premium, concu avec soin, qui respecte son gout pour les belles choses autant que son besoin de performance.

---

## 3. PROFIL UTILISATEUR CIBLE

### Persona principal : "Le Passionné Esthète"

| Attribut | Description |
|---|---|
| Age | 20-35 ans |
| Pratique | Musculation en salle, 3-5 sessions/semaine |
| Niveau | Intermediaire a avance (pas debutant) |
| Rapport au design | Tres sensible — possede un iPhone/Android haut de gamme, aime les apps bien designees |
| Rapport a la perf | Methodique, suit sa progression, veut progresser |
| Douleur actuelle | Perd du temps a se souvenir des charges, frustre par les apps moches existantes |
| Attente | Une app aussi belle qu'efficace, qui l'aide vraiment |

### Comportement d'usage en salle

- L'utilisateur consulte son telephone **pendant la seance**, entre les series
- Il est en mouvement, parfois les mains moites ou gantees
- Il est dans un environnement lumineux variable (salle eclairee ou semi-eclairee)
- Il veut aller vite : saisir les poids en moins de 10 secondes par serie
- Il consulte l'historique avant de commencer chaque exercice (moins de 1 seconde d'attente tolere)

### Implication pour la DA

- **Lisibilite maximale** en toutes conditions de luminosite
- **Touch targets genereux** (mains occupees, gestes rapides)
- **Hierarchie visuelle forte** (les chiffres — poids et repetitions — doivent sauter aux yeux)
- **Fluidite** : 60fps minimum, aucune lenteur percue
- **Mood** : inspire, motivant, premium — pas medicale, pas utilitaire

---

## 4. POSITIONNEMENT DE MARQUE

### Territoire de marque

Apollon se positionne sur l'intersection de **3 univers** :

```
PERFORMANCE SPORTIVE  +  DESIGN PREMIUM  +  CULTURE GRECQUE ANTIQUE
```

Ce n'est pas une app de "tracking de calories" generique. C'est un outil de sculpteur — celui qui taille son corps avec methode et ambition, et qui merite un outil a la hauteur.

### Valeurs de marque

| Valeur | Expression concrète |
|---|---|
| **Excellence** | Finitions soignees, aucun detail laisse au hasard |
| **Puissance** | Formes imposantes, typographie forte, energie visuelle |
| **Elegance** | Minimalisme assumé, espace blanc maîtrisé, jamais vulgaire |
| **Precision** | Chiffres lisibles, hierarchie claire, zero ambiguité |
| **Modernite** | Pas nostalgique — la Grece antique reinterpretee par le XXIe siecle |

### Ce qu'Apollon N'EST PAS

- Pas une app medicale ou de sante generique (pas d'iconographie croix rouge, stethoscope)
- Pas une app de coaching pour debutants (pas de ton "baby steps" ou illustrations cartoon)
- Pas une app luxe inaccessible (premium mais accessible, pas ostentatoire)
- Pas une app "hardcore" bodybuilding (pas de visuels agressifs, pas de testosteronе visuelle)

### Moodboard de territoire (a titre indicatif)

Pour donner une idee du territoire :
- **Nike Training Club** (fluidite, energie, minimalisme)
- **Apple Fitness+** (premium, propre, elitiste)
- **Whoop** (sophistique, technique, noir)
- **Centurion Amex card** (prestige discret, matiere, texture)

---

## 5. ARCHITECTURE DE L'APPLICATION

### Structure de navigation

```
Apollon
├── Connexion (Ecran Google Auth)
│
└── Application principale
    ├── Accueil (Home)
    │   ├── Section progression
    │   ├── Categories d'exercices
    │   └── Derniers entrainements
    │
    ├── Bibliotheque d'exercices (selection)
    │   ├── Navigation par Groupe Musculaire
    │   ├── Navigation par Type d'exercice
    │   └── Recherche par nom
    │
    ├── Session d'entrainement (par exercice)
    │   ├── Header exercice (image + nom + groupe + description)
    │   ├── Historique derniere seance (texte) + Graphique d'amélioration
    │   └── Saisie series (reps + poids)
    │
    ├── Historique des seances
    │   ├── Liste des seances passees
    │   └── Detail d'une seance
    │
    └── Statistiques
        ├── Progression par exercice
        └── Records personnels (PR)
```

### Hierarchie des donnees (Glossaire metier)

Comprendre la hierarchie est essentiel pour concevoir la bonne information architecture :

```
UTILISATEUR
    └── SEANCES (une seance = un entrainement complet)
            └── EXERCICES (ex: "Developpé couché barre")
                    └── SERIES (ex: "12 reps x 80 kg")
```

**Groupes musculaires** (systeme de categorisation/navigation) :
Pectoraux, Dorsaux, Epaules, Biceps, Triceps, Abdominaux, Quadriceps, Ischio-jambiers, Fessiers, Mollets, Cardio, Avant-bras

**Types d'exercices** (second filtre de navigation) :
Poids libres (barres/halteres), Machine guidee, Poids corporel, Cardio

---

## 6. DESCRIPTION DETAILLEE DES ECRANS

### Ecran 1 : Connexion (Login)

**Role :** Point d'entree obligatoire. L'utilisateur se connecte via son compte Google.

**Contrainte fonctionnelle :** RG-001 — Aucun acces sans authentification Google.

**Elements UI requis :**
- Identite visuelle forte de l'application (logo, nom, tagline eventuelle)
- Bouton "Se connecter avec Google" (standard Google Sign-In)
- Background immersif

**Enjeu DA :**
C'est la **premiere impression**. Cet ecran doit communiquer immediatement l'identite premium et l'ambition du produit. C'est l'equivalent de la couverture d'un livre.

---

### Ecran 2 : Accueil (Home)

**Role :** Dashboard principal, point de depart de chaque session.

**Elements UI actuellement implementes :**
- AppBar avec titre "Apollon" et avatar utilisateur
- Message de bienvenue contextuel selon l'heure ("Prêt à sculpter ta perfection ?")
- Section progression circulaire (pourcentage seances completees)
- Section categories exercices (scroll horizontal)
- Section derniers entrainements

**Bouton d'action principal :**
"Nouvelle seance" — c'est le CTA le plus important de toute l'application. Le processus P2 (Enregistrer une seance) est le coeur du produit.

**Enjeu DA :**
Trouver l'equilibre entre **richesse d'information et clarte d'action**. L'utilisateur doit voir en un coup d'oeil ou il en est et pouvoir demarrer une seance en 1 tap.

---

### Ecran 3 : Bibliotheque d'exercices

**Role :** Navigation et selection d'un exercice pour la seance en cours.

**Comportement fonctionnel :**
- Navigation par groupe musculaire (onglets ou grille de categories)
- Chaque categorie affiche la liste des exercices associes
- Recherche textuelle disponible
- ~50 exercices pre-charges (seed data) + possibilite future d'en ajouter

**Donnees affichees par exercice :**
- Nom de l'exercice
- Groupe(s) musculaire(s) cible(s)
- Type d'exercice (icone ou badge)
- Emoji representatif de la categorie (V1, images IA en V2)

**Enjeu DA :**
La navigation doit etre **rapide et intuitive**. En salle, l'utilisateur sait ce qu'il veut faire — il faut lui permettre de le trouver en 2-3 taps maximum. Les categories musculaires sont le point d'entree naturel.

---

### Ecran 4 : Session d'entrainement (Workout Session)

**Role :** Ecran coeur du produit. C'est ici que se passe la saisie des donnees en temps reel.

**Structure de l'ecran :**

```
[Header : Image exercice + Nom + Groupe musculaire]
         ↓
[Section Historique]                                                [Section graphique ]
 "Derniere seance (12/02/2026):"
  • Serie 1 : 12 reps x 80 kg                                       Graphique de l'évolution
  • Serie 2 : 10 reps x 80 kg
  • Serie 3 : 8 reps x 82.5 kg
  [OU : "Pas de seance pour l'instant" si premier usage]
         ↓
[Section Series actuelles]
  • Serie 1 : [12] reps x [80] kg  [supprimer]
  • Serie 2 : [10] reps x [80] kg  [supprimer]
  [+ Ajouter une serie]
         ↓
[Bouton "Terminer l'exercice"]
[Bouton "Terminer la seance"]
```

**Regles fonctionnelles critiques :**
- RG-003 : reps > 0 et poids >= 0 (validation en temps reel)
- RG-004 : sauvegarde automatique toutes les 10 secondes (seance brouillon)
- RG-005 : historique en texte simple (pas de graphiques en V1)
- RG-006 : la seance n'est finalisee QUE sur "Terminer la seance"

**Edge case important :**
- EC-001 : Premiere utilisation d'un exercice → afficher "Pas de seance pour l'instant" (pas d'erreur, pas de vide moche)
- EC-004 : Suppression d'une serie avec confirmation

**Enjeu DA :**
C'est l'ecran le plus utilise. Les **chiffres (poids et reps) sont le contenu principal** — ils doivent etre immediatement lisibles. La section historique doit etre suffisamment visible pour etre utile (l'utilisateur copie mentalement ses poids) sans ecraser la zone de saisie active. Trouver le bon rapport visuel entre "ce que j'ai fait" et "ce que je fais maintenant".

---

### Ecran 5 : Historique des seances

**Role :** Consultation de toutes les seances passees.

**Structure :**
- Liste triee par date decroissante
- Chaque item : date + nombre d'exercices + duree (V2)
- Tap → Detail complet : liste des exercices + series

**Enjeu DA :**
L'historique doit donner un sentiment de **progression et d'accumulation** — voir la liste de ses entrainements doit etre gratifiant. Le vide (premiere utilisation) doit encourager sans culpabiliser.

---

### Ecran 6 : Statistiques et Records Personnels

**Role :** Vue de progression par exercice et records personnels (PR).

**Contenu V1 :**
- Progression de charge maximale par exercice (texte simple)
- Liste des PR (records personnels) par exercice

**Contenu V2 (prevu) :**
- Graphiques de progression (poids vs repetitions)
- Calendrier visuel des seances
- Statistiques avancees (volume total, frequence)

**Enjeu DA :**
Meme en V1, cet ecran doit donner **envie de progresser**. La donnée brute doit etre sublimee visuellement pour generer de la fierté et de la motivation.

---

### Ecran transversal : Drawer / Profil

**Role :** Navigation secondaire et informations profil.

**Elements :**
- Avatar Google + nom utilisateur
- Liens vers sections principales
- Bouton deconnexion
- Toggle Dark/Light mode

---

## 7. DESIGN SYSTEM EXISTANT

Cette section documente ce qui a deja ete defini et code dans l'application. La DA doit s'appuyer sur ces fondations ou proposer une evolution argumentee.

### 7.1 Palette de couleurs actuelle

#### Couleur primaire

| Role | Hex | Description |
|---|---|---|
| Bleu primaire | `#4A90E2` | Bleu moderne, couleur dominante |
| Bleu fonce | `#2E5C8A` | Variations, profondeur |
| Bleu clair | `#7BB5F0` | Hover, disabled, accents |

#### Couleurs semantiques

| Role | Hex | Usage |
|---|---|---|
| Succes | `#00D9A3` | Validations, progression positive |
| Erreur | `#E74C3C` | Erreurs, alertes |
| Warning | `#FF9F43` | Avertissements |

#### Palette neutre (backgrounds)

| Mode | Background | Surface | Surface Variant |
|---|---|---|---|
| Light | `#FAFAFA` | `#FFFFFF` | `#F5F5F5` |
| Dark | `#1A1A24` | `#1A1A24` | `#252535` |

#### Couleurs premium (definies mais usage a renforcer)

| Nom | Hex | Role |
|---|---|---|
| Or pur | `#FFD700` | Highlights premium, records |
| Or clair | `#FFE57F` | Variantes or |
| Or brûle | `#FFA000` | Or profond |
| Marbre blanc | `#F8F9FA` | Backgrounds elegants |
| Marbre sombre | `#263238` | Dark mode premium |

#### Couleurs par groupe musculaire (systeme semantique)

Chaque groupe musculaire a une couleur d'accent dediee :

| Groupe | Hex |
|---|---|
| Pectoraux | `#E74C3C` (rouge) |
| Dorsaux | `#3498DB` (bleu) |
| Epaules | `#F39C12` (orange) |
| Biceps | `#9B59B6` (violet) |
| Triceps | `#1ABC9C` (turquoise) |
| Abdominaux | `#E67E22` (orange fonce) |
| Quadriceps | `#27AE60` (vert) |
| Fessiers | `#C0392B` (rouge fonce) |
| Cardio | `#E91E63` (rose) |

---

### 7.2 Typographie actuelle

**Note :** Deux systemes typographiques coexistent dans le code actuel — une tension a resoudre dans la DA.

#### Systeme A (app_typography.dart) — Style "Apollon Heritage"

| Role | Police | Usage |
|---|---|---|
| Titres / Headlines | **Cinzel** (Google Fonts) | Style grec noble, serif elegante avec influence antique |
| Corps de texte | **Raleway** (Google Fonts) | Moderne, lisible, elegant |
| Chiffres (poids/reps) | **JetBrains Mono** | Lisibilite maximale des valeurs numeriques |

**Philosophie :** Cinzel cree une identite forte liee au nom "Apollon" — ses empattements serifs rappellent les inscriptions sur marbre grec. Raleway apporte la modernite. JetBrains Mono garantit que les chiffres (le contenu principal) soient toujours lisibles.

#### Systeme B (app_theme.dart) — Style "Modern Clean"

| Role | Police | Usage |
|---|---|---|
| Tout | **Inter** (Google Fonts) | Police systemique, ultra-lisible, neutre |

**Philosophie :** Inter est la police de reference du design d'interface moderne. Elle maximise la lisibilite et la neutralite.

---

### 7.3 Espacements et border-radius

#### Systeme d'espacement

| Token | Valeur | Usage |
|---|---|---|
| XS | 4px | Micro-espacement |
| S | 8px | Elements serrés |
| M | 16px | Espacement standard |
| L | 24px | Padding ecran |
| XL | 32px | Entre sections |
| XXL | 48px | Grandes sections |

#### Systeme de coins arrondis

| Token | Valeur | Usage |
|---|---|---|
| S | 8px | Badges, petits elements |
| M | 12px | Boutons secondaires |
| L | 16px | Boutons principaux, inputs |
| XL | 20px | Cards |
| XXL | 24px | Bottom sheets, dialogs |

---

### 7.4 Style visuel actuel (etat implementé)

Le design actuel est un "Modern Flat" avec :
- **Neumorphisme** (Jeu d'ombre et de lumière pour donner un effet d'élévation)
- **Borders subtiles** (1px, opacite 10%) a la place des ombres
- **Fond uni** (pas de gradient anime — performance)
- **Cards plates** avec border radius XL (20px)
- Inspiration initiale "Liquid Glass" (glassmorphisme) partiellement abandonnee au profit du flat design

---

### 7.5 Composants existants

Composants deja codes dans `lib/core/widgets/` :

| Composant | Description |
|---|---|
| `AppCard` | Card standard avec border subtile |
| `MarbleCard` | Card avec texture marbre premium |
| `GlassOrbButton` | Bouton circulaire avec effet de profondeur |
| `AppButton` | Bouton principal standardise |
| `AppTextField` | Input standardise |
| `AppBackground` | Background avec gradient mesh anime |
| `MeshGradientBackground` | Background premium anime |
| `ModernCircularProgress` | Indicateur progression circulaire |
| `FloatingWorkoutTimer` | Timer flottant persistant |
| `PRCelebrationOverlay` | Animation celebration record personnel |

---

## 8. ETAT ACTUEL ET POINTS DE FRICTION IDENTIFIES

### Points de friction (a resoudre dans la DA)

**Point 1 : Identite visuelle incomplete**  
Le nom "Apollon" porte une promesse forte (Grece antique, perfection, beaute) que le design actuel ne tient pas completement. Le bleu generique `#4A90E2` ne differencie pas Apollon d'une app bancaire ou d'une app meteo. L'identite visuelle n'a pas encore trouve son expression unique.

**Point 2 : Tension typographique non resolue**  
Deux systemes de polices coexistent (Cinzel/Raleway vs Inter). La DA doit statuer sur ce point.

**Point 3 : Manque d'un element visuel signature**  
L'application n'a pas encore de "moment wow" — un element visuel distinctif qui fait dire "c'est Apollon". Que ce soit un traitement de la couleur, une animation signature, un pattern graphique ou un traitement typographique, cet element reste a imaginer.

---

## 10. CONTRAINTES TECHNIQUES

### Contraintes strictes (non negociables)

- **Plateforme :** Application mobile Flutter (Android + iOS)
- **Performance :** 60fps minimum sur tous les ecrans — les animations et effets visuels ne doivent pas degrader les performances
- **Modes :** Dark mode ET Light mode obligatoires — la DA doit fonctionner dans les deux modes
- **Accessibilite :** Contraste WCAG AA minimum sur tous les textes
- **Touch targets :** Minimum 48x48px pour tous les elements interactifs
- **Emojis dans le code :** INTERDITS dans le code source, les commits et la documentation technique. Autorises uniquement dans les conversations et le contenu utilisateur.

### Contraintes de performance specifiques

- Les effets de flou (backdrop blur) sont couteux en performance sur Android — a utiliser avec parcimonie
- Les gradients animes (mesh gradient) sont implementes mais peuvent etre desactives si necessaire
- Les animations doivent durer entre 150ms et 400ms pour rester dans le budget de frame

### Contraintes de faisabilite

- Developpeur solo, intermediaire Flutter
- 36 heures de developpement total pour le MVP
- Les composants doivent etre implementables en Flutter avec les packages standards

### Packages disponibles

| Package | Usage |
|---|---|
| `google_fonts` | Polices Google (Cinzel, Raleway, Inter, JetBrains Mono disponibles) |
| `flutter_animate` | Animations declaratives |
| `fl_chart` | Graphiques (V2) |
| `cached_network_image` | Images cachees |
| `provider` | State management |

---

## 11. REFERENCES ET INSPIRATIONS


### Univers de reference (pour aller plus loin)

**Applications fitness premium :**
- Nike Training Club (energie, mouvement)
- Apple Fitness+ (qualite Apple, premium)
- Strava (design sportif clair)
- Whoop (sophistication technique)

**Identites visuelles inspirantes pour le territoire "Apollon" :**
- Musees d'antiquites (British Museum, Louvre) : leur brand design combine heritage et modernite
- Maisons de luxe sportif (Hermès x sport, Berluti) : quand le luxe rencontre la performance
- Architecture minimaliste grecque moderne : blanc, ligne claire, lumiere

**Typographies de reference pour l'identite greco-moderne :**
- Cinzel (existant) : directement inspire des inscriptions romaines/grecques
- Optima (Hermann Zapf) : serif humaniste qui a inspire le logo Nike
- Trajan : utilise massivement dans les films historiques epiques
- EB Garamond avec variations display

---

## 12. CRITERES DE SUCCES

La Direction Artistique sera consideree reussie si :

### Criteres objectifs

- **CS-DA-01 :** Un utilisateur voit l'ecran de login et reconnait immediatement l'univers "premium sportif" sans avoir lu le nom
- **CS-DA-02 :** Les chiffres (poids et repetitions) sont lisibles en moins de 300ms, a 50cm de distance, en lumiere directe
- **CS-DA-03 :** Le design fonctionne en dark mode ET light mode sans degradation
- **CS-DA-04 :** Les 14 groupes musculaires sont visuellement differencies et memorables
- **CS-DA-05 :** L'application peut etre implementee par un developpeur Flutter intermediaire en 36 heures de travail

### Criteres subjectifs

- **CS-DA-06 :** L'utilisateur a "envie" d'ouvrir l'application — elle genere une emotion positive
- **CS-DA-07 :** L'application se distingue immediatement des apps fitness generiques du marche
- **CS-DA-08 :** Le nom "Apollon" et le design forment un tout coherent et memorisable

---

## ANNEXE A : VOCABULAIRE METIER

Glossaire des termes metier a connaitre pour la DA :

| Terme | Definition | Impact DA |
|---|---|---|
| **Exercice** | Mouvement lie a un equipement (ex: "Developpe couche barre") | Element de liste, card dans la bibliotheque |
| **Groupe musculaire** | Zone anatomique ciblee (pectoraux, biceps...) | Systeme de categorisation, couleurs semantiques |
| **Type d'exercice** | Nature de l'equipement (poids libres, machine, cardio) | Filtre secondaire, badge/icone |
| **Serie** | Ensemble de repetitions continues (ex: 12 reps x 80 kg) | Element de saisie, le contenu le plus affiche |
| **Seance** | Session complete d'entrainement | Unite principale dans l'historique |
| **Brouillon** | Seance non finalisee, conservee 24h | Etat UI specifique a communiquer |
| **Record personnel (PR)** | Poids ou volume jamais atteint | Moment de celebration, etat special |

---

## ANNEXE B : REGLES DE GESTION VISIBLES DANS L'UI

Ces regles fonctionnelles ont un impact direct sur le design :

| Regle | Impact UI / DA |
|---|---|
| **RG-001** : Auth Google obligatoire | L'ecran de login est le premier ecran, toujours visible si non connecte |
| **RG-003** : reps > 0, poids >= 0 | Les inputs de saisie doivent communiquer clairement les etats valide/invalide |
| **RG-004** : Sauvegarde auto toutes les 10s | Un indicateur de statut de sauvegarde peut etre present (discret) |
| **RG-005** : Historique en texte simple | La section historique affiche du texte structure, pas de graphique en V1 |
| **RG-006** : Finalisation sur "Terminer la seance" | Le bouton "Terminer la seance" est un CTA critique — son importance doit etre communiquee visuellement |
| **EC-001** : Premiere utilisation exercice | Etat vide = "Pas de seance pour l'instant" — doit etre traite avec soin |
| **EC-004** : Suppression avec confirmation | Les dialogs de confirmation existent — leur DA doit etre coherente |

---

**Document genere par :** Apollon Project Assistant  
**Base sur :** ProjectContext-Apollon.yaml + analyse du code source  
**Version :** 1.0  
**A destination de :** Expert Direction Artistique / Designer UI-UX
