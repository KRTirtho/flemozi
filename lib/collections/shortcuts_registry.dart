import 'package:flemozi/providers/shortcuts.dart';
import 'package:flemozi/utils/platform.dart';
import 'package:flutter/foundation.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';

enum ShortcutAction {
  openFlemozi,
}

class ShortcutsRegistry {
  static final ShortcutsRegistry _instance = ShortcutsRegistry._internal();

  factory ShortcutsRegistry() {
    return _instance;
  }

  ShortcutsRegistry._internal();

  final Map<ShortcutAction, VoidCallback> _shortcuts = {
    ShortcutAction.openFlemozi: () async {
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
    },
  };

  void updateRegistry(ShortcutsNotifier notifier) async {
    hotKeyManager.unregisterAll();
    final shortcuts = notifier.shortcuts;
    for (final shortcut in shortcuts) {
      hotKeyManager.register(
        shortcut.hotKey,
        keyDownHandler: (hotKey) {
          _shortcuts[shortcut.action]?.call();
        },
      );
    }
  }
}
