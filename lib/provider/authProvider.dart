import 'package:bcrypt/bcrypt.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/user_dao.dart';
import '../models/local_user.dart';

final authProvider = StateNotifierProvider<AuthNotifier, LocalUser?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<LocalUser?> {
  final UserDao _userDao = UserDao();

  AuthNotifier() : super(null) {
    _loadExistingUser();
  }

  Future<void> _loadExistingUser() async {
    final users = await _userDao.getAllUsers();
    if (users.isNotEmpty) {
      state = users.first;
    }
  }

  bool get isAuthenticated => state != null;

  Future<Map<String, dynamic>> authenticateUser(
    String username,
    String password,
  ) async {
    try {
      final localUser = await _userDao.getUserByUsername(username);

      if (localUser != null) {
        if (verifyPassword(password, localUser.password)) {
          state = localUser;
          return {'success': true, 'user': localUser};
        } else {
          return {'success': false, 'error': 'Invalid password'};
        }
      } else {
        return {
          'success': false,
          'error': 'User not found. Please register first.',
        };
      }
    } catch (e) {
      print('Auth error: $e');
      return {'success': false, 'error': 'Error during login: $e'};
    }
  }

  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String password,
    required String nickname,
    String? function,
    String? address,
    String? dob,
    String? sex,
    String? firstDiagnosisDate,
    String? smokingStatus,
    String? alcoholConsumption,
  }) async {
    try {
      final existingUser = await _userDao.getUserByUsername(username);
      if (existingUser != null) {
        return {'success': false, 'error': 'Username already exists'};
      }

      String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

      LocalUser newUser = LocalUser(
        username: username,
        password: hashedPassword,
        nickname: nickname,
        function: function,
        address: address,
        dob: dob,
        sex: sex,
        firstDiagnosisDate: firstDiagnosisDate,
        smokingStatus: smokingStatus,
        alcoholConsumption: alcoholConsumption,
        createdAt: DateTime.now().toIso8601String(),
        isSynced: 0,
      );

      int userId = await _userDao.insertUser(newUser);
      newUser = newUser.copyWith(id: userId);
      state = newUser;
      return {'success': true, 'user': newUser};
    } catch (e) {
      print('Register error: $e');
      return {'success': false, 'error': 'Error during registration: $e'};
    }
  }

  Future<void> logout() async {
    state = null;
  }

  Future<Map<String, dynamic>> updateUser(LocalUser user) async {
    try {
      await _userDao.updateUser(user);
      state = user;
      return {'success': true};
    } catch (e) {
      print('Update user error: $e');
      return {'success': false, 'error': 'Error updating profile: $e'};
    }
  }

  static bool verifyPassword(String plainTextPassword, String hashedPassword) {
    return BCrypt.checkpw(plainTextPassword, hashedPassword);
  }
}
