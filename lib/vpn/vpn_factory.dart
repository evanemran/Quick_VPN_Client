import 'dart:io';

import 'package:openvpn_flutter/openvpn_flutter.dart';

import 'openvpn_connection.dart';
import 'windows_openvpn_connection.dart';

OpenVpnConnection createOpenVpnConnection({
  required void Function(VpnStatus? data) onVpnStatusChanged,
  required void Function(VPNStage stage, String rawStage) onVpnStageChanged,
}) {
  if (Platform.isWindows) {
    return WindowsOpenVpnConnection(
      onVpnStatusChanged: onVpnStatusChanged,
      onVpnStageChanged: onVpnStageChanged,
    );
  }
  return MobileOpenVpnConnection(
    OpenVPN(
      onVpnStatusChanged: onVpnStatusChanged,
      onVpnStageChanged: onVpnStageChanged,
    ),
  );
}
