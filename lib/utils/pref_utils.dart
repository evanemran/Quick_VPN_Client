import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefUtils {
  Future<String?> pickAndSaveOpenVpnFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final File selectedFile = File(result.files.single.path!);
      final appDir = await getApplicationDocumentsDirectory();

      // Copy file to app storage
      final savedFile = await selectedFile.copy('${appDir.path}/vpn_profile.ovpn');

      // Save the new path in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ovpn_path', savedFile.path);

      return savedFile.path;
    }

    return null;
  }

  Future<String?> getSavedOpenVpnPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('ovpn_path');
  }

  Future<String?> loadOpenVpnContent() async {
    final path = await getSavedOpenVpnPath();
    if (path == null) return null;

    final file = File(path);
    if (!await file.exists()) return null;

    return file.readAsString();
  }


  Future<void> saveVpnStage(VPNStage stage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vpn_stage', stage.name); // saves as string like 'connected'
  }

  Future<void> saveVpnStats(VpnStatus stat) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vpn_stats', jsonEncode(stat.toJson())); // saves as string like 'connected'
  }

  Future<VPNStage> loadVpnStage() async {
    final prefs = await SharedPreferences.getInstance();
    final stageStr = prefs.getString('vpn_stage');

    // Fallback to disconnected if not found
    return VPNStage.values.firstWhere(
          (e) => e.name == stageStr,
      orElse: () => VPNStage.disconnected,
    );
  }

  Future<VpnStatus?> loadVpnStats() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStat = prefs.getString('vpn_stats');
    if (jsonStat == null) return null;
    jsonDecode(jsonStat);
    return VpnStatus(duration: "");
  }

  Future<void> clearVpnStage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('vpn_stage');
  }

  Future<void> saveConnectedOn(DateTime connectedOn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('vpn_connected_on_ms', connectedOn.millisecondsSinceEpoch);
  }

  Future<DateTime?> loadConnectedOn() async {
    final prefs = await SharedPreferences.getInstance();
    final connectedOnMs = prefs.getInt('vpn_connected_on_ms');
    if (connectedOnMs == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(connectedOnMs);
  }

  Future<void> clearConnectedOn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('vpn_connected_on_ms');
  }
}