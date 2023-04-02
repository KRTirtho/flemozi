import 'package:flemozi/collections/shortcuts.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:super_hot_key/super_hot_key.dart';

class ShortcutNotifier
    extends StateNotifier<Map<FlemoziShortcuts, FlemoziShortcutKey>> {
  final Ref ref;
  ShortcutNotifier(super.state, this.ref);

  void initialize(BuildContext context) async {
    final globalShortcuts = FlemoziShortcuts.values
        .where((shortcut) => shortcut.type == ShortcutType.system)
        .toList();

    for (var shortcut in globalShortcuts) {
      await HotKey.create(
        definition: state[shortcut]!.toHotKeyDefinition(),
        callback: () {
          return shortcut.action(ref.read, context);
        },
      );
    }
  }

  static final provider = StateNotifierProvider<ShortcutNotifier,
      Map<FlemoziShortcuts, FlemoziShortcutKey>>(
    (ref) => ShortcutNotifier(
      defaultFlemoziShortcuts,
      ref,
    ),
  );
}
