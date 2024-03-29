import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:flemozi/collections/emoticons.dart';
import 'package:flemozi/hooks/use_window_listeners.dart';
import 'package:flemozi/intents/close_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

class Emoticon extends HookWidget {
  const Emoticon({super.key});

  @override
  Widget build(BuildContext context) {
    final searchFocusNode = useFocusNode();
    final searchTerm = useState("");
    final firstEmoticonFocusNode = useFocusNode();

    FocusScope.of(context).requestFocus(searchFocusNode);

    final List<Map<String, String>> filteredEmoticons = useMemoized(
      () {
        if (searchTerm.value.isEmpty) {
          return emoticons.entries
              .map(
                (e) => e.value.map(
                  (f) => {
                    "emoticon": f,
                    "description": e.key,
                  },
                ),
              )
              .expand((e) => e)
              .toList();
        } else {
          final List<Map<String, dynamic>> map = [];
          for (var group in emoticons.entries) {
            final description = group.key;
            final ratio = weightedRatio(
              "$description ${group.value.join(" ")}",
              searchTerm.value,
            );

            if (ratio > 50) {
              map.addAll(group.value.map(
                (e) => {
                  "emoticon": e,
                  "description": description,
                  "ratio": ratio,
                },
              ));
            }
          }
          map.sort((a, b) => (b["ratio"] as int) - (a["ratio"] as int));
          return map.map((e) {
            e.remove("ratio");
            return e.cast<String, String>();
          }).toList();
        }
      },
      [searchTerm.value],
    );

    useWindowListeners(
      onWindowFocus: () {
        searchFocusNode.requestFocus();
      },
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: CallbackShortcuts(
              bindings: {
                LogicalKeySet(LogicalKeyboardKey.arrowDown): () {
                  if (filteredEmoticons.isNotEmpty) {
                    FocusScope.of(context).requestFocus(firstEmoticonFocusNode);
                  }
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
                  if (filteredEmoticons.isNotEmpty) {
                    firstEmoticonFocusNode.requestFocus();
                  } else {
                    FocusScope.of(context).requestFocus(searchFocusNode);
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 60,
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredEmoticons.length,
              itemBuilder: (context, index) {
                return HookBuilder(builder: (context) {
                  final focusnodeUn = useFocusNode();
                  final focusNode =
                      index == 0 ? firstEmoticonFocusNode : focusnodeUn;
                  final emoticon = filteredEmoticons.elementAt(index);
                  final tooltipKey = GlobalKey<TooltipState>();

                  final copyEmoticon = useCallback(
                    () {
                      focusNode.requestFocus();
                      Clipboard.setData(
                        ClipboardData(text: emoticon["emoticon"]!),
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
                              "${emoticon["emoticon"]} was copied to clipboard",
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
                    },
                    [focusNode, emoticon["emoticon"]],
                  );

                  useEffect(() {
                    focusNode.onKeyEvent = (node, event) {
                      if (event.logicalKey == LogicalKeyboardKey.enter) {
                        copyEmoticon();
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
                        FocusScope.of(context).requestFocus(searchFocusNode);
                      },
                    },
                    child: Tooltip(
                      key: tooltipKey,
                      message: emoticon["description"]!,
                      child: MaterialButton(
                        focusNode: focusNode,
                        padding: EdgeInsets.zero,
                        focusColor: Theme.of(context).colorScheme.primary,
                        highlightColor: Theme.of(context).colorScheme.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        onPressed: copyEmoticon,
                        child: AutoSizeText(
                          emoticon["emoticon"]!,
                          maxLines: 1,
                          minFontSize: 5,
                          maxFontSize: 20,
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
