import 'package:material_ui/material_ui.dart';
import '../theme/app_colors.dart';

/// Custom floating capsule bottom navigation bar.
/// Matches reference image (Dashboard Image 1):
/// - Dark navy capsule container (#212074)
/// - Home, Cards, Center '+' in Golden Amber, Docs, Profile
class CustomFloatingBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomFloatingBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      height: 68,
      decoration: BoxDecoration(
        color: AppColors.bottomNavBackground,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: AppColors.bottomNavBackground.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 0: Home
          _buildNavItem(
            index: 0,
            icon: Icons.home_rounded,
            isSelected: currentIndex == 0,
          ),

          // 1: Cards / EMIs
          _buildNavItem(
            index: 1,
            icon: Icons.credit_card_rounded,
            isSelected: currentIndex == 1,
          ),

          // 2: Center Highlighted Add Button
          GestureDetector(
            onTap: () => onTap(2),
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: AppColors.bottomNavCenterButton,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x40FBC14E),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.add_rounded,
                  color: AppColors.bottomNavCenterIcon,
                  size: 26,
                ),
              ),
            ),
          ),

          // 3: Documents / Reports
          _buildNavItem(
            index: 3,
            icon: Icons.receipt_long_outlined,
            isSelected: currentIndex == 3,
          ),

          // 4: Profile
          _buildNavItem(
            index: 4,
            icon: Icons.person_outline_rounded,
            isSelected: currentIndex == 4,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.12) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            icon,
            color: isSelected ? Colors.white : AppColors.bottomNavUnselected,
            size: 22,
          ),
        ),
      ),
    );
  }
}
