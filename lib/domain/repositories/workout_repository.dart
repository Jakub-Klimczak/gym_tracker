import 'package:flutter/foundation.dart';

import '../models/workout.dart';

abstract interface class WorkoutRepository {
  void addListener(VoidCallback listener);

  void removeListener(VoidCallback listener);

  Future<List<Workout>> fetchWorkouts();

  Future<void> addWorkout(Workout workout);
}
