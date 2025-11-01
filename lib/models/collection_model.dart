import 'package:equatable/equatable.dart';

/// Modelo de coleção de GIFs
class CollectionModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? coverImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int gifCount;
  final bool isPublic;
  final List<String> gifIds;
  final String? color;
  final String? icon;
  
  const CollectionModel({
    required this.id,
    required this.name,
    this.description,
    this.coverImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.gifCount = 0,
    this.isPublic = false,
    this.gifIds = const [],
    this.color,
    this.icon,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      gifCount: json['gifCount'] as int? ?? 0,
      isPublic: json['isPublic'] as bool? ?? false,
      gifIds: (json['gifIds'] as List?)?.cast<String>() ?? [],
      color: json['color'] as String?,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'coverImageUrl': coverImageUrl,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'gifCount': gifCount,
    'isPublic': isPublic,
    'gifIds': gifIds,
    'color': color,
    'icon': icon,
  };

  CollectionModel copyWith({
    String? id,
    String? name,
    String? description,
    String? coverImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? gifCount,
    bool? isPublic,
    List<String>? gifIds,
    String? color,
    String? icon,
  }) {
    return CollectionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      gifCount: gifCount ?? this.gifCount,
      isPublic: isPublic ?? this.isPublic,
      gifIds: gifIds ?? this.gifIds,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    coverImageUrl,
    createdAt,
    updatedAt,
    gifCount,
    isPublic,
    gifIds,
    color,
    icon,
  ];
}

