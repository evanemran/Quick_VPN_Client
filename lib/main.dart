import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

import 'commons/app_routes.dart';
import 'themes/app_theme.dart';
import 'themes/theme_controller.dart';
import 'utils/pref_utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeController = Get.put(ThemeController(PrefUtils()), permanent: true);
  await themeController.loadThemeMode();
  runApp(const MyApp());
}

class MyApp extends GetView<ThemeController> {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: Obx(
        () => GetMaterialApp(
          title: "Quick VPN",
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: controller.themeMode.value,
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.vpnPage,
          getPages: AppRoutes.pages,
        ),
      ),
    );
  }
}
