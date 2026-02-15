import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/workout.dart';
import '../models/workout_exercise.dart';
import '../models/workout_set.dart';
import '../services/workout_service.dart';

/// Provider pour gérer l'état de la séance de workout en cours
/// Implémente US-4.4: State management pour enregistrement séance
/// Enhanced US-4.1: Chronomètre en temps réel
/// 
/// Fonctionnalités:
/// - Gestion de la séance brouillon (draft)
/// - Ajout/suppression d'exercices et de séries
/// - Auto-save toutes les 10 secondes (RG-004)
/// - Chronomètre en temps réel (tick chaque seconde)
/// - Sauvegarde finale de la séance
class WorkoutProvider extends ChangeNotifier {
  final WorkoutService _workoutService;
  
  // État de la séance en cours
  Workout? _currentWorkout;
  Timer? _autoSaveTimer;
  Timer? _chronoTimer;
  bool _isSaving = false;
  Duration _elapsed = Duration.zero;
  
  WorkoutProvider({required WorkoutService workoutService})
      : _workoutService = workoutService;

  // Getters
  Workout? get currentWorkout => _currentWorkout;
  bool get hasActiveWorkout => _currentWorkout != null;
  bool get isSaving => _isSaving;
  Duration get elapsedTime => _elapsed;
  
  /// Temps écoulé formaté (HH:MM:SS)
  String get elapsedTimeFormatted {
    final hours = _elapsed.inHours;
    final minutes = _elapsed.inMinutes.remainder(60);
    final seconds = _elapsed.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  /// Démarre une nouvelle séance
  /// Crée un Workout avec status 'draft'
  /// Enhanced US-4.1: Démarre aussi le chronomètre
  void startNewWorkout(String userId) {
    _currentWorkout = Workout(
      id: '', // Sera généré par Firestore
      userId: userId,
      date: DateTime.now(),
      status: WorkoutStatus.draft,
      exercises: [],
      duration: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Réinitialiser le chronomètre
    _elapsed = Duration.zero;
    
    // Démarrer l'auto-save toutes les 10 secondes
    _startAutoSave();
    
    // Démarrer le chronomètre (tick chaque seconde)
    _startChrono();
    
    notifyListeners();
  }
  
  /// Ajoute un exercice à la séance
  /// Appelé depuis ExerciseSelectionScreen
  void addExercise(String exerciseId, String exerciseName) {
    if (_currentWorkout == null) return;
    
    // Vérifier si l'exercice n'est pas déjà dans la séance
    final exerciseExists = _currentWorkout!.exercises.any(
      (ex) => ex.exerciseId == exerciseId,
    );
    
    if (exerciseExists) {
      debugPrint('Exercise already in workout: $exerciseName');
      return;
    }
    
    final workoutExercise = WorkoutExercise(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      sets: [],
      createdAt: DateTime.now(),
    );
    
    _currentWorkout = _currentWorkout!.copyWith(
      exercises: [..._currentWorkout!.exercises, workoutExercise],
      updatedAt: DateTime.now(),
    );
    
    notifyListeners();
  }
  
  /// Supprime un exercice de la séance
  void removeExercise(String exerciseId) {
    if (_currentWorkout == null) return;
    
    _currentWorkout = _currentWorkout!.copyWith(
      exercises: _currentWorkout!.exercises
          .where((ex) => ex.exerciseId != exerciseId)
          .toList(),
      updatedAt: DateTime.now(),
    );
    
    notifyListeners();
  }
  
  /// Ajoute une série à un exercice
  /// Validation RG-003: reps > 0, weight >= 0
  /// Si l'exercice n'existe pas encore dans la séance, il est créé automatiquement
  void addSet(String exerciseId, int reps, double weight, {String? exerciseName}) {
    if (_currentWorkout == null) return;
    
    try {
      // Création du set avec validation RG-003
      final newSet = WorkoutSet(reps: reps, weight: weight);
      
      // Trouver l'index de l'exercice
      final exerciseIndex = _currentWorkout!.exercises
          .indexWhere((ex) => ex.exerciseId == exerciseId);
      
      // Si l'exercice n'existe pas, le créer
      if (exerciseIndex == -1) {
        if (exerciseName == null) {
          debugPrint('Cannot add exercise without name');
          return;
        }
        
        final workoutExercise = WorkoutExercise(
          exerciseId: exerciseId,
          exerciseName: exerciseName,
          sets: [newSet],
          createdAt: DateTime.now(),
        );
        
        _currentWorkout = _currentWorkout!.copyWith(
          exercises: [..._currentWorkout!.exercises, workoutExercise],
          updatedAt: DateTime.now(),
        );
        
        notifyListeners();
        return;
      }
      
      // Copier l'exercice avec le nouveau set
      final exercise = _currentWorkout!.exercises[exerciseIndex];
      final updatedExercise = exercise.copyWith(
        sets: [...exercise.sets, newSet],
      );
      
      // Remplacer l'exercice dans la liste
      final updatedExercises = [..._currentWorkout!.exercises];
      updatedExercises[exerciseIndex] = updatedExercise;
      
      _currentWorkout = _currentWorkout!.copyWith(
        exercises: updatedExercises,
        updatedAt: DateTime.now(),
      );
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding set: $e');
      rethrow;
    }
  }
  
  /// Supprime une série d'un exercice
  void removeSet(String exerciseId, int setIndex) {
    if (_currentWorkout == null) return;
    
    final exerciseIndex = _currentWorkout!.exercises
        .indexWhere((ex) => ex.exerciseId == exerciseId);
    
    if (exerciseIndex == -1) return;
    
    final exercise = _currentWorkout!.exercises[exerciseIndex];
    
    if (setIndex < 0 || setIndex >= exercise.sets.length) return;
    
    // Copier les sets en retirant celui à setIndex
    final updatedSets = [...exercise.sets];
    updatedSets.removeAt(setIndex);
    
    final updatedExercise = exercise.copyWith(sets: updatedSets);
    
    // Remplacer l'exercice dans la liste
    final updatedExercises = [..._currentWorkout!.exercises];
    updatedExercises[exerciseIndex] = updatedExercise;
    
    _currentWorkout = _currentWorkout!.copyWith(
      exercises: updatedExercises,
      updatedAt: DateTime.now(),
    );
    
    notifyListeners();
  }
  
  /// Sauvegarde automatique de la séance draft
  /// Appelé toutes les 10 secondes (RG-004)
  Future<void> _autoSaveDraft() async {
    if (_currentWorkout == null || _isSaving) return;
    
    try {
      _isSaving = true;
      
      // Sauvegarder comme draft
      if (_currentWorkout!.id == null || _currentWorkout!.id!.isEmpty) {
        // Première sauvegarde: créer le workout
        final workoutId = await _workoutService.createWorkout(
          _currentWorkout!.userId,
          _currentWorkout!,
        );
        _currentWorkout = _currentWorkout!.copyWith(id: workoutId);
      } else {
        // Mettre à jour le workout
        await _workoutService.updateWorkout(
          _currentWorkout!.userId,
          _currentWorkout!,
        );
      }
      
      debugPrint('Auto-save draft successful');
    } catch (e) {
      debugPrint('Auto-save draft failed: $e');
    } finally {
      _isSaving = false;
    }
  }
  
  /// Termine la séance et la sauvegarde avec status 'completed'
  /// Calcule la durée totale
  Future<void> completeWorkout() async {
    if (_currentWorkout == null) return;
    
    // Filtrer les exercices pour ne garder que ceux avec au moins une série
    final exercisesWithSets = _currentWorkout!.exercises
        .where((ex) => ex.sets.isNotEmpty)
        .toList();
    
    // Validation: ne pas sauvegarder si aucun exercice avec des séries
    if (exercisesWithSets.isEmpty) {
      debugPrint('Cannot complete workout: no exercises with sets');
      throw Exception('Ajoutez au moins un exercice avec des séries avant de terminer');
    }
    
    try {
      _isSaving = true;
      
      // Calculer la durée (en minutes)
      final duration = DateTime.now()
          .difference(_currentWorkout!.createdAt)
          .inMinutes;
      
      // Mettre à jour le status, la durée et les exercices filtrés
      _currentWorkout = _currentWorkout!.copyWith(
        status: WorkoutStatus.completed,
        duration: duration,
        exercises: exercisesWithSets,
        updatedAt: DateTime.now(),
      );
      
      // Sauvegarder
      if (_currentWorkout!.id == null || _currentWorkout!.id!.isEmpty) {
        final workoutId = await _workoutService.createWorkout(
          _currentWorkout!.userId,
          _currentWorkout!,
        );
        _currentWorkout = _currentWorkout!.copyWith(id: workoutId);
      } else {
        await _workoutService.updateWorkout(
          _currentWorkout!.userId,
          _currentWorkout!,
        );
      }
      
      // Arrêter l'auto-save et le chronomètre, puis nettoyer
      _stopAutoSave();
      _stopChrono();
      _currentWorkout = null;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error completing workout: $e');
      _isSaving = false;
      rethrow;
    }
  }
  
  /// Annule la séance en cours
  /// Ne sauvegarde pas comme completed
  void cancelWorkout() {
    _stopAutoSave();
    _stopChrono();
    _currentWorkout = null;
    notifyListeners();
  }
  
  /// Démarre le timer d'auto-save (toutes les 10 secondes)
  void _startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _autoSaveDraft(),
    );
  }
  
  /// Arrête le timer d'auto-save
  void _stopAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }
  
  /// Démarre le chronomètre (tick chaque seconde)
  /// Enhanced US-4.1: Affichage temps réel
  void _startChrono() {
    _chronoTimer?.cancel();
    _chronoTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (_currentWorkout != null) {
          _elapsed = DateTime.now().difference(_currentWorkout!.createdAt);
          notifyListeners();
        }
      },
    );
  }
  
  /// Arrête le chronomètre
  void _stopChrono() {
    _chronoTimer?.cancel();
    _chronoTimer = null;
  }
  
  /// Récupère l'exercice actuel par son ID
  WorkoutExercise? getExercise(String exerciseId) {
    if (_currentWorkout == null) return null;
    
    try {
      return _currentWorkout!.exercises.firstWhere(
        (ex) => ex.exerciseId == exerciseId,
      );
    } catch (e) {
      return null;
    }
  }
  
  @override
  void dispose() {
    _stopAutoSave();
    _stopChrono();
    super.dispose();
  }
}
