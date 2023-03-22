import 'dart:convert';

import 'package:flemozi/collections/shortcuts_registry.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Shortcut {
  final String name;
  final HotKey hotKey;
  final ShortcutAction action;

  Shortcut({
    required this.name,
    required this.hotKey,
    required this.action,
  });

  factory Shortcut.fromJson(Map<String, dynamic> json) {
    return Shortcut(
      name: json['name'] as String,
      hotKey: HotKey.fromJson(json['hotKey'] as Map<String, dynamic>),
      action: ShortcutAction.values[json['action'] as int],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'hotKey': hotKey.toJson(),
      'action': action.index,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Shortcut && other.name == name && other.hotKey == hotKey;
  }

  @override
  int get hashCode => name.hashCode ^ hotKey.hashCode;

  Shortcut copyWith({
    String? name,
    HotKey? hotKey,
    ShortcutAction? action,
  }) {
    return Shortcut(
      name: name ?? this.name,
      hotKey: hotKey ?? this.hotKey,
      action: action ?? this.action,
    );
  }
}

class ShortcutsNotifier extends StateNotifier<Set<Shortcut>> {
  late final LazyBox _shortcutsBox;

  ShortcutsNotifier()
      : super({
          Shortcut(
            name: "Open Flemozi",
            hotKey: HotKey(
              KeyCode.period,
              modifiers: [
                KeyModifier.control,
                KeyModifier.alt,
              ],
              identifier: "Show/Hide",
              scope: HotKeyScope.system,
            ),
            action: ShortcutAction.openFlemozi,
          ),
        }) {
    Hive.openLazyBox('shortcuts').then((value) async {
      _shortcutsBox = value;
      state = await _shortcutsBox.get('shortcuts', defaultValue: state).then(
            (json) =>
                (jsonDecode(json) as List?)
                    ?.map((e) => Shortcut.fromJson(e))
                    .toSet() ??
                state,
          );
      ShortcutsRegistry().updateRegistry(this);
    });
  }

  static final provider =
      StateNotifierProvider<ShortcutsNotifier, Set<Shortcut>>(
    (ref) => ShortcutsNotifier(),
  );

  List<Shortcut> get shortcuts => state.toList();

  void updateShortcut(Shortcut shortcut) {
    state = state.map((e) {
      if (e.name == shortcut.name) {
        return shortcut;
      }
      return e;
    }).toSet();
    ShortcutsRegistry().updateRegistry(this);
  }

  @override
  set state(Set<Shortcut> value) {
    super.state = value;
    _shortcutsBox.put(
      'shortcuts',
      jsonEncode(value.map((e) => e.toJson()).toList()),
    );
  }
}
