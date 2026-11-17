import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

class WalletDocumentModel {
  final String id;
  final String title;
  final String subtitle;
  final String category; // 'KYC', 'Income', 'Loan'
  final String badgeText;
  final IconData icon;
  final bool isFeatured; // true for Aadhaar (dark blue card)

  WalletDocumentModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.badgeText,
    required this.icon,
    this.isFeatured = false,
  });
}

class DocumentWalletController extends GetxController {
  final selectedCategory = 'All · 6'.obs;
  final searchQuery = ''.obs;
  final searchController = TextEditingController();

  final categories = ['All · 6', 'KYC', 'Income', 'Loan'];

  final documents = <WalletDocumentModel>[
    WalletDocumentModel(
      id: 'aadhaar',
      title: 'Aadhaar card',
      subtitle: 'Front + back · 12 Nov',
      category: 'KYC',
      badgeText: 'Verified',
      icon: Icons.badge_outlined,
      isFeatured: true,
    ),
    WalletDocumentModel(
      id: 'pan',
      title: 'PAN card',
      subtitle: 'JPG · 840 KB',
      category: 'KYC',
      badgeText: 'Verified',
      icon: Icons.credit_card_rounded,
    ),
    WalletDocumentModel(
      id: 'salary_slips',
      title: 'Salary slips',
      subtitle: 'PDF · 1.2 MB',
      category: 'Income',
      badgeText: 'Added',
      icon: Icons.description_outlined,
    ),
    WalletDocumentModel(
      id: 'bank_statement',
      title: 'Bank statement',
      subtitle: 'PDF · 2.8 MB',
      category: 'Income',
      badgeText: 'Added',
      icon: Icons.description_outlined,
    ),
    WalletDocumentModel(
      id: 'form_16',
      title: 'Form 16 / ITR',
      subtitle: 'PDF · 960 KB',
      category: 'Income',
      badgeText: 'Added',
      icon: Icons.description_outlined,
    ),
    WalletDocumentModel(
      id: 'credit_report',
      title: 'Credit report',
      subtitle: 'CIBIL · Nov 2026',
      category: 'Loan',
      badgeText: 'Latest',
      icon: Icons.bar_chart_rounded,
    ),
  ].obs;

  List<WalletDocumentModel> get filteredDocuments {
    final cat = selectedCategory.value;
    final query = searchQuery.value.trim().toLowerCase();

    return documents.where((doc) {
      final matchesCategory = cat.startsWith('All') || doc.category.toLowerCase() == cat.toLowerCase();
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
}
