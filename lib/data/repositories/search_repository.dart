import 'package:mobile/data/models/search_model.dart';
import 'package:mobile/data/services/api_service.dart';

class SearchRepository {
  final ApiService api;

  SearchRepository(this.api);

  /// Recherche globale avec filtres dynamiques
  Future<List<SearchResultModel>> search({
    required String query,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final response = await api.get(
        "/api/search",
        queryParameters: {"q": query, ...?filters},
      );

      final List data = response['data'] ?? [];
      print('data: $data');
      return data.map((e) => SearchResultModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Erreur lors de la recherche");
    }
  }
}
