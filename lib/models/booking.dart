// lib/models/booking.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String? id;

  final String userId;
  final String providerId;
  final String carId;

  final String userName;
  final String userEmail;
  final String userPhone;

  final double latitude;
  final double longitude;

  final DateTime startDate;
  final int days;
  DateTime get endDate => startDate.add(Duration(days: days));

  final double dailyRate;
  double get totalPrice => dailyRate * days;

  final String paymentMethod;
  final DateTime createdAt;

  final String carImageUrl;
  final String carMake;
  final String carModel;

  final String status;

  Booking({
    this.id,
    required this.userId,
    required this.providerId,
    required this.carId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.latitude,
    required this.longitude,
    required this.startDate,
    required this.days,
    required this.dailyRate,
    required this.paymentMethod,
    required this.createdAt,
    required this.carImageUrl,
    required this.carMake,
    required this.carModel,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'providerId': providerId,
      'carId': carId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'latitude': latitude,
      'longitude': longitude,
      'startDate': startDate.toIso8601String(),
      'days': days,
      'dailyRate': dailyRate,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'carImageUrl': carImageUrl,
      'carMake': carMake,
      'carModel': carModel,
      'status': status,
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map, String id) {
    return Booking(
      id: id,
      userId: map['userId'] ?? '',
      providerId: map['providerId'] ?? '',
      carId: map['carId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userPhone: map['userPhone'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      startDate: DateTime.tryParse(map['startDate'] ?? '') ?? DateTime.now(),
      days: (map['days'] ?? 1).toInt(),
      dailyRate: (map['dailyRate'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? 'cash',

      // ✅ أهم تعديل
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),

      carImageUrl: map['carImageUrl'] ?? '',
      carMake: map['carMake'] ?? '',
      carModel: map['carModel'] ?? '',
      status: map['status'] ?? 'pending',
    );
  }
}
