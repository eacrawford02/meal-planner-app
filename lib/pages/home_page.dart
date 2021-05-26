import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _index = 0;
  final List<Widget> _pages = []; // TODO: add screen widgets

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
      )
    );
  }
}