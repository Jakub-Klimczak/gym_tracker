import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/fitness_goal.dart';
import '../../domain/models/meal_entry.dart';
import '../../domain/models/workout.dart';
import '../core/data_state.dart';
import '../core/widgets/error_view.dart';
import '../core/widgets/section_heading.dart';
import '../goals/goals_view_model.dart';
import '../nutrition/nutrition_view_model.dart';
import '../workouts/workouts_view_model.dart';

class GymDashboardScreen extends StatelessWidget {
  const GymDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workouts = context.watch<WorkoutsViewModel>();
    final goals = context.watch<GoalsViewModel>();
    final nutrition = context.watch<NutritionViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final spacing = 16.0;
          final cardWidth = constraints.maxWidth >= 1000
              ? (constraints.maxWidth - spacing * 2) / 3
              : constraints.maxWidth >= 600
              ? (constraints.maxWidth - spacing) / 2
              : constraints.maxWidth;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SectionHeading(
                title: 'Your fitness at a glance',
                subtitle: 'A quick overview of your recent activity and goals.',
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _workoutSummary(workouts.state, workouts.load),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _goalSummary(goals.state, goals.load),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _mealSummary(nutrition.state, nutrition.load),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _workoutSummary(
    DataState<List<Workout>> state,
    Future<void> Function() onRetry,
  ) => switch (state) {
    DataLoading() => const _SummaryCard(
      title: 'Workouts this week',
      value: 'Loading',
      description: 'Recent activity',
      icon: Icons.fitness_center,
    ),
    DataError(:final message) => ErrorView(message: message, onRetry: onRetry),
    DataLoaded<List<Workout>>(:final value) => _SummaryCard(
      title: 'Workouts this week',
      value: _weeklyWorkoutCount(value).toString(),
      description: 'Recent activity',
      icon: Icons.fitness_center,
    ),
  };

  Widget _goalSummary(
    DataState<List<FitnessGoal>> state,
    Future<void> Function() onRetry,
  ) => switch (state) {
    DataLoading() => const _SummaryCard(
      title: 'Fitness goals',
      value: 'Loading',
      description: 'Personal targets',
      icon: Icons.flag,
    ),
    DataError(:final message) => ErrorView(message: message, onRetry: onRetry),
    DataLoaded<List<FitnessGoal>>(:final value) => _SummaryCard(
      title: 'Fitness goals',
      value: value.length.toString(),
      description: 'Personal targets',
      icon: Icons.flag,
    ),
  };

  Widget _mealSummary(
    DataState<List<MealEntry>> state,
    Future<void> Function() onRetry,
  ) => switch (state) {
    DataLoading() => const _SummaryCard(
      title: 'Meals today',
      value: 'Loading',
      description: 'Nutrition entries',
      icon: Icons.restaurant,
    ),
    DataError(:final message) => ErrorView(message: message, onRetry: onRetry),
    DataLoaded<List<MealEntry>>(:final value) => _SummaryCard(
      title: 'Meals today',
      value: _mealsTodayCount(value).toString(),
      description: 'Nutrition entries',
      icon: Icons.restaurant,
    ),
  };

  int _weeklyWorkoutCount(List<Workout> workouts) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final nextWeek = weekStart.add(const Duration(days: 7));
    return workouts
        .where(
          (workout) =>
              !workout.date.isBefore(weekStart) &&
              workout.date.isBefore(nextWeek),
        )
        .length;
  }

  int _mealsTodayCount(List<MealEntry> meals) {
    final now = DateTime.now();
    return meals
        .where(
          (meal) =>
              meal.loggedAt.year == now.year &&
              meal.loggedAt.month == now.month &&
              meal.loggedAt.day == now.day,
        )
        .length;
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.description,
    required this.icon,
  });

  final String title;
  final String value;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colors.secondaryContainer,
              child: Icon(icon, color: colors.onSecondaryContainer),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: text.titleMedium),
                  const SizedBox(height: 4),
                  Text(value, style: text.headlineMedium),
                  Text(description, style: text.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
