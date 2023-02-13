import 'package:flemozi/components/root/twemoji.dart';
import 'package:flemozi/intents/close_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flemozi/collections/emojis.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:window_manager/window_manager.dart';

class Emoji extends StatefulHookWidget {
  const Emoji({Key? key}) : super(key: key);

  @override
  State<Emoji> createState() => _EmojiState();
}

class _EmojiState extends State<Emoji> with WindowListener {
  late FocusNode searchFocusNode;
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void onWindowFocus() {
    searchFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final searchTerm = useState("");

    final filteredEmojis = useMemoized(
      () {
        if (searchTerm.value.isEmpty) {
          return emojis;
        } else {
          final List<Map<String, Object>> map = [];
          for (var emoji in emojis) {
            final description = emoji["description"] as String;
            final aliases = (emoji["aliases"] as List).join(" ");
            final tags = (emoji["tags"] as List? ?? []).join(" ");
            final ratio = weightedRatio(
              "$description $aliases $tags",
              searchTerm.value,
            );
            emoji["ratio"] = ratio;
            if (ratio > 50) {
              map.add(emoji);
            }
          }
          map.sort((a, b) => (b["ratio"] as int) - (a["ratio"] as int));
          return map;
        }
      },
      [searchTerm.value],
    );

    return Column(
      children: [
        CallbackShortcuts(
          bindings: {
            LogicalKeySet(LogicalKeyboardKey.arrowDown): () {
              searchFocusNode.nextFocus();
            },
          },
          child: TextField(
            autofocus: true,
            focusNode: searchFocusNode,
            decoration: const InputDecoration(
              hintText: "Search",
              isDense: true,
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
                final focusNode = useFocusNode();
                final emoji = filteredEmojis.elementAt(index);
                final tooltipKey = GlobalKey<TooltipState>();

                useEffect(() {
                  listener() {
                    if (focusNode.hasFocus) {
                      tooltipKey.currentState?.ensureTooltipVisible();
                    } else {
                      tooltipKey.currentState?.deactivate();
                    }
                  }

                  focusNode.addListener(listener);
                  return () {
                    focusNode.removeListener(listener);
                  };
                }, [focusNode]);

                return CallbackShortcuts(
                  bindings: {
                    LogicalKeySet(LogicalKeyboardKey.escape): () {
                      searchFocusNode.requestFocus();
                    },
                  },
                  child: Tooltip(
                    message: emoji["description"] as String,
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
                        focusNode.requestFocus();
                        Clipboard.setData(
                          ClipboardData(text: emoji["emoji"] as String),
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
                                "Copied ${(emoji["aliases"] as List).first as String} ",
                              ),
                              Twemoji(
                                emoji: emoji["emoji"] as String,
                                height: 20,
                                width: 20,
                              ),
                            ],
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        Actions.invoke(context, const CloseWindowIntent());
                      },
                      child: Twemoji(
                        emoji: emoji["emoji"] as String,
                      ),
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }
}
