import 'package:equatable/equatable.dart';

/// Modelo de histórico de busca
class SearchHistoryModel extends Equatable {
  final String id;
  final String query;
  final DateTime searchedAt;
  final int resultCount;
  
  const SearchHistoryModel({
    required this.id,
    required this.query,
    required this.searchedAt,
    this.resultCount = 0,
  });

  factory SearchHistoryModel.fromJson(Map<String, dynamic> json) {
    return SearchHistoryModel(
      id: json['id'] as String,
      query: json['query'] as String,
      searchedAt: DateTime.parse(json['searchedAt'] as String),
      resultCount: json['resultCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'query': query,
    'searchedAt': searchedAt.toIso8601String(),
    'resultCount': resultCount,
  };

  @override
  List<Object?> get props => [id, query, searchedAt, resultCount];
}

