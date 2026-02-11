import 'package:flutter/material.dart';
import 'package:mobile/data/models/bien_model.dart';
import 'package:mobile/presentation/screens/Details/DetailScreen.dart';
import '../theme/colors.dart';

class MeubleCard extends StatelessWidget {
  final BienModel bien;

  const MeubleCard({super.key, required this.bien});

  @override
  Widget build(BuildContext context) {
    final String imageUrl = bien.images.isNotEmpty
        ? bien.images.first
        : "assets/images/meuble.jpg";


    final url = "https://api-location-plus.lamadonebenin.com/storage/";
  
    // Étiquette Achat/Location
    final String transactionLabel = (bien.transactionType?.toLowerCase() == 'achat')
        ? 'Achat'
        : (bien.transactionType?.toLowerCase() == 'location')
            ? 'Location'
            : 'Meuble';

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
                      url + imageUrl,
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
                    Icon(Icons.star, color: Colors.amber, size: 18),
                    Icon(Icons.star_half, color: Colors.amber, size: 18),
                    SizedBox(width: 6),
                    Text("(4)", style: TextStyle(fontSize: 12, color: Colors.white)),
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

                // BOUTON ACHETER + OEIL
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
                          child: const Center(
                            child: Text(
                              "Acheter",
                              style: TextStyle(
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

// class MeubleCard extends StatelessWidget {
//   final BienModel bien;

//   const MeubleCard({super.key, required this.bien});

//   @override
//   Widget build(BuildContext context) {
//     final String imageUrl = bien.images.isNotEmpty
//         ? bien.images.first
//         : "assets/images/meuble.jpg";

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
//                           height: 120,
//                           width: 260,
//                           fit: BoxFit.cover,
//                         )
//                       : Image.asset(
//                           imageUrl,
//                           height: 120,
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
//                       "Meuble",
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
//                   Icon(Icons.star, color: Colors.amber, size: 18),
//                   Icon(Icons.star_half, color: Colors.amber, size: 18),
//                   SizedBox(width: 6),
//                   Text("(4)", style: TextStyle(fontSize: 12)),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 4),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Text(
//                 bien.city ?? "Abomey-Calavi",
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






// import 'package:flutter/material.dart';
// import 'package:mobile/presentation/screens/Details/DetailScreen.dart';
// import '../theme/colors.dart';

// class MeubleCard extends StatelessWidget {
//   const MeubleCard({super.key});

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
//                   "assets/images/meuble.jpg",
//                   height: 120,
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
//                       "Meuble",
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
//                 "Meuble de salon",
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
//                   Icon(Icons.star, color: Colors.amber, size: 18),
//                   Icon(Icons.star_half, color: Colors.amber, size: 18),
//                   SizedBox(width: 6),
//                   Text("(4)", style: TextStyle(fontSize: 12)),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 4),

//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 10),
//               child: Text("Abomey-Calavi", style: TextStyle(fontSize: 12)),
//             ),

//             const SizedBox(height: 6),

//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 10),
//               child: Text(
//                 "350,000 F",
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
//                                 type: DetailType.Meuble,
//                                 title: "Canapé moderne 3 places",
//                                 location: "Cotonou, Zogbo",
//                                 price: "120,000 F",
//                                 description: "Canapé confortable avec revêtement en cuir synthétique, idéal pour salon moderne.",
//                                 imageUrl: "assets/images/meuble.jpg",
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




















// import 'package:flutter/material.dart';
// import '../theme/colors.dart';

// class MeubleCard extends StatelessWidget {
//   final String image;
//   final String title;
//   final double price;
//   final String location;
//   final double rating;
//   final int ratingCount;
//   final VoidCallback? onBuy;
//   final VoidCallback? onView;
//   final VoidCallback? onFavorite;

//   const MeubleCard({
//     super.key,
//     required this.image,
//     required this.title,
//     required this.price,
//     required this.location,
//     required this.rating,
//     required this.ratingCount,
//     this.onBuy,
//     this.onView,
//     this.onFavorite,
//   });

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
//                   image,
//                   height: 120,
//                   width: 260,
//                   fit: BoxFit.cover,
//                 ),

//                 // TAG
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
//                       "Meuble",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),

//                 // FAVORI
//                 Positioned(
//                   top: 8,
//                   right: 10,
//                   child: GestureDetector(
//                     onTap: onFavorite,
//                     child: const CircleAvatar(
//                       radius: 16,
//                       backgroundColor: Colors.white,
//                       child: Icon(Icons.favorite_border),
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 8),

//             // TITRE
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Text(
//                 title,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//             ),

//             const SizedBox(height: 4),

//             // RATING
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Row(
//                 children: [
//                   ...List.generate(
//                     5,
//                     (index) => Icon(
//                       index + 1 <= rating ? Icons.star : Icons.star_border,
//                       color: Colors.amber,
//                       size: 18,
//                     ),
//                   ),
//                   const SizedBox(width: 6),
//                   Text("($ratingCount)", style: const TextStyle(fontSize: 12)),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 4),

//             // LOCALISATION
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Text(location, style: const TextStyle(fontSize: 12)),
//             ),

//             const SizedBox(height: 6),

//             // PRIX
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Text(
//                 "${price.toStringAsFixed(0)} F",
//                 style: const TextStyle(
//                   fontSize: 17,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.red,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 8),

//             // BOUTONS ACTION
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: onBuy,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         decoration: BoxDecoration(
//                           color: AppColors.primary,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
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
//                   GestureDetector(
//                     onTap: onView,
//                     child: Container(
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         color: Colors.black12,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Icon(Icons.remove_red_eye),
//                     ),
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
