import 'dart:convert';
import 'dart:io';

import 'package:flemozi/api/api.dart';
import 'package:flemozi/intents/close_window.dart';
import 'package:flemozi/pages/root.dart';
import 'package:flemozi/utils/platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:http/http.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart' as window_size;

void main(List<String> args) async {
  final isHeadless = args.contains("--headless");

  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await hotKeyManager.unregisterAll();
  SystemTheme.fallbackColor = Colors.blue;
  await SystemTheme.accentColor.load();

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

  /// No shortcut for wayland as it's not supported (yet)
  if (kIsWayland) {
    try {
      await get(Uri.parse("http://localhost:42069/show"));
      exit(0);
    } catch (e) {
      await api();
    }
  } else {
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
        if (await windowManager.isVisible() &&
            !await windowManager.isFocused()) {
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
  }

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
        themeMode: ThemeMode.dark,
        theme: ThemeData.light(useMaterial3: true),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: SystemTheme.accentColor.accent,
          splashFactory: NoSplash.splashFactory,
          scaffoldBackgroundColor: Colors.transparent,
          tabBarTheme: TabBarTheme(
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[850]?.withOpacity(.5),
          ),
        ),
        builder: (context, child) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  isDark ? Colors.grey[900]!.withOpacity(.5) : Colors.white60,
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
