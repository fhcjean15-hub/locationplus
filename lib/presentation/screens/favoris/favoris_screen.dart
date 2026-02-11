// import 'package:flutter/material.dart';
// import 'package:mobile/presentation/components/vehicule_card.dart';
// import '../../theme/colors.dart';

// // Tes cartes mises à jour
// import '../../components/immobilier_card.dart';
// import '../../components/meuble_card.dart';
// import '../../components/hotel_card.dart';

// class FavorisScreen extends StatefulWidget {
//   const FavorisScreen({super.key});

//   @override
//   State<FavorisScreen> createState() => _FavorisScreenState();
// }

// class _FavorisScreenState extends State<FavorisScreen> {
//   String selectedCategory = "Immobilier";

//   final List<Map<String, dynamic>> categories = [
//     {"icon": Icons.house, "label": "Immobilier"},
//     {"icon": Icons.chair, "label": "Meubles"},
//     {"icon": Icons.directions_car, "label": "Véhicules"},
//     {"icon": Icons.hotel, "label": "Hôtels"},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           "Mes favoris",
//           style: TextStyle(
//             color: AppColors.textDark,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           const SizedBox(height: 10), // ← espace entre AppBar et rubriques
//           _buildCategoryBar(),
//           const SizedBox(height: 6),
//           Expanded(child: _buildContent()),
//         ],
//       ),
//     );
//   }

//   // ---------------- BARRE DES RUBRIQUES ----------------
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

// // ---------------- CONTENU SELON CATÉGORIE ----------------
// Widget _buildContent() {
//   switch (selectedCategory) {
//     case "Immobilier":
//       // Utilisation des StatefulWidget avec overlay
//       return _favoriteList((index) {
//         final item = index % 2 == 0 ? "Achat" : "Location"; // exemple
//         if (item == "Achat") {
//           return ImmobilierCardSale(); // Overlay fonctionne
//         } else {
//           return ImmobilierCard(); // Overlay fonctionne
//         }
//       });

//     case "Meubles":
//       // MeubleCard peut rester const si c'est un StatelessWidget
//       return _favoriteList((_) => const MeubleCard());

//     case "Véhicules":
//       // StatefulWidget pour overlay similaire aux véhicules
//       return _favoriteList((index) {
//         final item = index % 2 == 0 ? "Achat" : "Location";
//         if (item == "Achat") {
//           return VehiculeCardSale(); // Widget Stateful avec overlay
//         } else {
//           return VehiculeCardRent(); // Widget Stateful avec overlay
//         }
//       });

//     case "Hôtels":
//       // StatelessWidget, const ok
//       return _favoriteList((_) => const HotelCard());

//     default:
//       return const SizedBox();
//   }
// }


//   // ---------------- LISTE FAVORIS CENTRÉE HORIZONTALE ----------------
//   Widget _favoriteList(Widget Function(int) builder) {
//     final List<int> fakeData = List.generate(6, (i) => i);

//     if (fakeData.isEmpty) {
//       return const Center(
//         child: Text(
//           "Aucun favori pour le moment",
//           style: TextStyle(color: Colors.grey, fontSize: 16),
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       itemCount: fakeData.length,
//       itemBuilder: (_, index) {
//         return Center(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 6),
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(
//                 maxWidth: 300, // largeur maximale de la carte
//               ),
//               child: builder(index),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import '../../theme/colors.dart';

// // Exemple de cartes réutilisables ou placeholders
// import '../../components/immobilier_card.dart';
// import '../../components/meuble_card.dart';
// import '../../components/hotel_card.dart';

// class FavorisScreen extends StatefulWidget {
//   const FavorisScreen({super.key});

//   @override
//   State<FavorisScreen> createState() => _FavorisScreenState();
// }

// class _FavorisScreenState extends State<FavorisScreen> {
//   String selectedCategory = "Immobilier";

//   final List<Map<String, dynamic>> categories = [
//     {"icon": Icons.house, "label": "Immobilier"},
//     {"icon": Icons.chair, "label": "Meubles"},
//     {"icon": Icons.directions_car, "label": "Véhicules"},
//     {"icon": Icons.hotel, "label": "Hôtels"},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,

//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           "Mes favoris",
//           style: TextStyle(
//             color: AppColors.textDark,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),

//       body: Column(
//         children: [
//           _buildCategoryBar(),
//           const SizedBox(height: 6),
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
//       case "Immobilier":
//         return _favoriteList(() => const ImmobilierCard());

//       case "Meubles":
//         return _favoriteList(() => const MeubleCard());

//       case "Véhicules":
//         return _favoriteList(
//           () => Container(
//             height: 120,
//             width: 250,
//             color: Colors.grey.shade300,
//             child: const Center(child: Text("Carte véhicule favorite")),
//           ),
//         );

//       case "Hôtels":
//         return _favoriteList(() => const HotelCard());

//       default:
//         return const SizedBox();
//     }
//   }

//   // ------------------------ LISTE FAVORIS CENTRÉE HORIZONTAL ------------------------
//   Widget _favoriteList(Widget Function() builder) {
//     final List<int> fakeData = List.generate(6, (i) => i);

//     if (fakeData.isEmpty) {
//       return const Center(
//         child: Text(
//           "Aucun favori pour le moment",
//           style: TextStyle(color: Colors.grey, fontSize: 16),
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       itemCount: fakeData.length,
//       itemBuilder: (_, index) {
//         return Center(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 6),
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(
//                 maxWidth: 300, // largeur maximale de la carte
//               ),
//               child: builder(),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import '../../theme/colors.dart';

// // Exemple de cartes réutilisables ou placeholders
// import '../../components/immobilier_card.dart';
// import '../../components/meuble_card.dart';
// import '../../components/hotel_card.dart';

// class FavorisScreen extends StatefulWidget {
//   const FavorisScreen({super.key});

//   @override
//   State<FavorisScreen> createState() => _FavorisScreenState();
// }

// class _FavorisScreenState extends State<FavorisScreen> {
//   String selectedCategory = "Immobilier";

//   final List<Map<String, dynamic>> categories = [
//     {"icon": Icons.house, "label": "Immobilier"},
//     {"icon": Icons.chair, "label": "Meubles"},
//     {"icon": Icons.directions_car, "label": "Véhicules"},
//     {"icon": Icons.hotel, "label": "Hôtels"},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,

//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           "Mes favoris",
//           style: TextStyle(
//             color: AppColors.textDark,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),

//       body: Column(
//         children: [
//           _buildCategoryBar(),
//           const SizedBox(height: 6),
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
//       case "Immobilier":
//         return _favoriteList(() => const ImmobilierCard());

//       case "Meubles":
//         return _favoriteList(() => const MeubleCard());

//       case "Véhicules":
//         return _favoriteList(
//           () => Container(
//             height: 120,
//             margin: const EdgeInsets.all(12),
//             color: Colors.grey.shade300,
//             child: const Center(child: Text("Carte véhicule favorite")),
//           ),
//         );

//       case "Hôtels":
//         return _favoriteList(() => const HotelCard());

//       default:
//         return const SizedBox();
//     }
//   }

//   // ------------------------ LISTE FAVORIS (NON INFINIE) ------------------------
//   Widget _favoriteList(Widget Function() builder) {
//     final List<int> fakeData = List.generate(6, (i) => i);

//     if (fakeData.isEmpty) {
//       return const Center(
//         child: Text(
//           "Aucun favori pour le moment",
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
//           child: builder(),
//         );
//       },
//     );
//   }
// }
