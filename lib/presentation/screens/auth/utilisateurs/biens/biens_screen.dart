import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/business/providers/bien_controller_provider.dart';
import 'package:mobile/data/models/bien_model.dart';
import 'dart:async';
import 'package:mobile/presentation/screens/auth/utilisateurs/biens/add_bien_screen.dart';
import 'package:mobile/presentation/screens/auth/utilisateurs/biens/edit_bien_screen.dart';
import 'package:mobile/presentation/theme/colors.dart';
import 'package:mobile/presentation/widgets/bien_card.dart';


class MesBiensScreen extends ConsumerStatefulWidget {
  const MesBiensScreen({super.key});

  @override
  ConsumerState<MesBiensScreen> createState() => _MesBiensScreenState();
}

class _MesBiensScreenState extends ConsumerState<MesBiensScreen> {
  String selectedCategory = "Tous";
  final List<String> categories = [
    "Tous",
    "Immobilier",
    "Vehicule",
    "Meuble",
    "Hotel",
    "Hebergement",
  ];

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(bienControllerProvider.notifier).fetchUserBiens();
    });
  }

  @override
  Widget build(BuildContext context) {
    final biensAsync = ref.watch(bienControllerProvider); // AsyncValue<List<BienModel>>

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Mes Biens",
          style: TextStyle(color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, size: 28, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddBiensScreen()),
          ).then((_) => ref.read(bienControllerProvider.notifier).fetchUserBiens());
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            //------------------- CATEGORIES -------------------
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (_, i) {
                  final cat = categories[i];
                  final isActive = selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => selectedCategory = cat),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(color: isActive ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            //------------------- LISTE DES BIENS -------------------
            Expanded(
              child: biensAsync.when(
                data: (biens) {
                  // 1️⃣ Ne garder que les biens actifs
                  final actifs = biens.where((b) => b.actif == true).toList();

                  // 2️⃣ Appliquer le filtre par catégorie
                  final biensFiltered = selectedCategory == "Tous"
                      ? actifs
                      : actifs
                          .where(
                            (b) =>
                                b.category.toLowerCase() ==
                                selectedCategory.toLowerCase(),
                          )
                          .toList();

                  if (biensFiltered.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: biensFiltered.length,
                    itemBuilder: (_, i) => buildBienCard(biensFiltered[i]),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (err, stack) => Center(
                  child: Text("Erreur: $err"),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  //---------------- AUCUN BIEN ----------------
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "Aucun bien ajouté",
            style: TextStyle(fontSize: 18, color: AppColors.textDark, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            "Ajoutez vos biens afin de les gérer facilement",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  //---------------- CARTE BIEN ----------------
  Widget buildBienCard(BienModel item) => BienCard(item: item, ref: ref, onDelete: () async {
        final success = await ref.read(bienControllerProvider.notifier).deleteBien(int.parse(item.id));
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erreur lors de la suppression"), backgroundColor: Colors.red),
          );
        } else {
          ref.read(bienControllerProvider.notifier).fetchUserBiens();
        }
      });
}












// import 'package:flutter/material.dart';
// import 'package:mobile/presentation/screens/auth/utilisateurs/biens/add_bien_screen.dart';
// import 'package:mobile/presentation/theme/colors.dart';

// class MesBiensScreen extends StatefulWidget {
//   const MesBiensScreen({super.key});

//   @override
//   State<MesBiensScreen> createState() => _MesBiensScreenState();
// }

// class _MesBiensScreenState extends State<MesBiensScreen> {
//   String selectedCategory = "Tous";

//   final List<String> categories = [
//     "Tous",
//     "Immobilier",
//     "Véhicules",
//     "Meubles",
//     "Hôtels",
//   ];

//   final List<Map<String, dynamic>> userBiens = [
//     {
//       "type": "Immobilier",
//       "mode": "Location",
//       "image": "assets/images/chambre.jpg",
//       "titre": "Appartement Moderne 2 Chambres",
//       "lieu": "Abomey-Calavi, Godomey",
//       "prix": "120 000 F / mois",
//       "description": "Superbe appartement moderne situé dans un quartier calme...",
//       "expanded": false,
//     },
//     {
//       "type": "Véhicules",
//       "mode": "Achat",
//       "image": "assets/images/vehicule.png",
//       "titre": "Toyota Corolla 2015",
//       "lieu": "Cotonou, Ste Rita",
//       "prix": "3 200 000 F",
//       "description": "Voiture en très bon état, économique et confortable...",
//       "expanded": false,
//     },
//     {
//       "type": "Meubles",
//       "image": "assets/images/meuble.jpg",
//       "titre": "Canapé 3 Places",
//       "prix": "85 000 F",
//       "description": "Canapé confortable idéal pour salon moderne...",
//       "expanded": false,
//     },
//     {
//       "type": "Hôtels",
//       "image": "assets/images/hotel.jpg",
//       "titre": "Chambre Deluxe",
//       "lieu": "Cotonou, Fidjrossè",
//       "prix": "18 000 F / nuit",
//       "description": "Chambre spacieuse avec vue mer et petit-déjeuner inclus...",
//       "expanded": false,
//     }
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final biensFiltered = selectedCategory == "Tous"
//         ? userBiens
//         : userBiens.where((b) => b["type"] == selectedCategory).toList();

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           "Mes Biens",
//           style: TextStyle(
//             color: AppColors.textDark,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {},
//             icon: const Icon(Icons.search, color: AppColors.textDark),
//           ),
//         ],
//       ),

//       floatingActionButton: FloatingActionButton(
//         backgroundColor: AppColors.primary,
//         child: const Icon(Icons.add, size: 28, color: Colors.white),
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const AddBiensScreen()),
//           );
//         },
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // ------------------ CATEGORIES ------------------
//             SizedBox(
//               height: 45,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: categories.length,
//                 itemBuilder: (_, i) {
//                   final cat = categories[i];
//                   final isActive = selectedCategory == cat;

//                   return GestureDetector(
//                     onTap: () => setState(() => selectedCategory = cat),
//                     child: Container(
//                       margin: const EdgeInsets.only(right: 10),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 18, vertical: 10),
//                       decoration: BoxDecoration(
//                         color: isActive ? AppColors.primary : Colors.grey.shade100,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         cat,
//                         style: TextStyle(
//                           color: isActive ? Colors.white : Colors.black87,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             const SizedBox(height: 20),

//             // ------------------ LISTE DES BIENS ------------------
//             Expanded(
//               child: biensFiltered.isEmpty
//                   ? _buildEmptyState()
//                   : ListView.builder(
//                       padding: const EdgeInsets.only(top: 10),
//                       itemCount: biensFiltered.length,
//                       itemBuilder: (_, i) {
//                         final item = biensFiltered[i];

//                         return Center(
//                           child: Container(
//                             width: MediaQuery.of(context).size.width * 0.92,
//                             margin: const EdgeInsets.only(bottom: 18),
//                             child: buildBienCardVariant4(item, i),
//                           ),
//                         );
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ---------------------- EMPTY STATE ----------------------
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.inventory_2, size: 80, color: Colors.grey.shade300),
//           const SizedBox(height: 16),
//           const Text(
//             "Aucun bien ajouté",
//             style: TextStyle(
//               fontSize: 18,
//               color: AppColors.textDark,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             "Ajoutez vos biens afin de les gérer facilement",
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey.shade600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ------------------ CARTE VARIANTE 4 ------------------
//   Widget buildBienCardVariant4(Map<String, dynamic> item, int index) {
//     final bool isExpanded = item["expanded"] ?? false;
//     return GestureDetector(
//       onTap: () {},
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 250),
//         curve: Curves.easeOut,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(18),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.06),
//               blurRadius: 8,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // IMAGE
//             ClipRRect(
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(18),
//                 topRight: Radius.circular(18),
//               ),
//               child: Image.asset(
//                 item["image"],
//                 height: 160,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//               ),
//             ),

//             // TITRE + MENU
//             Padding(
//               padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Text(
//                       item["titre"],
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),

//                   PopupMenuButton(
//                     icon: const Icon(Icons.more_vert, color: Colors.black87),
//                     elevation: 4,
//                     onSelected: (value) {
//                       if (value == "edit") {
//                         // open edit
//                       } else if (value == "delete") {
//                         // delete item
//                       }
//                     },
//                     itemBuilder: (context) => [
//                       const PopupMenuItem(
//                         value: "edit",
//                         child: Text("Modifier"),
//                       ),
//                       const PopupMenuItem(
//                         value: "delete",
//                         child: Text("Supprimer"),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             // DESCRIPTION
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 14),
//               child: Text(
//                 item["description"],
//                 maxLines: item["expanded"] ? 10 : 2,
//                 overflow:
//                     item["expanded"] ? TextOverflow.visible : TextOverflow.ellipsis,
//                 softWrap: true,
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: Colors.grey.shade700,
//                   height: 1.35,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 8),

//             // BOUTON VOIR PLUS / MOINS
//             InkWell(
//               onTap: () {
//                 setState(() {
//                   item["expanded"] = !item["expanded"];
//                 });
//               },
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
//                 child: Text(
//                   item["expanded"] ? "Voir moins ↑" : "Voir plus →",
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.blue.shade600,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ),

//             // INFORMATIONS SUPPLÉMENTAIRES
//             if (item["expanded"]) ...[
//               const Divider(height: 1),

//               Padding(
//                 padding: const EdgeInsets.all(14),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     if (item["mode"] != null)
//                       Text("Mode : ${item["mode"]}",
//                           style: _infoStyle()),

//                     if (item["prix"] != null)
//                       Text("Prix : ${item["prix"]}",
//                           style: _infoStyle()),

//                     if (item["lieu"] != null)
//                       Text("Lieu : ${item["lieu"]}",
//                           style: _infoStyle()),
//                   ],
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   TextStyle _infoStyle() {
//     return TextStyle(
//       fontSize: 13,
//       color: Colors.grey.shade800,
//       height: 1.4,
//       fontWeight: FontWeight.w500,
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:mobile/presentation/screens/auth/utilisateurs/biens/add_bien_screen.dart';
// import 'package:mobile/presentation/theme/colors.dart';

// class MesBiensScreen extends StatefulWidget {
//   const MesBiensScreen({super.key});

//   @override
//   State<MesBiensScreen> createState() => _MesBiensScreenState();
// }

// class _MesBiensScreenState extends State<MesBiensScreen> {
//   String selectedCategory = "Tous";

//   final List<String> categories = [
//     "Tous",
//     "Immobilier",
//     "Véhicules",
//     "Meubles",
//     "Hôtels",
//   ];

//   final List<Map<String, dynamic>> userBiens = [
//     {
//       "categorie": "Immobilier",
//       "mode": "Location",
//       "image": "assets/images/chambre.jpg",
//       "titre": "Appartement Moderne 2 Chambres",
//       "lieu": "Abomey-Calavi, Godomey",
//       "prix": "120 000 F / mois",
//       "description": "Superbe appartement moderne situé dans un quartier calme...",
//     },
//     {
//       "categorie": "Véhicules",
//       "mode": "Achat",
//       "image": "assets/images/vehicule.png",
//       "titre": "Toyota Corolla 2015",
//       "lieu": "Cotonou, Ste Rita",
//       "prix": "3 200 000 F",
//       "description": "Voiture en très bon état, économique et confortable...",
//     },
//     {
//       "categorie": "Meubles",
//       "image": "assets/images/meuble.jpg",
//       "titre": "Canapé 3 Places",
//       "prix": "85 000 F",
//       "description": "Canapé confortable idéal pour salon moderne...",
//     },
//     {
//       "categorie": "Hôtels",
//       "image": "assets/images/hotel.jpg",
//       "titre": "Chambre Deluxe",
//       "lieu": "Cotonou, Fidjrossè",
//       "prix": "18 000 F / nuit",
//       "description": "Chambre spacieuse avec vue mer et petit-déjeuner inclus...",
//     }
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final biensFiltered = selectedCategory == "Tous"
//         ? userBiens
//         : userBiens.where((b) => b["categorie"] == selectedCategory).toList();

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           "Mes Biens",
//           style: TextStyle(
//             color: AppColors.textDark,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {},
//             icon: const Icon(Icons.search, color: AppColors.textDark),
//           ),
//         ],
//       ),

//       floatingActionButton: FloatingActionButton(
//         backgroundColor: AppColors.primary,
//         child: const Icon(Icons.add, size: 28, color: Colors.white),
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const AddBiensScreen()),
//           );
//         },
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // ------------------ CATEGORIES ------------------
//             SizedBox(
//               height: 45,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: categories.length,
//                 itemBuilder: (_, i) {
//                   final cat = categories[i];
//                   final isActive = selectedCategory == cat;

//                   return GestureDetector(
//                     onTap: () => setState(() => selectedCategory = cat),
//                     child: Container(
//                       margin: const EdgeInsets.only(right: 10),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 18, vertical: 10),
//                       decoration: BoxDecoration(
//                         color: isActive ? AppColors.primary : Colors.grey.shade100,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         cat,
//                         style: TextStyle(
//                           color: isActive ? Colors.white : Colors.black87,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             const SizedBox(height: 20),

//             // ------------------ LISTE DES BIENS ------------------
//             Expanded(
//               child: biensFiltered.isEmpty
//                   ? _buildEmptyState()
//                   : ListView.builder(
//                       padding: const EdgeInsets.only(top: 10),
//                       itemCount: biensFiltered.length,
//                       itemBuilder: (_, i) {
//                         final item = biensFiltered[i];

//                         return Center(
//                           child: Container(
//                             width: MediaQuery.of(context).size.width * 0.92,
//                             margin: const EdgeInsets.only(bottom: 18),
//                             child: buildBienCardVariant4(
//                               imageUrl: item["image"],
//                               title: item["titre"],
//                               description: item["description"] ?? "",
//                               onTap: () {
//                                 // Navigation future vers détails
//                               },
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ------------------ AUCUN BIEN ------------------
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.inventory_2, size: 80, color: Colors.grey.shade300),
//           const SizedBox(height: 16),
//           const Text(
//             "Aucun bien ajouté",
//             style: TextStyle(
//               fontSize: 18,
//               color: AppColors.textDark,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             "Ajoutez vos biens afin de les gérer facilement",
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey.shade600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ------------------ NOUVELLE CARTE VARIANTE 4 ------------------
//   // ------------------ NOUVELLE CARTE VARIANTE 4 ------------------
// Widget buildBienCardVariant4({
//   required String imageUrl,
//   required String title,
//   required String description,
//   required VoidCallback onTap,
// }) {
//   return GestureDetector(
//     onTap: onTap,
//     child: Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // IMAGE FIXE
//           ClipRRect(
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(18),
//               topRight: Radius.circular(18),
//             ),
//             child: Image.asset(
//               imageUrl,
//               height: 160, // hauteur fixe pour laisser de l'espace au texte
//               width: double.infinity,
//               fit: BoxFit.cover,
//             ),
//           ),

//           // TEXTES
//           Padding(
//             padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),

//                 const SizedBox(height: 6),

//                 Text(
//                   description,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   softWrap: true, // ⚡️ Ajouté pour forcer l'affichage du texte
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.grey.shade700,
//                     height: 1.35,
//                   ),
//                 ),

//                 const SizedBox(height: 8),

//                 Text(
//                   "Voir plus →",
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.blue.shade600,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

// }



// import 'package:flutter/material.dart';
// import 'package:mobile/presentation/theme/colors.dart';
// import '../../../../theme/colors.dart';

// class MesBiensScreen extends StatelessWidget {
//   const MesBiensScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         title: const Text(
//           "Mes Biens",
//           style: TextStyle(
//             color: AppColors.textDark,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           _bienItem(
//             context,
//             title: "Maison moderne 3 chambres",
//             statut: "Publié",
//             image: "assets/images/house.jpg",
//           ),
//           _bienItem(
//             context,
//             title: "Toyota Corolla 2015",
//             statut: "En attente",
//             image: "assets/images/car.jpg",
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _bienItem(BuildContext context,
//       {required String title, required String statut, required String image}) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 2,
//       child: Column(
//         children: [
//           ClipRRect(
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//             child: Image.asset(image, height: 150, width: double.infinity, fit: BoxFit.cover),
//           ),
//           ListTile(
//             title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//             subtitle: Text("Statut : $statut"),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _btn(Icons.edit, "Modifier", Colors.blue, () {}),
//               _btn(Icons.delete, "Supprimer", Colors.red, () {}),
//               _btn(Icons.settings, "Gérer", AppColors.primary, () {}),
//             ],
//           ),
//           const SizedBox(height: 12),
//         ],
//       ),
//     );
//   }

//   Widget _btn(IconData icon, String label, Color color, VoidCallback onTap) {
//     return TextButton.icon(
//       onPressed: onTap,
//       icon: Icon(icon, color: color),
//       label: Text(label, style: TextStyle(color: color)),
//     );
//   }
// }
