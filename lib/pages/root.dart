import 'package:flemozi/components/root/emoji.dart';
import 'package:flemozi/components/root/emoticon.dart';
import 'package:flemozi/components/root/gif.dart';
import 'package:flemozi/components/ui/top_bar.dart';
import 'package:flemozi/components/ui/vertical_tabs.dart';
import 'package:flemozi/hooks/use_window_listeners.dart';
import 'package:flemozi/utils/platform.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

class RootPage extends HookConsumerWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final theme = Theme.of(context);
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

    useEffect(() {
      final showWaylandDialog = Hive.box('flemozi.config')
          .get("showWaylandDialog", defaultValue: true);
      if (kIsWayland && showWaylandDialog) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("You're using Wayland"),
                content: RichText(
                  text: TextSpan(children: [
                    const TextSpan(
                      text:
                          "Wayland currently doesn't allow applications to set custom global shortcut\n"
                          "So user has to manually set custom keyboard shortcut to launch Flemozi\n\n",
                    ),
                    const TextSpan(text: "Learn more about it here:\n"),
                    TextSpan(
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                      text:
                          "https://github.com/KRTirtho/flemozi/wiki/Setup-on-Wayland",
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => launchUrlString(
                              "https://github.com/KRTirtho/flemozi/wiki/Setup-on-Wayland",
                            ),
                    ),
                  ]),
                ),
                actions: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await Hive.box("flemozi.config")
                          .put("showWaylandDialog", false);
                    },
                    child: const Text("Don't show this again"),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Ok"),
                  ),
                ],
              );
            },
          );
        });
      }
      return null;
    }, []);

    return Scaffold(
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
    );
  }
}
