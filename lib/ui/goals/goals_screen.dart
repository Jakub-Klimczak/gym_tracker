import 'package:flutter/material.dart';

import '../../data/fake_fitness_goals.dart';
import '../core/widgets/section_heading.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: fakeFitnessGoals.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: SectionHeading(
              title: 'Small steps add up',
              subtitle: 'Track your progress towards personal fitness goals.',
            ),
          );
        }

        final goal = fakeFitnessGoals[index - 1];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(goal.title, style: text.titleMedium),
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
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatValue(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();
}
