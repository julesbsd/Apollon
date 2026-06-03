# BRIEF: Refactoring Architecture - Apollon V1.0.1

**Agent cible:** Flutter Developer Expert  
**Date:** 18 fevrier 2026  
**Auteur:** apollon-project-assistant  
**Priorite:** HAUTE  
**Effort estime:** 3-4h (buffer disponible: 4.5h)

---

## CONTEXTE METIER

### Situation actuelle

Le projet Apollon (MVP V1 - version 1.0.1) est **fonctionnel et production-ready** avec 39/39 tests passes et 0 erreur/warning. Cependant, l'ajout recent du **nouveau systeme d'images pour les exercices** a introduit du desordre architectural:

**Problematique:**
- Fichiers deprecated non nettoyes (ancien systeme ~50 exercices vs nouveau ~94 exercices)
- Cohabitation de 2 systemes d'exercices (ancien: `Exercise` + nouveau: `ExerciseLibrary`)
- Architecture mixte suite aux modifications pour conserver la page de detail avec nouvelles fonctionnalites
- Widget chrono deplace en bas d'ecran (FloatingWorkoutTimer) mais ancien widget (WorkoutTimerAppBar) conserve

### Glossaire metier rappel

- **EXERCICE**: Mouvement lie a un equipement specifique
- **SEANCE**: Session complete salle avec liste exercices
- **SERIE**: Ensemble repetitions continues

### Regles de gestion impactees

- **RG-002**: Unicite noms exercices (verifier coherence post-refactoring)
- **RG-004**: Persistance seance arriere-plan (ne PAS casser)

### Processus metier critiques

- **P2 (CRITIQUE)**: Enregistrer seance - Selection exercice → Affichage historique → Ajout series → Terminer
  - **Ne pas casser le flow utilisateur actuel**

---

## OBJECTIF DU REFACTORING

### Vision

Nettoyer l'architecture pour **eliminer la dette technique** sans degrader les fonctionnalites existantes, tout en preservant la qualite du MVP V1 (39/39 tests passes, 0 erreur).

### Objectifs specifiques

1. **Supprimer code deprecated** sans impact fonctionnel
2. **Consolider l'architecture** autour du nouveau systeme ExerciseLibrary
3. **Nettoyer les widgets chrono** (supprimer WorkoutTimerAppBar, garder FloatingWorkoutTimer)
4. **Reorganiser structure de fichiers** pour clarte
5. **Preserver 100% des fonctionnalites** (aucune regression)

---

## ETAT DES LIEUX TECHNIQUE

### Fichiers identifies comme deprecated

**Models (deprecated):**
- `lib/core/models/exercise.dart` - Ancien modele (~50 exercices)
  - Annotation: `@Deprecated` presente
  - Utilise par: `ExerciseSelectionScreen` (deprecated), `ExerciseService` (deprecated)

**Services (deprecated):**
- `lib/core/services/exercise_service.dart` - Ancien service Firestore
  - Collection: `exercises` (ancienne) vs `exercises_library` (nouvelle)
  - Annotation: `@Deprecated` presente

**Screens (deprecated):**
- `lib/screens/workout/exercise_selection_screen.dart` - Ancien ecran selection
  - Annotation: `@Deprecated` presente
  - Remplace par: `lib/features/exercise_library/screens/exercise_library_selection_screen.dart`

**Widgets chrono (duplicates):**
- `lib/core/widgets/workout_timer_app_bar.dart` - Ancien chrono en AppBar
  - **A supprimer**: Remplace par FloatingWorkoutTimer en bas d'ecran
- `lib/core/widgets/floating_workout_timer.dart` - **GARDER** (nouveau systeme)

### Architecture actuelle (73 fichiers .dart)

```
lib/
├── core/
│   ├── models/
│   │   ├── exercise.dart                    ❌ DEPRECATED (ancien)
│   │   ├── workout.dart                     ✅ OK
│   │   ├── workout_exercise.dart            ✅ OK
│   │   └── workout_set.dart                 ✅ OK
│   ├── services/
│   │   ├── exercise_service.dart            ❌ DEPRECATED (ancien)
│   │   ├── workout_service.dart             ✅ OK
│   │   └── statistics_service.dart          ✅ OK
│   ├── widgets/
│   │   ├── workout_timer_app_bar.dart       ❌ A SUPPRIMER (remplace par FloatingWorkoutTimer)
│   │   ├── floating_workout_timer.dart      ✅ OK (nouveau systeme)
│   │   └── [17 autres widgets OK]
│   └── providers/                           ✅ OK
├── features/
│   └── exercise_library/                    ✅ OK (nouveau systeme images)
│       ├── models/
│       │   ├── exercise_library.dart        ✅ OK (nouveau, ~94 exercices)
│       │   ├── exercise_image_manifest.dart ✅ OK
│       │   ├── muscle_info.dart             ✅ OK
│       │   ├── type_info.dart               ✅ OK
│       │   └── category_info.dart           ✅ OK
│       ├── data/repositories/
│       │   └── exercise_library_repository.dart ✅ OK
│       ├── providers/
│       │   └── exercise_library_provider.dart   ✅ OK
│       ├── services/
│       │   └── exercise_image_downloader.dart   ✅ OK
│       ├── screens/
│       │   ├── exercise_library_selection_screen.dart ✅ OK
│       │   └── exercise_library_detail_screen.dart    ✅ OK
│       └── widgets/
│           ├── exercise_image_widget.dart   ✅ OK
│           └── exercise_library_tile.dart   ✅ OK
└── screens/
    ├── workout/
    │   ├── exercise_selection_screen.dart   ❌ DEPRECATED (ancien)
    │   └── workout_session_screen.dart      ⚠️ A VERIFIER (refs deprecated?)
    ├── home/
    │   └── home_page.dart                   ⚠️ A VERIFIER (refs WorkoutTimerAppBar?)
    └── [autres screens OK]
```

### Dependances a verifier

**Fichiers potentiellement impactes par la suppression:**
1. `workout_session_screen.dart` - Utilise-t-il l'ancien ExerciseSelectionScreen?
2. `home_page.dart` - Utilise-t-il WorkoutTimerAppBar?
3. `app.dart` - Routes vers ancien ExerciseSelectionScreen?
4. Autres imports directs de `exercise.dart` ou `exercise_service.dart`

---

## PLAN DE REFACTORING

### Phase 1: Audit et verification (30 min)

**Actions:**
1. Lister TOUS les imports de fichiers deprecated:
   ```bash
   grep -r "import.*exercise.dart" lib/
   grep -r "import.*exercise_service.dart" lib/
   grep -r "import.*exercise_selection_screen.dart" lib/
   grep -r "import.*workout_timer_app_bar.dart" lib/
   ```

2. Identifier les usages dans le code actif (non-deprecated):
   - `Exercise` (ancien modele)
   - `ExerciseService` (ancien service)
   - `ExerciseSelectionScreen` (ancien ecran)
   - `WorkoutTimerAppBar` (ancien widget chrono)

3. Verifier les routes dans `app.dart` ou `main.dart`

4. Lister les collections Firestore utilisees:
   - Collection `exercises` (ancienne) → A supprimer si inutilisee
   - Collection `exercises_library` (nouvelle) → A conserver

**Livrable Phase 1:** Rapport d'audit avec liste complete des dependances

### Phase 2: Migration des usages (1h30)

**Actions:**

1. **Remplacer imports dans fichiers actifs:**
   - Remplacer `Exercise` par `ExerciseLibrary`
   - Remplacer `ExerciseService` par `ExerciseLibraryRepository` + `ExerciseLibraryProvider`
   - Remplacer `ExerciseSelectionScreen` par `ExerciseLibrarySelectionScreen`
   - Supprimer imports de `WorkoutTimerAppBar`

2. **Adapter code si necessaire:**
   - Verifier compatibilite champs (ex: `emoji` vs `imageUrl`)
   - Adapter logique si ancien modele utilise dans Workout/WorkoutExercise
   - Verifier que `workout_session_screen.dart` utilise bien le nouveau systeme

3. **Tester apres chaque modification:**
   ```bash
   flutter analyze
   flutter test
   ```

**Livrable Phase 2:** Code migre avec 0 erreur/warning et tests passes

### Phase 3: Suppression fichiers deprecated (30 min)

**Actions:**

1. **Supprimer fichiers deprecated:**
   ```
   lib/core/models/exercise.dart
   lib/core/services/exercise_service.dart
   lib/screens/workout/exercise_selection_screen.dart
   lib/core/widgets/workout_timer_app_bar.dart
   ```

2. **Nettoyer exports dans fichiers barrel:**
   - `lib/core/models/models.dart` → Retirer export `exercise.dart`
   - `lib/core/services/services.dart` → Retirer export `exercise_service.dart`
   - `lib/core/widgets/widgets.dart` → Retirer export `workout_timer_app_bar.dart`

3. **Verifier compilation:**
   ```bash
   flutter clean
   flutter pub get
   flutter analyze
   flutter test
   ```

**Livrable Phase 3:** 69 fichiers .dart (-4) sans erreur

### Phase 4: Reorganisation et documentation (1h)

**Actions:**

1. **Reorganiser structure si necessaire:**
   - Deplacer widgets lies au systeme images dans `features/exercise_library/widgets/` si eparpilles
   - Verifier coherence organisation actuelle

2. **Mettre a jour documentation:**
   - Modifier `DOCUMENTATION.md` pour supprimer references ancien systeme
   - Ajouter note dans `CHANGELOG.md` (version 1.0.2-refactor)
   - Mettre a jour commentaires inline si references obsoletes

3. **Valider architecture finale:**
   - Structure claire et logique
   - Separation concerns respectee
   - Aucun fichier orphelin

**Livrable Phase 4:** Architecture propre et documentee

### Phase 5: Tests et validation finale (30 min)

**Actions:**

1. **Tests exhaustifs:**
   ```bash
   flutter test --coverage
   flutter analyze --no-fatal-warnings
   ```

2. **Tests manuels workflow critique (P2):**
   - Lancer app
   - Demarrer nouvelle seance (FloatingWorkoutTimer apparait bien en bas)
   - Selectionner exercice (nouveau catalogue avec images)
   - Ajouter series
   - Terminer seance
   - Verifier historique

3. **Performance check:**
   - Temps chargement catalogue (~500ms maintenu)
   - FPS stable (60fps)
   - Aucune regression UX

**Livrable Phase 5:** Validation complete - Ready to commit

---

## CONTRAINTES TECHNIQUES

### Obligatoires (CRITIQUE)

- **Zero regression fonctionnelle** - Toutes fonctionnalites MVP V1 preservees
- **Zero cassage tests** - 39/39 tests doivent passer post-refactoring
- **Zero erreur/warning** - Analyse statique clean
- **Performance maintenue** - CS-002 (< 1s historique) et CS-001 (< 2min saisie seance)
- **Processus P2 preserve** - Flow critique ne doit PAS etre altere

### Design System

- FloatingWorkoutTimer (nouveau widget en bas) doit rester intact
- Design Liquid Glass preserve
- Dark/Light mode fonctionnel

### Architecture

- Pattern Repository + Provider maintenu (features/exercise_library)
- Separation Core vs Features respectee
- Pas de nouveaux patterns (rester coherent avec existant)

### Firestore

- Collection `exercises_library` utilisee (pas `exercises`)
- Regles securite inchangees
- Offline persistence fonctionnelle

---

## CRITERES D'ACCEPTATION (Mesurables)

### Fonctionnels

1. **CA-F1**: Tous les tests unitaires passent (39/39) ✅
2. **CA-F2**: Aucune erreur `flutter analyze` ✅
3. **CA-F3**: Aucun warning bloquant ✅
4. **CA-F4**: Workflow P2 (enregistrer seance) fonctionne parfaitement ✅
5. **CA-F5**: FloatingWorkoutTimer affiche correctement en bas d'ecran ✅
6. **CA-F6**: Selection exercice utilise le nouveau catalogue (94 exercices avec images) ✅
7. **CA-F7**: Historique charge en < 1s (CS-002) ✅

### Techniques

8. **CA-T1**: 4 fichiers deprecated supprimes (exercise.dart, exercise_service.dart, exercise_selection_screen.dart, workout_timer_app_bar.dart) ✅
9. **CA-T2**: Aucune reference a l'ancien systeme dans code actif ✅
10. **CA-T3**: Collection Firestore `exercises` non utilisee (seulement `exercises_library`) ✅
11. **CA-T4**: Structure fichiers claire (69 fichiers vs 73) ✅
12. **CA-T5**: Documentation mise a jour (CHANGELOG, DOCUMENTATION.md) ✅

### Qualite

13. **CA-Q1**: Code coverage maintenu (logique metier) ✅
14. **CA-Q2**: Performance 60fps maintenue ✅
15. **CA-Q3**: Temps compilation similaire (<3s cold start) ✅
16. **CA-Q4**: Architecture homogene (pas de mixte ancien/nouveau) ✅

---

## RISQUES ET MITIGATION

### Risques identifies

| Risque | Probabilite | Impact | Mitigation |
|--------|-------------|--------|------------|
| **R1**: Cassage flow P2 (enregistrement seance) | MOYEN | CRITIQUE | Tests manuels exhaustifs phase 5 + rollback git possible |
| **R2**: Regression performance (< 1s historique) | FAIBLE | MOYEN | Profiling avant/apres + benchmarks |
| **R3**: Tests fails apres suppression deprecated | MOYEN | ELEVE | Migration progressive + test apres chaque etape |
| **R4**: Imports circulaires apres reorganisation | FAIBLE | MOYEN | Analyse imports avant suppression |
| **R5**: FloatingWorkoutTimer casse apres nettoyage | FAIBLE | CRITIQUE | Ne PAS toucher ce widget sauf verification imports |

### Strategy rollback

- Commit atomique par phase (5 commits)
- Tags git pour chaque phase validee
- Branch feature: `refactor/architecture-cleanup-v1.0.1`
- Tests automatises avant chaque commit

---

## RESSOURCES

### Documentation projet

- [ProjectContext-Apollon.yaml](_byan-output/bmb-creations/ProjectContext-Apollon.yaml)
- [STATUS.md](STATUS.md) - Etat MVP V1 (87.5% complet)
- [DOCUMENTATION.md](DOCUMENTATION.md) - Index docs techniques
- [docs/design-system.md](docs/design-system.md) - Widgets Liquid Glass

### Code reference

**Nouveau systeme (a conserver):**
- `lib/features/exercise_library/` - Architecture moderne
- `lib/core/widgets/floating_workout_timer.dart` - Widget chrono en bas

**Ancien systeme (a supprimer):**
- `lib/core/models/exercise.dart`
- `lib/core/services/exercise_service.dart`
- `lib/screens/workout/exercise_selection_screen.dart`
- `lib/core/widgets/workout_timer_app_bar.dart`

### Commandes utiles

```bash
# Analyse dependances
grep -r "import.*exercise.dart" lib/ --include="*.dart"
grep -r "import.*exercise_service.dart" lib/ --include="*.dart"
grep -r "ExerciseSelectionScreen" lib/ --include="*.dart"
grep -r "WorkoutTimerAppBar" lib/ --include="*.dart"

# Tests
flutter analyze --no-fatal-warnings
flutter test --coverage
flutter test test/models/ --coverage

# Nettoyage
flutter clean
flutter pub get

# Compilation
flutter build apk --debug  # Verifier que build fonctionne
```

---

## CHECKLIST PRE-DEMARRAGE

Avant de commencer le refactoring, valider:

- [ ] Backup commit actuel (branch `main` clean)
- [ ] Tous tests passent (39/39)
- [ ] Aucune erreur `flutter analyze`
- [ ] Buffer disponible: 4.5h (suffisant pour 3-4h estimes)
- [ ] Environnement dev fonctionnel (Flutter, Firebase)
- [ ] Documentation projet lue et comprise

---

## LIVRABLES ATTENDUS

### Immediats

1. **Code refactore** - Branch `refactor/architecture-cleanup-v1.0.1`
2. **Tests passes** - 39/39 (100%)
3. **Analyse clean** - 0 erreur, 0 warning
4. **Rapport validation** - Checklist CA-F1 a CA-Q4 validee

### Documentation

5. **CHANGELOG.md** - Nouvelle entree version 1.0.2-refactor
6. **DOCUMENTATION.md** - Suppression references ancien systeme
7. **Commentaires code** - Nettoyage references obsoletes

### Post-refactoring

8. **Pull Request** - Description detaillee changements
9. **Tests manuels** - Screenshots validation workflow P2
10. **Recommandations** - Suggestions optimisations futures (optionnel)

---

## NOTES IMPORTANTES

### A NE PAS TOUCHER

- **FloatingWorkoutTimer** - Widget chrono en bas (fonctionnel, ne pas modifier)
- **WorkoutProvider** - Logique metier critique
- **Firestore rules** - Security rules deployees
- **Tests existants** - 39 tests unitaires (sauf si adaptations necessaires)

### Modifications autorises

- Suppression fichiers @Deprecated
- Migration imports vers nouveau systeme
- Nettoyage exports barrel files
- Mise a jour documentation

### Validation finale obligatoire

- Jules doit tester manuellement le flow P2 complet avant merge
- Validation performance (< 1s, < 2min, 60fps)
- Verification visuelle FloatingWorkoutTimer fonctionne

---

## QUESTIONS A JULES (Si necessaire)

1. **Collection Firestore `exercises` (ancienne)** - Peut-on la supprimer de Firebase ou faut-il la conserver pour historique?
2. **WorkoutTimerAppBar** - Confirmer que ce widget n'est plus utilise nulle part?
3. **Tests widget** - Faut-il ajouter tests pour FloatingWorkoutTimer (actuellement 0 tests widget)?
4. **Seed data** - Les 50 exercices originaux sont-ils toujours dans `seed_service.dart`? Faut-il les supprimer?

---

## SIGNATURE

**Brief valide par:** apollon-project-assistant  
**Contexte source:** ProjectContext-Apollon.yaml  
**Version brief:** 1.0.0  
**Date emission:** 18 fevrier 2026

**Action requise:** Flutter Developer Expert - Demarrer refactoring selon plan 5 phases

---

**PRIORITE:** HAUTE  
**IMPACT:** MOYEN (dette technique)  
**URGENCE:** MOYENNE (buffer disponible 4.5h)  
**COMPLEXITE:** MOYENNE (migration + suppression)
