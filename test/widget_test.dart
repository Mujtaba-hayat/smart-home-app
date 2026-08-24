import 'package:flutter_test/flutter_test.dart';

import 'package:smart_home/main.dart';

void main() {
  testWidgets('Smart Home app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartHomeApp());

    expect(find.byType(SmartHomeApp), findsOneWidget);
  });
}