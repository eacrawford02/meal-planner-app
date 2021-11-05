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
  Map<String, Nutrient> nutrients = Nutrient.nutrients();
  // Packaged amounts of the chosen food item (metric)
  int packageSize = 0;
  int servingSize = 0;
  String packageUnits = grams;
  // Default metric conversions for liquids
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
          Nutrient.calories : nutrients[Nutrient.calories].amount
        },
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  // measurement is given in non-metric units (measurementUnit)
  // equivMeasurement is given in metric units
  void setRatio(double measurement, String measurementUnit,
      double equivMeasurement) {
    _UnitRatio ratioUnit = _filterUnit(measurementUnit);
    ratioUnit.a = measurement;
    ratioUnit.b = equivMeasurement;
  }

  int getAmount(Nutrient nutrient, double portionSize, String measurementUnit) {
    _UnitRatio ratioUnit = _filterUnit(measurementUnit);
    double ratio = nutrient.amount / servingSize;
    return (portionSize * ratioUnit.ratio * ratio).round();
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
      nutrients[Nutrient.calories].amount = rows[i][Nutrient.calories];
    }
  }

  _UnitRatio _filterUnit(String unit) {
    if (unit == cup || unit == cups) {
      return _cupRatio;
    }
    else if (unit == teaspoons) {
      return _tspRatio;
    }
    else if (unit == tablespoons) {
      return _tbspRatio;
    }
    else {
      throw Exception("Invalid measurement unit: $unit");
    }
  }
}

class Nutrient {
  static const String calories = "Calories";
  // TODO: add more

  static Map<String, Nutrient> _nutrients = {
    calories: Nutrient(calories, 0, "kcal") // TODO: add more
  };

  static Map<String, Nutrient> nutrients() => _nutrients;

  String name;
  int amount;
  String unit;

  Nutrient(this.name, this.amount, [this.unit]) {
    if (unit == null) {
      unit = _nutrients[name].unit;
    }
  }
}

class _UnitRatio {
  double a;
  double b;
  double get ratio => b / a;

  _UnitRatio(this.a, this.b);
}

// Stores a list of food item categories as strings in a single-column SQL table
class Categories {
  static Future<void> addCategory(String name) async {
    final Database db = await Utils.getDatabase();
    await db.insert(
        "categories",
        {
          "name" : name
        },
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  static Future<List<String>> getCategories() async {
    final Database db = await Utils.getDatabase();
    List<Map<String, dynamic>> rows;
    try {
      rows = await db.query("categories");
    }
    on DatabaseException {
      rows = List.empty();
    }
    List<String> categories;
    for (var row in rows) {
      categories.add(row["name"]);
    }
    return categories;
  }
}