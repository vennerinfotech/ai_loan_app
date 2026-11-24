import 'dart:convert';
import 'dart:typed_data';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/my_documents_response_model.dart';
import '../models/wallet_document_model.dart';
import '../services/api_service.dart';
export '../models/wallet_document_model.dart';

class DocumentWalletController extends GetxController {
  final isLoading = false.obs;
  final myDocumentsData = Rxn<MyDocumentsResponseData>();

  final selectedCategory = 'All'.obs;
  final searchQuery = ''.obs;
  final searchController = TextEditingController();

  final categories = <String>['All', 'KYC', 'Income', 'Loan'].obs;
  final documents = <WalletDocumentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyDocuments();
  }

  /// Fetch documents strictly from GET {{baseUrl}}/my-documents
  Future<void> fetchMyDocuments() async {
    isLoading.value = true;
    try {
      final res = await ApiService.getMyDocuments();
      if (res['success'] == true || res['status_code'] == 200) {
        final data = MyDocumentsResponseData.fromJson(res);
        myDocumentsData.value = data;
        _populateDocumentsFromApi(data);
      } else {
        debugPrint('Notice in fetchMyDocuments: ${res['message']}');
        documents.clear();
      }
    } catch (e) {
      debugPrint('Error in fetchMyDocuments: $e');
      documents.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Maps API data entity into UI [WalletDocumentModel] cards
  void _populateDocumentsFromApi(MyDocumentsResponseData data) {
    final List<WalletDocumentModel> list = [];
    final doc = data.document;

    // 1. Aadhaar Card
    if (doc != null && (doc.aadharCardImage != null || doc.aadharCardNumber != null)) {
      final status = (doc.aadhaarStatus?.toLowerCase() == 'accepted' || doc.aadhaarStatus?.toLowerCase() == 'verified')
          ? 'Verified'
          : (doc.aadhaarStatus != null ? doc.aadhaarStatus!.capitalizeFirst! : 'Uploaded');
      final number = doc.aadharCardNumber != null && doc.aadharCardNumber!.length >= 4
          ? '•••• ${doc.aadharCardNumber!.substring(doc.aadharCardNumber!.length - 4)}'
          : 'Identity Proof';

      list.add(
        WalletDocumentModel(
          id: 'aadhaar',
          title: 'Aadhaar Card',
          subtitle: number,
          category: 'KYC',
          badgeText: status,
          icon: Icons.badge_outlined,
          isFeatured: true,
          frontImageUrl: doc.aadharCardImage != null ? '${ApiService.baseUrl}/storage/${doc.aadharCardImage}' : null,
          status: 'Verified via UIDAI',
          uploadedDate: _formatDate(doc.createdAt),
          usedIn: 'KYC Verification',
        ),
      );
    }

    // 2. PAN Card
    if (doc != null && (doc.panCardImage != null || doc.panCardNumber != null)) {
      final status = (doc.panStatus?.toLowerCase() == 'accepted' || doc.panStatus?.toLowerCase() == 'verified')
          ? 'Verified'
          : (doc.panStatus != null ? doc.panStatus!.capitalizeFirst! : 'Uploaded');
      final panNumber = doc.panCardNumber != null && doc.panCardNumber!.isNotEmpty
          ? doc.panCardNumber!
          : 'Tax ID Matched';

      list.add(
        WalletDocumentModel(
          id: 'pan',
          title: 'PAN Card',
          subtitle: panNumber,
          category: 'KYC',
          badgeText: status,
          icon: Icons.credit_card_rounded,
          frontImageUrl: doc.panCardImage != null ? '${ApiService.baseUrl}/storage/${doc.panCardImage}' : null,
          status: 'Income Tax Dept Verified',
          uploadedDate: _formatDate(doc.createdAt),
          usedIn: 'KYC Verification',
        ),
      );
    }

    // 3. Salaried Proof Image
    if (doc?.salariedProofImage != null && doc!.salariedProofImage!.isNotEmpty) {
      list.add(
        WalletDocumentModel(
          id: 'salaried_proof',
          title: 'Salary Slip / Proof',
          subtitle: _getFileExtension(doc.salariedProofImage),
          category: 'Income',
          badgeText: 'Added',
          icon: Icons.description_outlined,
          frontImageUrl: '${ApiService.baseUrl}/storage/${doc.salariedProofImage}',
          status: 'Income Verified',
          uploadedDate: _formatDate(doc.createdAt),
          usedIn: 'Income Verification',
        ),
      );
    }

    // 4. Business Proof Image
    if (doc?.businessProofImage != null && doc!.businessProofImage!.isNotEmpty) {
      list.add(
        WalletDocumentModel(
          id: 'business_proof',
          title: 'Business Proof',
          subtitle: _getFileExtension(doc.businessProofImage),
          category: 'Income',
          badgeText: 'Added',
          icon: Icons.business_center_outlined,
          frontImageUrl: '${ApiService.baseUrl}/storage/${doc.businessProofImage}',
          status: 'Business Verified',
          uploadedDate: _formatDate(doc.createdAt),
          usedIn: 'Income Verification',
        ),
      );
    }

    // 5. Documents from active leads
    for (final lead in data.leads) {
      // Bank Statement
      if (lead.bankStatement != null && lead.bankStatement!.isNotEmpty) {
        String bankName = 'Bank Statement';
        String status = 'Pending';
        try {
          final decoded = jsonDecode(lead.bankStatement!);
          if (decoded is List && decoded.isNotEmpty) {
            final first = decoded.first;
            if (first is Map) {
              bankName = first['name']?.toString() ?? 'bank_statement.pdf';
              status = first['status']?.toString().capitalizeFirst ?? 'Pending';
            }
          }
        } catch (_) {}

        list.add(
          WalletDocumentModel(
            id: 'bank_statement_${lead.id}',
            title: 'Bank Statement',
            subtitle: bankName,
            category: 'Income',
            badgeText: status,
            icon: Icons.account_balance_outlined,
            status: 'Lead #${lead.id}',
            uploadedDate: _formatDate(lead.createdAt),
            usedIn: lead.loanType ?? 'Loan Application',
          ),
        );
      }

      // Form 16 / ITR
      if (lead.form16Itr != null && lead.form16Itr!.isNotEmpty) {
        list.add(
          WalletDocumentModel(
            id: 'form16_${lead.id}',
            title: 'Form 16 / ITR',
            subtitle: _getFileExtension(lead.form16Itr),
            category: 'Income',
            badgeText: 'Added',
            icon: Icons.receipt_long_outlined,
            status: 'Income Tax Return',
            uploadedDate: _formatDate(lead.createdAt),
            usedIn: lead.loanType ?? 'Loan Application',
          ),
        );
      }

      // GST Registration
      if (lead.gstRegistration != null && lead.gstRegistration!.isNotEmpty) {
        list.add(
          WalletDocumentModel(
            id: 'gst_${lead.id}',
            title: 'GST Certificate',
            subtitle: _getFileExtension(lead.gstRegistration),
            category: 'Loan',
            badgeText: 'Verified',
            icon: Icons.verified_outlined,
            status: 'Business Tax Document',
            uploadedDate: _formatDate(lead.createdAt),
            usedIn: lead.loanType ?? 'Loan Application',
          ),
        );
      }
    }

    // Update categories with dynamic counts
    final total = list.length;
    final kycCount = list.where((d) => d.category.toLowerCase() == 'kyc').length;
    final incomeCount = list.where((d) => d.category.toLowerCase() == 'income').length;
    final loanCount = list.where((d) => d.category.toLowerCase() == 'loan').length;

    categories.assignAll([
      'All · $total',
      'KYC · $kycCount',
      'Income · $incomeCount',
      'Loan · $loanCount',
    ]);
    selectedCategory.value = 'All · $total';

    documents.assignAll(list);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Recent';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(dt.toLocal());
    } catch (_) {
      return dateStr;
    }
  }

  String _getFileExtension(String? path) {
    if (path == null || path.isEmpty) return 'Document';
    if (path.toLowerCase().endsWith('.pdf')) return 'PDF Document';
    if (path.toLowerCase().endsWith('.jpg') || path.toLowerCase().endsWith('.jpeg')) return 'JPG Image';
    if (path.toLowerCase().endsWith('.png')) return 'PNG Image';
    return 'Document';
  }

  List<WalletDocumentModel> get filteredDocuments {
    final cat = selectedCategory.value.split('·').first.trim().toLowerCase();
    final query = searchQuery.value.trim().toLowerCase();

    return documents.where((doc) {
      final matchesCategory = cat == 'all' || doc.category.toLowerCase() == cat;
      final matchesQuery = query.isEmpty ||
          doc.title.toLowerCase().contains(query) ||
          doc.subtitle.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void selectCategory(String cat) {
    selectedCategory.value = cat;
  }

  void onSearchChanged(String val) {
    searchQuery.value = val;
  }

  /// Updates or replaces the document image (front or back) for direct image rendering
  void updateDocumentImage(String id, Uint8List bytes, {bool isFront = true}) {
    final index = documents.indexWhere((d) => d.id == id);
    if (index != -1) {
      final doc = documents[index];
      documents[index] = doc.copyWith(
        frontImageBytes: isFront ? bytes : doc.frontImageBytes,
        backImageBytes: !isFront ? bytes : doc.backImageBytes,
      );
    }
  }
}
