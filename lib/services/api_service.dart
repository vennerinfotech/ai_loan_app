import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'session_manager.dart';

/// Central API Service for handling network requests across Finsphere AI Loan App.
/// Always returns the decoded response Map for both success and error responses.
class ApiService {
  ApiService._();

  /// Common base URL for all API calls
  static String baseUrl = 'https://app.crm.finsphereai.com/api';

  /// Standard HTTP headers
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Extracts the exact error message from Finsphere API response:
  /// Handles both formats:
  /// 1. errors: { "otp": ["Invalid OTP. Please try again."] } -> returns "Invalid OTP. Please try again."
  /// 2. message: "Invalid MPIN." -> returns "Invalid MPIN."
  static String getErrorMessage(Map<String, dynamic>? response) {
    if (response == null) {
      return 'Something went wrong. Please try again.';
    }

    // 1. Check nested errors dictionary first (e.g. { "otp": ["..."], "phone": ["..."] })
    if (response['errors'] is Map) {
      final errorsMap = response['errors'] as Map;
      for (final key in errorsMap.keys) {
        final val = errorsMap[key];
        if (val is List && val.isNotEmpty) {
          final firstError = val.first?.toString().trim();
          if (firstError != null && firstError.isNotEmpty) {
            return firstError;
          }
        } else if (val is String && val.trim().isNotEmpty) {
          return val.trim();
        }
      }
    }

    // 2. Check main response message
    final msg = response['message']?.toString().trim();
    if (msg != null && msg.isNotEmpty && msg != 'Validation failed.') {
      return msg;
    }

    return msg ?? 'Something went wrong. Please try again.';
  }

  /// Check Mobile Registered API: POST {{baseUrl}}/check-mobile-login
  static Future<Map<String, dynamic>> checkMobileLogin({
    required String phone,
  }) async {
    final url = Uri.parse('$baseUrl/check-mobile-login');

    final body = jsonEncode({
      'phone': phone.trim(),
    });

    try {
      final response = await http.post(
        url,
        headers: defaultHeaders,
        body: body,
      );

      debugPrint('========== Check Mobile Login ==========');
      debugPrint('--> POST $url');
      debugPrint('Request Body: $body');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in checkMobileLogin: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to connect to server. Please try again.',
      };
    }
  }

  /// Register User API: POST {{baseUrl}}/register
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

      debugPrint('========== Register ==========');
      debugPrint('--> POST $url');
      debugPrint('Request Body: $body');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in register: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to connect to server. Please try again.',
      };
    }
  }

  /// Verify Registration OTP API: POST {{baseUrl}}/verify-otp
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

      debugPrint('========== Verify OTP ==========');
      debugPrint('--> POST $url');
      debugPrint('Request Body: $body');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in verifyOtp: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to connect to server. Please try again.',
      };
    }
  }

  /// Resend Registration OTP API: POST {{baseUrl}}/resend-otp
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

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in resendOtp: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to connect to server. Please try again.',
      };
    }
  }

  /// Set MPIN API: POST {{baseUrl}}/set-mpin
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

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in setMpin: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to connect to server. Please try again.',
      };
    }
  }

  /// Login with Phone & MPIN API: POST {{baseUrl}}/login
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

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in login: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to connect to server. Please try again.',
      };
    }
  }

  /// Forgot MPIN OTP API: POST {{baseUrl}}/forgot-mpin-otp
  static Future<Map<String, dynamic>> forgotMpinOtp({
    required String phone,
  }) async {
    final url = Uri.parse('$baseUrl/forgot-mpin-otp');

    final body = jsonEncode({
      'phone': phone.trim(),
    });

    try {
      final response = await http.post(
        url,
        headers: defaultHeaders,
        body: body,
      );

      debugPrint('========== Forgot MPIN OTP ==========');
      debugPrint('--> POST $url');
      debugPrint('Request Body: $body');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in forgotMpinOtp: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to connect to server. Please try again.',
      };
    }
  }

  /// Forgot MPIN Verify OTP API: POST {{baseUrl}}/forgot-mpin-verify
  static Future<Map<String, dynamic>> forgotMpinVerify({
    required String phone,
    required String otp,
  }) async {
    final url = Uri.parse('$baseUrl/forgot-mpin-verify');

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

      debugPrint('========== Forgot MPIN Verify ==========');
      debugPrint('--> POST $url');
      debugPrint('Request Body: $body');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in forgotMpinVerify: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to connect to server. Please try again.',
      };
    }
  }

  /// Forgot MPIN Resend OTP API: POST {{baseUrl}}/forgot-mpin-resend
  static Future<Map<String, dynamic>> forgotMpinResend({
    required String phone,
  }) async {
    final url = Uri.parse('$baseUrl/forgot-mpin-resend');

    final body = jsonEncode({
      'phone': phone.trim(),
    });

    try {
      final response = await http.post(
        url,
        headers: defaultHeaders,
        body: body,
      );

      debugPrint('========== Forgot MPIN Resend ==========');
      debugPrint('--> POST $url');
      debugPrint('Request Body: $body');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in forgotMpinResend: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to connect to server. Please try again.',
      };
    }
  }

  /// Reset MPIN API: POST {{baseUrl}}/reset-mpin
  static Future<Map<String, dynamic>> resetMpin({
    required String phone,
    required String otp,
    required String mpin,
    required String mpinConfirmation,
  }) async {
    final url = Uri.parse('$baseUrl/reset-mpin');

    final body = jsonEncode({
      'phone': phone.trim(),
      'otp': otp.trim(),
      'mpin': mpin.trim(),
      'mpin_confirmation': mpinConfirmation.trim(),
    });

    try {
      final response = await http.post(
        url,
        headers: defaultHeaders,
        body: body,
      );

      debugPrint('========== Reset MPIN ==========');
      debugPrint('--> POST $url');
      debugPrint('Request Body: $body');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in resetMpin: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to connect to server. Please try again.',
      };
    }
  }

  /// Logout API: POST {{baseUrl}}/logout
  static Future<Map<String, dynamic>> logout({
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/logout');

    final authToken = token ?? await SessionManager.getAuthToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
      );

      debugPrint('========== Logout ==========');
      debugPrint('--> POST $url');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in logout: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to connect to server. Please try again.',
      };
    }
  }

  /// Store Aadhaar API: POST {{baseUrl}}/store-aadhaar
  static Future<Map<String, dynamic>> storeAadhaar({
    required String aadhaarNumber,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/store-aadhaar');

    final authToken = token ?? await SessionManager.getAuthToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
    };

    final body = jsonEncode({
      'aadhaar_number': aadhaarNumber.replaceAll(RegExp(r'\D'), '').trim(),
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      debugPrint('========== Store Aadhaar ==========');
      debugPrint('--> POST $url');
      debugPrint('Request Body: $body');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in storeAadhaar: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to connect to server. Please try again.',
      };
    }
  }

  /// Upload Aadhaar Card Image API: POST {{baseUrl}}/upload-aadhaar
  /// Multipart form-data with key 'aadhar_card_image'
  static Future<Map<String, dynamic>> uploadAadhaar({
    required String filePath,
    Uint8List? fileBytes,
    String? filename,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/upload-aadhaar');
    final authToken = token ?? await SessionManager.getAuthToken();

    try {
      final request = http.MultipartRequest('POST', url);

      request.headers.addAll({
        'Accept': 'application/json',
        if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
      });

      if (fileBytes != null && fileBytes.isNotEmpty) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'aadhar_card_image',
            fileBytes,
            filename: filename ?? 'aadhaar_card.jpg',
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'aadhar_card_image',
            filePath,
          ),
        );
      }

      debugPrint('========== Upload Aadhaar Card ==========');
      debugPrint('--> POST (Multipart) $url');
      debugPrint('File Path: $filePath');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in uploadAadhaar: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to upload Aadhaar document. Please try again.',
      };
    }
  }

  /// Verify Aadhaar OTP API: POST {{baseUrl}}/verify-aadhaar-otp
  /// Request: { "otp": otp, "document_id": document_id }
  static Future<Map<String, dynamic>> verifyAadhaarOtp({
    required String otp,
    required dynamic documentId,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/verify-aadhaar-otp');
    final authToken = token ?? await SessionManager.getAuthToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
    };

    final body = jsonEncode({
      'otp': otp.trim(),
      'document_id': documentId,
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      debugPrint('========== Verify Aadhaar OTP ==========');
      debugPrint('--> POST $url');
      debugPrint('Request Body: $body');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in verifyAadhaarOtp: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to verify OTP. Please try again.',
      };
    }
  }

  /// Resend Aadhaar OTP API: POST {{baseUrl}}/resend-aadhaar-otp
  static Future<Map<String, dynamic>> resendAadhaarOtp({
    dynamic documentId,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/resend-aadhaar-otp');
    final authToken = token ?? await SessionManager.getAuthToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
    };

    final body = jsonEncode({
      if (documentId != null) 'document_id': documentId,
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      debugPrint('========== Resend Aadhaar OTP ==========');
      debugPrint('--> POST $url');
      debugPrint('Request Body: $body');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in resendAadhaarOtp: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to resend Aadhaar OTP. Please try again.',
      };
    }
  }
}
