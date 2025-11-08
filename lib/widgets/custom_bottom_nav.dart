import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../features/auth/providers/auth_provider.dart';
import '../core/config/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  const CustomBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return FutureBuilder<String?>(
      future: auth.getUserType(),
      builder: (context, snapshot) {
        final userType = snapshot.data ?? 'user';
        final isProvider = userType == 'provider';

        final items = [
          _NavItem(Icons.home, 'Home', '/home'),
          _NavItem(Icons.directions_car, 'Cars', '/details'),
          _NavItem(Icons.person, 'Profile', '/profile'),
        ];

        // ✅ إذا كان Provider نضيف Dashboard
        if (isProvider) {
          items.insert(2, _NavItem(Icons.dashboard, 'Dashboard', '/dashboard'));
        }

        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (i) {
                final item = items[i];
                final selected = i == currentIndex;

                return GestureDetector(
                  onTap: () => context.go(item.route),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        color: selected ? AppColors.sunYellow : Colors.grey,
                      ),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: selected
                              ? AppColors.sunYellow
                              : Colors.grey[600],
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  _NavItem(this.icon, this.label, this.route);
}
