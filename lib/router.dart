import 'package:go_router/go_router.dart';

import 'ui/core/shell/app_shell.dart';
import 'ui/goals/goals_screen.dart';
import 'ui/home/gym_dashboard_screen.dart';
import 'ui/nutrition/nutrition_screen.dart';
import 'ui/nutrition/meal_entry_form_screen.dart';
import 'ui/workouts/workout_details_screen.dart';
import 'ui/workouts/workout_form_screen.dart';
import 'ui/workouts/workouts_screen.dart';
import 'ui/goals/fitness_goal_form_screen.dart';

GoRouter createRouter() => GoRouter(
  initialLocation: '/dashboard',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const GymDashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/workouts',
              builder: (context, state) => const WorkoutsScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const WorkoutFormScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) => WorkoutDetailsScreen(
                    workoutId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/nutrition',
              builder: (context, state) => const NutritionScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const MealEntryFormScreen(),
                ),
                GoRoute(
                  path: ':mealId/edit',
                  builder: (context, state) => MealEntryFormScreen(
                    mealId: state.pathParameters['mealId']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/goals',
              builder: (context, state) => const GoalsScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const FitnessGoalFormScreen(),
                ),
                GoRoute(
                  path: ':goalId/edit',
                  builder: (context, state) => FitnessGoalFormScreen(
                    goalId: state.pathParameters['goalId']!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
