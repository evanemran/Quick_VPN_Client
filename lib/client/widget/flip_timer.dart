import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/cupertino.dart';
import 'package:openvpn_client/themes/app_colors.dart';

class FlipTime extends StatelessWidget {
  final String time;

  const FlipTime(this.time, {super.key});

  @override
  Widget build(BuildContext context) {
    final parts = time.split(':').map(int.parse).toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _flip(parts[0]),
        const Text(" : ", style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 30),),
        _flip(parts[1]),
        const Text(" : ", style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 30),),
        _flip(parts[2]),
      ],
    );
  }

  Widget _flip(int value) {
    return AnimatedFlipCounter(
      value: value,
      wholeDigits: 2,
      textStyle: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 36),
      duration: const Duration(milliseconds: 500),
    );
  }
}
