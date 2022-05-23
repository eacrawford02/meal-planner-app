import 'package:meal_planner_app/utils.dart';
import 'package:sqflite/sqflite.dart';

class FoodItem {
  static const String grams = "g";
  static const String cup = "cup";
  static const String cups = "cups";
  static const String millilitres = "mL";
  static const String teaspoons = "tsp";
  static const String tablespoons = "tbsp";
  String name; // Not null
  String category;
  // Nutrition information variables (per serving size unit A (metric))
  Map<String, Nutrient> _nutrients = Nutrient.nutrients();
  // Packaged amounts of the chosen food item (metric ONLY)
  int packageSize;
  String packageUnits; // Can ONLY be either grams or millilitres
  // Standard metric conversions for liquids
  final _UnitRatio _cupRatio = _UnitRatio(250, millilitres, 1, cup); // 1 cup = 250 mL
  final _UnitRatio _tspRatio = _UnitRatio(5, millilitres, 1, teaspoons); // 1 tsp = 5 mL
  final _UnitRatio _tbspRatio = _UnitRatio(15, millilitres, 1, tablespoons); // 1 tbsp = 15 mL
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
    List<String> items = [];
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
  void setServingSize(double amountA, String unitA, double amountB,
      String unitB) {
    // Ensure that unitA is in metric units and unitB in non-metric to maintain
    // correct ratio representation when performing conversion
    List<String> metricUnits = [grams, millilitres];
    List<String> nonMetricUnits = [cup, cup, teaspoons, tablespoons];
    // Ensure that unitA and unitB are different
    if ((metricUnits.contains(unitA) && metricUnits.contains(unitB)) ||
        (nonMetricUnits.contains(unitA) && nonMetricUnits.contains(unitB))) {
      throw Exception("Error: units A ('$unitA') and B ('$unitB') must be "
          "different");
    }
    // Store serving size information in UnitRatio object with the metric amount
    // held in the 'a' field and the non-metric amount held in the 'b' field. If
    // either measurement amount is negative or zero, set to default null val
    if (metricUnits.contains(unitA)) {
      _servingRatio = _UnitRatio(
        amountA <= 0 ? null : amountA,
        unitA,
        amountB <= 0 ? null : amountB,
        unitB
      );
    }
    else if (nonMetricUnits.contains(unitA)) {
      _servingRatio = _UnitRatio(
        amountB <= 0 ? null : amountB,
        unitB,
        amountA <= 0 ? null : amountA,
        unitA
      );
    }
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

  /// Returns the amount of a specific nutrient in a given portion size of this
  /// food item.
  int convertAmount(String nutrient, double portionSize, String measurementUnit) {
    // Check if 'measurementUnit' is one of the serving size units
    if (measurementUnit == _servingRatio.unitA) {
      // i.e., tbsp * cal/tbsp = cal
      return portionSize * _nutrients[nutrient].amount ~/ _servingRatio.a;
    }
    else if (measurementUnit == _servingRatio.unitB) {
      return portionSize * _nutrients[nutrient].amount ~/ _servingRatio.b;
    }
    else {
      // Perform conversion
      // Nutrient density of this FoodItem; the amount of 'nutrient' per serving
      // size
      _UnitRatio nDensity = _UnitRatio(
        (_nutrients[nutrient].amount).toDouble(),
        _nutrients[nutrient].unit,
        _servingRatio.a,
        _servingRatio.unitA
      );
      return (_convert(portionSize, measurementUnit, nDensity)).toInt();
    }
  }

  /// Converts from unit 'unit' to the target unit given in 'ratio'. In the
  /// example conversion below, the initial argument for 'ratio' is cal/g:
  ///
  /// tbsp * mL/tbsp * cups/mL * g/cups * cal/g = cal
  ///
  /// Here, the serving ratio is g/cups.
  ///
  /// Throws exception if target unit cannot be reached.
  double _convert(double amount, String unit, _UnitRatio ratio) {
    _UnitRatio lRatio; // i.e., mL/tbsp
    _UnitRatio rRatio; // i.e., cups/mL
    if (unit != grams && unit != millilitres) {
      lRatio = _filterUnit(unit);
    }
    else {
      // Since lRatio.unitB is never referenced, we can initialize it to null.
      // Initializing lRatio.b to 1 ensures that calling lRatio.ab returns
      // amount
      lRatio = _UnitRatio(1, unit, 1, null);
    }
    if (lRatio.unitA == _servingRatio.unitA) {
      // In this case, we end up with an expression like:
      // tbsp * mL/tbsp * mL/cups * cal/mL
      // and thus we drop the serving ratio term to get
      // tbsp * mL/tbsp * cal/mL
      return amount * lRatio.ab * ratio.ab;
    }
    else {
      rRatio = _filterUnit(_servingRatio.unitB);
      if (rRatio.unitA == lRatio.unitA) {
        return amount * lRatio.ab * rRatio.ba * _servingRatio.ab * ratio.ab;
      }
      else {
        throw Exception("Could not convert from $unit to ${ratio.unitB}");
      }
    }
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
    List<String> categories = [];
    for (var row in rows) {
      categories.add(row["name"]);
    }
    return categories;
  }
}