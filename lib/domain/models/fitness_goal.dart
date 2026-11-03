enum GoalTrackingMode { manual, workouts, wearable }

class FitnessGoal {
  const FitnessGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.currentValue,
    required this.targetValue,
    required this.unit,
    this.deadline,
    this.trackingMode = GoalTrackingMode.manual,
  });

  final String id;
  final String title;
  final String description;
  final double currentValue;
  final double targetValue;
  final String unit;
  final DateTime? deadline;
  final GoalTrackingMode trackingMode;

  FitnessGoal copyWith({
    String? id,
    String? title,
    String? description,
    double? currentValue,
    double? targetValue,
    String? unit,
    DateTime? deadline,
    GoalTrackingMode? trackingMode,
  }) => FitnessGoal(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    currentValue: currentValue ?? this.currentValue,
    targetValue: targetValue ?? this.targetValue,
    unit: unit ?? this.unit,
    deadline: deadline ?? this.deadline,
    trackingMode: trackingMode ?? this.trackingMode,
  );

  double get progress => targetValue <= 0
      ? 0
      : (currentValue / targetValue).clamp(0.0, 1.0).toDouble();
}
