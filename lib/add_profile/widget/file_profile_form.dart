import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:openvpn_client/add_profile/controller/file_profile_controller.dart';

import '../../themes/app_colors.dart';

class FileProfileForm extends GetView<FileProfileController> {
  const FileProfileForm({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: colors.glassDecoration(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 118,
                height: 118,
                decoration: BoxDecoration(
                  gradient: colors.heroGradient,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: colors.accent.withOpacity(0.24),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    "assets/images/file_type.png",
                    color: Colors.white,
                    height: 56,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Import OpenVPN Config',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Select a .ovpn file to create a profile instantly. The connection logic stays unchanged; this screen only improves the experience.',
                style: TextStyle(
                  color: colors.textMuted,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
