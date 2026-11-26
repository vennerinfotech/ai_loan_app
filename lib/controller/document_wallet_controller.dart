import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';
import '../models/my_documents_response_model.dart';
import '../models/wallet_document_model.dart';
import '../services/api_service.dart';
export '../models/wallet_document_model.dart';

class DocumentWalletController extends GetxController {
  final isLoading = false.obs;
  final myDocumentsData = Rxn<MyDocumentsResponseData>();

  final searchQuery = ''.obs;
  final searchController = TextEditingController();

  // Section Filters: All, Applicant, Co-Applicant, Loan Application
  final selectedSection = 'All'.obs;
  final sectionFilters = <String>[
    'All',
    'Applicant',
    'Co-Applicant',
    'Loan Application',
  ];

  final documents = <WalletDocumentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyDocuments();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// Fetch documents strictly from GET {{baseUrl}}/my-documents
  Future<void> fetchMyDocuments() async {
    isLoading.value = true;
    try {
      final res = await ApiService.getMyDocuments();
      if (res['success'] == true || res['status_code'] == 200) {
        final data = MyDocumentsResponseData.fromJson(res);
        myDocumentsData.value = data;
      } else {
        debugPrint('Notice in fetchMyDocuments: ${res['message']}');
        myDocumentsData.value = null;
      }
    } catch (e) {
      debugPrint('Error in fetchMyDocuments: $e');
      myDocumentsData.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Checks if applicant documents exist
  bool get hasApplicantDocuments {
    final doc = myDocumentsData.value?.document;
    if (doc == null) return false;
    return (doc.aadharCardNumber != null ||
        doc.panCardNumber != null ||
        doc.cibilScore != null ||
        (myDocumentsData.value?.documentUrls?.aadhaar.isNotEmpty ?? false) ||
        (myDocumentsData.value?.documentUrls?.pan.isNotEmpty ?? false));
  }

  /// Gets list of co-applicants who have documents or KYC details
  List<MyDocumentsCoApplicant> get coApplicantsWithDocuments {
    final list = myDocumentsData.value?.coApplicants ?? [];
    return list.where((ca) {
      final hasAadhaar = (ca.aadhaarCardNumber != null && ca.aadhaarCardNumber!.isNotEmpty) ||
          ca.aadhaarCardImageUrls.isNotEmpty;
      final hasPan = (ca.panCardNumber != null && ca.panCardNumber!.isNotEmpty) ||
          (ca.panCardImageUrl != null && ca.panCardImageUrl!.isNotEmpty);
      final hasDocs = ca.documents != null &&
          (ca.documents is List ? (ca.documents as List).isNotEmpty : true);
      return hasAadhaar || hasPan || hasDocs;
    }).toList();
  }

  /// Checks if co-applicant documents exist
  bool get hasCoApplicantDocuments => coApplicantsWithDocuments.isNotEmpty;

  /// Gets leads that have uploaded files in document_files
  List<MyDocumentsLead> get leadsWithDocuments {
    final leads = myDocumentsData.value?.leads ?? [];
    return leads.where((l) => l.documentFiles.isNotEmpty).toList();
  }

  /// Checks if loan application documents exist
  bool get hasLoanApplicationDocuments => leadsWithDocuments.isNotEmpty;

  /// Check if entire document wallet is empty
  bool get isEmptyWallet {
    return !hasApplicantDocuments && !hasCoApplicantDocuments && !hasLoanApplicationDocuments;
  }

  void onSearchChanged(String val) {
    searchQuery.value = val;
  }

  /// Updates or replaces the document image (front or back) in memory
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
