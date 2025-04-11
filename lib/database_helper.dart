import 'package:libsql_dart/libsql_dart.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static LibsqlClient? _database;

  DatabaseHelper._init();

  Future<LibsqlClient> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDb();
    return _database!;
  }

  Future<LibsqlClient> _initializeDb() async {
    final dir = await getApplicationCacheDirectory();
    final path = '${dir.path}/local.db';

    // --- IMPORTANT ---
    // Replace with your actual Turso/LibSQL URL and Auth Token
    const syncUrl = String.fromEnvironment("TURSO_DATABASE_URL");
    const authToken = String.fromEnvironment("TURSO_AUTH_TOKEN");

    final client =
        LibsqlClient(path)
          ..authToken = authToken
          ..syncUrl = syncUrl
          ..syncIntervalSeconds =
              5 // Or your desired sync interval
          ..readYourWrites = true;

    await client.connect();
    // You might want to run schema creation here if the DB is new
    // await _ensureSchema(client);
    return client;
  }

  // Insert a checkout record, or return it if it exists
  // Returns (bool, int) where the bool is whether the record was created
  // and int is the id.
  Future<(bool, int)> insertCheckout(String workId, String userIdString) async {
    final db = await instance.database;
    final now = DateTime.now().toIso8601String();

    final int? userId = int.tryParse(userIdString);
    if (userId == null) {
      throw "invalid user id";
    }

    final query = await db.prepare(
      'select * from checkouts where work_id = ? AND user_id = ? AND return_timestamp IS NULL',
    );
    final List<Map<String, dynamic>> existingCheckouts = await query.query(
      positional: [workId, userId],
    );

    if (existingCheckouts.isNotEmpty) {
      final query = await db.prepare(
        'update checkouts set return_timestamp = "$now" where work_id = ? AND user_id = ? AND return_timestamp IS NULL',
      );
      await query.query(positional: [workId, userId]);

      final id = existingCheckouts.first["checkout_id"];

      if (id is int) {
        return (false, id);
      } else {
        throw "invalid checkout id type";
      }
    }

    final id = await db.execute(
      'insert into checkouts (work_id, user_id, checkout_timestamp, return_timestamp) values ("$workId", $userId, "$now", null)',
    );
    print(
      "Inserted checkout record with ID: $id for Work: $workId, User: $userId",
    );
    return (true, id);
  }

  // Add other methods here later if needed (e.g., fetchCheckouts, returnItem)

  Future dispose() async {
    final db = await instance.database;
    await db.dispose();
  }
}
