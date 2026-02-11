import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/business/providers/auth_controller_provider.dart';
import 'package:mobile/business/providers/notification_provider.dart';
import 'package:mobile/data/models/notification_model.dart';
import 'package:mobile/presentation/theme/colors.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    Future.microtask(() {
      final authState = ref.read(authControllerProvider);

      if (authState.user != null) {
        ref
            .read(notificationListControllerProvider.notifier)
            .fetchNotifications(authState.user!.id);
      }
    });
  }

  Future<void> _refresh() async {
    if (_userId != null) {
      await ref
          .read(notificationListControllerProvider.notifier)
          .fetchNotifications(_userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(notificationListControllerProvider);

    // Regroupement par type
    final Map<String, List<NotificationModel>> grouped = {};
    for (var notif in notifState.notifications) {
      grouped.putIfAbsent(notif.type, () => []).add(notif);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.textLight,
      ),
      body: notifState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifState.error != null
          ? Center(child: Text('Erreur : ${notifState.error}'))
          : RefreshIndicator(
              onRefresh: _refresh,
              child: grouped.isEmpty
                  ? const Center(child: Text('Aucune notification'))
                  : ListView(
                      padding: const EdgeInsets.all(12),
                      children: grouped.entries.expand((entry) {
                        final type = entry.key;
                        final notifs = entry.value;

                        return [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              _typeLabel(type),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          ...notifs.map(
                            (n) => _NotificationCard(notification: n),
                          ),
                        ];
                      }).toList(),
                    ),
            ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'paiement':
        return 'Paiements';
      case 'demande':
        return 'Demandes';
      case 'signalement':
        return 'Signalements';
      case 'admin_action':
        return 'Actions administratives';
      case 'compte_validé':
        return 'Compte validé';
      case 'compte_rejeté':
        return 'Compte rejeté';
      default:
        return 'Autres';
    }
  }
}

class _NotificationCard extends ConsumerWidget {
  final NotificationModel notification;

  const _NotificationCard({required this.notification});

  Color _getColorByType(String type) {
    switch (type) {
      case 'paiement':
        return Colors.green;
      case 'demande':
        return Colors.blue;
      case 'signalement':
        return Colors.red;
      case 'admin_action':
        return Colors.orange;
      case 'compte_validé':
        return Colors.greenAccent;
      case 'compte_rejeté':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconByType(String type) {
    switch (type) {
      case 'paiement':
        return Icons.payment;
      case 'demande':
        return Icons.list_alt;
      case 'signalement':
        return Icons.report;
      case 'admin_action':
        return Icons.admin_panel_settings;
      case 'compte_validé':
        return Icons.check_circle;
      case 'compte_rejeté':
        return Icons.cancel;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRead = notification.read;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () async {
          if (!isRead) {
            await ref
                .read(notificationListControllerProvider.notifier)
                .markNotificationAsRead(notification.id);
          }
        },
        leading: CircleAvatar(
          backgroundColor: _getColorByType(notification.type),
          child: Icon(_getIconByType(notification.type), color: Colors.white),
        ),
        title: Text(
          notification.message,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(
          notification.formattedDate,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: isRead
            ? null
            : const Icon(Icons.circle, color: Colors.red, size: 10),
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class NotificationsScreen extends StatelessWidget {
//   const NotificationsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,

//       appBar: AppBar(
//         title: const Text(
//           "Notifications",
//           style: TextStyle(fontWeight: FontWeight.w600),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0.2,
//       ),

//       body: FutureBuilder<List<NotificationItem>>(
//         future: fakeNotifications(), // Simule un chargement API
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return _loadingSkeleton();
//           }

//           final items = snapshot.data!;

//           if (items.isEmpty) {
//             return _emptyView();
//           }

//           return ListView.separated(
//             padding: const EdgeInsets.all(16),
//             itemCount: items.length,
//             separatorBuilder: (_, __) => const SizedBox(height: 12),
//             itemBuilder: (context, index) {
//               return _buildNotificationCard(items[index]);
//             },
//           );
//         },
//       ),
//     );
//   }

//   // --- UI COMPONENTS --------------------------------------------------------

//   Widget _buildNotificationCard(NotificationItem item) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: item.isRead ? Colors.grey.shade100 : Colors.blue.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: item.isRead ? Colors.grey.shade200 : Colors.blue.shade100,
//         ),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(
//             item.icon,
//             size: 28,
//             color: item.isRead ? Colors.grey : Colors.blueAccent,
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   item.title,
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                     color: item.isRead ? Colors.black87 : Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   item.description,
//                   style: TextStyle(
//                     fontSize: 13.5,
//                     color: item.isRead ? Colors.grey.shade600 : Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   item.time,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey.shade500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // --- LOADING SKELETON -----------------------------------------------------

//   Widget _loadingSkeleton() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: 4,
//       itemBuilder: (_, __) {
//         return Container(
//           margin: const EdgeInsets.only(bottom: 14),
//           height: 70,
//           decoration: BoxDecoration(
//             color: Colors.grey.shade200,
//             borderRadius: BorderRadius.circular(12),
//           ),
//         );
//       },
//     );
//   }

//   // --- EMPTY VIEW -----------------------------------------------------------

//   Widget _emptyView() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: const [
//             Icon(Icons.notifications_none, size: 60, color: Colors.grey),
//             SizedBox(height: 16),
//             Text(
//               "Aucune notification pour le moment",
//               style: TextStyle(fontSize: 16, color: Colors.grey),
//               textAlign: TextAlign.center,
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// // -----------------------------------------------------------------------------
// // EXAMPLE DATA MODEL & FAKE API
// // -----------------------------------------------------------------------------

// class NotificationItem {
//   final String title;
//   final String description;
//   final String time;
//   final IconData icon;
//   final bool isRead;

//   NotificationItem({
//     required this.title,
//     required this.description,
//     required this.time,
//     required this.icon,
//     this.isRead = false,
//   });
// }

// Future<List<NotificationItem>> fakeNotifications() async {
//   await Future.delayed(const Duration(seconds: 2)); // simulate network

//   return [
//     NotificationItem(
//       title: "Nouveau message",
//       description: "Vous avez reçu un message concernant votre annonce.",
//       time: "Il y a 2 min",
//       icon: Icons.mail,
//       isRead: false,
//     ),
//     NotificationItem(
//       title: "Annonce approuvée",
//       description: "Votre annonce 'Appartement 3 pièces' est maintenant en ligne.",
//       time: "Il y a 1 heure",
//       icon: Icons.check_circle,
//       isRead: true,
//     ),
//     NotificationItem(
//       title: "Réservation confirmée",
//       description: "Votre réservation d'hôtel pour le 24 déc. est confirmée.",
//       time: "Il y a 3 heures",
//       icon: Icons.hotel,
//       isRead: false,
//     ),
//     NotificationItem(
//       title: "Paiement reçu",
//       description: "Votre paiement de 120 000 F a été validé.",
//       time: "Hier",
//       icon: Icons.payment,
//       isRead: true,
//     ),
//   ];
// }
