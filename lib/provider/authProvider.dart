import 'package:bcrypt/bcrypt.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthapp/database/databaseService.dart';
import 'package:postgres/postgres.dart';

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<User?> {
  AuthNotifier() : super(null);
  bool get isAuthenticated => state != null;
  Future<Map<String, dynamic>?> authenticateUser(
    String username,
    String password,
  ) async {
    try {
      Connection? con = await DatabaseService().openConnection();
      if (con != null) {
        final result = await con.execute(
          Sql.named(
            'SELECT * FROM health_db.profiles WHERE username = @username',
          ),
          parameters: {'username': username},
        );

        if (result.isNotEmpty) {
          final row = result[0];
          final storedHashedPassword = row[5] as String;

          if (verifyPassword(password, storedHashedPassword)) {
            final user = User(
              id: row[0] as int,
              username: row[1] as String,
              nickname: row[2] as String,
              function: row[6] as String,
              address: row[3] as String,
              birthdate: row[7] as DateTime,
            );
            state = user;
            return {'success': true, 'user': user};
          } else {
            return {'success': false, 'error': 'Invalid password'};
          }
        } else {
          return {'success': false, 'error': 'User not found'};
        }
      } else {
        throw Exception('Database connection failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    state = null;
  }

  static bool verifyPassword(String plainTextPassword, String hashedPassword) {
    return BCrypt.checkpw(plainTextPassword, hashedPassword);
  }
}

class User {
  int id;
  String username;
  String nickname;
  String function;
  String address;
  DateTime birthdate;
  User({
    required this.id,
    required this.username,
    required this.nickname,
    required this.function,
    required this.address,
    required this.birthdate,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      nickname: json['nickname'],
      function: json['function'],
      address: json['address'],
      birthdate: json['birthdate'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nickname': nickname,
      'function': function,
      'address': address,
      'birthdate': birthdate,
    };
  }
}
