import 'package:flemozi/collections/emojis.dart';
import 'package:flemozi/components/root/twemoji.dart';
import 'package:flemozi/hooks/use_window_listeners.dart';
import 'package:flemozi/providers/native_window_information.dart';
import 'package:flemozi/services/injector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:window_manager/window_manager.dart';

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

class Emoji extends HookConsumerWidget {
  const Emoji({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchFocusNode = useFocusNode();
    final searchTerm = useState("");
    final firstEmojiFocusNode = useFocusNode();

    final filteredEmojis = useMemoized(() {
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
    }, [searchTerm.value]);

    useWindowListeners(
      onWindowFocus: () {
        FocusScope.of(context).requestFocus(searchFocusNode);
      },
      onWindowRestore: () {
        print("Window restored");
        FocusScope.of(context).requestFocus(searchFocusNode);
      },
      // on Window shown/unhide
      onWindowEvent: (event) {
        print("Window shown: $event");
        // FocusScope.of(context).requestFocus(searchFocusNode);
      },
    );

    Future<void> copyEmoji(RatioEmojiType emoji) async {
      // focusNode.requestFocus();
      // Clipboard.setData(ClipboardData(text: emoji.emoji));
      final caretInfo = ref.read(nativeWindowInformationProvider).value;
      await windowManager.hide();
      await Future.delayed(const Duration(milliseconds: 100));
      if (caretInfo != null) {
        await Injector.injectEmojiNative(
          emoji.emoji,
          targetHwndRaw: caretInfo.hwnd,
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: CallbackShortcuts(
              bindings: {
                LogicalKeySet(LogicalKeyboardKey.arrowDown): () {
                  if (filteredEmojis.isNotEmpty) {
                    FocusScope.of(context).requestFocus(firstEmojiFocusNode);
                  }
                },
              },
              child: TextField(
                autocorrect: true,
                focusNode: searchFocusNode,
                decoration: const InputDecoration(
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  searchTerm.value = value;
                },
                onSubmitted: (value) {
                  if (filteredEmojis.isNotEmpty) {
                    FocusScope.of(context).requestFocus(firstEmojiFocusNode);
                  } else {
                    FocusScope.of(context).requestFocus(searchFocusNode);
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: FocusableActionDetector(
              focusNode: firstEmojiFocusNode,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 40,
                  childAspectRatio: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: filteredEmojis.length,
                itemBuilder: (context, index) {
                  return HookBuilder(
                    builder: (context) {
                      final emoji = filteredEmojis.elementAt(index);
                      final tooltipKey = GlobalKey<TooltipState>();

                      return CallbackShortcuts(
                        bindings: {
                          LogicalKeySet(LogicalKeyboardKey.escape): () {
                            FocusScope.of(
                              context,
                            ).requestFocus(searchFocusNode);
                          },
                        },
                        child: Tooltip(
                          message: emoji.description,
                          key: tooltipKey,
                          triggerMode: TooltipTriggerMode.manual,
                          child: MaterialButton(
                            padding: EdgeInsets.zero,
                            focusColor: Theme.of(context).colorScheme.primary,
                            highlightColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            onPressed: () {
                              copyEmoji(emoji);
                            },
                            child: Twemoji(emoji: emoji.emoji),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
