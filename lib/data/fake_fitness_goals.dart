import '../domain/models/fitness_goal.dart';

final fakeFitnessGoals = List<FitnessGoal>.unmodifiable([
  FitnessGoal(
    id: 'weekly-workouts',
    title: 'Train consistently',
    description: 'Complete 4 workouts this week',
    currentValue: 3,
    targetValue: 4,
    unit: 'workouts',
    deadline: DateTime(2026, 10, 25),
  ),
  FitnessGoal(
    id: 'monthly-distance',
    title: 'Move more',
    description: 'Run or walk 30 km this month',
    currentValue: 18.4,
    targetValue: 30,
    unit: 'km',
    deadline: DateTime(2026, 10, 31),
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
    currentValue: 2,
    targetValue: 2,
    unit: 'L',
  ),
]);
