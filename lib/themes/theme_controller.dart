import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/pref_utils.dart';

class ThemeController extends GetxController {
  ThemeController(this._prefUtils);

  final PrefUtils _prefUtils;
  final themeMode = ThemeMode.dark.obs;

  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  Future<void> loadThemeMode() async {
    themeMode.value = await _prefUtils.loadThemeMode();
  }

  Future<void> toggleThemeMode() async {
    final nextMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    themeMode.value = nextMode;
    await _prefUtils.saveThemeMode(nextMode);
    Get.changeThemeMode(nextMode);
  }
}
