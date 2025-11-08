import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // هذا الكائن مسؤول عن التعامل مع التخزين الآمن
  final _s = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // كتابة قيمة (مثل توكن)
  Future<void> write(String key, String value) =>
      _s.write(key: key, value: value);

  // قراءة قيمة
  Future<String?> read(String key) => _s.read(key: key);

  // حذف قيمة
  Future<void> delete(String key) => _s.delete(key: key);
}
