import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flemozi/caching/queries.dart';
import 'package:flemozi/components/ui/waypoint.dart';
import 'package:flemozi/hooks/use_debounced_state.dart';
import 'package:flemozi/intents/close_window.dart';
import 'package:flemozi/models/tenor/response_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:giphy_api_client/giphy_api_client.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart';
import 'package:shimmer/shimmer.dart';
import 'package:super_clipboard/super_clipboard.dart';

const placeholder = SizedBox(
  height: 200,
  width: 200,
  child: ColoredBox(
    color: Color(0xFF2F3136),
    child: Icon(
      Icons.image_rounded,
      size: 50,
      color: Color(0xFF8E9297),
    ),
  ),
);

class Gif extends HookConsumerWidget {
  const Gif({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final controller = useScrollController();
    final focusNode = useFocusNode();
    final searchFocusNode = useFocusNode();

    final tenorTrending = Queries.useTenorGet(ref);
    final giphyTrending = Queries.useGiphyGet(ref);

    final text = useDebouncedState('');

    final tenorSearch = Queries.useTenorSearch(ref, text.value);
    final giphySearch = Queries.useGiphySearch(ref, text.value);

    final tenorPagesToStrings = useCallback(
      (List<TenorResponsePage> pages) => pages
          .expand((page) => page.results.map((r) => r.tinygif?.url.toString()))
          .whereNotNull(),
      [],
    );

    final giphyPagesToStrings = useCallback(
      (List<GiphyCollection> pages) => pages
          .expand((page) => (page.data ?? []).map(
                (e) => e?.images?.fixedWidthDownsampled?.url
                    ?.replaceAll(RegExp(r"media\d+\.giphy\.com"), "i.giphy.com")
                    .split("?")[0],
              ))
          .whereNotNull(),
      [],
    );

    final displayGifs = useMemoized(
        () => [
              ...tenorPagesToStrings(tenorTrending.pages),
              ...giphyPagesToStrings(giphyTrending.pages),
            ],
        [
          tenorTrending.pages,
          giphyTrending.pages,
        ]);

    final searchGifs = useMemoized(
        () => [
              ...tenorPagesToStrings(tenorSearch.pages),
              ...giphyPagesToStrings(giphySearch.pages),
            ],
        [
          tenorSearch.pages,
          giphySearch.pages,
        ]);

    final gifs =
        text.value.isEmpty || searchGifs.isEmpty ? displayGifs : searchGifs;

    useEffect(() {
      if (text.value.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          controller.jumpTo(0);
          await Future.wait(
            [giphySearch.refreshAll(), tenorSearch.refreshAll()],
          );
        });
      }
      return null;
    }, [text.value]);

    final tenorImg = useMemoized(
        () => Image.asset(
              "assets/tenor.png",
              height: 20,
              width: 20,
            ),
        []);

    final giphyImg = useMemoized(
        () => Image.asset(
              "assets/giphy.png",
              height: 40,
              width: 40,
            ),
        []);

    final isEverythingLoading = text.value.isEmpty || searchGifs.isEmpty
        ? (!tenorTrending.hasPageData && !giphyTrending.hasPageData)
        : (!tenorSearch.hasPageData && !giphySearch.hasPageData);

    return Column(
      children: [
        CallbackShortcuts(
          bindings: {
            LogicalKeySet(LogicalKeyboardKey.arrowDown): () {
              FocusScope.of(context).requestFocus(focusNode);
            },
          },
          child: TextField(
            autofocus: true,
            focusNode: searchFocusNode,
            onChanged: (value) => text.value = value,
            decoration: const InputDecoration(
              hintText: 'Search GIFs and Stickers',
            ),
          ),
        ),
        if (isEverythingLoading)
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[850]!,
                    highlightColor: Colors.grey[800]!,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        else
          Expanded(
            child: GridView.builder(
              controller: controller,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: gifs.length + 1,
              itemBuilder: (context, index) {
                if (index == gifs.length) {
                  return Waypoint.item(
                    controller: controller,
                    onTouchEdge: () async {
                      if (text.value.isEmpty || searchGifs.isEmpty) {
                        if (giphyTrending.hasNextPage) {
                          await giphyTrending.fetchNext();
                        }
                        if (tenorTrending.hasNextPage) {
                          await tenorTrending.fetchNext();
                        }
                      } else {
                        if (giphySearch.hasNextPage) {
                          await giphySearch.fetchNext();
                        }
                        if (tenorSearch.hasNextPage) {
                          await tenorSearch.fetchNext();
                        }
                      }
                    },
                    child: Stack(
                      children: const [
                        Center(
                          child: SizedBox(
                            height: 50,
                            width: 50,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final gif = gifs[index];

                final image = CachedNetworkImage(
                  imageUrl: gif,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => placeholder,
                );
                Future<void> copyGif() async {
                  final imageFile = await DefaultCacheManager()
                      .getFileFromCache(gif)
                      .then((s) async => await s?.file.readAsBytes());
                  if (imageFile == null) {
                    return;
                  }
                  await ClipboardWriter.instance.write([
                    DataWriterItem(suggestedName: basename(gif))
                      ..add(Formats.png(imageFile))
                      ..add(Formats.bmp(imageFile))
                      ..add(Formats.webp(imageFile))
                      ..add(Formats.gif(imageFile))
                      ..add(Formats.tiff(imageFile))
                      ..add(
                        Formats.htmlText(
                          '<meta http-equiv="content-type" content="text/html; charset=utf-8"><img src="$gif">',
                        ),
                      )
                  ]);
                  SnackBar snackBar = SnackBar(
                    content: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 35, child: image),
                        const SizedBox(width: 10),
                        const Text("Copied to clipboard!"),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  );
                  if (context.mounted) {
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
                  }
                }

                return CallbackShortcuts(
                  bindings: {
                    LogicalKeySet(LogicalKeyboardKey.escape): () {
                      FocusScope.of(context).requestFocus(searchFocusNode);
                    },
                  },
                  child: HookBuilder(builder: (context) {
                    useEffect(() {
                      focusNode.onKeyEvent = (node, event) {
                        if (event.logicalKey == LogicalKeyboardKey.enter) {
                          copyGif();
                          return KeyEventResult.handled;
                        }
                        return KeyEventResult.ignored;
                      };

                      return () {
                        focusNode.onKeyEvent = null;
                      };
                    }, [focusNode]);

                    return InkWell(
                      focusNode: index == 0 ? focusNode : useFocusNode(),
                      borderRadius: BorderRadius.circular(10),
                      onTap: copyGif,
                      canRequestFocus: true,
                      focusColor: Theme.of(context).colorScheme.secondary,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: image,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        SizedBox(
          height: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Powered by",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 5),
              giphyImg,
              const SizedBox(width: 5),
              Text(
                "and",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 5),
              tenorImg,
            ],
          ),
        )
      ],
    );
  }
}
