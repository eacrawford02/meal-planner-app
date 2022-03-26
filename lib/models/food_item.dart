import 'package:meal_planner_app/utils.dart';
import 'package:sqflite/sqflite.dart';

class FoodItem {
  static const String grams = "g";
  static const String cup = "cup";
  static const String cups = "cups";
  static const String millilitres = "mL";
  static const String teaspoons = "tsp";
  static const String tablespoons = "tbsp";
  String name;
  String category;
  // Nutrition information variables (per serving size unit A (metric))
  Map<String, Nutrient> _nutrients = Nutrient.nutrients();
  // Packaged amounts of the chosen food item (metric ONLY)
  int packageSize;
  String packageUnits; // Can ONLY be either grams or millilitres
  // Standard metric conversions for liquids
  final _UnitRatio _cupRatio = _UnitRatio(1, cup, 250, millilitres); // 1 cup = 250 mL
  final _UnitRatio _tspRatio = _UnitRatio(1, cup, 5, millilitres); // 1 tsp = 5 mL
  final _UnitRatio _tbspRatio = _UnitRatio(1, cup, 15, millilitres); // 1 tsp = 15 mL
  // Serving size ratio
  _UnitRatio _servingRatio = _UnitRatio();

  // Upon instantiation of a previously saved FoodItem object, instance members
  // cannot be safely read until 'loading' completes; however, these members
  // can be safely written to at any time. New (unsaved) FoodItem objects do
  // not need to wait for the completion of 'loading'
  FoodItem({
    this.name = "Unnamed Food Item",
    this.category = "", // TODO: change default value(?)
    this.packageSize = 0,
    this.packageUnits = grams
  });

  // Returns all food items stored in database
  static Future<List<String>> getAll() async {
    final Database db = await Utils.getDatabase();
    List<Map<String, dynamic>> rows = await db.query(
      "food_items",
      columns: ["name"]
    );
    List<String> items;
    for (var row in rows) {
      items.add(row["name"]);
    }
    return items;
  }

  static Future<void> delete(String name) async {
    final Database db = await Utils.getDatabase();
    await db.delete(
      "food_items",
      where: "name = ?",
      whereArgs: [name]
    );
  }

  Future<void> save() async {
    final Database db = await Utils.getDatabase();
    await db.insert(
        "food_items",
        {
          "name" : name,
          "category" : category,
          "packageSize" : packageSize,
          "servingSizeA" : _servingRatio.a,
          "servingSizeB" : _servingRatio.b,
          "packageUnits" : packageUnits,
          "servingUnitsA" : _servingRatio.unitA,
          "servingUnitsB" : _servingRatio.unitB,
          Nutrient.calories : _nutrients[Nutrient.calories].amount
        },
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  // Sets the serving size of the FoodItem as the ratio of a non-metric unit
  // (cups, tbsp, tsp) to a metric unit (g, mL), given by the nutrition label
  //
  // 'measurement' is given in non-metric units (measurementUnit)
  // 'equivMeasurement' is given in metric units (metricUnit)
  void setServingSize(double measurement, String measurementUnit,
      double equivMeasurement, String metricUnit) {
    // Ensure that unitA is in metric units and unitB in non-metric to maintain
    // correct ratio representation when performing conversion
    if (measurementUnit == grams || measurementUnit == millilitres) {
      throw Exception("Error: incorrect unit '$measurementUnit' supplied to "
          "non-metric serving size of FoodItem '$name'");
    }
    if (metricUnit != grams || metricUnit != millilitres) {
      throw Exception("Error: incorrect unit '$metricUnit' supplied to "
          "metric serving size of FoodItem '$name'");
    }
    // If either measurement amount is negative or zero, set to default null val
    _servingRatio = _UnitRatio(
      equivMeasurement <= 0 ? null : equivMeasurement,
      metricUnit,
      measurement <= 0 ? null : measurement,
      measurementUnit
    );
  }

  double getServingSize(bool metric) {
    return metric ? _servingRatio.a : _servingRatio.b;
  }

  String getServingUnit(bool metric) {
    return metric ? _servingRatio.unitA : _servingRatio.unitB;
  }

  // Sets the total amount of a specific nutrient in the serving size of this
  // food item
  void setAmount(String nutrient, int amount) {
    _nutrients[nutrient].amount = amount;
  }

  int getAmount(String nutrient) {
    return _nutrients[nutrient].amount;
  }

  // Returns the amount of a specific nutrient in a given portion size of this
  // food item
  // 'portionSize' is given in non-metric units (measurementUnit), i.e., the
  // amount of an ingredient that a recipe calls for
  int convertAmount(String nutrient, double portionSize, String measurementUnit) {
    // Nutrient density of this FoodItem; the amount of 'nutrient' per serving
    // size
    _UnitRatio nDensity = _UnitRatio(
      (_nutrients[nutrient].amount).toDouble(),
      _nutrients[_nutrients].unit,
      _servingRatio.a,
      _servingRatio.unitA
    );
    return (_convert(portionSize, measurementUnit, nDensity)).toInt();
  }

  // Works backwards from the nutrient density of the food item to recursively
  // convert units using unit ratios until the target unit is reached. In the
  // example conversion below, the initial argument for 'ratio' is cal/g:
  //
  // tbsp * mL/tbsp * cups/mL * g/cups * cal/g = cal
  //
  // Here, the serving ratio is g/cups
  //
  // Throws exception if target unit cannot be reached.
  double _convert(double amount, String unit, _UnitRatio ratio,
      [bool flag = false]) {
    if (unit == ratio.unitB) {
      // Handles start-of-chain case where 'unit' is of the same units as the
      // denominator of the food item's nutrient density (either g or mL)
      return amount * ratio.ab;
    }
    else if (unit == ratio.unitA) {
      // Handles end-of-chain case where 'unit' is of the same units as the
      // numerator of the standard unit conversion returned by '_filterUnit()'
      // (one of the non-metric units; cups, tsp, tbsp)
      return amount * ratio.ba;
    }
    _UnitRatio nextRatio;
    // A metric denominator may occur twice in the conversion expression.
    // 'flag' tracks whether or not to use the serving ratio (first occurrence)
    // or one of the standard unit conversions (second occurrence)
    if ((ratio.unitB == grams || ratio.unitB == millilitres) && !flag) {
      nextRatio = _servingRatio;
      flag = true;
    }
    else if ((ratio.unitB == grams || ratio.unitB == millilitres) && flag) {
      nextRatio = _filterUnit(unit);
    }
    else {
      nextRatio = _filterUnit(ratio.unitB);
    }
    return _convert(amount, unit, nextRatio, flag) * ratio.ab;
  }

  Future<void> loadData() async {
    // TODO: prevent overwriting fields due to async execution of function
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
    // TODO: remove loop, replace i with 0
    for (int i = 0; i < rows.length; i++) {
      name = rows[i]["name"];
      category = rows[i]["category"];
      packageSize = rows[i]["packageSize"];
      _servingRatio.a = rows[i]["servingSizeA"];
      _servingRatio.b = rows[i]["servingSizeB"];
      packageUnits = rows[i]["packageUnits"];
      _servingRatio.unitA = rows[i]["servingUnitsA"];
      _servingRatio.unitB = rows[i]["servingUnitsB"];
      _nutrients[Nutrient.calories].amount = rows[i][Nutrient.calories];
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

  static final Map<String, Nutrient> _nutrients = {
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

// Represents the ratio between two numbers, a and b
class _UnitRatio {
  double a;
  double b;
  String unitA;
  String unitB;
  double get ab => a / b;
  double get ba => b / a;

  _UnitRatio([this.a, this.unitA, this.b, this.unitB]);
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