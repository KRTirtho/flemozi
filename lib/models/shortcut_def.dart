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

  Future<HotKeyDefinition> toHotKeyDefinition() async {
    return HotKeyDefinition(
      key: (await triggerAsPhysicalKey())!,
      alt: alt,
      shift: shift,
      control: control,
      meta: meta,
    );
  }

  Future<SingleActivator> toSingleActivator() async {
    return SingleActivator(
      (await triggerAsLogicalKey())!,
      alt: alt,
      shift: shift,
      control: control,
      meta: meta,
    );
  }

  Future<LogicalKeyboardKey?> triggerAsLogicalKey() async {
    if (trigger is LogicalKeyboardKey) {
      return trigger as LogicalKeyboardKey;
    } else {
      final layout =
          await KeyboardLayoutManager.instance().then((v) => v.currentLayout);

      return layout.getLogicalKeyForPhysicalKey(trigger as PhysicalKeyboardKey);
    }
  }

  Future<PhysicalKeyboardKey?> triggerAsPhysicalKey() async {
    if (trigger is PhysicalKeyboardKey) {
      return trigger as PhysicalKeyboardKey;
    } else {
      final layout =
          await KeyboardLayoutManager.instance().then((v) => v.currentLayout);

      return layout.getPhysicalKeyForLogicalKey(trigger as LogicalKeyboardKey);
    }
  }

  Future<Set<String>> get keyLabels async {
    return {
      if (control) 'Ctrl',
      if (shift) 'Shift',
      if (alt) 'Alt',
      if (meta) 'Meta',
      (await triggerAsLogicalKey())?.keyLabel ?? 'Unknown',
    };
  }
}
