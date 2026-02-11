// import 'package:flutter/material.dart';
// import 'package:mobile/presentation/components/meuble_card.dart';
// import '../../theme/colors.dart';
// import '../../components/meuble_card.dart';

// class MeublesScreen extends StatelessWidget {
//   const MeublesScreen({super.key});

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
//           "Meubles",
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//       ),

//       // -------------------------------
//       // LISTE SCROLLABLE DES MEUBLES
//       // -------------------------------
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: 20, // provisoire avant API
//         itemBuilder: (context, index) {
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 20),
//             child: const MeubleCard(),
//           );
//         },
//       ),
//     );
//   }
// }
