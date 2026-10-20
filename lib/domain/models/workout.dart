class Workout {
  Workout({
    required this.id,
    required this.name,
    required this.date,
    required this.durationMinutes,
    required List<String> exercises,
    this.caloriesBurned,
    this.source,
    this.notes,
  }) : exercises = List.unmodifiable(exercises);

  final String id;
  final String name;
  final DateTime date;
  final int durationMinutes;
  final List<String> exercises;
  final int? caloriesBurned;
  final String? source;
  final String? notes;
}
