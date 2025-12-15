import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

import 'package:get/get_state_manager/src/simple/get_view.dart';

import '../controller/vpn_controller.dart';

class PacketsGraphWidget extends GetView<VpnController> {
  PacketsGraphWidget({super.key});

  final List<FlSpot> inSpots = [];
  final List<FlSpot> outSpots = [];
  double time = 0;
  int? lastIn;
  int? lastOut;

  void _updateGraph() {
    final currentIn = int.parse(controller.packetsIn.value);
    final currentOut = int.parse(controller.packetsOut.value);

    double ppsIn = 0;
    double ppsOut = 0;

    if (lastIn != null) {
      ppsIn = (currentIn - lastIn!).toDouble();
    }
    if (lastOut != null) {
      ppsOut = (currentOut - lastOut!).toDouble();
    }

    lastIn = currentIn;
    lastOut = currentOut;

    time += 1; // assume update every 1 second

    inSpots.add(FlSpot(time, ppsIn));
    outSpots.add(FlSpot(time, ppsOut));

    // keep only last 30 seconds
    if (inSpots.length > 30) inSpots.removeAt(0);
    if (outSpots.length > 30) outSpots.removeAt(0);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: inSpots,
              isCurved: true,
              color: Colors.green,
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
            LineChartBarData(
              spots: outSpots,
              isCurved: true,
              color: Colors.red,
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
