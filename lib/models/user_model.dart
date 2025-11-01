import 'package:equatable/equatable.dart';

/// Modelo de usuário
class UserModel extends Equatable {
  final String id;
  final String? name;
  final String? email;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isPremium;
  final int level;
  final int totalPoints;
  final int currentLevelPoints;
  final int pointsToNextLevel;
  
  const UserModel({
    required this.id,
    this.name,
    this.email,
    this.photoUrl,
    required this.createdAt,
    this.lastLoginAt,
    this.isPremium = false,
    this.level = 1,
    this.totalPoints = 0,
    this.currentLevelPoints = 0,
    this.pointsToNextLevel = 100,
  });

  factory UserModel.empty() {
    return UserModel(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Convidado',
      createdAt: DateTime.now(),
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt'] as String) 
          : null,
      isPremium: json['isPremium'] as bool? ?? false,
      level: json['level'] as int? ?? 1,
      totalPoints: json['totalPoints'] as int? ?? 0,
      currentLevelPoints: json['currentLevelPoints'] as int? ?? 0,
      pointsToNextLevel: json['pointsToNextLevel'] as int? ?? 100,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'photoUrl': photoUrl,
    'createdAt': createdAt.toIso8601String(),
    'lastLoginAt': lastLoginAt?.toIso8601String(),
    'isPremium': isPremium,
    'level': level,
    'totalPoints': totalPoints,
    'currentLevelPoints': currentLevelPoints,
    'pointsToNextLevel': pointsToNextLevel,
  };

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isPremium,
    int? level,
    int? totalPoints,
    int? currentLevelPoints,
    int? pointsToNextLevel,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isPremium: isPremium ?? this.isPremium,
      level: level ?? this.level,
      totalPoints: totalPoints ?? this.totalPoints,
      currentLevelPoints: currentLevelPoints ?? this.currentLevelPoints,
      pointsToNextLevel: pointsToNextLevel ?? this.pointsToNextLevel,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    photoUrl,
    createdAt,
    lastLoginAt,
    isPremium,
    level,
    totalPoints,
    currentLevelPoints,
    pointsToNextLevel,
  ];
}

