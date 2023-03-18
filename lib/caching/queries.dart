import 'package:fl_query_hooks/fl_query_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract class Queries {
  static void useTenorGet(WidgetRef ref) {
    useInfiniteQuery(
      "tenor_get",
      (page) {},
      nextPage: (lastPage, lastPageData) {
        return null;
      },
      initialPage: 0,
    );
  }

  static void useGiphyGet() {
    useInfiniteQuery(
      "giphy_get",
      (page) {},
      nextPage: (lastPage, lastPageData) {
        return null;
      },
      initialPage: 0,
    );
  }

  static void useTenorSearch() {
    useInfiniteQuery(
      "tenor_search",
      (page) {},
      nextPage: (lastPage, lastPageData) {
        return null;
      },
      initialPage: 0,
    );
  }

  static void useGiphySearch() {
    useInfiniteQuery(
      "giphy_search",
      (page) {},
      nextPage: (lastPage, lastPageData) {
        return null;
      },
      initialPage: 0,
    );
  }
}
