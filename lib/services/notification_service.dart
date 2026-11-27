import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../firebase_options.dart';
import 'api_service.dart';
import 'session_manager.dart';
import '../screens/document_wallet_screen.dart';
import '../screens/loan_flow/applicant_details_screen.dart';
import '../screens/loan_flow/recommended_loan_offers_screen.dart';

/// Top-level background message handler required by Firebase Messaging
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('--> [FCM Background Message]: ${message.messageId}');
  debugPrint('    Title: ${message.notification?.title}');
  debugPrint('    Body: ${message.notification?.body}');
  debugPrint('    Data: ${message.data}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _highImportanceChannel =
      AndroidNotificationChannel(
    'high_importance_channel',
    'Loan Updates & Notifications',
    description:
        'This channel is used for important application and document updates.',
    importance: Importance.high,
    playSound: true,
  );

  /// Initialize Firebase messaging, permissions, local notifications, and listeners
  Future<void> initialize() async {
    // 1. Request notification permissions (iOS + Android 13+)
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('FCM Authorization status: ${settings.authorizationStatus}');

    // 2. Setup Local Notifications for Foreground display
    const androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInitSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: darwinInitSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final data = jsonDecode(response.payload!) as Map<String, dynamic>;
            _handleNotificationRoute(data);
          } catch (e) {
            debugPrint('Error parsing notification payload: $e');
          }
        }
      },
    );

    // 3. Create Android notification channel
    if (Platform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(_highImportanceChannel);
    }

    // 4. Foreground presentation options on iOS
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 5. Fetch and synchronize FCM Device Token
    await syncDeviceToken();

    // 6. Listen for token refresh
    // ignore: deprecated_member_use
    _fcm.onTokenRefresh.listen((newToken) {
      debugPrint('--> [FCM Token Refreshed]: $newToken');
      syncDeviceToken(forcedToken: newToken);
    });

    // 7. Foreground message listener (App is open)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('--> [FCM Foreground Message]: ${message.messageId}');
      _showForegroundNotification(message);
    });

    // 8. Background tap listener (App running in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('--> [FCM Notification Clicked (Background)]: ${message.data}');
      _handleNotificationRoute(message.data);
    });

    // 9. Terminated tap listener (App was closed completely)
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('--> [FCM Notification Clicked (Terminated)]: ${initialMessage.data}');
      Future.delayed(const Duration(milliseconds: 600), () {
        _handleNotificationRoute(initialMessage.data);
      });
    }
  }

  /// Fetch current FCM token and send it to your backend
  Future<String?> syncDeviceToken({String? forcedToken}) async {
    try {
      // ignore: deprecated_member_use
      final token = forcedToken ?? await _fcm.getToken();
      debugPrint('====================================');
      debugPrint('🔥 [FCM Device Token]: $token');
      debugPrint('====================================');

      if (token != null && token.isNotEmpty) {
        final authToken = await SessionManager.getAuthToken();
        // Only send to backend if user is authenticated
        if (authToken.isNotEmpty) {
          final deviceType = Platform.isIOS ? 'ios' : 'android';
          await ApiService.updateFcmToken(
            fcmToken: token,
            deviceType: deviceType,
          );
        }
      }
      return token;
    } catch (e) {
      debugPrint('Failed to get or sync FCM token: $e');
      return null;
    }
  }

  /// Show a heads-up banner when notification arrives while app is in foreground
  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    final title = notification?.title ?? message.data['title'] ?? 'Notification';
    final body = notification?.body ?? message.data['body'] ?? message.data['message'] ?? '';

    final androidDetails = AndroidNotificationDetails(
      _highImportanceChannel.id,
      _highImportanceChannel.name,
      channelDescription: _highImportanceChannel.description,
      icon: android?.smallIcon ?? '@mipmap/ic_launcher',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: details,
      payload: jsonEncode(message.data),
    );
  }

  /// Route user to relevant screen on notification tap
  void _handleNotificationRoute(Map<String, dynamic> data) {
    final type = (data['type'] ?? data['screen'] ?? '').toString().toLowerCase();

    debugPrint('Navigating based on notification type: $type');

    if (type.contains('loan') || type.contains('offer') || type.contains('application')) {
      Get.to(() => const RecommendedLoanOffersScreen());
    } else if (type.contains('document') || type.contains('wallet') || type.contains('kyc')) {
      Get.to(() => const DocumentWalletScreen());
    } else if (type.contains('co_applicant') || type.contains('applicant')) {
      Get.to(() => const ApplicantDetailsScreen());
    }
  }
}
