import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openvpn_client/themes/app_colors.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SpeedometerGauge extends StatelessWidget {
  const SpeedometerGauge({
    super.key,
    required this.speed,
    this.maxSpeed = 20,
  });

  final RxDouble speed;
  final double maxSpeed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Obx(() {
      return SfRadialGauge(
        axes: [
          RadialAxis(
            minimum: 0,
            maximum: maxSpeed,
            startAngle: 150,
            endAngle: 30,
            interval: 2,
            showTicks: false,
            showLabels: true,
            labelOffset: 18,
            axisLabelStyle: GaugeTextStyle(
              color: colors.textMuted,
              fontSize: 11,
            ),
            axisLineStyle: AxisLineStyle(
              thickness: 0.16,
              thicknessUnit: GaugeSizeUnit.factor,
              color: colors.meterTrack,
              cornerStyle: CornerStyle.bothCurve,
            ),
            ranges: [
              GaugeRange(
                startValue: 0,
                endValue: maxSpeed * 0.4,
                color: colors.secondaryAccent,
                startWidth: 0.16,
                endWidth: 0.16,
                sizeUnit: GaugeSizeUnit.factor,
              ),
              GaugeRange(
                startValue: maxSpeed * 0.4,
                endValue: maxSpeed * 0.75,
                color: colors.accent,
                startWidth: 0.16,
                endWidth: 0.16,
                sizeUnit: GaugeSizeUnit.factor,
              ),
              GaugeRange(
                startValue: maxSpeed * 0.75,
                endValue: maxSpeed,
                color: colors.success,
                startWidth: 0.16,
                endWidth: 0.16,
                sizeUnit: GaugeSizeUnit.factor,
              ),
            ],
            pointers: [
              NeedlePointer(
                value: speed.value.clamp(0, maxSpeed),
                enableAnimation: true,
                animationType: AnimationType.easeOutBack,
                animationDuration: 320,
                needleLength: 0.68,
                needleColor: colors.textPrimary,
                knobStyle: KnobStyle(
                  color: colors.surface,
                  borderColor: colors.accent,
                  borderWidth: 0.03,
                  knobRadius: 0.08,
                ),
                tailStyle: TailStyle(
                  color: colors.accent,
                  width: 7,
                  length: 0.16,
                ),
              ),
            ],
            annotations: [
              GaugeAnnotation(
                angle: 90,
                positionFactor: 0.9,
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      speed.value.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      "Mbps",
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textMuted,
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
