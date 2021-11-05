import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
              " category TEXT, packageSize INTEGER, servingSize INTEGER,"
              " packageUnits TEXT, calories INTEGER)"
          );
          await db.execute("CREATE TABLE categories(name TEXT PRIMARY KEY)");
        }
      );
    }
    return _database;
  }
}