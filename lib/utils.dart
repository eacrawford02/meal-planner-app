import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:fraction/fraction.dart';

class Utils {
  static const String placeholderImg = "assets/placeholder.png";

  static Future<Database> _database;

  static Future<Database> getDatabase() async {
    if (_database == null) {
      _database = openDatabase(
        // Set the path to the database
        join(await getDatabasesPath(), "app_database"),
        version: 1,
        // When the database is first created, create each table needed to store
        // the list's data
        onCreate: (db, version) async {
          await db.execute("CREATE TABLE recipes(name TEXT PRIMARY KEY,"
              " imagePath TEXT, time TEXT, servings INTEGER, ingredients TEXT,"
              " instructions TEXT)"
          );
          await db.execute("CREATE TABLE food_items(name TEXT PRIMARY KEY,"
              " category TEXT, packageSize INTEGER, servingSizeA REAL,"
              " servingUnitsA TEXT, servingSizeB REAL, servingUnitsB TEXT,"
              " packageUnits TEXT, calories INTEGER)"
          );
          await db.execute("CREATE TABLE categories(name TEXT PRIMARY KEY)");
        }
      );
    }
    return _database;
  }

  // Returns string representation of a double as a fraction, e.g.
  // 1.5 => "1 1/2" or 0.75 => "3/4", or the string given by 'def' if there is
  // none
  static String strFraction(double real, [String def = ""]) {
    if (real == null) {
      return def;
    }
    Fraction fraction = Fraction.fromDouble(real);
    if (fraction.isWhole) {
      return fraction.numerator.toString();
    }
    else if (fraction.isImproper) {
      return fraction.toMixedFraction().toString();
    }
    else {
      return fraction.toString();
    }
  }

  // Returns the whole number of a fraction given by a double, or the string
  // given by 'def' if there is none
  static String strWhole(double real, [String def = ""]) {
    if (real == null) {
      return def;
    }
    Fraction fraction = Fraction.fromDouble(real);
    if (fraction.isImproper) {
      return fraction.toMixedFraction().whole.toString();
    }
    else if (fraction.isWhole) {
      return fraction.numerator.toString();
    }
    else {
      return def;
    }
  }

  // Returns the numerator of a fraction given by a double, or the string given
  // by 'def' if the fraction is whole. If improper, returns the mixed fraction
  // minus the whole number
  static String strNumerator(double real, [String def = ""]) {
    if (real == null) {
      return def;
    }
    Fraction fraction = Fraction.fromDouble(real);
    if (!fraction.isWhole) {
      if (fraction.isImproper) {
        return fraction.toMixedFraction().numerator.toString();
      }
      else {
        return fraction.numerator.toString();
      }
    }
    else {
      return def;
    }
  }

  // Returns the denominator of a fraction given by a double, or the string
  // given by 'def' if the fraction is whole
  static String strDenominator(double real, [String def = ""]) {
    if (real == null) {
      return def;
    }
    Fraction fraction = Fraction.fromDouble(real);
    if (!fraction.isWhole) {
      return fraction.denominator.toString();
    }
    else {
      return def;
    }
  }
}