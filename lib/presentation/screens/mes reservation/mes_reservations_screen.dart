import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/business/providers/auth_controller_provider.dart';
import 'package:mobile/business/providers/reservation_provider.dart';
import 'package:mobile/core/utils/whatsapp_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mobile/data/models/reservation_model.dart';
import 'package:mobile/presentation/theme/colors.dart';

class MesReservationsScreen extends ConsumerStatefulWidget {
  const MesReservationsScreen({super.key});

  @override
  ConsumerState<MesReservationsScreen> createState() =>
      _MesReservationsScreenState();
}

class _MesReservationsScreenState extends ConsumerState<MesReservationsScreen> {
  String? _trackingToken;
  String? _userId;
  
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final authState = ref.read(authControllerProvider);
    final prefs = await SharedPreferences.getInstance();
    final controller = ref.read(reservationListControllerProvider.notifier);

    // ----------------------------
    // UTILISATEUR CONNECTÉ
    // ----------------------------
    if (authState.user != null) {
      _userId = authState.user!.id;
      print("Yes");

      controller.fetchReservations(
        userId: _userId,
        ownerId: _userId, // 👈 clé du besoin
      );
    }
    // ----------------------------
    // MODE INVITÉ
    // ----------------------------
    else {
      _trackingToken = prefs.getString('tracking_token');

      if (_trackingToken != null) {
        controller.fetchGuestReservations(trackingToken: _trackingToken);
      }
    }
  }

  Future<void> _refresh() async {
    final controller = ref.read(reservationListControllerProvider.notifier);

    if (_userId != null) {
      await controller.fetchReservations(userId: _userId, ownerId: _userId);
    } else if (_trackingToken != null) {
      await controller.fetchGuestReservations(trackingToken: _trackingToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservationsAsync = ref.watch(reservationListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes réservations'),
        backgroundColor: AppColors.textLight,
      ),
      body: reservationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (reservations) {
          if (reservations.isEmpty) {
            return const Center(child: Text('Aucune réservation trouvée'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final reservation = reservations[index];
                return _ReservationCard(reservation: reservation);
              },
            ),
          );
        },
      ),
    );
  }
}




class _ReservationCard extends ConsumerWidget {
  final ReservationModel reservation;

  const _ReservationCard({required this.reservation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bien = reservation.bien;
    
    final baseUrl = "https://api-location-plus.lamadonebenin.com/storage/";

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---------------- IMAGE DU BIEN ----------------
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: bien != null && bien.images.isNotEmpty
                ? Image.network(
                    baseUrl + bien.images.first,
                    height: 180,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 180,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.home, size: 80, color: Colors.white),
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------- TITRE DU BIEN ----------------
                Text(
                  bien?.title ?? 'Bien immobilier',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${reservation.category.toUpperCase()} • ${_translateTransaction(reservation.transactionType)}',
                  style: const TextStyle(color: Colors.grey),
                ),

                const Divider(height: 20),

                // ---------------- MESSAGE PRINCIPAL ----------------
                Text(
                  _buildReservationMessage(),
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),

                if (reservation.message != null &&
                    reservation.message!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    '📝 Message du client :\n"${reservation.message!}"',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // ---------------- CONTACT ----------------
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _contact(reservation.clientPhone),
                      icon: const Icon(Icons.chat),
                      label: const Text('Contacter le client'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Supprimer la réservation',
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final ok = await ref
                            .read(reservationListControllerProvider.notifier)
                            .deleteReservation(reservation.id);

                        if (ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Réservation supprimée'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- MESSAGE FORMULÉ ----------------
  String _buildReservationMessage() {
    final buffer = StringBuffer();

    buffer.write(
        '👤 ${reservation.clientName} souhaite effectuer une ');
    buffer.write(
        '**${_translateReservationType(reservation.reservationType)}** ');

    buffer.write('pour ce bien.');

    if (reservation.visitDate != null) {
      buffer.write(
          '\n📅 Date prévue : ${_formatDate(reservation.visitDate!)}');
    } else if (reservation.startDate != null) {
      buffer.write(
          '\n📅 Du ${_formatDate(reservation.startDate!)}');
      if (reservation.endDate != null) {
        buffer.write(
            ' au ${_formatDate(reservation.endDate!)}');
      }
    }

    buffer.write(
        '\n💰 Montant : ${reservation.price.toStringAsFixed(0)} FCFA');

    buffer.write(
        '\n✉️ Email : ${reservation.clientEmail}');

    return buffer.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _contact(String phone) async {
    await WhatsAppUtilsMesReservation.sendMessage(phone: phone);
  }

  // ---------------- TRADUCTIONS ----------------
  String _translateTransaction(String value) {
    switch (value.toLowerCase()) {
      case 'rent':
        return 'Location';
      case 'sale':
        return 'Vente';
      default:
        return value;
    }
  }

  String _translateReservationType(String value) {
    switch (value.toLowerCase()) {
      case 'visit':
        return 'visite';
      case 'booking':
        return 'réservation';
      default:
        return value;
    }
  }
}



// import 'package:flutter/material.dart';
// import '../../theme/colors.dart';

// class MesReservationsScreen extends StatefulWidget {
//   const MesReservationsScreen({super.key});

//   @override
//   State<MesReservationsScreen> createState() => _MesReservationsScreenState();
// }

// class _MesReservationsScreenState extends State<MesReservationsScreen> {
//   String selectedCategory = "Toutes";

//   final List<String> categories = ["Toutes", "Achat", "Location"];

//   // Exemple de données reçues par l'entreprise avec un champ 'mode'
//   final List<Map<String, dynamic>> reservations = [
//     {
//       "client": "Jean Dupont",
//       "type": "Hôtel",
//       "service": "Chambre double",
//       "date": "02 Déc 2025 - 05 Déc 2025",
//       "status": "Confirmé",
//       "mode": "Location",
//     },
//     {
//       "client": "Marie Martin",
//       "type": "Appartement",
//       "service": "T2",
//       "date": "15 Déc 2025 - 20 Déc 2025",
//       "status": "En attente",
//       "mode": "Achat",
//     },
//     {
//       "client": "Paul Leblanc",
//       "type": "Voiture",
//       "service": "SUV",
//       "date": "10 Déc 2025",
//       "status": "Annulé",
//       "mode": "Location",
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           "Mes réservations",
//           style: TextStyle(
//             color: AppColors.textDark,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           _buildCategoryBar(),
//           const SizedBox(height: 8),
//           Expanded(child: _buildReservationList()),
//         ],
//       ),
//     );
//   }

//   // ------------------------ BARRE DES RUBRIQUES ------------------------
//   Widget _buildCategoryBar() {
//     return SizedBox(
//       height: 50,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         itemCount: categories.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 12),
//         itemBuilder: (_, index) {
//           final cat = categories[index];
//           final isActive = selectedCategory == cat;

//           return GestureDetector(
//             onTap: () {
//               setState(() {
//                 selectedCategory = cat;
//               });
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               decoration: BoxDecoration(
//                 color: isActive ? AppColors.primary : Colors.grey.shade200,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Text(
//                 cat,
//                 style: TextStyle(
//                   color: isActive ? Colors.white : AppColors.textDark,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ------------------------ LISTE DES RÉSERVATIONS ------------------------
//   Widget _buildReservationList() {
//     // Filtrer selon la catégorie sélectionnée
//     final List<Map<String, dynamic>> filtered = selectedCategory == "Toutes"
//         ? reservations
//         : reservations
//             .where((Map<String, dynamic> r) => r["mode"] == selectedCategory)
//             .toList();

//     if (filtered.isEmpty) {
//       return const Center(
//         child: Text(
//           "Aucune réservation pour le moment",
//           style: TextStyle(color: Colors.grey, fontSize: 16),
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       itemCount: filtered.length,
//       itemBuilder: (_, index) {
//         final res = filtered[index];
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           child: _reservationCard(res),
//         );
//       },
//     );
//   }

//   // ------------------------ CARTE DE RÉSERVATION ------------------------
//   Widget _reservationCard(Map<String, dynamic> res) {
//     Color statusColor;
//     switch (res["status"]) {
//       case "Confirmé":
//         statusColor = Colors.green;
//         break;
//       case "En attente":
//         statusColor = Colors.orange;
//         break;
//       case "Annulé":
//         statusColor = Colors.red;
//         break;
//       default:
//         statusColor = Colors.grey;
//     }

//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Client et statut
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   res["client"],
//                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: statusColor.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     res["status"],
//                     style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 6),
//             Text(
//               "${res["type"]} - ${res["service"]}",
//               style: const TextStyle(color: Colors.grey, fontSize: 14),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               res["date"],
//               style: const TextStyle(color: Colors.grey, fontSize: 12),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton(
//                   onPressed: () {
//                     // TODO: Voir détails réservation
//                   },
//                   child: const Text("Voir Détails"),
//                 ),
//                 const SizedBox(width: 8),
//                 TextButton(
//                   onPressed: () {
//                     // TODO: Contacter client
//                   },
//                   child: const Text("Contacter"),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




// import 'package:flutter/material.dart';
// import '../../theme/colors.dart';

// class ReservationsScreen extends StatefulWidget {
//   const ReservationsScreen({super.key});

//   @override
//   State<ReservationsScreen> createState() => _ReservationsScreenState();
// }

// class _ReservationsScreenState extends State<ReservationsScreen> {
//   String selectedCategory = "Toutes";

//   final List<String> categories = ["Toutes", "Hôtels", "Immobilier", "Véhicules", "Autres"];

//   // Exemple de données reçues par l'entreprise
//   final List<Map<String, dynamic>> reservations = [
//     {
//       "client": "Jean Dupont",
//       "type": "Hôtel",
//       "service": "Chambre double",
//       "date": "02 Déc 2025 - 05 Déc 2025",
//       "status": "Confirmé",
//     },
//     {
//       "client": "Marie Martin",
//       "type": "Immobilier",
//       "service": "Appartement T2",
//       "date": "15 Déc 2025 - 20 Déc 2025",
//       "status": "En attente",
//     },
//     {
//       "client": "Paul Leblanc",
//       "type": "Véhicules",
//       "service": "Voiture SUV",
//       "date": "10 Déc 2025",
//       "status": "Annulé",
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           "Mes réservations",
//           style: TextStyle(
//             color: AppColors.textDark,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           _buildCategoryBar(),
//           const SizedBox(height: 8),
//           Expanded(child: _buildReservationList()),
//         ],
//       ),
//     );
//   }

//   // ------------------------ BARRE DES RUBRIQUES ------------------------
//   Widget _buildCategoryBar() {
//     return SizedBox(
//       height: 50,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         itemCount: categories.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 12),
//         itemBuilder: (_, index) {
//           final cat = categories[index];
//           final isActive = selectedCategory == cat;

//           return GestureDetector(
//             onTap: () {
//               setState(() {
//                 selectedCategory = cat;
//               });
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               decoration: BoxDecoration(
//                 color: isActive ? AppColors.primary : Colors.grey.shade200,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Text(
//                 cat,
//                 style: TextStyle(
//                   color: isActive ? Colors.white : AppColors.textDark,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ------------------------ LISTE DES RÉSERVATIONS ------------------------
//   Widget _buildReservationList() {
//     // Préciser explicitement le type pour éviter l'erreur
//     final List<Map<String, dynamic>> filtered = selectedCategory == "Toutes"
//         ? reservations
//         : reservations
//             .where((Map<String, dynamic> r) => r["type"] == selectedCategory)
//             .toList();

//     if (filtered.isEmpty) {
//       return const Center(
//         child: Text(
//           "Aucune réservation pour le moment",
//           style: TextStyle(color: Colors.grey, fontSize: 16),
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       itemCount: filtered.length,
//       itemBuilder: (_, index) {
//         final res = filtered[index];
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           child: _reservationCard(res),
//         );
//       },
//     );
//   }

//   // ------------------------ CARTE DE RÉSERVATION ------------------------
//   Widget _reservationCard(Map<String, dynamic> res) {
//     Color statusColor;
//     switch (res["status"]) {
//       case "Confirmé":
//         statusColor = Colors.green;
//         break;
//       case "En attente":
//         statusColor = Colors.orange;
//         break;
//       case "Annulé":
//         statusColor = Colors.red;
//         break;
//       default:
//         statusColor = Colors.grey;
//     }

//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Client et statut
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   res["client"],
//                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: statusColor.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     res["status"],
//                     style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 6),
//             Text(
//               "${res["type"]} - ${res["service"]}",
//               style: const TextStyle(color: Colors.grey, fontSize: 14),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               res["date"],
//               style: const TextStyle(color: Colors.grey, fontSize: 12),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton(
//                   onPressed: () {
//                     // TODO: Voir détails réservation
//                   },
//                   child: const Text("Voir Détails"),
//                 ),
//                 const SizedBox(width: 8),
//                 TextButton(
//                   onPressed: () {
//                     // TODO: Contacter client
//                   },
//                   child: const Text("Contacter"),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }









// import 'package:flutter/material.dart';
// import '../../theme/colors.dart';

// class ReservationsScreen extends StatefulWidget {
//   const ReservationsScreen({super.key});

//   @override
//   State<ReservationsScreen> createState() => _ReservationsScreenState();
// }

// class _ReservationsScreenState extends State<ReservationsScreen> {
//   String selectedCategory = "Toutes";

//   final List<String> categories = ["Toutes", "Hôtels", "Immobilier", "Véhicules", "Autres"];

//   // Exemple de données reçues par l'entreprise
//   final List<Map<String, dynamic>> reservations = [
//     {
//       "client": "Jean Dupont",
//       "type": "Hôtel",
//       "service": "Chambre double",
//       "date": "02 Déc 2025 - 05 Déc 2025",
//       "status": "Confirmé",
//     },
//     {
//       "client": "Marie Martin",
//       "type": "Immobilier",
//       "service": "Appartement T2",
//       "date": "15 Déc 2025 - 20 Déc 2025",
//       "status": "En attente",
//     },
//     {
//       "client": "Paul Leblanc",
//       "type": "Véhicules",
//       "service": "Voiture SUV",
//       "date": "10 Déc 2025",
//       "status": "Annulé",
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           "Mes réservations",
//           style: TextStyle(
//             color: AppColors.textDark,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           _buildCategoryBar(),
//           const SizedBox(height: 8),
//           Expanded(child: _buildReservationList()),
//         ],
//       ),
//     );
//   }

//   // ------------------------ BARRE DES RUBRIQUES ------------------------
//   Widget _buildCategoryBar() {
//     return SizedBox(
//       height: 50,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         itemCount: categories.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 12),
//         itemBuilder: (_, index) {
//           final cat = categories[index];
//           final isActive = selectedCategory == cat;

//           return GestureDetector(
//             onTap: () {
//               setState(() {
//                 selectedCategory = cat;
//               });
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               decoration: BoxDecoration(
//                 color: isActive ? AppColors.primary : Colors.grey.shade200,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Text(
//                 cat,
//                 style: TextStyle(
//                   color: isActive ? Colors.white : AppColors.textDark,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ------------------------ LISTE DES RÉSERVATIONS ------------------------
//   Widget _buildReservationList() {
//     final filtered = selectedCategory == "Toutes"
//         ? reservations
//         : reservations.where((r) => r["type"] == selectedCategory).toList();

//     if (filtered.isEmpty) {
//       return const Center(
//         child: Text(
//           "Aucune réservation pour le moment",
//           style: TextStyle(color: Colors.grey, fontSize: 16),
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       itemCount: filtered.length,
//       itemBuilder: (_, index) {
//         final res = filtered[index];
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           child: _reservationCard(res),
//         );
//       },
//     );
//   }

//   // ------------------------ CARTE DE RÉSERVATION ------------------------
//   Widget _reservationCard(Map<String, dynamic> res) {
//     Color statusColor;
//     switch (res["status"]) {
//       case "Confirmé":
//         statusColor = Colors.green;
//         break;
//       case "En attente":
//         statusColor = Colors.orange;
//         break;
//       case "Annulé":
//         statusColor = Colors.red;
//         break;
//       default:
//         statusColor = Colors.grey;
//     }

//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Client et type de service
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   res["client"],
//                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: statusColor.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     res["status"],
//                     style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 6),
//             Text(
//               "${res["type"]} - ${res["service"]}",
//               style: const TextStyle(color: Colors.grey, fontSize: 14),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               res["date"],
//               style: const TextStyle(color: Colors.grey, fontSize: 12),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton(
//                   onPressed: () {
//                     // TODO: Voir détails réservation
//                   },
//                   child: const Text("Voir Détails"),
//                 ),
//                 const SizedBox(width: 8),
//                 TextButton(
//                   onPressed: () {
//                     // TODO: Contacter client
//                   },
//                   child: const Text("Contacter"),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }





















// import 'package:flutter/material.dart';
// import '../../theme/colors.dart';

// // Tes cartes (ici placeholders si tu veux les remplacer)
// import '../../components/hotel_card.dart';
// import '../../components/immobilier_card.dart';

// class ReservationsScreen extends StatefulWidget {
//   const ReservationsScreen({super.key});

//   @override
//   State<ReservationsScreen> createState() => _ReservationsScreenState();
// }

// class _ReservationsScreenState extends State<ReservationsScreen> {
//   String selectedCategory = "Hôtels";

//   final List<Map<String, dynamic>> categories = [
//     {"icon": Icons.hotel, "label": "Hôtels"},
//     {"icon": Icons.house, "label": "Immobilier"},
//     {"icon": Icons.directions_car, "label": "Véhicules"},
//     {"icon": Icons.event_note, "label": "Autres"},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,

//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           "Mes réservations",
//           style: TextStyle(
//             color: AppColors.textDark,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),

//       body: Column(
//         children: [
//           _buildCategoryBar(),
//           const SizedBox(height: 8),
//           Expanded(child: _buildContent()),
//         ],
//       ),
//     );
//   }

//   // ------------------------ BARRE DES RUBRIQUES ------------------------
//   Widget _buildCategoryBar() {
//     return SizedBox(
//       height: 85,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         itemCount: categories.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 16),
//         itemBuilder: (_, index) {
//           final cat = categories[index];
//           final isActive = selectedCategory == cat["label"];

//           return GestureDetector(
//             onTap: () {
//               setState(() {
//                 selectedCategory = cat["label"];
//               });
//             },
//             child: Column(
//               children: [
//                 Container(
//                   width: 58,
//                   height: 58,
//                   decoration: BoxDecoration(
//                     color: isActive ? AppColors.primary : Colors.grey.shade200,
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Icon(
//                     cat["icon"],
//                     color: isActive ? Colors.white : AppColors.textDark,
//                     size: 28,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   cat["label"],
//                   style: const TextStyle(fontSize: 12),
//                 )
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ------------------------ CONTENU SELON CATÉGORIE ------------------------
//   Widget _buildContent() {
//     switch (selectedCategory) {
//       case "Hôtels":
//         return _buildReservationList(() => const HotelCard());

//       case "Immobilier":
//         return _buildReservationList(() => const ImmobilierCard());

//       case "Véhicules":
//         return _buildReservationList(
//           () => Container(
//             height: 120,
//             margin: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Center(
//               child: Text("Carte réservation véhicule"),
//             ),
//           ),
//         );

//       case "Autres":
//         return _buildReservationList(
//           () => Container(
//             height: 120,
//             margin: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Center(
//               child: Text("Réservation autre service"),
//             ),
//           ),
//         );

//       default:
//         return const SizedBox();
//     }
//   }

//   // ------------------------ LISTE DES RÉSERVATIONS ------------------------
//   Widget _buildReservationList(Widget Function() cardBuilder) {
//     final List<int> fakeData = List.generate(5, (i) => i);

//     if (fakeData.isEmpty) {
//       return const Center(
//         child: Text(
//           "Aucune réservation pour le moment",
//           style: TextStyle(color: Colors.grey, fontSize: 16),
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       itemCount: fakeData.length,
//       itemBuilder: (_, index) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           child: cardBuilder(),
//         );
//       },
//     );
//   }
// }
