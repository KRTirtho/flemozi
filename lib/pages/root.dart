import 'package:flemozi/components/root/emoji.dart';
import 'package:flemozi/components/root/emoticon.dart';
import 'package:flemozi/components/root/gif.dart';
import 'package:flemozi/components/ui/top_bar.dart';
import 'package:flemozi/components/ui/vertical_tabs.dart';
import 'package:flemozi/hooks/use_window_listeners.dart';
import 'package:flemozi/intents/close_window.dart';
import 'package:flemozi/pages/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class RootPage extends HookWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final windowIsShowing = useState(true);

    useWindowListeners(onWindowEvent: (String eventName) {
      switch (eventName) {
        case "hide":
          windowIsShowing.value = false;
          break;
        case "show":
          windowIsShowing.value = true;
          break;
        default:
          break;
      }
    });

    return CallbackShortcuts(
      bindings: {
        LogicalKeySet(
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.comma,
        ): () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const Settings(),
              ),
            ),
        LogicalKeySet(LogicalKeyboardKey.escape): () =>
            CloseWindowAction().invoke(const CloseWindowIntent()),
      },
      child: Scaffold(
        appBar: const TopBar(),
        body: windowIsShowing.value
            ? VerticalTabs(
                tabs: const [
                  Tooltip(
                    message: 'Emoji',
                    child: Icon(Icons.emoji_emotions),
                  ),
                  Tooltip(
                    message: 'GIFs',
                    child: Icon(Icons.gif_rounded),
                  ),
                  Tooltip(
                    message: 'Emoticons',
                    child: Text(':)'),
                  ),
                ],
                children: const [
                  Emoji(),
                  Gif(),
                  Emoticon(),
                ],
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
