# 📚 Documentation Apollon

Index complet de la documentation du projet Apollon.

**Version:** 1.2.0 - MVP V1 + V2 partielle + "Marbre & Lumière" ✅  
**Dernière mise à jour:** 6 août 2026  

---

## 🎯 DÉMARRAGE RAPIDE

### Pour Développeurs

1. **[README.md](README.md)** - Vue d'ensemble, glossaire métier, installation
2. **[docs/firebase-setup-guide.md](docs/firebase-setup-guide.md)** - Configuration Firebase (45-60 min)
3. **[docs/firestore-architecture.md](docs/firestore-architecture.md)** - Architecture base de données
4. **[docs/design-system.md](docs/design-system.md)** - Design system et composants UI

### Pour Tests & Qualité

5. **[docs/tests-and-quality.md](docs/tests-and-quality.md)** - Standards tests et qualité code
6. **[AUDIT-PERFORMANCE-MVP-V1.md](AUDIT-PERFORMANCE-MVP-V1.md)** - Rapport audit EPIC-6 complet

### Pour Chef de Projet

7. **[STATUS.md](STATUS.md)** - 📊 Dashboard visuel de l'état du projet (NOUVEAU)
8. **[_byan-output/bmb-creations/Backlog-MVP-V1.md](_byan-output/bmb-creations/Backlog-MVP-V1.md)** - Backlog Agile avec user stories
9. **[_byan-output/bmb-creations/VALIDATION-FINALE-MVP-V1.md](_byan-output/bmb-creations/VALIDATION-FINALE-MVP-V1.md)** - Validation complète MVP
10. **[_byan-output/bmb-creations/ProjectContext-Apollon.yaml](_byan-output/bmb-creations/ProjectContext-Apollon.yaml)** - Contexte projet complet

---

## 📖 DOCUMENTATION PAR CATÉGORIE

### 🏗️ Architecture & Backend

| Document | Description | Durée lecture |
|----------|-------------|---------------|
| [Firestore Architecture](docs/firestore-architecture.md) | Structure collections, requêtes optimisées | 15 min |
| [Firestore Security Rules](docs/firestore-security-rules.md) | Règles de sécurité et validation | 10 min |
| [Firebase Setup Guide](docs/firebase-setup-guide.md) | Setup complet Firebase (étapes détaillées) | 45-60 min |
| [Seed Data Exercices](docs/seed-data-exercises.md) | Liste 50 exercices prédéfinis | 5 min |

### 🎨 Design & UI

| Document | Description | Durée lecture |
|----------|-------------|---------------|
| [Design System](docs/design-system.md) | Composants UI, couleurs, typographie | 20 min |
| [README.md](README.md) | Glossaire métier (6 concepts) | 10 min |

### 🧪 Tests & Qualité

| Document | Description | Durée lecture |
|----------|-------------|---------------|
| [Tests & Qualité](docs/tests-and-quality.md) | Stratégie tests, standards qualité | 15 min |
| [Audit Performance MVP V1](AUDIT-PERFORMANCE-MVP-V1.md) | Rapport audit EPIC-6 détaillé | 20 min |

### 📋 Gestion Projet

| Document | Description | Durée lecture |
|----------|-------------|---------------|
| [STATUS.md](STATUS.md) | 📊 **Dashboard visuel du projet** (NOUVEAU) | **2 min** |
| [Backlog MVP V1](/_byan-output/bmb-creations/Backlog-MVP-V1.md) | Épics, user stories, sprints | 30 min |
| [Validation Finale MVP V1](/_byan-output/bmb-creations/VALIDATION-FINALE-MVP-V1.md) | Métriques finales, validation | 10 min |
| [Project Context](/_byan-output/bmb-creations/ProjectContext-Apollon.yaml) | Contexte complet (RG, processus, edge cases) | 25 min |
| [Backlog V2 Roadmap](/_byan-output/bmb-creations/Backlog-V2-Roadmap.md) | Fonctionnalités avancées V2 | 40 min |

---

## 🚀 COMMANDES UTILES

### Développement

```bash
# Installation dépendances
flutter pub get

# Lancer app (dev)
flutter run

# Lancer app (release)
flutter run --release

# Hot reload
r

# Hot restart
R
```

### Tests

```bash
# Tous les tests
flutter test

# Tests modèles uniquement
flutter test test/models/

# Tests avec couverture
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Qualité Code

```bash
# Analyse statique
flutter analyze

# Corrections automatiques
dart fix --apply

# Formater code
dart format lib/ test/

# Build release
flutter build apk --release
```

### Firebase

```bash
# Déployer Security Rules
firebase deploy --only firestore:rules

# Importer seed data (voir docs/seed-data-exercises.md)
dart run scripts/seed_exercises.dart
```

---

## 📊 ÉTAT DU PROJET

### MVP V1 - ✅ COMPLET

**Statut:** Production-ready  
**Date:** 17 février 2026  
**Effort:** 31.5h / 36h (87.5%)  

#### Métriques Clés

| Métrique | Valeur | Status |
|----------|--------|--------|
| EPICs complétés | 6/6 | ✅ 100% |
| Tests unitaires | 39/39 | ✅ 100% |
| Règles de gestion | 6/6 | ✅ Validées |
| Critères succès | 3/3 | ✅ Atteints |
| Issues code | 255 | ⚠️ Info only |
| Performance | 60fps | ✅ Maintenue |

#### Fonctionnalités Livrées

- ✅ **Authentification Google** (EPIC-1)
- ✅ **Modèles & Services Firebase** (EPIC-2)
- ✅ **Design System Liquid Glass** (EPIC-3)
- ✅ **Enregistrement séance** avec chronomètre (EPIC-4)
- ✅ **Historique séances** avec filtres (EPIC-5)
- ✅ **Tests & Audit qualité** (EPIC-6)

### V2 - 📝 PLANIFIÉ

**Effort estimé:** ~127h  
**Timeline:** 6-9 mois  

**Top 5 Épics prioritaires:**
1. Statistiques & Graphiques (18h) - ROI ⭐⭐⭐⭐⭐
2. Achievements & Gamification (12h)
3. Podomètre Quotidien (14h)
4. Timer Avancé & Repos (8h)
5. Templates Séances (10h)

Voir [Backlog V2 Roadmap](/_byan-output/bmb-creations/Backlog-V2-Roadmap.md) pour détails.

---

## 🎓 CONCEPTS MÉTIER CLÉS

Comprendre les 6 concepts métier fondamentaux :

1. **EXERCICE** - Mouvement lié à équipement (ex: Développé couché barre)
2. **GROUPE MUSCULAIRE** - Zone anatomique ciblée (pectoraux, biceps...)
3. **TYPE EXERCICE** - Nature équipement (poids libres, machine, corporel, cardio)
4. **SÉRIE** - Ensemble répétitions (reps > 0, poids ≥ 0 kg)
5. **SÉANCE** - Session complète salle (date, durée, liste exercices)
6. **UTILISATEUR** - Profil connecté via Google Auth

**Hiérarchie:** UTILISATEUR → SÉANCES → EXERCICES → SÉRIES

Détails complets dans [README.md](README.md#glossaire-métier)

---

## 🔗 LIENS EXTERNES

- **Stack Technique:** Flutter 3.x + Firebase + Provider
- **Design:** Material 3 + "Marbre & Lumière" (v1.2.0) - voir [docs/design-system.md](docs/design-system.md)
- **Plateformes:** Android (prioritaire), iOS (secondaire)
- **Repo GitHub:** (À ajouter)
- **Démo:** (À ajouter)

---

## 📞 CONTACTS

**Chef de Projet:** apollon-project-assistant  
**Développeur Flutter:** flutter-developer-expert  
**Spécialiste Firebase:** firebase-backend-specialist  

**Solo Developer:** Jules

---

## 📝 LICENCE

À définir

---

**Généré par:** apollon-project-assistant  
**Dernière révision:** 6 août 2026
