import 'package:flemozi/models/giphy/collection.dart';
import 'package:flemozi/providers/giphy.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GiphySearchData {
  final String query;
  final List<GiphyCollection> pages;
  final int? nextOffset;

  const GiphySearchData({
    this.query = '',
    this.pages = const [],
    this.nextOffset,
  });

  bool get hasPageData => pages.isNotEmpty;
  bool get hasNextPage => nextOffset != null;
}

class GiphySearchNotifier extends AsyncNotifier<GiphySearchData> {
  int _fetchGeneration = 0;
  bool _isFetching = false;

  @override
  Future<GiphySearchData> build() async => const GiphySearchData();

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const AsyncData(GiphySearchData());
      return;
    }

    _isFetching = true;
    final generation = ++_fetchGeneration;
    state = const AsyncLoading();

    try {
      final service = ref.read(giphyProvider);
      final page = await service.search(query, offset: 0, limit: 10);

      if (generation != _fetchGeneration) return;

      final nextOffset = (page.data?.length ?? 0) < 10 ? null : 10;
      state = AsyncData(
        GiphySearchData(query: query, pages: [page], nextOffset: nextOffset),
      );
    } catch (e) {
      if (generation != _fetchGeneration) return;
      state = AsyncError(e, StackTrace.current);
    } finally {
      _isFetching = false;
    }
  }

  Future<void> fetchNext() async {
    final data = state.value;
    if (data == null || data.nextOffset == null || _isFetching) return;

    _isFetching = true;
    final generation = ++_fetchGeneration;

    try {
      final service = ref.read(giphyProvider);
      final page = await service.search(
        data.query,
        offset: data.nextOffset!,
        limit: 10,
      );

      if (generation != _fetchGeneration) return;

      final nextOffset = (page.data?.length ?? 0) < 10
          ? null
          : data.nextOffset! + 10;
      state = AsyncData(
        GiphySearchData(
          query: data.query,
          pages: [...data.pages, page],
          nextOffset: nextOffset,
        ),
      );
    } catch (e) {
      if (generation != _fetchGeneration) return;
      state = AsyncError(e, StackTrace.current);
    } finally {
      _isFetching = false;
    }
  }

  Future<void> refreshAll() async {
    final query = state.value?.query;
    if (query == null || query.isEmpty) return;
    await search(query);
  }
}

final giphySearchProvider =
    AsyncNotifierProvider<GiphySearchNotifier, GiphySearchData>(
      GiphySearchNotifier.new,
    );
