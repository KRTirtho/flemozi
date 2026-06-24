import './gif.dart';

class GiphyCollection {
  final List<GiphyGif?>? data;
  final GiphyPagination? pagination;
  final GiphyMeta? meta;

  GiphyCollection({this.data, this.pagination, this.meta});

  factory GiphyCollection.fromJson(Map<String, dynamic> json) =>
      GiphyCollection(
          data: (json['data'] as List?)
              ?.map((e) => e == null
                  ? null
                  : GiphyGif.fromJson(e as Map<String, dynamic>))
              .toList(),
          pagination: json['pagination'] == null
              ? null
              : GiphyPagination.fromJson(
                  json['pagination'] as Map<String, dynamic>),
          meta: json['meta'] == null
              ? null
              : GiphyMeta.fromJson(json['meta'] as Map<String, dynamic>));

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'data': data, 'pagination': pagination, 'meta': meta};

  @override
  String toString() {
    return 'GiphyCollection{data: $data, pagination: $pagination, meta: $meta}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GiphyCollection &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          pagination == other.pagination &&
          meta == other.meta;

  @override
  int get hashCode => data.hashCode ^ pagination.hashCode ^ meta.hashCode;
}

class GiphyPagination {
  final int? totalCount;
  final int? count;
  final int? offset;

  GiphyPagination({this.totalCount, this.count, this.offset});

  factory GiphyPagination.fromJson(Map<String, dynamic> json) =>
      GiphyPagination(
          totalCount: json['total_count'] as int?,
          count: json['count'] as int?,
          offset: json['offset'] as int?);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'total_count': totalCount,
      'count': count,
      'offset': offset
    };
  }

  @override
  String toString() {
    return 'GiphyPagination{totalCount: $totalCount, count: $count, offset: $offset}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GiphyPagination &&
          runtimeType == other.runtimeType &&
          totalCount == other.totalCount &&
          count == other.count &&
          offset == other.offset;

  @override
  int get hashCode => totalCount.hashCode ^ count.hashCode ^ offset.hashCode;
}

class GiphyMeta {
  final int? status;
  final String? msg;

  final String? responseId;

  GiphyMeta({this.status, this.msg, this.responseId});

  factory GiphyMeta.fromJson(Map<String, dynamic> json) => GiphyMeta(
      status: json['status'] as int?,
      msg: json['msg'] as String?,
      responseId: json['response_id'] as String?);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'status': status,
      'msg': msg,
      'response_id': responseId
    };
  }

  @override
  String toString() {
    return 'GiphyMeta{status: $status, msg: $msg, responseId: $responseId}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GiphyMeta &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          msg == other.msg &&
          responseId == other.responseId;

  @override
  int get hashCode => status.hashCode ^ msg.hashCode ^ responseId.hashCode;
}
