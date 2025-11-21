import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/car.dart';
import '../../features/auth/providers/car_provider.dart';
import '../../../core/config/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProviderDashboardView extends StatefulWidget {
  const ProviderDashboardView({super.key});

  @override
  State<ProviderDashboardView> createState() => _ProviderDashboardViewState();
}

class _ProviderDashboardViewState extends State<ProviderDashboardView> {
  @override
  void initState() {
    super.initState();

    /// تحميل سيارات المزود الحالي فقط
    Future.microtask(() {
      context.read<CarProvider>().fetchProviderCars();
    });
  }

  @override
  Widget build(BuildContext context) {
    final carProvider = context.watch<CarProvider>();
    final cars = carProvider.providerCars;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Cars Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.sunYellow,
        foregroundColor: Colors.black,
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: cars.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                key: const ValueKey('carList'),
                padding: const EdgeInsets.all(16),
                itemCount: cars.length,
                itemBuilder: (context, index) {
                  final car = cars[index];
                  return _CarDashboardCard(car: car, index: index);
                },
              ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.sunYellow,
        foregroundColor: Colors.black,
        onPressed: () {
          context.push('/provider-dashboard/add-car');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      key: const ValueKey('empty'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_car, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No cars added yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => context.push('/provider-dashboard/add-car'),
            icon: const Icon(Icons.add),
            label: const Text('Add Car'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sunYellow,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _CarDashboardCard extends StatefulWidget {
  final Car car;
  final int index;

  const _CarDashboardCard({required this.car, required this.index});

  @override
  State<_CarDashboardCard> createState() => _CarDashboardCardState();
}

class _CarDashboardCardState extends State<_CarDashboardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _controller.forward();
  void _onTapUp(_) => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final carProvider = context.read<CarProvider>();
    final car = widget.car;

    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _controller.reverse,
        child: Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                /// صورة السيارة
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    car.imageUrl.isNotEmpty
                        ? car.imageUrl
                        : 'https://cdn-icons-png.flaticon.com/512/744/744465.png',
                    width: 100,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(width: 14),

                /// معلومات السيارة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${car.make} ${car.model}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${car.year} • ${car.color}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '\$${car.daily_rate}/day',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                /// أزرار التحكم
                Column(
                  children: [
                    /// حذف
                    IconButton(
                      onPressed: () async {
                        await carProvider.deleteCar(car);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Car removed successfully ✅'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                    ),

                    /// تعديل
                    IconButton(
                      onPressed: () {
                        context.push(
                          '/provider-dashboard/edit-car',
                          extra: car,
                        );
                      },

                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
