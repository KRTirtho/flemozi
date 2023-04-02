import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_hot_key/super_hot_key.dart';
import 'package:super_keyboard_layout/super_keyboard_layout.dart';

enum ShortcutType {
  application,
  system,
}

class FlemoziShortcutDef {
  final KeyboardKey trigger;
  final bool alt;
  final bool shift;
  final bool control;
  final bool meta;
  const FlemoziShortcutDef(
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

  Future<String?> _getPhysicalKeyLabel(PhysicalKeyboardKey trigger) async {
    final layout =
        await KeyboardLayoutManager.instance().then((v) => v.currentLayout);

    final key = layout.getLogicalKeyForPhysicalKey(trigger)?.keyLabel;

    return key;
  }

  Future<Set<String>> get keyLabels async {
    return {
      if (control) 'Ctrl',
      if (shift) 'Shift',
      if (alt) 'Alt',
      if (meta) 'Meta',
      if (trigger is PhysicalKeyboardKey)
        await _getPhysicalKeyLabel(trigger as PhysicalKeyboardKey) ?? "?"
      else
        (trigger as LogicalKeyboardKey).keyLabel,
    };
  }
}
