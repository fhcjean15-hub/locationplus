import 'package:flutter/material.dart';
import 'package:mobile/presentation/screens/Details/DetailScreen.dart';
import '../theme/colors.dart';
import '../../data/models/bien_model.dart';

class VehiculeCard extends StatelessWidget {
  final BienModel bien;

  const VehiculeCard({super.key, required this.bien});

  @override
  Widget build(BuildContext context) {
    final imageUrl = bien.images.isNotEmpty
        ? bien.images.first
        : "assets/images/vehicule.png";
        
    final url = "https://api-location-plus.lamadonebenin.com/storage/";

    // Déterminer étiquette et bouton selon transactionType
    final isVente = bien.transactionType?.toLowerCase() == 'vente';
    final isLocation = bien.transactionType?.toLowerCase() == 'location';
    final transactionLabel = isVente
        ? 'Achat'
        : isLocation
            ? 'Louer'
            : 'Vente';
    final buttonText = isVente
        ? 'Acheter'
        : isLocation
            ? 'Louer'
            : 'Acheter';

    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(.05),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // IMAGE AVEC OPACITÉ
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.35),
                BlendMode.darken,
              ),
              child: Image.network(
                      url+ imageUrl,
                      height: 260,
                      width: 260,
                      fit: BoxFit.cover,
                    ),
            ),
          ),

          // ÉTIQUETTE + FAVORI
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                transactionLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const Positioned(
            top: 8,
            right: 10,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Icon(Icons.favorite_border, color: AppColors.primary),
            ),
          ),

          // CONTENU SUR IMAGE
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TITRE
                Text(
                  bien.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                // LOCALISATION
                Text(
                  bien.city ?? "Localisation inconnue",
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),

                // ÉTOILES
                Row(
                  children: const [
                    Icon(Icons.star, color: Colors.amber, size: 18),
                    Icon(Icons.star, color: Colors.amber, size: 18),
                    Icon(Icons.star, color: Colors.amber, size: 18),
                    Icon(Icons.star_half, color: Colors.amber, size: 18),
                    Icon(Icons.star_border, color: Colors.amber, size: 18),
                    SizedBox(width: 6),
                    Text("(23)", style: TextStyle(fontSize: 12, color: Colors.white)),
                  ],
                ),

                const SizedBox(height: 8),

                // PRIX
                Text(
                  "${bien.price.toStringAsFixed(0)} F",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // BOUTON + OEIL
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(bien: bien),
                              ),
                            );
                          },
                          child: Center(
                            child: Text(
                              buttonText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.remove_red_eye, color: Colors.white),
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
}



// import 'package:flutter/material.dart';
// import 'package:mobile/data/models/bien_model.dart';
// import 'package:mobile/presentation/screens/Details/DetailScreen.dart';
// import '../theme/colors.dart';

// class VehiculeCardSale extends StatelessWidget {
//   final BienModel bien;

//   const VehiculeCardSale({super.key, required this.bien});

//   @override
//   Widget build(BuildContext context) {
//     final String imageUrl = bien.images.isNotEmpty
//         ? bien.images.first
//         : "assets/images/vehicule.png";

//     return ClipRRect(
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         width: 260,
//         margin: const EdgeInsets.only(right: 16),
//         color: Colors.white,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // IMAGE + TAG + FAVORI
//             Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//                   child: imageUrl.startsWith('http')
//                       ? Image.network(
//                           imageUrl,
//                           height: 80,
//                           width: 260,
//                           fit: BoxFit.cover,
//                         )
//                       : Image.asset(
//                           imageUrl,
//                           height: 80,
//                           width: 260,
//                           fit: BoxFit.cover,
//                         ),
//                 ),
//                 Positioned(
//                   top: 10,
//                   left: 10,
//                   child: Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//                     decoration: BoxDecoration(
//                       color: AppColors.primary,
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     child: const Text(
//                       "Achat",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const Positioned(
//                   top: 8,
//                   right: 10,
//                   child: CircleAvatar(
//                     radius: 16,
//                     backgroundColor: Colors.white,
//                     child: Icon(Icons.favorite_border, color: AppColors.primary),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 8),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Text(
//                 bien.title,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//             ),

//             const SizedBox(height: 4),

//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 10),
//               child: Row(
//                 children: [
//                   Icon(Icons.star, color: Colors.amber, size: 18),
//                   Icon(Icons.star, color: Colors.amber, size: 18),
//                   Icon(Icons.star, color: Colors.amber, size: 18),
//                   Icon(Icons.star_half, color: Colors.amber, size: 18),
//                   Icon(Icons.star_border, color: Colors.amber, size: 18),
//                   SizedBox(width: 6),
//                   Text("(23)", style: TextStyle(fontSize: 12)),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 4),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Text(
//                 bien.city ?? "Cotonou, Gbégamey",
//                 style: const TextStyle(fontSize: 12),
//               ),
//             ),

//             const SizedBox(height: 6),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Text(
//                 "${bien.price.toStringAsFixed(0)} F",
//                 style: const TextStyle(
//                   fontSize: 17,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.red,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 8),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       decoration: BoxDecoration(
//                         color: AppColors.primary,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => DetailScreen(bien: bien),
//                             ),
//                           );
//                         },
//                         child: const Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.shopping_cart, color: Colors.white),
//                             SizedBox(width: 6),
//                             Text(
//                               "Acheter",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: Colors.black12,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: const Icon(Icons.remove_red_eye),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 10),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class VehiculeCardRent extends StatelessWidget {
//   final BienModel bien;

//   const VehiculeCardRent({super.key, required this.bien});

//   @override
//   Widget build(BuildContext context) {
//     final String imageUrl = bien.images.isNotEmpty
//         ? bien.images.first
//         : "assets/images/voiture.png";

//     return ClipRRect(
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         width: 260,
//         margin: const EdgeInsets.only(right: 16),
//         color: Colors.white,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // IMAGE + TAG + FAVORI
//             Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//                   child: imageUrl.startsWith('http')
//                       ? Image.network(
//                           imageUrl,
//                           height: 100,
//                           width: 260,
//                           fit: BoxFit.cover,
//                         )
//                       : Image.asset(
//                           imageUrl,
//                           height: 100,
//                           width: 260,
//                           fit: BoxFit.cover,
//                         ),
//                 ),
//                 Positioned(
//                   top: 10,
//                   left: 10,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//                     decoration: BoxDecoration(
//                       color: Colors.orange,
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     child: const Text(
//                       "Location",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const Positioned(
//                   top: 8,
//                   right: 10,
//                   child: CircleAvatar(
//                     radius: 16,
//                     backgroundColor: Colors.white,
//                     child: Icon(Icons.favorite_border, color: AppColors.primary),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 8),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Text(
//                 bien.title,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//             ),

//             const SizedBox(height: 4),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Text(
//                 bien.transactionType == 'location'
//                     ? "${bien.price.toStringAsFixed(0)} F / jour"
//                     : "${bien.price.toStringAsFixed(0)} F",
//                 style: const TextStyle(
//                   fontSize: 17,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.primary,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 4),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Text(
//                 bien.city ?? "Cotonou, Akpakpa",
//                 style: const TextStyle(fontSize: 12),
//               ),
//             ),

//             const SizedBox(height: 8),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       decoration: BoxDecoration(
//                         color: Colors.orange,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => DetailScreen(bien: bien),
//                             ),
//                           );
//                         },
//                         child: const Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.directions_car, color: Colors.white),
//                             SizedBox(width: 6),
//                             Text(
//                               "Louer",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: Colors.black12,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: const Icon(Icons.remove_red_eye),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 10),
//           ],
//         ),
//       ),
//     );
//   }
// }







// import 'package:flutter/material.dart';
// import 'package:mobile/presentation/screens/Details/DetailScreen.dart';
// import '../theme/colors.dart';

// class VehiculeCardSale extends StatelessWidget {
//   const VehiculeCardSale({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         width: 260,
//         margin: const EdgeInsets.only(right: 16),
//         color: Colors.white,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // IMAGE + TAG + FAVORI
//             Stack(
//               children: [
//                 Image.asset(
//                   "assets/images/vehicule.png", // ← change selon ton image
//                   height: 80,
//                   width: 260,
//                   fit: BoxFit.cover,
//                 ),

//                 Positioned(
//                   top: 10,
//                   left: 10,
//                   child: Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//                     decoration: BoxDecoration(
//                       color: AppColors.primary,
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     child: const Text(
//                       "Achat",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),

//                 Positioned(
//                   top: 8,
//                   right: 10,
//                   child: CircleAvatar(
//                     radius: 16,
//                     backgroundColor: Colors.white,
//                     child: Icon(Icons.favorite_border,
//                         color: AppColors.primary),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 8),

//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 10),
//               child: Text(
//                 "Toyota Corolla 2018",
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//             ),

//             const SizedBox(height: 4),

//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 10),
//               child: Row(
//                 children: [
//                   Icon(Icons.star, color: Colors.amber, size: 18),
//                   Icon(Icons.star, color: Colors.amber, size: 18),
//                   Icon(Icons.star, color: Colors.amber, size: 18),
//                   Icon(Icons.star_half, color: Colors.amber, size: 18),
//                   Icon(Icons.star_border, color: Colors.amber, size: 18),
//                   SizedBox(width: 6),
//                   Text("(23)", style: TextStyle(fontSize: 12)),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 4),

//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 10),
//               child: Text("Cotonou, Gbégamey",
//                   style: TextStyle(fontSize: 12)),
//             ),

//             const SizedBox(height: 6),

//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 10),
//               child: Text(
//                 "6,500,000 F",
//                 style: TextStyle(
//                   fontSize: 17,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.red,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 8),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       decoration: BoxDecoration(
//                         color: AppColors.primary,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => DetailScreen(
//                                 type: DetailType.Vehicule,
//                                 title: "Toyota Corolla 2020",
//                                 location: "Cotonou, Fidjrossè",
//                                 price: "8,500,000 F",
//                                 description: "Voiture en excellent état, faible kilométrage, idéale pour la ville et les longs trajets.",
//                                 imageUrl: "assets/images/voiture.png",
//                                 action: ActionType.Acheter,
//                               ),
//                             ),
//                           );
//                         },
//                         child: const Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.shopping_cart, color: Colors.white),
//                             SizedBox(width: 6),
//                             Text(
//                               "Acheter",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),


//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: Colors.black12,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: const Icon(Icons.remove_red_eye),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 10),
//           ],
//         ),
//       ),
//     );
//   }
// }


// class VehiculeCardRent extends StatelessWidget {
//   const VehiculeCardRent({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         width: 260,
//         margin: const EdgeInsets.only(right: 16),
//         color: Colors.white,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // IMAGE + TAG + FAVORI
//             Stack(
//               children: [
//                 Image.asset(
//                   "assets/images/voiture.png", // ← ton image location
//                   height: 100,
//                   width: 260,
//                   fit: BoxFit.cover,
//                 ),

//                 Positioned(
//                   top: 10,
//                   left: 10,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 12, vertical: 5),
//                     decoration: BoxDecoration(
//                       color: Colors.orange,
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     child: const Text(
//                       "Location",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),

//                 Positioned(
//                   top: 8,
//                   right: 10,
//                   child: CircleAvatar(
//                     radius: 16,
//                     backgroundColor: Colors.white,
//                     child: Icon(Icons.favorite_border,
//                         color: AppColors.primary),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 8),

//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 10),
//               child: Text(
//                 "Hyundai Tucson 2021",
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//             ),

//             const SizedBox(height: 4),

//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 10),
//               child: Text(
//                 "45 000 F / jour",
//                 style: TextStyle(
//                   fontSize: 17,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.primary,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 4),

//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 10),
//               child: Text(
//                 "Cotonou, Akpakpa",
//                 style: TextStyle(fontSize: 12),
//               ),
//             ),

//             const SizedBox(height: 8),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       decoration: BoxDecoration(
//                         color: Colors.orange,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => DetailScreen(
//                                 type: DetailType.Vehicule,
//                                 title: "Toyota Corolla 2020",
//                                 location: "Cotonou, Fidjrossè",
//                                 price: "150,000 F /mois",
//                                 description: "Voiture disponible à la location, bien entretenue et économique.",
//                                 imageUrl: "assets/images/voiture.png",
//                                 action: ActionType.Louer,
//                               ),
//                             ),
//                           );
//                         },
//                         child: const Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.directions_car, color: Colors.white),
//                             SizedBox(width: 6),
//                             Text(
//                               "Louer",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),


//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: Colors.black12,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: const Icon(Icons.remove_red_eye),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 10),
//           ],
//         ),
//       ),
//     );
//   }
// }
