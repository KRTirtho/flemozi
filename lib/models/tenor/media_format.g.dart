// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_format.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TenorMediaFormat _$TenorMediaFormatFromJson(Map<String, dynamic> json) =>
    TenorMediaFormat(
      url: Uri.parse(json['url'] as String),
      duration: secondsToDuration(json['duration'] as num),
      preview: json['preview'] as String,
      dims: dimsFromJson(json['dims'] as List),
      size: json['size'] as int,
    );

Map<String, dynamic> _$TenorMediaFormatToJson(TenorMediaFormat instance) =>
    <String, dynamic>{
      'url': uriToString(instance.url),
      'duration': durationToSeconds(instance.duration),
      'preview': instance.preview,
      'dims': dimsToJson(instance.dims),
      'size': instance.size,
    };
