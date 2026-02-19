# APOLLON

Application mobile Flutter de suivi de progression en musculation

---

## VUE D'ENSEMBLE

**Apollon** est une application mobile développée en Flutter permettant aux pratiquants de musculation de suivre leurs performances en salle de sport. L'objectif principal est de résoudre le problème d'oubli des poids utilisés lors des séances précédentes, tout en offrant une expérience utilisateur fluide et un design moderne Material 3.

### Problématique

- Oubli fréquent des poids utilisés lors des séances de musculation
- Perte de temps à tâtonner pour retrouver le bon poids à chaque exercice
- Progression sous-optimale par manque de traçabilité
- Applications existantes avec un design peu attractif

### Solution

Application mobile permettant :
- La saisie rapide des séances d'entraînement (exercices, séries, répétitions, poids)
- La visualisation instantanée de l'historique des performances
- Une interface fluide et intuitive avec design Material 3 moderne
- Une synchronisation cloud via Firebase pour accès multi-appareils

---

## GLOSSAIRE MÉTIER

L'application s'appuie sur 6 concepts métier principaux :

### EXERCICE
Mouvement de musculation lié à un équipement ou une machine spécifique avec sa variante.

**Exemples :** Développé couché à la barre, Smith Machine, Hack Squat, Pompes

**Attributs :**
- Nom unique
- Lié à un équipement/machine précis
- Chaque variante constitue un exercice distinct

**Relations :**
- Appartient à un ou plusieurs Groupes Musculaires
- Possède un Type d'Exercice
- Contient plusieurs Séries dans une Séance

### GROUPE MUSCULAIRE
Zone anatomique ciblée par un exercice de musculation.

**Exemples :** Pectoraux, Biceps, Triceps, Abdominaux, Quadriceps, Fessiers, Dorsaux, Épaules

**Caractéristiques :**
- Un exercice peut cibler plusieurs groupes musculaires simultanément
- Exemple : Développé couché → Pectoraux + Triceps
- Exemple : Squat → Quadriceps + Fessiers + Ischio-jambiers

**Usage :** Système de navigation principal pour sélectionner les exercices

### TYPE EXERCICE
Nature de l'équipement ou modalité d'exécution de l'exercice.

**Valeurs possibles :**
- Poids libres (barres, haltères)
- Machine guidée
- Poids corporel
- Cardio

**Usage :** Système de navigation secondaire (filtrage complémentaire)

### SÉRIE
Ensemble de répétitions continues effectuées sans pause pour un exercice donné.

**Attributs :**
- **Nombre de répétitions** : Entier strictement positif (> 0)
- **Poids en kg** : Décimal positif ou nul (≥ 0), où 0 kg = poids corporel

**Création :** Via bouton "Ajouter une série" → saisie répétitions + poids

**Relation :** Une série est toujours liée à UN exercice dans UNE séance

### SÉANCE
Session complète d'entraînement à la salle de sport.

**Attributs :**
- **Date** : Obligatoire, format ISO 8601
- **Durée totale** : Optionnel (prévu pour V2 avec chronomètre global)

**Contenu :** Liste d'exercices, chacun contenant plusieurs séries

**Hiérarchie :** SÉANCE → EXERCICES → SÉRIES (répétitions + poids)

**Workflow :**
1. Démarrage : Bouton "Nouvelle séance"
2. Ajout exercices et séries
3. Finalisation : Bouton "Terminer la séance" → Sauvegarde Firestore

### UTILISATEUR
Personne utilisant l'application (pratiquant de musculation).

**Authentification :** Connexion obligatoire via compte Google

**Données associées :**
- Historique complet de séances
- Préférences (futures : unité kg/lbs, exercices favoris)

**Permissions :**
- CRUD sur ses propres données (séances, exercices, séries)
- Isolation complète : aucun accès aux données des autres utilisateurs

---

## STACK TECHNIQUE

### Frontend
- **Framework :** Flutter/Dart
- **State Management :** Provider (recommandé pour V1)
- **Design System :** Material 3 moderne avec Raleway (#1E88E5)
  - Arrondis prononcés
  - Effets de transparence et flou
  - Animations fluides 60fps minimum
- **Thème :** Mode sombre et mode clair (obligatoires V1)

### Backend
- **Authentification :** Firebase Authentication (Google Sign-In)
- **Base de données :** Cloud Firestore
- **Mode hors ligne :** Support natif Firestore (offline-first avec synchronisation automatique)

### Plateformes
- **Principale :** Android (prioritaire)
- **Secondaire :** iOS (bonus)

### Infrastructure
- **Hébergement :** Firebase (plan gratuit pour démarrage)

---

## ARCHITECTURE

### Structure de données Firestore

```
users (collection)
  └─ {userId} (document)
      └─ sessions (collection)
          └─ {sessionId} (document)
              - date: timestamp
              - duration: number (optional)
              - exercises: array
                  - exerciseId: string
                  - exerciseName: string
                  - series: array
                      - reps: number (> 0)
                      - weight: number (≥ 0)

exercises (collection)
  └─ {exerciseId} (document)
      - name: string (unique)
      - muscleGroups: array[string]
      - type: string (poids libres | machine | poids corporel | cardio)
      - icon: string (emoji V1, image IA V2)
```

### Hiérarchie des données

```
UTILISATEUR
  └─ SÉANCES
      └─ EXERCICES
          └─ SÉRIES
```

---

## RÈGLES DE GESTION

### RG-001 : Authentification Google obligatoire
**Priorité :** Critique

Aucune donnée accessible sans connexion Google. L'écran de login est affiché systématiquement si l'utilisateur n'est pas authentifié.

### RG-002 : Unicité des noms d'exercices
**Priorité :** Haute

Chaque exercice possède un nom unique dans la base de données. Aucun doublon n'est possible.

### RG-003 : Validation des données de série
**Priorité :** Haute

**Validation :**
- Répétitions : Entier strictement positif (> 0)
- Poids : Décimal positif ou nul (≥ 0), où 0 kg représente le poids corporel

**Implémentation :** Validation côté client ET côté serveur (Firestore Security Rules)

### RG-004 : Persistance de la séance en cours
**Priorité :** Haute

La séance reste active même si :
- L'application est mise en arrière-plan
- Le téléphone est éteint/verrouillé
- L'utilisateur change d'application

**Mécanismes :**
- Sauvegarde automatique continue (mode brouillon local + Firestore)
- Brouillon conservé pendant 24h maximum
- Notification persistante : "Séance en cours depuis X min" (V2)

Finalisation uniquement via bouton "Terminer la séance".

### RG-005 : Affichage de l'historique exercice
**Priorité :** Moyenne

**Version V1 :** Format texte simple (non graphique)

Lors de la sélection d'un exercice :
- Affichage automatique de la DERNIÈRE séance où l'exercice a été effectué
- Format : Date + liste des séries (reps × poids)

**Exemple :**
```
Dernière séance (12/02/2026):
• Série 1: 12 reps × 80kg
• Série 2: 10 reps × 80kg
• Série 3: 8 reps × 82.5kg
```

**Version V2 :** Graphiques de progression (poids vs répétitions)

### RG-006 : Sauvegarde finale de la séance
**Priorité :** Critique

La séance n'est finalisée et définitivement sauvegardée que lors du clic sur "Terminer la séance". Avant cela, elle reste en mode brouillon.

---

## PROCESSUS MÉTIER

### P1 : Première connexion
**Criticité :** Haute

**Étapes :**
1. L'utilisateur lance l'application
2. L'écran de connexion Google est affiché
3. L'utilisateur s'authentifie via son compte Google
4. En cas de succès, redirection vers l'écran d'accueil

**Règles appliquées :** RG-001

### P2 : Enregistrer une séance
**Criticité :** CRITIQUE (processus principal)

**Étapes :**

**Étape 1 :** L'utilisateur clique sur "Nouvelle séance"
- Résultat : Écran de saisie de séance activé

**Étape 2 :** Sélection d'un exercice
- Navigation par Groupe Musculaire (pectoraux, biceps, etc.)
- OU navigation par Type d'Exercice (poids libres, machine, etc.)
- OU recherche par nom d'exercice
- Résultat : Exercice sélectionné

**Étape 3 :** Affichage automatique de l'historique
- Dernière séance où cet exercice a été effectué (texte simple : date + séries)
- Si première utilisation : "Pas de séance pour l'instant"

**Étape 4 :** Ajout des séries
- Clic sur "Ajouter une série"
- Saisie : nombre de répétitions (entier > 0)
- Saisie : poids en kg (décimal ≥ 0)
- Répéter pour chaque série de l'exercice

**Étape 5 :** Répétition pour autres exercices
- Retour à l'étape 2 pour ajouter d'autres exercices

**Étape 6 :** Finalisation de la séance
- Clic sur "Terminer la séance"
- Résultat : Sauvegarde définitive dans Firestore

**Règles appliquées :** RG-002, RG-003, RG-004, RG-005, RG-006

**Edge cases :** EC-001, EC-002, EC-003, EC-004

### P3 : Consulter l'historique
**Criticité :** Moyenne

**Étapes :**
1. L'utilisateur accède à l'historique (menu/onglet)
2. Liste des séances affichée (triée par date décroissante)
3. Sélection d'une séance
4. Détail affiché : exercices effectués + séries (reps + poids) pour chaque

**Version V2 :** Calendrier visuel, graphiques de progression

---

## CAS LIMITES (EDGE CASES)

### EC-001 : Première utilisation d'un exercice
**Scenario :** L'utilisateur sélectionne un exercice jamais effectué auparavant

**Comportement :** Affichage du message "Pas de séance pour l'instant"

**Priorité :** Moyenne

### EC-002 : Séance jamais terminée (brouillon abandonné)
**Scenario :** L'utilisateur démarre une séance puis ferme l'application sans cliquer sur "Terminer"

**Comportement :**
- Conservation du brouillon pendant 24h
- Au-delà de 24h : Suppression automatique OU dialogue "Reprendre séance du XX/XX ?"
- Option : Supprimer manuellement le brouillon

**Priorité :** Moyenne

### EC-003 : Perte de connexion internet
**Scenario :** L'utilisateur perd la connexion pendant une séance ou consultation

**Comportement :**
- Mode offline natif de Firestore activé
- Données sauvegardées localement dans le cache
- Synchronisation automatique au retour de la connexion
- Indicateur visuel "Mode hors ligne" (optionnel)

**Complexité :** Faible (intégré à Firebase)

**Priorité :** Haute

### EC-004 : Suppression de données
**Scenario :** L'utilisateur veut supprimer une séance, un exercice ou une série

**Comportement :**

**Niveaux de suppression :**
- **Suppression d'une SÉRIE :** Confirmation "Supprimer cette série ?"
- **Suppression d'un EXERCICE :** Confirmation "Supprimer cet exercice et toutes ses séries ?"
- **Suppression d'une SÉANCE :** Confirmation "Supprimer cette séance définitivement ?"

**Version V1 :** Suppression définitive (pas d'undo)

**Version V2 :** Corbeille avec récupération possible

**Priorité :** Moyenne

---

## CRITÈRES DE SUCCÈS V1

### CS-001 : Efficacité de saisie
**Cible :** Saisir une séance complète (5 exercices) en moins de 2 minutes

**Mesure :** Chronomètre lors des tests utilisateur

**Priorité :** Critique

### CS-002 : Performance de récupération
**Cible :** Retrouver les derniers poids utilisés pour un exercice en moins de 1 seconde

**Mesure :** Temps de chargement de l'écran exercice

**Priorité :** Critique

### CS-003 : Qualité UX
**Cible :** Interface fluide, belle et intuitive - utilisation sans frustration

**Mesure :** Test utilisateur qualitatif + fluidité 60fps

**Priorité :** Haute

---

## ROADMAP

### Version 1.0 (MVP) - 3 mois
**Fonctionnalités principales :**
- Connexion Google Authentication
- Navigation exercices (par Groupe Musculaire + Type)
- Saisie séries (répétitions + poids)
- Historique texte simple (dernière séance par exercice)
- Sauvegarde séance (bouton "Terminer")
- Mode sombre + mode clair
- Design System Material 3 moderne avec Raleway
- Couleur primaire #1E88E5 (bleu Material Design)
- Page transitions fluides (5 types)
- CircularProgressButton avec arc de progression
- ProfileDrawer avec ThemeSwitcher intégré
- Dark/Light mode avec persistance
- Liste exercices prédéfinis (~50 exercices populaires)
- Mode offline (Firestore natif)

### Version 1.5 (Nice to Have)
**Si temps restant :**
- Notification persistante "Séance en cours"
- Graphiques basiques avec fl_chart

### Version 2.0+ (Future)
**Fonctionnalités avancées :**
- Chronomètre global de session
- Chronomètre par exercice
- Graphiques de progression avancés
- Statistiques complètes
- Calendrier visuel des séances
- Images exercices (générées par IA)
- Ajout exercices personnalisés par utilisateur
- Import/Export données
- Corbeille avec récupération
- Intégrations (montres connectées, balance)

---

## INSTALLATION

### Prérequis
- Flutter SDK (version stable recommandée)
- Dart SDK (inclus avec Flutter)
- Android Studio / Xcode (selon plateforme cible)
- Compte Firebase configuré

### Configuration Firebase

1. Créer un projet Firebase sur [console.firebase.google.com](https://console.firebase.google.com)
2. Activer Firebase Authentication (provider Google)
3. Activer Cloud Firestore
4. Télécharger les fichiers de configuration :
   - `google-services.json` pour Android → placer dans `android/app/`
   - `GoogleService-Info.plist` pour iOS → placer dans `ios/Runner/`

### Installation des dépendances

```bash
flutter pub get
```

### Lancer l'application

```bash
# Mode développement
flutter run

# Mode release
flutter run --release
```

---

## TESTS & QUALITÉ

### Tests Unitaires

**Status:** ✅ **39/39 tests passent** (100% des tests modèles)

```bash
# Exécuter tous les tests
flutter test

# Exécuter uniquement les tests modèles
flutter test test/models/
```

**Couverture:**
- ✅ Modèles métier (WorkoutSet, Workout, Exercise, WorkoutExercise)
- ✅ Validation règles de gestion (RG-003: reps > 0, poids ≥ 0)
- ⚠️ Tests widgets nécessitent Firebase mocks (prévu V2)

### Qualité du Code

**Status:** ✅ **255 issues** (toutes de niveau info, aucune erreur)

```bash
# Analyser le code
flutter analyze

# Appliquer corrections automatiques
dart fix --apply

# Formater le code
dart format .
```

**Métriques:**
- ✅ 54 fichiers formatés selon conventions Dart
- ✅ Architecture propre (Models/Services/Providers/UI)
- ✅ Performance optimisée (ListView.builder, const, dispose)
- ✅ Aucun memory leak détecté

**Audit complet:** Voir [AUDIT-PERFORMANCE-MVP-V1.md](AUDIT-PERFORMANCE-MVP-V1.md)

---

## DONNÉES D'INITIALISATION

### Exercices prédéfinis

L'application intègre un **catalogue de 94 exercices professionnels** via l'API Workout API, avec :

**Données** :
- Noms standardisés en français
- Classification par muscles primaires/secondaires
- Catégorisation par équipement (poids libres, machines, poids corporel)
- Descriptions techniques complètes
- Stockage dans la collection Firestore `exercises_library`

**Images (système hybride à trois niveaux)** :
- ✅ **20 images SVG préchargées** dans l'APK (top exercices, affichage instantané)
- ✅ **74 images téléchargeables** à la demande (téléchargement au premier affichage)
- ✅ **Stockage permanent** dans le répertoire privé de l'application
- ✅ **Optimisation quota API** : 21/100 requêtes utilisées, 79 disponibles
- ✅ **Fallback émoji** pour les exercices sans image

📘 **Documentation complète** : [docs/IMAGE_SYSTEM.md](docs/IMAGE_SYSTEM.md)  
📘 **Feature README** : [lib/features/exercise_library/README.md](lib/features/exercise_library/README.md)

---

## LIENS UTILES

### 📊 Status et Progression

- **[STATUS.md](STATUS.md)** - Dashboard visuel du projet (épics, tests, qualité)
- **[CHANGELOG.md](CHANGELOG.md)** - Historique des versions
- **[DOCUMENTATION.md](DOCUMENTATION.md)** - Index complet de la documentation

### 📝 Documentation Technique

- **[docs/IMAGE_SYSTEM.md](docs/IMAGE_SYSTEM.md)** - Système d'images hybride (assets/local/remote)
- **[docs/](docs/)** - Documentation complète (Firebase, Architecture, Design)
- **[AUDIT-PERFORMANCE-MVP-V1.md](AUDIT-PERFORMANCE-MVP-V1.md)** - Rapport d'audit détaillé
- **[lib/features/exercise_library/README.md](lib/features/exercise_library/README.md)** - Catalogue d'exercices Workout API

### 🎯 Gestion Projet

- **[Backlog MVP V1](_byan-output/bmb-creations/Backlog-MVP-V1.md)** - Épics et user stories
- **[Backlog V2 Roadmap](_byan-output/bmb-creations/Backlog-V2-Roadmap.md)** - Fonctionnalités futures

---

## CONTRIBUTEURS

**Développeur :** Jules (solo developer)

**Méthodologie :** Agile

**Timeline :** 3 mois (2-3h/semaine, ~36h total)

---

## LICENCE

A définir

---

## CONTACT

Pour toute question ou suggestion concernant le projet Apollon.

---

**Dernière mise à jour :** 18 février 2026  
**Version:** MVP V1.1 - Images hybrides ✅
