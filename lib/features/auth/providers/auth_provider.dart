import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/services/secure_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final SecureStorageService _storage;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _loading = false;
  bool get loading => _loading;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  String? _userEmail;
  String? get userEmail => _userEmail;

  String? _userType;
  String? get userType => _userType;

  Map<String, dynamic>? _userData;
  Map<String, dynamic>? get user => _userData;

  AuthProvider(this._storage);

  Future<void> login(String email, String password) async {
    _loading = true;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      final user = _auth.currentUser;

      if (user != null) {
        _isAuthenticated = true;
        _userEmail = user.email;

        final doc = await _firestore.collection('users').doc(user.uid).get();
        final data = doc.data() ?? {};

        _userType = data['type'] ?? 'User';

        _userData = {...data, 'imageUrl': data['imageUrl'] ?? ''};

        await _storage.write('logged_in', 'true');
        await _storage.write('user_email', _userEmail!);
        await _storage.write('type', _userType!);
      }
    } catch (e) {
      print("Login Error: $e");
      _isAuthenticated = false;
    }

    _loading = false;
    notifyListeners();
  }

  Future<bool> registerFull(Map<String, dynamic> data) async {
    _loading = true;
    notifyListeners();

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: data['email'],
        password: data['password'],
      );

      final user = cred.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'firstName': data['firstName'],
          'lastName': data['lastName'],
          'email': data['email'],
          'phone': data['phone'],
          'address': data['address'],
          'city': data['city'],
          'username': data['username'],
          'type': data['type'],
          'createdAt': FieldValue.serverTimestamp(),
          'imageUrl': '', // 🔥 إضافة الصورة فاضية
        });

        _userData = {...data, 'imageUrl': ''};

        _isAuthenticated = true;
        _userEmail = user.email;
        _userType = data['type'];

        await _storage.write('logged_in', 'true');
        await _storage.write('user_email', _userEmail!);
        await _storage.write('type', _userType!);

        _loading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print("Register Error: $e");
    }

    _isAuthenticated = false;
    _loading = false;
    notifyListeners();

    return false;
  }

  Future<void> signInWithGoogle() async {
    try {
      _loading = true;
      notifyListeners();

      final google = GoogleSignIn();
      final googleUser = await google.signIn();

      if (googleUser == null) {
        _loading = false;
        notifyListeners();
        return;
      }

      final tokens = await googleUser.authentication;
      final cred = GoogleAuthProvider.credential(
        idToken: tokens.idToken,
        accessToken: tokens.accessToken,
      );

      final result = await _auth.signInWithCredential(cred);
      final user = result.user;

      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();

        if (!doc.exists) {
          await _auth.signOut();
          throw Exception("NO_ACCOUNT");
        }

        final data = doc.data() ?? {};

        _userData = {...data, 'imageUrl': data['imageUrl'] ?? ''};

        _userType = data['type'] ?? 'User';
        _userEmail = user.email;
        _isAuthenticated = true;

        await _storage.write('logged_in', 'true');
        await _storage.write('user_email', _userEmail!);
        await _storage.write('type', _userType!);
      }
    } catch (e) {
      print("Google Error: $e");
      if (e.toString().contains("NO_ACCOUNT")) {
        throw Exception("NO_ACCOUNT");
      }
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.signOut();

    try {
      await GoogleSignIn().signOut();
    } catch (_) {}

    _isAuthenticated = false;
    _userEmail = null;
    _userType = null;
    _userData = null;

    await _storage.delete('logged_in');
    await _storage.delete('user_email');
    await _storage.delete('type');

    notifyListeners();
  }

  Future<void> restoreSession() async {
    final logged = await _storage.read('logged_in');
    final email = await _storage.read('user_email');
    final type = await _storage.read('type');

    if (logged == 'true' && email != null) {
      _isAuthenticated = true;
      _userEmail = email;
      _userType = type;

      final uid = _auth.currentUser?.uid;

      if (uid != null) {
        final snap = await _firestore.collection('users').doc(uid).get();
        final data = snap.data() ?? {};

        _userData = {...data, 'imageUrl': data['imageUrl'] ?? ''};
      }
    } else {
      _isAuthenticated = false;
    }

    _isInitialized = true;
    notifyListeners();
  }

  void updateUser(Map<String, dynamic> data) {
    _userData ??= {};
    _userData!.addAll(data);
    notifyListeners();
  }
}
