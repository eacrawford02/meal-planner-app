import 'package:flutter/material.dart';
import 'package:meal_planner_app/pages/home_page.dart';

void main() {
  runApp(MealPlannerApp());
}

class MealPlannerApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Planner',
      home: HomePage()
    );
  }
}
