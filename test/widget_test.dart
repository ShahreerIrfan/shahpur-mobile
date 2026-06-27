import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('Shahpur mobile app opens home screen', (tester) async {
    await tester.pumpWidget(const ShahpurApp());
    await tester.pump();

    expect(find.text('শাহপুর দরবার শরীফ'), findsWidgets);
    expect(find.text('হোম'), findsWidgets);
  });
}
