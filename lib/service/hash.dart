import 'package:bcrypt/bcrypt.dart'; // password hashing algorithms

// bcrypt
Future<String> bcryptPassword(String password) async {
  final String salt = BCrypt.gensalt();
  final String hashed = BCrypt.hashpw(password, salt);
  return hashed;
}
