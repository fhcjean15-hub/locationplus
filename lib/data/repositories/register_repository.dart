import 'package:dio/dio.dart';

class RegisterRepository {
  final Dio dio;
  RegisterRepository(this.dio);

  // ----------------------------
  // 1️⃣ RÉCUPÉRER LES CATÉGORIES
  // ----------------------------
  Future<List<dynamic>> getCategories(String type) async {
    // 🔥 Sélectionne la bonne route selon le type
    final endpoint = type == "agent"
        ? "/api/account-categories/agents"
        : "/api/account-categories/agences";

    final res = await dio.get(endpoint);

    final data = res.data["data"];

    print('data: $data');

    return data;
  }


  // ----------------------------
  // 2️⃣ INSCRIPTION AGENT INDÉPENDANT
  // ----------------------------
  Future<void> registerAgent(Map<String, dynamic> payload) async {
    await dio.post("/api/register-agent", data: payload);
  }

  // ----------------------------
  // 3️⃣ INSCRIPTION AGENCE
  // ----------------------------
  Future<void> registerAgence(Map<String, dynamic> payload) async {
    await dio.post("/api/register-agence", data: payload);
  }
}
