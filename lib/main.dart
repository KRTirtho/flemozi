import 'package:flemozi/intents/close_window.dart';
import 'package:flemozi/pages/root.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart' as window_size;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await hotKeyManager.unregisterAll();

  window_size.setWindowMinSize(const Size(400, 300));
  window_size.setWindowMaxSize(const Size(720, 480));

  WindowOptions windowOptions = const WindowOptions(
    minimumSize: Size(400, 300),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: "Flemoji",
    maximumSize: Size(720, 480),
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  await hotKeyManager.register(
    HotKey(
      KeyCode.period,
      modifiers: [
        KeyModifier.control,
        KeyModifier.alt,
      ],
      identifier: "Show/Hide",
      scope: HotKeyScope.system,
    ),
    keyDownHandler: (hotKey) async {
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
    },
  );

  runApp(const Flemozi());
}

class Flemozi extends StatelessWidget {
  const Flemozi({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white60,
          colorScheme: ColorScheme.light(
            primary: Colors.grey[900]!,
            secondary: Colors.grey[900]!,
            background: Colors.white,
          ),
          tabBarTheme: TabBarTheme(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[900]!,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey[900]!,
            ),
          ),
        ),
        home: CallbackShortcuts(
          bindings: {
            LogicalKeySet(LogicalKeyboardKey.escape): () {
              windowManager.hide();
            },
          },
          child: const RootPage(),
        ),
        shortcuts: {
          ...WidgetsApp.defaultShortcuts,
          LogicalKeySet(LogicalKeyboardKey.escape): const CloseWindowIntent(),
        },
        actions: {
          ...WidgetsApp.defaultActions,
          CloseWindowIntent: CloseWindowAction(),
        },
      ),
    );
  }
}
