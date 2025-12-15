import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:openvpn_client/commons/app_routes.dart';
import 'package:openvpn_client/models/server_info.dart';
import 'package:openvpn_client/utils/date_utils.dart';
import 'package:openvpn_client/utils/pref_utils.dart';
import 'package:openvpn_client/utils/toast_utils.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import '../../models/ip_info.dart';
import '../../models/vpn_location_info.dart';
import '../widget/servers_sheet.dart';

class VpnController extends GetxController {

  OpenVPN? _vpn;
  var log = "Logs:\n".obs;
  var status = Rxn<VpnStatus>();
  var ipInfo = Rxn<IpInfo>();
  var server = "Unknown".obs;
  var openVpnContent = "".obs;
  var isConnected = false.obs;
  var isLoading = false.obs;

  final vpnStage = VPNStage.disconnected.obs;

  var connectedOn = "N/A".obs;
  var duration = "00:00:00".obs;
  var state = "Disconnected".obs;
  var byteIn = "0.00".obs;
  var byteOut = "0.00".obs;
  var packetsIn = "0.00".obs;
  var packetsOut = "0.00".obs;
  var ping = 0.obs;


  // Demo List
  var allServers = <ServerInfo> [
    ServerInfo("Home", "172.254.64.110", "🏡", "4 ms"),
    ServerInfo("Office", "10.74.55.36", "🏢", "17 ms"),
    ServerInfo("Workstation", "192.168.0.115", "🖥️", "6 ms"),
  ].obs;
  var selectedServer = Rxn<ServerInfo>();

  @override
  void onInit() {
    super.onInit();
    initVpnProfile();

    _vpn = OpenVPN(
      onVpnStatusChanged: (data) {
        if(isConnected.value) {
          status.value = data;
          parseStatus(data!);
        }
      },
      onVpnStageChanged: (vpnStage, stage) {
        if (vpnStage == VPNStage.connected) {
          isConnected.value = true;
          isLoading.value = false;
          log.value += "Connected VPN\n";
          ToastUtils.showToast("Connected!!");
          getVpnPing();
          getVpnLocationInfo();
        }
        else if (vpnStage == VPNStage.disconnected) {
          isConnected.value = false;
          isLoading.value = false;
          duration.value = "00:00:00";
          state.value = "Disconnected";
          log.value += "Disconnected VPN\n";
          ToastUtils.showToast("Disconnected VPN!!");
        }
        else if (vpnStage == VPNStage.error) {
          isConnected.value = false;
          isLoading.value = false;
          duration.value = "00:00:00";
          state.value = "Disconnected";
          log.value += "Error ${stage.capitalizeFirst}\n";
          ToastUtils.showToast("Error Occurred!");
        }
        else if (vpnStage == VPNStage.vpn_generate_config) {
        isConnected.value = false;
        isLoading.value = true;
        duration.value = "00:00:00";
        state.value = "Connecting...";
        log.value += "Configuring Network\n";
        }
        // log.value += "Stage: $stage\n";
      },
    );
  }

  /*Future<void> restoreVpnState() async {
    final currentStage = await openVPN.vpnStageSnapshot();
    vpnStage.value = currentStage;

    if (currentStage == VPNStage.connected) {
      final stats = await openVPN.vpnStatsSnapshot();
      byteIn.value = stats.byteIn;
      byteOut.value = stats.byteOut;

      final prefs = await SharedPreferences.getInstance();
      connectedServer.value = prefs.getString('connected_server') ?? '';
      final dateStr = prefs.getString('connected_on');
      if (dateStr != null) {
        connectedOn.value = DateTime.parse(dateStr);
      }
    }
  }*/

  void toggleConnection() {
    if(isConnected.value) {
      disconnect();
      isConnected.value = false;
    }
    else {
      connect(openVpnContent.value);
      // isConnected.value = true; //moved to connect
    }
  }

  void updateSelectedServer(ServerInfo server) {
    selectedServer.value = server;
  }

  void showServerSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ServerBottomSheet(
          servers: ['🏡 Home', '🏢 Office', '🖥️ Workstation'],
        );
      },
    );
  }

  void initVpnProfile() async {
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }
    final content = await PrefUtils().loadOpenVpnContent();
    if (content != null) {
      openVpnContent.value = content;
      server.value = extractRemoteAddress(content)??"Unknown";
    }
  }

  Future<void> initAddProfile() async {

    final result = await Get.toNamed(AppRoutes.addProfilePage);
    openVpnContent.value = result;
    toggleConnection();
  }

  void initSpeedTest() {
    Get.toNamed(AppRoutes.speedTestPage);
  }

  String? extractRemoteAddress(String config) {
    final lines = config.split('\n');
    for (var line in lines) {
      if (line.trim().startsWith('remote ')) {
        final parts = line.trim().split(' ');
        return parts.length > 1 ? parts[1] : null;
      }
    }
    return null;
  }

  Future<void> connect(String config) async {

    try {
      final connectedServer = extractRemoteAddress(config);
      server.value = connectedServer ?? "Unknown";
      log.value = 'Loaded config for: $server\n';

      await _vpn?.initialize(
        groupIdentifier: "",
        providerBundleIdentifier: "",
        localizedDescription: "Flutter VPN",
      );
      _vpn?.connect(config, "Home Network", username: "", password: "");
    }
    catch (e) {
      duration.value = "00:00:00";
      state.value = "Disconnected";
      log.value = 'Exception: ${e.toString()}\n';
      ToastUtils.showToast("Error Occurred!");
    }
  }

  void disconnect() {
    _vpn?.disconnect();
    log.value += 'Disconnected.\n';
    resetValues();
  }

  void parseStatus(VpnStatus data) {
    connectedOn.value = AppDateUtils.formatVpnTime(data.connectedOn??DateTime.now());
    duration.value = data.duration!;
    byteIn.value = (double.parse(data.byteIn!)/(1024*1024)).toStringAsFixed(2);
    byteOut.value = (double.parse(data.byteOut!)/(1024*1024)).toStringAsFixed(2);
    packetsIn.value = data.packetsIn!;
    packetsOut.value = data.packetsOut!;
  }

  /*Stream<Map<String,int>> packetsStream() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      yield {"in": int.parse(packetsIn.value), "out": int.parse(packetsIn.value)};
    }
  }*/


  void resetValues() {
    duration.value = "00:00:00";
    state.value = "Disconnected";
    connectedOn.value = "";
    byteIn.value = "0.00";
    byteOut.value = "0.00";
    ping.value = 0;
    ipInfo.value = null;
  }

  Future<void> getVpnPing() async {
    try {
      // Linux / Android / iOS compatible
      final result = await Process.run(
        'ping',
        ['-c', '1', '1.1.1.1'], // Cloudflare DNS
      );

      if (result.exitCode == 0) {
        final output = result.stdout.toString();

        // Extract time=XX ms
        final regex = RegExp(r'time=([\d.]+)\s*ms');
        final match = regex.firstMatch(output);

        if (match != null) {
          ping.value = double.parse(match.group(1)!).round();
        }
      }
    } catch (e) {
      print("Ping error: $e");
    }
  }

  Future<IpInfo?> getVpnLocationInfo() async {
    try {
      final response = await http.get(
        Uri.parse('https://ipwho.is/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          ipInfo.value = IpInfo.fromJson(data);
          return IpInfo.fromJson(data);
        }
      }
    } catch (e) {
      debugPrint('VPN location error: $e');
    }
    return null;
  }


}