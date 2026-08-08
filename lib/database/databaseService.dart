import 'dart:async';
import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DatabaseService {
  late final String _host;
  late final String _dbName;
  late final String _username;
  late final String _password;

  DatabaseService() {
    _host = dotenv.maybeGet('DB_HOST') ?? 'localhost';
    _dbName = dotenv.maybeGet('DB_NAME') ?? 'health_db';
    _username = dotenv.maybeGet('DB_USERNAME') ?? 'postgres';
    _password = dotenv.maybeGet('DB_PASSWORD') ?? '';
  }

  Future<Connection?> openConnection() async {
    try {
      final conn = await Connection.open(
        Endpoint(
          host: _host,
          database: _dbName,
          username: _username,
          password: _password,
          // port: _port,
        ),
        settings: ConnectionSettings(sslMode: SslMode.disable),
      );
      return conn;
    } catch (e) {
      print('Database connection failed: $e');
      return null;
    }
  }
}
