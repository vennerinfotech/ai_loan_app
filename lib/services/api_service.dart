import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Central API Service for handling network requests across Finsphere AI Loan App.
/// Base URL is kept as a common variable that can be changed anytime.
class ApiService {
  ApiService._();

  /// Common base URL for all API calls - can be changed or switched for environments
  static String baseUrl = 'https://app.crm.finsphereai.com/api';

  /// Standard HTTP headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Register User API (application/json): POST {{baseUrl}}/register
  static Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String email,
    String? referenceCode,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    final body = jsonEncode({
      'name': name.trim(),
      'phone': phone.trim(),
      'email': email.trim().isNotEmpty ? email.trim() : '',
      'reference_code': referenceCode?.trim() ?? '',
    });

    try {
      final response = await http.post(
        url,
        headers: defaultHeaders,
        body: body,
      );

      debugPrint('==========Register==========');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> jsonResponse =
          jsonDecode(response.body) as Map<String, dynamic>;

      return jsonResponse;
    } catch (e) {
      debugPrint('Error in register API: $e');
      return {'success': false, 'status_code': 500, 'message': e.toString()};
    }
  }

  /// Verify Registration OTP API (application/json): POST {{baseUrl}}/verify-otp
  static Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final url = Uri.parse('$baseUrl/verify-otp');

    final body = jsonEncode({
      'phone': phone.trim(),
      'otp': otp.trim(),
    });

    try {
      final response = await http.post(
        url,
        headers: defaultHeaders,
        body: body,
      );

      debugPrint('==========Verify OTP ==========');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> jsonResponse =
          jsonDecode(response.body) as Map<String, dynamic>;

      return jsonResponse;
    } catch (e) {
      debugPrint('Error in verifyOtp API: $e');
      return {'success': false, 'status_code': 500, 'message': e.toString()};
    }
  }

  /// Resend OTP API (application/json): POST {{baseUrl}}/resend-otp
  static Future<Map<String, dynamic>> resendOtp({
    required String phone,
  }) async {
    final url = Uri.parse('$baseUrl/resend-otp');

    final body = jsonEncode({
      'phone': phone.trim(),
    });

    try {
      final response = await http.post(
        url,
        headers: defaultHeaders,
        body: body,
      );

      debugPrint('========== Resend OTP ==========');
      debugPrint('--> POST $url');
      debugPrint('Request Body: $body');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> jsonResponse =
          jsonDecode(response.body) as Map<String, dynamic>;

      return jsonResponse;
    } catch (e) {
      debugPrint('Error in resendOtp API: $e');
      return {'success': false, 'status_code': 500, 'message': e.toString()};
    }
  }

  /// Set MPIN API (application/json): POST {{baseUrl}}/set-mpin
  static Future<Map<String, dynamic>> setMpin({
    required String mpin,
    required String mpinConfirmation,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/mpin');

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'mpin': mpin.trim(),
      'mpin_confirmation': mpinConfirmation.trim(),
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      debugPrint('========== Set MPIN ==========');
      debugPrint('--> POST $url');
      debugPrint('Request Body: $body');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> jsonResponse =
          jsonDecode(response.body) as Map<String, dynamic>;

      return jsonResponse;
    } catch (e) {
      debugPrint('Error in setMpin API: $e');
      return {'success': false, 'status_code': 500, 'message': e.toString()};
    }
  }

  /// Login with Phone & MPIN API (application/json): POST {{baseUrl}}/login
  static Future<Map<String, dynamic>> login({
    required String phone,
    required String mpin,
  }) async {
    final url = Uri.parse('$baseUrl/login');

    final body = jsonEncode({
      'phone': phone.trim(),
      'mpin': mpin.trim(),
    });

    try {
      final response = await http.post(
        url,
        headers: defaultHeaders,
        body: body,
      );

      debugPrint('========== Login (Phone & MPIN) ==========');
      debugPrint('--> POST $url');
      debugPrint('Request Body: $body');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> jsonResponse =
          jsonDecode(response.body) as Map<String, dynamic>;

      return jsonResponse;
    } catch (e) {
      debugPrint('Error in login API: $e');
      return {'success': false, 'status_code': 500, 'message': e.toString()};
    }
  }
}
