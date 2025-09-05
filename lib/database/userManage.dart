import 'package:bcrypt/bcrypt.dart';
import 'package:healthapp/database/databaseService.dart';
import 'package:postgres/postgres.dart';

class Usermanage {
  static Future<int> createUser(UserModel user) async {
    try {
      Connection? con = await DatabaseService().openConnection();
      int row = 0;
      if (con != null) {
        final result = await con.execute(
          Sql.named(
            'INSERT INTO health_db.profiles (username, nickname, password, function, address, dob, created_at) '
            'VALUES (@username, @nickname, @password, @function, @address, @dob, @created_at) '
            'RETURNING id',
          ),
          parameters: {
            'username': user.username,
            'nickname': user.nickname,
            'password': user.password,
            'function': user.function,
            'address': user.address,
            'dob': user.birthdate,
            'created_at': user.createdAt,
          },
        );

        final rows = result as List?;
        if (rows == null || rows.isEmpty) {
          throw Exception('No ID returned');
        }

        return rows[0][0] as int;
      }
      return row;
    } catch (e) {
      rethrow;
    }
  }
}

class UserModel {
  final String username;
  final String nickname;
  final String password;
  final String address;
  final String function;
  final String birthdate;
  final String createdAt;

  UserModel({
    required this.username,
    required this.password,
    required this.nickname,
    required this.function,
    required this.address,
    required this.birthdate,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'],
      password: json['password'],
      nickname: json['nickname'],
      function: json['function'],
      address: json['address'],
      birthdate: json['birthdate'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'nickname': nickname,
      'address': address,
      'function': function,
      'birthdate': birthdate,
      'created_at': createdAt,
    };
  }
}
