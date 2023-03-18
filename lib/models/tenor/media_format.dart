import 'package:flemozi/models/converts.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'media_format.g.dart';

@JsonSerializable()
class TenorMediaFormat {
  @JsonKey(
    name: 'url',
    fromJson: Uri.parse,
    toJson: uriToString,
  )
  final Uri url;
  @JsonKey(
    name: 'duration',
    fromJson: secondsToDuration,
    toJson: durationToSeconds,
  )
  final Duration duration;
  final String preview;

  @JsonKey(
    name: 'dims',
    fromJson: dimsFromJson,
    toJson: dimsToJson,
  )
  final Size dims;
  final int size;

  TenorMediaFormat({
    required this.url,
    required this.duration,
    required this.preview,
    required this.dims,
    required this.size,
  });

  factory TenorMediaFormat.fromJson(Map<String, dynamic> json) =>
      _$TenorMediaFormatFromJson(json);

  Map<String, dynamic> toJson() => _$TenorMediaFormatToJson(this);
}
