import 'package:meal_planner_app/utils.dart';
import 'package:sqflite/sqflite.dart';

class FoodItem {
  static const String grams = "g";
  static const String cup = "cup";
  static const String cups = "cups";
  static const String millilitres = "mL";
  static const String teaspoons = "tsp";
  static const String tablespoons = "tbsp";
  Future<void> loading;
  String name = "";
  String category = ""; // TODO: change default value(?)
  // Nutrition information variables (per serving size)
  Nutrient calories = Nutrient("Calories", 0, "cal");
  // TODO: add more
  // Packaged amounts of the chosen food item (metric)
  int packageSize = 0;
  int servingSize = 0;
  String packageUnits = grams;
  _UnitRatio _cupRatio = _UnitRatio(1, 250); // 1 cup = 250 mL
  _UnitRatio _tspRatio = _UnitRatio(1, 5); // 1 tsp = 5 mL
  _UnitRatio _tbspRatio = _UnitRatio(1, 15); // 1 tsp = 15 mL

  FoodItem(this.name) {
    // Load data
    loading = _loadData();
  }

  Future<void> save() async {
    final Database db = await Utils.getDatabase();
    await db.insert(
        "food_items",
        {
          "name" : name,
          "category" : category,
          "packageSize" : packageSize,
          "servingSize" : servingSize,
          "packageUnits" : packageUnits,
          "calories" : calories
        },
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  int getAmount(Nutrient nutrient, double portionSize, String measurementUnit) {
    double ratio = nutrient.amount / servingSize;
    if (measurementUnit == cup || measurementUnit == cups) {
      return (portionSize * _cupRatio.ratio * ratio).round();
    }
    else if (measurementUnit == teaspoons) {
      return (portionSize * _tspRatio.ratio * ratio).round();
    }
    else if (measurementUnit == tablespoons) {
      return (portionSize * _tbspRatio.ratio * ratio).round();
    }
    else {
      throw Exception("Invalid measurement unit: $measurementUnit");
    }
  }

  Future<void> _loadData() async {
    final Database db = await Utils.getDatabase();
    List<Map<String, dynamic>> rows;
    try {
      rows = await db.query(
          "food_items",
          where: "name = ?",
          whereArgs: [name]
      );
    }
    on DatabaseException {
      rows = List.empty();
    }
    if (rows.length > 1) {
      throw Exception("More than one occurrence of food item $name");
    }
    for (int i = 0; i < rows.length; i++) {
      name = rows[i]["name"];
      category = rows[i]["category"];
      packageSize = rows[i]["packageSize"];
      servingSize = rows[i]["servingSize"];
      packageUnits = rows[i]["packageUnits"];
      calories.amount = rows[i]["calories"];
    }
  }
}

class Nutrient {
  String name;
  int amount;
  String unit;

  Nutrient(this.name, this.amount, this.unit);
}

class _UnitRatio {
  double a;
  double b;
  double get ratio => b / a;

  _UnitRatio(this.a, this.b);
}

class Categories {
  static Future<void> addCategory(String name) async {
    // TODO: implement
  }

  static Future<List<String>> getCatagories() async {
    // TODO: implement
  }
}