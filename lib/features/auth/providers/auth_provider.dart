import 'package:flutter/foundation.dart';
import '../../../core/services/secure_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final SecureStorageService _storage;

  bool _loading = false;
  bool get loading => _loading;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  String? _userEmail;
  String? get userEmail => _userEmail;

  String? _userType;
  String? get userType => _userType;

  Map<String, String>? get user {
    if (_userEmail == null) return null;
    return {
      'email': _userEmail!,
      'name': 'Noor Awad', // مؤقت لعرضه بالبروفايل
      'phone': '+962790000000',
      'city': 'Amman',
    };
  }

  AuthProvider(this._storage);

  // محاكاة تسجيل الدخول (بدون API حالياً)
  Future<void> login(String email, String password) async {
    _loading = true;
    notifyListeners();

    // تأخير بسيط كأنه بنادي API
    await Future.delayed(const Duration(seconds: 1));

    // مؤقتاً نعتبر أي تسجيل دخول ناجح
    _isAuthenticated = true;
    _userEmail = email;

    // نحفظ الحالة مؤقتاً بالتخزين الآمن
    await _storage.write('logged_in', 'true');
    await _storage.write('user_email', email);

    _loading = false;
    notifyListeners();
  }

  Future<void> registerFull(Map<String, dynamic> userData) async {
    _loading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _isAuthenticated = true;
    _userEmail = userData['email'];
    _userType = userData['type'];

    await _storage.write('logged_in', 'true');
    await _storage.write('user_email', userData['email']);
    await _storage.write('username', userData['username']);
    await _storage.write('type', userData['type']); // ✅ نوع المستخدم

    _loading = false;
    notifyListeners();
  }

  Future<String?> getUserType() async {
    return await _storage.read('type');
  }

  // محاكاة تسجيل الخروج
  Future<void> logout() async {
    _isAuthenticated = false;
    _userEmail = null;
    await _storage.delete('logged_in');
    await _storage.delete('user_email');
    notifyListeners();
  }

  // استعادة الجلسة عند تشغيل التطبيق
  Future<void> restoreSession() async {
    final loggedIn = await _storage.read('logged_in');
    final email = await _storage.read('user_email');

    final type = await _storage.read('type');

    if (loggedIn == 'true' && email != null) {
      _isAuthenticated = true;
      _userEmail = email;
      _userType = type;
    } else {
      _isAuthenticated = false;
      _userEmail = null;
      _userType = null;
    }

    notifyListeners();
  }
}
