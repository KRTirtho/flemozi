import './image.dart';

class GiphyImages {
  final GiphyStillImage? fixedHeightStill;
  final GiphyStillImage? originalStill;
  final GiphyFullImage? fixedWidth;
  final GiphyStillImage? fixedHeightSmallStill;
  final GiphyDownsampledImage? fixedHeightDownsampled;
  final GiphyPreviewImage? preview;
  final GiphyFullImage? fixedHeightSmall;
  final GiphyStillImage? downsizedStill;
  final GiphyDownsizedImage? downsized;
  final GiphyDownsizedImage? downsizedLarge;
  final GiphyStillImage? fixedWidthSmallStill;
  final GiphyWebPImage? previewWebp;
  final GiphyStillImage? fixedWidthStill;
  final GiphyFullImage? fixedWidthSmall;
  final GiphyPreviewImage? downsizedSmall;
  final GiphyDownsampledImage? fixedWidthDownsampled;
  final GiphyPreviewImage? downsizedMedium;
  final GiphyOriginalImage? original;
  final GiphyFullImage? fixedHeight;
  final GiphyPreviewImage? hd;
  final GiphyLoopingImage? looping;
  final GiphyPreviewImage? originalMp4;
  final GiphyDownsizedImage? previewGif;
  final GiphyStillImage? w480Still;

  GiphyImages({
    this.fixedHeightStill,
    this.originalStill,
    this.fixedWidth,
    this.fixedHeightSmallStill,
    this.fixedHeightDownsampled,
    this.preview,
    this.fixedHeightSmall,
    this.downsizedStill,
    this.downsized,
    this.downsizedLarge,
    this.fixedWidthSmallStill,
    this.previewWebp,
    this.fixedWidthStill,
    this.fixedWidthSmall,
    this.downsizedSmall,
    this.fixedWidthDownsampled,
    this.downsizedMedium,
    this.original,
    this.fixedHeight,
    this.hd,
    this.looping,
    this.originalMp4,
    this.previewGif,
    this.w480Still,
  });

  factory GiphyImages.fromJson(Map<String, dynamic> json) {
    return GiphyImages(
      fixedHeightStill: json['fixed_height_still'] == null
          ? null
          : GiphyStillImage.fromJson(
              json['fixed_height_still'] as Map<String, dynamic>),
      originalStill: json['original_still'] == null
          ? null
          : GiphyStillImage.fromJson(
              json['original_still'] as Map<String, dynamic>),
      fixedWidth: json['fixed_width'] == null
          ? null
          : GiphyFullImage.fromJson(
              json['fixed_width'] as Map<String, dynamic>),
      fixedHeightSmallStill: json['fixed_height_small_still'] == null
          ? null
          : GiphyStillImage.fromJson(
              json['fixed_height_small_still'] as Map<String, dynamic>),
      fixedHeightDownsampled: json['fixed_height_downsampled'] == null
          ? null
          : GiphyDownsampledImage.fromJson(
              json['fixed_height_downsampled'] as Map<String, dynamic>),
      preview: json['preview'] == null
          ? null
          : GiphyPreviewImage.fromJson(json['preview'] as Map<String, dynamic>),
      fixedHeightSmall: json['fixed_height_small'] == null
          ? null
          : GiphyFullImage.fromJson(
              json['fixed_height_small'] as Map<String, dynamic>),
      downsizedStill: json['downsized_still'] == null
          ? null
          : GiphyStillImage.fromJson(
              json['downsized_still'] as Map<String, dynamic>),
      downsized: json['downsized'] == null
          ? null
          : GiphyDownsizedImage.fromJson(
              json['downsized'] as Map<String, dynamic>),
      downsizedLarge: json['downsized_large'] == null
          ? null
          : GiphyDownsizedImage.fromJson(
              json['downsized_large'] as Map<String, dynamic>),
      fixedWidthSmallStill: json['fixed_width_small_still'] == null
          ? null
          : GiphyStillImage.fromJson(
              json['fixed_width_small_still'] as Map<String, dynamic>),
      previewWebp: json['preview_webp'] == null
          ? null
          : GiphyWebPImage.fromJson(
              json['preview_webp'] as Map<String, dynamic>),
      fixedWidthStill: json['fixed_width_still'] == null
          ? null
          : GiphyStillImage.fromJson(
              json['fixed_width_still'] as Map<String, dynamic>),
      fixedWidthSmall: json['fixed_width_small'] == null
          ? null
          : GiphyFullImage.fromJson(
              json['fixed_width_small'] as Map<String, dynamic>),
      downsizedSmall: json['downsized_small'] == null
          ? null
          : GiphyPreviewImage.fromJson(
              json['downsized_small'] as Map<String, dynamic>),
      fixedWidthDownsampled: json['fixed_width_downsampled'] == null
          ? null
          : GiphyDownsampledImage.fromJson(
              json['fixed_width_downsampled'] as Map<String, dynamic>),
      downsizedMedium: json['downsized_medium'] == null
          ? null
          : GiphyPreviewImage.fromJson(
              json['downsized_medium'] as Map<String, dynamic>),
      original: json['original'] == null
          ? null
          : GiphyOriginalImage.fromJson(
              json['original'] as Map<String, dynamic>),
      fixedHeight: json['fixed_height'] == null
          ? null
          : GiphyFullImage.fromJson(
              json['fixed_height'] as Map<String, dynamic>),
      hd: json['hd'] == null
          ? null
          : GiphyPreviewImage.fromJson(json['hd'] as Map<String, dynamic>),
      looping: json['looping'] == null
          ? null
          : GiphyLoopingImage.fromJson(json['looping'] as Map<String, dynamic>),
      originalMp4: json['original_mp4'] == null
          ? null
          : GiphyPreviewImage.fromJson(
              json['original_mp4'] as Map<String, dynamic>),
      previewGif: json['preview_gif'] == null
          ? null
          : GiphyDownsizedImage.fromJson(
              json['preview_gif'] as Map<String, dynamic>),
      w480Still: json['480w_still'] == null
          ? null
          : GiphyStillImage.fromJson(
              json['480w_still'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'fixed_height_still': fixedHeightStill,
      'original_still': originalStill,
      'fixed_width': fixedWidth,
      'fixed_height_small_still': fixedHeightSmallStill,
      'fixed_height_downsampled': fixedHeightDownsampled,
      'preview': preview,
      'fixed_height_small': fixedHeightSmall,
      'downsized_still': downsizedStill,
      'downsized': downsized,
      'downsized_large': downsizedLarge,
      'fixed_width_small_still': fixedWidthSmallStill,
      'preview_webp': previewWebp,
      'fixed_width_still': fixedWidthStill,
      'fixed_width_small': fixedWidthSmall,
      'downsized_small': downsizedSmall,
      'fixed_width_downsampled': fixedWidthDownsampled,
      'downsized_medium': downsizedMedium,
      'original': original,
      'fixed_height': fixedHeight,
      'hd': hd,
      'looping': looping,
      'original_mp4': originalMp4,
      'preview_gif': previewGif,
      '480w_still': w480Still
    };
  }

  @override
  String toString() {
    return 'GiphyImages{fixedHeightStill: $fixedHeightStill, originalStill: $originalStill, fixedWidth: $fixedWidth, fixedHeightSmallStill: $fixedHeightSmallStill, fixedHeightDownsampled: $fixedHeightDownsampled, preview: $preview, fixedHeightSmall: $fixedHeightSmall, downsizedStill: $downsizedStill, downsized: $downsized, downsizedLarge: $downsizedLarge, fixedWidthSmallStill: $fixedWidthSmallStill, previewWebp: $previewWebp, fixedWidthStill: $fixedWidthStill, fixedWidthSmall: $fixedWidthSmall, downsizedSmall: $downsizedSmall, fixedWidthDownsampled: $fixedWidthDownsampled, downsizedMedium: $downsizedMedium, original: $original, fixedHeight: $fixedHeight, hd: $hd, looping: $looping, originalMp4: $originalMp4, previewGif: $previewGif, w480Still: $w480Still}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GiphyImages &&
          runtimeType == other.runtimeType &&
          fixedHeightStill == other.fixedHeightStill &&
          originalStill == other.originalStill &&
          fixedWidth == other.fixedWidth &&
          fixedHeightSmallStill == other.fixedHeightSmallStill &&
          fixedHeightDownsampled == other.fixedHeightDownsampled &&
          preview == other.preview &&
          fixedHeightSmall == other.fixedHeightSmall &&
          downsizedStill == other.downsizedStill &&
          downsized == other.downsized &&
          downsizedLarge == other.downsizedLarge &&
          fixedWidthSmallStill == other.fixedWidthSmallStill &&
          previewWebp == other.previewWebp &&
          fixedWidthStill == other.fixedWidthStill &&
          fixedWidthSmall == other.fixedWidthSmall &&
          downsizedSmall == other.downsizedSmall &&
          fixedWidthDownsampled == other.fixedWidthDownsampled &&
          downsizedMedium == other.downsizedMedium &&
          original == other.original &&
          fixedHeight == other.fixedHeight &&
          hd == other.hd &&
          looping == other.looping &&
          originalMp4 == other.originalMp4 &&
          previewGif == other.previewGif &&
          w480Still == other.w480Still;

  @override
  int get hashCode =>
      fixedHeightStill.hashCode ^
      originalStill.hashCode ^
      fixedWidth.hashCode ^
      fixedHeightSmallStill.hashCode ^
      fixedHeightDownsampled.hashCode ^
      preview.hashCode ^
      fixedHeightSmall.hashCode ^
      downsizedStill.hashCode ^
      downsized.hashCode ^
      downsizedLarge.hashCode ^
      fixedWidthSmallStill.hashCode ^
      previewWebp.hashCode ^
      fixedWidthStill.hashCode ^
      fixedWidthSmall.hashCode ^
      downsizedSmall.hashCode ^
      fixedWidthDownsampled.hashCode ^
      downsizedMedium.hashCode ^
      original.hashCode ^
      fixedHeight.hashCode ^
      hd.hashCode ^
      looping.hashCode ^
      originalMp4.hashCode ^
      previewGif.hashCode ^
      w480Still.hashCode;
}
