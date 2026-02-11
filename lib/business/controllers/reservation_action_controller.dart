import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/business/states/reservation_state.dart';
import 'package:mobile/data/models/reservation_model.dart';
import 'package:mobile/data/repositories/reservation_repository.dart';
import 'package:mobile/data/services/tracking_token_storage.dart';
import 'reservation_list_controller.dart';

class ReservationActionController
    extends StateNotifier<ReservationActionState> {
  final ReservationRepository repository;
  final ReservationListController reservationListController;

  ReservationActionController({
    required this.repository,
    required this.reservationListController,
  })
    : super(const ReservationActionState());

  // ---------------------------------------------------------------------------
  // CREATE RESERVATION
  // ---------------------------------------------------------------------------
  Future<ReservationModel> createReservation({
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
      state = state.copyWith(isLoading: true, error: null);

      final data = await repository.createReservation(
        bienId: bienId,
        userId: userId,
        ownerId: ownerId,
        clientName: clientName,
        clientEmail: clientEmail,
        clientPhone: clientPhone,
        category: category,
        transactionType: transactionType,
        reservationType: reservationType,
        price: price,
        startDate: startDate,
        endDate: endDate,
        visitDate: visitDate,
        message: message,
      );

      state = state.copyWith(isLoading: false);

      // 🔥 Enregistrer le trackingToken localement
      final token = data['tracking_token'] as String?;
      if (token != null) {
        await TrackingTokenStorage.saveToken(token);
      }

      // Rafraîchir les réservations en mémoire
      await reservationListController.fetchReservations(
        userId: userId,
        ownerId: ownerId,
        trackingToken: token,
      );

      return ReservationModel.fromJson(data['reservation']);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}
