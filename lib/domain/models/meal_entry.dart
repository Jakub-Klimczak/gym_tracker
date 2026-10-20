class MealEntry {
  const MealEntry({
    required this.id,
    required this.name,
    required this.loggedAt,
    this.calories,
    this.imageDescription,
    this.estimatedByAi = false,
  });

  final String id;
  final String name;
  final DateTime loggedAt;
  final int? calories;
  final String? imageDescription;
  final bool estimatedByAi;
}
