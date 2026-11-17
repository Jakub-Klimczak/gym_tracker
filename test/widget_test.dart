import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/repositories/fake_fitness_goal_repository.dart';
import 'package:gym_tracker/data/repositories/fake_meal_entry_repository.dart';
import 'package:gym_tracker/data/repositories/fake_workout_repository.dart';
import 'package:gym_tracker/domain/repositories/fitness_goal_repository.dart';
import 'package:gym_tracker/domain/repositories/meal_entry_repository.dart';
import 'package:gym_tracker/domain/repositories/workout_repository.dart';
import 'package:gym_tracker/ui/goals/goals_view_model.dart';
import 'package:gym_tracker/ui/nutrition/nutrition_view_model.dart';
import 'package:gym_tracker/ui/workouts/workouts_view_model.dart';
import 'package:gym_tracker/router.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('shows dashboard summary and loaded workouts', (tester) async {
    await tester.pumpWidget(_testApp(failureRate: 0));
    await tester.pumpAndSettle();

    expect(find.text('Your fitness at a glance'), findsOneWidget);
    expect(find.text('Workouts this week'), findsOneWidget);

    await _selectDestination(tester, 'Workouts');
    expect(find.text('Upper body strength'), findsOneWidget);
  });

  testWidgets('shows an error and retry action when loading fails', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(failureRate: 1));
    await tester.pumpAndSettle();

    await _selectDestination(tester, 'Workouts');
    expect(find.text('Could not load workouts.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('shows nutrition photo and wearable connection previews', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(failureRate: 0));
    await tester.pumpAndSettle();

    await _selectDestination(tester, 'Workouts');
    expect(find.text('Connect a wearable'), findsOneWidget);

    await _selectDestination(tester, 'Nutrition');
    expect(find.text('Estimate a meal from a photo'), findsOneWidget);
    expect(find.text('Take photo'), findsOneWidget);
    expect(find.text('Choose photo'), findsOneWidget);
    expect(find.textContaining('Lorem ipsum'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('adds and edits a meal with nutrition values', (tester) async {
    await tester.pumpWidget(_testApp(failureRate: 0));
    await tester.pumpAndSettle();
    await _selectDestination(tester, 'Nutrition');

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

    await tester.scrollUntilVisible(
      find.byTooltip('Edit Yogurt bowl'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byTooltip('Edit Yogurt bowl'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Greek yogurt');
    await tester.ensureVisible(find.text('Save meal'));
    await tester.tap(find.text('Save meal'));
    await tester.pumpAndSettle();
    expect(find.text('Greek yogurt'), findsOneWidget);
  });

  testWidgets('adds and edits a manual fitness goal', (tester) async {
    await tester.pumpWidget(_testApp(failureRate: 0));
    await tester.pumpAndSettle();
    await _selectDestination(tester, 'Goals');

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

Future<void> _selectDestination(WidgetTester tester, String label) async {
  final navigation = find.byType(NavigationRail).evaluate().isNotEmpty
      ? find.byType(NavigationRail)
      : find.byType(NavigationBar);
  await tester.tap(find.descendant(of: navigation, matching: find.text(label)));
  await tester.pumpAndSettle();
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
    child: MaterialApp.router(routerConfig: createRouter()),
  );
}
