import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../models/booking.dart';

class BookingProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> createBooking(Booking booking) async {
    try {
      _loading = true;
      notifyListeners();

      final data = booking.toMap();
      await _db.collection('bookings').add(data);

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      notifyListeners();
      if (kDebugMode) {
        print('🔥 Error creating booking: $e');
      }
      rethrow;
    }
  }

  Future<List<Booking>> getUserBookings() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snap = await _db
          .collection("bookings")
          .where("userId", isEqualTo: user.uid)
          .orderBy("createdAt", descending: true)
          .get();

      return snap.docs
          .map(
            (doc) =>
                Booking.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      debugPrint("🔥 Error loading user bookings: $e");
      return [];
    }
  }

  /// إنشاء جلسة دفع Stripe عبر Cloud Function
  Future<String?> createStripePayment({
    required int amount, // بالسنت
    required String carId,
    required String userEmail,
    String currency = "usd",
  }) async {
    try {
      final callable = FirebaseFunctions.instanceFor(
        region: "us-central1",
      ).httpsCallable('createCheckoutSession');

      final result = await callable.call({
        'amount': amount,
        'currency': currency,
        'carId': carId,
        'email': userEmail,
      });

      final data = result.data;
      if (data is Map && data['url'] is String) {
        return data['url'] as String;
      }

      debugPrint("⚠️ Unexpected createCheckoutSession response: $data");
      return null;
    } catch (e) {
      debugPrint("🔥 Payment error: $e");
      return null;
    }
  }
}
