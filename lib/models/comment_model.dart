import 'package:equatable/equatable.dart';

/// Modelo de comentário
class CommentModel extends Equatable {
  final String id;
  final String gifId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String text;
  final DateTime createdAt;
  final int likes;
  final List<String> likedBy;
  
  const CommentModel({
    required this.id,
    required this.gifId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.text,
    required this.createdAt,
    this.likes = 0,
    this.likedBy = const [],
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      gifId: json['gifId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userPhotoUrl: json['userPhotoUrl'] as String?,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      likes: json['likes'] as int? ?? 0,
      likedBy: (json['likedBy'] as List?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'gifId': gifId,
    'userId': userId,
    'userName': userName,
    'userPhotoUrl': userPhotoUrl,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
    'likes': likes,
    'likedBy': likedBy,
  };

  CommentModel copyWith({
    String? id,
    String? gifId,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    String? text,
    DateTime? createdAt,
    int? likes,
    List<String>? likedBy,
  }) {
    return CommentModel(
      id: id ?? this.id,
      gifId: gifId ?? this.gifId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
    );
  }

  @override
  List<Object?> get props => [
    id,
    gifId,
    userId,
    userName,
    userPhotoUrl,
    text,
    createdAt,
    likes,
    likedBy,
  ];
}

