import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class HotKeyPickerDialog extends HookWidget {
  final HotKey? initialHotKey;
  const HotKeyPickerDialog({
    super.key,
    this.initialHotKey,
  });

  @override
  Widget build(BuildContext context) {
    final hotKeyRef = useRef<HotKey?>(initialHotKey);
    final error = useState<String?>(null);

    return AlertDialog(
      title: const Text('Pick a hotkey'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HotKeyRecorder(
            onHotKeyRecorded: (hotKey) {
              if (hotKey.modifiers?.isNotEmpty != true ||
                  (hotKey.modifiers?.length == 1 &&
                      hotKey.modifiers?.first == KeyModifier.shift)) {
                error.value =
                    'Please select a modifier key (CTRL/Command, ALT, Windows/Super/Meta etc.)';
                return;
              }
              error.value = null;
              hotKeyRef.value = hotKey;
            },
            initalHotKey: hotKeyRef.value,
          ),
          if (error.value != null)
            Text(
              error.value!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(hotKeyRef.value);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
