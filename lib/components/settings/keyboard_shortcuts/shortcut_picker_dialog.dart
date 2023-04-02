import 'package:flemozi/collections/logical_key_list.dart';
import 'package:flemozi/models/shortcut_def.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const modifiers = [
  "Control",
  "Alt",
  "Shift",
  "Meta",
];

class ShortcutPickerDialog extends HookConsumerWidget {
  final FlemoziShortcutDef? initialSelection;
  final String title;
  const ShortcutPickerDialog({
    required this.title,
    this.initialSelection,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final logicalTrigger = useFuture(
      useMemoized(
        () => initialSelection?.triggerAsLogicalKey(),
        [initialSelection],
      ),
    );

    final trigger = useState<LogicalKeyboardKey?>(logicalTrigger.data);
    final modifiers = useState<Map<String, bool>>({
      "Control": initialSelection?.control ?? false,
      "Alt": initialSelection?.alt ?? false,
      "Shift": initialSelection?.shift ?? false,
      "Meta": initialSelection?.meta ?? false,
    });

    useEffect(() {
      if (logicalTrigger.data != null) {
        trigger.value = logicalTrigger.data;
      }
      return null;
    }, [logicalTrigger.data]);

    final isValid =
        trigger.value != null && modifiers.value.values.any((e) => e);

    return AlertDialog(
      title: Text('Pick a shortcut: $title'),
      titleTextStyle: Theme.of(context).textTheme.titleMedium,
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          DropdownMenu<LogicalKeyboardKey>(
            initialSelection: logicalTrigger.data,
            onSelected: (value) {
              trigger.value = value;
              if (logicalKeyListWithShift.contains(value)) {
                modifiers.value = {
                  ...modifiers.value,
                  "Shift": true,
                };
              }
            },
            label: const Text('Select a Trigger'),
            menuHeight: 150,
            enableFilter: true,
            dropdownMenuEntries: logicalKeys.map((key) {
              return DropdownMenuEntry(
                value: key,
                label: key.keyLabel,
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: modifiers.value.entries.map((entry) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(entry.key),
                  Checkbox(
                    value: entry.value,
                    onChanged: (value) {
                      modifiers.value = {
                        ...modifiers.value,
                        entry.key: value ?? false,
                      };
                    },
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: !isValid
              ? null
              : () => Navigator.of(context).pop(
                    FlemoziShortcutDef(
                      trigger.value!,
                      alt: modifiers.value["Alt"]!,
                      control: modifiers.value["Control"]!,
                      shift: modifiers.value["Shift"]!,
                      meta: modifiers.value["Meta"]!,
                    ),
                  ),
          child: const Text('Ok'),
        ),
      ],
    );
  }
}
