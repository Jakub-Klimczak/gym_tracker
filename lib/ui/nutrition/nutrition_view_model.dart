import 'package:flutter/foundation.dart';

import '../../domain/models/meal_entry.dart';
import '../../domain/repositories/meal_entry_repository.dart';
import '../core/data_state.dart';

class NutritionViewModel extends ChangeNotifier {
  NutritionViewModel(this._repository);

  final MealEntryRepository _repository;
  DataState<List<MealEntry>> _state = const DataLoading();
  bool _disposed = false;

  DataState<List<MealEntry>> get state => _state;

  Future<bool> saveMeal(MealEntry meal, {required bool isEditing}) async {
    try {
      if (isEditing) {
        await _repository.updateMealEntry(meal);
      } else {
        await _repository.addMealEntry(meal);
      }
      final state = _state;
      if (state is DataLoaded<List<MealEntry>>) {
        final meals = isEditing
            ? [
                for (final existing in state.value)
                  if (existing.id == meal.id) meal else existing,
              ]
            : [meal, ...state.value];
        _setState(DataLoaded(List.unmodifiable(meals)));
      } else {
        await load();
      }
      return this.state is DataLoaded<List<MealEntry>>;
    } catch (_) {
      return false;
    }
  }

  Future<void> load() async {
    _setState(const DataLoading());
    try {
      final entries = await _repository.fetchMealEntries();
      _setState(DataLoaded(entries));
    } catch (_) {
      _setState(const DataError('Could not load meal entries.'));
    }
  }

  void _setState(DataState<List<MealEntry>> state) {
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
