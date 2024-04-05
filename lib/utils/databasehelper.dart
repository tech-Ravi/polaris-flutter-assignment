import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  static Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'form_data.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE form_data(form_name TEXT PRIMARY KEY, fields_data TEXT)",
        );
      },
    );
  }

  static Future<void> insertFormData(
      Map<String, dynamic> formData, BuildContext context) async {
    final db = await database;
    await db.insert(
      'form_data',
      formData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    //print('Data saved to local DB!!' + db.toString());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Data saved to local Database!!"),
    ));
  }

  static Future<Map<String, dynamic>?> getFormData(String formName) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'form_data',
      where: 'form_name = ?',
      whereArgs: [formName],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }
}
