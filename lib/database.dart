import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final directory = await getApplicationDocumentsDirectory();
    _database = await openDatabase(
      join(directory.path, 'myspool.db'),
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE filaments (
            id TEXT PRIMARY KEY,
            brand TEXT NOT NULL,
            name TEXT NOT NULL,
            material TEXT NOT NULL,
            color TEXT NOT NULL,
            weight REAL NOT NULL,
            remaining REAL NOT NULL,
            quantity INTEGER NOT NULL,
            diameter REAL NOT NULL,
            print_temperature TEXT NOT NULL,
            bed_temperature TEXT NOT NULL,
            notes TEXT NOT NULL,
            nfc_id TEXT,
            location TEXT NOT NULL DEFAULT '',
            purchase_date TEXT,
            price REAL,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE trash (
            id TEXT PRIMARY KEY,
            filament_json TEXT NOT NULL,
            moved_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE consumption (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            filament_id TEXT NOT NULL,
            grams REAL NOT NULL,
            reason TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE price_sources (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            filament_id TEXT NOT NULL,
            store TEXT NOT NULL,
            url TEXT NOT NULL,
            current_price REAL,
            currency TEXT NOT NULL DEFAULT 'EUR',
            target_price REAL,
            updated_at TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE price_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            source_id INTEGER NOT NULL,
            price REAL NOT NULL,
            recorded_at TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE price_sources (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              filament_id TEXT NOT NULL,
              store TEXT NOT NULL,
              url TEXT NOT NULL,
              current_price REAL,
              currency TEXT NOT NULL DEFAULT 'EUR',
              target_price REAL,
              updated_at TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE price_history (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              source_id INTEGER NOT NULL,
              price REAL NOT NULL,
              recorded_at TEXT NOT NULL
            )
          ''');
        }
      },
    );
    return _database!;
  }
}
