import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/workout.dart';
import '../core/data_state.dart';
import '../core/widgets/error_view.dart';
import '../core/widgets/feature_chip.dart';
import 'workouts_view_model.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  const WorkoutDetailsScreen({super.key, required this.workoutId});

  final String workoutId;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorkoutsViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Workout details')),
      body: switch (vm.state) {
        DataLoading() => const Center(child: CircularProgressIndicator()),
        DataError(:final message) => ErrorView(
          message: message,
          onRetry: vm.load,
        ),
        DataLoaded() => _details(context, vm.workoutById(workoutId)),
      },
    );
  }

  Widget _details(BuildContext context, Workout? workout) {
    if (workout == null) {
      return const Center(child: Text('Workout not found.'));
    }

    final text = Theme.of(context).textTheme;
    final date =
        '${workout.date.day.toString().padLeft(2, '0')}.${workout.date.month.toString().padLeft(2, '0')}.${workout.date.year}';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(workout.name, style: text.headlineSmall),
        const SizedBox(height: 4),
        Text(date, style: text.bodyLarge),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            FeatureChip(
              icon: Icons.timer_outlined,
              label: '${workout.durationMinutes} min',
            ),
            if (workout.caloriesBurned != null)
              FeatureChip(
                icon: Icons.local_fire_department_outlined,
                label: '${workout.caloriesBurned} kcal',
              ),
            if (workout.source != null)
              FeatureChip(icon: Icons.watch_outlined, label: workout.source!),
          ],
        ),
        const SizedBox(height: 24),
        Text('Exercises and activity', style: text.titleLarge),
        const SizedBox(height: 8),
        for (final exercise in workout.exercises)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.check_circle_outline),
            title: Text(exercise),
          ),
        if (workout.notes != null) ...[
          const SizedBox(height: 16),
          Text('Notes', style: text.titleLarge),
          const SizedBox(height: 8),
          Text(workout.notes!, style: text.bodyLarge),
        ],
      ],
    );
  }
}
