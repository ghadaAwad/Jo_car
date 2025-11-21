import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CarBookingsDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> car;
  final List<Map<String, dynamic>> historyBookings;
  final Map<String, dynamic>? currentBooking;

  const CarBookingsDetailsScreen({
    Key? key,
    required this.car,
    required this.historyBookings,
    required this.currentBooking,
  }) : super(key: key);

  DateTime toDT(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    return DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final isRented = currentBooking != null;

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      appBar: AppBar(
        title: const Text("تفاصيل السيارة"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // الصورة
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: car["imageUrl"] != null
                  ? DecorationImage(
                      image: NetworkImage(car["imageUrl"]),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: Colors.black26,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            "${car["make"]} ${car["model"]}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            "لوحة: ${car["plate_number"]}",
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isRented
                  ? Colors.green.withOpacity(.2)
                  : Colors.red.withOpacity(.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isRented ? "Rented Now · محجوزة" : "Available · غير محجوزة",
              style: TextStyle(
                color: isRented ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            "الحجز الحالي",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),

          if (currentBooking != null)
            _bookingCard(currentBooking!)
          else
            const Text(
              "لا يوجد حجز نشط حالياً",
              style: TextStyle(color: Colors.grey),
            ),

          const SizedBox(height: 30),
          const Text(
            "جميع الحجوزات",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),

          ...historyBookings.map((b) => _bookingCard(b)),
        ],
      ),
    );
  }

  Widget _bookingCard(Map<String, dynamic> booking) {
    final start = toDT(booking["startDate"]);
    final days = booking["days"] ?? 1;
    final end = start.add(Duration(days: days));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row("الاسم", booking["userName"]),
          _row("الهاتف", booking["userPhone"]),
          _row("الحالة", booking["status"]),
          _row("البداية", start.toString()),
          _row("النهاية", end.toString()),
        ],
      ),
    );
  }

  Widget _row(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(value ?? "-", style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
