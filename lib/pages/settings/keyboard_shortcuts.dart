import 'package:flemozi/components/settings/keyboard_shortcuts/shortcut_picker_dialog.dart';
import 'package:flemozi/components/ui/top_bar.dart';
import 'package:flemozi/models/shortcut_def.dart';
import 'package:flemozi/providers/shortcut.dart';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class KeyboardShortcutsPage extends HookConsumerWidget {
  const KeyboardShortcutsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final shortcuts = ref.watch(ShortcutNotifier.provider).entries;
    final shortcutsNotifier = ref.watch(ShortcutNotifier.provider.notifier);

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
        child: ListView.separated(
          itemCount: shortcuts.length,
          padding: const EdgeInsets.all(10),
          separatorBuilder: (context, index) => const SizedBox(height: 5),
          itemBuilder: (context, index) {
            final shortcut = shortcuts.elementAt(index);
            return ListTile(
              title: Text(shortcut.key.title),
              trailing: FutureBuilder<Set<String>>(
                  future: shortcut.value.keyLabels,
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data?.join(' + ') ?? 'Calculating...',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    );
                  }),
              onTap: () async {
                final shortcutDef = await showDialog<FlemoziShortcutDef?>(
                  context: context,
                  builder: (context) => ShortcutPickerDialog(
                    initialSelection: shortcut.value,
                    title: shortcut.key.title,
                  ),
                );
                if (shortcutDef != null && context.mounted) {
                  await shortcutsNotifier.updateShortcut(
                    shortcut.key,
                    shortcutDef,
                    context,
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
