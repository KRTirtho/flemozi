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
    intent.ref.read(tabsIndex.notifier).state =
        intent.ref.read(tabsIndex) == 0 ? 1 : 0;
  }
}
