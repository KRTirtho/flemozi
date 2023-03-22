import 'package:flemozi/components/settings/shortcuts/hotkey_picker_dialog.dart';
import 'package:flemozi/components/ui/top_bar.dart';
import 'package:flemozi/providers/shortcuts.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class ShortcutsPage extends HookConsumerWidget {
  const ShortcutsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final shortcuts = ref.watch(ShortcutsNotifier.provider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: const TopBar(),
      body: ListTileTheme(
        dense: true,
        tileColor: Theme.of(context).colorScheme.onSecondary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        horizontalTitleGap: 0,
        child: ListView.builder(
          itemCount: shortcuts.length,
          padding: const EdgeInsets.all(10),
          itemBuilder: (context, index) {
            final shortcut = shortcuts.elementAt(index);
            return ListTile(
              title: Text(shortcut.name),
              trailing: Text(
                '${shortcut.hotKey.modifiers?.map((e) => e.keyLabel).join(' + ')} + ${shortcut.hotKey.keyCode.keyLabel}',
              ),
              onTap: () async {
                final newHotKey = await showDialog<HotKey>(
                  context: context,
                  builder: (context) =>
                      HotKeyPickerDialog(initialHotKey: shortcut.hotKey),
                );
                if (newHotKey != null) {
                  ref.read(ShortcutsNotifier.provider.notifier).updateShortcut(
                        shortcut.copyWith(hotKey: newHotKey),
                      );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
