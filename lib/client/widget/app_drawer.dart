import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../themes/app_colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.primaryColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
            ),
            child: Text(
              "Quick VPN",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {
              Navigator.pop(context); // close drawer
              // Navigate to Home
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Navigator.pop(context); // close drawer
              // Navigate to Settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              Navigator.pop(context); // close drawer
              // Perform logout
            },
          ),
        ],
      ),
    );
  }
}
