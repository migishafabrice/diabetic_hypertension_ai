import 'package:flutter_test/flutter_test.dart';
import 'package:diacare/models/local_user.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('insert user with lifestyle fields into profiles table', () async {
    final db = await openDatabase(
      inMemoryDatabasePath,
      version: 7,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE profiles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cloud_id INTEGER,
            username TEXT NOT NULL UNIQUE,
            nickname TEXT,
            password TEXT NOT NULL,
            function TEXT,
            address TEXT,
            dob TEXT,
            first_diagnosis_date TEXT,
            smoking_status TEXT,
            alcohol_consumption TEXT,
            sex TEXT,
            created_at TEXT,
            sync_status INTEGER DEFAULT 0
          )
        ''');
      },
    );

    final user = LocalUser(
      username: 'test@example.com',
      password: 'hashed',
      nickname: 'Test User',
      smokingStatus: 'Never Smoked',
      alcoholConsumption: 'Occasionally',
      sex: 'Female',
      createdAt: DateTime.now().toIso8601String(),
    );

    final id = await db.insert('profiles', user.toMap());
    expect(id, greaterThan(0));

    final rows = await db.query('profiles', where: 'id = ?', whereArgs: [id]);
    expect(rows.first['smoking_status'], 'Never Smoked');
    expect(rows.first['alcohol_consumption'], 'Occasionally');
    expect(rows.first['sex'], 'Female');
    expect(rows.first['sync_status'], 0);

    await db.close();
  });
}
