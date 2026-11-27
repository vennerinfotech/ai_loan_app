// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:material_ui/material_ui.dart' as m_ui;
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';
import 'theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set background messaging handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize Notification Service (permissions, channels, listeners)
  await NotificationService.instance.initialize();

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
      defaultTransition: Transition.noTransition,
      transitionDuration: Duration.zero,
      localizationsDelegates: const [
        m_ui.DefaultMaterialLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
