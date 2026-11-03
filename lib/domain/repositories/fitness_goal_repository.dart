import '../models/fitness_goal.dart';

abstract interface class FitnessGoalRepository {
  Future<List<FitnessGoal>> fetchGoals();

  Future<void> addGoal(FitnessGoal goal);

  Future<void> updateGoal(FitnessGoal goal);
}
