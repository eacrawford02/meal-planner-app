import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:meal_planner_app/utils.dart';
import 'package:meal_planner_app/models/food_item.dart';

class RecipeModel {
  String imagePath;
  String name;
  String time;
  int servings;
  List<Ingredient> ingredients;
  String instructions;

  RecipeModel({
    this.imagePath = Utils.placeholderImg,
    this.name = "",
    this.time = "0:0",
    this.servings = 0,
    this.ingredients,
    this.instructions = "",
  }) {
    ingredients = ingredients != null ? ingredients : [];
  }

  // Human-readable time duration format (e.g. 1 hr 25 m)
  String strDuration() {
    int i = time.indexOf(":");
    return time.substring(0, i) + " hr " + time.substring(i + 1) + " min";
  }

  // Time duration stored in a 4 digit format (e.g. 1 hr 25 m = 125)
  int intDuration() {
    int i = time.indexOf(":");
    return int.parse(time.substring(0, i)) * 100
        + int.parse(time.substring(i + 1));
  }

  void setDuration(int hours, int minutes) {
    // TODO: convert minutes > 60 to hours
    time = "$hours:$minutes";
  }

  Image getImage() {
    // Placeholder image is stored in app assets folder, user-supplied image
    // file is stored elsewhere on the device storage
    if (imagePath != Utils.placeholderImg) {
      return Image.file(File(imagePath));
    }
    else {
      return Image.asset(imagePath);
    }
  }

  Nutrient getNutrient(String name) {
    Nutrient nutrient = Nutrient(name, 0);
    for (var ingredient in ingredients) {
      nutrient.amount += ingredient.nutrient(name);
    }
    return nutrient;
  }
}

class Ingredient {
  FoodItem _foodItem;
  double amount;
  String units;

  // Example of strAmount format: "1 1/2"
  Ingredient(String name, [this.amount, this.units]) {
    _foodItem = FoodItem(name: name);
    _foodItem.loadData();
  }

  String get name => _foodItem.name;

  int nutrient(String name) => _foodItem.convertAmount(name, amount, units);
}