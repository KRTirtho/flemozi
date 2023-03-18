import 'package:fl_query/fl_query.dart';
import 'package:fl_query_hooks/fl_query_hooks.dart';
import 'package:flemozi/models/tenor/response_page.dart';
import 'package:flemozi/providers/giphy.dart';
import 'package:flemozi/providers/tenor.dart';
import 'package:flemozi/services/exception.dart';
import 'package:giphy_api_client/giphy_api_client.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

abstract class Queries {
  static InfiniteQuery<TenorResponsePage, TenorException, String> useTenorGet(
    WidgetRef ref,
  ) {
    final tenor = ref.watch(tenorProvider);

    return useInfiniteQuery<TenorResponsePage, TenorException, String>(
      "tenor_get",
      (page) {
        return tenor.featured(
          limit: 10,
          pos: page,
        );
      },
      nextPage: (lastPage, lastPageData) {
        if (lastPageData.results.length < 10) return null;
        return lastPageData.next;
      },
      initialPage: "",
    );
  }

  static InfiniteQuery<GiphyCollection, dynamic, int> useGiphyGet(
      WidgetRef ref) {
    final giphy = ref.watch(giphyProvider);
    return useInfiniteQuery<GiphyCollection, dynamic, int>(
      "giphy_get",
      (page) {
        return giphy.trending(
          offset: page,
          limit: 10,
        );
      },
      nextPage: (lastPage, lastPageData) {
        if ((lastPageData.data?.length ?? 0) < 10) return null;
        return lastPage + 10;
      },
      initialPage: 0,
    );
  }

  static InfiniteQuery<TenorResponsePage, TenorException, String>
      useTenorSearch(
    WidgetRef ref,
    String query,
  ) {
    final tenor = ref.watch(tenorProvider);
    return useInfiniteQuery<TenorResponsePage, TenorException, String>(
      "tenor_search",
      (page) {
        return tenor.search(
          query,
          limit: 10,
          pos: page,
        );
      },
      nextPage: (lastPage, lastPageData) {
        if (lastPageData.results.length < 10) return null;
        return lastPageData.next;
      },
      initialPage: "",
      enabled: false,
    );
  }

  static InfiniteQuery<GiphyCollection, dynamic, int> useGiphySearch(
      WidgetRef ref, String query) {
    final giphy = ref.watch(giphyProvider);
    return useInfiniteQuery<GiphyCollection, dynamic, int>(
      "giphy_search",
      (page) {
        return giphy.search(
          query,
          offset: page,
          limit: 10,
        );
      },
      nextPage: (lastPage, lastPageData) {
        if ((lastPageData.data?.length ?? 0) < 10) return null;
        return lastPage + 10;
      },
      initialPage: 0,
    );
  }
}
