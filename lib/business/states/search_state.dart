import 'package:mobile/data/models/search_model.dart';

class SearchState {
  final bool isLoading;
  final String query;
  final List<SearchResultModel> results;
  final Map<String, dynamic> filters;
  final String? error;

  SearchState({
    required this.isLoading,
    required this.query,
    required this.results,
    required this.filters,
    this.error,
  });

  factory SearchState.initial() {
    return SearchState(
      isLoading: false,
      query: '',
      results: [],
      filters: {},
      error: null,
    );
  }

  SearchState copyWith({
    bool? isLoading,
    String? query,
    List<SearchResultModel>? results,
    Map<String, dynamic>? filters,
    String? error,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
      results: results ?? this.results,
      filters: filters ?? this.filters,
      error: error,
    );
  }
}
