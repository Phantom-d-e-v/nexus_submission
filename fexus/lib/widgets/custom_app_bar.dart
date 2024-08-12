import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFCD558A), // Start color
            Color(0xFF4B5479), // End color
          ],
        ),
      ),
      child: AppBar(
        backgroundColor:
            Colors.transparent, // Make AppBar background transparent
        elevation: 0, // Remove shadow
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            '../../assets/appbar_logo.png', // Path to your logo asset
            height: 40, // Adjust height as needed
          ),
        ),
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu), // Hamburger menu icon
            onPressed: () {
              scaffoldKey.currentState?.openDrawer(); // Open the drawer menu
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
