import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class TenorCategory {
  final String searchterm;
  final String path;
  final String image;
  final String name;

  TenorCategory({
    required this.searchterm,
    required this.path,
    required this.image,
    required this.name,
  });

  factory TenorCategory.fromJson(Map<String, dynamic> json) =>
      _$TenorCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$TenorCategoryToJson(this);
}
