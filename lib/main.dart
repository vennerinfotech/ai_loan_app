import 'package:material_ui/material_ui.dart';
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
      title: 'Finsphere.AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
