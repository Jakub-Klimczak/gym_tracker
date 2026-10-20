import 'package:flutter/material.dart';
import '../../data/fake_meal_entries.dart';
import '../core/widgets/section_heading.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: fakeMealEntries.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: SectionHeading(
              title: 'Food & calories',
              subtitle: 'Meal estimates from your food photos and manual entries.',
            ),
          );
        }
        if (index == 1) {
          return Card(
            color: colors.primaryContainer,
            child: ListTile(
              leading: Icon(
                Icons.photo_camera_outlined,
                color: colors.onPrimaryContainer,
              ),
              title: Text(
                'Estimate a meal from a photo',
                style: text.titleMedium,
              ),
              subtitle: const Text('AI photo estimates coming soon'),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        }

        final meal = fakeMealEntries[index - 2];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: colors.tertiaryContainer,
              child: Icon(
                Icons.restaurant,
                color: colors.onTertiaryContainer,
              ),
            ),
            title: Text(meal.name, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text(
              '${_formatTime(meal.loggedAt)}'
              '${meal.estimatedByAi ? ' · AI estimate' : ''}',
            ),
            trailing: Text(
              meal.calories == null ? '-- kcal' : '${meal.calories} kcal',
              style: text.labelLarge,
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}'
      ' · ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
