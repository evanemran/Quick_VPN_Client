import 'package:flutter/material.dart';
import 'package:openvpn_client/themes/app_colors.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

class PowerButton extends StatelessWidget {
  const PowerButton({
    super.key,
    required this.isConnected,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isConnected;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final buttonSize = MediaQuery.of(context).size.width * 0.50;
    final iconSize = buttonSize * 0.27;
    final glowColor = isConnected ? colors.secondaryAccent : colors.accent;
    final ringColor = colors.isDark
        ? Colors.white.withOpacity(0.18)
        : colors.accent.withOpacity(0.14);
    final gradient = isConnected
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.success, colors.successAccent],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.accent, colors.heroEnd],
          );

    final core = AnimatedScale(
      scale: isLoading ? 1 : 1,
      duration: const Duration(milliseconds: 250),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: gradient,
          border: Border.all(
            color: Colors.white.withOpacity(colors.isDark ? 0.22 : 0.75),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(colors.isDark ? 0.34 : 0.20),
              blurRadius: 34,
              spreadRadius: 8,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: buttonSize * 0.68,
              height: buttonSize * 0.68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: 18),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: isLoading
                  ? const SizedBox(
                      key: ValueKey('loader'),
                      height: 36,
                      width: 36,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : Container(
                      key: const ValueKey('icon'),
                      width: buttonSize * 0.42,
                      height: buttonSize * 0.42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.22),
                        ),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/power_icon.png',
                          width: iconSize,
                          height: iconSize,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );

    return GestureDetector(
      onTap: onPressed,
      child: isConnected
          ? RippleAnimation(
              minRadius: buttonSize * 0.58,
              maxRadius: buttonSize * 0.90,
              ripplesCount: 3,
              color: colors.success,
              delay: const Duration(milliseconds: 500),
              repeat: true,
              duration: const Duration(milliseconds: 2000),
              child: core,
            )
          : Stack(
        children: [
          Visibility(
            visible: isLoading,
            child: Center(
              child: SizedBox(
                width: buttonSize,
                height: buttonSize,
                child: CircularProgressIndicator(
                  strokeWidth: 8,
                  backgroundColor: colors.starColor,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.secondaryAccent),
                ),
              ),
            ),
          ),
          Center(child: core)
        ],
      ),
    );
  }
}
