import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FancyDashboardDrawer extends StatefulWidget {
  final VoidCallback onClose;

  const FancyDashboardDrawer({super.key, required this.onClose});

  @override
  State<FancyDashboardDrawer> createState() => _FancyDashboardDrawerState();
}

class _FancyDashboardDrawerState extends State<FancyDashboardDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _slide = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutExpo));

    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _closeDrawer() {
    _anim.reverse().then((_) => widget.onClose());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // الخلفية الضبابية
        GestureDetector(
          onTap: _closeDrawer,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),
        ),

        // ⬅️ أنيميشن سلايد للدرور
        Align(
          alignment: Alignment.centerRight,
          child: SlideTransition(
            position: _slide,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.72,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  bottomLeft: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 30,
                    offset: Offset(-5, 0),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    // header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 35),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 85,
                            child: Image.asset(
                              "assets/images/LOGO.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "JoCar",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.yellow,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        children: [
                          _item(
                            icon: Icons.home_outlined,
                            text: "Home",
                            onTap: () {
                              context.go("/car");
                              _closeDrawer();
                            },
                          ),
                          _item(
                            icon: Icons.calendar_month_outlined,
                            text: "My Bookings",
                            onTap: () {
                              context.push("/booking-center");
                              _closeDrawer();
                            },
                          ),
                          _item(
                            icon: Icons.person_outline,
                            text: "Profile",
                            onTap: () {
                              context.push("/profile");
                              _closeDrawer();
                            },
                          ),
                          _item(
                            icon: Icons.help_outline,
                            text: "Help Center",
                            onTap: () {
                              context.push("/help-center");
                              _closeDrawer();
                            },
                          ),

                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 20),

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
                  ],
                ),
              ),
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
    Color color = Colors.black87,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Row(
            children: [
              Icon(icon, size: 26, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 17,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, size: 22, color: Colors.black45),
            ],
          ),
        ),
      ),
    );
  }
}
