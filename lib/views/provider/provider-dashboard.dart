import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_colors.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../widgets/custom_bottom_nav.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final username = auth.userEmail?.split('@').first ?? 'Provider';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Welcome, $username 👋',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.1,
          children: [
            _DashboardCard(
              icon: Icons.add_box_rounded,
              title: 'Add Car',
              color: const Color(0xFFFFD54F),
              onTap: () => context.push('/add-car'),
            ),
            _DashboardCard(
              icon: Icons.directions_car_rounded,
              title: 'Manage Cars',
              color: const Color(0xFF80DEEA),
              onTap: () => context.push('/manage-cars'),
            ),
            _DashboardCard(
              icon: Icons.calendar_today_rounded,
              title: 'Bookings',
              color: const Color(0xFFA5D6A7),
              onTap: () => context.push('/bookings'),
            ),
            _DashboardCard(
              icon: Icons.attach_money_rounded,
              title: 'Earnings',
              color: const Color(0xFFEF9A9A),
              onTap: () => context.push('/earnings'),
            ),
          ],
        ),
      ),

      // ✅ شريط التنقل السفلي المشترك
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}

class _DashboardCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  State<_DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<_DashboardCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Future.delayed(const Duration(milliseconds: 100), widget.onTap);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(_pressed ? 0.8 : 1),
          borderRadius: BorderRadius.circular(18),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: widget.color.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, size: 48, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
