import 'package:flutter_test/flutter_test.dart';

import 'package:app/app/app.dart';

void main() {
  testWidgets('App launches and shows Home Screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MiniTdApp());

    // Verify that our game home screen is visible.
    expect(find.text('Mini Tower Defense'), findsOneWidget);
    expect(find.text('Select a Battlefield'), findsOneWidget);
  });
}
