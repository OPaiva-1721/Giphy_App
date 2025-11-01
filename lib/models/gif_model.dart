import 'package:equatable/equatable.dart';

/// Modelo de dados para GIF
class GifModel extends Equatable {
  final String? id;
  final String? url;
  final String? stillUrl;
  final String? title;
  final String? username;
  final String? userDisplayName;
  final String? userAvatarUrl;
  final String? analyticsOnLoad;
  final String? analyticsOnClick;
  final int? width;
  final int? height;
  final int? size;
  final DateTime? trendingDateTime;
  final String? rating;
  final List<String>? tags;

  const GifModel({
    this.id,
    this.url,
    this.stillUrl,
    this.title,
    this.username,
    this.userDisplayName,
    this.userAvatarUrl,
    this.analyticsOnLoad,
    this.analyticsOnClick,
    this.width,
    this.height,
    this.size,
    this.trendingDateTime,
    this.rating,
    this.tags,
  });

  factory GifModel.fromJson(Map<String, dynamic> json) {
    // Se for formato simplificado (salvo localmente)
    if (json.containsKey('url') && !json.containsKey('images')) {
      final trendingDateTimeStr = json['trendingDateTime'] as String?;
      DateTime? trendingDateTime;
      if (trendingDateTimeStr != null) {
        try {
          trendingDateTime = DateTime.parse(trendingDateTimeStr);
        } catch (_) {}
      }

      return GifModel(
        id: json['id']?.toString(),
        url: json['url']?.toString(),
        stillUrl: json['stillUrl']?.toString(),
        title: json['title']?.toString(),
        username: json['username']?.toString(),
        userDisplayName: json['userDisplayName']?.toString(),
        userAvatarUrl: json['userAvatarUrl']?.toString(),
        analyticsOnLoad: json['analyticsOnLoad']?.toString(),
        analyticsOnClick: json['analyticsOnClick']?.toString(),
        width: json['width'] is int
            ? json['width'] as int
            : (json['width'] != null
                  ? int.tryParse(json['width'].toString())
                  : null),
        height: json['height'] is int
            ? json['height'] as int
            : (json['height'] != null
                  ? int.tryParse(json['height'].toString())
                  : null),
        size: json['size'] is int
            ? json['size'] as int
            : (json['size'] != null
                  ? int.tryParse(json['size'].toString())
                  : null),
        trendingDateTime: trendingDateTime,
        rating: json['rating']?.toString(),
        tags: (json['tags'] as List?)
            ?.map((e) => e.toString())
            .toList()
            .cast<String>(),
      );
    }

    // Formato da API do Giphy
    final imagesJson = json['images'] ?? {};
    Map<String, dynamic> images = {};
    if (imagesJson is Map) {
      images = imagesJson.map((key, value) => MapEntry(key.toString(), value));
    }

    final downsizedJson = images['downsized_medium'];
    final originalJson = images['original'];
    final stillJson =
        images['downsized_still'] ??
        images['fixed_height_still'] ??
        images['original_still'];

    Map<String, dynamic>? downsized;
    Map<String, dynamic>? original;
    Map<String, dynamic>? still;

    if (downsizedJson is Map) {
      downsized = downsizedJson.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    if (originalJson is Map) {
      original = originalJson.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    if (stillJson is Map) {
      still = stillJson.map((key, value) => MapEntry(key.toString(), value));
    }

    final analyticsJson = json['analytics'] ?? {};
    Map<String, dynamic> analytics = {};
    if (analyticsJson is Map) {
      analytics = analyticsJson.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }

    final onloadMap = analytics['onload'];
    final onclickMap = analytics['onclick'];
    final onload = onloadMap is Map ? onloadMap['url']?.toString() : null;
    final onclick = onclickMap is Map ? onclickMap['url']?.toString() : null;

    final userJson = json['user'];
    Map<String, dynamic>? user;
    if (userJson is Map) {
      user = userJson.map((key, value) => MapEntry(key.toString(), value));
    }
    final username = (user?['username'] ?? json['username'])?.toString();
    final userDisplayName = user?['display_name']?.toString();
    final userAvatarUrl = user?['avatar_url']?.toString();

    final trendingDateTimeStr = json['trending_datetime']?.toString();
    DateTime? trendingDateTime;
    if (trendingDateTimeStr != null &&
        trendingDateTimeStr != '0000-00-00 00:00:00') {
      try {
        trendingDateTime = DateTime.parse(trendingDateTimeStr);
      } catch (_) {}
    }

    return GifModel(
      id: json['id']?.toString(),
      url: (original?['url'] ?? downsized?['url'])?.toString(),
      stillUrl: still?['url']?.toString(),
      title: (json['title']?.toString() ?? 'GIF'),
      username: username,
      userDisplayName: userDisplayName,
      userAvatarUrl: userAvatarUrl,
      analyticsOnLoad: onload,
      analyticsOnClick: onclick,
      width: int.tryParse(
        (downsized?['width'] ?? original?['width'] ?? '0').toString(),
      ),
      height: int.tryParse(
        (downsized?['height'] ?? original?['height'] ?? '0').toString(),
      ),
      size: int.tryParse(
        (downsized?['size'] ?? original?['size'] ?? '0').toString(),
      ),
      trendingDateTime: trendingDateTime,
      rating: json['rating']?.toString(),
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'stillUrl': stillUrl,
    'title': title,
    'username': username,
    'userDisplayName': userDisplayName,
    'userAvatarUrl': userAvatarUrl,
    'analyticsOnLoad': analyticsOnLoad,
    'analyticsOnClick': analyticsOnClick,
    'width': width,
    'height': height,
    'size': size,
    'trendingDateTime': trendingDateTime?.toIso8601String(),
    'rating': rating,
    'tags': tags,
  };

  GifModel copyWith({
    String? id,
    String? url,
    String? stillUrl,
    String? title,
    String? username,
    String? userDisplayName,
    String? userAvatarUrl,
    String? analyticsOnLoad,
    String? analyticsOnClick,
    int? width,
    int? height,
    int? size,
    DateTime? trendingDateTime,
    String? rating,
    List<String>? tags,
  }) {
    return GifModel(
      id: id ?? this.id,
      url: url ?? this.url,
      stillUrl: stillUrl ?? this.stillUrl,
      title: title ?? this.title,
      username: username ?? this.username,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      analyticsOnLoad: analyticsOnLoad ?? this.analyticsOnLoad,
      analyticsOnClick: analyticsOnClick ?? this.analyticsOnClick,
      width: width ?? this.width,
      height: height ?? this.height,
      size: size ?? this.size,
      trendingDateTime: trendingDateTime ?? this.trendingDateTime,
      rating: rating ?? this.rating,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
    id,
    url,
    stillUrl,
    title,
    username,
    userDisplayName,
    userAvatarUrl,
    analyticsOnLoad,
    analyticsOnClick,
    width,
    height,
    size,
    trendingDateTime,
    rating,
    tags,
  ];
}
