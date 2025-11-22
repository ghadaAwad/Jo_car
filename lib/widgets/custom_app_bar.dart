import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onMenuTap;

  const CustomAppBar({super.key, required this.title, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final iconSize = screenWidth * 0.085;

    return AppBar(
      backgroundColor: Colors.black.withOpacity(0.55),
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
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Icon(Icons.menu, size: iconSize, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
