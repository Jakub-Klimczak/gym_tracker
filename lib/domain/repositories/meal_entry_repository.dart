import '../models/meal_entry.dart';

abstract interface class MealEntryRepository {
  Future<List<MealEntry>> fetchMealEntries();

  Future<void> addMealEntry(MealEntry meal);

  Future<void> updateMealEntry(MealEntry meal);
}
