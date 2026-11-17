import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../domain/models/fitness_goal.dart';
import '../core/data_state.dart';
import '../core/widgets/error_view.dart';
import 'goals_view_model.dart';

class FitnessGoalFormScreen extends StatefulWidget {
  const FitnessGoalFormScreen({super.key, this.goalId});

  final String? goalId;

  @override
  State<FitnessGoalFormScreen> createState() => _FitnessGoalFormScreenState();
}

class _FitnessGoalFormScreenState extends State<FitnessGoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _currentController;
  late final TextEditingController _targetController;
  late final TextEditingController _unitController;
  FitnessGoal? _goal;
  bool _initialized = false;
  bool _saving = false;

  bool get _isEditing => widget.goalId != null;
  bool get _isManual =>
      (_goal?.trackingMode ?? GoalTrackingMode.manual) ==
      GoalTrackingMode.manual;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _currentController = TextEditingController();
    _targetController = TextEditingController();
    _unitController = TextEditingController();
    if (!_isEditing) _initializeForm(null);
  }

  void _initializeForm(FitnessGoal? goal) {
    if (_initialized) return;
    _goal = goal;
    _titleController.text = goal?.title ?? '';
    _descriptionController.text = goal?.description ?? '';
    _currentController.text = goal == null
        ? '0'
        : _formatValue(goal.currentValue);
    _targetController.text = goal == null ? '' : _formatValue(goal.targetValue);
    _unitController.text = goal?.unit ?? '';
    _initialized = true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _currentController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  String _formatValue(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();

  String? _validateNumber(String? value, {required bool mustBePositive}) {
    final number = double.tryParse(value?.trim() ?? '');
    if (number == null || number < 0 || (mustBePositive && number == 0)) {
      return mustBePositive
          ? 'Enter a number greater than zero.'
          : 'Enter a non-negative number.';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final previous = _goal;
    final goal = FitnessGoal(
      id: previous?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      currentValue: _isManual
          ? double.parse(_currentController.text.trim())
          : previous!.currentValue,
      targetValue: double.parse(_targetController.text.trim()),
      unit: _unitController.text.trim(),
      deadline: previous?.deadline,
      trackingMode: previous?.trackingMode ?? GoalTrackingMode.manual,
    );

    setState(() => _saving = true);
    final saved = await context.read<GoalsViewModel>().saveGoal(
      goal,
      isEditing: _isEditing,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (saved) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save goal. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GoalsViewModel>();
    final state = vm.state;
    final goal = widget.goalId == null ? null : vm.goalById(widget.goalId!);
    if (!_initialized && (!_isEditing || goal != null)) {
      _initializeForm(goal);
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit goal' : 'Add goal')),
      body: _buildBody(vm, state, goal),
    );
  }

  Widget _buildBody(
    GoalsViewModel vm,
    DataState<List<FitnessGoal>> state,
    FitnessGoal? goal,
  ) {
    if (!_isEditing) return _buildForm();
    if (state is DataLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state case DataError(:final message)) {
      return ErrorView(message: message, onRetry: vm.load);
    }
    if (goal == null) {
      return ErrorView(message: 'Goal not found.', onRetry: vm.load);
    }
    return _buildForm();
  }

  Widget _buildForm() => Form(
    key: _formKey,
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Goal name',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.sentences,
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Enter a goal name.'
              : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.sentences,
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Enter a description.'
              : null,
        ),
        const SizedBox(height: 16),
        if (_isManual) ...[
          _numberField(
            controller: _currentController,
            label: 'Current progress',
            mustBePositive: false,
          ),
          const SizedBox(height: 16),
        ] else ...[
          _TrackingNotice(mode: _goal!.trackingMode),
          const SizedBox(height: 16),
        ],
        _numberField(
          controller: _targetController,
          label: 'Target',
          mustBePositive: true,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _unitController,
          decoration: const InputDecoration(
            labelText: 'Unit (e.g. workouts, km, kg, L)',
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter a unit.' : null,
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
          label: Text(_saving ? 'Saving' : 'Save goal'),
        ),
      ],
    ),
  );

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required bool mustBePositive,
  }) => TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    validator: (value) =>
        _validateNumber(value, mustBePositive: mustBePositive),
  );
}

class _TrackingNotice extends StatelessWidget {
  const _TrackingNotice({required this.mode});

  final GoalTrackingMode mode;

  @override
  Widget build(BuildContext context) {
    final message = switch (mode) {
      GoalTrackingMode.workouts =>
        'Current progress is calculated from workouts logged this week.',
      GoalTrackingMode.wearable => 'Current progress will come from a connected watch. Watch syncing is not connected yet.',
      GoalTrackingMode.manual => '',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              mode == GoalTrackingMode.wearable
                  ? Icons.watch_outlined
                  : Icons.fitness_center_outlined,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
