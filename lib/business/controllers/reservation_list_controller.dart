import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/data/models/reservation_model.dart';
import 'package:mobile/data/repositories/reservation_repository.dart';

class ReservationListController
    extends StateNotifier<AsyncValue<List<ReservationModel>>> {
  final ReservationRepository repository;

  ReservationListController(this.repository)
      : super(const AsyncValue.loading());

  // ---------------------------------------------------------------------------
  // FETCH RESERVATIONS
  // ---------------------------------------------------------------------------
  Future<void> fetchReservations({
    String? userId,
    String? ownerId,
    String? trackingToken,
  }) async {
    try {
      state = const AsyncValue.loading();
      final reservations = await repository.getReservations(
        userId: userId,
        ownerId: ownerId,
        trackingToken: trackingToken,
      );
      state = AsyncValue.data(reservations);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }


    Future<void> fetchGuestReservations({
      String? userId,
      String? ownerId,
      String? trackingToken,
    }) async {
      try {
        state = const AsyncValue.loading();
        final reservations = await repository.getGuestReservations(
          userId: userId,
          ownerId: ownerId,
          trackingToken: trackingToken,
        );
        state = AsyncValue.data(reservations);
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    }

  // ---------------------------------------------------------------------------
  // DELETE RESERVATION
  // ---------------------------------------------------------------------------
  Future<bool> deleteReservation(String id) async {
    try {
      final success = await repository.deleteReservation(id);
      if (success) {
        await fetchReservations();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // UPDATE STATUS
  // ---------------------------------------------------------------------------
  Future<void> updateStatus(String id, String status) async {
    try {
      await repository.updateStatus(id, status);
      await fetchReservations();
    } catch (_) {}
  }
}







// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile/data/repositories/reservation_repository.dart';
// import '../../data/models/reservation_model.dart';


// class ReservationController
//     extends StateNotifier<AsyncValue<List<ReservationModel>>> {
//   final ReservationRepository repository;

//   ReservationController(this.repository) : super(const AsyncValue.loading());

//   // ---------------------------------------------------------------------------
//   // FETCH RESERVATIONS
//   // ---------------------------------------------------------------------------
//   Future<void> fetchReservations({
//     String? userId,
//     String? ownerId,
//     String? trackingToken,
//   }) async {
//     try {
//       state = const AsyncValue.loading();
//       final reservations = await repository.getReservations(
//         userId: userId,
//         ownerId: ownerId,
//         trackingToken: trackingToken,
//       );
//       state = AsyncValue.data(reservations);
//     } catch (e, st) {
//       state = AsyncValue.error(e, st);
//     }
//   }

//   // ---------------------------------------------------------------------------
//   // CREATE RESERVATION
//   // ---------------------------------------------------------------------------
//   Future<ReservationModel?> createReservation({
//     required int bienId,
//     String? userId,
//     required String ownerId,
//     required String clientName,
//     required String clientEmail,
//     required String clientPhone,
//     required String category,
//     required String transactionType,
//     required String reservationType,
//     required double price,
//     DateTime? startDate,
//     DateTime? endDate,
//     DateTime? visitDate,
//     String? message,
//   }) async {
//     try {
//       final data = await repository.createReservation(
//         bienId: bienId,
//         userId: userId,
//         ownerId: ownerId,
//         clientName: clientName,
//         clientEmail: clientEmail,
//         clientPhone: clientPhone,
//         category: category,
//         transactionType: transactionType,
//         reservationType: reservationType,
//         price: price,
//         startDate: startDate,
//         endDate: endDate,
//         visitDate: visitDate,
//         message: message,
//       );

//       state = state.copyWith(isLoading: true, error: null);

//       final reservation = ReservationModel.fromJson(data['reservation']);
//       await fetchReservations(
//         userId: userId,
//         ownerId: ownerId,
//         trackingToken: data['tracking_token'],
//       );

//       state = state.copyWith(isLoading: false);
      
//       return reservation;
//     } catch (e) {
//       print("❌ Erreur création réservation: $e");
//       state = state.copyWith(
//         isLoading: false,
//         error: e.toString(),
//       );
//       rethrow;
//       return null;
//     }
//   }

//   // ---------------------------------------------------------------------------
//   // DELETE RESERVATION
//   // ---------------------------------------------------------------------------
//   Future<bool> deleteReservation(String id) async {
//     try {
//       final success = await repository.deleteReservation(id);
//       if (success) {
//         await fetchReservations();
//       }
//       return success;
//     } catch (e) {
//       print("❌ Erreur suppression réservation: $e");
//       return false;
//     }
//   }

//   // ---------------------------------------------------------------------------
//   // UPDATE STATUS
//   // ---------------------------------------------------------------------------
//   Future<void> updateStatus(String id, String status) async {
//     try {
//       await repository.updateStatus(id, status);
//       await fetchReservations();
//     } catch (e) {
//       print("❌ Erreur update status: $e");
//     }
//   }
// }




