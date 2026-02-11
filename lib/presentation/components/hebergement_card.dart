import 'package:flutter/material.dart';
import 'package:mobile/presentation/screens/Details/DetailScreen.dart';
import '../theme/colors.dart';
import '../../data/models/bien_model.dart';

class HebergementCard extends StatelessWidget {
  final BienModel bien;

  const HebergementCard({super.key, required this.bien});

  @override
  Widget build(BuildContext context) {
    final imageUrl = bien.images.isNotEmpty
        ? bien.images.first
        : "assets/images/hotel.jpg";
    
    final url = "https://api-location-plus.lamadonebenin.com/storage/";

    return Container(
      width: 240,
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
                      width: 240,
                      fit: BoxFit.cover,
                    ),
            ),
          ),

          // ❤️ COEUR FAVORI
          const Positioned(
            top: 10,
            right: 10,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.favorite_border,
                color: AppColors.primary,
              ),
            ),
          ),

          // CONTENU
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Text(
                  bien.city ?? "Localisation inconnue",
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  "Une Chambre",
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  "${bien.price.toStringAsFixed(0)} F /nuit",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
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
                          builder: (_) => DetailScreen(bien: bien,),
                        ),
                      );
                    },
                    child: const Center(
                      child: Text(
                        "Réserver",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
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
// import 'package:mobile/presentation/screens/Details/DetailScreen.dart';
// import '../theme/colors.dart';


// class HebergementCard extends StatelessWidget {
//   const HebergementCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 240,
//       margin: const EdgeInsets.only(right: 16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12.withOpacity(.05),
//             blurRadius: 6,
//             spreadRadius: 2,
//           ),
//         ],
//       ),
//       child: Stack(
//         children: [
//           // IMAGE AVEC OPACITÉ
//           ClipRRect(
//             borderRadius: BorderRadius.circular(16),
//             child: ColorFiltered(
//               colorFilter: ColorFilter.mode(
//                 Colors.black.withOpacity(0.35),
//                 BlendMode.darken,
//               ),
//               child: Image.asset(
//                 "assets/images/hotel.jpg",
//                 height: 260,
//                 width: 240,
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),

//           // ❤️ COEUR FAVORI
//           const Positioned(
//             top: 10,
//             right: 10,
//             child: CircleAvatar(
//               radius: 16,
//               backgroundColor: Colors.white,
//               child: Icon(
//                 Icons.favorite_border,
//                 color: AppColors.primary,
//               ),
//             ),
//           ),

//           // CONTENU
//           Positioned(
//             left: 12,
//             right: 12,
//             bottom: 12,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Résidence à Cotonou",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),

//                 const Text(
//                   "Cotonou",
//                   style: TextStyle(color: Colors.white, fontSize: 14),
//                 ),

//                 const Text(
//                   "Une Chambre",
//                   style: TextStyle(color: Colors.white70, fontSize: 13),
//                 ),

//                 const SizedBox(height: 8),

//                 const Text(
//                   "22,000 F /nuit",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),

//                 const SizedBox(height: 12),

//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   decoration: BoxDecoration(
//                     color: AppColors.primary,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => DetailScreen(
//                             type: DetailType.Hotel,
//                             title: "Hôtel La Riviera",
//                             location: "Cotonou, Fidjrossè",
//                             price: "50,000 F /nuit",
//                             description: "Chambre confortable avec vue sur la mer, petit-déjeuner inclus.",
//                             imageUrl: "assets/images/hotel.jpg",
//                             action: ActionType.Reserver,
//                           ),
//                         ),
//                       );
//                     },
//                     child: const Center(
//                       child: Text(
//                         "Réserver",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                   ),

//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
