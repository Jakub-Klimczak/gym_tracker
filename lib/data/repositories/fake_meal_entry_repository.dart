import 'dart:math';

import '../../domain/models/meal_entry.dart';
import '../../domain/repositories/meal_entry_repository.dart';

class FakeMealEntryRepository implements MealEntryRepository {
  FakeMealEntryRepository({
    this._delay = const Duration(milliseconds: 350),
    this._failureRate = 0.15,
    Random? random,
  }) : _random = random ?? Random();

  final Duration _delay;
  final double _failureRate;
  final Random _random;

  final List<MealEntry> _entries = [
    MealEntry(
      id: 'lunch-01',
      name: 'Chicken, rice and roasted vegetables',
      loggedAt: DateTime.now().subtract(const Duration(hours: 1)),
      calories: 640,
      imageDescription: 'Grilled chicken with rice and broccoli',
      estimatedByAi: true,
    ),
    MealEntry(
      id: 'breakfast-01',
      name: 'Oatmeal with banana',
      loggedAt: DateTime.now().subtract(const Duration(hours: 6)),
      calories: 390,
      imageDescription: 'A bowl of oatmeal topped with sliced banana',
      estimatedByAi: true,
    ),
    MealEntry(
      id: 'snack-01',
      name: 'Apple',
      loggedAt: DateTime.now().subtract(const Duration(days: 1)),
      calories: 95,
    ),
    MealEntry(
      id: 'dinner-01',
      name: 'Homemade lentil curry with brown rice',
      loggedAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      imageDescription: 'Image estimate not available yet',
    ),
    MealEntry(
      id: 'lunch-02',
      name: 'Salmon salad',
      loggedAt: DateTime.now().subtract(const Duration(days: 2)),
      calories: 520,
      imageDescription: 'Salmon with leafy greens and dressing',
      estimatedByAi: true,
    ),
  ];

  @override
  Future<List<MealEntry>> fetchMealEntries() async {
    await Future<void>.delayed(_delay);
    if (_random.nextDouble() < _failureRate) {
      throw Exception('Simulated meal repository failure.');
    }
    return List.unmodifiable(_entries);
  }

  @override
  Future<void> addMealEntry(MealEntry meal) async {
    await _waitAndMaybeFail();
    _entries.insert(0, meal);
  }

  @override
  Future<void> updateMealEntry(MealEntry meal) async {
    await _waitAndMaybeFail();
    final index = _entries.indexWhere((entry) => entry.id == meal.id);
    if (index < 0) throw StateError('Meal entry ${meal.id} was not found.');
    _entries[index] = meal;
  }

  Future<void> _waitAndMaybeFail() async {
    await Future<void>.delayed(_delay);
    if (_random.nextDouble() < _failureRate) {
      throw Exception('Simulated meal repository failure.');
    }
  }
}
