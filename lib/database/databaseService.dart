import 'dart:async';
import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DatabaseService {
  final String _host = dotenv.get('DB_HOST');
  final String _dbName = dotenv.get('DB_NAME');
  final String _username = dotenv.get('DB_USERNAME');
  final String _password = dotenv.get('DB_PASSWORD');

  Future<Connection?> openConnection() async {
    final conn = await Connection.open(
      Endpoint(
        host: _host,
        database: _dbName,
        username: _username,
        password: _password,
        // port: _port,
      ),
      settings: ConnectionSettings(sslMode: SslMode.require),
    );
    return conn;
  }
}
