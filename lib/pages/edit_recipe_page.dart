import 'package:flutter/material.dart';
import 'package:meal_planner_app/models/recipe_collection.dart';
import 'package:meal_planner_app/models/recipe_model.dart';
import 'package:meal_planner_app/pages/food_item_search.dart';
import 'package:meal_planner_app/utils.dart';
import 'package:meal_planner_app/widgets/ingredient_dialog.dart';
import 'package:meal_planner_app/widgets/time_dialog.dart';
import 'package:provider/provider.dart';

class EditRecipePage extends StatefulWidget {
  final RecipeModel _recipeModel;

  // TODO: Use string instead to reduce confusion with navigator return value(?)
  EditRecipePage(this._recipeModel);

  @override
  EditRecipePageState createState() => EditRecipePageState();
}

class EditRecipePageState extends State<EditRecipePage> {
  RecipeModel _data;
  RecipeModel _default;
  TextEditingController _titleText = TextEditingController();
  TextEditingController _instructionsText = TextEditingController();

  @override
  void initState() {
    _data = RecipeModel.copy(widget._recipeModel);
    _default = RecipeModel();
    if (_data.name != _default.name) {
      _titleText.text = _data.name;
      _instructionsText.text = _data.instructions;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body:
      CustomScrollView(slivers: [
        SliverAppBar(
          floating: false,
          pinned: true,
          snap: false,
          leading: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              // Return original recipe data to previous page
              Navigator.of(context).pop<RecipeModel>(widget._recipeModel);
            }
          ),
          title: Text(_data.name != _default.name ? "Edit Recipe" : "New Recipe"),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                primary: Theme.of(context).colorScheme.onPrimary
              ),
              child: Text("Save"),
              onPressed: () {
                // Ensure that name is set
                if (_data.name != _default.name) {
                  RecipeCollection collection = Provider.of<RecipeCollection>(
                      context, listen: false
                  );
                  collection.insertRecipe(_data);
                  // Return modified recipe model to previous page
                  Navigator.of(context).pop<RecipeModel>(_data);
                }
              },
            )
          ]
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _titleText,
                decoration: InputDecoration(
                    hintText: _data.name == _default.name ? "Add title" : ""
                ),
                onSubmitted: (String value) {
                  if (_titleText.text != "") {
                    _data.name = value;
                  }
                }
              )
            ),
            Divider(), // TODO: add category selection option
            // Duration
            TextButton.icon(
              icon: Icon(Icons.access_time),
              label: Text(_data.intDuration() == _default.intDuration() ?
                  "Set duration" : _data.strDuration()),
              onPressed: () async {
                String time = await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => TimeDialog(_data.time)
                );
                setState(() {
                  _data.time = time;
                });
              }
            ),
            Divider(),
            // Servings
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.people_outlined)
                ),
                Expanded(
                  child: Text("${_data.servings}")
                ),
                IconButton(
                  icon: Icon(Icons.remove_circle_outline),
                  onPressed: () { // TODO: inline
                    setState(() {
                      if (_data.servings > 0) {
                        _data.servings--;
                      }
                    });
                  }
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: IconButton(
                      icon: Icon(Icons.add_circle_outline),
                      onPressed: () => setState(() {_data.servings++;})
                  )
                )
              ]
            ),
            Divider(),
            // Ingredients
            _data.ingredients.length > 0 ? Column(children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(children: [
                  Icon(Icons.restaurant),
                  Expanded(
                    child: Column(children: _getIngredients())
                  )
                ])
              ),
              TextButton(
                onPressed: () async {
                  // Launch food item search page
                  Ingredient result = await showSearch<Ingredient>(
                    context: context, delegate: FoodItemSearch()
                  );
                  setState(() {
                    if (result != null) {
                      _data.ingredients.add(result);
                    }
                  });
                },
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 8 + IconTheme.of(context).size + 8
                  ),
                  child: const SizedBox(
                    width: double.infinity,
                    child: Text("Add ingredient")
                  )
                )
              )
            ]) : TextButton.icon(
              onPressed: () async {
                // Launch food item search page
                Ingredient result = await showSearch<Ingredient>(
                  context: context, delegate: FoodItemSearch()
                );
                setState(() {
                  if (result != null) {
                    _data.ingredients.add(result);
                  }
                });
              },
              icon: Icon(Icons.restaurant),
              label: Expanded(
                child: Text("Add ingredient")
              )
            ),
            Divider(),
            // Instructions
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(Icons.subject)
                ),
                Expanded(
                  child: TextField() // TODO: implement
                )
              ])
            )
          ])
        )
      ])
    );
  }

  List<Widget> _getIngredients() {
    List<Widget> ingredients = [];
    for (var ingredient in _data.ingredients) {
      ingredients.add(Padding(
        padding: EdgeInsets.only(
          bottom: ingredient == _data.ingredients.last ? 0 : 8
        ),
        child: Row(
          children: [
            Text(
              Utils.strFraction(ingredient.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold
              )
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: TextButton(
                  child: Text(ingredient.name),
                  onPressed: () async {
                    bool result = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return IngredientDialog(ingredient, false);
                      }
                    );
                    setState(() {
                      if (result) {
                        _data.ingredients.remove(ingredient);
                        _data.ingredients.add(ingredient);
                      }
                    });
                  }
                )
              )
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _data.ingredients.remove(ingredient);
                });
              },
              icon: Icon(Icons.close)
            )
          ]
        )
      ));
    }
    return ingredients;
  }
}