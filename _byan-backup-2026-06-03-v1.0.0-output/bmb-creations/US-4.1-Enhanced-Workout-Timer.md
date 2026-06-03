# US-4.1 Enhanced : HomePage + Chronomètre de Séance

## 📋 Contexte

**EPIC-4 : Enregistrement Séance**  
**User Story** : US-4.1 - HomePage avec démarrage de séance  
**Priorité** : P0 - Critique  
**Estimation originale** : 1h  
**Estimation avec chrono** : 2h  
**Sprint** : Sprint 2

---

## 🎯 Objectif

L'utilisateur doit pouvoir démarrer une nouvelle séance d'entraînement depuis la HomePage. Dès le clic sur "Nouvelle séance", un chronomètre se lance et reste visible en permanence jusqu'à ce qu'il termine la séance.

---

## ✅ Critères d'acceptation

### 1. HomePage - Bouton principal
- ✅ Afficher un bouton principal "Nouvelle séance" (Liquid Glass style)
- ✅ Afficher le nom de l'utilisateur (Welcome message)
- ✅ Clic sur le bouton → Créer un `Workout` en status `draft`
- ✅ Rediriger vers ExerciseSelectionScreen

### 2. Chronomètre persistant ⏱️ **[NOUVEAU]**
- ✅ Démarrer automatiquement dès le clic sur "Nouvelle séance"
- ✅ Afficher le temps écoulé en temps réel (format HH:MM:SS)
- ✅ Visible en permanence sur TOUS les écrans pendant la séance :
  - ExerciseSelectionScreen
  - WorkoutRecordScreen (enregistrement séries)
  - Tout écran de navigation durant la séance
- ✅ Position : **AppBar persistant** ou **FloatingActionButton custom**
- ✅ Calcul basé sur `workout.createdAt`

### 3. Bouton "Terminer la séance" 🛑 **[NOUVEAU]**
- ✅ Toujours accessible (à côté du chrono)
- ✅ Clic → Popup de confirmation :
  - "Terminer la séance ?"
  - "Durée : XX min | X exercices | XX séries"
  - Boutons : "Annuler" / "Terminer"
- ✅ Si confirmé :
  - Calculer `duration = (now - createdAt).inMinutes`
  - Passer `workout.status = completed`
  - Sauvegarder en Firestore via `WorkoutService`
  - Navigation → HomePage ou HistoryScreen
- ✅ Arrêter le chronomètre

### 4. Gestion d'état
- ✅ Utiliser `WorkoutProvider` pour stocker la séance en cours
- ✅ `currentWorkout: Workout?` (null si aucune séance active)
- ✅ Persistance automatique en arrière-plan (RG-004)

---

## 🏗️ Architecture technique

### **Modèles utilisés**

```dart
// Déjà existant dans lib/core/models/workout.dart
Workout.createDraft(String userId) // Créer séance draft
workout.complete({int? duration})   // Terminer séance
workout.createdAt                   // Timestamp de début
workout.status                      // draft | completed
workout.exercises                   // Liste exercices liés
```

### **Provider à créer/enrichir**

```dart
// lib/core/providers/workout_provider.dart
class WorkoutProvider extends ChangeNotifier {
  Workout? _currentWorkout;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  
  // Getter
  Workout? get currentWorkout => _currentWorkout;
  bool get hasActiveWorkout => _currentWorkout != null;
  String get elapsedTimeFormatted => _formatDuration(_elapsed);
  
  // Actions
  Future<void> startNewWorkout(String userId);
  Future<void> completeWorkout();
  Future<void> cancelWorkout();
  void _startTimer();
  void _stopTimer();
  String _formatDuration(Duration d) {
    // Format: "01:23:45"
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }
}
```

### **Services utilisés**

```dart
// Déjà existant : lib/core/services/workout_service.dart
WorkoutService.createWorkout(Workout workout)
WorkoutService.updateWorkout(String id, Workout workout)
WorkoutService.getActiveWorkout(String userId) // Vérifier si draft existe
```

---

## 🎨 Design UI

### **HomePage - Bouton principal**

```dart
LiquidButton(
  text: "🏋️ Nouvelle séance",
  variant: LiquidButtonVariant.primary,
  size: LiquidButtonSize.large,
  onPressed: () => _startNewWorkout(context),
)
```

### **Chronomètre persistant - Option A : AppBar custom**

```dart
AppBar(
  title: Row(
    children: [
      Icon(Icons.timer, color: AppColors.primary),
      SizedBox(width: 8),
      Text(elapsedTime, style: AppTypography.h3), // "01:23:45"
    ],
  ),
  actions: [
    IconButton(
      icon: Icon(Icons.stop_circle, color: Colors.red),
      onPressed: () => _showCompleteDialog(context),
    ),
  ],
)
```

### **Chronomètre persistant - Option B : FloatingActionButton**

```dart
Stack(
  children: [
    Positioned(
      top: 16,
      right: 16,
      child: GlassCard(
        child: Row(
          children: [
            Icon(Icons.timer),
            Text(elapsedTime),
            IconButton(
              icon: Icon(Icons.stop),
              onPressed: _showCompleteDialog,
            ),
          ],
        ),
      ),
    ),
  ],
)
```

### **Dialog de confirmation**

```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text("Terminer la séance ?"),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("⏱️ Durée : ${workout.displayDuration}"),
        Text("💪 ${workout.totalExercises} exercices"),
        Text("🔢 ${workout.totalSets} séries"),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text("Annuler"),
      ),
      LiquidButton(
        text: "Terminer",
        variant: LiquidButtonVariant.primary,
        onPressed: () => _confirmComplete(context),
      ),
    ],
  ),
);
```

---

## 🔄 Flow complet

```
1. HomePage
   ↓ [Clic "Nouvelle séance"]
   
2. WorkoutProvider.startNewWorkout()
   - Créer Workout(status: draft, createdAt: now)
   - Sauvegarder en Firestore
   - Démarrer Timer local (tick chaque seconde)
   - currentWorkout = workout
   ↓
   
3. Navigation → ExerciseSelectionScreen
   - AppBar affiche chrono + bouton Stop
   - Chrono se met à jour chaque seconde
   ↓
   
4. [Utilisateur ajoute exercices et séries]
   - workout.addExercise(...)
   - Auto-save en arrière-plan (RG-004)
   ↓
   
5. [Clic bouton "Terminer"]
   - Afficher Dialog de confirmation
   ↓
   
6. [Confirmation "Terminer"]
   - WorkoutProvider.completeWorkout()
   - Calculer duration = (now - createdAt).inMinutes
   - workout.complete(duration: duration)
   - Sauvegarder en Firestore
   - Arrêter Timer
   - currentWorkout = null
   ↓
   
7. Navigation → HomePage ou HistoryScreen
   - Afficher message "Séance terminée ! 💪"
```

---

## 📦 Fichiers à créer/modifier

### **À créer**
1. `lib/core/providers/workout_provider.dart` - Provider pour séance en cours
2. `lib/core/widgets/workout_timer_app_bar.dart` - AppBar avec chrono (optionnel)
3. `lib/screens/workout/workout_complete_dialog.dart` - Dialog de confirmation

### **À modifier**
1. `lib/screens/home/home_page.dart` - Ajouter bouton "Nouvelle séance"
2. `lib/main.dart` - Enregistrer WorkoutProvider
3. `lib/core/services/workout_service.dart` - Vérifier méthodes CRUD complètes

---

## 🧪 Tests à effectuer

### **Tests fonctionnels**
- [ ] Clic "Nouvelle séance" → Chrono démarre à 00:00:00
- [ ] Chrono visible sur ExerciseSelectionScreen
- [ ] Chrono visible sur WorkoutRecordScreen
- [ ] Chrono continue de tourner pendant navigation
- [ ] Clic "Terminer" → Dialog s'affiche
- [ ] Annuler → Dialog se ferme, séance continue
- [ ] Confirmer → Séance sauvegardée avec duration correcte
- [ ] Vérifier en Firestore : `status = completed`, `duration = XX`
- [ ] HomePage : Bouton "Nouvelle séance" réapparaît

### **Tests de persistance**
- [ ] Hot reload → Chrono continue (État conservé)
- [ ] App minimisée → Chrono continue en arrière-plan
- [ ] Retour app → Durée correcte affichée

### **Tests edge cases**
- [ ] Démarrer 2 séances en même temps → Impossible (vérif)
- [ ] Quitter l'app sans terminer → Séance en draft existe
- [ ] Relancer l'app → Reprendre séance draft existante

---

## 🚀 Prêt pour implémentation

**Dépendances :** ✅ Toutes satisfaites
- Models : `Workout`, `WorkoutExercise`, `WorkoutSet` ✅
- Services : `WorkoutService` ✅
- Design System : Liquid Glass widgets ✅

**Ordre d'implémentation recommandé :**

1. **Phase 1 (30 min)** : WorkoutProvider de base
   - Créer le provider
   - Implémenter `startNewWorkout()` et `completeWorkout()`
   - Timer local avec formatage

2. **Phase 2 (45 min)** : UI HomePage + Chrono
   - Bouton "Nouvelle séance" sur HomePage
   - AppBar custom avec chrono
   - Dialog de confirmation

3. **Phase 3 (30 min)** : Intégration + Tests
   - Connecter WorkoutProvider au reste de l'app
   - Navigation entre écrans avec chrono visible
   - Tests manuels complets

4. **Phase 4 (15 min)** : Polish
   - Animations
   - Feedback utilisateur (toasts, haptics)
   - Gestion erreurs

---

## 📝 Notes importantes

- **RG-004** : Persistance automatique en arrière-plan → Implémenter auto-save toutes les 30s
- **RG-006** : Séance "terminée" = status completed + duration calculée
- Le chrono est **local** (UI) mais la source de vérité est `workout.createdAt` en Firestore
- Si app crash : Reprendre séance draft au redémarrage (vérifier `getActiveWorkout()`)

---

**Prêt pour @flutter-developer-expert ! 🎯**
