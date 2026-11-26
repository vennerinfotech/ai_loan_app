import 'package:material_ui/material_ui.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

/// Centralized service for Help & Support integration.
/// Direct url_launcher integration for WhatsApp & Email with Fluttertoast on failure.
/// - WhatsApp: 95372 90307 (+91 95372 90307)
/// - Email: finsphereaipvtltd@gmail.com
class SupportService {
  static const String phoneCountryCode = '919537290307';
  static const String supportEmail = 'finsphereaipvtltd@gmail.com';

  /// Launches WhatsApp directly with the support number: 95372 90307
  static Future<void> openWhatsApp({String? customMessage}) async {
    final message = customMessage ??
        'Hello Finsphere Support, I need help with my loan application.';
    final whatsappUrl = Uri.parse(
      'https://wa.me/$phoneCountryCode?text=${Uri.encodeComponent(message)}',
    );

    try {
      final launched = await launchUrl(
        whatsappUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        // Fallback to whatsapp:// scheme
        final fallbackUri = Uri.parse(
          'whatsapp://send?phone=$phoneCountryCode&text=${Uri.encodeComponent(message)}',
        );
        final fallbackLaunched = await launchUrl(
          fallbackUri,
          mode: LaunchMode.externalApplication,
        );

        if (!fallbackLaunched) {
          _showFailedToast('Unable to open WhatsApp');
        }
      }
    } catch (_) {
      _showFailedToast('Unable to open WhatsApp');
    }
  }

  /// Opens default email client directly addressed to finsphereaipvtltd@gmail.com
  static Future<void> openEmail({
    String? subject,
    String? body,
  }) async {
    final emailSubject = subject ?? 'Support Request - Finsphere Loan App';
    final emailBody = body ??
        'Hello Finsphere Team,\n\nI need assistance regarding my loan application.\n\nThank you.';

    final emailUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      query: _encodeQueryParameters({
        'subject': emailSubject,
        'body': emailBody,
      }),
    );

    try {
      final launched = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showFailedToast('Unable to open email client');
      }
    } catch (_) {
      _showFailedToast('Unable to open email client');
    }
  }

  /// Helper to encode query parameters safely for mailto
  static String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  /// Shows toast notification via fluttertoast ONLY when launching fails
  static void _showFailedToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xFF1E293B),
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }
}
