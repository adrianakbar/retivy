import 'package:flutter_test/flutter_test.dart';
import 'package:retivy/main.dart';

void main() {
  testWidgets('Retivy smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle(); // Settle async database loading

    // Verify that Retivy app renders correctly
    expect(find.byType(MyApp), findsOneWidget);
  });
}
