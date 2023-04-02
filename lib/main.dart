import 'dart:convert';
import 'dart:io';

import 'package:fl_query/fl_query.dart';
import 'package:flemozi/api/api.dart';
import 'package:flemozi/collections/env.dart';
import 'package:flemozi/intents/close_window.dart';
import 'package:flemozi/intents/switch_tabs.dart';
import 'package:flemozi/pages/root.dart';
import 'package:flemozi/utils/platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart' as window_size;
import 'package:path_provider/path_provider.dart';

void main(List<String> args) async {
  final isHeadless = args.contains("--headless");

  WidgetsFlutterBinding.ensureInitialized();
  await Env.configure();
  await windowManager.ensureInitialized();

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
  }

  final appDataDir = await getApplicationSupportDirectory();

  await QueryClient.initialize(
    cachePrefix: 'flemoji',
    cacheDir: appDataDir.path,
  );
  await Hive.openBox('flemozi.config');
  runApp(const ProviderScope(child: Flemozi()));
}

class Flemozi extends StatefulHookConsumerWidget {
  const Flemozi({super.key});

  @override
  ConsumerState<Flemozi> createState() => _FlemoziState();
}

class _FlemoziState extends ConsumerState<Flemozi> with WidgetsBindingObserver {
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
    return QueryClientProvider(
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
        home: const RootPage(),
        shortcuts: {
          ...WidgetsApp.defaultShortcuts,
          LogicalKeySet(LogicalKeyboardKey.escape): const CloseWindowIntent(),
          LogicalKeySet(
            LogicalKeyboardKey.control,
            LogicalKeyboardKey.tab,
          ): SwitchTabsIntent(ref),
        },
        actions: {
          ...WidgetsApp.defaultActions,
          CloseWindowIntent: CloseWindowAction(),
          SwitchTabsIntent: SwitchTabsAction(),
        },
      ),
    );
  }
}
