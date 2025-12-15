import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:openvpn_client/speed_test/controller/speed_test_controller.dart';

class SpeedTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SpeedTestController>(() => SpeedTestController());
  }
}