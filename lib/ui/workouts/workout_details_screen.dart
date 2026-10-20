import 'package:flutter/material.dart';

import '../../domain/models/workout.dart';
import '../core/widgets/feature_chip.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  const WorkoutDetailsScreen({super.key, required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final date =
        '${workout.date.day.toString().padLeft(2, '0')}.${workout.date.month.toString().padLeft(2, '0')}.${workout.date.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: ListView(
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
      ),
    );
  }
}
