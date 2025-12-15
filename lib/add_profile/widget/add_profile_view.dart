import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:openvpn_client/add_profile/controller/add_profile_controller.dart';
import 'package:openvpn_client/add_profile/controller/profile_tab_controller.dart';

import '../../themes/app_colors.dart';
import 'file_profile_form.dart';
import 'manual_profile_form.dart';

class AddProfileView extends GetView<AddProfileController> {

  final ProfileTabController profileTabController = Get.find<ProfileTabController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          leading: IconButton(onPressed: () => Get.back(), icon: ImageIcon(AssetImage("assets/images/ic_back.png"), color: Colors.white,)),
          title: Text(
            'Add New Profile',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        bottom: TabBar(
          controller: profileTabController.tabController,
          indicatorColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 4,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16),
          unselectedLabelColor: Colors.white30,
          labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          isScrollable: false,
          tabs: [
            Tab(text: 'Manual'),
            Tab(text: 'File'),
          ],
        ),
      ),
      body: TabBarView(
        controller: profileTabController.tabController,
        children: [
          ManualProfileForm(),
          FileProfileForm(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8, 16, 16),
        child: ElevatedButton(
          onPressed: () async {
            if(profileTabController.selectedTabNumber.value==0) {

            }
            else {
              var config = await profileTabController.selectOpenVpnFile();
              Get.back(result: config);
            }
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2), // semi-transparent
              foregroundColor: Colors.white, // text/icon color
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0, // optional: remove shadow
              minimumSize: Size(MediaQuery.of(context).size.width*0.9, 20)
          ),
          child: Obx(()=> profileTabController.selectedTabNumber.value==0 ? Text('Save') : Text('Browse')),
        ),
      ),
    );
  }
}
