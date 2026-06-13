<<<<<<< HEAD
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
=======
import 'package:flutter/src/widgets/framework.dart';
>>>>>>> f44b02be608a92b5bc15c86d59c01e7daf52d4a7
import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
<<<<<<< HEAD
    await tester.pumpWidget(const TECHstile());
    expect(find.text('Techstile'), findsOneWidget);
=======
    await tester.pumpWidget( const TECHstile() as Widget);
    expect(find.text('ServEase'), findsOneWidget);
>>>>>>> f44b02be608a92b5bc15c86d59c01e7daf52d4a7
  });
}

class TECHstile {
  const TECHstile();
}
