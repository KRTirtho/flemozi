import 'package:flemozi/components/ui/vertical_tabs.dart';
import 'package:flemozi/models/shortcut_def.dart';
import 'package:flemozi/pages/settings/settings.dart';
import 'package:flemozi/utils/platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:window_manager/window_manager.dart';

typedef ProviderReader = T Function<T>(ProviderListenable<T> provider);

abstract class ShortcutActions {
  static void openFlemozi(ProviderReader read, BuildContext context) async {
    if (await windowManager.isVisible() && !await windowManager.isFocused()) {
      if (kIsLinux) {
        await windowManager.setAlwaysOnTop(true);
      }
      await windowManager.focus();
      if (kIsLinux) await windowManager.grabKeyboard();
      if (kIsLinux) {
        Future.delayed(const Duration(milliseconds: 100), () async {
          await windowManager.setAlwaysOnTop(false);
          await windowManager.focus();
          await windowManager.grabKeyboard();
        });
      }
    } else {
      if (kIsLinux) await windowManager.setAlwaysOnTop(true);
      await windowManager.show();
      await windowManager.focus();
      if (kIsLinux) await windowManager.grabKeyboard();
      if (kIsLinux) {
        Future.delayed(const Duration(milliseconds: 100), () async {
          await windowManager.setAlwaysOnTop(false);
          await windowManager.focus();
          await windowManager.grabKeyboard();
        });
      }
    }
  }

  static void switchTabs(ProviderReader read, BuildContext context) {
    const length = 3;
    final tabs = read(tabsIndex);
    read(tabsIndex.notifier).state = (tabs + 1) % length;
  }

  static void openSettings(ProviderReader read, BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const Settings(),
      ),
    );
  }
}

enum FlemoziShortcuts {
  openFlemozi(
    "Open Flemozi",
    ShortcutActions.openFlemozi,
    ShortcutType.system,
  ),

  switchTabs(
    "Switch Tabs",
    ShortcutActions.switchTabs,
    ShortcutType.application,
  ),

  openSettings(
    "Open Settings",
    ShortcutActions.openSettings,
    ShortcutType.application,
  );

  final String title;
  final void Function(ProviderReader read, BuildContext context) action;
  final ShortcutType type;
  const FlemoziShortcuts(
    this.title,
    this.action,
    this.type,
  );
}

final Map<FlemoziShortcuts, FlemoziShortcutDef> defaultFlemoziShortcuts = {
  FlemoziShortcuts.openFlemozi: const FlemoziShortcutDef(
    PhysicalKeyboardKey.period,
    alt: true,
    control: true,
  ),
  FlemoziShortcuts.switchTabs: const FlemoziShortcutDef(
    LogicalKeyboardKey.tab,
    control: true,
  ),
  FlemoziShortcuts.openSettings: const FlemoziShortcutDef(
    LogicalKeyboardKey.comma,
    control: true,
  ),
};
