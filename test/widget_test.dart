import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget( const TECHstile() as Widget);
    expect(find.text('ServEase'), findsOneWidget);
  });
}

class TECHstile {
  const TECHstile();
}
