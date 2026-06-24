import './images.dart';
import './user.dart';

class GiphyGif {
  final String? title;
  final String? type;
  final String? id;
  final String? slug;
  final String? url;
  final String? bitlyGifUrl;
  final String? bitlyUrl;
  final String? embedUrl;
  final String? username;
  final String? source;
  final String? rating;
  final String? contentUrl;
  final String? sourceTld;
  final String? sourcePostUrl;
  final int? isSticker;
  final DateTime? importDatetime;
  final DateTime? trendingDatetime;
  final GiphyUser? user;
  final GiphyImages? images;

  GiphyGif({
    this.title,
    this.type,
    this.id,
    this.slug,
    this.url,
    this.bitlyGifUrl,
    this.bitlyUrl,
    this.embedUrl,
    this.username,
    this.source,
    this.rating,
    this.contentUrl,
    this.sourceTld,
    this.sourcePostUrl,
    this.isSticker,
    this.importDatetime,
    this.trendingDatetime,
    this.user,
    this.images,
  });

  factory GiphyGif.fromJson(Map<String, dynamic> json) => GiphyGif(
      title: json['title'] as String?,
      type: json['type'] as String?,
      id: json['id'] as String?,
      slug: json['slug'] as String?,
      url: json['url'] as String?,
      bitlyGifUrl: json['bitly_gif_url'] as String?,
      bitlyUrl: json['bitly_url'] as String?,
      embedUrl: json['embed_url'] as String?,
      username: json['username'] as String?,
      source: json['source'] as String?,
      rating: json['rating'] as String?,
      contentUrl: json['content_url'] as String?,
      sourceTld: json['source_tld'] as String?,
      sourcePostUrl: json['source_post_url'] as String?,
      isSticker: json['is_sticker'] as int?,
      importDatetime: json['import_datetime'] == null
          ? null
          : DateTime.parse(json['import_datetime'] as String),
      trendingDatetime: json['trending_datetime'] == null
          ? null
          : DateTime.parse(json['trending_datetime'] as String),
      user: json['user'] == null
          ? null
          : GiphyUser.fromJson(json['user'] as Map<String, dynamic>),
      images: json['images'] == null
          ? null
          : GiphyImages.fromJson(json['images'] as Map<String, dynamic>));

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'type': type,
      'id': id,
      'slug': slug,
      'url': url,
      'bitly_gif_url': bitlyGifUrl,
      'bitly_url': bitlyUrl,
      'embed_url': embedUrl,
      'username': username,
      'source': source,
      'rating': rating,
      'content_url': contentUrl,
      'source_tld': sourceTld,
      'source_post_url': sourcePostUrl,
      'is_sticker': isSticker,
      'import_datetime': importDatetime?.toIso8601String(),
      'trending_datetime': trendingDatetime?.toIso8601String(),
      'user': user,
      'images': images
    };
  }

  @override
  String toString() {
    return 'GiphyGif{title: $title, type: $type, id: $id, slug: $slug, url: $url, bitlyGifUrl: $bitlyGifUrl, bitlyUrl: $bitlyUrl, embedUrl: $embedUrl, username: $username, source: $source, rating: $rating, contentUrl: $contentUrl, sourceTld: $sourceTld, sourcePostUrl: $sourcePostUrl, isSticker: $isSticker, importDatetime: $importDatetime, trendingDatetime: $trendingDatetime, user: $user, images: $images}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GiphyGif &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          type == other.type &&
          id == other.id &&
          slug == other.slug &&
          url == other.url &&
          bitlyGifUrl == other.bitlyGifUrl &&
          bitlyUrl == other.bitlyUrl &&
          embedUrl == other.embedUrl &&
          username == other.username &&
          source == other.source &&
          rating == other.rating &&
          contentUrl == other.contentUrl &&
          sourceTld == other.sourceTld &&
          sourcePostUrl == other.sourcePostUrl &&
          isSticker == other.isSticker &&
          importDatetime == other.importDatetime &&
          trendingDatetime == other.trendingDatetime &&
          user == other.user &&
          images == other.images;

  @override
  int get hashCode =>
      title.hashCode ^
      type.hashCode ^
      id.hashCode ^
      slug.hashCode ^
      url.hashCode ^
      bitlyGifUrl.hashCode ^
      bitlyUrl.hashCode ^
      embedUrl.hashCode ^
      username.hashCode ^
      source.hashCode ^
      rating.hashCode ^
      contentUrl.hashCode ^
      sourceTld.hashCode ^
      sourcePostUrl.hashCode ^
      isSticker.hashCode ^
      importDatetime.hashCode ^
      trendingDatetime.hashCode ^
      user.hashCode ^
      images.hashCode;
}
