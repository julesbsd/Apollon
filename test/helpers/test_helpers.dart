/// Test helpers for mocking Firebase and Providers
library;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:apollon/core/services/auth_service.dart';
import 'package:apollon/core/services/workout_service.dart';
import 'package:apollon/core/services/statistics_service.dart';
import 'package:apollon/core/providers/auth_provider.dart' as app_providers;
import 'package:apollon/core/providers/workout_provider.dart';
import 'package:mocktail/mocktail.dart';

/// Mock FirebaseAuth
class MockFirebaseAuth extends Mock implements firebase_auth.FirebaseAuth {}

/// Mock User
class MockUser extends Mock implements firebase_auth.User {}

/// Mock WorkoutService
class MockWorkoutService extends Mock implements WorkoutService {}

/// Mock StatisticsService
class MockStatisticsService extends Mock implements StatisticsService {}

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
/// Passe le MockAuthService au constructeur parent via l'injection de dépendance
class TestAuthProvider extends app_providers.AuthProvider {
  TestAuthProvider(MockAuthService mockAuthService)
      : super(authService: mockAuthService);
}

/// WorkoutProvider pour tests qui n'utilise pas Firestore
class TestWorkoutProvider extends WorkoutProvider {
  TestWorkoutProvider(
    MockWorkoutService mockWorkoutService,
    MockStatisticsService mockStatisticsService,
  ) : super(
          workoutService: mockWorkoutService,
          statisticsService: mockStatisticsService,
        );
}

/// Crée un MockWorkoutService configuré pour les tests
MockWorkoutService createMockWorkoutService() {
  final mockService = MockWorkoutService();
  // Configuration par défaut des mocks si nécessaire
  return mockService;
}

/// Crée un WorkoutProvider configuré pour les tests (sans Firebase)
WorkoutProvider createTestWorkoutProvider() {
  return TestWorkoutProvider(
    createMockWorkoutService(),
    MockStatisticsService(),
  );
}

/// Widget wrapper pour tests avec tous les providers nécessaires
Widget createTestApp({
  required Widget child,
  app_providers.AuthProvider? authProvider,
  WorkoutProvider? workoutProvider,
}) {
  return MaterialApp(home: child);
}
