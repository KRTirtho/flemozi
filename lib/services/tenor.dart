import 'dart:convert';

import 'package:flemozi/models/tenor/response_page.dart';
import 'package:flemozi/services/exception.dart';
import 'package:http/http.dart';

enum TenorContentFilter { off, low, medium, high }

enum TenorArRange { all, wide, standard }

enum TenorSearchFilter {
  animated,
  static,
  all;

  String get originalValues {
    switch (this) {
      case TenorSearchFilter.animated:
        return 'sticker,-static';
      case TenorSearchFilter.static:
        return 'sticker,static';
      case TenorSearchFilter.all:
        return 'sticker';
    }
  }
}

enum TenorMediaType {
  gif,
  mediumgif,
  tinygif,
  nanogif,
  mp4,
  loopedmp4,
  tinymp4,
  nanomp4,
  webm,
  tinywebm,
  nanowebm,
}

class Tenor {
  final String apiKey;
  final Client client;

  final String baseUrl = 'https://tenor.googleapis.com/v2';

  Tenor({
    required this.apiKey,
  }) : client = Client();

  Future<Response> _request(
      String path, Map<String, String> queryParameters) async {
    final uri = Uri.parse(
      '$baseUrl/$path',
    ).replace(
      queryParameters: {
        ...queryParameters,
        'key': apiKey,
      },
    );
    final response = await client.get(uri);
    return response;
  }

  Future<TenorResponsePage> search(
    String query, {
    String? clientKey,
    TenorSearchFilter? searchFilter,
    TenorContentFilter? contentFilter,
    TenorArRange? arRange,
    bool? random,
    int? limit,
    Object? pos,
    String? locale,
    String? country,
  }) async {
    assert(
      pos == null || pos is String || pos is int,
      'pos must be either a String or an int',
    );
    final response = await _request(
      'search',
      {
        'key': apiKey,
        'q': query,
        if (clientKey != null) 'client_key': clientKey,
        if (searchFilter != null) 'searchfilter': searchFilter.originalValues,
        if (contentFilter != null) 'contentfilter': contentFilter.name,
        if (arRange != null) 'ar_range': arRange.name,
        if (random != null) 'random': random.toString(),
        if (limit != null) 'limit': limit.toString(),
        if (pos != null) 'pos': pos.toString(),
        if (locale != null) 'locale': locale,
        if (country != null) 'country': country,
      },
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return TenorResponsePage.fromJson(body);
    } else {
      throw TenorException.fromResponse(response);
    }
  }

  Future<List<String>> searchSuggestions(
    String query, {
    String? country,
    int? limit,
    String? locale,
  }) async {
    final response = await _request(
      'search_suggestions',
      {
        'key': apiKey,
        'q': query,
        if (limit != null) 'limit': limit.toString(),
        if (locale != null) 'locale': locale,
        if (country != null) 'country': country,
      },
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return List<String>.from(body['results']);
    } else {
      throw TenorException.fromResponse(response);
    }
  }

  Future<List<String>> autocomplete(
    String query, {
    String? country,
    int? limit,
    String? locale,
    String? clientKey,
  }) async {
    final response = await _request(
      'autocomplete',
      {
        'key': apiKey,
        'q': query,
        if (limit != null) 'limit': limit.toString(),
        if (locale != null) 'locale': locale,
        if (country != null) 'country': country,
        if (clientKey != null) 'client_key': clientKey,
      },
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return List<String>.from(body['results']);
    } else {
      throw TenorException.fromResponse(response);
    }
  }

  Future<void> registerShare(
    String id, {
    String? query,
    String? clientKey,
    String? locale,
    String? country,
  }) async {
    final response = await _request(
      'share',
      {
        'key': apiKey,
        'id': id,
        if (clientKey != null) 'client_key': clientKey,
        if (query != null) 'q': query,
        if (locale != null) 'locale': locale,
        if (country != null) 'country': country,
      },
    );
    if (response.statusCode != 200) {
      throw TenorException.fromResponse(response);
    }
  }

  Future<TenorResponsePage> featured({
    String? clientKey,
    TenorSearchFilter? searchFilter,
    TenorContentFilter? contentFilter,
    TenorArRange? arRange,
    bool? random,
    int? limit,
    Object? pos,
    String? locale,
    String? country,
    Set<TenorMediaType>? mediaFilter,
  }) async {
    assert(
      pos == null || pos is String || pos is int,
      'pos must be either a String or an int',
    );
    final response = await _request(
      'featured',
      {
        'key': apiKey,
        if (clientKey != null) 'client_key': clientKey,
        if (searchFilter != null) 'searchfilter': searchFilter.originalValues,
        if (contentFilter != null) 'contentfilter': contentFilter.name,
        if (arRange != null) 'ar_range': arRange.name,
        if (random != null) 'random': random.toString(),
        if (limit != null) 'limit': limit.toString(),
        if (pos != null) 'pos': pos.toString(),
        if (locale != null) 'locale': locale,
        if (country != null) 'country': country,
        if (mediaFilter != null)
          'media_filter': mediaFilter.map((e) => e.name).join(','),
      },
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return TenorResponsePage.fromJson(body);
    } else {
      throw TenorException.fromResponse(response);
    }
  }
}
