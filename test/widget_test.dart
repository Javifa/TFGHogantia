import 'package:flutter_test/flutter_test.dart';
import 'package:hogentia/app.dart';

void main() {
  testWidgets('HogentiaApp se construye sin errores', (tester) async {
    await tester.pumpWidget(const HogentiaApp());
  });
}
