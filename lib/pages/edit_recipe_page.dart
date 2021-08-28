import 'package:flutter/material.dart';
import 'package:meal_planner_app/models/recipe_model.dart';

class EditRecipePage extends StatefulWidget {
  final RecipeModel _recipeModel;

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
    _data = widget._recipeModel;
    _default = RecipeModel();
    if (_data.name != _default.name) {_titleText.text = _data.name;}

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: [
      SliverAppBar(
        floating: false,
        pinned: true,
        snap: false,
        leading: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            // TODO: implement
          }
        ),
        title: Text(_data.name != _default.name ? "Edit Recipe" : "New Recipe"),
        actions: [
          TextButton(
            child: Text("Save"),
            onPressed: () {
              // TODO: ensure that name is set and name is unique
              // TODO: implement
            },
          )
        ]
      ),
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
      TextButton.icon(
        icon: Icon(Icons.access_time),
        label: Text("Set duration"),
        onPressed: () {
          // TODO: launch timepicker dialog
        }
      ),
      Divider(),
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
              setState(() {_data.servings--;});
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
      TextButton.icon(
        icon: Icon(Icons.restaurant),
      )
    ]);
  }

  List<Widget> _getIngredients() {
    List<Widget> ingredients = [];
    for (var ingredient in _data.ingredients) {
      // TODO: implement
    }
  }
}