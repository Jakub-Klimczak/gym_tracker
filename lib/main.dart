import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/fake_fitness_goal_repository.dart';
import 'data/repositories/fake_meal_entry_repository.dart';
import 'data/repositories/fake_workout_repository.dart';
import 'ui/goals/goals_view_model.dart';
import 'domain/repositories/fitness_goal_repository.dart';
import 'domain/repositories/meal_entry_repository.dart';
import 'domain/repositories/workout_repository.dart';
import 'ui/home/gym_dashboard_screen.dart';
import 'ui/nutrition/nutrition_view_model.dart';
import 'ui/workouts/workouts_view_model.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<WorkoutRepository>(create: (_) => FakeWorkoutRepository()),
        Provider<FitnessGoalRepository>(
          create: (_) => FakeFitnessGoalRepository(),
        ),
        Provider<MealEntryRepository>(create: (_) => FakeMealEntryRepository()),
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
      child: const GymTrackerApp(),
    ),
  );
}

class GymTrackerApp extends StatelessWidget {
  const GymTrackerApp({super.key});

  static const _seed = Color.fromARGB(255, 111, 255, 121);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const GymDashboardScreen(),
    );
  }
}
