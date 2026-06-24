import 'package:flemozi/models/tenor/response_page.dart';
import 'package:flemozi/providers/tenor.dart';
import 'package:flemozi/services/exception.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TenorSearchData {
  final String query;
  final List<TenorResponsePage> pages;
  final String? nextPos;

  const TenorSearchData({
    this.query = '',
    this.pages = const [],
    this.nextPos,
  });

  bool get hasPageData => pages.isNotEmpty;
  bool get hasNextPage => nextPos != null;
}

class TenorSearchNotifier extends AsyncNotifier<TenorSearchData> {
  int _fetchGeneration = 0;
  bool _isFetching = false;

  @override
  Future<TenorSearchData> build() async => const TenorSearchData();

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const AsyncData(TenorSearchData());
      return;
    }

    _isFetching = true;
    final generation = ++_fetchGeneration;
    state = const AsyncLoading();

    try {
      final service = ref.read(tenorProvider);
      final page = await service.search(query, limit: 10, pos: '');

      if (generation != _fetchGeneration) return;

      final next = page.results.length < 10 ? null : page.next;
      state = AsyncData(TenorSearchData(
        query: query,
        pages: [page],
        nextPos: next,
      ));
    } on TenorException catch (e) {
      if (generation != _fetchGeneration) return;
      state = AsyncError(e, StackTrace.current);
    } finally {
      _isFetching = false;
    }
  }

  Future<void> fetchNext() async {
    final data = state.value;
    if (data == null || data.nextPos == null || _isFetching) return;

    _isFetching = true;
    final generation = ++_fetchGeneration;

    try {
      final service = ref.read(tenorProvider);
      final page =
          await service.search(data.query, limit: 10, pos: data.nextPos!);

      if (generation != _fetchGeneration) return;

      final next = page.results.length < 10 ? null : page.next;
      state = AsyncData(TenorSearchData(
        query: data.query,
        pages: [...data.pages, page],
        nextPos: next,
      ));
    } on TenorException catch (e) {
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

final tenorSearchProvider =
    AsyncNotifierProvider<TenorSearchNotifier, TenorSearchData>(
  TenorSearchNotifier.new,
);
