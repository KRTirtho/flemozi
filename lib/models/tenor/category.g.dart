// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TenorCategory _$TenorCategoryFromJson(Map<String, dynamic> json) =>
    TenorCategory(
      searchterm: json['searchterm'] as String,
      path: json['path'] as String,
      image: json['image'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$TenorCategoryToJson(TenorCategory instance) =>
    <String, dynamic>{
      'searchterm': instance.searchterm,
      'path': instance.path,
      'image': instance.image,
      'name': instance.name,
    };
