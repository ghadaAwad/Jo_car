import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

class CarService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instanceFor(
    bucket: "gs://jocar97",
  );

  Future<void> addCar({
    required String make,
    required String model,
    required int year,
    required String plateNumber,
    required Uint8List imageBytes,
    required String providerId,
    required String providerName,
    required String color,
    required String transmission,
    required String fuelType,
    required int seats,
    required int doors,
    required int mileageKm,
    required String status,
    required double dailyRate,
  }) async {
    try {
      // رفع الصورة
      String fileName =
          "cars/${providerId}-${DateTime.now().millisecondsSinceEpoch}.jpg";

      UploadTask uploadTask = storage
          .ref(fileName)
          .putData(imageBytes, SettableMetadata(contentType: 'image/jpeg'));

      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();

      // حفظ السيارة في Firestore
      await firestore.collection("cars").add({
        "make": make,
        "model": model,
        "year": year,
        "plate_number": plateNumber,
        "provider_id": providerId,
        "provider_name": providerName,
        "imageUrl": imageUrl,

        "color": color,
        "transmission": transmission,
        "fuel_type": fuelType,

        "seats": seats,
        "doors": doors,
        "mileage_km": mileageKm,
        "status": status,
        "daily_rate": dailyRate,

        "created_at": DateTime.now().toIso8601String(),
      });
      print("🔥 Firebase App: ${Firebase.app().options.storageBucket}");

      print("🚗 Car added successfully!");
    } catch (e) {
      print("🔥 Error adding car: $e");
      rethrow;
    }
  }
}
