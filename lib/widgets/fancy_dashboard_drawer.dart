import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/config/app_colors.dart';

class FancyDashboardDrawer extends StatelessWidget {
  final VoidCallback onClose;

  const FancyDashboardDrawer({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // خلفية بلور
        GestureDetector(
          onTap: onClose,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
        ),

        // القائمة نفسها
        Align(
          alignment: Alignment.centerRight,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            width: 260,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(-4, 0),
                ),
              ],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                bottomLeft: Radius.circular(40),
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
              children: [
                _item(
                  icon: Icons.home_outlined,
                  text: "Home",
                  onTap: () {
                    context.go("/car");
                    onClose();
                  },
                ),
                _item(
                  icon: Icons.calendar_month_outlined,
                  text: "My Bookings",
                  onTap: () {
                    context.push("/my-bookings");
                    onClose();
                  },
                ),
                _item(
                  icon: Icons.person_outline,
                  text: "Profile",
                  onTap: () {
                    context.push("/profile");
                    onClose();
                  },
                ),
                _item(
                  icon: Icons.help_outline,
                  text: "Help Center",
                  onTap: () {
                    context.push("/help-center");
                    onClose();
                  },
                ),

                const SizedBox(height: 22),
                const Divider(),

                _item(
                  icon: Icons.logout,
                  text: "Logout",
                  color: Colors.red,
                  onTap: () {
                    context.go("/logout");
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _item({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color color = AppColors.textPrimary,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 26, color: color),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 17,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
