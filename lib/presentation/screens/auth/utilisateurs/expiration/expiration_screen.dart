import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/presentation/screens/auth/utilisateurs/verification/verification_screen.dart';
import '../../../../theme/colors.dart';
import '../../../../../business/providers/auth_controller_provider.dart';

class ExpirationScreen extends ConsumerWidget {
  const ExpirationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(authControllerProvider.notifier);
    final state = ref.watch(authControllerProvider);
    final user = state.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final String paymentStatus = user.paymentStatus;
    final DateTime? validUntil = user.paymentValidUntil;
    final DateTime now = DateTime.now();

    bool hasNeverSubscribed = validUntil == null;
    bool expired = false;
    bool active = false;
    int daysRemaining = 0;

    if (!hasNeverSubscribed && paymentStatus == 'paid') {
      if (validUntil!.isAfter(now)) {
        active = true;
        expired = false;
        daysRemaining = validUntil.difference(now).inDays;
      } else {
        expired = true;
        active = false;

        // 🔥 Mise à jour auto côté serveur si expiré
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.updatePaymentStatus(param: "none");
        });
      }
    }

    String expirationDateText = validUntil != null
        ? "${validUntil.day.toString().padLeft(2, '0')}/"
          "${validUntil.month.toString().padLeft(2, '0')}/"
          "${validUntil.year}"
        : "Aucune";

    // -----------------------------
    // TEXTES DYNAMIQUES
    // -----------------------------
    String statusText;
    Color statusColor;
    String messageText;

    if (hasNeverSubscribed) {
      statusText = "Aucun abonnement";
      statusColor = Colors.orange;
      messageText = "Vous n’avez jamais souscrit à un abonnement.";
    } else if (active) {
      statusText = "Actif";
      statusColor = Colors.green;
      messageText = "⏳ Il vous reste $daysRemaining jour(s) d’abonnement.";
    } else {
      statusText = "Expiré";
      statusColor = Colors.red;
      messageText = "⚠️ Votre abonnement est expiré. Veuillez le renouveler.";
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Expiration du Compte",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Statut de l’abonnement",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // ------------------------
                // STATUT
                // ------------------------
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 18,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // ------------------------
                // DATE D'EXPIRATION
                // ------------------------
                Text(
                  "Expire le : $expirationDateText",
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 16),

                // ------------------------
                // MESSAGE
                // ------------------------
                Text(
                  messageText,
                  style: TextStyle(
                    fontSize: 16,
                    color: expired ? Colors.red : Colors.black,
                  ),
                ),

                const Spacer(),

                // ------------------------
                // BOUTON
                // ------------------------
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VerificationScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Renouveler l’abonnement",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}









// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile/presentation/screens/auth/utilisateurs/verification/verification_screen.dart';
// import '../../../../theme/colors.dart';
// import '../../../../../business/providers/auth_controller_provider.dart';

// class ExpirationScreen extends ConsumerWidget {
//   const ExpirationScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final controller = ref.read(authControllerProvider.notifier);
//     final state = ref.watch(authControllerProvider);
//     final user = state.user;

//     if (user == null) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     final String paymentStatus = user.paymentStatus;
//     final DateTime? validUntil = user.paymentValidUntil;
//     final DateTime now = DateTime.now();

//     bool expired = true;
//     int daysRemaining = 0;

//     if (paymentStatus == 'paid' && validUntil != null) {
//       if (validUntil.isAfter(now)) {
//         expired = false;
//         daysRemaining = validUntil.difference(now).inDays;
//       }
//     }

//     // 🔥 MISE À JOUR AUTOMATIQUE DU STATUT SI EXPIRÉ
//     if (expired && paymentStatus == 'paid') {
//       Future.microtask(() async {
//         await controller.updatePaymentStatus();
//       });
//     }

//     final String expirationDateText = validUntil != null
//         ? "${validUntil.day.toString().padLeft(2, '0')}/"
//           "${validUntil.month.toString().padLeft(2, '0')}/"
//           "${validUntil.year}"
//         : "Non définie";

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: const Text(
//           "Expiration du Compte",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: AppColors.textDark,
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Card(
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Statut de l’abonnement",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 16),

//                 // ------------------------
//                 // STATUT
//                 // ------------------------
//                 Text(
//                   expired ? "Expiré" : "Actif",
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: expired ? Colors.red : Colors.green,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 // ------------------------
//                 // DATE
//                 // ------------------------
//                 Text(
//                   "Expire le : $expirationDateText",
//                   style: const TextStyle(fontSize: 16),
//                 ),

//                 const SizedBox(height: 16),

//                 // ------------------------
//                 // MESSAGE
//                 // ------------------------
//                 if (!expired)
//                   Text(
//                     "⏳ Il vous reste $daysRemaining jour(s) d’abonnement.",
//                     style: const TextStyle(fontSize: 16),
//                   )
//                 else
//                   const Text(
//                     "⚠️ Votre abonnement est expiré. Veuillez le renouveler.",
//                     style: TextStyle(fontSize: 16, color: Colors.red),
//                   ),

//                 const Spacer(),

//                 // ------------------------
//                 // ACTION
//                 // ------------------------
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => const VerificationScreen(),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primary,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: Text(
//                       expired ? "Renouveler maintenant" : "Renouveler",
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }














// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile/presentation/screens/auth/utilisateurs/verification/verification_screen.dart';
// import '../../../../theme/colors.dart';
// import '../../../../../business/providers/auth_controller_provider.dart';

// class ExpirationScreen extends ConsumerWidget {
//   const ExpirationScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final controller = ref.read(authControllerProvider.notifier);
//     final user = ref.read(authControllerProvider).user;

//     if (user == null) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     final String paymentStatus = user.paymentStatus;
//     final DateTime? validUntil = user.paymentValidUntil;

//     final DateTime now = DateTime.now();

//     bool expired = true;
//     int daysRemaining = 0;

//     if (paymentStatus == 'paid' && validUntil != null) {
//       if (validUntil.isAfter(now)) {
//         expired = false;
//         daysRemaining = validUntil.difference(now).inDays;
//       }
//     }

//     String expirationDateText = validUntil != null
//         ? "${validUntil.day.toString().padLeft(2, '0')}/"
//               "${validUntil.month.toString().padLeft(2, '0')}/"
//               "${validUntil.year}"
//         : "Non définie";

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: const Text(
//           "Expiration du Compte",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: AppColors.textDark,
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Card(
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Statut de l’abonnement",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 16),

//                 // ------------------------
//                 // STATUT
//                 // ------------------------
//                 Text(
//                   expired ? "Expiré" : "Actif",
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: expired ? Colors.red : Colors.green,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 // ------------------------
//                 // DATE D'EXPIRATION
//                 // ------------------------
//                 Text(
//                   "Expire le : $expirationDateText",
//                   style: const TextStyle(fontSize: 16),
//                 ),

//                 const SizedBox(height: 16),

//                 // ------------------------
//                 // MESSAGE
//                 // ------------------------
//                 if (!expired)
//                   Text(
//                     "⏳ Il vous reste $daysRemaining jour(s) d’abonnement.",
//                     style: const TextStyle(fontSize: 16),
//                   )
//                 else
//                   const Text(
//                     "⚠️ Votre abonnement est expiré. Veuillez le renouveler.",
//                     style: TextStyle(fontSize: 16, color: Colors.red),
//                   ),

//                 const Spacer(),

//                 // ------------------------
//                 // BOUTON
//                 // ------------------------
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => const VerificationScreen()),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primary,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: Text(
//                       expired ? "Renouveler maintenant" : "Renouveler",
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }









// import 'package:flutter/material.dart';
// import '../../../../theme/colors.dart';

// class ExpirationScreen extends StatelessWidget {
//   const ExpirationScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final bool expired = false;
//     final String expirationDate = "15/03/2026";

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: const Text(
//           "Expiration du Compte",
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: AppColors.textDark,
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Card(
//           elevation: 2,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text("Statut du compte",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 16),

//                 Text(
//                   expired ? "Expiré" : "Actif",
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: expired ? Colors.red : Colors.green,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 Text("Expiration : $expirationDate",
//                     style: const TextStyle(fontSize: 16)),

//                 const Spacer(),

//                 ElevatedButton(
//                   onPressed: () {},
//                   child: Text(expired ? "Renouveler maintenant" : "Renouveler"),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
