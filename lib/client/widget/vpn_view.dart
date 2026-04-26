import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openvpn_client/client/controller/vpn_controller.dart';
import 'package:openvpn_client/client/widget/power_button.dart';
import 'package:openvpn_client/themes/app_colors.dart';
import 'package:openvpn_client/themes/theme_controller.dart';

import 'flip_timer.dart';

class VpnView extends GetView<VpnController> {
  const VpnView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: colors.pageGradient),
        child: Stack(
          children: [
            const _SpaceBackdrop(),
            SafeArea(
              child: Obx(() {
                final isConnected = controller.isConnected.value;
                final isLoading = controller.isLoading.value;
                final selectedServer = controller.selectedServer.value;
                final serverName = selectedServer?.name ?? 'Home Network';
                final address = controller.server.value;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 136),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _GlassPanel(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Column(
                          children: [
                            _WorldMapLayer(
                              isConnected: isConnected,
                              isLoading: isLoading,
                              child: Column(
                                children: [
                                  _TopBar(controller: controller),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        /*Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                controller.selectedServer.value?.name ?? 'Unknown',
                                                style: TextStyle(
                                                  color: colors.textPrimary,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              if (isConnected) ...[
                                                const SizedBox(height: 10),
                                                Text(
                                                  address,
                                                  style: TextStyle(
                                                    color: colors.accent,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ] else ... [
                                                const SizedBox(height: 8),
                                                Text(
                                                  isConnected
                                                      ? 'Connected'
                                                      : isLoading
                                                      ? 'Connecting'
                                                      : 'Ready to Connect',
                                                  style: TextStyle(
                                                    color: colors.textMuted,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),*/
                                        _StatusDot(
                                          label: controller.state.value,
                                          active: isConnected,
                                          loading: isLoading,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  /*Text(
                                    isConnected
                                        ? 'Session'
                                        : isLoading
                                            ? 'Preparing tunnel'
                                            : 'Not connected',
                                    style: TextStyle(
                                      color: colors.textMuted,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 14),*/
                                  isConnected
                                      ? FlipTime(controller.duration.value)
                                      : Text(
                                          controller.duration.value,
                                          style: TextStyle(
                                            color: colors.textPrimary,
                                            fontSize: 42,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                  const SizedBox(height: 8),
                                  PowerButton(
                                    isConnected: isConnected,
                                    isLoading: isLoading,
                                    onPressed: controller.toggleConnection,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    isConnected
                                        ? 'Connection is successful'
                                        : isLoading
                                            ? 'Negotiating VPN session...'
                                            : 'Tap the power button to connect',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: colors.textMuted,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _StatCard(
                                          title: 'Download',
                                          value: controller.downloadSpeed.value,
                                          subvalue: '${controller.byteIn.value} MB',
                                          icon: Icons.south_rounded,
                                          accent: colors.secondaryAccent,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: _StatCard(
                                          title: 'Upload',
                                          value: controller.uploadSpeed.value,
                                          subvalue: '${controller.byteOut.value} MB',
                                          icon: Icons.north_rounded,
                                          accent: colors.accent,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _MiniInfoCard(
                                          title: 'Ping',
                                          value: '${controller.ping.value} ms',
                                          icon: Icons.network_check_rounded,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: _MiniInfoCard(
                                          title: 'Packets',
                                          value:
                                          '${controller.packetsIn.value}/${controller.packetsOut.value}',
                                          icon: Icons.stacked_line_chart_rounded,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _LocationStrip(
                                    controller: controller,
                                    serverName: serverName,
                                    address: address,
                                    onTap: () => _showServerSheet(context),
                                  ),
                                  const SizedBox(height: 18),
                                  const _SectionHeader(
                                    title: 'Activity log',
                                    subtitle: 'Live VPN events and connection diagnostics.',
                                  ),
                                  const SizedBox(height: 12),
                                  _GlassPanel(
                                    padding: const EdgeInsets.all(16),
                                    child: Container(
                                      width: double.infinity,
                                      constraints: const BoxConstraints(minHeight: 148),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: colors.logFill,
                                        borderRadius: BorderRadius.circular(22),
                                        border: Border.all(color: colors.stroke),
                                      ),
                                      child: Text(
                                        controller.log.value.trim().isEmpty
                                            ? 'No log events yet.'
                                            : controller.log.value,
                                        style: TextStyle(
                                          color: colors.textPrimary.withOpacity(0.88),
                                          fontSize: 13,
                                          height: 1.55,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 18,
              child: SafeArea(
                top: false,
                child: _GlassPanel(
                  padding: const EdgeInsets.all(10),
                  radius: 28,
                  child: ElevatedButton.icon(
                    onPressed: () => _showServerSheet(context),
                    icon: const Icon(Icons.public_rounded),
                    label: const Text('Select Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.bottomGlow,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showServerSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return FractionallySizedBox(
          heightFactor: 0.72,
          child: _ServerSheet(controller: controller),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.controller});

  final VpnController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final themeController = Get.find<ThemeController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick VPN',
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
          _TopAction(
            icon: themeController.isDarkMode
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            onTap: themeController.toggleThemeMode,
          ),
          const SizedBox(width: 10),
          _TopAction(
            icon: Icons.speed_rounded,
            onTap: controller.initSpeedTest,
          ),
          const SizedBox(width: 10),
          _TopAction(
            icon: Icons.add_rounded,
            onTap: controller.initAddProfile,
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

class _StatusDot extends StatelessWidget {
  const _StatusDot({
    required this.label,
    required this.active,
    required this.loading,
  });

  final String label;
  final bool active;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final indicator = active
        ? colors.success
        : loading
            ? colors.warning
            : colors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.chipFill,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.stroke),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: indicator,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: indicator.withOpacity(0.45),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorldMapLayer extends StatelessWidget {
  const _WorldMapLayer({
    required this.child,
    required this.isConnected,
    required this.isLoading,
  });

  final Widget child;
  final bool isConnected;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      width: double.maxFinite,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 24,
            left: 0,
            right: 0,
            child: Icon(
              Icons.public,
              size: 240,
              color: Colors.transparent,
            ),
          ),
          /*Positioned(
            bottom: -12,
            left: -40,
            right: -40,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: RadialGradient(
                  colors: [
                    colors.bottomGlow.withOpacity(colors.isDark ? 0.62 : 0.30),
                    colors.bottomGlow.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),*/
          // if (isLoading)
          //   Positioned(
          //     top: 310,
          //     child: SizedBox(
          //       width: 180,
          //       height: 180,
          //       child: CircularProgressIndicator(
          //         strokeWidth: 3,
          //         valueColor: AlwaysStoppedAnimation<Color>(colors.secondaryAccent),
          //       ),
          //     ),
          //   ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 26, 10, 26),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.subvalue,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String value;
  final String subvalue;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return _GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 12,),
              Text(
                title,
                style: TextStyle(
                  color: colors.textMuted,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subvalue,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniInfoCard extends StatelessWidget {
  const _MiniInfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return _GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      radius: 24,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.softIconFill,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: colors.textPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
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

class _LocationStrip extends StatelessWidget {
  const _LocationStrip({
    required this.controller,
    required this.serverName,
    required this.address,
    required this.onTap,
  });

  final VpnController controller;
  final String serverName;
  final String address;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final info = controller.ipInfo.value;
    final location = [info?.city, info?.countryCode]
        .whereType<String>()
        .where((e) => e.trim().isNotEmpty)
        .join(', ');

    return _GlassPanel(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        // onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.softIconFill,
                border: Border.all(color: colors.stroke),
              ),
              child: Icon(Icons.public_rounded, color: colors.accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serverName,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location.isEmpty ? address : '$location • $address',
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Icon(Icons.keyboard_arrow_up_rounded, color: colors.textPrimary),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: colors.textMuted,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _ServerSheet extends StatelessWidget {
  const _ServerSheet({required this.controller});

  final VpnController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: BoxDecoration(
        color: colors.locationSheet,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: colors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 52,
              height: 5,
              decoration: BoxDecoration(
                color: colors.textMuted.withOpacity(0.35),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'All locations',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: colors.softIconFill,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: Colors.transparent,
                      hintText: 'Search location',
                      hintStyle: TextStyle(color: colors.textMuted),
                    ),
                  ),
                ),
                Icon(Icons.search_rounded, color: colors.textPrimary),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Obx(
              () => ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: controller.allServers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final server = controller.allServers[index];
                  final isSelected =
                      controller.selectedServer.value?.name == server.name;
                  return _ServerTile(
                    serverName: server.name,
                    address: server.ip,
                    ping: server.ping,
                    selected: isSelected,
                    onTap: () {
                      controller.selectedServer.value = server;
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServerTile extends StatelessWidget {
  const _ServerTile({
    required this.serverName,
    required this.address,
    required this.ping,
    required this.selected,
    required this.onTap,
  });

  final String serverName;
  final String address;
  final String ping;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final foreground = selected ? Colors.white : colors.textPrimary;
    final secondary = selected ? Colors.white.withOpacity(0.76) : colors.textMuted;
    final iconFill = selected ? Colors.white.withOpacity(0.16) : colors.softIconFill;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: selected ? colors.heroGradient : null,
            color: selected ? null : colors.panelFill,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? Colors.white.withOpacity(0.20) : colors.stroke,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: colors.accent.withOpacity(0.22),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconFill,
                ),
                child: Icon(Icons.flag_circle_rounded, color: foreground),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serverName,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address,
                      style: TextStyle(
                        color: secondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    ping,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.chevron_right_rounded,
                    color: foreground.withOpacity(0.92),
                  ),
                ],
              ),
            ],
          ),
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

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(0),
    this.radius = 30,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          padding: padding,
          // decoration: colors.glassDecoration(radius: radius),
          child: child,
        ),
      ),
    );
  }
}
