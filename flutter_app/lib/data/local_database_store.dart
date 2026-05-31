import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

/// SQLite store prepared for the next local-storage migration.
///
/// The production app can move from SharedPreferences JSON blobs to this store
/// for large wardrobes, indexing and offline-first sync. It is intentionally
/// isolated so current MVP storage remains stable until Flutter QA is run.
class LocalDatabaseStore {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final base = await getDatabasesPath();
    final path = p.join(base, 'bharatfit_local.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE wardrobe_items (
            item_id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            item_json TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute('CREATE INDEX idx_local_wardrobe_user ON wardrobe_items(user_id)');
        await db.execute('''
          CREATE TABLE outfit_history (
            outfit_id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            outfit_json TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('CREATE INDEX idx_local_outfits_user ON outfit_history(user_id)');
      },
    );
    return _db!;
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) await db.close();
    _db = null;
  }
}
