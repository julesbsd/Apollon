import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:apollon/core/providers/auth_provider.dart' as app_providers;
import 'package:apollon/core/providers/workout_provider.dart';
import 'package:apollon/screens/exercise_library/exercise_library_selection_screen.dart';
import 'package:apollon/core/services/exercise_library_repository.dart';
import 'package:apollon/core/providers/exercise_library_provider.dart';
import '../helpers/test_helpers.dart';

class MockExerciseLibraryRepository extends Mock implements ExerciseLibraryRepository {}

Widget buildTestWidget() {
  final mockRepo = MockExerciseLibraryRepository();
  when(() => mockRepo.getAll()).thenAnswer((_) async => []);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<WorkoutProvider>(
        create: (_) => createTestWorkoutProvider(),
      ),
      ChangeNotifierProvider<app_providers.AuthProvider>(
        create: (_) => TestAuthProvider(MockAuthService()),
      ),
      Provider<ExerciseLibraryRepository>.value(value: mockRepo),
      ChangeNotifierProvider<ExerciseLibraryProvider>(
        create: (_) => ExerciseLibraryProvider(mockRepo),
      ),
    ],
    child: const MaterialApp(home: ExerciseLibrarySelectionScreen()),
  );
}

void main() {
  group('ExerciseLibrarySelectionScreen Widget Tests', () {
    testWidgets('should have tabs for muscle groups', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(Tab), findsWidgets);
    });

    testWidgets('should have search bar', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should have Scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('search bar should be editable', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Bench');
      await tester.pump();

      expect(find.text('Bench'), findsOneWidget);
    });
  });
}
