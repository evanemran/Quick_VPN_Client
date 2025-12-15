import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:openvpn_client/add_profile/controller/file_profile_controller.dart';

import '../../themes/app_colors.dart';

class FileProfileForm extends GetView<FileProfileController> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("assets/images/file_type.png", color: Colors.white, height: 100,),
              SizedBox(height: 16,),
              Text("Select a \".ovpn\" file for your profile. The maximum file size is 256 KB", style: TextStyle(color: Colors.white), textAlign: TextAlign.center,)
            ],
          ),
        ),
      ),
    );
  }
}