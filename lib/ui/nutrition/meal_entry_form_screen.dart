import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/meal_entry.dart';
import 'nutrition_view_model.dart';

class MealEntryFormScreen extends StatefulWidget {
  const MealEntryFormScreen({super.key, this.meal});

  final MealEntry? meal;

  @override
  State<MealEntryFormScreen> createState() => _MealEntryFormScreenState();
}

class _MealEntryFormScreenState extends State<MealEntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbohydratesController;
  late final TextEditingController _sugarsController;
  late final TextEditingController _fatController;
  bool _saving = false;

  bool get _isEditing => widget.meal != null;

  @override
  void initState() {
    super.initState();
    final meal = widget.meal;
    _nameController = TextEditingController(text: meal?.name ?? '');
    _caloriesController = TextEditingController(
      text: meal?.calories?.toString() ?? '',
    );
    _proteinController = TextEditingController(
      text: _formatMacro(meal?.proteinGrams),
    );
    _carbohydratesController = TextEditingController(
      text: _formatMacro(meal?.carbohydratesGrams),
    );
    _sugarsController = TextEditingController(
      text: _formatMacro(meal?.sugarsGrams),
    );
    _fatController = TextEditingController(
      text: _formatMacro(meal?.fatGrams),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbohydratesController.dispose();
    _sugarsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  String _formatMacro(double? value) =>
      value == null ? '' : value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1);

  String? _validateNumber(String? value, {required bool integer}) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return null;
    final number = integer ? int.tryParse(raw) : double.tryParse(raw);
    if (number == null || number < 0) return 'Enter a non-negative number.';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final previous = widget.meal;
    final meal = MealEntry(
      id: previous?.id ?? now.microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      loggedAt: previous?.loggedAt ?? now,
      calories: int.tryParse(_caloriesController.text.trim()),
      proteinGrams: double.tryParse(_proteinController.text.trim()),
      carbohydratesGrams: double.tryParse(
        _carbohydratesController.text.trim(),
      ),
      sugarsGrams: double.tryParse(_sugarsController.text.trim()),
      fatGrams: double.tryParse(_fatController.text.trim()),
      imageDescription: previous?.imageDescription,
      estimatedByAi: previous?.estimatedByAi ?? false,
    );

    setState(() => _saving = true);
    final saved = await context.read<NutritionViewModel>().saveMeal(
      meal,
      isEditing: _isEditing,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (saved) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save meal. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_isEditing ? 'Edit meal' : 'Add meal')),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Meal name',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Enter a meal name.'
                : null,
          ),
          const SizedBox(height: 16),
          _numberField(
            controller: _caloriesController,
            label: 'Calories (kcal)',
            integer: true,
          ),
          const SizedBox(height: 16),
          Text('Nutrition per serving', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _numberField(controller: _proteinController, label: 'Protein (g)'),
          const SizedBox(height: 12),
          _numberField(
            controller: _carbohydratesController,
            label: 'Carbohydrates (g)',
          ),
          const SizedBox(height: 12),
          _numberField(controller: _sugarsController, label: 'Sugars (g)'),
          const SizedBox(height: 12),
          _numberField(controller: _fatController, label: 'Fat (g)'),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_saving ? 'Saving' : 'Save meal'),
          ),
        ],
      ),
    ),
  );

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    bool integer = false,
  }) => TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    validator: (value) => _validateNumber(value, integer: integer),
  );
}
