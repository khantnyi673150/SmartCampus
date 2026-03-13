import 'package:flutter_test/flutter_test.dart';

import 'package:smart_class_checkin_reflection_app/main.dart';

void main() {
  testWidgets('Home screen shows check-in and finish class buttons', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SmartClassApp());

    expect(find.text('Check-in'), findsOneWidget);
    expect(find.text('Finish Class'), findsOneWidget);
  });
}
