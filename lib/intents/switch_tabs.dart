import 'package:flemozi/components/ui/vertical_tabs.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SwitchTabsIntent extends Intent {
  final WidgetRef ref;
  const SwitchTabsIntent(this.ref);
}

class SwitchTabsAction extends Action<SwitchTabsIntent> {
  @override
  void invoke(SwitchTabsIntent intent) async {
    // cycle tabs
    const length = 3;
    final tabs = intent.ref.read(tabsIndex);
    intent.ref.read(tabsIndex.notifier).state = (tabs + 1) % length;
  }
}
