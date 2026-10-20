import 'package:flutter/material.dart';
import '../goals/goals_screen.dart';
import '../nutrition/nutrition_screen.dart';
import '../workouts/workouts_screen.dart';

class GymDashboardScreen extends StatefulWidget {
  const GymDashboardScreen({super.key});

  @override
  State<GymDashboardScreen> createState() => _GymDashboardScreenState();
}

class _GymDashboardScreenState extends State<GymDashboardScreen> {
  int _selectedIndex = 0;

  static const _pages = [
    WorkoutsScreen(),
    GoalsScreen(),
    NutritionScreen(),
  ];

  static const _titles = ['gym_tracker', 'My goals', 'Nutrition'];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 840;
        final destinations = const [
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Workouts',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag),
            label: 'Goals',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: 'Nutrition',
          ),
        ];

        return Scaffold(
          appBar: AppBar(title: Text(_titles[_selectedIndex])),
          body: wide
              ? Row(
                  children: [
                    NavigationRail(
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (index) {
                        setState(() => _selectedIndex = index);
                      },
                      labelType: NavigationRailLabelType.all,
                      destinations: [
                        for (final destination in destinations)
                          NavigationRailDestination(
                            icon: destination.icon,
                            selectedIcon: destination.selectedIcon,
                            label: Text(destination.label),
                          ),
                      ],
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: IndexedStack(
                        index: _selectedIndex,
                        children: _pages,
                      ),
                    ),
                  ],
                )
              : IndexedStack(
                  index: _selectedIndex,
                  children: _pages,
                ),
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() => _selectedIndex = index);
                  },
                  destinations: destinations,
                ),
        );
      },
    );
  }
}
