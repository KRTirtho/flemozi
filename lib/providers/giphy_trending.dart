import 'package:flemozi/models/giphy/collection.dart';
import 'package:flemozi/providers/giphy.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GiphyTrendingData {
  final List<GiphyCollection> pages;
  final int? nextOffset;

  const GiphyTrendingData({
    this.pages = const [],
    this.nextOffset,
  });

  bool get hasPageData => pages.isNotEmpty;
  bool get hasNextPage => nextOffset != null;
}

class GiphyTrendingNotifier extends AsyncNotifier<GiphyTrendingData> {
  int _fetchGeneration = 0;
  bool _isFetching = false;

  @override
  Future<GiphyTrendingData> build() async {
    _isFetching = true;
    final service = ref.read(giphyProvider);
    final page = await service.trending(offset: 0, limit: 10);
    final nextOffset = (page.data?.length ?? 0) < 10 ? null : 10;
    _isFetching = false;
    return GiphyTrendingData(pages: [page], nextOffset: nextOffset);
  }

  Future<void> fetchNext() async {
    final data = state.value;
    if (data == null || data.nextOffset == null || _isFetching) return;

    _isFetching = true;
    final generation = ++_fetchGeneration;

    try {
      final service = ref.read(giphyProvider);
      final page =
          await service.trending(offset: data.nextOffset!, limit: 10);

      if (generation != _fetchGeneration) return;

      final nextOffset =
          (page.data?.length ?? 0) < 10 ? null : data.nextOffset! + 10;
      state = AsyncData(GiphyTrendingData(
        pages: [...data.pages, page],
        nextOffset: nextOffset,
      ));
    } catch (e) {
      if (generation != _fetchGeneration) return;
      state = AsyncError(e, StackTrace.current);
    } finally {
      _isFetching = false;
    }
  }

  Future<void> refreshAll() async {
    if (_isFetching) return;

    _isFetching = true;
    final generation = ++_fetchGeneration;
    state = const AsyncLoading();

    try {
      final service = ref.read(giphyProvider);
      final page = await service.trending(offset: 0, limit: 10);

      if (generation != _fetchGeneration) return;

      final nextOffset = (page.data?.length ?? 0) < 10 ? null : 10;
      state = AsyncData(GiphyTrendingData(
        pages: [page],
        nextOffset: nextOffset,
      ));
    } catch (e) {
      if (generation != _fetchGeneration) return;
      state = AsyncError(e, StackTrace.current);
    } finally {
      _isFetching = false;
    }
  }
}

final giphyTrendingProvider =
    AsyncNotifierProvider<GiphyTrendingNotifier, GiphyTrendingData>(
  GiphyTrendingNotifier.new,
);
