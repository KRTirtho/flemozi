import 'package:flemozi/collections/shortcuts.dart';
import 'package:flemozi/models/shortcut_def.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:super_hot_key/super_hot_key.dart';

class ShortcutNotifier
    extends StateNotifier<Map<FlemoziShortcuts, FlemoziShortcutDef>> {
  final Ref ref;
  Box box;
  ShortcutNotifier(super.state, this.ref) : box = Hive.box('flemozi.config') {
    final shortcuts = box.get('shortcuts') as Map?;
    state = shortcuts?.map(
          (key, value) => MapEntry(
            FlemoziShortcuts.values[key],
            FlemoziShortcutDef.fromJson(
              Map.castFrom<dynamic, dynamic, String, dynamic>(value),
            ),
          ),
        ) ??
        state;
  }

  final Map<FlemoziShortcuts, HotKey> _hotKeys = {};

  void initialize(BuildContext context) async {
    final globalShortcuts = FlemoziShortcuts.values
        .where((shortcut) => shortcut.type == ShortcutType.system)
        .toList();

    for (var shortcut in globalShortcuts) {
      final hotKey = await HotKey.create(
        definition: await state[shortcut]!.toHotKeyDefinition(),
        callback: () {
          return shortcut.action(ref.read, context);
        },
      );

      if (hotKey != null) _hotKeys[shortcut] = hotKey;
    }
  }

  static final provider = StateNotifierProvider<ShortcutNotifier,
      Map<FlemoziShortcuts, FlemoziShortcutDef>>(
    (ref) => ShortcutNotifier(
      defaultFlemoziShortcuts,
      ref,
    ),
  );

  Future<void> updateShortcut(
    FlemoziShortcuts shortcutAction,
    FlemoziShortcutDef keyDef, [
    BuildContext? context,
  ]) async {
    if (shortcutAction.type == ShortcutType.system) {
      assert(
        context != null,
        "Context is required for global shortcuts",
      );
      await _hotKeys[shortcutAction]?.dispose();
      final hotKey = await HotKey.create(
        definition: await keyDef.toHotKeyDefinition(),
        callback: () {
          return shortcutAction.action(ref.read, context!);
        },
      );
      if (hotKey != null) _hotKeys[shortcutAction] = hotKey;
    }
    state = {...state, shortcutAction: keyDef};
  }

  @override
  set state(Map<FlemoziShortcuts, FlemoziShortcutDef> value) {
    super.state = value;
    box.put(
      'shortcuts',
      value.map((key, value) => MapEntry(key.index, value.toJson())),
    );
  }
}
