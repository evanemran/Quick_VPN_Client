import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openvpn_client/speed_test/controller/speed_test_controller.dart';
import 'package:openvpn_client/speed_test/widget/sppedometer_gauge.dart';
import 'package:openvpn_client/themes/app_colors.dart';

import '../../client/controller/vpn_controller.dart';
import '../../themes/theme_controller.dart';

class SpeedTestWidget extends GetView<SpeedTestController> {
  const SpeedTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      /*appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Quick Speed Test'),
      ),*/
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: colors.pageGradient),
        child: SafeArea(
          top: false,
          child: Stack(
            children: [
              const _SpaceBackdrop(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                child: Column(
                  children: [
                    _TopBar(),
                    _GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Network throughput',
                            style: TextStyle(
                              color: colors.textMuted,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SpeedometerGauge(
                            speed: controller.downloadSpeedMbps,
                            maxSpeed: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: Obx(() {
                        final info = controller.ipInfo.value;
                        if (info == null) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: colors.accent,
                            ),
                          );
                        }

                        final details = <MapEntry<String, String>>[
                          MapEntry('IP Address', info.ip ?? 'Unknown'),
                          MapEntry('Region', info.region ?? 'Unknown'),
                          MapEntry(
                            'Country',
                            '${info.country ?? 'Unknown'}, ${info.continent ?? 'Unknown'}',
                          ),
                          MapEntry('Provider', info.connection?.isp ?? 'Unknown'),
                          MapEntry('Domain', info.connection?.domain ?? 'Unknown'),
                        ];

                        return ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: details.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 1),
                          itemBuilder: (context, index) {
                            final detail = details[index];
                            return _GlassCard(
                              radius: 24,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      detail.key,
                                      style: TextStyle(
                                        color: colors.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      detail.value,
                                      style: TextStyle(
                                        color: colors.textMuted,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 18,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isTesting.value
                        ? controller.stopSpeedTest
                        : controller.startSpeedTest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.isTesting.value
                          ? colors.danger
                          : colors.bottomGlow,
                    ),
                    child: Text(
                      controller.isTesting.value ? 'Stop Test' : 'Start Test',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
    this.radius = 30,
  });

  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          // decoration: colors.glassDecoration(radius: radius),
          child: child,
        ),
      ),
    );
  }
}

class _SpaceBackdrop extends StatelessWidget {
  const _SpaceBackdrop();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -100,
            child: _BlurOrb(size: 260, color: colors.accent.withOpacity(0.18)),
          ),
          Positioned(
            top: 200,
            right: -110,
            child:
            _BlurOrb(size: 240, color: colors.secondaryAccent.withOpacity(0.14)),
          ),
          Positioned(
            bottom: -120,
            left: 10,
            right: 10,
            child: Container(
              height: 260,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    colors.bottomGlow.withOpacity(colors.isDark ? 0.42 : 0.20),
                    colors.bottomGlow.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          ...List.generate(26, (index) {
            final top = 30.0 + (index * 33 % 620);
            final left = 16.0 + (index * 57 % 340);
            final size = index % 5 == 0 ? 4.0 : 2.2;
            return Positioned(
              top: top,
              left: left,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: colors.starColor.withOpacity(colors.isDark ? 0.7 : 0.45),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _BlurOrb extends StatelessWidget {
  const _BlurOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();


  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final themeController = Get.find<ThemeController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 24),
      child: Row(
        children: [
          _TopAction(
            icon: themeController.isDarkMode
                ? Icons.arrow_back_ios_new
                : Icons.arrow_back_ios_new,
            onTap: () {
              Get.back();
            }
          ),
          SizedBox(width: 12,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Speed Test',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Private Network',
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopAction extends StatelessWidget {
  const _TopAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: colors.buttonFill,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.stroke),
          ),
          child: Icon(icon, color: colors.textPrimary),
        ),
      ),
    );
  }
}
