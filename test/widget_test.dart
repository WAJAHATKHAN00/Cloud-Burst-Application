import 'package:flutter_test/flutter_test.dart';

import 'package:cloud_burst/app/app.dart';

void main() {
  testWidgets('app shows splash screen', (tester) async {
    await tester.pumpWidget(const CloudBurstApp());

    expect(find.text('CloudBurst Alert'), findsOneWidget);
  });
}
