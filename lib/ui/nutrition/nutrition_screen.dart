import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/meal_entry.dart';
import '../core/data_state.dart';
import '../core/widgets/error_view.dart';
import '../core/widgets/section_heading.dart';
import 'meal_entry_form_screen.dart';
import 'nutrition_view_model.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NutritionViewModel>();

    return switch (vm.state) {
      DataLoading() => const Center(child: CircularProgressIndicator()),
      DataError(:final message) => ErrorView(
        message: message,
        onRetry: vm.load,
      ),
      DataLoaded<List<MealEntry>>(:final value) => RefreshIndicator(
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
                      title: 'Food & calories',
                      subtitle:
                          'Meal estimates from your food photos and manual entries.',
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Add meal',
                    onPressed: () => Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const MealEntryFormScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            const _PhotoMealCard(),
            const _AiPreviewCard(),
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 8),
              child: Text(
                'Recent meals',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (value.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Your logged meals will appear here.'),
                ),
              )
            else
              for (final meal in value) _MealCard(meal: meal),
          ],
        ),
      ),
    };
  }
}

class _PhotoMealCard extends StatelessWidget {
  const _PhotoMealCard();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Card(
      color: colors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: colors.onPrimaryContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Estimate a meal from a photo',
                    style: text.titleMedium?.copyWith(
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
                _ComingSoonLabel(
                  backgroundColor: colors.surface,
                  foregroundColor: colors.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Add a meal photo and get a nutrition estimate. '
              'AI analysis is coming soon.',
              style: text.bodyMedium?.copyWith(
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Take photo'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Choose photo'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AiPreviewCard extends StatelessWidget {
  const _AiPreviewCard();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Example analysis', style: text.titleMedium),
                ),
                _ComingSoonLabel(
                  backgroundColor: colors.secondaryContainer,
                  foregroundColor: colors.onSecondaryContainer,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
              'A sample result will appear here after photo analysis.',
              style: text.bodyMedium,
            ),
            const SizedBox(height: 16),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _NutritionPlaceholder(label: '540 kcal'),
                _NutritionPlaceholder(label: 'Protein 32 g'),
                _NutritionPlaceholder(label: 'Carbs 48 g'),
                _NutritionPlaceholder(label: 'Fat 18 g'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ComingSoonLabel extends StatelessWidget {
  const _ComingSoonLabel({
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      'Coming soon',
      style: Theme.of(
        context,
      ).textTheme.labelSmall?.copyWith(color: foregroundColor),
    ),
  );
}

class _NutritionPlaceholder extends StatelessWidget {
  const _NutritionPlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Chip(
    avatar: const Icon(Icons.circle, size: 10),
    label: Text(label),
    visualDensity: VisualDensity.compact,
  );
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal});

  final MealEntry meal;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final macros = [
      if (meal.proteinGrams != null) 'P ${_formatMacro(meal.proteinGrams!)}g',
      if (meal.carbohydratesGrams != null)
        'C ${_formatMacro(meal.carbohydratesGrams!)}g',
      if (meal.sugarsGrams != null) 'Sugar ${_formatMacro(meal.sugarsGrams!)}g',
      if (meal.fatGrams != null) 'F ${_formatMacro(meal.fatGrams!)}g',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: colors.tertiaryContainer,
            child: Icon(Icons.restaurant, color: colors.onTertiaryContainer),
          ),
          title: Text(meal.name, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_formatTime(meal.loggedAt)}'
                '${meal.estimatedByAi ? ' · AI estimate' : ''}'
                ' · ${meal.calories == null ? '-- kcal' : '${meal.calories} kcal'}',
              ),
              if (macros.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(macros.join(' · ')),
                ),
            ],
          ),
          trailing: IconButton(
            constraints: const BoxConstraints.tightFor(width: 40, height: 40),
            padding: EdgeInsets.zero,
            tooltip: 'Edit ${meal.name}',
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => MealEntryFormScreen(meal: meal),
              ),
            ),
            icon: const Icon(Icons.edit_outlined),
          ),
        ),
      ),
    );
  }

  String _formatMacro(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();

  String _formatTime(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}'
      ' · ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
