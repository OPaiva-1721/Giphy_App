import 'package:equatable/equatable.dart';

/// Tipo de reação
enum ReactionType {
  like,
  love,
  laugh,
  wow,
  sad,
  angry,
}

/// Modelo de reação
class ReactionModel extends Equatable {
  final String id;
  final String gifId;
  final String userId;
  final ReactionType type;
  final DateTime createdAt;
  
  const ReactionModel({
    required this.id,
    required this.gifId,
    required this.userId,
    required this.type,
    required this.createdAt,
  });

  factory ReactionModel.fromJson(Map<String, dynamic> json) {
    return ReactionModel(
      id: json['id'] as String,
      gifId: json['gifId'] as String,
      userId: json['userId'] as String,
      type: ReactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReactionType.like,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'gifId': gifId,
    'userId': userId,
    'type': type.name,
    'createdAt': createdAt.toIso8601String(),
  };

  String get emoji {
    switch (type) {
      case ReactionType.like:
        return '👍';
      case ReactionType.love:
        return '❤️';
      case ReactionType.laugh:
        return '😂';
      case ReactionType.wow:
        return '😮';
      case ReactionType.sad:
        return '😢';
      case ReactionType.angry:
        return '😠';
    }
  }

  @override
  List<Object?> get props => [id, gifId, userId, type, createdAt];
}

