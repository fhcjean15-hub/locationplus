import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/business/controllers/reservation_action_controller.dart';
import 'package:mobile/business/states/reservation_state.dart';
import 'package:mobile/data/providers/api_providers.dart';
import 'package:mobile/data/repositories/reservation_repository.dart';
import '../controllers/reservation_list_controller.dart';

// ---------------------------------------------------------------------------
// REPOSITORY
// ---------------------------------------------------------------------------
final reservationRepositoryProvider =
    Provider<ReservationRepository>((ref) {
  final api = ref.read(apiServiceProvider);
  return ReservationRepository(api);
});

// ---------------------------------------------------------------------------
// LIST CONTROLLER
// ---------------------------------------------------------------------------
final reservationListControllerProvider =
    StateNotifierProvider<ReservationListController, AsyncValue<List>>((ref) {
  final repo = ref.read(reservationRepositoryProvider);
  return ReservationListController(repo);
});

// ---------------------------------------------------------------------------
// ACTION CONTROLLER (FORM)
// ---------------------------------------------------------------------------
final reservationActionControllerProvider =
    StateNotifierProvider<ReservationActionController, ReservationActionState>(
        (ref) {
  final repo = ref.read(reservationRepositoryProvider);
  final listController =
      ref.read(reservationListControllerProvider.notifier);
  return ReservationActionController(
    repository: repo,
    reservationListController: listController,
  );
});



// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile/business/controllers/reservation_action_controller.dart';
// import 'package:mobile/business/states/reservation_state.dart';
// import 'package:mobile/data/providers/api_providers.dart';
// import 'package:mobile/data/repositories/reservation_repository.dart';
// import '../controllers/reservation_list_controller.dart';

// // ---------------------------------------------------------------------------
// // REPOSITORY
// // ---------------------------------------------------------------------------
// final reservationRepositoryProvider =
//     Provider<ReservationRepository>((ref) {
//   final api = ref.read(apiServiceProvider);
//   return ReservationRepository(api);
// });

// // ---------------------------------------------------------------------------
// // LIST CONTROLLER
// // ---------------------------------------------------------------------------
// final reservationListControllerProvider =
//     StateNotifierProvider<ReservationListController,
//         AsyncValue<List>>((ref) {
//   final repo = ref.read(reservationRepositoryProvider);
//   return ReservationListController(repo);
// });

// // ---------------------------------------------------------------------------
// // ACTION CONTROLLER (FORM)
// // ---------------------------------------------------------------------------
// final reservationActionControllerProvider =
//     StateNotifierProvider<ReservationActionController,
//         ReservationActionState>((ref) {
//   final repo = ref.read(reservationRepositoryProvider);
//   return ReservationActionController(repo);
// });







// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile/business/controllers/reservation_controller.dart';
// import 'package:mobile/data/models/reservation_model.dart';
// import 'package:mobile/data/providers/api_providers.dart';
// import 'package:mobile/data/repositories/reservation_repository.dart';
// import 'package:mobile/data/services/api_service.dart';


// // ---------------------------------------------------------------------------
// // RESERVATION REPOSITORY
// // ---------------------------------------------------------------------------
// final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
//   final api = ref.read(apiServiceProvider);
//   return ReservationRepository(api);
// });

// // ---------------------------------------------------------------------------
// // RESERVATION CONTROLLER
// // ---------------------------------------------------------------------------
// final reservationControllerProvider =
//     StateNotifierProvider<ReservationController, AsyncValue<List<ReservationModel>>>(
//   (ref) {
//     final repository = ref.read(reservationRepositoryProvider);
//     return ReservationController(repository);
//   },
// );
