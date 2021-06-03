import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecipePage extends StatefulWidget {
  @override
  RecipePageState createState() => RecipePageState();
}

class RecipePageState extends State<RecipePage> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          floating: false,
          snap: false,
          expandedHeight: 100,
          flexibleSpace: const FlexibleSpaceBar(
            title: Text("Recipes")
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                // TODO: implement (animate to fill title space of app bar)
              }
            ),
            IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () {
                // TODO: implement
              }
            )
          ]
        ),
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              // TODO: implement
            },
            childCount: 0, // TODO: implement
            findChildIndexCallback: (Key key) {
                // TODO: implement
            }
          )
        )
      ]
    );
  }
}