import 'package:flutter/material.dart';
import 'package:meal_planner_app/models/recipe_collection.dart';
import 'package:meal_planner_app/models/recipe_model.dart';
import 'package:meal_planner_app/widgets/recipe_card.dart';
import 'package:provider/provider.dart';

class RecipePage extends StatefulWidget {
  @override
  RecipePageState createState() => RecipePageState();
}

class RecipePageState extends State<RecipePage> {
  RecipeCollection _recipeCollection;
  Map<ValueKey<String>, RecipeModel> _recipeKeys;

  @override
  void initState() {
    _recipeCollection = RecipeCollection();
    _recipeKeys = Map();

    super.initState();
  }

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
        FutureBuilder<RecipeModel>(
          future: _recipeCollection.loading,
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16
                  ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    RecipeModel data = _recipeCollection.getRecipe(index);
                    ValueKey<String> key = ValueKey(data.name);
                    _recipeKeys[key] = data;
                    return RecipeCard(data, key);
                  },
                  childCount: _recipeCollection.collectionSize(),
                  findChildIndexCallback: (Key key) {
                    return _recipeCollection.getIndex(_recipeKeys[key]);
                  }
                )
              );
            }
            else {
              return CircularProgressIndicator();
            }
          }
        )
      ]
    );
  }
}