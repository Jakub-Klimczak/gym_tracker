import 'package:flutter/material.dart';
import 'ui/home/gym_dashboard_screen.dart';

void main() => runApp(const GymTrackerApp());

class GymTrackerApp extends StatelessWidget {
  const GymTrackerApp({super.key});

  static const _seed = Color(0xFF176B5B);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'gym_tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const GymDashboardScreen(),
    );
  }
}
