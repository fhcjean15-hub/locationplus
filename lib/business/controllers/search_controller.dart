import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/business/states/search_state.dart';
import 'package:mobile/data/models/search_model.dart';
import 'package:mobile/data/providers/api_providers.dart';
import 'package:mobile/data/repositories/search_repository.dart';
import 'package:mobile/data/services/api_service.dart';

/// ================= PROVIDER =================
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final api = ref.read(apiServiceProvider); // ton ApiService déjà configuré
  return SearchRepository(api);
});

final searchControllerProvider =
    StateNotifierProvider<SearchController, SearchState>((ref) {
  final repo = ref.watch(searchRepositoryProvider);
  return SearchController(repo);
});

class SearchController extends StateNotifier<SearchState> {
  final SearchRepository repository;

  SearchController(this.repository) : super(SearchState.initial());

  /// Met à jour le mot-clé de recherche
  void updateQuery(String query) {
    state = state.copyWith(query: query);
  }

  /// Met à jour les filtres dynamiques
  void updateFilters(Map<String, dynamic> filters) {
    state = state.copyWith(filters: filters);
  }

  /// Ajouter ou modifier un filtre individuel
  void setFilter(String key, dynamic value) {
    final newFilters = Map<String, dynamic>.from(state.filters);
    newFilters[key] = value;
    state = state.copyWith(filters: newFilters);
  }

  /// Supprimer un filtre
  void removeFilter(String key) {
    final newFilters = Map<String, dynamic>.from(state.filters);
    newFilters.remove(key);
    state = state.copyWith(filters: newFilters);
  }

  /// Effectuer la recherche
  Future<void> search() async {
    if (state.query.isEmpty) {
      state = state.copyWith(results: [], error: null);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await repository.search(
        query: state.query,
        filters: state.filters,
      );

      state = state.copyWith(results: results, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Réinitialiser les résultats et filtres
  void clear() {
    state = SearchState.initial();
  }
}
