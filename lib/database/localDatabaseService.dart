import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class LocalDatabaseService {
  static final LocalDatabaseService instance =
      LocalDatabaseService._privateConstructor();
  static Database? _database;

  LocalDatabaseService._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'health_app.db');

    return await openDatabase(
      path,
      version: 9,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
  }

  Future<void> _onOpen(Database db) async {
    await _ensureProfileColumns(db);
  }

  Future<void> _ensureProfileColumns(Database db) async {
    final columns = await db.rawQuery('PRAGMA table_info(profiles)');
    final columnNames = columns
        .map((column) => column['name'] as String)
        .toSet();

    if (!columnNames.contains('smoking_status')) {
      await db.execute('ALTER TABLE profiles ADD COLUMN smoking_status TEXT');
    }
    if (!columnNames.contains('alcohol_consumption')) {
      await db.execute(
        'ALTER TABLE profiles ADD COLUMN alcohol_consumption TEXT',
      );
    }
    if (!columnNames.contains('sex')) {
      await db.execute('ALTER TABLE profiles ADD COLUMN sex TEXT');
    }
    if (!columnNames.contains('sync_status')) {
      await db.execute(
        'ALTER TABLE profiles ADD COLUMN sync_status INTEGER DEFAULT 0',
      );
    }
  }

  Future _onCreate(Database db, int version) async {
    // Profiles (users) table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cloud_id INTEGER,
        username TEXT NOT NULL UNIQUE,
        nickname TEXT,
        password TEXT NOT NULL,
        function TEXT,
        address TEXT,
        dob TEXT,
        sex TEXT,
        first_diagnosis_date TEXT,
        smoking_status TEXT,
        alcohol_consumption TEXT,
        created_at TEXT,
        sync_status INTEGER DEFAULT 0
      )
    ''');

    // Bloodpressure table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bloodpressure (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cloud_id INTEGER,
        userid INTEGER NOT NULL,
        systolic INTEGER NOT NULL,
        diastolic INTEGER NOT NULL,
        pulse INTEGER,
        note TEXT,
        date_taken_on TEXT,
        time_taken_on TEXT,
        sync_status INTEGER DEFAULT 0,
        FOREIGN KEY (userid) REFERENCES profiles (id)
      )
    ''');

    // Bloodsugar table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bloodsugar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cloud_id INTEGER,
        userid INTEGER NOT NULL,
        type_measurement TEXT,
        meal_relation TEXT,
        level REAL NOT NULL,
        date_taken_on TEXT,
        time_taken_on TEXT,
        note TEXT,
        unit TEXT,
        sync_status INTEGER DEFAULT 0,
        FOREIGN KEY (userid) REFERENCES profiles (id)
      )
    ''');

    // Food intake table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS food_intake (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cloud_id INTEGER,
        userid INTEGER NOT NULL,
        food_description TEXT NOT NULL,
        quantity INTEGER,
        calories INTEGER,
        meal_type TEXT,
        intake_date TEXT NOT NULL,
        intake_time TEXT,
        note TEXT,
        sync_status INTEGER DEFAULT 0,
        FOREIGN KEY (userid) REFERENCES profiles (id)
      )
    ''');

    // Physical activity table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS physical_activity (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cloud_id INTEGER,
        userid INTEGER NOT NULL,
        exercise_type TEXT NOT NULL,
        intensity_level TEXT,
        duration_minutes INTEGER NOT NULL,
        exercise_time TEXT NOT NULL,
        calories_burned INTEGER,
        exercise_date TEXT NOT NULL,
        note TEXT,
        sync_status INTEGER DEFAULT 0,
        FOREIGN KEY (userid) REFERENCES profiles (id)
      )
    ''');

    // Medication prescriptions table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS medication_prescriptions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cloud_id INTEGER,
        userid INTEGER NOT NULL,
        medication_name TEXT NOT NULL,
        medication_type TEXT NOT NULL,
        dosage TEXT NOT NULL,
        frequency INTEGER NOT NULL,
        note TEXT,
        active INTEGER DEFAULT 1,
        sync_status INTEGER DEFAULT 0,
        FOREIGN KEY (userid) REFERENCES profiles (id)
      )
    ''');

    // Medication intake table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS medication_intake (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cloud_id INTEGER,
        userid INTEGER NOT NULL,
        medication_id INTEGER NOT NULL,
        dosage_taken TEXT NOT NULL,
        session TEXT NOT NULL,
        intake_date TEXT NOT NULL,
        intake_time TEXT NOT NULL,
        note TEXT,
        sync_status INTEGER DEFAULT 0,
        FOREIGN KEY (userid) REFERENCES profiles (id),
        FOREIGN KEY (medication_id) REFERENCES medication_prescriptions (id)
      )
    ''');

    // Appointments table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS appointments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cloud_id INTEGER,
        userid INTEGER NOT NULL,
        appointment_with TEXT NOT NULL,
        appointment_type TEXT NOT NULL,
        appointment_date TEXT NOT NULL,
        appointment_status TEXT NOT NULL,
        appointment_outcome TEXT,
        sync_status INTEGER DEFAULT 0,
        FOREIGN KEY (userid) REFERENCES profiles (id)
      )
    ''');

    // Body measurements (height/weight/BMI) table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS body_measurements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cloud_id INTEGER,
        userid INTEGER NOT NULL,
        height_cm REAL NOT NULL,
        weight_kg REAL NOT NULL,
        bmi REAL NOT NULL,
        measurement_date TEXT NOT NULL,
        measurement_time TEXT NOT NULL,
        note TEXT,
        sync_status INTEGER DEFAULT 0,
        FOREIGN KEY (userid) REFERENCES profiles (id)
      )
    ''');

    // Symptoms table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS symptoms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cloud_id INTEGER,
        userid INTEGER NOT NULL,
        symptom_name TEXT NOT NULL,
        severity INTEGER,
        note TEXT,
        recorded_date TEXT,
        recorded_time TEXT,
        sync_status INTEGER DEFAULT 0,
        FOREIGN KEY (userid) REFERENCES profiles (id)
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      // Add first_diagnosis_date to profiles
      try {
        await db.execute(
          'ALTER TABLE profiles ADD COLUMN first_diagnosis_date TEXT',
        );
      } catch (e) {
        // Ignore if column already exists
      }
      // Create body_measurements table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS body_measurements (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cloud_id INTEGER,
          userid INTEGER NOT NULL,
          height_cm REAL NOT NULL,
          weight_kg REAL NOT NULL,
          bmi REAL NOT NULL,
          measurement_date TEXT NOT NULL,
          measurement_time TEXT NOT NULL,
          note TEXT,
          sync_status INTEGER DEFAULT 0,
          FOREIGN KEY (userid) REFERENCES profiles (id)
        )
      ''');
    }
    if (oldVersion < 6) {
      // Recreate all tables with sync_status
      await db.execute('DROP TABLE IF EXISTS bloodpressure');
      await db.execute('DROP TABLE IF EXISTS bloodsugar');
      await db.execute('DROP TABLE IF EXISTS food_intake');
      await db.execute('DROP TABLE IF EXISTS physical_activity');
      await db.execute('DROP TABLE IF EXISTS medication_prescriptions');
      await db.execute('DROP TABLE IF EXISTS medication_intake');
      await db.execute('DROP TABLE IF EXISTS appointments');
      await db.execute('DROP TABLE IF EXISTS body_measurements');

      // Bloodpressure table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS bloodpressure (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cloud_id INTEGER,
          userid INTEGER NOT NULL,
          systolic INTEGER NOT NULL,
          diastolic INTEGER NOT NULL,
          pulse INTEGER,
          note TEXT,
          date_taken_on TEXT,
          time_taken_on TEXT,
          sync_status INTEGER DEFAULT 0,
          FOREIGN KEY (userid) REFERENCES profiles (id)
        )
      ''');

      // Bloodsugar table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS bloodsugar (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cloud_id INTEGER,
          userid INTEGER NOT NULL,
          type_measurement TEXT,
          meal_relation TEXT,
          level REAL NOT NULL,
          date_taken_on TEXT,
          time_taken_on TEXT,
          note TEXT,
          unit TEXT,
          sync_status INTEGER DEFAULT 0,
          FOREIGN KEY (userid) REFERENCES profiles (id)
        )
      ''');

      // Food intake table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS food_intake (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cloud_id INTEGER,
          userid INTEGER NOT NULL,
          food_description TEXT NOT NULL,
          quantity INTEGER,
          calories INTEGER,
          meal_type TEXT,
          intake_date TEXT NOT NULL,
          intake_time TEXT,
          note TEXT,
          sync_status INTEGER DEFAULT 0,
          FOREIGN KEY (userid) REFERENCES profiles (id)
        )
      ''');

      // Physical activity table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS physical_activity (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cloud_id INTEGER,
          userid INTEGER NOT NULL,
          exercise_type TEXT NOT NULL,
          intensity_level TEXT,
          duration_minutes INTEGER NOT NULL,
          exercise_time TEXT NOT NULL,
          calories_burned INTEGER,
          exercise_date TEXT NOT NULL,
          note TEXT,
          sync_status INTEGER DEFAULT 0,
          FOREIGN KEY (userid) REFERENCES profiles (id)
        )
      ''');

      // Medication prescriptions table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS medication_prescriptions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cloud_id INTEGER,
          userid INTEGER NOT NULL,
          medication_name TEXT NOT NULL,
          medication_type TEXT NOT NULL,
          dosage TEXT NOT NULL,
          frequency INTEGER NOT NULL,
          note TEXT,
          active INTEGER DEFAULT 1,
          sync_status INTEGER DEFAULT 0,
          FOREIGN KEY (userid) REFERENCES profiles (id)
        )
      ''');

      // Medication intake table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS medication_intake (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cloud_id INTEGER,
          userid INTEGER NOT NULL,
          medication_id INTEGER NOT NULL,
          dosage_taken TEXT NOT NULL,
          session TEXT NOT NULL,
          intake_date TEXT NOT NULL,
          intake_time TEXT NOT NULL,
          note TEXT,
          sync_status INTEGER DEFAULT 0,
          FOREIGN KEY (userid) REFERENCES profiles (id),
          FOREIGN KEY (medication_id) REFERENCES medication_prescriptions (id)
        )
      ''');

      // Appointments table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS appointments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cloud_id INTEGER,
          userid INTEGER NOT NULL,
          appointment_with TEXT NOT NULL,
          appointment_type TEXT NOT NULL,
          appointment_date TEXT NOT NULL,
          appointment_status TEXT NOT NULL,
          appointment_outcome TEXT,
          sync_status INTEGER DEFAULT 0,
          FOREIGN KEY (userid) REFERENCES profiles (id)
        )
      ''');

      // Body measurements (height/weight/BMI) table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS body_measurements (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cloud_id INTEGER,
          userid INTEGER NOT NULL,
          height_cm REAL NOT NULL,
          weight_kg REAL NOT NULL,
          bmi REAL NOT NULL,
          measurement_date TEXT NOT NULL,
          measurement_time TEXT NOT NULL,
          note TEXT,
          sync_status INTEGER DEFAULT 0,
          FOREIGN KEY (userid) REFERENCES profiles (id)
        )
      ''');
    }
    if (oldVersion < 7) {
      try {
        await db.execute('ALTER TABLE profiles ADD COLUMN smoking_status TEXT');
      } catch (_) {}
      try {
        await db.execute(
          'ALTER TABLE profiles ADD COLUMN alcohol_consumption TEXT',
        );
      } catch (_) {}
    }
    if (oldVersion < 8) {
      try {
        await db.execute('ALTER TABLE profiles ADD COLUMN sex TEXT');
      } catch (_) {}
    }
    if (oldVersion < 9) {
      // Add symptoms table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS symptoms (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cloud_id INTEGER,
          userid INTEGER NOT NULL,
          symptom_name TEXT NOT NULL,
          severity INTEGER,
          note TEXT,
          recorded_date TEXT,
          recorded_time TEXT,
          sync_status INTEGER DEFAULT 0,
          FOREIGN KEY (userid) REFERENCES profiles (id)
        )
      ''');
    }
  }

  // Helper methods for CRUD operations
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
