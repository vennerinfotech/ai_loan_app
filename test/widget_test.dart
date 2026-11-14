import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ai_loan_app/main.dart';
import 'package:ai_loan_app/controller/splash_controller.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FinsphereApp());
    expect(find.byType(FinsphereApp), findsOneWidget);

    // Complete splash timer and clean up
    await tester.pump(const Duration(seconds: 5));
    Get.delete<SplashController>();
  });
}
