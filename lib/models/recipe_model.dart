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
    this.time = "",
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
      nutrient.amount += ingredient.nutrient(name).amount;
    }
    return nutrient;
  }
}

class Ingredient {
  FoodItem _foodItem;
  // nWhole, numerator, and denominator are used to represent the amount of an
  // ingredient using fractions
  int _nWhole = 0;
  int _numerator = 0;
  int _denominator = 0;

  // Example of strAmount format: "1 1/2"
  Ingredient(String name, [String strAmount]) {
    _foodItem = FoodItem(name);
    // If an initial amount is provided (in string format), parse and store
    // using integer representation
    if (strAmount != null) {
      int space = strAmount.indexOf(" ");
      int div = strAmount.indexOf("/");
      _nWhole = int.parse(strAmount.substring(0, space));
      _numerator = int.parse(strAmount.substring(space + 1, div - 1));
      _denominator = int.parse(strAmount.substring(div + 2));
    }
  }

  String get name => _foodItem.name;
  double get dblAmount => _nWhole + _numerator / _denominator;
  String get strAmount => "$_nWhole $_numerator / $_denominator";

  Nutrient nutrient(String name) => _foodItem.nutrients[name];
}