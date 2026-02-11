import 'package:dio/dio.dart';
import 'package:mobile/data/services/api_service.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final ApiService api;

  NotificationRepository(this.api);

  /// Récupérer toutes les notifications pour un utilisateur
  Future<List<NotificationModel>> fetchNotifications(String userId) async {
    final response = await api.get('/api/notifications');

    final data = response['data'] as List;
    return data.map((e) => NotificationModel.fromJson(e)).toList();
  }

  /// Marquer une notification comme lue
  Future<bool> markAsRead(String notificationId) async {
    try {
      await api.put('/api/notifications/$notificationId/read');
      return true;
    } catch (e) {
      return false;
    }
  }


  /// ================== SEND REPORT ==================
  Future<void> sendReport({
    required String note,
    Map<String, dynamic>? payload,
  }) async {
    try {
      await api.post(
        '/api/notifications/report',
        {
          "type": "signalement",
          "note": note,
          "payload": payload ?? {},
        },
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? "Erreur lors de l'envoi du signalement",
      );
    }
  }
}
