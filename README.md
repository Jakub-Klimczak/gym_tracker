# gym_tracker

A Flutter fitness-tracking app prototype. The current UI uses fake data for
workouts, personal goals, and meal calorie estimates; smartwatch syncing,
AI image analysis, and persistence are not wired up yet.

## Project structure

```text
lib/
  main.dart                         app setup and theme
  domain/models/                    Workout, FitnessGoal, MealEntry
  domain/repositories/              repository contracts
  data/repositories/                fake implementations
  ui/
    core/widgets/                   reusable widgets
    home/                           dashboard and bottom navigation
    workouts/                       workout list and details
    goals/                           goal progress
    nutrition/                       meal and calorie overview
```

## Architecture

The main data flow is repository -> view model -> screen; screens send user
actions back through their view model to a repository.

```text
lib/
  main.dart
  domain/models/
  domain/repositories/
  data/repositories/
  ui/core/
  ui/home/
  ui/workouts/
  ui/goals/
  ui/nutrition/
```

The app uses Provider with `ChangeNotifier` view models. This keeps state
management consistent across features while using Flutter's built-in
notification model, and lets multiple screens observe shared workout state.

Repository contracts:

- `WorkoutRepository` fetches and adds workouts, and notifies listeners when
  workouts change.
- `FitnessGoalRepository` provides fitness goals.
- `MealEntryRepository` provides meal entries and calorie estimates.

The fake implementations live in `data/repositories/`; each simulates network
latency and intermittent failure. Only `main.dart` selects concrete repository
implementations.

## Run

```sh
flutter pub get
flutter run
```

Run widget tests with `flutter test`.

See [docs/TESTING_GUIDE.md](docs/TESTING_GUIDE.md) for a manual test walkthrough
and pointers to the app's code.
