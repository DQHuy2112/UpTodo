import 'package:flutter/material.dart';
import 'package:uptodo/ui/splash/splash.dart';
import 'package:uptodo/data/settings_service.dart';
import 'package:uptodo/data/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Nạp cấu hình đã lưu
  final settings = await AppSettings.load();

  // Tạo controller và gán vào biến toàn cục
  final controller = SettingsController(settings);
  settingsController = controller;

  runApp(MyApp(controller: controller));
}

class MyApp extends StatelessWidget {
  final SettingsController controller;
  const MyApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller, // ✔ KHÔNG có dấu chấm
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'UpTodo',
          theme: controller.lightTheme,
          darkTheme: controller.darkTheme,
          themeMode: controller.themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
