import 'package:flutter/material.dart';
import '../../data/fake_workouts.dart';
import '../core/widgets/feature_chip.dart';
import '../core/widgets/section_heading.dart';
import 'workout_details_screen.dart';

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 700;
        final horizontalPadding = wide ? 32.0 : 16.0;

        return ListView.builder(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 24),
          itemCount: fakeWorkouts.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: SectionHeading(
                  title: 'Your activity',
                  subtitle: 'Recent workouts and activity from your devices',
                ),
              );
            }
            if (index == 1) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.local_fire_department, color: colors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '3 workouts this week',
                          style: text.titleMedium,
                        ),
                      ),
                      Text('Goal: 4', style: text.bodyMedium),
                    ],
                  ),
                ),
              );
            }

            final workout = fakeWorkouts[index - 2];
            return Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: colors.secondaryContainer,
                      child: Icon(
                        Icons.fitness_center,
                        color: colors.onSecondaryContainer,
                      ),
                    ),
                    title: Text(
                      workout.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${_formatDate(workout.date)} · ${workout.durationMinutes} min',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => WorkoutDetailsScreen(workout: workout),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 0,
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
                          FeatureChip(
                            icon: Icons.watch_outlined,
                            label: workout.source!,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
}
