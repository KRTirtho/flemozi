import 'package:flemozi/models/tenor/response_page.dart';
import 'package:flemozi/providers/tenor.dart';
import 'package:flemozi/services/exception.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TenorFeaturedData {
  final List<TenorResponsePage> pages;
  final String? nextPos;

  const TenorFeaturedData({this.pages = const [], this.nextPos});

  bool get hasPageData => pages.isNotEmpty;
  bool get hasNextPage => nextPos != null;
}

class TenorFeaturedNotifier extends AsyncNotifier<TenorFeaturedData> {
  int _fetchGeneration = 0;
  bool _isFetching = false;

  @override
  Future<TenorFeaturedData> build() async {
    _isFetching = true;
    final service = ref.read(tenorProvider);
    final page = await service.featured(limit: 10, pos: '');
    final next = page.results.length < 10 ? null : page.next;
    _isFetching = false;
    return TenorFeaturedData(pages: [page], nextPos: next);
  }

  Future<void> fetchNext() async {
    final data = state.value;
    if (data == null || data.nextPos == null || _isFetching) return;

    _isFetching = true;
    final generation = ++_fetchGeneration;

    try {
      final service = ref.read(tenorProvider);
      final page = await service.featured(limit: 10, pos: data.nextPos!);

      if (generation != _fetchGeneration) return;

      final next = page.results.length < 10 ? null : page.next;
      state = AsyncData(
        TenorFeaturedData(pages: [...data.pages, page], nextPos: next),
      );
    } on TenorException catch (e) {
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
      final service = ref.read(tenorProvider);
      final page = await service.featured(limit: 10, pos: '');

      if (generation != _fetchGeneration) return;

      final next = page.results.length < 10 ? null : page.next;
      state = AsyncData(TenorFeaturedData(pages: [page], nextPos: next));
    } on TenorException catch (e) {
      if (generation != _fetchGeneration) return;
      state = AsyncError(e, StackTrace.current);
    } finally {
      _isFetching = false;
    }
  }
}

final tenorFeaturedProvider =
    AsyncNotifierProvider<TenorFeaturedNotifier, TenorFeaturedData>(
      TenorFeaturedNotifier.new,
    );
