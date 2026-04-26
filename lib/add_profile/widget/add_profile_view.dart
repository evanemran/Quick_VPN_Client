import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openvpn_client/add_profile/controller/add_profile_controller.dart';
import 'package:openvpn_client/add_profile/controller/profile_tab_controller.dart';
import 'package:openvpn_client/themes/app_colors.dart';

import 'file_profile_form.dart';
import 'manual_profile_form.dart';

class AddProfileView extends GetView<AddProfileController> {
  AddProfileView({super.key});

  final ProfileTabController profileTabController =
      Get.find<ProfileTabController>();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      extendBodyBehindAppBar: true,
      /*appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Add Profile'),
      ),*/
      body: Stack(
        children: [
          _SpaceBackdrop(),
          DecoratedBox(
            decoration: BoxDecoration(gradient: colors.pageGradient),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, kBottomNavigationBarHeight*1.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBar(),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colors.softIconFill,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: TabBar(
                        controller: profileTabController.tabController,
                        indicator: BoxDecoration(
                          gradient: colors.tabGradiant,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        splashFactory: NoSplash.splashFactory,
                        labelStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        tabs: const [
                          Tab(text: 'Manual'),
                          Tab(text: 'File'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: TabBarView(
                        controller: profileTabController.tabController,
                        children: [
                          const ManualProfileForm(),
                          const FileProfileForm(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(bottom: 12, left: 16, right: 16, child: Obx(
                () => ElevatedButton.icon(
                  icon: const Icon(Icons.save_outlined),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.bottomGlow,
                    minimumSize: Size(double.maxFinite, kBottomNavigationBarHeight),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
              onPressed: () async {
                if (profileTabController.selectedTabNumber.value == 0) {
                  return;
                }
                final config = await profileTabController.selectOpenVpnFile();
                Get.back(result: config);
              },
              label: Text(
                profileTabController.selectedTabNumber.value == 0
                    ? 'Save'
                    : 'Browse for .ovpn',
              ),
            ),
          ))
        ],
      ),
      /*bottomNavigationBar: BottomAppBar(
        // minimum: const EdgeInsets.fromLTRB(20, 8, 20, 18), // For SafeArea
        color: Colors.transparent,
        child: Obx(
          () => ElevatedButton(
            onPressed: () async {
              if (profileTabController.selectedTabNumber.value == 0) {
                return;
              }
              final config = await profileTabController.selectOpenVpnFile();
              Get.back(result: config);
            },
            child: Text(
              profileTabController.selectedTabNumber.value == 0
                  ? 'Save'
                  : 'Browse for .ovpn',
            ),
          ),
        ),
      ),*/
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: colors.glassDecoration(radius: 30),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 24),
      child: Row(
        children: [
          _TopAction(
              icon: Icons.arrow_back_ios_new,
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
                  'Add VPN Profile',
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
