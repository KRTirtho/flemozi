class GiphyFullImage {
  final String? url;
  final String? width;
  final String? height;
  final String? size;
  final String? mp4;
  final String? mp4Size;
  final String? webp;
  final String? webpSize;

  GiphyFullImage({
    this.url,
    this.width,
    this.height,
    this.size,
    this.mp4,
    this.mp4Size,
    this.webp,
    this.webpSize,
  });

  factory GiphyFullImage.fromJson(Map<String, dynamic> json) => GiphyFullImage(
      url: json['url'] as String?,
      width: json['width'] as String?,
      height: json['height'] as String?,
      size: json['size'] as String?,
      mp4: json['mp4'] as String?,
      mp4Size: json['mp4_size'] as String?,
      webp: json['webp'] as String?,
      webpSize: json['webp_size'] as String?);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'url': url,
      'width': width,
      'height': height,
      'size': size,
      'mp4': mp4,
      'mp4_size': mp4Size,
      'webp': webp,
      'webp_size': webpSize
    };
  }

  @override
  String toString() {
    return 'GiphyFullImage{url: $url, width: $width, height: $height, size: $size, mp4: $mp4, mp4Size: $mp4Size, webp: $webp, webpSize: $webpSize}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GiphyFullImage &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          width == other.width &&
          height == other.height &&
          size == other.size &&
          mp4 == other.mp4 &&
          mp4Size == other.mp4Size &&
          webp == other.webp &&
          webpSize == other.webpSize;

  @override
  int get hashCode =>
      url.hashCode ^
      width.hashCode ^
      height.hashCode ^
      size.hashCode ^
      mp4.hashCode ^
      mp4Size.hashCode ^
      webp.hashCode ^
      webpSize.hashCode;
}

class GiphyOriginalImage {
  final String? url;
  final String? width;
  final String? height;
  final String? size;
  final String? frames;
  final String? mp4;
  final String? mp4Size;
  final String? webp;
  final String? webpSize;
  final String? hash;

  GiphyOriginalImage({
    this.url,
    this.width,
    this.height,
    this.size,
    this.frames,
    this.mp4,
    this.mp4Size,
    this.webp,
    this.webpSize,
    this.hash,
  });

  factory GiphyOriginalImage.fromJson(Map<String, dynamic> json) {
    return GiphyOriginalImage(
        url: json['url'] as String?,
        width: json['width'] as String?,
        height: json['height'] as String?,
        size: json['size'] as String?,
        frames: json['frames'] as String?,
        mp4: json['mp4'] as String?,
        mp4Size: json['mp4_size'] as String?,
        webp: json['webp'] as String?,
        webpSize: json['webp_size'] as String?,
        hash: json['hash'] as String?);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'url': url,
      'width': width,
      'height': height,
      'size': size,
      'frames': frames,
      'mp4': mp4,
      'mp4_size': mp4Size,
      'webp': webp,
      'webp_size': webpSize,
      'hash': hash
    };
  }

  @override
  String toString() {
    return 'GiphyOriginalImage{url: $url, width: $width, height: $height, size: $size, frames: $frames, mp4: $mp4, mp4Size: $mp4Size, webp: $webp, webpSize: $webpSize, hash: $hash}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GiphyOriginalImage &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          width == other.width &&
          height == other.height &&
          size == other.size &&
          frames == other.frames &&
          mp4 == other.mp4 &&
          mp4Size == other.mp4Size &&
          webp == other.webp &&
          webpSize == other.webpSize &&
          hash == other.hash;

  @override
  int get hashCode =>
      url.hashCode ^
      width.hashCode ^
      height.hashCode ^
      size.hashCode ^
      frames.hashCode ^
      mp4.hashCode ^
      mp4Size.hashCode ^
      webp.hashCode ^
      webpSize.hashCode ^
      hash.hashCode;
}

class GiphyStillImage {
  final String? url;
  final String? width;
  final String? height;
  final String? size;

  GiphyStillImage({
    this.url,
    this.width,
    this.height,
    this.size,
  });

  factory GiphyStillImage.fromJson(Map<String, dynamic> json) =>
      GiphyStillImage(
          url: json['url'] as String?,
          width: json['width'] as String?,
          height: json['height'] as String?,
          size: json['size'] as String?);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'url': url,
      'width': width,
      'height': height,
      'size': size
    };
  }

  @override
  String toString() {
    return 'GiphyStillImage{url: $url, width: $width, height: $height, size: $size}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GiphyStillImage &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          width == other.width &&
          height == other.height &&
          size == other.size;

  @override
  int get hashCode =>
      url.hashCode ^ width.hashCode ^ height.hashCode ^ size.hashCode;
}

class GiphyDownsampledImage {
  final String? url;
  final String? width;
  final String? height;
  final String? size;
  final String? webp;
  final String? webpSize;

  GiphyDownsampledImage({
    this.url,
    this.width,
    this.height,
    this.size,
    this.webp,
    this.webpSize,
  });

  factory GiphyDownsampledImage.fromJson(Map<String, dynamic> json) {
    return GiphyDownsampledImage(
        url: json['url'] as String?,
        width: json['width'] as String?,
        height: json['height'] as String?,
        size: json['size'] as String?,
        webp: json['webp'] as String?,
        webpSize: json['webp_size'] as String?);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'url': url,
      'width': width,
      'height': height,
      'size': size,
      'webp': webp,
      'webp_size': webpSize
    };
  }

  @override
  String toString() {
    return 'GiphyDownsampledImage{url: $url, width: $width, height: $height, size: $size, webp: $webp, webpSize: $webpSize}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GiphyDownsampledImage &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          width == other.width &&
          height == other.height &&
          size == other.size &&
          webp == other.webp &&
          webpSize == other.webpSize;

  @override
  int get hashCode =>
      url.hashCode ^
      width.hashCode ^
      height.hashCode ^
      size.hashCode ^
      webp.hashCode ^
      webpSize.hashCode;
}

class GiphyLoopingImage {
  final String? mp4;
  final String? mp4Size;

  GiphyLoopingImage({
    this.mp4,
    this.mp4Size,
  });

  factory GiphyLoopingImage.fromJson(Map<String, dynamic> json) =>
      GiphyLoopingImage(
          mp4: json['mp4'] as String?, mp4Size: json['mp4_size'] as String?);

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'mp4': mp4, 'mp4_size': mp4Size};

  @override
  String toString() {
    return 'GiphyLoopingImage{mp4: $mp4, mp4Size: $mp4Size}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GiphyLoopingImage &&
          runtimeType == other.runtimeType &&
          mp4 == other.mp4 &&
          mp4Size == other.mp4Size;

  @override
  int get hashCode => mp4.hashCode ^ mp4Size.hashCode;
}

class GiphyPreviewImage {
  final String? width;
  final String? height;
  final String? mp4;
  final String? mp4Size;

  GiphyPreviewImage({
    this.width,
    this.height,
    this.mp4,
    this.mp4Size,
  });

  factory GiphyPreviewImage.fromJson(Map<String, dynamic> json) {
    return GiphyPreviewImage(
      width: json['width'] as String?,
      height: json['height'] as String?,
      mp4: json['mp4'] as String?,
      mp4Size: json['mp4_size'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'width': width,
      'height': height,
      'mp4': mp4,
      'mp4_size': mp4Size
    };
  }

  @override
  String toString() {
    return 'GiphyPreviewImage{width: $width, height: $height, mp4: $mp4, mp4Size: $mp4Size}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GiphyPreviewImage &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          height == other.height &&
          mp4 == other.mp4 &&
          mp4Size == other.mp4Size;

  @override
  int get hashCode =>
      width.hashCode ^ height.hashCode ^ mp4.hashCode ^ mp4Size.hashCode;
}

class GiphyDownsizedImage {
  final String? url;
  final String? width;
  final String? height;
  final String? size;

  GiphyDownsizedImage({
    this.url,
    this.width,
    this.height,
    this.size,
  });

  factory GiphyDownsizedImage.fromJson(Map<String, dynamic> json) {
    return GiphyDownsizedImage(
      url: json['url'] as String?,
      width: json['width'] as String?,
      height: json['height'] as String?,
      size: json['size'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'url': url,
      'width': width,
      'height': height,
      'size': size
    };
  }

  @override
  String toString() {
    return 'GiphyDownsizedImage{url: $url, width: $width, height: $height, size: $size}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GiphyDownsizedImage &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          width == other.width &&
          height == other.height &&
          size == other.size;

  @override
  int get hashCode =>
      url.hashCode ^ width.hashCode ^ height.hashCode ^ size.hashCode;
}

class GiphyWebPImage {
  final String? url;
  final String? width;
  final String? height;
  final String? size;

  GiphyWebPImage({
    this.url,
    this.width,
    this.height,
    this.size,
  });

  factory GiphyWebPImage.fromJson(Map<String, dynamic> json) {
    return GiphyWebPImage(
      url: json['url'] as String?,
      width: json['width'] as String?,
      height: json['height'] as String?,
      size: json['size'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'url': url,
      'width': width,
      'height': height,
      'size': size
    };
  }

  @override
  String toString() {
    return 'GiphyWebPImage{url: $url, width: $width, height: $height, size: $size}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GiphyWebPImage &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          width == other.width &&
          height == other.height &&
          size == other.size;

  @override
  int get hashCode =>
      url.hashCode ^ width.hashCode ^ height.hashCode ^ size.hashCode;
}
