import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:openvpn_client/add_profile/controller/manual_profile_controller.dart';

import '../../themes/app_colors.dart';

class ManualProfileForm extends GetView<ManualProfileController> {

  bool _obscureText = true;

  String? selectedValue = "IKEv2/IPSec MSCHAPv2";
  String? selectedCertificate = 'Don\'t verify server';
  String? selectedServerCertificate = 'SvcAgentKey';

  List<String> items = ['IKEv2/IPSec MSCHAPv2', 'IKEv2/IPSec PSK', 'IKEv2/IPSec RSA', 'IKEv2/IPSec EAP-TLS'];
  List<String> certificates = ['Don\'t verify server', 'FMEKeyStore', 'FindMyMobile', 'SvcAgentKey'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name", style: TextStyle(color: Colors.white54),),
              TextField(
                controller: TextEditingController(),
                style: TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Enter profile name',
                  hintStyle: TextStyle(color: Colors.white54, fontSize: 18),
                ),
              ),
              SizedBox(height: 16,),
          
              Text("Type", style: TextStyle(color: Colors.white54),),
              DropdownButtonFormField<String>(
                value: selectedValue,
                isExpanded: true,
                items: items.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item, style: TextStyle(color: Colors.white, fontSize: 18),),
                  );
                }).toList(),
                onChanged: (val) {
                  selectedValue = val;
                },
              ),
              SizedBox(height: 16,),
          
              Text("Server address", style: TextStyle(color: Colors.white54),),
              TextField(
                controller: TextEditingController(),
                style: TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Enter address',
                  hintStyle: TextStyle(color: Colors.white54),
                ),
              ),
              SizedBox(height: 16,),
          
              Text("IPSec Identifier", style: TextStyle(color: Colors.white54),),
              TextField(
                controller: TextEditingController(),
                style: TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Not Used',
                  hintStyle: TextStyle(color: Colors.white54),
                ),
              ),
              SizedBox(height: 16,),

              Text("IPSec CA Certificate", style: TextStyle(color: Colors.white54),),
              DropdownButtonFormField<String>(
                value: selectedCertificate,
                isExpanded: true,
                items: certificates.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item, style: TextStyle(color: Colors.white, fontSize: 18),),
                  );
                }).toList(),
                onChanged: (val) {
                  selectedValue = val;
                },
              ),
              SizedBox(height: 16,),

              Text("IPSec Server Certificate", style: TextStyle(color: Colors.white54),),
              DropdownButtonFormField<String>(
                value: selectedCertificate,
                isExpanded: true,
                items: certificates.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item, style: TextStyle(color: Colors.white, fontSize: 18),),
                  );
                }).toList(),
                onChanged: (val) {
                  selectedValue = val;
                },
              ),
              SizedBox(height: 16,),
          
              Text("Username", style: TextStyle(color: Colors.white54),),
              TextField(
                controller: TextEditingController(),
                style: TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Enter username',
                  hintStyle: TextStyle(color: Colors.white54),
                ),
              ),
              SizedBox(height: 16,),
          
              Text("Password", style: TextStyle(color: Colors.white54),),
              TextField(
                controller: TextEditingController(),
                style: TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Enter password',
                  hintStyle: TextStyle(color: Colors.white54),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      _obscureText = !_obscureText;
                    },
                  ),
                ),
              ),
              SizedBox(height: 16,),
            ],
          ),
        ),
      ),
    );
  }
}