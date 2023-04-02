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

  factory FlemoziShortcutDef.fromJson(Map<String, dynamic> json) {
    final trigger = json['trigger']['keyId'] != null
        ? LogicalKeyboardKey.findKeyByKeyId(json['trigger']['keyId'])
        : PhysicalKeyboardKey.findKeyByCode(json['trigger']['usbHidUsage']);
    return FlemoziShortcutDef(
      trigger!,
      alt: json['alt'],
      shift: json['shift'],
      control: json['control'],
      meta: json['meta'],
    );
  }

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

  Map<String, dynamic> toJson() {
    return {
      'trigger': {
        if (trigger is LogicalKeyboardKey)
          'keyId': (trigger as LogicalKeyboardKey).keyId
        else
          'usbHidUsage': (trigger as PhysicalKeyboardKey).usbHidUsage
      },
      'alt': alt,
      'shift': shift,
      'control': control,
      'meta': meta,
    };
  }
}
