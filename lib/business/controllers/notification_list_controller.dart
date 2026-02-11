import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/data/models/notification_model.dart';
import 'package:mobile/data/repositories/notification_repository.dart';

class NotificationListState {
  final bool isLoading;
  final bool isSendingReport;
  final List<NotificationModel> notifications;
  final String? error;

  NotificationListState({
    required this.isLoading,
    required this.notifications,
    this.isSendingReport = false,
    this.error,
  });

  NotificationListState copyWith({
    bool? isLoading,
    bool? isSendingReport,
    List<NotificationModel>? notifications,
    String? error,
  }) {
    return NotificationListState(
      isLoading: isLoading ?? this.isLoading,
      isSendingReport: isSendingReport ?? this.isSendingReport,
      notifications: notifications ?? this.notifications,
      error: error,
    );
  }
}

class NotificationListController extends StateNotifier<NotificationListState> {
  final NotificationRepository repo;

  NotificationListController(this.repo)
      : super(NotificationListState(isLoading: false, notifications: []));

  /// Récupérer les notifications pour un utilisateur
  Future<void> fetchNotifications(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final list = await repo.fetchNotifications(userId);
      state = state.copyWith(isLoading: false, notifications: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Marquer une notification comme lue
  Future<void> markNotificationAsRead(String notificationId) async {
    final ok = await repo.markAsRead(notificationId);

    if (ok) {
      final updatedList = state.notifications.map((n) {
        if (n.id == notificationId) {
          return NotificationModel(
            id: n.id,
            type: n.type,
            payload: n.payload,
            read: true,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();

      state = state.copyWith(notifications: updatedList);
    }
  }

  /// ================== SEND REPORT ==================
  Future<bool> sendReport({
    required String note,
    Map<String, dynamic>? payload,
  }) async {
    state = state.copyWith(isSendingReport: true, error: null);

    try {
      await repo.sendReport(
        note: note,
        payload: payload,
      );

      state = state.copyWith(isSendingReport: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSendingReport: false,
        error: e.toString(),
      );
      return false;
    }
  }


  /// Filtrer selon le type
  List<NotificationModel> getByType(String type) {
    return state.notifications.where((n) => n.type == type).toList();
  }


  
}
