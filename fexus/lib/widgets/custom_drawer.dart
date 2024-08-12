import 'package:fexus/main.dart';
import 'package:fexus/models/user.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius:
                        BorderRadius.circular(20.0), // Rounded corners
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.white),
                    title: const Text('Sign Out',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      UserPreferences.clearUserSession();
                      Navigator.pop(context); // Close the drawer
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LandingPage()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
