import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/workout.dart';
import 'workouts_view_model.dart';

class WorkoutFormScreen extends StatefulWidget {
  const WorkoutFormScreen({super.key});

  @override
  State<WorkoutFormScreen> createState() => _WorkoutFormScreenState();
}

class _WorkoutFormScreenState extends State<WorkoutFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  final _exercisesController = TextEditingController();
  final _notesController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _exercisesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<WorkoutsViewModel>();
    final workout = Workout(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      date: DateTime.now(),
      durationMinutes: int.parse(_durationController.text.trim()),
      exercises: List.unmodifiable(
        _exercisesController.text
            .split(RegExp(r'[,;\n]'))
            .map((exercise) => exercise.trim())
            .where((exercise) => exercise.isNotEmpty),
      ),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    setState(() => _saving = true);
    final saved = await vm.addWorkout(workout);
    if (!mounted) return;
    setState(() => _saving = false);

    if (saved) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save workout. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Add workout')),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Workout name',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Enter a workout name.'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _durationController,
            decoration: const InputDecoration(
              labelText: 'Duration in minutes',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              final duration = int.tryParse(value?.trim() ?? '');
              if (duration == null || duration < 1 || duration > 1440) {
                return 'Enter a duration between 1 and 1440 minutes.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _exercisesController,
            decoration: const InputDecoration(
              labelText: 'Exercises or activity',
              hintText: 'Separate items with commas',
              border: OutlineInputBorder(),
            ),
            minLines: 2,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            validator: (value) {
              final exercises = (value ?? '')
                  .split(RegExp(r'[,;\n]'))
                  .where((exercise) => exercise.trim().isNotEmpty);
              return exercises.isEmpty
                  ? 'Enter at least one exercise or activity.'
                  : null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              border: OutlineInputBorder(),
            ),
            minLines: 2,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_saving ? 'Saving' : 'Save workout'),
          ),
        ],
      ),
    ),
  );
}
