import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/config/app_colors.dart';
import '../../models/car.dart';
import '../../widgets/car_card.dart';
import '../../widgets/fancy_dashboard_drawer.dart';
import '../../widgets/custom_app_bar.dart'; // 👈 مهم جداً

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = '';
  bool isProvider = false;
  bool showDrawer = false;

  Map<String, Map<String, String>> providerInfo = {};
  bool loadingProviders = true;

  @override
  void initState() {
    super.initState();
    _checkUserType();
    _loadProviderInfo();
  }

  Future<void> _checkUserType() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      setState(() {
        isProvider = (doc.data()?['type'] == "Provider");
      });
    }
  }

  Future<void> _loadProviderInfo() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('users').get();

      final map = <String, Map<String, String>>{};

      for (var doc in snap.docs) {
        final data = doc.data();

        map[doc.id] = {
          "name": (data["username"] ?? data["firstName"] ?? "Unknown")
              .toString(),
          "city": (data["city"] ?? "").toString(),
        };
      }

      setState(() {
        providerInfo = map;
        loadingProviders = false;
      });
    } catch (e) {
      setState(() => loadingProviders = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey[100],

          floatingActionButton: isProvider
              ? FloatingActionButton(
                  backgroundColor: AppColors.sunYellow,
                  child: const Icon(Icons.add, color: Colors.black),
                  onPressed: () => context.push("/provider-dashboard/add-car"),
                )
              : null,

          appBar: CustomAppBar(
            title: "Find Your Car",
            onMenuTap: () {
              setState(() => showDrawer = true);
            },
          ),

          body: Column(
            children: [
              _buildSearchBar(),
              Expanded(child: _buildCarsStream()),
            ],
          ),
        ),

        if (showDrawer)
          FancyDashboardDrawer(
            onClose: () {
              setState(() => showDrawer = false);
            },
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) => setState(() => searchQuery = value),
        decoration: InputDecoration(
          hintText: "serch cars , provider name ,color ...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCarsStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("cars")
          .orderBy("created_at", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || loadingProviders) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        final cars = docs
            .map(
              (doc) =>
                  Car.fromFirestore(doc.data() as Map<String, dynamic>, doc.id),
            )
            .toList();

        // ------------------------------------------------------------------
        // 🔍 فلترة السيرش الجديدة — بدون ما ألمس أي شي من كودك
        // ------------------------------------------------------------------
        final q = searchQuery.trim().toLowerCase();
        final filteredCars = q.isEmpty
            ? cars
            : cars.where((car) {
                final providerName =
                    (providerInfo[car.provider_id]?["name"] ?? "")
                        .toLowerCase();
                final make = (car.make ?? "").toLowerCase();
                final model = (car.model ?? "").toLowerCase();
                final color = (car.color ?? "").toLowerCase();
                final fuel = (car.fuel_type ?? "").toLowerCase();

                return providerName.contains(q) ||
                    make.contains(q) ||
                    model.contains(q) ||
                    color.contains(q) ||
                    fuel.contains(q);
              }).toList();
        // ------------------------------------------------------------------

        final providersMap = <String, List<Car>>{};
        for (var car in filteredCars) {
          providersMap.putIfAbsent(car.provider_id, () => []);
          providersMap[car.provider_id]!.add(car);
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: providersMap.entries.map((entry) {
            final providerId = entry.key;
            final providerCars = entry.value.take(4).toList();

            final providerName = providerInfo[providerId]?["name"] ?? "Unknown";
            final providerCity = providerInfo[providerId]?["city"] ?? "";

            return Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              providerName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            if (providerCity.isNotEmpty)
                              Text(
                                providerCity,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push(
                            "/provider-cars",
                            extra: {
                              "id": providerId,
                              "name": providerName,
                              "city": providerCity,
                            },
                          );
                        },
                        child: const Text(
                          "See All",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.sunYellow,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 230,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: providerCars.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final car = providerCars[index];
                        return CarCard(
                          car: car,
                          onTap: () => context.push("/details", extra: car),
                          showAvailability: false,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
