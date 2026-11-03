import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/workout.dart';
import '../core/data_state.dart';
import '../core/widgets/error_view.dart';
import '../core/widgets/feature_chip.dart';
import '../core/widgets/section_heading.dart';
import 'workout_details_screen.dart';
import 'workout_form_screen.dart';
import 'workouts_view_model.dart';

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WorkoutsViewModel>();
    final colors = Theme.of(context).colorScheme;

    return switch (vm.state) {
      DataLoading() => const Center(child: CircularProgressIndicator()),
      DataError(:final message) => ErrorView(
        message: message,
        onRetry: vm.load,
      ),
      DataLoaded<List<Workout>>(:final value) when value.isEmpty => _emptyState(
        context,
      ),
      DataLoaded<List<Workout>>(:final value) => RefreshIndicator(
        onRefresh: vm.load,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final padding = constraints.maxWidth >= 700 ? 32.0 : 16.0;
            return ListView(
              padding: EdgeInsets.fromLTRB(padding, 8, padding, 24),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      const Expanded(
                        child: SectionHeading(
                          title: 'Your activity',
                          subtitle:
                              'Recent workouts and activity from your devices',
                        ),
                      ),
                      IconButton.filledTonal(
                        tooltip: 'Add workout',
                        onPressed: () => Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => const WorkoutFormScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${_weeklyCount(value)} workouts this week',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const Text('Goal: 4'),
                      ],
                    ),
                  ),
                ),
                const _WearableConnectionCard(),
                for (final workout in value) _WorkoutCard(workout: workout),
              ],
            );
          },
        ),
      ),
    };
  }

  Widget _emptyState(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('No workouts yet.'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const WorkoutFormScreen(),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add workout'),
          ),
        ],
      ),
    ),
  );

  int _weeklyCount(List<Workout> workouts) {
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
}

class _WearableConnectionCard extends StatelessWidget {
  const _WearableConnectionCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colors.secondaryContainer,
              child: Icon(Icons.bluetooth, color: colors.onSecondaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Connect a wearable', style: text.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Sync workouts and activity from your watch.',
                    style: text.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Coming soon',
              style: text.labelSmall?.copyWith(color: colors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
            onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => WorkoutDetailsScreen(workoutId: workout.id),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Wrap(
              spacing: 8,
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
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
}
