// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:material_ui/material_ui.dart' as m_ui;
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
    return GetMaterialApp(
      title: 'Finsphere.AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      localizationsDelegates: const [
        m_ui.DefaultMaterialLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
