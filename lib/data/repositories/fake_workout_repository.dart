import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../domain/models/workout.dart';
import '../../domain/repositories/workout_repository.dart';

class FakeWorkoutRepository implements WorkoutRepository {
  FakeWorkoutRepository({
    this._delay = const Duration(milliseconds: 350),
    this._failureRate = 0.15,
    Random? random,
  }) : _random = random ?? Random();

  final Duration _delay;
  final double _failureRate;
  final Random _random;
  final List<VoidCallback> _listeners = [];
  List<Workout> _workouts = List.unmodifiable(_seedWorkouts);

  static final _today = DateTime.now();

  static final List<Workout> _seedWorkouts = List.unmodifiable([
    Workout(
      id: 'push-01',
      name: 'Upper body strength',
      date: _today,
      durationMinutes: 58,
      exercises: const [
        'Bench press - 4 x 8',
        'Overhead press - 3 x 10',
        'Incline dumbbell press - 3 x 12',
        'Cable triceps pushdown - 3 x 12',
      ],
      caloriesBurned: 340,
      source: 'Apple Watch',
      notes: 'Added 2.5 kg to the bench press.',
    ),
    Workout(
      id: 'legs-02',
      name: 'Leg day: squat, Romanian deadlift and accessory work',
      date: _today.subtract(const Duration(days: 2)),
      durationMinutes: 76,
      exercises: const [
        'Barbell squat - 4 x 6',
        'Romanian deadlift - 4 x 8',
        'Leg press - 3 x 12',
        'Standing calf raise - 4 x 15',
      ],
      caloriesBurned: 510,
      source: 'Garmin',
    ),
    Workout(
      id: 'run-03',
      name: 'Easy recovery run',
      date: _today.subtract(const Duration(days: 3)),
      durationMinutes: 32,
      exercises: const ['Outdoor run - 4.2 km'],
      caloriesBurned: 285,
      source: 'Fitbit',
    ),
    Workout(
      id: 'pull-04',
      name: 'Back and biceps',
      date: _today.subtract(const Duration(days: 5)),
      durationMinutes: 64,
      exercises: const [
        'Lat pulldown - 4 x 10',
        'Seated cable row - 3 x 10',
        'Face pull - 3 x 15',
        'Dumbbell curl - 3 x 12',
      ],
      source: 'Manual entry',
      notes: 'Focused on controlled reps.',
    ),
    Workout(
      id: 'core-05',
      name: 'Core and mobility',
      date: _today.subtract(const Duration(days: 7)),
      durationMinutes: 28,
      exercises: const [
        'Plank - 3 x 45 sec',
        'Dead bug - 3 x 10',
        'Hip mobility - 10 min',
      ],
      caloriesBurned: 125,
    ),
    Workout(
      id: 'full-06',
      name: 'Full body - technique and light weights',
      date: _today.subtract(const Duration(days: 9)),
      durationMinutes: 49,
      exercises: const [
        'Goblet squat - 3 x 10',
        'Dumbbell row - 3 x 10',
        'Push-up - 3 x 12',
      ],
      caloriesBurned: 260,
      source: 'Apple Watch',
    ),
    Workout(
      id: 'swim-07',
      name: 'Swimming',
      date: _today.subtract(const Duration(days: 12)),
      durationMinutes: 40,
      exercises: const ['Freestyle - 800 m'],
      source: 'Garmin',
    ),
    Workout(
      id: 'custom-08',
      name: 'A custom session with a deliberately long title to check layout',
      date: _today.subtract(const Duration(days: 14)),
      durationMinutes: 35,
      exercises: const ['Stretching and recovery'],
      notes: 'No calorie estimate for this session.',
    ),
  ]);

  @override
  void addListener(VoidCallback listener) => _listeners.add(listener);

  @override
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  @override
  Future<List<Workout>> fetchWorkouts() async {
    await _waitAndMaybeFail();
    return List.unmodifiable(_workouts);
  }

  @override
  Future<void> addWorkout(Workout workout) async {
    await _waitAndMaybeFail();
    _workouts = List.unmodifiable([workout, ..._workouts]);
    for (final listener in List<VoidCallback>.of(_listeners)) {
      listener();
    }
  }

  Future<void> _waitAndMaybeFail() async {
    await Future<void>.delayed(_delay);
    if (_random.nextDouble() < _failureRate) {
      throw Exception('Simulated workout repository failure.');
    }
  }
}
