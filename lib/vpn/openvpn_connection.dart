import 'package:openvpn_flutter/openvpn_flutter.dart';

/// Platform VPN backend: mobile uses [openvpn_flutter]; Windows runs `openvpn.exe`.
abstract class OpenVpnConnection {
  Future<void> initialize({
    String? groupIdentifier,
    String? providerBundleIdentifier,
    String? localizedDescription,
  });

  Future<void> connect(
    String config,
    String name, {
    String? username,
    String? password,
  });

  Future<void> disconnect();
}

class MobileOpenVpnConnection implements OpenVpnConnection {
  MobileOpenVpnConnection(this._vpn);

  final OpenVPN _vpn;

  @override
  Future<void> initialize({
    String? groupIdentifier,
    String? providerBundleIdentifier,
    String? localizedDescription,
  }) {
    return _vpn.initialize(
      groupIdentifier: groupIdentifier,
      providerBundleIdentifier: providerBundleIdentifier,
      localizedDescription: localizedDescription,
    );
  }

  @override
  Future<void> connect(
    String config,
    String name, {
    String? username,
    String? password,
  }) {
    return _vpn.connect(
      config,
      name,
      username: username,
      password: password,
    );
  }

  @override
  Future<void> disconnect() async {
    _vpn.disconnect();
  }
}
