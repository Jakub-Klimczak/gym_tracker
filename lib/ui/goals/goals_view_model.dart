import 'package:flutter/foundation.dart';

import '../../domain/models/fitness_goal.dart';
import '../../domain/models/workout.dart';
import '../../domain/repositories/fitness_goal_repository.dart';
import '../../domain/repositories/workout_repository.dart';
import '../core/data_state.dart';

class GoalsViewModel extends ChangeNotifier {
  GoalsViewModel(this._goalRepository, this._workoutRepository) {
    _workoutRepository.addListener(_refreshWorkoutCount);
  }

  final FitnessGoalRepository _goalRepository;
  final WorkoutRepository _workoutRepository;
  DataState<List<FitnessGoal>> _state = const DataLoading();
  List<Workout> _workouts = const [];
  bool _disposed = false;

  DataState<List<FitnessGoal>> get state => _state;

  Future<bool> saveGoal(FitnessGoal goal, {required bool isEditing}) async {
    try {
      if (isEditing) {
        await _goalRepository.updateGoal(goal);
      } else {
        await _goalRepository.addGoal(goal);
      }
      final state = _state;
      if (state is DataLoaded<List<FitnessGoal>>) {
        final goals = isEditing
            ? [
                for (final existing in state.value)
                  if (existing.id == goal.id) goal else existing,
              ]
            : [goal, ...state.value];
        _setState(DataLoaded(_withWorkoutCount(List.unmodifiable(goals))));
      } else {
        await load();
      }
      return this.state is DataLoaded<List<FitnessGoal>>;
    } catch (_) {
      return false;
    }
  }

  Future<void> load() async {
    _setState(const DataLoading());
    try {
      final results = await Future.wait([
        _goalRepository.fetchGoals(),
        _workoutRepository.fetchWorkouts(),
      ]);
      final goals = results[0] as List<FitnessGoal>;
      _workouts = results[1] as List<Workout>;
      _setState(DataLoaded(_withWorkoutCount(goals)));
    } catch (_) {
      _setState(const DataError('Could not load fitness goals.'));
    }
  }

  Future<void> _refreshWorkoutCount() async {
    try {
      _workouts = await _workoutRepository.fetchWorkouts();
      final state = _state;
      if (state is DataLoaded<List<FitnessGoal>>) {
        _setState(DataLoaded(_withWorkoutCount(state.value)));
      }
    } catch (_) {
      // The goal screen keeps its last loaded value if this refresh fails.
    }
  }

  List<FitnessGoal> _withWorkoutCount(List<FitnessGoal> goals) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final nextWeek = weekStart.add(const Duration(days: 7));
    final count = _workouts
        .where(
          (workout) =>
              !workout.date.isBefore(weekStart) &&
              workout.date.isBefore(nextWeek),
        )
        .length;

    return [
      for (final goal in goals)
        if (goal.id == 'weekly-workouts')
          goal.copyWith(currentValue: count.toDouble())
        else
          goal,
    ];
  }

  void _setState(DataState<List<FitnessGoal>> state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _workoutRepository.removeListener(_refreshWorkoutCount);
    super.dispose();
  }
}
