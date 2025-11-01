import 'package:equatable/equatable.dart';

/// Modelo de estatísticas do usuário
class UserStatsModel extends Equatable {
  final int gifsViewed;
  final int gifsShared;
  final int gifsFavorited;
  final int collectionsCreated;
  final int commentsPosted;
  final int daysStreak;
  final DateTime? lastActiveDate;
  final int totalPoints;
  final Map<String, int> categoryViews;
  final List<String> unlockedAchievements;
  
  const UserStatsModel({
    this.gifsViewed = 0,
    this.gifsShared = 0,
    this.gifsFavorited = 0,
    this.collectionsCreated = 0,
    this.commentsPosted = 0,
    this.daysStreak = 0,
    this.lastActiveDate,
    this.totalPoints = 0,
    this.categoryViews = const {},
    this.unlockedAchievements = const [],
  });

  factory UserStatsModel.empty() {
    return const UserStatsModel();
  }

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      gifsViewed: json['gifsViewed'] as int? ?? 0,
      gifsShared: json['gifsShared'] as int? ?? 0,
      gifsFavorited: json['gifsFavorited'] as int? ?? 0,
      collectionsCreated: json['collectionsCreated'] as int? ?? 0,
      commentsPosted: json['commentsPosted'] as int? ?? 0,
      daysStreak: json['daysStreak'] as int? ?? 0,
      lastActiveDate: json['lastActiveDate'] != null
          ? DateTime.parse(json['lastActiveDate'] as String)
          : null,
      totalPoints: json['totalPoints'] as int? ?? 0,
      categoryViews: (json['categoryViews'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as int)) ?? {},
      unlockedAchievements: (json['unlockedAchievements'] as List?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'gifsViewed': gifsViewed,
    'gifsShared': gifsShared,
    'gifsFavorited': gifsFavorited,
    'collectionsCreated': collectionsCreated,
    'commentsPosted': commentsPosted,
    'daysStreak': daysStreak,
    'lastActiveDate': lastActiveDate?.toIso8601String(),
    'totalPoints': totalPoints,
    'categoryViews': categoryViews,
    'unlockedAchievements': unlockedAchievements,
  };

  UserStatsModel copyWith({
    int? gifsViewed,
    int? gifsShared,
    int? gifsFavorited,
    int? collectionsCreated,
    int? commentsPosted,
    int? daysStreak,
    DateTime? lastActiveDate,
    int? totalPoints,
    Map<String, int>? categoryViews,
    List<String>? unlockedAchievements,
  }) {
    return UserStatsModel(
      gifsViewed: gifsViewed ?? this.gifsViewed,
      gifsShared: gifsShared ?? this.gifsShared,
      gifsFavorited: gifsFavorited ?? this.gifsFavorited,
      collectionsCreated: collectionsCreated ?? this.collectionsCreated,
      commentsPosted: commentsPosted ?? this.commentsPosted,
      daysStreak: daysStreak ?? this.daysStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      totalPoints: totalPoints ?? this.totalPoints,
      categoryViews: categoryViews ?? this.categoryViews,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
    );
  }

  @override
  List<Object?> get props => [
    gifsViewed,
    gifsShared,
    gifsFavorited,
    collectionsCreated,
    commentsPosted,
    daysStreak,
    lastActiveDate,
    totalPoints,
    categoryViews,
    unlockedAchievements,
  ];
}

