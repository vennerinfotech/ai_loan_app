import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../theme/app_colors.dart';

/// Data container for generating the Official CIBIL Bureau Report PDF
class CibilReportData {
  final String fullName;
  final String dob;
  final String gender;
  final String panNumber;
  final String aadhaarNumber;
  final String contactNumber;
  final String email;
  final String registeredAddress;
  final int score;
  final String referenceId;
  final DateTime generatedDate;

  CibilReportData({
    required this.fullName,
    required this.dob,
    required this.gender,
    required this.panNumber,
    required this.aadhaarNumber,
    required this.contactNumber,
    required this.email,
    required this.registeredAddress,
    this.score = 793,
    String? referenceId,
    DateTime? generatedDate,
  })  : referenceId = referenceId ??
            'CIB-${panNumber.isNotEmpty ? panNumber.toUpperCase() : "REPORT"}${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase().padLeft(6, "0").substring(0, 6)}',
        generatedDate = generatedDate ?? DateTime.now();
}

/// Service that creates a pixel-perfect CIBIL Bureau Report PDF
/// matching the exact structure and visual styling of the official report.
class CibilReportPdfService {
  /// Generate PDF document as raw Uint8List bytes
  static Future<Uint8List> generatePdf(CibilReportData data) async {
    final pdf = pw.Document();

    final dateFormatted =
        DateFormat('dd MMM, yyyy HH:mm a').format(data.generatedDate);

    // Score rating & status text
    final String scoreRating;
    if (data.score >= 750) {
      scoreRating = 'Excellent';
    } else if (data.score >= 700) {
      scoreRating = 'Good';
    } else if (data.score >= 650) {
      scoreRating = 'Fair';
    } else {
      scoreRating = 'Needs Attention';
    }

    final primaryBlue = PdfColor.fromHex('0B5CAB');
    final darkText = PdfColor.fromHex('222222');
    final mutedText = PdfColor.fromHex('666666');
    final borderGrey = PdfColor.fromHex('DCE2E6');
    final cardBgGrey = PdfColor.fromHex('FAFAFA');
    final greenText = PdfColor.fromHex('168A48');
    final greenBadgeBg = PdfColor.fromHex('EBF7ED');
    final greenBadgeBorder = PdfColor.fromHex('81C784');
    final greenBadgeText = PdfColor.fromHex('2E7D32');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Subtle background watermark
              pw.Positioned.fill(
                child: pw.Center(
                  child: pw.Transform.rotate(
                    angle: -math.pi / 4,
                    child: pw.Text(
                      'CONFIDENTIAL',
                      style: pw.TextStyle(
                        color: PdfColor.fromHex('F3F5F7'),
                        fontSize: 64,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              // Main report content
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // 1. TOP HEADER SECTION
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Left: CIBIL branding & compliance badges
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            children: [
                              pw.Text(
                                'CIBIL ',
                                style: pw.TextStyle(
                                  color: primaryBlue,
                                  fontSize: 24,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text(
                                '| Bureau Report',
                                style: pw.TextStyle(
                                  color: darkText,
                                  fontSize: 22,
                                  fontWeight: pw.FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 6),
                          pw.Row(
                            children: [
                              _buildPillBadge(
                                text: 'GOVERNMENT VERIFIED',
                                bg: greenBadgeBg,
                                border: greenBadgeBorder,
                                textColor: greenBadgeText,
                              ),
                              pw.SizedBox(width: 8),
                              _buildPillBadge(
                                text: 'RBI COMPLIANT',
                                bg: greenBadgeBg,
                                border: greenBadgeBorder,
                                textColor: greenBadgeText,
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Right: Meta details
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          _buildMetaRow('Report Generated: ', dateFormatted),
                          pw.SizedBox(height: 2),
                          _buildMetaRow('Reference ID: ', data.referenceId),
                          pw.SizedBox(height: 2),
                          _buildMetaRow(
                              'Data Source: ', 'Verified Bureau Database'),
                        ],
                      ),
                    ],
                  ),

                  // Divider line below header
                  pw.Container(
                    height: 2,
                    color: primaryBlue,
                    margin: const pw.EdgeInsets.only(top: 10, bottom: 12),
                  ),

                  // 2. YOUR OFFICIAL CREDIT SCORE CARD
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: borderGrey, width: 1),
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    child: pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      decoration: pw.BoxDecoration(
                        color: cardBgGrey,
                        borderRadius:
                            const pw.BorderRadius.all(pw.Radius.circular(6)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'YOUR OFFICIAL CREDIT SCORE',
                            style: pw.TextStyle(
                              color: mutedText,
                              fontSize: 9.5,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            '${data.score}',
                            style: pw.TextStyle(
                              color: greenText,
                              fontSize: 44,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            scoreRating,
                            style: pw.TextStyle(
                              color: greenText,
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            'Score Range: 300-900. Higher is better. This score is calculated based on your credit history across all banks and financial institutions.',
                            style: pw.TextStyle(
                              color: mutedText,
                              fontSize: 7.5,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  pw.SizedBox(height: 12),

                  // 3. PERSONAL INFORMATION CARD
                  pw.Container(
                    width: double.infinity,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: borderGrey, width: 1),
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.fromLTRB(14, 10, 14, 8),
                          child: pw.Text(
                            'PERSONAL INFORMATION',
                            style: pw.TextStyle(
                              color: primaryBlue,
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Container(height: 0.8, color: borderGrey),
                        _buildInfoRow('Full Name', data.fullName),
                        _buildInfoRow('Date of Birth', data.dob),
                        _buildInfoRow('Gender', data.gender),
                        _buildInfoRow(
                          'PAN Number',
                          data.panNumber,
                          badgeText: 'VERIFIED',
                        ),
                        _buildInfoRow(
                          'Aadhaar Number',
                          data.aadhaarNumber,
                          badgeText: 'LINKED',
                        ),
                        _buildInfoRow('Contact Number', data.contactNumber),
                        _buildInfoRow('Email Address', data.email),
                        _buildInfoRow('Registered Address', data.registeredAddress,
                            isLast: true),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 12),

                  // 4. ACCOUNT SUMMARY & COMPLIANCE CARD
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.fromLTRB(14, 10, 14, 12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: borderGrey, width: 1),
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'ACCOUNT SUMMARY & COMPLIANCE',
                          style: pw.TextStyle(
                            color: primaryBlue,
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Container(
                          height: 0.8,
                          color: borderGrey,
                          margin: const pw.EdgeInsets.symmetric(vertical: 8),
                        ),
                        _buildComplianceParagraph(
                          title: 'Strictly Confidential: ',
                          body:
                              'This report is generated secure servers and is intended solely for the use of the individual to whom it pertains. Access to this report is logged and monitored.',
                        ),
                        pw.SizedBox(height: 6),
                        _buildComplianceParagraph(
                          title: 'Government Compliance: ',
                          body:
                              'This credit report is generated in accordance with the Credit Information Companies (Regulation) Act, 2005 and RBI guidelines. The data presented is aggregated from certified member institutions.',
                        ),
                        pw.SizedBox(height: 6),
                        _buildComplianceParagraph(
                          title: 'Disclaimer: ',
                          body:
                              'The score provided is an estimate based on available data. Actual eligibility for loans or credit cards depends on the internal policies of the lending institution.',
                        ),
                      ],
                    ),
                  ),

                  pw.Spacer(),

                  // 5. FOOTER SECTION
                  pw.Container(
                    height: 0.8,
                    color: PdfColor.fromHex('E0E0E0'),
                    margin: const pw.EdgeInsets.only(bottom: 6),
                  ),
                  pw.Center(
                    child: pw.Text(
                      'Generated by AI FinSphere © 2026 | Certified Secure System | Page 1 of 1',
                      style: pw.TextStyle(
                        color: PdfColor.fromHex('888888'),
                        fontSize: 7.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Triggers native "Save As" location dialog and saves the report
  static Future<bool> saveOrDownloadPdf({
    required CibilReportData data,
  }) async {
    try {
      final bytes = await generatePdf(data);
      final safePan = data.panNumber.replaceAll(RegExp(r'\s+'), '').toUpperCase();
      final defaultFileName =
          'Official_CIBIL_Report_${safePan.isNotEmpty ? safePan : "AMNPG7909B"}.pdf';

      // Open Save As dialog allowing user to choose directory and filename
      final resultUri = await FilePicker.saveFile(
        dialogTitle: 'Save CIBIL Bureau Report',
        fileName: defaultFileName,
        bytes: bytes,
        mimeType: 'application/pdf',
      );

      if (resultUri != null) {
        Get.snackbar(
          'Download Successful',
          'Report saved as $defaultFileName',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.navy,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        );
        return true;
      } else {
        // User cancelled location selection
        return false;
      }
    } catch (e) {
      debugPrint('Error saving CIBIL report PDF: $e');
      Get.snackbar(
        'Download Failed',
        'Could not save report: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
  }

  // Helper: Pill badge
  static pw.Widget _buildPillBadge({
    required String text,
    required PdfColor bg,
    required PdfColor border,
    required PdfColor textColor,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: pw.BoxDecoration(
        color: bg,
        border: pw.Border.all(color: border, width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: textColor,
          fontSize: 7.5,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  // Helper: Header metadata row
  static pw.Widget _buildMetaRow(String label, String value) {
    return pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: label,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 8,
              color: PdfColor.fromHex('333333'),
            ),
          ),
          pw.TextSpan(
            text: value,
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColor.fromHex('555555'),
            ),
          ),
        ],
      ),
    );
  }

  // Helper: Personal information table row
  static pw.Widget _buildInfoRow(
    String label,
    String value, {
    String? badgeText,
    bool isLast = false,
  }) {
    final borderGrey = PdfColor.fromHex('ECEFF1');
    final rowBg = PdfColor.fromHex('FFFFFF');

    return pw.Container(
      decoration: pw.BoxDecoration(
        color: rowBg,
        border: isLast
            ? null
            : pw.Border(
                bottom: pw.BorderSide(color: borderGrey, width: 0.8),
              ),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 6.5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 140,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                color: PdfColor.fromHex('333333'),
                fontSize: 8.5,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(
                    value.isNotEmpty ? value : '-',
                    style: pw.TextStyle(
                      color: PdfColor.fromHex('222222'),
                      fontSize: 8.5,
                      fontWeight: pw.FontWeight.normal,
                    ),
                  ),
                ),
                if (badgeText != null) ...[
                  pw.SizedBox(width: 6),
                  _buildPillBadge(
                    text: badgeText,
                    bg: PdfColor.fromHex('EBF7ED'),
                    border: PdfColor.fromHex('81C784'),
                    textColor: PdfColor.fromHex('2E7D32'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper: Compliance note paragraph
  static pw.Widget _buildComplianceParagraph({
    required String title,
    required String body,
  }) {
    return pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: title,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 7.5,
              color: PdfColor.fromHex('222222'),
            ),
          ),
          pw.TextSpan(
            text: body,
            style: pw.TextStyle(
              fontSize: 7.5,
              color: PdfColor.fromHex('555555'),
              lineSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
