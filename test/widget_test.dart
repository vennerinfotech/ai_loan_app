import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ai_loan_app/main.dart';
import 'package:ai_loan_app/screens/splash_screen.dart';

void main() {
  testWidgets('Splash screen loads properly', (WidgetTester tester) async {
    await tester.pumpWidget(const FinsphereApp());

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.textContaining('Finsphere'), findsOneWidget);
    expect(find.text('Your financial partner'), findsOneWidget);
    expect(find.text('SECURING YOUR SESSION'), findsOneWidget);
  });
}
