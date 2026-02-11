import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../models/reservation_model.dart';

class ReservationRepository {
  final ApiService api;

  ReservationRepository(this.api);

  // ---------------------------------------------------------------------------
  // CREATE RESERVATION
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> createReservation({
    required int bienId,
    String? userId,
    required String ownerId,
    required String clientName,
    required String clientEmail,
    required String clientPhone,
    required String category,
    required String transactionType,
    required String reservationType,
    required double price,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? visitDate,
    String? message,
  }) async {
    try {
      final data = {
        'bien_id': bienId,
        'user_id': userId,
        'owner_id': ownerId,
        'client_name': clientName,
        'client_email': clientEmail,
        'client_phone': clientPhone,
        'category': category,
        'transaction_type': transactionType,
        'reservation_type': reservationType,
        'price': price,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        if (visitDate != null) 'visit_date': visitDate.toIso8601String(),
        if (message != null) 'message': message,
      };

      final response = await api.post('/api/reservations', data);

      print("$response");

      return Map<String, dynamic>.from(response);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // GET RESERVATIONS (user / owner / guest)
  // ---------------------------------------------------------------------------
  Future<List<ReservationModel>> getReservations({
    String? userId,
    String? ownerId,
    String? trackingToken,
  }) async {
    try {
      final response = await api.get(
        '/api/reservations',
        queryParameters: {
          if (userId != null) 'user_id': userId,
          if (ownerId != null) 'owner_id': ownerId,
          if (trackingToken != null) 'tracking_token': trackingToken,
        },
      );

      final List data = response['data'] ?? [];
      print('data: $data');
      return data.map((e) => ReservationModel.fromJson(e)).toList();
    } on DioException catch (e) {
      _handleDioError(e);
      return [];
    }
  }

  Future<List<ReservationModel>> getGuestReservations({
    String? userId,
    String? ownerId,
    String? trackingToken,
  }) async {
    try {
      final response = await api.get(
        '/api/reservations/guest',
        queryParameters: {
          if (userId != null) 'user_id': userId,
          if (ownerId != null) 'owner_id': ownerId,
          if (trackingToken != null) 'tracking_token': trackingToken,
        },
      );

      final List data = response['data'] ?? [];
      return data.map((e) => ReservationModel.fromJson(e)).toList();
    } on DioException catch (e) {
      _handleDioError(e);
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // GET RESERVATION DETAIL
  // ---------------------------------------------------------------------------
  Future<ReservationModel> getReservation(String id) async {
    try {
      final response = await api.get('/api/reservations/$id');
      return ReservationModel.fromJson(response['data']);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // UPDATE STATUS
  // ---------------------------------------------------------------------------
  Future<ReservationModel> updateStatus(String id, String status) async {
    try {
      final response = await api.put(
        '/api/reservations/$id',
        data: {'status': status},
      );
      return ReservationModel.fromJson(response['data']);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // DELETE RESERVATION
  // ---------------------------------------------------------------------------
  Future<bool> deleteReservation(String id) async {
    try {
      await api.delete('/api/reservations/$id');
      return true;
    } on DioException catch (e) {
      _handleDioError(e);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // ERROR HANDLING
  // ---------------------------------------------------------------------------
  Never _handleDioError(DioException e) {
    print("🔥 RESERVATION API ERROR");
    print("➡ STATUS : ${e.response?.statusCode}");
    print("➡ DATA   : ${e.response?.data}");
    print("➡ MSG    : ${e.message}");

    final data = e.response?.data;

    if (data is Map && data['errors'] is Map<String, dynamic>) {
      final errors = data['errors'] as Map<String, dynamic>;
      final firstError = errors.values.first;
      throw Exception(
        firstError is List ? firstError.first : firstError.toString(),
      );
    }

    if (data is Map && data['message'] != null) {
      throw Exception(data['message']);
    }

    if (data is String) {
      throw Exception(data);
    }

    throw Exception("Erreur réseau inconnue");
  }
}






// Nous allons continuer avec """Voici un **résumé opérationnel clair**, orienté **mode opératoire de l’écran `ReservationScreen`** 👇

// ---

// ## 🎯 Décision d’architecture

// 👉 **Écran dédié `ReservationScreen` (et non un modal)**
// C’est le meilleur choix pour :

// * gérer des **formulaires complexes et dynamiques**
// * assurer une **bonne UX** (retour, erreurs, reprise)
// * faciliter l’**évolutivité** (notifications, paiement, admin)

// ---

// ## 🧭 Mode opératoire de `ReservationScreen`

// ### 1️⃣ Point d’entrée

// Depuis une carte de bien :

// ```dart
// ReservationScreen(bien: BienModel)
// ```

// ---

// ### 2️⃣ Structure de l’écran

// ```
// AppBar
// ────────────────
// Résumé du bien
// ────────────────
// Formulaire client (commun)
// ────────────────
// Formulaire spécifique au bien
// ────────────────
// Bouton "Confirmer la réservation"
// ```

// ---

// ### 3️⃣ Données affichées en haut (Résumé du bien)

// * Titre
// * Catégorie
// * Prix
// * Type de transaction (Achat / Location)

// 👉 **Lecture seule**, sert de contexte

// ---

// ### 4️⃣ Formulaire COMMUN (toujours présent)

// | Champ                | Obligatoire |
// | -------------------- | ----------- |
// | Nom & Prénoms        | ✅           |
// | Email                | ✅           |
// | Téléphone (WhatsApp) | ✅           |

// Ces champs sont **toujours envoyés** à l’API.

// ---

// ### 5️⃣ Formulaire DYNAMIQUE (selon `bien.category`)

// Géré via :

// ```dart
// switch (bien.category)
// ```

// #### 🏠 Immobilier

// * Date de visite
// * Message (optionnel)

// #### 🚗 Véhicule

// * Date début
// * Date fin
// * Lieu de récupération

// #### 🏨 Hôtel / Hébergement

// * Date arrivée
// * Date départ
// * Nombre de personnes

// 👉 Chaque catégorie a **son widget dédié**.

// ---

// ### 6️⃣ Soumission (flow technique)

// 1. Validation des champs
// 2. Appel API `POST /reservations`
// 3. Backend :

//    * stocke la réservation
//    * génère `tracking_token` si invité
//    * envoie Email
//    * prépare WhatsApp
// 4. Front :

//    * stocke `tracking_token` en local
//    * redirige vers **Mes Réservations**

// ---

// ### 7️⃣ Après soumission

// * La réservation apparaît dans **Mes Réservations**
// * Suivi possible :

//   * utilisateur connecté → `user_id`
//   * invité → `tracking_token`

// ---

// ## 🗂 Organisation Flutter recommandée

// ```
// reservation/
//  ├── reservation_screen.dart
//  ├── widgets/
//  │   ├── client_form.dart
//  │   ├── immobilier_form.dart
//  │   ├── vehicule_form.dart
//  │   └── hotel_form.dart
//  ├── reservation_controller.dart
//  └── reservation_repository.dart
// ```

// ---

// ## 🧠 Règle clé à retenir

// > **Le formulaire client est commun,
// > le formulaire métier dépend de la catégorie.**

// ---

// ## ✅ Résultat attendu

// * UX fluide
// * Code lisible
// * Zéro duplication
// * Facile à maintenir
// * Prêt pour paiement / notifications / admin

// ---

// Si tu veux, **prochaine étape logique** :
// 👉 te générer le **squelette complet de `ReservationScreen` Flutter**
// ou
// 👉 commencer par le **controller + repository Flutter**

// Dis-moi 👌 """