// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gif.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TenorGif _$TenorGifFromJson(Map<String, dynamic> json) => TenorGif(
      id: json['id'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      itemUrl: Uri.parse(json['itemurl'] as String),
      contentDescription: json['content_description'] as String,
      created: unixToDateTime(json['created'] as double),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      flags: (json['flags'] as List<dynamic>).map((e) => e as String).toList(),
      hasAudio: json['hasaudio'] as bool,
      hasCaption: json['hascaption'] as bool?,
      bgColor: json['bg_color'] as String?,
      mediaFormats: (json['media_formats'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, TenorMediaFormat.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$TenorGifToJson(TenorGif instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'url': instance.url,
      'itemurl': uriToString(instance.itemUrl),
      'content_description': instance.contentDescription,
      'created': dateTimeToUnix(instance.created),
      'tags': instance.tags,
      'flags': instance.flags,
      'hasaudio': instance.hasAudio,
      'hascaption': instance.hasCaption,
      'bg_color': instance.bgColor,
      'media_formats': instance.mediaFormats,
    };
