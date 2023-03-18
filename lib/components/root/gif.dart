import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flemozi/caching/queries.dart';
import 'package:flemozi/components/ui/waypoint.dart';
import 'package:flemozi/hooks/use_debounced_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart';
import 'package:super_clipboard/super_clipboard.dart';

class Gif extends HookConsumerWidget {
  const Gif({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final controller = useScrollController();
    final focusNode = useFocusNode();

    final tenorTrending = Queries.useTenorGet(ref);
    final giphyTrending = Queries.useGiphyGet(ref);

    final text = useDebouncedState('');

    final tenorSearch = Queries.useTenorSearch(ref, text.value);
    final giphySearch = Queries.useGiphySearch(ref, text.value);

    final displayGifs = useMemoized(
        () => [
              ...tenorTrending.pages
                  .expand((page) =>
                      page.results.map((r) => r.tinygif?.url.toString()))
                  .whereNotNull(),
              ...giphyTrending.pages
                  .expand((page) => (page.data ?? []).map(
                        (e) => e?.images?.fixedWidthDownsampled?.url
                            ?.replaceAll(
                                RegExp(r"media\d+\.giphy\.com"), "i.giphy.com")
                            .split("?")[0],
                      ))
                  .whereNotNull(),
            ],
        [
          tenorTrending.pages,
          giphyTrending.pages,
        ]);

    final searchGifs = useMemoized(
        () => [
              ...tenorSearch.pages
                  .expand((page) =>
                      page.results.map((r) => r.tinygif?.url.toString()))
                  .whereNotNull(),
              ...giphySearch.pages
                  .expand((page) => (page.data ?? []).map(
                        (e) => e?.images?.fixedWidthDownsampled?.url
                            ?.replaceAll(
                                RegExp(r"media\d+\.giphy\.com"), "i.giphy.com")
                            .split("?")[0],
                      ))
                  .whereNotNull(),
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

    return Column(
      children: [
        CallbackShortcuts(
          bindings: {
            LogicalKeySet(LogicalKeyboardKey.arrowDown): () {
              FocusScope.of(context).requestFocus(focusNode);
            },
          },
          child: TextField(
            onChanged: (value) => text.value = value,
            decoration: const InputDecoration(
              hintText: 'Search GIFs and Stickers',
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            controller: controller,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: gifs.length,
            itemBuilder: (context, index) {
              final gif = gifs[index];

              final image = CachedNetworkImage(
                imageUrl: gif,
                fit: BoxFit.contain,
              );

              final child = InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () async {
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
                  }
                  // Actions.invoke(context, const CloseWindowIntent());
                },
                focusNode: index == 0 ? focusNode : null,
                canRequestFocus: true,
                focusColor: Theme.of(context).colorScheme.secondary,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: image,
                ),
              );
              if (index == gifs.length - 1) {
                return Waypoint.item(
                  controller: controller,
                  onTouchEdge: () async {
                    if (giphyTrending.hasNextPage) {
                      await giphyTrending.fetchNext();
                    }
                    if (tenorTrending.hasNextPage) {
                      await tenorTrending.fetchNext();
                    }
                  },
                  child: child,
                );
              }
              return child;
            },
          ),
        ),
      ],
    );
  }
}
