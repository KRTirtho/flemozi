import 'package:collection/collection.dart';
import 'package:flemozi/components/root/twemoji.dart';
import 'package:flemozi/hooks/use_window_listeners.dart';
import 'package:flemozi/intents/close_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flemozi/collections/emojis.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

typedef RatioEmojiType = ({
  String emoji,
  String description,
  String category,
  List<String> aliases,
  List<String> tags,
  String unicodeVersion,
  String iosVersion,
  bool skinTones,
  int? ratio,
});

class Emoji extends HookWidget {
  const Emoji({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchFocusNode = useFocusNode();
    final searchTerm = useState("");
    final firstEmojiFocusNode = useFocusNode();

    final filteredEmojis = useMemoized(
      () {
        if (searchTerm.value.isEmpty) {
          return emojis
              .map(
                (emoji) => (
                  emoji: emoji.emoji,
                  description: emoji.description,
                  category: emoji.category,
                  aliases: emoji.aliases,
                  tags: emoji.tags,
                  unicodeVersion: emoji.unicodeVersion,
                  iosVersion: emoji.iosVersion,
                  skinTones: emoji.skinTones,
                  ratio: null,
                ),
              )
              .toList();
        } else {
          final List<RatioEmojiType> map = [];
          for (var emoji in emojis) {
            final aliases = emoji.aliases.join(" ");
            final tags = emoji.tags.join(" ");
            final ratio = weightedRatio(
              "${emoji.description} $aliases $tags",
              searchTerm.value,
            );

            if (ratio > 50) {
              map.add((
                emoji: emoji.emoji,
                description: emoji.description,
                category: emoji.category,
                aliases: emoji.aliases,
                tags: emoji.tags,
                unicodeVersion: emoji.unicodeVersion,
                iosVersion: emoji.iosVersion,
                skinTones: emoji.skinTones,
                ratio: ratio,
              ));
            }
          }
          map.sort((a, b) => b.ratio! - a.ratio!);
          return map;
        }
      },
      [searchTerm.value],
    );

    useWindowListeners(
      onWindowFocus: () {
        searchFocusNode.requestFocus();
      },
    );

    final copyEmoji = useCallback((RatioEmojiType emoji, FocusNode focusNode) {
      focusNode.requestFocus();
      Clipboard.setData(
        ClipboardData(text: emoji.emoji),
      );
      SnackBar snackBar = SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.copy,
              color: Theme.of(context).colorScheme.background,
            ),
            const SizedBox(width: 10),
            Text(
              "Copied ${emoji.aliases.firstOrNull} ",
            ),
            Twemoji(
              emoji: emoji.emoji,
              height: 20,
              width: 20,
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      final keys = RawKeyboard.instance.keysPressed;
      const controls = [
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.controlLeft,
        LogicalKeyboardKey.controlRight,
      ];
      if (controls.none((element) => keys.contains(element))) {
        Actions.invoke(context, const CloseWindowIntent());
      }
    }, []);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          CallbackShortcuts(
            bindings: {
              LogicalKeySet(LogicalKeyboardKey.arrowDown): () {
                FocusScope.of(context).requestFocus(firstEmojiFocusNode);
              },
            },
            child: TextField(
              autofocus: true,
              focusNode: searchFocusNode,
              decoration: const InputDecoration(
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                searchTerm.value = value;
              },
              onSubmitted: (value) {
                searchFocusNode.nextFocus();
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 40,
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredEmojis.length,
              itemBuilder: (context, index) {
                return HookBuilder(builder: (context) {
                  final focusnodeUn = useFocusNode();
                  final focusNode =
                      index == 0 ? firstEmojiFocusNode : focusnodeUn;
                  final emoji = filteredEmojis.elementAt(index);
                  final tooltipKey = GlobalKey<TooltipState>();

                  useEffect(() {
                    focusNode.onKeyEvent = (node, event) {
                      if (event.logicalKey == LogicalKeyboardKey.enter) {
                        copyEmoji(emoji, focusNode);
                        return KeyEventResult.handled;
                      }
                      return KeyEventResult.ignored;
                    };

                    return () {
                      focusNode.onKeyEvent = null;
                    };
                  }, [focusNode]);

                  return CallbackShortcuts(
                    bindings: {
                      LogicalKeySet(LogicalKeyboardKey.escape): () {
                        searchFocusNode.requestFocus();
                      },
                    },
                    child: Tooltip(
                      message: emoji.description,
                      key: tooltipKey,
                      triggerMode: TooltipTriggerMode.manual,
                      child: MaterialButton(
                        focusNode: focusNode,
                        padding: EdgeInsets.zero,
                        focusColor: Theme.of(context).colorScheme.primary,
                        highlightColor: Theme.of(context).colorScheme.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        onPressed: () {
                          copyEmoji(emoji, focusNode);
                        },
                        child: Twemoji(
                          emoji: emoji.emoji,
                        ),
                      ),
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
