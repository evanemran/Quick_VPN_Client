import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openvpn_client/speed_test/controller/speed_test_controller.dart';
import 'package:openvpn_client/speed_test/widget/sppedometer_gauge.dart';
import 'package:openvpn_client/themes/app_colors.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SpeedTestWidget extends GetView<SpeedTestController> {
  const SpeedTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(onPressed: () => Get.back(), icon: ImageIcon(AssetImage("assets/images/ic_back.png"), color: Colors.white,)),
        title: Text('Quick Speed Test', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  SpeedometerGauge(
                    speed: controller.downloadSpeedMbps,
                    maxSpeed: 20,
                  ),
                  const SizedBox(height: 16),

                ],
              ),
              Obx(() => controller.ipInfo.value != null ? Column(
                children: [
                  Text(controller.ipInfo.value!.ip ?? "", style: TextStyle(color: AppColors.white, fontSize: 14),),
                  SizedBox(height: 8,),
                  Text(controller.ipInfo.value!.region ?? "", style: TextStyle(color: AppColors.white, fontSize: 14),),
                  SizedBox(height: 8,),
                  Text("${controller.ipInfo.value!.flag!.emoji} ${controller.ipInfo.value!.country}, ${controller.ipInfo.value!.continent}", style: TextStyle(color: AppColors.white, fontSize: 14),),
                  SizedBox(height: 8,),
                  Text("${controller.ipInfo.value!.connection!.isp}", style: TextStyle(color: AppColors.white, fontSize: 14),),
                  SizedBox(height: 8,),
                  Text("${controller.ipInfo.value!.connection!.domain}", style: TextStyle(color: AppColors.white, fontSize: 14),)
                ],
              ) : SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.accentColor,),))
            ],
          ),
          Positioned(bottom: 10, left: 16, right: 16, child: Obx(() => ElevatedButton(
            onPressed: controller.isTesting.value
                ? controller.stopSpeedTest
                : controller.startSpeedTest,
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
            child: Text(controller.isTesting.value ? "STOP" : "START"),
          )),)
        ],
      ),
    );
  }
}
