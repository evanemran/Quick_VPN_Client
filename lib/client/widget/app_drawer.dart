import 'package:flutter/material.dart';

import '../../themes/app_colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Drawer(
      backgroundColor: colors.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: colors.heroGradient,
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                "Quick VPN",
                style: TextStyle(
                  color: colors.isDark ? Colors.white : colors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          _item(context, Icons.home_rounded, "Home"),
          _item(context, Icons.settings_rounded, "Settings"),
          _item(context, Icons.logout_rounded, "Logout"),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String label) {
    final colors = context.appColors;
    return ListTile(
      leading: Icon(icon, color: colors.textPrimary),
      title: Text(
        label,
        style: TextStyle(color: colors.textPrimary),
      ),
      onTap: () => Navigator.pop(context),
    );
  }
}
