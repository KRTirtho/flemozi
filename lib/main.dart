import 'dart:io';

import 'package:flemozi/intents/close_window.dart';
import 'package:flemozi/pages/root.dart';
import 'package:flemozi/utils/platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart' as window_size;

void main(List<String> args) async {
  final isHeadless = args.contains("--headless") && !kIsWayland;

  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await hotKeyManager.unregisterAll();

  window_size.setWindowMinSize(const Size(400, 300));
  window_size.setWindowMaxSize(const Size(720, 480));

  final packageInfo = await PackageInfo.fromPlatform();

  launchAtStartup.setup(
    appName: packageInfo.appName,
    appPath: Platform.resolvedExecutable,
    args: <String>["--headless"],
  );

  await launchAtStartup.enable();

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
    if (isHeadless) return;
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
        if (kIsLinux) await windowManager.setAlwaysOnTop(true);
        await windowManager.focus();
        if (kIsLinux) {
          Future.delayed(const Duration(milliseconds: 100), () async {
            await windowManager.setAlwaysOnTop(false);
            await windowManager.focus();
          });
        }
      } else {
        if (kIsLinux) await windowManager.setAlwaysOnTop(true);
        await windowManager.show();
        await windowManager.focus();
        if (kIsLinux) {
          Future.delayed(const Duration(milliseconds: 100), () async {
            await windowManager.setAlwaysOnTop(false);
            await windowManager.focus();
          });
        }
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
          scaffoldBackgroundColor: Colors.transparent,
          colorScheme: ColorScheme.light(
            primary: Colors.grey[900]!,
            secondary: Colors.grey[900]!,
            background: Colors.white,
            onBackground: Colors.grey[900]!,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            primaryContainer: Colors.grey[900]!,
            secondaryContainer: Colors.grey[900]!,
            surface: Colors.white,
            onSurface: Colors.grey[900]!,
            tertiary: Colors.grey[900]!,
            onTertiary: Colors.white,
            error: Colors.red,
            onError: Colors.white,
            errorContainer: Colors.red,
            onSecondaryContainer: Colors.white,
            onPrimaryContainer: Colors.white,
            scrim: Colors.black,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Colors.white70,
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
        builder: (context, child) {
          return Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white60,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DragToResizeArea(child: child!),
          );
        },
        home: CallbackShortcuts(
          bindings: {
            LogicalKeySet(LogicalKeyboardKey.escape): () =>
                CloseWindowAction().invoke(const CloseWindowIntent()),
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
