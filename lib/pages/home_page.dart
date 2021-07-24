import 'package:flutter/material.dart';
import 'package:meal_planner_app/models/recipe_collection.dart';
import 'package:meal_planner_app/pages/recipes_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _index = 0;
  final List<Widget> _pages = [
    RecipePage(),
    RecipePage(),
    RecipePage()
  ]; // TODO: add screen widgets
  RecipeCollection _recipeCollection = RecipeCollection();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.view_day_outlined),
            activeIcon: Icon(Icons.view_day),
            label: "Menu"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_outlined),
            activeIcon: Icon(Icons.receipt),
            label: "Recipes"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket_outlined),
            activeIcon: Icon(Icons.shopping_basket),
            label: "Groceries"
          )
        ],
        currentIndex: _index,
        onTap: (int i) {
          setState(() {
            _index = i;
          });
        }
      ),
      body: ChangeNotifierProvider.value(
        value: _recipeCollection,
        child: _pages[_index]
      )
    );
  }
}