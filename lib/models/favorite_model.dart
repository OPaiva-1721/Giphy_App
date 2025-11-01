import 'package:equatable/equatable.dart';
import 'gif_model.dart';

/// Modelo de favorito
class FavoriteModel extends Equatable {
  final String id;
  final GifModel gif;
  final DateTime addedAt;
  final List<String> collectionIds;
  final String? note;

  const FavoriteModel({
    required this.id,
    required this.gif,
    required this.addedAt,
    this.collectionIds = const [],
    this.note,
  });

  /// Converte recursivamente Map<dynamic, dynamic> para Map<String, dynamic>
  static Map<String, dynamic> _convertMapRecursive(dynamic value) {
    if (value is Map) {
      return value.map(
        (key, val) => MapEntry(
          key.toString(),
          val is Map ? _convertMapRecursive(val) : val,
        ),
      );
    }
    throw Exception('Valor não é um Map');
  }

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    // Converte o objeto gif que pode vir como Map<dynamic, dynamic>
    final gifJson = json['gif'];
    Map<String, dynamic> gifMap;
    if (gifJson is Map) {
      // Converte recursivamente todos os Maps aninhados
      gifMap = _convertMapRecursive(gifJson);
    } else {
      throw Exception('gif deve ser um Map');
    }

    return FavoriteModel(
      id: json['id'] as String,
      gif: GifModel.fromJson(gifMap),
      addedAt: DateTime.parse(json['addedAt'] as String),
      collectionIds: (json['collectionIds'] as List?)?.cast<String>() ?? [],
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'gif': gif.toJson(),
    'addedAt': addedAt.toIso8601String(),
    'collectionIds': collectionIds,
    'note': note,
  };

  FavoriteModel copyWith({
    String? id,
    GifModel? gif,
    DateTime? addedAt,
    List<String>? collectionIds,
    String? note,
  }) {
    return FavoriteModel(
      id: id ?? this.id,
      gif: gif ?? this.gif,
      addedAt: addedAt ?? this.addedAt,
      collectionIds: collectionIds ?? this.collectionIds,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [id, gif, addedAt, collectionIds, note];
}
