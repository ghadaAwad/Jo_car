import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onMenuTap;

  const CustomAppBar({super.key, required this.title, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black.withOpacity(0.55), // 🔥 اسود شفاف حقيقي
      elevation: 0,
      centerTitle: true,

      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),

      leading: GestureDetector(
        onTap: onMenuTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 6, // 🔥 أقل Padding = اللوجو يكبر فعليًا
            vertical: 4,
          ),
          child: Image.asset(
            "assets/images/LOGO.png",
            fit: BoxFit.contain,
            width: 55, // 🔥 مكبّر بشكل محترم
            height: 55,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
