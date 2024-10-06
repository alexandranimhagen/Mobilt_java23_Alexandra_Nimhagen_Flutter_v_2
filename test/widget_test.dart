import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobilt_java23_alexandra_nimhagen_flutter_v2/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Bygg appen och trigga en frame.
    await tester.pumpWidget(const MyApp());

    // Verifiera att räknaren startar på 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tryck på '+' ikonen och trigga en frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verifiera att räknaren har ökat.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
