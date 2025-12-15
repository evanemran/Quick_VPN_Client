import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../models/ip_info.dart';

class SpeedTestController extends GetxController {
  final downloadSpeedMbps = 0.0.obs;
  final isTesting = false.obs;
  var ipInfo = Rxn<IpInfo>();

  HttpClient? _client;
  int _bytesReceived = 0;
  late Stopwatch _stopwatch;

  Duration animationDuration = Duration(milliseconds: 100);

  @override
  void onInit() {
    super.onInit();
    getVpnLocationInfo();
  }

  /// Start speed test
  Future<void> startSpeedTest() async {
    if (isTesting.value) return;

    isTesting.value = true;
    downloadSpeedMbps.value = 0;
    _bytesReceived = 0;
    _stopwatch = Stopwatch()..start();

    _client = HttpClient();

    try {
      // Very fast CDN test file (Cloudflare)
      final request = await _client!.getUrl(
        Uri.parse("https://speed.cloudflare.com/__down?bytes=50000000"),
      );

      final response = await request.close();

      response.listen(
            (chunk) {
          _bytesReceived += chunk.length;

          final elapsedSeconds =
              _stopwatch.elapsedMilliseconds / 1000;

          if (elapsedSeconds > 0) {
            final mbps =
                (_bytesReceived * 8) / elapsedSeconds / 1000000;
            downloadSpeedMbps.value = mbps;
          }
        },
        onDone: stopSpeedTest,
        onError: (_) => stopSpeedTest(),
        cancelOnError: true,
      );
    } catch (_) {
      stopSpeedTest();
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

  /// Stop speed test
  void stopSpeedTest() {
    _stopwatch.stop();
    _client?.close(force: true);
    downloadSpeedMbps.value = 0;
    isTesting.value = false;
  }
}
