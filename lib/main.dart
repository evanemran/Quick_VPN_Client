import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openvpn_client/themes/app_colors.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';
import 'package:toastification/toastification.dart';
import 'commons/app_routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: GetMaterialApp(
        title: "Quick VPN",
        theme: ThemeData(
          colorSchemeSeed: AppColors.primaryColor,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.vpnPage,
        getPages: AppRoutes.pages,
      ),
    );
  }
}

/*class VpnPage extends StatefulWidget {
  @override
  _VpnPageState createState() => _VpnPageState();
}

class _VpnPageState extends State<VpnPage> {
  OpenVPN? _vpn;
  String _log = '';
  VpnStatus? _status;
  String? _server;

  @override
  void initState() {
    super.initState();
    _vpn = OpenVPN(
      onVpnStatusChanged: (data) {
        setState(() {
          _status = data;
        });
      },
      onVpnStageChanged: (v, stage) {
        setState(() {
          _log += "Stage: $stage\n";
        });
      },
    );
  }

  Future<void> _selectOvpnFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      final config = await file.readAsString();
      final server = _extractRemoteAddress(config);
      setState(() {
        _server = server;
        _log = 'Loaded .ovpn for: $server\n';
      });

      await _vpn?.initialize(
        groupIdentifier: "",
        providerBundleIdentifier: "",
        localizedDescription: "Flutter VPN",
      );

      _vpn?.connect(config, "vpn_profile", username: "", password: "");
    }
  }

  String? _extractRemoteAddress(String config) {
    final lines = config.split('\n');
    for (var line in lines) {
      if (line.trim().startsWith('remote')) {
        final parts = line.trim().split(' ');
        return parts.length > 1 ? parts[1] : null;
      }
    }
    return null;
  }

  void _disconnect() {
    _vpn?.disconnect();
    setState(() {
      _log += 'Disconnected.\n';
    });
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _status?.toString() ?? "Unknown";
    return Scaffold(
      appBar: AppBar(title: Text('VPN Client')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _selectOvpnFile,
              child: Text("Select .ovpn File & Connect"),
            ),
            SizedBox(height: 10),
            Text("Server: ${_server ?? 'Not selected'}"),
            SizedBox(height: 10),
            Text("Status: $statusText"),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _disconnect,
              child: Text("Disconnect"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(8),
                  color: Colors.black,
                  child: Text(
                    _log,
                    style: TextStyle(color: Colors.greenAccent),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/
