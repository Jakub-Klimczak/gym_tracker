import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/domain/models/fitness_goal.dart';
import 'package:gym_tracker/domain/models/meal_entry.dart';
import 'package:gym_tracker/domain/models/workout.dart';
import 'package:gym_tracker/domain/repositories/fitness_goal_repository.dart';
import 'package:gym_tracker/domain/repositories/meal_entry_repository.dart';
import 'package:gym_tracker/domain/repositories/workout_repository.dart';
import 'package:gym_tracker/ui/core/data_state.dart';
import 'package:gym_tracker/ui/goals/goals_view_model.dart';
import 'package:gym_tracker/ui/nutrition/nutrition_view_model.dart';
import 'package:gym_tracker/ui/workouts/workouts_view_model.dart';

void main() {
  test('Workout keeps its exercises immutable', () {
    final exercises = ['Run'];
    final workout = Workout(
      id: 'one',
      name: 'Test workout',
      date: DateTime.now(),
      durationMinutes: 20,
      exercises: exercises,
    );
    exercises.add('Swim');

    expect(workout.exercises, ['Run']);
    expect(() => workout.exercises.add('Cycle'), throwsUnsupportedError);
  });

  group('WorkoutsViewModel', () {
    test('loads workouts', () async {
      final vm = WorkoutsViewModel(_TestWorkoutRepository());

      await vm.load();

      expect(vm.state, isA<DataLoaded<List<Workout>>>());
      expect((vm.state as DataLoaded<List<Workout>>).value, hasLength(1));
    });

    test('exposes an error when loading fails', () async {
      final vm = WorkoutsViewModel(_TestWorkoutRepository(shouldFail: true));

      await vm.load();

      expect(vm.state, isA<DataError<List<Workout>>>());
    });
  });

  group('GoalsViewModel', () {
    test('adds and updates goals', () async {
      final repository = _TestGoalRepository();
      final vm = GoalsViewModel(repository, _TestWorkoutRepository());
      await vm.load();

      const goal = FitnessGoal(
        id: 'hydration',
        title: 'Stay hydrated',
        description: 'Drink water each day',
        currentValue: 1,
        targetValue: 2,
        unit: 'L',
      );
      expect(await vm.saveGoal(goal, isEditing: false), isTrue);
      expect(vm.state, isA<DataLoaded<List<FitnessGoal>>>());
      expect(
        (vm.state as DataLoaded<List<FitnessGoal>>).value.first.title,
        'Stay hydrated',
      );

      final updated = goal.copyWith(targetValue: 3);
      expect(await vm.saveGoal(updated, isEditing: true), isTrue);
      expect(
        (vm.state as DataLoaded<List<FitnessGoal>>).value.first.targetValue,
        3,
      );
      vm.dispose();
    });

    test('updates the weekly goal after a workout is added', () async {
      final workoutRepository = _TestWorkoutRepository()..workouts = [];
      final vm = GoalsViewModel(_TestGoalRepository(), workoutRepository);
      await vm.load();

      final workout = Workout(
        id: 'today',
        name: 'Today',
        date: DateTime.now(),
        durationMinutes: 30,
        exercises: const ['Run'],
      );
      await workoutRepository.addWorkout(workout);
      await Future<void>.delayed(Duration.zero);

      final state = vm.state as DataLoaded<List<FitnessGoal>>;
      expect(state.value.single.currentValue, 1);
      vm.dispose();
    });

    test('exposes an error when loading fails', () async {
      final vm = GoalsViewModel(
        _TestGoalRepository(shouldFail: true),
        _TestWorkoutRepository(),
      );

      await vm.load();

      expect(vm.state, isA<DataError<List<FitnessGoal>>>());
    });
  });

  group('NutritionViewModel', () {
    test('adds and updates meal macros', () async {
      final vm = NutritionViewModel(_TestMealRepository());
      await vm.load();

      final meal = MealEntry(
        id: 'new-meal',
        name: 'Yogurt bowl',
        loggedAt: DateTime.now(),
        calories: 250,
        proteinGrams: 18,
        carbohydratesGrams: 30,
        sugarsGrams: 12,
        fatGrams: 6,
      );
      expect(await vm.saveMeal(meal, isEditing: false), isTrue);
      expect(
        (vm.state as DataLoaded<List<MealEntry>>).value.first.proteinGrams,
        18,
      );

      final updated = meal.copyWith(calories: 300);
      expect(await vm.saveMeal(updated, isEditing: true), isTrue);
      expect(
        (vm.state as DataLoaded<List<MealEntry>>).value.first.calories,
        300,
      );
      vm.dispose();
    });

    test('loads meal entries', () async {
      final vm = NutritionViewModel(_TestMealRepository());

      await vm.load();

      expect(vm.state, isA<DataLoaded<List<MealEntry>>>());
      expect((vm.state as DataLoaded<List<MealEntry>>).value, hasLength(1));
    });

    test('exposes an error when loading fails', () async {
      final vm = NutritionViewModel(_TestMealRepository(shouldFail: true));

      await vm.load();

      expect(vm.state, isA<DataError<List<MealEntry>>>());
    });
  });
}

class _TestWorkoutRepository extends ChangeNotifier
    implements WorkoutRepository {
  _TestWorkoutRepository({this.shouldFail = false});

  final bool shouldFail;
  List<Workout> workouts = [
    Workout(
      id: 'one',
      name: 'Test workout',
      date: DateTime.now(),
      durationMinutes: 20,
      exercises: const ['Run'],
    ),
  ];

  @override
  Future<List<Workout>> fetchWorkouts() async {
    if (shouldFail) throw Exception('Expected test failure.');
    return List.unmodifiable(workouts);
  }

  @override
  Future<void> addWorkout(Workout workout) async {
    if (shouldFail) throw Exception('Expected test failure.');
    workouts = [workout, ...workouts];
    notifyListeners();
  }
}

class _TestGoalRepository implements FitnessGoalRepository {
  _TestGoalRepository({this.shouldFail = false});

  final bool shouldFail;
  final List<FitnessGoal> goals = [
    const FitnessGoal(
      id: 'weekly-workouts',
      title: 'Train consistently',
      description: 'Complete 4 workouts this week',
      currentValue: 0,
      targetValue: 4,
      unit: 'workouts',
      trackingMode: GoalTrackingMode.workouts,
    ),
  ];

  @override
  Future<List<FitnessGoal>> fetchGoals() async {
    if (shouldFail) throw Exception('Expected test failure.');
    return List.unmodifiable(goals);
  }

  @override
  Future<void> addGoal(FitnessGoal goal) async {
    if (shouldFail) throw Exception('Expected test failure.');
    goals.insert(0, goal);
  }

  @override
  Future<void> updateGoal(FitnessGoal goal) async {
    if (shouldFail) throw Exception('Expected test failure.');
    final index = goals.indexWhere((entry) => entry.id == goal.id);
    goals[index] = goal;
  }
}

class _TestMealRepository implements MealEntryRepository {
  _TestMealRepository({this.shouldFail = false});

  final bool shouldFail;
  final List<MealEntry> meals = [
    MealEntry(
      id: 'meal',
      name: 'Test meal',
      loggedAt: DateTime.now(),
      calories: 300,
    ),
  ];

  @override
  Future<List<MealEntry>> fetchMealEntries() async {
    if (shouldFail) throw Exception('Expected test failure.');
    return List.unmodifiable(meals);
  }

  @override
  Future<void> addMealEntry(MealEntry meal) async {
    if (shouldFail) throw Exception('Expected test failure.');
    meals.insert(0, meal);
  }

  @override
  Future<void> updateMealEntry(MealEntry meal) async {
    if (shouldFail) throw Exception('Expected test failure.');
    final index = meals.indexWhere((entry) => entry.id == meal.id);
    meals[index] = meal;
  }
}
