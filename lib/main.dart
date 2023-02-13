import 'dart:convert';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart' as window_size;

void main(List<String> args) async {
  final isHeadless = args.contains("--headless");

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
    final localStorage = await SharedPreferences.getInstance();
    final rawSize = localStorage.getString('window_size');
    final savedSize = rawSize != null ? json.decode(rawSize) : null;
    final double? height = savedSize?["height"];
    final double? width = savedSize?["width"];
    if (height != null && width != null) {
      await windowManager.setSize(Size(width, height));
    }
    await windowManager.setAsFrameless();

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

class Flemozi extends StatefulWidget {
  const Flemozi({super.key});

  @override
  State<Flemozi> createState() => _FlemoziState();
}

class _FlemoziState extends State<Flemozi> with WidgetsBindingObserver {
  Size? prevSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() async {
    super.didChangeMetrics();
    final localStorage = await SharedPreferences.getInstance();
    final size = await windowManager.getSize();
    final windowSameDimension =
        prevSize?.width == size.width && prevSize?.height == size.height;

    if (windowSameDimension) return;
    localStorage.setString(
      'window_size',
      jsonEncode({
        'width': size.width,
        'height': size.height,
      }),
    );
    prevSize = size;
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
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
        darkTheme: ThemeData(
          scaffoldBackgroundColor: Colors.transparent,
          colorScheme: ColorScheme.dark(
            primary: Colors.grey[700]!,
            secondary: Colors.grey[700]!,
            background: Colors.grey[900]!,
            onBackground: Colors.grey[700]!,
            onPrimary: Colors.grey[900]!,
            onSecondary: Colors.grey[900]!,
            primaryContainer: Colors.grey[700]!,
            secondaryContainer: Colors.grey[700]!,
            surface: Colors.grey[900]!,
            onSurface: Colors.grey[700]!,
            tertiary: Colors.grey[700]!,
            onTertiary: Colors.grey[900]!,
            error: Colors.red,
            onError: Colors.grey[700]!,
            errorContainer: Colors.red,
            onSecondaryContainer: Colors.grey[900]!,
            onPrimaryContainer: Colors.grey[900]!,
            scrim: Colors.black,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[700]!,
          ),
          tabBarTheme: TabBarTheme(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[700]!,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey[700]!,
            ),
          ),
        ),
        builder: (context, child) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  isDark ? Colors.grey[900]!.withOpacity(.6) : Colors.white60,
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
