import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openvpn_client/commons/app_routes.dart';
import 'package:openvpn_client/models/server_info.dart';
import 'package:openvpn_client/utils/date_utils.dart';
import 'package:openvpn_client/utils/pref_utils.dart';
import 'package:openvpn_client/utils/toast_utils.dart';
import 'package:openvpn_client/vpn/openvpn_connection.dart';
import 'package:openvpn_client/vpn/vpn_factory.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import '../../models/ip_info.dart';
import '../widget/servers_sheet.dart';

class VpnController extends GetxController {

  OpenVpnConnection? _vpn;
  DateTime? _connectedAt;
  Timer? _durationTimer;
  bool _isRestoringState = false;
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
  var downloadSpeed = "0 kbps".obs;
  var uploadSpeed = "0 kbps".obs;

  int? _lastByteInTotal;
  int? _lastByteOutTotal;
  DateTime? _lastSpeedSampleAt;


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

    _vpn = createOpenVpnConnection(
      onVpnStatusChanged: (data) {
        if (data != null) {
          status.value = data;
          parseStatus(data);
          PrefUtils().saveVpnStats(data);
        }
      },
      onVpnStageChanged: (vpnStage, stage) {
        if (vpnStage == VPNStage.connected) {
          isConnected.value = true;
          isLoading.value = false;
          state.value = "Connected";
          PrefUtils().saveVpnStage(vpnStage);
          _ensureConnectedAt();
          _startDurationTicker();
          if(!_isRestoringState) {
            log.value += "Connected VPN\n";
            ToastUtils.showToast("Connected!!");
          }
          getVpnPing();
          getVpnLocationInfo();
        }
        else if (vpnStage == VPNStage.disconnected) {
          isConnected.value = false;
          isLoading.value = false;
          duration.value = "00:00:00";
          state.value = "Disconnected";
          PrefUtils().clearVpnStage();
          PrefUtils().clearConnectedOn();
          _stopDurationTicker();
          if(!_isRestoringState) {
            log.value += "Disconnected VPN\n";
            ToastUtils.showToast("Disconnected VPN!!");
          }
        }
        else if (vpnStage == VPNStage.error) {
          isConnected.value = false;
          isLoading.value = false;
          duration.value = "00:00:00";
          state.value = "Disconnected";
          PrefUtils().clearVpnStage();
          PrefUtils().clearConnectedOn();
          _stopDurationTicker();
          if(!_isRestoringState) {
            log.value += "Error ${stage.capitalizeFirst}\n";
            ToastUtils.showToast("Error Occurred!");
          }
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
    _restoreVpnState();
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
    if (isConnected.value) {
      unawaited(disconnect());
    } else {
      connect(openVpnContent.value);
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
      await _vpn?.connect(config, "Home Network", username: "", password: "");
    }
    catch (e) {
      duration.value = "00:00:00";
      state.value = "Disconnected";
      log.value = 'Exception: ${e.toString()}\n';
      ToastUtils.showToast("Error Occurred!");
    }
  }

  Future<void> disconnect() async {
    await _vpn?.disconnect();
    log.value += 'Disconnected.\n';
    PrefUtils().clearVpnStage();
    PrefUtils().clearConnectedOn();
    _stopDurationTicker();
    resetValues();
  }

  void parseStatus(VpnStatus data) {
    final connectedOnDate = data.connectedOn ?? _connectedAt ?? DateTime.now();
    _setConnectedAt(connectedOnDate, persist: true);
    if ((data.duration ?? '').isNotEmpty) {
      duration.value = data.duration!;
    } else {
      _syncDurationFromConnectedAt();
    }
    final totalByteIn = int.tryParse(data.byteIn ?? "0") ?? 0;
    final totalByteOut = int.tryParse(data.byteOut ?? "0") ?? 0;
    byteIn.value = (totalByteIn/(1024*1024)).toStringAsFixed(2);
    byteOut.value = (totalByteOut/(1024*1024)).toStringAsFixed(2);
    packetsIn.value = data.packetsIn!;
    packetsOut.value = data.packetsOut!;
    _updateRealtimeSpeeds(totalByteIn: totalByteIn, totalByteOut: totalByteOut);
  }

  /*Stream<Map<String,int>> packetsStream() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      yield {"in": int.parse(packetsIn.value), "out": int.parse(packetsIn.value)};
    }
  }*/


  void resetValues() {
    _stopDurationTicker();
    _connectedAt = null;
    duration.value = "00:00:00";
    state.value = "Disconnected";
    connectedOn.value = "";
    byteIn.value = "0.00";
    byteOut.value = "0.00";
    ping.value = 0;
    ipInfo.value = null;
    downloadSpeed.value = "0 kbps";
    uploadSpeed.value = "0 kbps";
    _lastByteInTotal = null;
    _lastByteOutTotal = null;
    _lastSpeedSampleAt = null;
  }

  Future<void> getVpnPing() async {
    try {
      final ProcessResult result;
      if (Platform.isWindows) {
        result = await Process.run('ping', ['-n', '1', '1.1.1.1']);
      } else {
        result = await Process.run('ping', ['-c', '1', '1.1.1.1']);
      }

      if (result.exitCode != 0) {
        return;
      }
      final output = result.stdout.toString();
      if (output.contains(RegExp(r'time[=<]1ms', caseSensitive: false))) {
        ping.value = 1;
        return;
      }
      final match =
          RegExp(r'time[=<](\d+)\s*ms', caseSensitive: false).firstMatch(output) ??
              RegExp(r'time=([\d.]+)\s*ms').firstMatch(output);
      if (match != null) {
        ping.value = double.parse(match.group(1)!).round();
      }
    } catch (e) {
      debugPrint("Ping error: $e");
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

  Future<void> _restoreVpnState() async {
    _isRestoringState = true;
    try {
      final currentStage = await PrefUtils().loadVpnStage();
      if (currentStage == VPNStage.connected) {
        final savedConnectedOn = await PrefUtils().loadConnectedOn();
        _setConnectedAt(savedConnectedOn ?? DateTime.now(), persist: savedConnectedOn == null);
        isConnected.value = true;
        isLoading.value = false;
        state.value = "Connected";
        _syncDurationFromConnectedAt();
        _startDurationTicker();
        log.value += "Restored previous VPN state\n";
        await getVpnPing();
        await getVpnLocationInfo();
      } else {
        isConnected.value = false;
        isLoading.value = false;
        state.value = "Disconnected";
        _stopDurationTicker();
      }
    } catch (_) {
      // Ignore restore errors and let callbacks drive state.
    } finally {
      _isRestoringState = false;
    }
  }

  void _setConnectedAt(DateTime dateTime, {required bool persist}) {
    _connectedAt = dateTime;
    connectedOn.value = AppDateUtils.formatVpnTime(dateTime);
    if (persist) {
      PrefUtils().saveConnectedOn(dateTime);
    }
  }

  void _ensureConnectedAt() {
    if (_connectedAt != null) {
      return;
    }
    _setConnectedAt(DateTime.now(), persist: true);
  }

  void _startDurationTicker() {
    _durationTimer?.cancel();
    _syncDurationFromConnectedAt();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _syncDurationFromConnectedAt();
    });
  }

  void _stopDurationTicker() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  void _syncDurationFromConnectedAt() {
    if (_connectedAt == null) {
      duration.value = "00:00:00";
      return;
    }
    final elapsed = DateTime.now().difference(_connectedAt!);
    final totalSeconds = elapsed.inSeconds;
    final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    duration.value = "$hours:$minutes:$seconds";
  }

  void _updateRealtimeSpeeds({
    required int totalByteIn,
    required int totalByteOut,
  }) {
    final now = DateTime.now();
    if (_lastByteInTotal == null || _lastByteOutTotal == null || _lastSpeedSampleAt == null) {
      _lastByteInTotal = totalByteIn;
      _lastByteOutTotal = totalByteOut;
      _lastSpeedSampleAt = now;
      return;
    }

    final elapsedMs = now.difference(_lastSpeedSampleAt!).inMilliseconds;
    if (elapsedMs <= 0) {
      return;
    }

    final deltaIn = (totalByteIn - _lastByteInTotal!).clamp(0, 1 << 31);
    final deltaOut = (totalByteOut - _lastByteOutTotal!).clamp(0, 1 << 31);
    final elapsedSeconds = elapsedMs / 1000.0;

    final inBitsPerSecond = (deltaIn * 8) / elapsedSeconds;
    final outBitsPerSecond = (deltaOut * 8) / elapsedSeconds;

    downloadSpeed.value = _formatBitsPerSecond(inBitsPerSecond);
    uploadSpeed.value = _formatBitsPerSecond(outBitsPerSecond);

    _lastByteInTotal = totalByteIn;
    _lastByteOutTotal = totalByteOut;
    _lastSpeedSampleAt = now;
  }

  String _formatBitsPerSecond(double bps) {
    if (bps >= 1000 * 1000) {
      return "${(bps / (1000 * 1000)).toStringAsFixed(2)} mbps";
    }
    return "${(bps / 1000).toStringAsFixed(2)} kbps";
  }

  @override
  void onClose() {
    _stopDurationTicker();
    super.onClose();
  }


}