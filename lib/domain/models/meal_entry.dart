class MealEntry {
  const MealEntry({
    required this.id,
    required this.name,
    required this.loggedAt,
    this.calories,
    this.proteinGrams,
    this.carbohydratesGrams,
    this.sugarsGrams,
    this.fatGrams,
    this.imageDescription,
    this.estimatedByAi = false,
  });

  final String id;
  final String name;
  final DateTime loggedAt;
  final int? calories;
  final double? proteinGrams;
  final double? carbohydratesGrams;
  final double? sugarsGrams;
  final double? fatGrams;
  final String? imageDescription;
  final bool estimatedByAi;

  MealEntry copyWith({
    String? id,
    String? name,
    DateTime? loggedAt,
    int? calories,
    double? proteinGrams,
    double? carbohydratesGrams,
    double? sugarsGrams,
    double? fatGrams,
    String? imageDescription,
    bool? estimatedByAi,
  }) => MealEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    loggedAt: loggedAt ?? this.loggedAt,
    calories: calories ?? this.calories,
    proteinGrams: proteinGrams ?? this.proteinGrams,
    carbohydratesGrams: carbohydratesGrams ?? this.carbohydratesGrams,
    sugarsGrams: sugarsGrams ?? this.sugarsGrams,
    fatGrams: fatGrams ?? this.fatGrams,
    imageDescription: imageDescription ?? this.imageDescription,
    estimatedByAi: estimatedByAi ?? this.estimatedByAi,
  );
}
