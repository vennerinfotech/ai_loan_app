import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/employment_type_model.dart';
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

  /// Upload Aadhaar Documents API: POST {{baseUrl}}/upload-aadhaar
  /// Multipart form-data with:
  /// - 'upload_mode': 'separate'
  /// - 'aadhaar_front_image': Front image file
  /// - 'aadhaar_back_image': Back image file
  static Future<Map<String, dynamic>> uploadAadhaar({
    required String frontPath,
    required String backPath,
    Uint8List? frontBytes,
    Uint8List? backBytes,
    String? frontFilename,
    String? backFilename,
    String uploadMode = 'separate',
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

      request.fields['upload_mode'] = uploadMode;

      // Add Front Image / Document
      final resolvedFrontName = frontFilename ??
          (frontPath.isNotEmpty
              ? frontPath.split('/').last
              : (frontPath.toLowerCase().endsWith('.pdf') ? 'aadhaar_front.pdf' : 'aadhaar_front.jpg'));
      if (frontBytes != null && frontBytes.isNotEmpty) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'aadhaar_front_image',
            frontBytes,
            filename: resolvedFrontName,
          ),
        );
      } else if (frontPath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'aadhaar_front_image',
            frontPath,
            filename: resolvedFrontName,
          ),
        );
      }

      // Add Back Image / Document
      final resolvedBackName = backFilename ??
          (backPath.isNotEmpty
              ? backPath.split('/').last
              : (backPath.toLowerCase().endsWith('.pdf') ? 'aadhaar_back.pdf' : 'aadhaar_back.jpg'));
      if (backBytes != null && backBytes.isNotEmpty) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'aadhaar_back_image',
            backBytes,
            filename: resolvedBackName,
          ),
        );
      } else if (backPath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'aadhaar_back_image',
            backPath,
            filename: resolvedBackName,
          ),
        );
      }

      debugPrint('========== Upload Aadhaar Documents ==========');
      debugPrint('--> POST (Multipart) $url');
      debugPrint('Upload Mode: $uploadMode');
      debugPrint('Front Image Path: $frontPath');
      debugPrint('Back Image Path: $backPath');

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
        'message': 'Failed to upload Aadhaar documents. Please try again.',
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
      ...? (documentId != null ? {'document_id': documentId} : null),
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

  /// Update Onboarding Step API: POST {{baseUrl}}/update-onboarding-step
  /// Request: { "step": 5 }
  static Future<Map<String, dynamic>> updateOnboardingStep({
    required int step,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/update-onboarding-step');
    final authToken = token ?? await SessionManager.getAuthToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
    };

    final body = jsonEncode({
      'step': step,
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      debugPrint('========== Update Onboarding Step ==========');
      debugPrint('--> POST $url');
      debugPrint('Request Body: $body');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in updateOnboardingStep: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to update onboarding step. Please try again.',
      };
    }
  }

  /// Download Verification Receipt API: GET {{baseUrl}}/download-verification-receipt
  static Future<Map<String, dynamic>> downloadVerificationReceipt({
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/download-verification-receipt');
    final authToken = token ?? await SessionManager.getAuthToken();
    final headers = {
      'Accept': 'application/json',
      if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
    };

    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      debugPrint('========== Download Verification Receipt ==========');
      debugPrint('--> GET $url');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in downloadVerificationReceipt: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to download verification receipt. Please try again.',
      };
    }
  }

  /// Store PAN Card API: POST {{baseUrl}}/store-pan-card
  /// Request: { "pan_card_number": "ABCDE1234F" }
  static Future<Map<String, dynamic>> storePanCard({
    required String panCardNumber,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/store-pan-card');
    final authToken = token ?? await SessionManager.getAuthToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
    };

    final body = jsonEncode({
      'pan_card_number': panCardNumber.trim().toUpperCase(),
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      debugPrint('========== Store PAN Card ==========');
      debugPrint('--> POST $url');
      debugPrint('Request Body: $body');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in storePanCard: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to connect to server. Please try again.',
      };
    }
  }

  /// Upload PAN Card Image API: POST {{baseUrl}}/upload-pan
  /// Multipart form-data with:
  /// - 'upload_mode': 'combined' (Text)
  /// - 'pan_card_image': File (Required. JPG, JPEG, PNG or PDF)
  static Future<Map<String, dynamic>> uploadPan({
    required String filePath,
    Uint8List? fileBytes,
    String? filename,
    String uploadMode = 'combined',
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/upload-pan');
    final authToken = token ?? await SessionManager.getAuthToken();

    try {
      final request = http.MultipartRequest('POST', url);

      request.headers.addAll({
        'Accept': 'application/json',
        if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
      });

      request.fields['upload_mode'] = uploadMode;

      final resolvedName = filename ??
          (filePath.isNotEmpty
              ? filePath.split('/').last
              : (filePath.toLowerCase().endsWith('.pdf') ? 'pan_card.pdf' : 'pan_card.jpg'));

      if (fileBytes != null && fileBytes.isNotEmpty) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'pan_card_image',
            fileBytes,
            filename: resolvedName,
          ),
        );
      } else if (filePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'pan_card_image',
            filePath,
            filename: resolvedName,
          ),
        );
      }

      debugPrint('========== Upload PAN Card ==========');
      debugPrint('--> POST (Multipart) $url');
      debugPrint('Upload Mode: $uploadMode');
      debugPrint('File Path: $filePath');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in uploadPan: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to upload PAN card. Please try again.',
      };
    }
  }

  /// Fetch CIBIL Credit Score API: POST {{baseUrl}}/loan/cibil-score
  /// Request body: { "pan_number": "ABCDE1234F" }
  static Future<Map<String, dynamic>> fetchCibilScore({
    String? panNumber,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/loan/cibil-score');
    final authToken = token ?? await SessionManager.getAuthToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
    };

    final cleanPan = panNumber?.trim().toUpperCase();
    final body = jsonEncode({
      if (cleanPan != null && cleanPan.isNotEmpty) 'pan_number': cleanPan,
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      debugPrint('========== Fetch CIBIL Score ==========');
      debugPrint('--> POST $url');
      debugPrint('Request Body: $body');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in fetchCibilScore: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to fetch CIBIL score. Please try again.',
      };
    }
  }

  /// Fetch Dashboard Data API: GET {{baseUrl}}/dashboard
  static Future<Map<String, dynamic>> getDashboardData({
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/dashboard');
    final authToken = token ?? await SessionManager.getAuthToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
    };

    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      debugPrint('========== Get Dashboard Data ==========');
      debugPrint('--> GET $url');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in getDashboardData: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to fetch dashboard data. Please try again.',
      };
    }
  }

  /// Get Employment Types API: GET {{baseUrl}}/loan/employment-types
  static Future<Map<String, dynamic>> getEmploymentTypes({
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/loan/employment-types');
    final authToken = token ?? await SessionManager.getAuthToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
    };

    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      debugPrint('========== Get Employment Types ==========');
      debugPrint('--> GET $url');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in getEmploymentTypes: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to fetch employment types. Please try again.',
      };
    }
  }

  /// Store Loan Amount and Details API: POST {{baseUrl}}/loan/store-amount
  /// Uses raw JSON body matching Postman collection
  static Future<Map<String, dynamic>> storeLoanAmount({
    required dynamic amount,
    required String loanType,
    required String employmentType,
    dynamic tenureMonths,
    String? businessEntity,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/loan/store-amount');
    final authToken = token ?? await SessionManager.getAuthToken();

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
    };

    final Map<String, dynamic> bodyMap = {
      'amount': amount is num ? amount : (num.tryParse(amount.toString()) ?? amount),
      'loan_type': loanType.trim(),
      'employment_type': employmentType.trim(),
      'business_entity': businessEntity ?? '',
    };
    if (tenureMonths != null) {
      bodyMap['tenure_months'] = tenureMonths is int
          ? tenureMonths
          : (int.tryParse(tenureMonths.toString()) ?? tenureMonths);
    }

    final body = jsonEncode(bodyMap);

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      debugPrint('========== Store Loan Amount ==========');
      debugPrint('--> POST (JSON) $url');
      debugPrint('Headers: $headers');
      debugPrint('Request Body: $body');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in storeLoanAmount: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to store loan amount. Please try again.',
      };
    }
  }

  /// Submit Loan Application Lead API: POST {{baseUrl}}/leads/store
  /// Uses multipart/form-data matching Postman collection
  static Future<Map<String, dynamic>> submitLoanLead({
    required Map<String, String> fields,
    required List<LoanDocumentItem> documents,
    required Map<String, List<XFile>> uploadedFiles,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/leads/store');
    final authToken = token ?? await SessionManager.getAuthToken();

    try {
      final request = http.MultipartRequest('POST', url);
      request.headers['Accept'] = 'application/json';
      if (authToken.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $authToken';
      }

      // Add all dynamic form fields (employment details, salary amounts, reference details)
      fields.forEach((k, v) {
        if (v.trim().isNotEmpty) {
          request.fields[k] = v.trim();
        }
      });

      // Attach all uploaded document files using leadStoreField format
      for (final doc in documents) {
        final key = doc.key ?? '';
        final files = uploadedFiles[key] ?? [];
        if (files.isNotEmpty) {
          final isMulti = doc.allowMultiple == true;
          final fieldName = doc.upload?.leadStoreField ??
              (isMulti ? 'documents[$key][]' : 'documents[$key]');

          for (final file in files) {
            final bytes = await file.readAsBytes();
            request.files.add(
              http.MultipartFile.fromBytes(
                fieldName,
                bytes,
                filename: file.name,
              ),
            );
          }
        }
      }

      debugPrint('========== Submit Loan Application Lead ==========');
      debugPrint('--> POST (multipart) $url');
      debugPrint('Fields: ${request.fields}');
      debugPrint('Files Count: ${request.files.length}');

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in submitLoanLead: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to submit application. Please try again.',
      };
    }
  }

  /// Calculate EMI API: POST {{baseUrl}}/emi-calculate
  /// Sends JSON body matching Postman collection (loan_amount, interest_rate, tenure_months)
  static Future<Map<String, dynamic>> calculateEmi({
    required dynamic loanAmount,
    dynamic interestRate,
    dynamic tenureMonths,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/emi-calculate');
    final authToken = token ?? await SessionManager.getAuthToken();

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
    };

    final Map<String, dynamic> bodyMap = {
      'loan_amount': loanAmount is num
          ? loanAmount
          : (num.tryParse(loanAmount.toString()) ?? loanAmount),
      if (interestRate != null)
        'interest_rate': interestRate is num
            ? interestRate
            : (num.tryParse(interestRate.toString()) ?? interestRate),
      if (tenureMonths != null)
        'tenure_months': tenureMonths is int
            ? tenureMonths
            : (int.tryParse(tenureMonths.toString()) ?? tenureMonths),
    };

    final body = jsonEncode(bodyMap);

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      debugPrint('========== Calculate EMI ==========');
      debugPrint('--> POST (JSON) $url');
      debugPrint('Headers: $headers');
      debugPrint('Request Body: $body');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in calculateEmi: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to calculate EMI. Please try again.',
      };
    }
  }

  /// Update Profile Photo API: POST {{baseUrl}}/update-profile-photo
  /// Multipart form-data with file field 'profile_photo'
  static Future<Map<String, dynamic>> updateProfilePhoto({
    required String filePath,
    Uint8List? fileBytes,
    String? filename,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/update-profile-photo');
    final authToken = token ?? await SessionManager.getAuthToken();

    try {
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Accept': 'application/json',
        if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
      });

      final resolvedName = filename ??
          (filePath.isNotEmpty
              ? filePath.split('/').last
              : 'profile_photo.jpg');

      if (fileBytes != null && fileBytes.isNotEmpty) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'profile_photo',
            fileBytes,
            filename: resolvedName,
          ),
        );
      } else if (filePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_photo',
            filePath,
            filename: resolvedName,
          ),
        );
      }

      debugPrint('========== Update Profile Photo ==========');
      debugPrint('--> POST (Multipart) $url');
      debugPrint('File Path: $filePath');
      debugPrint('Filename: $resolvedName');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in updateProfilePhoto: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to upload profile photo. Please try again.',
        'errors': e.toString(),
      };
    }
  }

  /// Update Personal Info API: POST {{baseUrl}}/update-personal-info
  /// JSON body with {name, email, dob, gender, marital_status, address, address_type}
  static Future<Map<String, dynamic>> updatePersonalInfo({
    required String name,
    required String email,
    required String dob,
    required String gender,
    required String maritalStatus,
    required String address,
    required String addressType,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/update-personal-info');
    final authToken = token ?? await SessionManager.getAuthToken();

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
    };

    final body = jsonEncode({
      'name': name.trim(),
      'email': email.trim(),
      'dob': dob.trim(),
      'gender': gender.trim(),
      'marital_status': maritalStatus.trim(),
      'address': address.trim(),
      'address_type': addressType.trim(),
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      debugPrint('========== Update Personal Info ==========');
      debugPrint('--> POST $url');
      debugPrint('Request Body: $body');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in updatePersonalInfo: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to update personal information. Please try again.',
        'errors': e.toString(),
      };
    }
  }

  /// Get Loan Types API: GET {{baseUrl}}/loan/types
  static Future<Map<String, dynamic>> getLoanTypes({
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/loan/types');
    final authToken = token ?? await SessionManager.getAuthToken();

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
    };

    try {
      final response = await http.get(url, headers: headers);

      debugPrint('========== Get Loan Types ==========');
      debugPrint('--> GET $url');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in getLoanTypes: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to fetch loan types. Please try again.',
        'errors': e.toString(),
      };
    }
  }

  /// Get Co-Applicant Form Options API: GET {{baseUrl}}/co-applicants/form-options
  static Future<Map<String, dynamic>> getCoApplicantFormOptions({
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/co-applicants/form-options');
    final authToken = token ?? await SessionManager.getAuthToken();

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
    };

    try {
      final response = await http.get(url, headers: headers);

      debugPrint('========== Get Co-Applicant Form Options ==========');
      debugPrint('--> GET $url');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in getCoApplicantFormOptions: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to fetch co-applicant form options. Please try again.',
        'errors': e.toString(),
      };
    }
  }

  /// Add Co-Applicant API: POST {{baseUrl}}/co-applicants
  static Future<Map<String, dynamic>> addCoApplicant({
    required String coApplicantName,
    required String coApplicantMobile,
    required String coRelationship,
    required String applicantType,
    required String employmentType,
    required dynamic leadId,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/co-applicants');
    final authToken = token ?? await SessionManager.getAuthToken();

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
    };

    final body = jsonEncode({
      'co_applicant_name': coApplicantName,
      'co_applicant_mobile': coApplicantMobile,
      'co_relationship': coRelationship,
      'applicant_type': applicantType,
      'employment_type': employmentType,
      'lead_id': leadId,
    });

    try {
      debugPrint('========== Add Co-Applicant ==========');
      debugPrint('--> POST $url');
      debugPrint('Body: $body');

      final response = await http.post(url, headers: headers, body: body);

      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in addCoApplicant: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to add co-applicant. Please try again.',
        'errors': e.toString(),
      };
    }
  }

  /// Get Co-Applicants List API: GET {{baseUrl}}/co-applicants
  static Future<Map<String, dynamic>> getCoApplicants({
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/co-applicants');
    final authToken = token ?? await SessionManager.getAuthToken();

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
    };

    try {
      final response = await http.get(url, headers: headers);

      debugPrint('========== Get Co-Applicants ==========');
      debugPrint('--> GET $url');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in getCoApplicants: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to fetch co-applicants list. Please try again.',
        'errors': e.toString(),
      };
    }
  }

  /// Get Co-Applicant Details API: GET {{baseUrl}}/co-applicants/{co_applicant_id}
  static Future<Map<String, dynamic>> getCoApplicantDetails({
    required dynamic coApplicantId,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/co-applicants/$coApplicantId');
    final authToken = token ?? await SessionManager.getAuthToken();

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
    };

    try {
      final response = await http.get(url, headers: headers);

      debugPrint('========== Get Co-Applicant Details ==========');
      debugPrint('--> GET $url');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in getCoApplicantDetails: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to fetch co-applicant details. Please try again.',
        'errors': e.toString(),
      };
    }
  }

  /// Delete Co-Applicant API: DELETE {{baseUrl}}/co-applicants/{id}
  static Future<Map<String, dynamic>> deleteCoApplicant({
    required dynamic coApplicantId,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/co-applicants/$coApplicantId');
    final authToken = token ?? await SessionManager.getAuthToken();

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
    };

    try {
      final response = await http.delete(url, headers: headers);

      debugPrint('========== Delete Co-Applicant ==========');
      debugPrint('--> DELETE $url');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in deleteCoApplicant: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to delete co-applicant. Please try again.',
        'errors': e.toString(),
      };
    }
  }

  /// Update Co-Applicant API: POST {{baseUrl}}/co-applicants/{id}
  static Future<Map<String, dynamic>> updateCoApplicant({
    required dynamic coApplicantId,
    required String coApplicantName,
    required String coApplicantMobile,
    required String coRelationship,
    required String applicantType,
    required String employmentType,
    Map<String, dynamic>? additionalFields,
    dynamic leadId,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/co-applicants/$coApplicantId');
    final authToken = token ?? await SessionManager.getAuthToken();

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
    };

    final Map<String, dynamic> bodyMap = {
      'co_applicant_name': coApplicantName,
      'co_applicant_mobile': coApplicantMobile,
      'co_relationship': coRelationship,
      'applicant_type': applicantType,
      'employment_type': employmentType,
    };
    if (additionalFields != null) {
      bodyMap.addAll(additionalFields);
    }
    if (leadId != null) {
      bodyMap['lead_id'] = leadId;
    }
    final body = jsonEncode(bodyMap);

    try {
      final response = await http.post(url, headers: headers, body: body);

      debugPrint('========== Update Co-Applicant ==========');
      debugPrint('--> POST $url');
      debugPrint('Request Body: $body');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in updateCoApplicant: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to update co-applicant. Please try again.',
        'errors': e.toString(),
      };
    }
  }

  /// Get Bank Loan Suggestions API: POST {{baseUrl}}/loan-suggestions
  static Future<Map<String, dynamic>> getLoanSuggestions({
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/loan-suggestions');
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
        body: jsonEncode({}),
      );

      debugPrint('========== Get Loan Suggestions ==========');
      debugPrint('--> POST $url');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in getLoanSuggestions: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to fetch bank loan suggestions. Please try again.',
        'errors': e.toString(),
      };
    }
  }

  /// Get Applicant Details API: GET {{baseUrl}}/applicants/{user_id}
  static Future<Map<String, dynamic>> getApplicantDetails({
    required dynamic userId,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/applicants/$userId');
    final authToken = token ?? await SessionManager.getAuthToken();

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
    };

    try {
      final response = await http.get(url, headers: headers);

      debugPrint('========== Get Applicant Details ==========');
      debugPrint('--> GET $url');
      debugPrint('Headers: $headers');
      debugPrint('<--------- Status:---------- ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } catch (e) {
      debugPrint('Exception in getApplicantDetails: $e');
      return {
        'success': false,
        'status_code': 500,
        'message': 'Failed to fetch applicant details. Please try again.',
        'errors': e.toString(),
      };
    }
  }
}
