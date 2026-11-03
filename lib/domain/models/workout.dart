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

  Workout copyWith({
    String? id,
    String? name,
    DateTime? date,
    int? durationMinutes,
    List<String>? exercises,
    int? caloriesBurned,
    String? source,
    String? notes,
  }) => Workout(
    id: id ?? this.id,
    name: name ?? this.name,
    date: date ?? this.date,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    exercises: exercises ?? this.exercises,
    caloriesBurned: caloriesBurned ?? this.caloriesBurned,
    source: source ?? this.source,
    notes: notes ?? this.notes,
  );
}
