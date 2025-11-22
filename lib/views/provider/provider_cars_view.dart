import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import '../../models/car.dart';
import '../../widgets/car_card.dart';
import '../../widgets/custom_app_bar.dart';

class ProviderCarsView extends StatelessWidget {
  final String providerId;
  final String providerName;
  final String providerCity;

  const ProviderCarsView({
    super.key,
    required this.providerId,
    required this.providerName,
    required this.providerCity,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: CustomAppBar(
        title: providerName,
        onMenuTap: () => Navigator.pop(context),
      ),

      body: Column(
        children: [
          const SizedBox(height: 12),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("cars")
                  .where("provider_id", isEqualTo: providerId)
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading cars"));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text("no cars in this provider"));
                }

                final cars = docs.map((d) {
                  return Car.fromFirestore(
                    d.data() as Map<String, dynamic>,
                    d.id,
                  );
                }).toList();

                return FutureBuilder(
                  future: _loadBookings(providerId),
                  builder: (context, bookingSnap) {
                    if (!bookingSnap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final bookings = bookingSnap.data!;
                    final Map<String, int> bookingCount = {};

                    for (var b in bookings.docs) {
                      final carId = b["carId"];
                      bookingCount[carId] = (bookingCount[carId] ?? 0) + 1;
                    }

                    final sortedCars = [...cars];
                    sortedCars.sort((a, b) {
                      final countA = bookingCount[a.id] ?? 0;
                      final countB = bookingCount[b.id] ?? 0;
                      return countB.compareTo(countA);
                    });

                    final featured = sortedCars.take(4).toList();

                    return ListView(
                      padding: const EdgeInsets.only(bottom: 20),
                      children: [
                        _buildHeader(),

                        const SizedBox(height: 20),

                        _sectionTitle("Most Booked Cars"),
                        const SizedBox(height: 14),

                        SizedBox(
                          height: 250,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: featured.length,
                            itemBuilder: (context, index) {
                              final car = featured[index];
                              final count = bookingCount[car.id] ?? 0;

                              return TweenAnimationBuilder(
                                duration: Duration(
                                  milliseconds: 300 + index * 80,
                                ),
                                tween: Tween<double>(begin: 0, end: 1),
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, 30 * (1 - value)),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(left: 16),
                                  child: CarCard(
                                    car: car,
                                    isRented: count > 0,
                                    onTap: () =>
                                        context.push("/details", extra: car),
                                    onArrowTap: () =>
                                        context.push("/details", extra: car),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 30),

                        _sectionTitle("All Cars"),
                        const SizedBox(height: 16),

                        ...sortedCars.asMap().entries.map((entry) {
                          final index = entry.key;
                          final car = entry.value;
                          final count = bookingCount[car.id] ?? 0;

                          return TweenAnimationBuilder(
                            duration: Duration(milliseconds: 250 + index * 90),
                            tween: Tween<double>(begin: 0, end: 1),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 40 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: CarCard(
                                car: car,
                                isRented: count > 0,
                                onTap: () =>
                                    context.push("/details", extra: car),
                                onArrowTap: () =>
                                    context.push("/details", extra: car),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<QuerySnapshot> _loadBookings(String providerId) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection("bookings")
          .where("providerId", isEqualTo: providerId)
          .get();

      if (snap.docs.isNotEmpty) return snap;

      final snap2 = await FirebaseFirestore.instance
          .collection("bookings")
          .where("provider_id", isEqualTo: providerId)
          .get();

      return snap2;
    } catch (e) {
      return FirebaseFirestore.instance
          .collection("bookings")
          .where("provider_id", isEqualTo: providerId)
          .get();
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.15),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.amber.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              providerName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_pin, color: Colors.black54, size: 18),
                const SizedBox(width: 4),
                Text(
                  providerCity,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
      ),
    );
  }
}
