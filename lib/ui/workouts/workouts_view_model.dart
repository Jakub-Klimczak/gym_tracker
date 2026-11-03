import 'package:flutter/foundation.dart';

import '../../domain/models/workout.dart';
import '../../domain/repositories/workout_repository.dart';
import '../core/data_state.dart';

class WorkoutsViewModel extends ChangeNotifier {
  WorkoutsViewModel(this._repository);

  final WorkoutRepository _repository;
  DataState<List<Workout>> _state = const DataLoading();
  bool _disposed = false;

  DataState<List<Workout>> get state => _state;

  Workout? workoutById(String id) {
    final state = _state;
    if (state is DataLoaded<List<Workout>>) {
      for (final workout in state.value) {
        if (workout.id == id) return workout;
      }
    }
    return null;
  }

  Future<void> load() async {
    _setState(const DataLoading());
    try {
      _setState(DataLoaded(await _repository.fetchWorkouts()));
    } catch (_) {
      _setState(const DataError('Could not load workouts.'));
    }
  }

  Future<bool> addWorkout(Workout workout) async {
    try {
      await _repository.addWorkout(workout);
      final state = _state;
      if (state is DataLoaded<List<Workout>>) {
        _setState(DataLoaded(List.unmodifiable([workout, ...state.value])));
      } else {
        await load();
      }
      return state is DataLoaded<List<Workout>> ||
          this.state is DataLoaded<List<Workout>>;
    } catch (_) {
      return false;
    }
  }

  void _setState(DataState<List<Workout>> state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
