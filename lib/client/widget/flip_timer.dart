import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:openvpn_client/themes/app_colors.dart';

class FlipTime extends StatelessWidget {
  final String time;

  const FlipTime(this.time, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final parts = time.split(':').map(int.parse).toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _flip(context, parts[0]),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            ":",
            style: TextStyle(
              color: colors.textMuted,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
        ),
        _flip(context, parts[1]),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            ":",
            style: TextStyle(
              color: colors.textMuted,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
          ),
        ),
        _flip(context, parts[2]),
      ],
    );
  }

  Widget _flip(BuildContext context, int value) {
    final colors = context.appColors;
    return AnimatedFlipCounter(
      value: value,
      wholeDigits: 2,
      textStyle: TextStyle(
        color: colors.textPrimary,
        fontWeight: FontWeight.w800,
        fontSize: 42,
        letterSpacing: 1.5,
      ),
      duration: const Duration(milliseconds: 500),
    );
  }
}
