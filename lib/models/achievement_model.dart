import 'package:equatable/equatable.dart';

/// Categoria de conquista
enum AchievementCategory {
  viewer,
  collector,
  social,
  creator,
  explorer,
}

/// Raridade da conquista
enum AchievementRarity {
  common,
  rare,
  epic,
  legendary,
}

/// Modelo de conquista
class AchievementModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementCategory category;
  final AchievementRarity rarity;
  final int points;
  final int requirement;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int currentProgress;
  
  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.rarity,
    required this.points,
    required this.requirement,
    this.isUnlocked = false,
    this.unlockedAt,
    this.currentProgress = 0,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      category: AchievementCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => AchievementCategory.viewer,
      ),
      rarity: AchievementRarity.values.firstWhere(
        (e) => e.name == json['rarity'],
        orElse: () => AchievementRarity.common,
      ),
      points: json['points'] as int,
      requirement: json['requirement'] as int,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      currentProgress: json['currentProgress'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'icon': icon,
    'category': category.name,
    'rarity': rarity.name,
    'points': points,
    'requirement': requirement,
    'isUnlocked': isUnlocked,
    'unlockedAt': unlockedAt?.toIso8601String(),
    'currentProgress': currentProgress,
  };

  double get progressPercentage => (currentProgress / requirement).clamp(0.0, 1.0);

  AchievementModel copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    AchievementCategory? category,
    AchievementRarity? rarity,
    int? points,
    int? requirement,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? currentProgress,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      rarity: rarity ?? this.rarity,
      points: points ?? this.points,
      requirement: requirement ?? this.requirement,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      currentProgress: currentProgress ?? this.currentProgress,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    icon,
    category,
    rarity,
    points,
    requirement,
    isUnlocked,
    unlockedAt,
    currentProgress,
  ];
}

