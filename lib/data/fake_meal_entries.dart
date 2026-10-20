import '../domain/models/meal_entry.dart';

final fakeMealEntries = List<MealEntry>.unmodifiable([
  MealEntry(
    id: 'lunch-01',
    name: 'Chicken, rice and roasted vegetables',
    loggedAt: DateTime(2026, 10, 20, 13),
    calories: 640,
    imageDescription: 'Grilled chicken with rice and broccoli',
    estimatedByAi: true,
  ),
  MealEntry(
    id: 'breakfast-01',
    name: 'Oatmeal with banana',
    loggedAt: DateTime(2026, 10, 20, 8),
    calories: 390,
    imageDescription: 'A bowl of oatmeal topped with sliced banana',
    estimatedByAi: true,
  ),
  MealEntry(
    id: 'snack-01',
    name: 'Apple',
    loggedAt: DateTime(2026, 10, 19, 16),
    calories: 95,
  ),
  MealEntry(
    id: 'dinner-01',
    name: 'Homemade lentil curry with brown rice',
    loggedAt: DateTime(2026, 10, 19, 19),
    imageDescription: 'Image estimate not available yet',
  ),
  MealEntry(
    id: 'lunch-02',
    name: 'Salmon salad',
    loggedAt: DateTime(2026, 10, 18, 12),
    calories: 520,
    imageDescription: 'Salmon with leafy greens and dressing',
    estimatedByAi: true,
  ),
]);
