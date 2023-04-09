import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flemozi/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets(
      'tap on the GIFs tab and verify the GIFs are loaded',
      (tester) async {
        await app.main([]);
        await tester.pumpAndSettle(
          const Duration(seconds: 1),
        );

        expect(find.byTooltip('GIFs'), findsOneWidget);

        await tester.tap(find.byTooltip('GIFs'));
      },
    );
  });
}
