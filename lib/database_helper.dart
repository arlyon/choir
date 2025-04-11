import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('choir.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, filePath);
    // Note: onCreate is omitted here. We assume the schema.sql is executed
    // separately during app initialization or first run.
    // If you need to create tables here, add an onCreate callback.
    return await openDatabase(path, version: 1 /*, onCreate: _createDB */);
  }

  /* Example onCreate if needed:
  Future _createDB(Database db, int version) async {
    // Read schema.sql and execute it
    // final String schemaSql = await rootBundle.loadString('assets/schema.sql'); // Requires assets setup
    // await db.execute(schemaSql); // Be careful executing multi-statement SQL like this
    // Or execute CREATE TABLE statements directly
    await db.execute('''
      CREATE TABLE checkouts (
          checkout_id INTEGER PRIMARY KEY AUTOINCREMENT,
          work_id TEXT NOT NULL,
          user_id INTEGER NOT NULL,
          checkout_timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
          return_timestamp DATETIME,
          FOREIGN KEY (work_id) REFERENCES works(work_id),
          FOREIGN KEY (user_id) REFERENCES users(user_id)
      );
    ''');
    // Add other table creations (works, users) if managing schema here
  }
  */

  // Insert a checkout record
  Future<int> insertCheckout(String workId, String userIdString) async {
    final db = await instance.database;
    // Ensure userId is an integer
    final int? userId = int.tryParse(userIdString);
    if (userId == null) {
      print("Error: Invalid User ID format '$userIdString'. Must be an integer.");
      // Consider throwing an exception or returning an error code
      return -1; // Indicate error
    }

    // Check if the item is already checked out (return_timestamp IS NULL)
    final List<Map<String, dynamic>> existingCheckouts = await db.query(
      'checkouts',
      where: 'work_id = ? AND return_timestamp IS NULL',
      whereArgs: [workId],
    );

    if (existingCheckouts.isNotEmpty) {
      print("Error: Work ID '$workId' is already checked out.");
      // Optionally, you could update the existing record or handle as a return+checkout
      // For now, we prevent duplicate checkouts
      return -2; // Indicate already checked out
    }


    final Map<String, dynamic> row = {
      'work_id': workId,
      'user_id': userId,
      'checkout_timestamp': DateTime.now().toIso8601String(), // Store as ISO8601 string
      'return_timestamp': null, // Explicitly set to null for checkout
    };
    final id = await db.insert('checkouts', row);
    print("Inserted checkout record with ID: $id for Work: $workId, User: $userId");
    return id;
  }

  // Add other methods here later if needed (e.g., fetchCheckouts, returnItem)

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}