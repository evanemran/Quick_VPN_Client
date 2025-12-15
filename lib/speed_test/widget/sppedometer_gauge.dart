import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SpeedometerGauge extends StatelessWidget {
  final RxDouble speed;
  final double maxSpeed;

  const SpeedometerGauge({
    super.key,
    required this.speed,
    this.maxSpeed = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SfRadialGauge(
        axes: [
          RadialAxis(
            minimum: 0,
            maximum: maxSpeed,
            startAngle: 130,
            endAngle: 50,
            interval: 2,
            showTicks: true,
            showLabels: true,
            axisLineStyle: const AxisLineStyle(
              thickness: 0.15,
              thicknessUnit: GaugeSizeUnit.factor,
              cornerStyle: CornerStyle.bothCurve,
            ),
            ranges: [
              GaugeRange(
                startValue: 0,
                endValue: maxSpeed * 0.4,
                color: Colors.indigo,
                startWidth: 0.15,
                endWidth: 0.15,
                sizeUnit: GaugeSizeUnit.factor,
              ),
              GaugeRange(
                startValue: maxSpeed * 0.4,
                endValue: maxSpeed * 0.75,
                color: Colors.indigoAccent,
                startWidth: 0.15,
                endWidth: 0.15,
                sizeUnit: GaugeSizeUnit.factor,
              ),
              GaugeRange(
                startValue: maxSpeed * 0.75,
                endValue: maxSpeed,
                color: Colors.blueAccent,
                startWidth: 0.15,
                endWidth: 0.15,
                sizeUnit: GaugeSizeUnit.factor,
              ),
            ],
            pointers: [
              NeedlePointer(
                value: speed.value.clamp(0, maxSpeed),
                enableAnimation: true,
                animationType: AnimationType.easeOutBack,
                animationDuration: 300,
                needleLength: 0.7,
                needleColor: Colors.red,
                knobStyle: const KnobStyle(
                  color: Colors.white,
                  knobRadius: 0.08,
                ),
              ),
            ],
            annotations: [
              GaugeAnnotation(
                angle: 90,
                positionFactor: 0.5,
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      speed.value.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                    const Text(
                      "Mbps",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}
