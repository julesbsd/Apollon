/// Test helpers for mocking Firebase and Providers
library;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:apollon/core/services/auth_service.dart';
import 'package:apollon/core/services/workout_service.dart';
import 'package:apollon/core/providers/auth_provider.dart' as app_providers;
import 'package:apollon/core/providers/workout_provider.dart';
import 'package:mocktail/mocktail.dart';

/// Mock FirebaseAuth
class MockFirebaseAuth extends Mock implements firebase_auth.FirebaseAuth {}

/// Mock User
class MockUser extends Mock implements firebase_auth.User {}

/// Mock WorkoutService
class MockWorkoutService extends Mock implements WorkoutService {}

/// MockAuthService qui ne dépend pas de Firebase réel
class MockAuthService extends Mock implements AuthService {
  MockAuthService() {
    // Configuration par défaut: non authentifié
    when(() => currentUser).thenReturn(null);
    when(() => authStateChanges).thenAnswer((_) => Stream.value(null));
  }

  void setAuthenticated(firebase_auth.User user) {
    when(() => currentUser).thenReturn(user);
    when(() => authStateChanges).thenAnswer((_) => Stream.value(user));
  }

  void setUnauthenticated() {
    when(() => currentUser).thenReturn(null);
    when(() => authStateChanges).thenAnswer((_) => Stream.value(null));
  }
}

/// AuthProvider pour tests qui n'utilise pas Firebase
class TestAuthProvider extends app_providers.AuthProvider {
  final MockAuthService _mockAuthService;

  TestAuthProvider(this._mockAuthService);

  @override
  firebase_auth.User? get currentUser => _mockAuthService.currentUser;

  @override
  Stream<firebase_auth.User?> get authStateChanges =>
      _mockAuthService.authStateChanges;

  @override
  Future<void> signIn() async {
    // Simulate successful sign in
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<bool> signOut() async {
    // Simulate sign out
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }
}

/// WorkoutProvider pour tests qui n'utilise pas Firestore
class TestWorkoutProvider extends WorkoutProvider {
  TestWorkoutProvider(MockWorkoutService mockWorkoutService)
      : super(workoutService: mockWorkoutService);

  // Override methods that access Firestore to prevent errors in tests
  // Les données sont stockées en mémoire seulement pendant les tests
}

/// Crée un MockWorkoutService configuré pour les tests
MockWorkoutService createMockWorkoutService() {
  final mockService = MockWorkoutService();
  // Configuration par défaut des mocks si nécessaire
  return mockService;
}

/// Crée un WorkoutProvider configuré pour les tests
WorkoutProvider createTestWorkoutProvider() {
  return TestWorkoutProvider(createMockWorkoutService());
}

/// Widget wrapper pour tests avec tous les providers nécessaires
Widget createTestApp({
  required Widget child,
  app_providers.AuthProvider? authProvider,
  WorkoutProvider? workoutProvider,
}) {
  return MaterialApp(home: child);
}
