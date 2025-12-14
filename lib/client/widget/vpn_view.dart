import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:openvpn_client/client/controller/vpn_controller.dart';
import 'package:openvpn_client/client/widget/power_button.dart';
import 'package:openvpn_client/commons/app_colors.dart';

class VpnView extends GetView<VpnController> {
  const VpnView({super.key});


  Widget _buildFullServerList(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: controller.allServers.map((server) {
        return ListTile(
          title: Text(server,style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),),
          onTap: () {
            controller .selectedServer.value = server;
            Navigator.pop(context);
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          leading: IconButton(onPressed: () {}, icon: ImageIcon(AssetImage("assets/images/menu_icon.png"), color: Colors.white,)),
          actions: [
            IconButton(onPressed: controller.initAddProfile, icon: ImageIcon(AssetImage("assets/images/add_icon.png"), color: Colors.white,)),
            SizedBox(width: 4,)
          ],
          title: Text(
            'Quick VPN',
            style: TextStyle(
              color: Colors.white,
            ),
          )),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/background.png',
            fit: BoxFit.cover,
            color: Colors.white24,
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  Obx(()=> Text(controller.duration.value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),)),
                  SizedBox(height: 10),
                  Obx(() => PowerButton(
                    isConnected: controller.isConnected.value,
                    isLoading: controller.isLoading.value,
                    onPressed: () {
                      controller.toggleConnection();
                    },
                  )),
                  SizedBox(height: 10),
                  Obx(()=>Text("Server: ${controller.server ?? 'Not selected'}", style: TextStyle(color: Colors.white),)),
                  SizedBox(height: 10),
                  Obx(()=>Text("Connected on: ${controller.connectedOn ?? 'Not selected'}", style: TextStyle(color: Colors.white),)),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(8),
                          color: Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset("assets/images/down_icon.png", height: 28, width: 28, color: Colors.white54,),
                              SizedBox(width: 8,),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Download", style: TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.normal),),
                                  Obx(()=> Text("${controller.byteIn.value} Mb", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),)),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(width: 1, height: 20, color: Colors.white24,),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(8),
                          color: Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset("assets/images/up_icon.png", height: 28, width: 28, color: Colors.white54,),
                              SizedBox(width: 8,),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Upload", style: TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.normal),),
                                  Obx(()=> Text("${controller.byteOut.value} Mb", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),)),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  //Obx(()=> Text("Status: ${controller.status}", style: TextStyle(color: Colors.white),)),
                  SizedBox(height: 10),
                  /*ElevatedButton(
                onPressed: controller.disconnect,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text("Disconnect", style: TextStyle(color: Colors.white),),
              ),*/
                  SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: SingleChildScrollView(
                      child: Container(
                        width: double.maxFinite,
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(8),
                        color: Colors.black26,
                        child: Obx(()=> Text(
                          controller.log.value,
                          style: TextStyle(color: Colors.white38),
                        )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(bottom: 10, left: 16, right: 16 ,child: ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                backgroundColor: AppColors.primaryColor,
                context: context,
                builder: (_) => _buildFullServerList(context),
              );
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
            child: Text('Change Server'),
          )),
        ],
      ),
    );
  }
}
