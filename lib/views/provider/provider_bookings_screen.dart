import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../../models/booking.dart';
import '../../../core/config/app_colors.dart';
import '../../../widgets/custom_app_bar.dart';

class ProviderBookingsPage extends StatefulWidget {
  const ProviderBookingsPage({super.key});

  @override
  State<ProviderBookingsPage> createState() => _ProviderBookingsPageState();
}

class _ProviderBookingsPageState extends State<ProviderBookingsPage> {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  String? providerId;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProvider();
  }

  Future<void> _loadProvider() async {
    providerId = _auth.currentUser?.uid;

    setState(() => loading = false);
  }

  Future<void> acceptBooking(Booking b) async {
    if (b.id == null) return;
    await _db.collection("bookings").doc(b.id).update({"status": "confirmed"});
  }

  Future<void> cancelBooking(Booking b) async {
    if (b.id == null) return;
    await _db.collection("bookings").doc(b.id).update({"status": "canceled"});
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (providerId == null) {
      return const Scaffold(
        body: Center(child: Text("خطأ: لا يوجد معرف للمزوّد")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(
        title: "Bookings",
        onMenuTap: () => Navigator.pop(context),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db
            .collection("bookings")
            .where("providerId", isEqualTo: providerId)
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text("خطأ في التحميل: ${snap.error}"));
          }

          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("لا يوجد حجوزات"));
          }

          final bookings = docs
              .map(
                (d) => Booking.fromMap(d.data() as Map<String, dynamic>, d.id),
              )
              .toList();

          final pending = bookings.where((b) => b.status == "pending").toList();
          final others = bookings.where((b) => b.status != "pending").toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pending.isNotEmpty) ...[
                  const Text(
                    "pending to confirmed",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  ...pending.map(
                    (b) => BookingCard(
                      booking: b,
                      showActions: true,
                      onAccept: () => acceptBooking(b),
                      onCancel: () => cancelBooking(b),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                const Text(
                  "جميع الحجوزات",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                ...others.map(
                  (b) => BookingCard(booking: b, showActions: false),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final Booking booking;
  final bool showActions;
  final VoidCallback? onAccept;
  final VoidCallback? onCancel;

  const BookingCard({
    super.key,
    required this.booking,
    this.showActions = false,
    this.onAccept,
    this.onCancel,
  });

  Color statusColor(String s) {
    switch (s) {
      case "pending":
        return Colors.orange;
      case "confirmed":
        return Colors.blue;
      case "active":
        return Colors.green;
      case "completed":
        return Colors.grey;
      case "canceled":
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  String statusText(String s) {
    switch (s) {
      case "pending":
        return "pending to confirmed ";
      case "confirmed":
        return "confirmed ";
      case "active":
        return "rent now";
      case "completed":
        return "completed";
      case "canceled":
        return "canceled";
      default:
        return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = booking.totalPrice;

    return GestureDetector(
      onTap: () => context.push("/booking-details", extra: booking),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            // صورة السيارة
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[300],
                image: booking.carImageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(booking.carImageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: booking.carImageUrl.isEmpty
                  ? const Icon(Icons.directions_car, size: 32)
                  : null,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          booking.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor(booking.status).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusText(booking.status),
                          style: TextStyle(
                            color: statusColor(booking.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                  Text(
                    "${booking.carMake} ${booking.carModel}",
                    style: const TextStyle(fontSize: 13),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    "at ${booking.startDate.day}/${booking.startDate.month} "
                    "to ${booking.endDate.day}/${booking.endDate.month} "
                    "(${booking.days} day)",
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    "الإجمالي: ${total.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),

                  if (showActions) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.sunYellow,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: onAccept,
                            child: const Text("recpect"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: onCancel,
                            child: const Text(
                              "cancle",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
