import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/business/controllers/notification_list_controller.dart';
import 'package:mobile/data/repositories/notification_repository.dart';
import 'package:mobile/data/providers/api_providers.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final api = ref.read(apiServiceProvider);
  return NotificationRepository(api);
});

final notificationListControllerProvider =
    StateNotifierProvider<NotificationListController, NotificationListState>((ref) {
  final repo = ref.read(notificationRepositoryProvider);
  return NotificationListController(repo);
});
