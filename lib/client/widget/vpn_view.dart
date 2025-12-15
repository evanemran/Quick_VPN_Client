import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:openvpn_client/client/controller/vpn_controller.dart';
import 'package:openvpn_client/client/widget/app_drawer.dart';
import 'package:openvpn_client/client/widget/packets_graph_widget.dart';
import 'package:openvpn_client/client/widget/power_button.dart';

import '../../themes/app_colors.dart';
import 'flip_timer.dart';

class VpnView extends GetView<VpnController> {
  const VpnView({super.key});


  Widget _buildFullServerList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: controller.allServers.length,
      itemBuilder: (context, index) {
        final server = controller.allServers[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(16),
            color: AppColors.accentColorTransparent,
            child: ListTile(
              title: Text(
                '${server.icon} ${server.name}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                server.ip,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min, // REQUIRED
                children: [
                  Text(
                    server.ping,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Image.asset(
                    "assets/images/signal.png",
                    height: 18,
                    width: 18,
                    color: Colors.white54,
                  ),
                ],
              ),
              onTap: () {
                controller.selectedServer.value = server;
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          /*leading: Builder(
            builder: (context) {
              return IconButton(onPressed: () {
                Scaffold.of(context).openDrawer();
              }, icon: ImageIcon(AssetImage("assets/images/menu_icon.png"), color: Colors.white,));
            }
          ),*/
          actions: [
            IconButton(onPressed: controller.initSpeedTest, icon: ImageIcon(AssetImage("assets/images/speed.png"), color: Colors.white,)),
            SizedBox(width: 4,),
            IconButton(onPressed: controller.initAddProfile, icon: ImageIcon(AssetImage("assets/images/add_icon.png"), color: Colors.white,)),
            SizedBox(width: 4,),
          ],
          title: Text(
            'Quick VPN',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
          )),
      /*drawer: AppDrawer(),*/
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
                  Obx(() => controller.isConnected.value ? FlipTime(controller.duration.value) : Text(controller.state.value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),)),
                  //Obx(()=> Text(controller.duration.value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),)),
                  SizedBox(height: 10),
                  Obx(()=>Text("IP: ${controller.server ?? 'Not selected'}", style: TextStyle(color: Colors.white),)),
                  SizedBox(height: 10),
                  Obx(()=>Text("Connected on: ${controller.connectedOn ?? 'Not selected'}", style: TextStyle(color: Colors.white),)),
                  SizedBox(height: 20),
                  Obx(() => PowerButton(
                    isConnected: controller.isConnected.value,
                    isLoading: controller.isLoading.value,
                    onPressed: () {
                      controller.toggleConnection();
                    },
                  )),
                  SizedBox(height: 20),
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
                              Image.asset("assets/images/signal.png", height: 28, width: 28, color: Colors.white54,),
                              SizedBox(width: 8,),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Ping", style: TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.normal),),
                                  Obx(()=> Text("${controller.ping.value} ms", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),)),
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
                              Image.asset("assets/images/pin.png", height: 28, width: 28, color: Colors.white54,),
                              SizedBox(width: 8,),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Location", style: TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.normal),),
                                  Obx(()=> Text(controller.ipInfo.value != null ? "${controller.ipInfo.value!.flag!.emoji ?? '🌍'} ${controller.ipInfo.value!.city}, ${controller.ipInfo.value!.countryCode}" : "N/A", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),)),
                                  Obx(()=> Text(controller.ipInfo.value != null ? "${controller.ipInfo.value!.connection!.isp}" : "N/A", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.normal),)),
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
                  /*PacketsGraphWidget(),*/
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
                backgroundColor: AppColors.transparent,
                isScrollControlled: true,
                context: context,
                builder: (_) => SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: _buildFullServerList(context)
                ),
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
