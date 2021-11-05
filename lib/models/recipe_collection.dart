import 'package:flutter/material.dart';
import 'package:meal_planner_app/Utils.dart';
import 'package:sqflite/sqflite.dart';
import 'package:meal_planner_app/models/recipe_model.dart';

typedef SortMetric = int Function(RecipeModel a, RecipeModel b);

class RecipeCollection extends ChangeNotifier {
  static const int ASCENDING = 1;
  static const int DESCENDING = -1;
  static final SortMetric name = (a, b) => a.name.compareTo(b.name);
  static final SortMetric time =
      (a, b) => a.intDuration().compareTo(b.intDuration());
  static final SortMetric servings = (a, b) => a.servings.compareTo(b.servings);
  int _sortOrder = ASCENDING;
  SortMetric _sortMetric = name;
  List<RecipeModel> _recipes = [];
  Future<void> _loading;

  RecipeCollection() {
    // Load recipe collection data
    _loading = _loadData();
  }

  Future<void> _loadData() async {
    final Database db = await Utils.getDatabase();
    List<Map<String, dynamic>> rows;
    try {
      rows = await db.query("recipes");
    }
    on DatabaseException {
      rows = List.empty();
    }
    for (int i = 0; i < rows.length; i++) {
      addRecipe(RecipeModel(
        imagePath: rows[i]["imagePath"],
        name: rows[i]["name"],
        time: rows[i]["time"],
        servings: rows[i]["servings"],
        ingredients: _parseIngredients(rows[i]["ingredients"]),
        instructions: rows[i]["instructions"],
      ));
    }
  }

  Future<void> _saveData(RecipeModel data) async {
    final Database db = await Utils.getDatabase();
    await db.insert(
      "recipes",
      {
        "imagePath" : data.imagePath,
        "name" : data.name,
        "time" : data.time,
        "servings" : data.servings,
        "ingredients" : _serializeIngredients(data.ingredients),
        "instructions" : data.instructions,
      },
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  List<Ingredient> _parseIngredients(String data) {
    List<Ingredient> ingredients = [];
    List<String> entries = data.split(",");
    for (var entry in entries) {
      List<String> values = entry.split(":");
      Ingredient ingredient = Ingredient(values[0], values[1]);
      ingredients.add(ingredient);
    }
    return ingredients;
  }

  String _serializeIngredients(List<Ingredient> ingredients) {
    String out = "";
    for (var ingredient in ingredients) {
      out = out + ingredient.name + ":" + ingredient.strAmount + ",";
    }
    return out.substring(0, out.length - 1); // Remove trailing comma
  }

  void _sort() => _recipes.sort((a, b) => _sortMetric(a, b) * _sortOrder);

  Future<void> get loading => _loading;

  RecipeModel getRecipe(int index) {
    return _recipes[index];
  }

  int getIndex(RecipeModel data) {
    return _recipes.indexOf(data);
  }

  void addRecipe(RecipeModel data) {
    _recipes.add(data);
    _sort();
    notifyListeners();
    _saveData(data);
  }

  void editRecipe(RecipeModel data) {
    _recipes.remove(data);
    _recipes.add(data);
    _sort();
    notifyListeners();
    _saveData(data);
  }

  void removeRecipe(RecipeModel data) {
    _recipes.remove(data);
    notifyListeners();
    _saveData(data);
  }

  void sortBy(SortMetric metric, int order) {
    _sortMetric = metric;
    _sortOrder = order;
    _sort();
    notifyListeners();
  }

  int collectionSize() => _recipes.length;
}