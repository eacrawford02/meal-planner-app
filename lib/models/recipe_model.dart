import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:meal_planner_app/utils.dart';

class RecipeModel {
  String imagePath;
  String name;
  String time;
  int servings;
  List<String> ingredients;
  String instructions;
  Map<String, int> nutrition; // TODO: safety - more default keys

  RecipeModel({
    this.imagePath = Utils.placeholderImg,
    this.name = "Unnamed Recipe",
    this.time = "0:0",
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