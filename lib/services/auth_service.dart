import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final List<UserModel> _registeredUsers = [];
  UserModel? _currentUser;

  bool register(UserModel user) {
    final exists = _registeredUsers.any((u) => u.email == user.email);
    if (exists) return false;

    _registeredUsers.add(user);
    _currentUser = user;
    return true;
  }

  bool login(String email, String password) {
    final user = _registeredUsers.firstWhere(
      (u) => u.email == email && u.password == password,
      orElse: () => UserModel(
        firstName: '',
        lastName: '',
        email: '',
        phone: '',
        address: '',
        city: '',
        username: '',
        password: '',
        type: '',
      ),
    );

    if (user.email.isEmpty) return false;

    _currentUser = user;
    return true;
  }

  UserModel? get currentUser => _currentUser;

  void logout() {
    _currentUser = null;
  }
}
