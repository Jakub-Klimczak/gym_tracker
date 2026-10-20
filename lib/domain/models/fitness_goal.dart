class FitnessGoal {
  const FitnessGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.currentValue,
    required this.targetValue,
    required this.unit,
    this.deadline,
  });

  final String id;
  final String title;
  final String description;
  final double currentValue;
  final double targetValue;
  final String unit;
  final DateTime? deadline;

  double get progress => targetValue <= 0
      ? 0
      : (currentValue / targetValue).clamp(0.0, 1.0).toDouble();
}
