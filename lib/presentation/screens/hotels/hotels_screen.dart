// import 'package:flutter/material.dart';
// import 'package:mobile/presentation/components/hotel_card.dart';
// import '../../theme/colors.dart';
// import '../../components/hotel_card.dart';

// class HotelsScreen extends StatelessWidget {
//   const HotelsScreen({super.key});

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
//           "Hôtels",
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//       ),

//       // -------------------------------
//       // LISTE DES OFFRES (INFINITE LIST)
//       // -------------------------------
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: 20, // en attendant les données réelles  
//         itemBuilder: (context, index) {
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 20),
//             child: const HotelCard(),
//           );
//         },
//       ),
//     );
//   }
// }
