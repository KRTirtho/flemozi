import 'package:alfred/alfred.dart';
import 'package:window_manager/window_manager.dart';

Future<void> api([int port = 42069]) async {
  final app = Alfred();

  app.get(
    '/ping',
    (req, res) {
      res.json({'pong': true});
    },
  );

  app.get(
    '/show',
    (req, res) async {
      if (await windowManager.isVisible() && !await windowManager.isFocused()) {
        await windowManager.setAlwaysOnTop(true);
        await windowManager.focus();
        Future.delayed(const Duration(milliseconds: 100), () async {
          await windowManager.setAlwaysOnTop(false);
          await windowManager.focus();
        });
      } else {
        await windowManager.setAlwaysOnTop(true);
        await windowManager.show();
        await windowManager.focus();
        Future.delayed(const Duration(milliseconds: 100), () async {
          await windowManager.setAlwaysOnTop(false);
          await windowManager.focus();
        });
      }

      res.json({'visible': await windowManager.isVisible()});
    },
  );

  await app.listen(port);
}
