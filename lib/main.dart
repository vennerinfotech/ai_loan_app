import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'screens/splash_screen.dart';
import 'theme/theme.dart';

void main() {
  runApp(const FinsphereApp());
}

class FinsphereApp extends StatelessWidget {
  const FinsphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: Get.key,
      title: 'Finsphere.AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
