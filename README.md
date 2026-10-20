# gym_tracker

A Flutter fitness-tracking app prototype. The current UI uses fake data for
workouts, personal goals, and meal calorie estimates; smartwatch syncing,
AI image analysis, and persistence are not wired up yet.

## Project structure

```text
lib/
  main.dart                         app setup and theme
  domain/models/                    Workout, FitnessGoal, MealEntry
  data/                             fake data for each model
  ui/
    core/widgets/                   reusable widgets
    home/                           dashboard and bottom navigation
    workouts/                       workout list and details
    goals/                           goal progress
    nutrition/                       meal and calorie overview
```

## Run

```sh
flutter pub get
flutter run
```

Run widget tests with `flutter test`.

See [docs/TESTING_GUIDE.md](docs/TESTING_GUIDE.md) for a manual test walkthrough
and pointers to the app's code.
