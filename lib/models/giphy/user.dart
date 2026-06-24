class GiphyUser {
  final String? avatarUrl;
  final String? bannerUrl;
  final String? profileUrl;
  final String? username;
  final String? displayName;
  final String? twitter;
  final String? guid;
  final String? metadataDescription;
  final String? attributionDisplayName;
  final String? name;
  final String? description;
  final String? facebookUrl;
  final String? twitterUrl;
  final String? instagramUrl;
  final String? tumblrUrl;
  final bool? suppressChrome;
  final String? websiteUrl;
  final String? websiteDisplayUrl;

  GiphyUser({
    this.avatarUrl,
    this.bannerUrl,
    this.profileUrl,
    this.username,
    this.displayName,
    this.twitter,
    this.guid,
    this.metadataDescription,
    this.attributionDisplayName,
    this.name,
    this.description,
    this.facebookUrl,
    this.twitterUrl,
    this.instagramUrl,
    this.tumblrUrl,
    this.suppressChrome,
    this.websiteUrl,
    this.websiteDisplayUrl,
  });

  factory GiphyUser.fromJson(Map<String, dynamic> json) {
    return GiphyUser(
      avatarUrl: json['avatar_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      profileUrl: json['profile_url'] as String?,
      username: json['username'] as String?,
      displayName: json['display_name'] as String?,
      twitter: json['twitter'] as String?,
      guid: json['guid'] as String?,
      metadataDescription: json['metadata_description'] as String?,
      attributionDisplayName: json['attribution_display_name'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      facebookUrl: json['facebook_url'] as String?,
      twitterUrl: json['twitter_url'] as String?,
      instagramUrl: json['instagram_url'] as String?,
      tumblrUrl: json['tumblr_url'] as String?,
      suppressChrome: json['suppress_chrome'] as bool?,
      websiteUrl: json['website_url'] as String?,
      websiteDisplayUrl: json['website_display_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'avatar_url': avatarUrl,
      'banner_url': bannerUrl,
      'profile_url': profileUrl,
      'username': username,
      'display_name': displayName,
      'twitter': twitter,
      'guid': guid,
      'metadata_description': metadataDescription,
      'attribution_display_name': attributionDisplayName,
      'name': name,
      'description': description,
      'facebook_url': facebookUrl,
      'twitter_url': twitterUrl,
      'instagram_url': instagramUrl,
      'tumblr_url': tumblrUrl,
      'suppress_chrome': suppressChrome,
      'website_url': websiteUrl,
      'website_display_url': websiteDisplayUrl,
    };
  }

  @override
  String toString() {
    return 'GiphyUser{avatarUrl: $avatarUrl, bannerUrl: $bannerUrl, profileUrl: $profileUrl, username: $username, displayName: $displayName, twitter: $twitter, guid: $guid, metadataDescription: $metadataDescription, attributionDisplayName: $attributionDisplayName, name: $name, description: $description, facebookUrl: $facebookUrl, twitterUrl: $twitterUrl, instagramUrl: $instagramUrl, tumblrUrl: $tumblrUrl, suppressChrome: $suppressChrome, websiteUrl: $websiteUrl, websiteDisplayUrl: $websiteDisplayUrl}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GiphyUser &&
          runtimeType == other.runtimeType &&
          avatarUrl == other.avatarUrl &&
          bannerUrl == other.bannerUrl &&
          profileUrl == other.profileUrl &&
          username == other.username &&
          displayName == other.displayName &&
          twitter == other.twitter &&
          guid == other.guid &&
          metadataDescription == other.metadataDescription &&
          attributionDisplayName == other.attributionDisplayName &&
          name == other.name &&
          description == other.description &&
          facebookUrl == other.facebookUrl &&
          twitterUrl == other.twitterUrl &&
          instagramUrl == other.instagramUrl &&
          tumblrUrl == other.tumblrUrl &&
          suppressChrome == other.suppressChrome &&
          websiteUrl == other.websiteUrl &&
          websiteDisplayUrl == other.websiteDisplayUrl;

  @override
  int get hashCode =>
      avatarUrl.hashCode ^
      bannerUrl.hashCode ^
      profileUrl.hashCode ^
      username.hashCode ^
      displayName.hashCode ^
      twitter.hashCode ^
      guid.hashCode ^
      metadataDescription.hashCode ^
      attributionDisplayName.hashCode ^
      name.hashCode ^
      description.hashCode ^
      facebookUrl.hashCode ^
      twitterUrl.hashCode ^
      instagramUrl.hashCode ^
      tumblrUrl.hashCode ^
      suppressChrome.hashCode ^
      websiteUrl.hashCode ^
      websiteDisplayUrl.hashCode;
}
