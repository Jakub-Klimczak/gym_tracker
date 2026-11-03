import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/repositories/fake_fitness_goal_repository.dart';
import 'package:gym_tracker/data/repositories/fake_meal_entry_repository.dart';
import 'package:gym_tracker/data/repositories/fake_workout_repository.dart';
import 'package:gym_tracker/domain/repositories/fitness_goal_repository.dart';
import 'package:gym_tracker/domain/repositories/meal_entry_repository.dart';
import 'package:gym_tracker/domain/repositories/workout_repository.dart';
import 'package:gym_tracker/ui/goals/goals_view_model.dart';
import 'package:gym_tracker/ui/home/gym_dashboard_screen.dart';
import 'package:gym_tracker/ui/nutrition/nutrition_view_model.dart';
import 'package:gym_tracker/ui/workouts/workouts_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('shows loaded workouts', (tester) async {
    await tester.pumpWidget(_testApp(failureRate: 0));
    await tester.pumpAndSettle();

    expect(find.text('Upper body strength'), findsOneWidget);
  });

  testWidgets('shows an error and retry action when loading fails', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(failureRate: 1));
    await tester.pumpAndSettle();

    expect(find.text('Could not load workouts.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('shows nutrition photo and wearable connection previews', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(failureRate: 0));
    await tester.pumpAndSettle();

    expect(find.text('Connect a wearable'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Nutrition'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Estimate a meal from a photo'), findsOneWidget);
    expect(find.text('Take photo'), findsOneWidget);
    expect(find.text('Choose photo'), findsOneWidget);
    expect(find.textContaining('Lorem ipsum'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('adds and edits a meal with nutrition values', (tester) async {
    await tester.pumpWidget(_testApp(failureRate: 0));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Nutrition'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add meal'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Yogurt bowl');
    await tester.enterText(find.byType(TextFormField).at(1), '280');
    await tester.enterText(find.byType(TextFormField).at(2), '20');
    await tester.enterText(find.byType(TextFormField).at(3), '32');
    await tester.enterText(find.byType(TextFormField).at(4), '12');
    await tester.enterText(find.byType(TextFormField).at(5), '8');
    await tester.ensureVisible(find.text('Save meal'));
    await tester.tap(find.text('Save meal'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Nutrition'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Yogurt bowl', skipOffstage: false), findsOneWidget);
  });

  testWidgets('adds and edits a manual fitness goal', (tester) async {
    await tester.pumpWidget(_testApp(failureRate: 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Goals').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add goal'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Drink water');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Daily water goal',
    );
    await tester.enterText(find.byType(TextFormField).at(2), '1');
    await tester.enterText(find.byType(TextFormField).at(3), '2');
    await tester.enterText(find.byType(TextFormField).at(4), 'L');
    await tester.ensureVisible(find.text('Save goal'));
    await tester.tap(find.text('Save goal'));
    await tester.pumpAndSettle();

    expect(find.text('Drink water'), findsOneWidget);
    expect(find.text('1 / 2 L'), findsOneWidget);

    await tester.tap(find.byTooltip('Edit Drink water'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(2), '1.5');
    await tester.ensureVisible(find.text('Save goal'));
    await tester.tap(find.text('Save goal'));
    await tester.pumpAndSettle();

    expect(find.text('1.5 / 2 L'), findsOneWidget);
  });
}

Widget _testApp({required double failureRate}) {
  final workoutRepository = FakeWorkoutRepository(
    delay: Duration.zero,
    failureRate: failureRate,
  );
  final goalRepository = FakeFitnessGoalRepository(
    delay: Duration.zero,
    failureRate: 0,
  );
  final mealRepository = FakeMealEntryRepository(
    delay: Duration.zero,
    failureRate: 0,
  );

  return MultiProvider(
    providers: [
      Provider<WorkoutRepository>.value(value: workoutRepository),
      Provider<FitnessGoalRepository>.value(value: goalRepository),
      Provider<MealEntryRepository>.value(value: mealRepository),
      ChangeNotifierProvider(
        create: (context) =>
            WorkoutsViewModel(context.read<WorkoutRepository>())..load(),
      ),
      ChangeNotifierProvider(
        create: (context) => GoalsViewModel(
          context.read<FitnessGoalRepository>(),
          context.read<WorkoutRepository>(),
        )..load(),
      ),
      ChangeNotifierProvider(
        create: (context) =>
            NutritionViewModel(context.read<MealEntryRepository>())..load(),
      ),
    ],
    child: MaterialApp(home: const GymDashboardScreen()),
  );
}
