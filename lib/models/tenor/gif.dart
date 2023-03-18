import 'package:flemozi/models/converts.dart';
import 'package:flemozi/models/tenor/media_format.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gif.g.dart';

@JsonSerializable()
class TenorGif {
  final String id;
  final String title;
  final String url;
  @JsonKey(
    name: 'itemurl',
    fromJson: Uri.parse,
    toJson: uriToString,
  )
  final Uri itemUrl;
  @JsonKey(name: 'content_description')
  final String contentDescription;

  @JsonKey(
    name: 'created',
    fromJson: unixToDateTime,
    toJson: dateTimeToUnix,
  )
  final DateTime created;
  final List<String> tags;
  final List<String> flags;
  @JsonKey(name: 'hasaudio')
  final bool hasAudio;
  @JsonKey(name: 'hascaption')
  final bool? hasCaption;
  @JsonKey(name: 'bg_color')
  final String? bgColor;
  @JsonKey(name: 'media_formats')
  final Map<String, TenorMediaFormat> mediaFormats;

  TenorGif({
    required this.id,
    required this.title,
    required this.url,
    required this.itemUrl,
    required this.contentDescription,
    required this.created,
    required this.tags,
    required this.flags,
    required this.hasAudio,
    this.hasCaption,
    this.bgColor,
    required this.mediaFormats,
  });

  factory TenorGif.fromJson(Map<String, dynamic> json) =>
      _$TenorGifFromJson(json);

  Map<String, dynamic> toJson() => _$TenorGifToJson(this);

  TenorMediaFormat? get gif => mediaFormats["gif"];
  TenorMediaFormat? get mediumgif => mediaFormats["mediumgif"];
  TenorMediaFormat? get tinygif => mediaFormats["tinygif"];
  TenorMediaFormat? get nanogif => mediaFormats["nanogif"];
  TenorMediaFormat? get mp4 => mediaFormats["mp4"];
  TenorMediaFormat? get loopedmp4 => mediaFormats["loopedmp4"];
  TenorMediaFormat? get tinymp4 => mediaFormats["tinymp4"];
  TenorMediaFormat? get nanomp4 => mediaFormats["nanomp4"];
  TenorMediaFormat? get webm => mediaFormats["webm"];
  TenorMediaFormat? get tinywebm => mediaFormats["tinywebm"];
  TenorMediaFormat? get nanowebm => mediaFormats["nanowebm"];
  TenorMediaFormat? get webp_transparent => mediaFormats["webp_transparent"];
  TenorMediaFormat? get tinywebp_transparent =>
      mediaFormats["tinywebp_transparent"];
  TenorMediaFormat? get nanowebp_transparent =>
      mediaFormats["nanowebp_transparent"];
  TenorMediaFormat? get gif_transparent => mediaFormats["gif_transparent"];
  TenorMediaFormat? get tinygif_transparent =>
      mediaFormats["tinygif_transparent"];
  TenorMediaFormat? get nanogif_transparent =>
      mediaFormats["nanogif_transparent"];
}
