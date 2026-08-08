import 'package:sqflite/sqflite.dart';
import '../models/local_user.dart';
import 'localDatabaseService.dart';

class UserDao {
  final LocalDatabaseService _dbService = LocalDatabaseService.instance;

  Future<int> insertUser(LocalUser user) async {
    final db = await _dbService.database;
    final data = Map<String, dynamic>.from(user.toMap())..remove('id');
    return await db.insert(
      'profiles',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LocalUser>> getAllUsers() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query('profiles');
    return List.generate(maps.length, (i) => LocalUser.fromMap(maps[i]));
  }

  Future<LocalUser?> getUserByUsername(String username) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'profiles',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return LocalUser.fromMap(maps.first);
    }
    return null;
  }

  Future<LocalUser?> getUserById(int id) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'profiles',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return LocalUser.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(LocalUser user) async {
    final db = await _dbService.database;
    final data = Map<String, dynamic>.from(user.toMap())..remove('id');
    return await db.update(
      'profiles',
      data,
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await _dbService.database;
    return await db.delete('profiles', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<LocalUser>> getUnsyncedUsers() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'profiles',
      where: 'sync_status = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) => LocalUser.fromMap(maps[i]));
  }
}
