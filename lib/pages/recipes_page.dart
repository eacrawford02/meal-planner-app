import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meal_planner_app/models/recipe_collection.dart';
import 'package:meal_planner_app/models/recipe_model.dart';
import 'package:meal_planner_app/pages/edit_recipe_page.dart';
import 'package:meal_planner_app/widgets/recipe_card.dart';
import 'package:provider/provider.dart';

class RecipePage extends StatefulWidget {
  @override
  RecipePageState createState() => RecipePageState();
}

class RecipePageState extends State<RecipePage> {
  Map<ValueKey<String>, RecipeModel> _recipeKeys;

  @override
  void initState() {
    _recipeKeys = Map();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      CustomScrollView(
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
          Consumer<RecipeCollection>(
            builder: (context, recipeCollection, child) {
              return FutureBuilder<void>(
                future: recipeCollection.loading,
                builder: (BuildContext context,
                    AsyncSnapshot<void> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return SliverGrid(
                      gridDelegate: const
                      SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          RecipeModel data = recipeCollection.getRecipe(index);
                          ValueKey<String> key = ValueKey(data.name);
                          _recipeKeys[key] = data;
                          return RecipeCard(data, key);
                        },
                        childCount: recipeCollection.collectionSize(),
                        findChildIndexCallback: (Key key) {
                          return recipeCollection.getIndex(
                              _recipeKeys[key]);
                        }
                      )
                    );
                  }
                  else {
                    return SliverToBoxAdapter(
                      child: Container(
                          alignment: Alignment.center,
                          child: SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator()
                          )
                      )
                    );
                  }
                }
              );
            }
          )
        ]
      ),
      Positioned(
        right: 16,
        bottom: 16,
        child: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            RecipeModel recipe = await Navigator.push<RecipeModel>(
              context,
              MaterialPageRoute<RecipeModel>(builder: (BuildContext context) {
                return EditRecipePage(RecipeModel());
              })
            );
            if (recipe != null) {
              RecipeCollection collection = Provider.of<RecipeCollection>(
                context, listen: false
              );
              collection.insertRecipe(recipe);
            }
          }
        )
      )
    ]);
  }
}