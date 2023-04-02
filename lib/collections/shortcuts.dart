import 'package:flemozi/components/ui/vertical_tabs.dart';
import 'package:flemozi/pages/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:super_hot_key/super_hot_key.dart';

enum ShortcutType {
  application,
  system,
}

typedef ProviderReader = T Function<T>(ProviderListenable<T> provider);

abstract class ShortcutActions {
  static void openFlemozi(ProviderReader read, BuildContext context) {
    print("Open Flemozi");
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

class FlemoziShortcutKey {
  final KeyboardKey trigger;
  final bool alt;
  final bool shift;
  final bool control;
  final bool meta;
  const FlemoziShortcutKey(
    this.trigger, {
    this.alt = false,
    this.shift = false,
    this.control = false,
    this.meta = false,
  });

  HotKeyDefinition toHotKeyDefinition() {
    return HotKeyDefinition(
      key: trigger as PhysicalKeyboardKey,
      alt: alt,
      shift: shift,
      control: control,
      meta: meta,
    );
  }

  SingleActivator toSingleActivator() {
    return SingleActivator(
      trigger as LogicalKeyboardKey,
      alt: alt,
      shift: shift,
      control: control,
      meta: meta,
    );
  }

  Set<String> get keyLabels => {
        if (shift == true) 'Shift',
        if (control == true) 'Ctrl',
        if (alt == true) 'Alt',
        if (meta == true) 'Meta',
        trigger.toString(),
      };
}

final Map<FlemoziShortcuts, FlemoziShortcutKey> defaultFlemoziShortcuts = {
  FlemoziShortcuts.openFlemozi: const FlemoziShortcutKey(
    PhysicalKeyboardKey.period,
    alt: true,
    control: true,
  ),
  FlemoziShortcuts.switchTabs: const FlemoziShortcutKey(
    LogicalKeyboardKey.tab,
    control: true,
  ),
  FlemoziShortcuts.openSettings: const FlemoziShortcutKey(
    LogicalKeyboardKey.comma,
    control: true,
  ),
};
