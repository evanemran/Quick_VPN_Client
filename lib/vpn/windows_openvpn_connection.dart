import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:openvpn_flutter/openvpn_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'openvpn_connection.dart';

/// Runs the system or bundled OpenVPN binary on Windows using the management interface.
/// Requires OpenVPN for Windows (TAP driver) or `openvpn.exe` next to the app executable.
class WindowsOpenVpnConnection implements OpenVpnConnection {
  WindowsOpenVpnConnection({
    required this.onVpnStatusChanged,
    required this.onVpnStageChanged,
  });

  final void Function(VpnStatus? data) onVpnStatusChanged;
  final void Function(VPNStage stage, String rawStage) onVpnStageChanged;

  Process? _process;
  Socket? _mgmt;
  StreamSubscription<String>? _mgmtLines;
  StreamSubscription<List<int>>? _outSub;
  StreamSubscription<List<int>>? _errSub;
  Timer? _pollTimer;
  DateTime? _connectedAt;
  bool _connectedEmitted = false;
  int _lastByteIn = 0;
  int _lastByteOut = 0;
  bool _intentionalExit = false;

  @override
  Future<void> initialize({
    String? groupIdentifier,
    String? providerBundleIdentifier,
    String? localizedDescription,
  }) async {
    onVpnStatusChanged(VpnStatus.empty());
  }

  @override
  Future<void> connect(
    String config,
    String name, {
    String? username,
    String? password,
  }) async {
    await _resetSession();
    _intentionalExit = false;
    _connectedEmitted = false;
    onVpnStageChanged(VPNStage.vpn_generate_config, 'preparing');

    final exe = await _resolveOpenVpnExecutable();
    if (exe == null) {
      onVpnStageChanged(
        VPNStage.error,
        'OpenVPN executable not found. Install OpenVPN for Windows '
        'or place openvpn.exe next to this app.',
      );
      return;
    }

    final tempDir = await getTemporaryDirectory();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final configPath = p.join(tempDir.path, 'quick_vpn_$stamp.ovpn');
    _configPath = configPath;

    final server = ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final bound = await server;
    final mgmtPort = bound.port;
    await bound.close();

    final augmented = _appendManagement(config, mgmtPort);
    await File(configPath).writeAsString(augmented);

    String? authPath;
    final u = username?.trim() ?? '';
    final pw = password?.trim() ?? '';
    if (u.isNotEmpty || pw.isNotEmpty) {
      authPath = p.join(tempDir.path, 'quick_vpn_auth_$stamp.txt');
      _authPath = authPath;
      await File(authPath).writeAsString('$u\n$pw\n');
    }

    onVpnStageChanged(VPNStage.connecting, 'starting_openvpn');

    final args = <String>[
      '--config',
      configPath,
      '--management',
      '127.0.0.1',
      '$mgmtPort',
    ];
    if (authPath != null) {
      args.addAll(['--auth-user-pass', authPath]);
    }

    try {
      _process = await Process.start(
        exe,
        args,
        mode: ProcessStartMode.normal,
      );
    } catch (e) {
      onVpnStageChanged(VPNStage.error, 'start_failed: $e');
      await _cleanupTempFiles();
      return;
    }

    _outSub = _process!.stdout.listen((bytes) {
      final t = utf8.decode(bytes, allowMalformed: true);
      for (final line in t.split(RegExp(r'\r?\n'))) {
        if (line.contains('Initialization Sequence Completed')) {
          _emitConnectedIfNeeded();
        }
      }
    });

    _errSub = _process!.stderr.listen((bytes) {
      final t = utf8.decode(bytes, allowMalformed: true);
      for (final line in t.split(RegExp(r'\r?\n'))) {
        final s = line.trim();
        if (s.isEmpty) continue;
        if (s.toLowerCase().contains('fatal')) {
          onVpnStageChanged(VPNStage.error, s);
        }
      }
    });

    unawaited(_process!.exitCode.then((code) async {
      if (code != 0 && !_connectedEmitted && !_intentionalExit) {
        onVpnStageChanged(VPNStage.error, _describeOpenVpnExitCode(code));
      }
      await _tearDown();
      if (_connectedEmitted && !_intentionalExit) {
        onVpnStageChanged(VPNStage.disconnected, 'process_exit');
      }
      onVpnStatusChanged(VpnStatus.empty());
      _intentionalExit = false;
    }));

    Socket? mgmt;
    for (var i = 0; i < 80; i++) {
      try {
        mgmt = await Socket.connect(
          '127.0.0.1',
          mgmtPort,
          timeout: const Duration(milliseconds: 500),
        );
        break;
      } catch (_) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
    }

    if (mgmt == null) {
      onVpnStageChanged(VPNStage.error, 'management_interface_unavailable');
      await _forceKill();
      await _cleanupTempFiles();
      return;
    }

    _mgmt = mgmt;
    final lineStream = mgmt
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    _mgmtLines = lineStream.listen(
      _onMgmtLine,
      onError: (_) {},
      onDone: () {},
    );

    _mgmt!.write('bytecount 1\n');
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      try {
        _mgmt?.write('state\n');
      } catch (_) {}
      _pushStatus();
    });
  }

  void _onMgmtLine(String line) {
    if (line.startsWith('>BYTECOUNT:') || line.startsWith('BYTECOUNT:')) {
      final payload = line.startsWith('>BYTECOUNT:')
          ? line.substring('>BYTECOUNT:'.length)
          : line.substring('BYTECOUNT:'.length);
      final parts = payload.split(',');
      if (parts.length >= 2) {
        _lastByteIn = int.tryParse(parts[0].trim()) ?? _lastByteIn;
        _lastByteOut = int.tryParse(parts[1].trim()) ?? _lastByteOut;
        _pushStatus();
      }
      return;
    }

    if (line.startsWith('>STATE:')) {
      final rest = line.substring('>STATE:'.length);
      final parts = rest.split(',');
      if (parts.length >= 2) {
        final stateName = parts[1].trim();
        if (stateName == 'CONNECTED') {
          _emitConnectedIfNeeded();
        }
        if (stateName == 'EXITING' || stateName == 'RECONNECTING') {
          onVpnStageChanged(VPNStage.disconnecting, line);
        }
      }
      return;
    }

    if (line.contains('Initialization Sequence Completed')) {
      _emitConnectedIfNeeded();
    }
  }

  void _emitConnectedIfNeeded() {
    if (_connectedEmitted) return;
    _connectedEmitted = true;
    _connectedAt = DateTime.now();
    onVpnStageChanged(VPNStage.connected, 'CONNECTED');
    _pushStatus();
  }

  void _pushStatus() {
    if (!_connectedEmitted || _connectedAt == null) {
      return;
    }
    final d = DateTime.now().difference(_connectedAt!);
    final dur =
        '${d.inHours.toString().padLeft(2, '0')}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
    onVpnStatusChanged(VpnStatus(
      connectedOn: _connectedAt,
      duration: dur,
      byteIn: '$_lastByteIn',
      byteOut: '$_lastByteOut',
      packetsIn: '$_lastByteIn',
      packetsOut: '$_lastByteOut',
    ));
  }

  @override
  Future<void> disconnect() async {
    _intentionalExit = true;
    await _forceKill();
    await _tearDown();
    onVpnStageChanged(VPNStage.disconnected, 'user_disconnect');
    onVpnStatusChanged(VpnStatus.empty());
    await _cleanupTempFiles();
  }

  Future<void> _resetSession() async {
    _intentionalExit = true;
    await _forceKill();
    await _tearDown();
    await _cleanupTempFiles();
  }

  Future<void> _forceKill() async {
    final proc = _process;
    _process = null;
    if (proc != null) {
      try {
        proc.kill(ProcessSignal.sigterm);
      } catch (_) {}
      try {
        await proc.exitCode.timeout(const Duration(seconds: 3), onTimeout: () {
          try {
            proc.kill(ProcessSignal.sigkill);
          } catch (_) {}
          return -1;
        });
      } catch (_) {}
    }
  }

  Future<void> _tearDown() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    await _mgmtLines?.cancel();
    _mgmtLines = null;
    await _outSub?.cancel();
    await _errSub?.cancel();
    _outSub = null;
    _errSub = null;
    try {
      await _mgmt?.close();
    } catch (_) {}
    _mgmt = null;
    _connectedEmitted = false;
    _connectedAt = null;
    _lastByteIn = 0;
    _lastByteOut = 0;
  }

  String? _configPath;
  String? _authPath;

  Future<void> _cleanupTempFiles() async {
    try {
      final c = _configPath;
      if (c != null && File(c).existsSync()) await File(c).delete();
    } catch (_) {}
    try {
      final a = _authPath;
      if (a != null && File(a).existsSync()) await File(a).delete();
    } catch (_) {}
    _configPath = null;
    _authPath = null;
  }

  String _appendManagement(String config, int port) {
    final trimmed = config.trimRight();
    final hasMgmt = RegExp(r'^\s*management\s', multiLine: true).hasMatch(config);
    if (hasMgmt) {
      return '$trimmed\n';
    }
    return '$trimmed\n\nmanagement 127.0.0.1 $port\n';
  }

  Future<String?> _resolveOpenVpnExecutable() async {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final cwd = Directory.current.path;
    final candidates = <String>[
      // CMake copies `<project>/openvpn/` next to openvpn_client.exe (see windows/CMakeLists.txt).
      p.join(exeDir, 'openvpn', 'openvpn.exe'),
      // `flutter run` / IDE: current directory is usually the project root.
      p.join(cwd, 'openvpn', 'openvpn.exe'),
      p.join(exeDir, 'openvpn.exe'),
      p.join(exeDir, 'data', 'flutter_assets', 'openvpn', 'openvpn.exe'),
      p.join(cwd, 'openvpn.exe'),
      r'C:\Program Files\OpenVPN\bin\openvpn.exe',
      r'C:\Program Files (x86)\OpenVPN\bin\openvpn.exe',
    ];
    for (final c in candidates) {
      if (File(c).existsSync()) {
        return c;
      }
    }
    try {
      final r = await Process.run('where', ['openvpn.exe'], runInShell: true);
      if (r.exitCode == 0) {
        final line = r.stdout.toString().split(RegExp(r'\r?\n')).firstWhere(
              (e) => e.trim().isNotEmpty,
              orElse: () => '',
            );
        if (line.isNotEmpty && File(line.trim()).existsSync()) {
          return line.trim();
        }
      }
    } catch (_) {}
    return null;
  }

  /// Maps common Windows process exit codes to actionable text.
  static String _describeOpenVpnExitCode(int code) {
    // STATUS_DLL_NOT_FOUND — usually openvpn.exe without libcrypto/libssl etc.
    const statusDllNotFound = -1073741515;
    if (code == statusDllNotFound) {
      return 'OpenVPN failed to start: a required DLL is missing. Do not copy '
          'only openvpn.exe — copy every file from the OpenVPN installation '
          '"bin" folder (same folder as openvpn.exe), or install OpenVPN from '
          'openvpn.net and use the default location.';
    }
    return 'exit_code_$code';
  }
}
