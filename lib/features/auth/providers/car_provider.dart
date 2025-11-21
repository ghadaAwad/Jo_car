import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../../../models/car.dart';

class CarProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Car> _allCars = [];
  List<Car> get allCars => List.unmodifiable(_allCars);

  List<Car> _providerCars = [];
  List<Car> get providerCars => List.unmodifiable(_providerCars);

  bool _loading = false;
  bool get loading => _loading;

  /// 🔹 جلب كل السيارات (لصفحة الهوم)
  Future<void> fetchAllCars() async {
    try {
      _loading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('cars')
          .orderBy('created_at', descending: true)
          .get();

      _allCars = snapshot.docs
          .map((doc) => Car.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) print('🔥 Error fetching all cars: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 🔹 سيارات هذا البروفايدر فقط (Dashboard)
  Future<void> fetchProviderCars() async {
    try {
      final uid = _auth.currentUser!.uid;

      final snapshot = await _firestore
          .collection('cars')
          .where('provider_id', isEqualTo: uid)
          .orderBy('created_at', descending: true)
          .get();

      _providerCars = snapshot.docs
          .map((doc) => Car.fromFirestore(doc.data(), doc.id))
          .toList();

      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('🔥 Error fetching provider cars: $e');
    }
  }

  /// ------------------------------------------------------
  /// 🔥 Get provider (office) name from Firestore
  /// ------------------------------------------------------
  Future<String> getProviderName() async {
    final uid = _auth.currentUser!.uid;

    final doc = await _firestore.collection('users').doc(uid).get();

    if (doc.exists && doc.data() != null) {
      return doc.data()!['name'] ?? 'Unknown Provider';
    }

    return 'Unknown Provider';
  }

  Future<void> addCar(Car car, File imageFile) async {
    try {
      final uid = _auth.currentUser!.uid;

      // 🔥 Get provider name
      final providerName = await getProviderName();

      // 🔥 Upload image
      // 🔥 اسم ملف نظيف بدون فراغات
      // اسم ملف آمن بدون أي مشاكل
      final fileName = "car_${DateTime.now().millisecondsSinceEpoch}.jpg";

      // مرجع الصورة
      final imageRef = _storage.ref().child('cars/$fileName');

      // رفع الصورة
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        await imageRef.putData(bytes);
      } else {
        await imageRef.putFile(imageFile);
      }

      // رابط الصورة
      String imageUrl = await imageRef.getDownloadURL();

      // تنظيف الرابط
      final cleanUrl = imageUrl.trim();

      // 🔥 Prepare data
      final data = car.toMap()
        ..['provider_id'] = uid
        ..['provider_name'] = providerName
        ..['imageUrl'] = cleanUrl
        ..['created_at'] = DateTime.now().toIso8601String();

      // 🔥 Save car in Firestore
      final docRef = await _firestore.collection('cars').add(data);

      final savedCar = Car.fromFirestore(data, docRef.id);
      _providerCars.add(savedCar);
      _allCars.add(savedCar);

      notifyListeners();
    } catch (e) {
      print('🔥 Error adding car: $e');
    }
  }

  /// 🔹 حذف سيارة
  Future<void> deleteCar(Car car) async {
    try {
      if (car.id != null) {
        await _firestore.collection('cars').doc(car.id).delete();
      }

      if (car.imageUrl.isNotEmpty) {
        await _storage.refFromURL(car.imageUrl).delete();
      }

      _allCars.removeWhere((c) => c.id == car.id);
      _providerCars.removeWhere((c) => c.id == car.id);

      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('🔥 Error deleting car: $e');
    }
  }

  /// 🔹 تعديل سيارة
  Future<void> updateCar(Car car) async {
    try {
      if (car.id == null) return;

      await _firestore.collection('cars').doc(car.id).update(car.toMap());

      await fetchAllCars();
      await fetchProviderCars();
    } catch (e) {
      if (kDebugMode) print('🔥 Error updating car: $e');
    }
  }
}
