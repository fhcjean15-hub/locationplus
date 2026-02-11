import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile/data/models/bien_model.dart';
import 'package:mobile/presentation/screens/Details/DetailScreen.dart';
import 'package:mobile/presentation/theme/colors.dart';

class ImmobilierCard extends StatefulWidget {
  final BienModel bien;

  const ImmobilierCard({
    super.key,
    required this.bien,
  });

  @override
  State<ImmobilierCard> createState() => _ImmobilierCardState();
}

class _ImmobilierCardState extends State<ImmobilierCard> {
  bool isPressed = false;
  Timer? overlayTimer;
  final url = "https://api-location-plus.lamadonebenin.com/storage/";

  void _showOverlay() {
    setState(() => isPressed = true);
    overlayTimer?.cancel();
    overlayTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => isPressed = false);
      }
    });
  }

  void _hideOverlay() {
    overlayTimer?.cancel();
    setState(() => isPressed = false);
  }

  @override
  void dispose() {
    overlayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.bien.images.isNotEmpty
        ? widget.bien.images.first
        : "assets/images/chambre.jpg";

    return GestureDetector(
      onTapDown: (_) => _showOverlay(),
      onTapCancel: _hideOverlay,
      onTapUp: (_) {},
      onTap: () {},
      child: Stack(
        children: [
          // ---------------- CARD ----------------
          Container(
            width: 240,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(.06),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMAGE + TAG + FAVORI
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.network(
                              url + imageUrl,
                              height: 130,
                              width: 240,
                              fit: BoxFit.cover,
                            ),
                    ),

                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          widget.bien.transactionType == 'vente'
                          ? 'Achat'
                          : 'Location',
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
                        child: Icon(
                          Icons.favorite_border,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // TITLE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    widget.bien.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // LOCATION
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: AppColors.secondaryBlue),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.bien.city ?? "Localisation inconnue",
                          maxLines: 2,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // PRICE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "${widget.bien.price.toStringAsFixed(0)} F",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ---------------- OVERLAY ----------------
          AnimatedOpacity(
            opacity: isPressed ? 1 : 0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              width: 240,
              height: 260,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.45),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(bien: widget.bien),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      "Voir détail",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textLight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

























// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:mobile/data/models/bien_model.dart';
// import 'package:mobile/presentation/screens/Details/DetailScreen.dart';
// import 'package:mobile/presentation/theme/colors.dart';

// class ImmobilierCard extends StatefulWidget {
//   final BienModel bien;

//   const ImmobilierCard({
//     super.key,
//     required this.bien,
//   });

//   @override
//   State<ImmobilierCard> createState() => _ImmobilierCardState();
// }

// class _ImmobilierCardState extends State<ImmobilierCard> {
//   bool isPressed = false;
//   Timer? overlayTimer;

//   void _showOverlay() {
//     setState(() => isPressed = true);
//     overlayTimer?.cancel();
//     overlayTimer = Timer(const Duration(seconds: 5), () {
//       if (mounted) {
//         setState(() => isPressed = false);
//       }
//     });
//   }

//   void _hideOverlay() {
//     overlayTimer?.cancel();
//     setState(() => isPressed = false);
//   }

//   @override
//   void dispose() {
//     overlayTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final imageUrl = widget.bien.images.isNotEmpty
//         ? widget.bien.images.first
//         : "assets/images/chambre.jpg";

//     return GestureDetector(
//       onTapDown: (_) => _showOverlay(),
//       onTapCancel: _hideOverlay,
//       onTapUp: (_) {},
//       onTap: () {},
//       child: Stack(
//         children: [
//           // ---------------- CARD ----------------
//           Container(
//             width: 240,
//             margin: const EdgeInsets.only(right: 16),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(16),
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black12.withOpacity(.06),
//                   blurRadius: 8,
//                   spreadRadius: 2,
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // IMAGE + TAG + FAVORI
//                 Stack(
//                   children: [
//                     ClipRRect(
//                       borderRadius: const BorderRadius.vertical(
//                         top: Radius.circular(16),
//                       ),
//                       child: imageUrl.startsWith('http')
//                           ? Image.network(
//                               imageUrl,
//                               height: 130,
//                               width: 240,
//                               fit: BoxFit.cover,
//                             )
//                           : Image.asset(
//                               imageUrl,
//                               height: 130,
//                               width: 240,
//                               fit: BoxFit.cover,
//                             ),
//                     ),

//                     Positioned(
//                       top: 10,
//                       left: 10,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 12, vertical: 5),
//                         decoration: BoxDecoration(
//                           color: AppColors.primary,
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         child: Text(
//                           widget.bien.transactionType ?? "Location",
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),

//                     const Positioned(
//                       top: 8,
//                       right: 10,
//                       child: CircleAvatar(
//                         radius: 16,
//                         backgroundColor: Colors.white,
//                         child: Icon(
//                           Icons.favorite_border,
//                           color: AppColors.primary,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 8),

//                 // TITLE
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   child: Text(
//                     widget.bien.title,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 15,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 4),

//                 // LOCATION
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   child: Row(
//                     children: [
//                       const Icon(Icons.location_on,
//                           size: 14, color: AppColors.secondaryBlue),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: Text(
//                           widget.bien.city ?? "Localisation inconnue",
//                           maxLines: 2,
//                           style: const TextStyle(fontSize: 12),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 4),

//                 // PRICE
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   child: Text(
//                     "${widget.bien.price.toStringAsFixed(0)} F",
//                     style: const TextStyle(
//                       fontSize: 17,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.red,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // ---------------- OVERLAY ----------------
//           AnimatedOpacity(
//             opacity: isPressed ? 1 : 0,
//             duration: const Duration(milliseconds: 150),
//             child: Container(
//               width: 240,
//               height: 260,
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(.45),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Center(
//                 child: GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => DetailScreen(bien: widget.bien),
//                       ),
//                     );
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 18, vertical: 10),
//                     decoration: BoxDecoration(
//                       color: AppColors.primary,
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     child: const Text(
//                       "Voir détail",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.textLight,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

