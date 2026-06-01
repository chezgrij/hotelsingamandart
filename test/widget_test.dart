import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_singa_inn/main.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HotelApp());

    // Verify that the title exists
    expect(find.text('Hotel SingaINN - Management System'), findsOneWidget);
  });
}
