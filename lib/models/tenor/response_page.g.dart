// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TenorResponsePage _$TenorResponsePageFromJson(Map<String, dynamic> json) =>
    TenorResponsePage(
      results: (json['results'] as List<dynamic>)
          .map((e) => TenorGif.fromJson(e as Map<String, dynamic>))
          .toList(),
      next: json['next'] as String,
    );

Map<String, dynamic> _$TenorResponsePageToJson(TenorResponsePage instance) =>
    <String, dynamic>{
      'results': instance.results,
      'next': instance.next,
    };
