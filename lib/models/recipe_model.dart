import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:meal_planner_app/utils.dart';
import 'package:meal_planner_app/models/food_item.dart';

class RecipeModel {
  String imagePath;
  String name;
  String time;
  int servings;
  List<Ingredient> ingredients; // TODO: reformat to use new FoodItem and Nutrient types
  String instructions;
  Map<String, int> nutrition; // TODO: safety - more default keys

  RecipeModel({
    this.imagePath = Utils.placeholderImg,
    this.name = "",
    this.time = "",
    this.servings = 0,
    this.ingredients,
    this.instructions = "",
    this.nutrition
  }) {
    ingredients = ingredients != null ? ingredients : [];
    nutrition = nutrition != null ? nutrition : Map();
    nutrition["Calories"] = 0;
  }

  // Human-readable time duration format
  // TODO: rename to strDuration and intDuration
  String getDurationS() {
    int i = time.indexOf(":");
    return time.substring(0, i) + " hr " + time.substring(i + 1) + " min";
  }

  int getDurationI() {
    int i = time.indexOf(":");
    return int.parse(time.substring(0, i)) * 100
        + int.parse(time.substring(i + 1));
  }

  void setDuration(int hours, int minutes) {
    time = "$hours:$minutes";
  }

  Image getImage() {
    if (imagePath != Utils.placeholderImg) {
      return Image.file(File(imagePath));
    }
    else {
      return Image.asset(imagePath);
    }
  }
}

class Ingredient {
  String name = "";
  FoodItem foodItem;
  int _nWhole = 0;
  int _numerator = 0;
  int _denominator = 0;

  double get dblAmount => _nWhole + _numerator / _denominator;
  String get strAmount => "$_nWhole $_numerator / $_denominator";
}