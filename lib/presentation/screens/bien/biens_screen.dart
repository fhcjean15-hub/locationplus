import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/business/providers/bien_controller_provider.dart';
import 'package:mobile/data/models/bien_model.dart';
import 'package:mobile/presentation/components/hebergement_list_card.dart';
import 'package:mobile/presentation/components/hotel_list_card.dart';
import 'package:mobile/presentation/components/immobilier_list_card.dart';
import 'package:mobile/presentation/components/meuble_list_card.dart';
import 'package:mobile/presentation/components/vehicule_list_card.dart';
import '../../theme/colors.dart';

// TES CARTES EXISTANTES
import '../../components/immobilier_card.dart';
import '../../components/meuble_card.dart';
import '../../components/hotel_card.dart';
import '../../components/vehicule_card.dart';
import '../../components/hebergement_card.dart';

class BiensScreen extends ConsumerStatefulWidget {
  const BiensScreen({super.key});

  @override
  ConsumerState<BiensScreen> createState() => _BiensScreenState();
}

class _BiensScreenState extends ConsumerState<BiensScreen> {
  String selectedCategory = "Immobilier";
  final ScrollController _scrollController = ScrollController();

  // ------------------------------- RUBRIQUES --------------------------------
  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.house, "label": "Immobilier"},
    {"icon": Icons.chair, "label": "Meubles"},
    {"icon": Icons.directions_car, "label": "Véhicules"},
    {"icon": Icons.hotel, "label": "Hôtels"},
    {"icon": Icons.apartment, "label": "Hébergements"},
  ];

  @override
  Widget build(BuildContext context) {
    final biensAsync = ref.watch(bienControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Mes biens",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildCategoryBar(),
          const SizedBox(height: 10),
          Expanded(
            child: biensAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Erreur : $e")),
              data: (biens) {
                // Filtrer par catégorie
                final List<BienModel> allBiens = biens.whereType<BienModel>().toList();

                final immobiliers =
                    allBiens.where((b) => b.category == 'immobilier').toList();
                final meubles = allBiens.where((b) => b.category == 'meuble').toList();
                final hotels = allBiens.where((b) => b.category == 'hotel').toList();
                final vehicules = allBiens.where((b) => b.category == 'vehicule').toList();
                final hebergements =
                    allBiens.where((b) => b.category == 'hebergement').toList();

                List<BienModel> displayedBiens;
                switch (selectedCategory) {
                  case "Immobilier":
                    displayedBiens = immobiliers;
                    break;
                  case "Meubles":
                    displayedBiens = meubles;
                    break;
                  case "Hôtels":
                    displayedBiens = hotels;
                    break;
                  case "Véhicules":
                    displayedBiens = vehicules;
                    break;
                  case "Hébergements":
                    displayedBiens = hebergements;
                    break;
                  default:
                    displayedBiens = [];
                }

                if (displayedBiens.isEmpty) {
                  return const Center(child: Text("Aucun bien disponible."));
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: displayedBiens.length,
                  itemBuilder: (_, index) {
                    final bien = displayedBiens[index];
                    switch (selectedCategory) {
                      case "Immobilier":
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: ImmobilierListCard(bien: bien),
                        );
                      case "Meubles":
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: MeubleListCard(bien: bien),
                        );
                      case "Hôtels":
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: HotelListCard(bien: bien),
                        );
                      case "Véhicules":
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: VehiculeListCard(bien: bien),
                        );
                      case "Hébergements":
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: HebergementListCard(bien: bien),
                        );
                      default:
                        return const SizedBox();
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------ BARRE HORIZONTALE DES RUBRIQUES -------------------
  Widget _buildCategoryBar() {
    return SizedBox(
      height: 95,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) {
          final item = categories[i];
          final isActive = selectedCategory == item["label"];

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = item["label"];
              });
            },
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    item["icon"],
                    color: isActive ? Colors.white : AppColors.textDark,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item["label"],
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}








// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile/business/providers/bien_controller_provider.dart';
// import 'package:mobile/data/models/bien_model.dart';
// import '../../theme/colors.dart';

// // TES CARTES EXISTANTES
// import '../../components/immobilier_card.dart';
// import '../../components/meuble_card.dart';
// import '../../components/hotel_card.dart';
// import '../../components/vehicule_card.dart';
// import '../../components/hebergement_card.dart';

// class BiensScreen extends ConsumerStatefulWidget {
//   const BiensScreen({super.key});

//   @override
//   ConsumerState<BiensScreen> createState() => _BiensScreenState();
// }

// class _BiensScreenState extends ConsumerState<BiensScreen> {
//   String selectedCategory = "Immobilier";
//   final ScrollController _scrollController = ScrollController();

//   // ------------------------------- RUBRIQUES --------------------------------
//   final List<Map<String, dynamic>> categories = [
//     {"icon": Icons.house, "label": "Immobilier"},
//     {"icon": Icons.chair, "label": "Meubles"},
//     {"icon": Icons.directions_car, "label": "Véhicules"},
//     {"icon": Icons.hotel, "label": "Hôtels"},
//     {"icon": Icons.apartment, "label": "Hébergements"},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final biensAsync = ref.watch(bienControllerProvider);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: const Text(
//           "Mes biens",
//           style: TextStyle(
//             color: AppColors.textDark,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           const SizedBox(height: 10),
//           _buildCategoryBar(),
//           const SizedBox(height: 10),
//           Expanded(
//             child: biensAsync.when(
//               loading: () => const Center(child: CircularProgressIndicator()),
//               error: (e, _) => Center(child: Text("Erreur : $e")),
//               data: (biens) {
//                 // Filtrer par catégorie
//                 final List<BienModel> allBiens = biens.whereType<BienModel>().toList();

//                 final immobiliers =
//                     allBiens.where((b) => b.category == 'immobilier').toList();
//                 final meubles = allBiens.where((b) => b.category == 'meuble').toList();
//                 final hotels = allBiens.where((b) => b.category == 'hotel').toList();
//                 final vehicules = allBiens.where((b) => b.category == 'vehicule').toList();
//                 final hebergements =
//                     allBiens.where((b) => b.category == 'hebergement').toList();

//                 List<BienModel> displayedBiens;
//                 switch (selectedCategory) {
//                   case "Immobilier":
//                     displayedBiens = immobiliers;
//                     break;
//                   case "Meubles":
//                     displayedBiens = meubles;
//                     break;
//                   case "Hôtels":
//                     displayedBiens = hotels;
//                     break;
//                   case "Véhicules":
//                     displayedBiens = vehicules;
//                     break;
//                   case "Hébergements":
//                     displayedBiens = hebergements;
//                     break;
//                   default:
//                     displayedBiens = [];
//                 }

//                 if (displayedBiens.isEmpty) {
//                   return const Center(child: Text("Aucun bien disponible."));
//                 }

//                 return ListView.builder(
//                   controller: _scrollController,
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   itemCount: displayedBiens.length,
//                   itemBuilder: (_, index) {
//                     final bien = displayedBiens[index];
//                     switch (selectedCategory) {
//                       case "Immobilier":
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8),
//                           child: ImmobilierCard(bien: bien),
//                         );
//                       case "Meubles":
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8),
//                           child: MeubleCard(bien: bien),
//                         );
//                       case "Hôtels":
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8),
//                           child: HotelCard(bien: bien),
//                         );
//                       case "Véhicules":
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8),
//                           child: VehiculeCard(bien: bien),
//                         );
//                       case "Hébergements":
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8),
//                           child: HebergementCard(bien: bien),
//                         );
//                       default:
//                         return const SizedBox();
//                     }
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ------------------------ BARRE HORIZONTALE DES RUBRIQUES -------------------
//   Widget _buildCategoryBar() {
//     return SizedBox(
//       height: 95,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         itemCount: categories.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 16),
//         itemBuilder: (_, i) {
//           final item = categories[i];
//           final isActive = selectedCategory == item["label"];

//           return GestureDetector(
//             onTap: () {
//               setState(() {
//                 selectedCategory = item["label"];
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
//                     item["icon"],
//                     color: isActive ? Colors.white : AppColors.textDark,
//                     size: 30,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   item["label"],
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }






// import 'package:flutter/material.dart';
// import '../../theme/colors.dart';

// // TES CARTES EXISTANTES
// import '../../components/immobilier_card.dart';
// import '../../components/meuble_card.dart';
// import '../../components/hotel_card.dart';
// import '../../components/vehicule_card.dart';
// import '../../components/hebergement_card.dart';

// class BiensScreen extends StatefulWidget {
//   const BiensScreen({super.key});

//   @override
//   State<BiensScreen> createState() => _BiensScreenState();
// }

// class _BiensScreenState extends State<BiensScreen> {
//   String selectedCategory = "Immobilier";
//   final ScrollController _scrollController = ScrollController();

//   // ---------------------- DONNÉES SIMULÉES ----------------------
//   final List<Map<String, String>> immobilierItems = [
//     {
//       "mode": "Achat",
//       "title": "Maison moderne 3 chambres",
//       "location": "Cotonou, Fidjrossè",
//       "price": "35,000,000 F"
//     },
//     {
//       "mode": "Location",
//       "title": "Une Chambre Salon à Abomey-Calavi",
//       "location": "Calavi Acconvil derrière super marché",
//       "price": "45,000 F /mois"
//     },
//   ];

//   final List<Map<String, String>> vehiculeItems = [
//     {
//       "mode": "Achat",
//       "title": "Toyota Corolla 2018",
//       "location": "Cotonou, Gbégamey",
//       "price": "6,500,000 F"
//     },
//     {
//       "mode": "Location",
//       "title": "Hyundai Tucson 2021",
//       "location": "Cotonou, Akpakpa",
//       "price": "45,000 F /jour"
//     },
//   ];

//   final List<Map<String, String>> meubleItems = [
//     {
//       "title": "Canapé 3 places",
//       "location": "Cotonou, Zogbo",
//       "price": "120,000 F"
//     },
//     {
//       "title": "Lit King Size",
//       "location": "Cotonou, Fidjrossè",
//       "price": "250,000 F"
//     },
//   ];

//   final List<Map<String, String>> hotelItems = [
//     {
//       "title": "Hôtel La Perle",
//       "location": "Cotonou, Akpakpa",
//       "price": "60,000 F /nuit"
//     },
//   ];

//   final List<Map<String, String>> hebergementItems = [
//     {
//       "title": "Appartement Meublé",
//       "location": "Cotonou, Fidjrossè",
//       "price": "150,000 F /mois"
//     },
//   ];

//   List<String> items = []; // Liste pour infinite scroll si nécessaire

//   @override
//   void initState() {
//     super.initState();
//     _loadMore();
//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels >=
//           _scrollController.position.maxScrollExtent - 200) {
//         _loadMore();
//       }
//     });
//   }

//   void _loadMore() {
//     if (!_isInfiniteCategory(selectedCategory)) return;

//     Future.delayed(const Duration(milliseconds: 400), () {
//       setState(() {
//         items.addAll(List.generate(10, (i) => "item_$i"));
//       });
//     });
//   }

//   bool _isInfiniteCategory(String cat) {
//     return ["Immobilier", "Meubles", "Véhicules", "Hôtels", "Hébergements"]
//         .contains(cat);
//   }

//   // ------------------------------- RUBRIQUES --------------------------------
//   final List<Map<String, dynamic>> categories = [
//     {"icon": Icons.house, "label": "Immobilier"},
//     {"icon": Icons.chair, "label": "Meubles"},
//     {"icon": Icons.directions_car, "label": "Véhicules"},
//     {"icon": Icons.hotel, "label": "Hôtels"},
//     {"icon": Icons.apartment, "label": "Hébergements"},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: const Text(
//           "Mes biens",
//           style: TextStyle(
//             color: AppColors.textDark,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           const SizedBox(height: 10),
//           _buildCategoryBar(),
//           const SizedBox(height: 10),
//           Expanded(child: _buildContentArea()),
//         ],
//       ),
//     );
//   }

//   // ------------------------ BARRE HORIZONTALE DES RUBRIQUES -------------------
//   Widget _buildCategoryBar() {
//     return SizedBox(
//       height: 95,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         itemCount: categories.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 16),
//         itemBuilder: (_, i) {
//           final item = categories[i];
//           final isActive = selectedCategory == item["label"];

//           return GestureDetector(
//             onTap: () {
//               setState(() {
//                 selectedCategory = item["label"];
//                 items.clear();
//                 _loadMore();
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
//                     item["icon"],
//                     color: isActive ? Colors.white : AppColors.textDark,
//                     size: 30,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   item["label"],
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ------------------------------ CONTENU DYNAMIQUE -------------------------
//   Widget _buildContentArea() {
//     switch (selectedCategory) {
//       case "Immobilier":
//         return _buildInfiniteList(
//             (index) => ImmobilierCard(key: ValueKey(index), bien: null));
//       case "Véhicules":
//         return _buildInfiniteList(
//             (index) => VehiculeCard(key: ValueKey(index), bien: null));
//       case "Meubles":
//         return _buildInfiniteList(
//             (index) => MeubleCard(key: ValueKey(index), bien: null));
//       case "Hôtels":
//         return _buildInfiniteList(
//             (index) => HotelCard(key: ValueKey(index), bien: null));
//       case "Hébergements":
//         return _buildInfiniteList(
//             (index) => HebergementCard(key: ValueKey(index), bien: null));
//       default:
//         return const SizedBox();
//     }
//   }

//   // ------------------------ LISTE INFINIE GÉNÉRIQUE -------------------------
//   Widget _buildInfiniteList(Widget Function(int) builder) {
//     return ListView.builder(
//       controller: _scrollController,
//       padding: const EdgeInsets.only(bottom: 16),
//       itemCount: items.length + 1,
//       itemBuilder: (_, index) {
//         if (index == items.length) {
//           return const Padding(
//             padding: EdgeInsets.all(16),
//             child: Center(
//               child: CircularProgressIndicator(
//                 color: AppColors.primary,
//               ),
//             ),
//           );
//         }

//         return Align(
//           alignment: Alignment.center,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: builder(index),
//           ),
//         );
//       },
//     );
//   }
// }







// import 'package:flutter/material.dart';
// import '../../theme/colors.dart';

// // TES CARTES EXISTANTES
// import '../../components/immobilier_card.dart';
// import '../../components/meuble_card.dart';
// import '../../components/hotel_card.dart';
// import '../../components/vehicule_card.dart';

// class BiensScreen extends StatefulWidget {
//   const BiensScreen({super.key});

//   @override
//   State<BiensScreen> createState() => _BiensScreenState();
// }

// class _BiensScreenState extends State<BiensScreen> {
//   String selectedCategory = "Immobilier";
//   final ScrollController _scrollController = ScrollController();

//   // ---------------------- DONNÉES SIMULÉES ----------------------
// final List<Map<String, String>> immobilierItems = [
//   {
//     "mode": "Achat",
//     "title": "Maison moderne 3 chambres",
//     "location": "Cotonou, Fidjrossè",
//     "price": "35,000,000 F"
//   },
//   {
//     "mode": "Location",
//     "title": "Une Chambre Salon à Abomey-Calavi",
//     "location": "Calavi Acconvil derrière super marché",
//     "price": "45,000 F /mois"
//   },
// ];

// final List<Map<String, String>> vehiculeItems = [
//   {
//     "mode": "Achat",
//     "title": "Toyota Corolla 2018",
//     "location": "Cotonou, Gbégamey",
//     "price": "6,500,000 F"
//   },
//   {
//     "mode": "Location",
//     "title": "Hyundai Tucson 2021",
//     "location": "Cotonou, Akpakpa",
//     "price": "45,000 F /jour"
//   },
// ];


//   List<String> items = []; // liste infinie → éléments chargés

//   @override
//   void initState() {
//     super.initState();
//     _loadMore(); // première charge

//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels >=
//           _scrollController.position.maxScrollExtent - 200) {
//         _loadMore();
//       }
//     });
//   }

//   void _loadMore() {
//     if (!_isInfiniteCategory(selectedCategory)) return;

//     Future.delayed(const Duration(milliseconds: 400), () {
//       setState(() {
//         items.addAll(List.generate(10, (i) => "item_$i"));
//       });
//     });
//   }

//   bool _isInfiniteCategory(String cat) {
//     return ["Immobilier", "Meubles", "Véhicules", "Hôtels"].contains(cat);
//   }

//   // ------------------------------- RUBRIQUES --------------------------------
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
//         title: const Text(
//           "Mes biens",
//           style: TextStyle(
//             color: AppColors.textDark,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         elevation: 0,
//         // ✘ Suppression de la cloche ici
//       ),

//       body: Column(
//         children: [
//           const SizedBox(height: 10),
//           _buildCategoryBar(),
//           const SizedBox(height: 10),
//           // Expanded(child: _buildContentArea()),
//         ],
//       ),
//     );
//   }

//   // ------------------------ BARRE HORIZONTALE DES RUBRIQUES -------------------
//   Widget _buildCategoryBar() {
//     return SizedBox(
//       height: 95,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         itemCount: categories.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 16),
//         itemBuilder: (_, i) {
//           final item = categories[i];
//           final isActive = selectedCategory == item["label"];

//           return GestureDetector(
//             onTap: () {
//               setState(() {
//                 selectedCategory = item["label"];
//                 items.clear();
//                 _loadMore();
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
//                     item["icon"],
//                     color: isActive ? Colors.white : AppColors.textDark,
//                     size: 30,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   item["label"],
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // // ------------------------------ CONTENU DYNAMIQUE -------------------------
//   Widget _buildContentArea() {
//   switch (selectedCategory) {
//     case "Immobilier":
//       return _buildInfiniteList((index) {
//         final item = immobilierItems.isNotEmpty 
//                 ? immobilierItems[index % immobilierItems.length]
//                 : null;

//         if (item != null && item["mode"] == "Achat") {
//           return ImmobilierCard(
//             // title: item["title"]!,
//             // location: item["location"]!,
//             // price: item["price"]!,
//           );
//         } else {
//           return ImmobilierCard(
//             // title: item["title"]!,
//             // location: item["location"]!,
//             // price: item["price"]!,
//           );
//         }
//       });

//     case "Véhicules":
//       return _buildInfiniteList((index) {
//         final item = vehiculeItems[index % vehiculeItems.length];
//         if (item["mode"] == "Achat") {
//           return VehiculeCardSale(
//             // title: item["title"]!,
//             // location: item["location"]!,
//             // price: item["price"]!,
//           );
//         } else {
//           return VehiculeCardRent(
//             // title: item["title"]!,
//             // location: item["location"]!,
//             // price: item["price"]!,
//           );
//         }
//       });

//     case "Meubles":
//       return _buildInfiniteList((_) => const MeubleCard());

//     case "Hôtels":
//       return _buildInfiniteList((_) => const HotelCard());

//     default:
//       return const SizedBox();
//   }
// }


//   // ------------------------ LISTE INFINIE GÉNÉRIQUE -------------------------
//   Widget _buildInfiniteList(Widget Function(int) builder) {
//     return ListView.builder(
//       controller: _scrollController,
//       padding: const EdgeInsets.only(bottom: 16),
//       itemCount: items.length + 1,
//       itemBuilder: (_, index) {
//         if (index == items.length) {
//           return const Padding(
//             padding: EdgeInsets.all(16),
//             child: Center(child: CircularProgressIndicator(color: AppColors.primary,)),
//           );
//         }

//         return Align(
//           alignment: Alignment.center,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: builder(index),
//           ),
//         );
//       },
//     );
//   }
// }











// import 'package:flutter/material.dart';
// import '../../theme/colors.dart';

// // TES CARTES EXISTANTES
// import '../../components/immobilier_card.dart';
// import '../../components/meuble_card.dart';
// import '../../components/hotel_card.dart';
// // Ajoute voitureCard plus tard si tu l'as
// // import '../../components/vehicule_card.dart';

// class BiensScreen extends StatefulWidget {
//   const BiensScreen({super.key});

//   @override
//   State<BiensScreen> createState() => _BiensScreenState();
// }

// class _BiensScreenState extends State<BiensScreen> {
//   String selectedCategory = "Immobilier";
//   final ScrollController _scrollController = ScrollController();

//   List<String> items = []; // liste infinie → éléments chargés

//   @override
//   void initState() {
//     super.initState();
//     _loadMore(); // première charge

//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels >=
//           _scrollController.position.maxScrollExtent - 200) {
//         _loadMore();
//       }
//     });
//   }

//   void _loadMore() {
//     // Charger seulement si la rubrique supporte les listes infinies
//     if (!_isInfiniteCategory(selectedCategory)) return;

//     Future.delayed(const Duration(milliseconds: 400), () {
//       setState(() {
//         items.addAll(List.generate(10, (i) => "item_$i"));
//       });
//     });
//   }

//   bool _isInfiniteCategory(String cat) {
//     return ["Immobilier", "Meubles", "Véhicules", "Hôtels"].contains(cat);
//   }

//   // ------------------------------- RUBRIQUES --------------------------------
//   final List<Map<String, dynamic>> categories = [
//     {"icon": Icons.house, "label": "Immobilier"},
//     {"icon": Icons.chair, "label": "Meubles"},
//     {"icon": Icons.directions_car, "label": "Véhicules"},
//     {"icon": Icons.hotel, "label": "Hôtels"},
//     {"icon": Icons.history, "label": "Historique"},
//     {"icon": Icons.bookmark, "label": "Réservation"},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,

//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: const Text(
//           "Mes biens",
//           style: TextStyle(
//             color: AppColors.textDark,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         elevation: 0,
//         actions: [
//           IconButton(
//             onPressed: () {},
//             icon: const Icon(Icons.notifications, color: AppColors.textDark),
//           ),
//         ],
//       ),

//       body: Column(
//         children: [
//           const SizedBox(height: 10),
//           _buildCategoryBar(),
//           const SizedBox(height: 10),
//           // Expanded(child: _buildContentArea()),
//         ],
//       ),
//     );
//   }

//   // ------------------------ BARRE HORIZONTALE DES RUBRIQUES -------------------
//   Widget _buildCategoryBar() {
//     return SizedBox(
//       height: 95,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         itemCount: categories.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 16),
//         itemBuilder: (_, i) {
//           final item = categories[i];
//           final isActive = selectedCategory == item["label"];

//           return GestureDetector(
//             onTap: () {
//               setState(() {
//                 selectedCategory = item["label"];
//                 items.clear();
//                 _loadMore();
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
//                     item["icon"],
//                     color: isActive ? Colors.white : AppColors.textDark,
//                     size: 30,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   item["label"],
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ------------------------------ CONTENU DYNAMIQUE -------------------------
//   // Widget _buildContentArea() {
//   //   switch (selectedCategory) {
//   //     case "Immobilier":
//   //       return _buildInfiniteList((_) => const ImmobilierCard(), 260);

//   //     case "Meubles":
//   //       return _buildInfiniteList((_) => const MeubleCard(), 300);

//   //     case "Véhicules":
//   //       // Remplace par ta vraie carte véhicule
//   //       return _buildInfiniteList(
//   //         (_) => Container(
//   //           height: 120,
//   //           margin: const EdgeInsets.all(12),
//   //           color: Colors.grey.shade300,
//   //           child: const Center(child: Text("Carte Véhicule ici")),
//   //         ),
//   //         200,
//   //       );

//   //     case "Hôtels":
//   //       return _buildInfiniteList((_) => const HotelCard(), 260);

//   //     case "Historique":
//   //       return const Center(
//   //         child: Text("Historique de vos activités",
//   //             style: TextStyle(fontSize: 16)),
//   //       );

//   //     case "Réservation":
//   //       return const Center(
//   //         child: Text("Liste de vos réservations",
//   //             style: TextStyle(fontSize: 16)),
//   //       );

//   //     default:
//   //       return const SizedBox();
//   //   }
//   // }

//   // ------------------------ LISTE INFINIE GÉNÉRIQUE -------------------------
//   Widget _buildInfiniteList(Widget Function(int) builder, double cardHeight) {
//     return ListView.builder(
//       controller: _scrollController,
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       itemCount: items.length + 1,
//       itemBuilder: (_, index) {
//         if (index == items.length) {
//           return const Padding(
//             padding: EdgeInsets.all(16),
//             child: Center(child: CircularProgressIndicator()),
//           );
//         }
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           child: builder(index),
//         );
//       },
//     );
//   }
// }
