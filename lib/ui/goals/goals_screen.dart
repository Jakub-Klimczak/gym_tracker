import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/fitness_goal.dart';
import '../core/data_state.dart';
import '../core/widgets/error_view.dart';
import '../core/widgets/section_heading.dart';
import 'fitness_goal_form_screen.dart';
import 'goals_view_model.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GoalsViewModel>();

    return switch (vm.state) {
      DataLoading() => const Center(child: CircularProgressIndicator()),
      DataError(:final message) => ErrorView(
        message: message,
        onRetry: vm.load,
      ),
      DataLoaded<List<FitnessGoal>>(:final value) => RefreshIndicator(
        onRefresh: vm.load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  const Expanded(
                    child: SectionHeading(
                      title: 'Small steps add up',
                      subtitle:
                          'Track your progress towards personal fitness goals.',
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Add goal',
                    onPressed: () => Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const FitnessGoalFormScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            if (value.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No goals yet. Add one to get started.'),
                ),
              )
            else
              for (final goal in value) _GoalCard(goal: goal),
          ],
        ),
      ),
    };
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal});

  final FitnessGoal goal;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(goal.title, style: text.titleMedium)),
                IconButton(
                  tooltip: 'Edit ${goal.title}',
                  onPressed: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => FitnessGoalFormScreen(goal: goal),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(goal.description),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: goal.progress),
            const SizedBox(height: 8),
            Text(
              '${_formatValue(goal.currentValue)} / '
              '${_formatValue(goal.targetValue)} ${goal.unit}',
              style: text.labelLarge,
            ),
            const SizedBox(height: 8),
            _trackingLabel(goal.trackingMode),
          ],
        ),
      ),
    );
  }

  Widget _trackingLabel(GoalTrackingMode mode) {
    final (label, icon) = switch (mode) {
      GoalTrackingMode.manual => ('Manual progress', Icons.edit_outlined),
      GoalTrackingMode.workouts => (
        'Tracked via workouts',
        Icons.fitness_center_outlined,
      ),
      GoalTrackingMode.wearable => (
        'Watch connection needed',
        Icons.watch_outlined,
      ),
    };

    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  String _formatValue(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();
}
