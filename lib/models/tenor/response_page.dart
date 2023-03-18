import 'package:flemozi/models/tenor/gif.dart';
import 'package:json_annotation/json_annotation.dart';

part 'response_page.g.dart';

@JsonSerializable()
class TenorResponsePage {
  final List<TenorGif> results;
  final String next;

  TenorResponsePage({
    required this.results,
    required this.next,
  });

  factory TenorResponsePage.fromJson(Map<String, dynamic> json) =>
      _$TenorResponsePageFromJson(json);

  Map<String, dynamic> toJson() => _$TenorResponsePageToJson(this);
}
