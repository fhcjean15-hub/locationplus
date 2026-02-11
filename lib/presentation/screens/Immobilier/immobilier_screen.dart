// import 'package:flutter/material.dart';
// import 'package:mobile/presentation/components/immobilier_card.dart';
// import '../../components/immobilier_card.dart';

// class ImmobiliersScreen extends StatelessWidget {
//   const ImmobiliersScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,

//       // -------------------------------
//       // APP BAR BLANCHE
//       // -------------------------------
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           "Immobilier",
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//       ),

//       // -------------------------------
//       // LISTE DES CARTES IMMOBILIÈRES
//       // -------------------------------
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: 20, // temp avant API
//         itemBuilder: (context, index) {
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 20),
//             child: const ImmobilierCard(),
//           );
//         },
//       ),
//     );
//   }
// }
