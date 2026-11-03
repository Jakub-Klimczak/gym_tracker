import 'dart:math';

import '../../domain/models/fitness_goal.dart';
import '../../domain/repositories/fitness_goal_repository.dart';

class FakeFitnessGoalRepository implements FitnessGoalRepository {
  FakeFitnessGoalRepository({
    this._delay = const Duration(milliseconds: 350),
    this._failureRate = 0.15,
    Random? random,
  }) : _random = random ?? Random();

  final Duration _delay;
  final double _failureRate;
  final Random _random;

  final List<FitnessGoal> _goals = [
    FitnessGoal(
      id: 'weekly-workouts',
      title: 'Train consistently',
      description: 'Complete 4 workouts this week',
      currentValue: 3,
      targetValue: 4,
      unit: 'workouts',
      deadline: DateTime.now().add(const Duration(days: 7)),
      trackingMode: GoalTrackingMode.workouts,
    ),
    FitnessGoal(
      id: 'monthly-distance',
      title: 'Move more',
      description: 'Run or walk 30 km this month',
      currentValue: 0,
      targetValue: 30,
      unit: 'km',
      deadline: DateTime.now().add(const Duration(days: 28)),
      trackingMode: GoalTrackingMode.wearable,
    ),
    FitnessGoal(
      id: 'strength',
      title: 'Build strength',
      description: 'Reach a 70 kg bench press',
      currentValue: 62.5,
      targetValue: 70,
      unit: 'kg',
    ),
    FitnessGoal(
      id: 'completed',
      title: 'Stay hydrated',
      description: 'Drink 2 litres of water each day',
      currentValue: 0,
      targetValue: 2,
      unit: 'L',
      trackingMode: GoalTrackingMode.manual,
    ),
  ];

  @override
  Future<List<FitnessGoal>> fetchGoals() async {
    await Future<void>.delayed(_delay);
    if (_random.nextDouble() < _failureRate) {
      throw Exception('Simulated fitness goal repository failure.');
    }
    return List.unmodifiable(_goals);
  }

  @override
  Future<void> addGoal(FitnessGoal goal) async {
    await _waitAndMaybeFail();
    _goals.insert(0, goal);
  }

  @override
  Future<void> updateGoal(FitnessGoal goal) async {
    await _waitAndMaybeFail();
    final index = _goals.indexWhere((entry) => entry.id == goal.id);
    if (index < 0) throw StateError('Fitness goal ${goal.id} was not found.');
    _goals[index] = goal;
  }

  Future<void> _waitAndMaybeFail() async {
    await Future<void>.delayed(_delay);
    if (_random.nextDouble() < _failureRate) {
      throw Exception('Simulated fitness goal repository failure.');
    }
  }
}
