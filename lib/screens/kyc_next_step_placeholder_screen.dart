import 'package:material_ui/material_ui.dart';
import '../theme/app_colors.dart';
import 'kyc_success_screen.dart';

/// Legacy alias for the KYC complete / success screen
class KycNextStepPlaceholderScreen extends StatelessWidget {
  final String? targetFeature;

  const KycNextStepPlaceholderScreen({
    super.key,
    this.targetFeature,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: KycSuccessBody(),
      ),
    );
  }
}

class KycNextStepPlaceholderBody extends StatelessWidget {
  final String? targetFeature;

  const KycNextStepPlaceholderBody({
    super.key,
    this.targetFeature,
  });

  @override
  Widget build(BuildContext context) {
    return const KycSuccessBody();
  }
}
