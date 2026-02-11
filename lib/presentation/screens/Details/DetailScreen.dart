import 'package:flutter/material.dart';
import 'package:mobile/data/models/bien_model.dart';
import 'package:mobile/presentation/theme/colors.dart';
import 'package:mobile/presentation/screens/reservation/reservation_screen.dart';

class DetailScreen extends StatefulWidget {
  final BienModel bien;

  const DetailScreen({
    super.key,
    required this.bien,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late String selectedImage;
  
  final url = "https://api-location-plus.lamadonebenin.com/storage/";

  @override
  void initState() {
    super.initState();
    // Sélection initiale : première image
    selectedImage = widget.bien.images.isNotEmpty ? widget.bien.images.first : '';
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.bien.images.take(7).toList(); // max 7 images

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: Text(
          widget.bien.title,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- IMAGES ----------------
            if (images.isNotEmpty)
              Column(
                children: [
                  SizedBox(
                    height: 240,
                    width: double.infinity,
                    child: Image.network(
                      url + selectedImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      itemBuilder: (_, i) {
                        final img = images[i];
                        final isSelected = img == selectedImage;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedImage = img;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected ? AppColors.primary : Colors.transparent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                url + img,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------------- OWNER ----------------
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: widget.bien.ownerAvatar.isNotEmpty
                            ? NetworkImage(url + widget.bien.ownerAvatar)
                            : null,
                        child: widget.bien.ownerAvatar.isEmpty
                            ? const Icon(Icons.person, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.bien.ownerName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ---------------- TITLE ----------------
                  Text(
                    widget.bien.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ---------------- META ----------------
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        widget.bien.city ?? "Ville non précisée",
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "• ${widget.bien.category}",
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ---------------- PRICE ----------------
                  Text(
                    "${widget.bien.price.toStringAsFixed(0)} F",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ---------------- ATTRIBUTES ----------------
                  if (widget.bien.attributes.isNotEmpty) ...[
                    const Text(
                      "Caractéristiques",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: widget.bien.attributes.entries.map((e) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            "${_getAttributeLabel(e.key)} : ${_formatAttributeValue(e.value)}",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ---------------- DESCRIPTION ----------------
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.bien.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.grey.shade800,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ---------------- ACTION ----------------
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: widget.bien.status == 'disponible'
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ReservationScreen(bien: widget.bien),
                                ),
                              );
                            }
                          : null,

                      child: Text(
                        _actionText(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- HELPERS ----------------

  String _actionText() {
    switch (widget.bien.transactionType) {
      case "vente":
        return "Acheter";
      case "location":
        return "Louer";
      case "booking":
        return "Réserver";
      default:
        return "Continuer";
    }
  }

  String _getAttributeLabel(String key) {
    switch (key) {
      case "surface":
        return "Surface";
      case "rooms":
        return "Pièces";
      case "bathrooms":
        return "Salles de bain";
      case "furnished":
        return "Meublé";
      case "parking":
        return "Parking";
      case "electricity":
        return "Électricité";
      case "water":
        return "Eau";
      case "brand":
        return "Marque";
      case "model":
        return "Modèle";
      case "year":
        return "Année";
      case "fuel":
        return "Carburant";
      case "gearbox":
        return "Boîte de vitesse";
      case "mileage":
        return "Kilométrage";
      case "type":
        return "Type";
      case "material":
        return "Matériau";
      case "dimensions":
        return "Dimensions";
      case "condition":
        return "État";
      case "room_type":
        return "Type de chambre";
      case "capacity":
        return "Capacité";
      case "wifi":
        return "Wifi";
      case "air_conditioning":
        return "Climatisation";
      case "bathroom_private":
        return "Salle de bain privée";
      case "bedrooms":
        return "Chambres";
      case "kitchen":
        return "Cuisine";
      case "rules":
        return "Règles";
      default:
        return key;
    }
  }

  String _formatAttributeValue(dynamic value) {
    if (value is bool) return value ? "Oui" : "Non";
    if (value is int) return value == 1 ? "Oui" : value.toString();
    if (value is String) {
      if (value == "1") return "Oui";
      if (value == "0") return "Non";
    }
    return value?.toString() ?? "-";
  }
}














// import 'package:flutter/material.dart';
// import 'package:mobile/data/models/bien_model.dart';
// import 'package:mobile/presentation/theme/colors.dart';

// class DetailScreen extends StatelessWidget {
//   final BienModel bien;

//   const DetailScreen({
//     super.key,
//     required this.bien,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         iconTheme: const IconThemeData(color: AppColors.textDark),
//         title: Text(
//           bien.title,
//           style: const TextStyle(
//             color: AppColors.textDark,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ---------------- IMAGES ----------------
//             if (bien.images.isNotEmpty)
//               SizedBox(
//                 height: 240,
//                 child: PageView.builder(
//                   itemCount: bien.images.length,
//                   itemBuilder: (_, i) => Image.network(
//                     bien.images[i],
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),

//             const SizedBox(height: 16),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // ---------------- OWNER ----------------
//                   Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 18,
//                         backgroundColor: Colors.grey.shade200,
//                         backgroundImage: bien.ownerAvatar.isNotEmpty
//                             ? NetworkImage(bien.ownerAvatar)
//                             : null,
//                         child: bien.ownerAvatar.isEmpty
//                             ? const Icon(Icons.person, color: Colors.grey)
//                             : null,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         bien.ownerName,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 14),

//                   // ---------------- TITLE ----------------
//                   Text(
//                     bien.title,
//                     style: const TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),

//                   const SizedBox(height: 6),

//                   // ---------------- META ----------------
//                   Row(
//                     children: [
//                       const Icon(Icons.location_on, size: 16, color: Colors.grey),
//                       const SizedBox(width: 4),
//                       Text(
//                         bien.city ?? "Ville non précisée",
//                         style: const TextStyle(fontSize: 13, color: Colors.grey),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         "• ${bien.category}",
//                         style: const TextStyle(fontSize: 13, color: Colors.grey),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 14),

//                   // ---------------- PRICE ----------------
//                   Text(
//                     "${bien.price.toStringAsFixed(0)} F",
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.primary,
//                     ),
//                   ),

//                   const SizedBox(height: 18),

//                   // ---------------- ATTRIBUTES ----------------
//                   if (bien.attributes.isNotEmpty) ...[
//                     const Text(
//                       "Caractéristiques",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Wrap(
//                       spacing: 10,
//                       runSpacing: 10,
//                       children: bien.attributes.entries.map((e) {
//                         return Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade100,
//                             borderRadius: BorderRadius.circular(14),
//                           ),
//                           child: Text(
//                             "${_getAttributeLabel(e.key)} : ${_formatAttributeValue(e.value)}",
//                             style: const TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                     const SizedBox(height: 20),
//                   ],

//                   // ---------------- DESCRIPTION ----------------
//                   const Text(
//                     "Description",
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     bien.description,
//                     style: TextStyle(
//                       fontSize: 14,
//                       height: 1.5,
//                       color: Colors.grey.shade800,
//                     ),
//                   ),

//                   const SizedBox(height: 30),

//                   // ---------------- ACTION ----------------
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.primary,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                       ),
//                       onPressed: () {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(_actionText()),
//                           ),
//                         );
//                       },
//                       child: Text(
//                         _actionText(),
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 30),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ---------------- HELPERS ----------------

//   String _actionText() {
//     switch (bien.transactionType) {
//       case "sale":
//         return "Acheter";
//       case "rent":
//         return "Louer";
//       case "booking":
//         return "Réserver";
//       default:
//         return "Continuer";
//     }
//   }

//   String _getAttributeLabel(String key) {
//     switch (key) {
//       case "surface":
//         return "Surface";
//       case "rooms":
//         return "Pièces";
//       case "bathrooms":
//         return "Salles de bain";
//       case "furnished":
//         return "Meublé";
//       case "parking":
//         return "Parking";
//       case "brand":
//         return "Marque";
//       case "model":
//         return "Modèle";
//       case "year":
//         return "Année";
//       case "fuel":
//         return "Carburant";
//       case "room_type":
//         return "Type de chambre";
//       case "capacity":
//         return "Capacité";
//       default:
//         return key;
//     }
//   }

//   String _formatAttributeValue(dynamic value) {
//     if (value is bool) return value ? "Oui" : "Non";
//     if (value is int) return value == 1 ? "Oui" : value.toString();
//     if (value is String) {
//       if (value == "1") return "Oui";
//       if (value == "0") return "Non";
//     }
//     return value?.toString() ?? "-";
//   }
// }







// import 'package:flutter/material.dart';
// import 'package:mobile/data/models/bien_model.dart';
// import '../../theme/colors.dart';

// enum DetailType { Immobilier, Vehicule, Meuble, Hotel }
// enum ActionType { Acheter, Louer, Reserver, Aucun }

// class DetailScreen extends StatelessWidget {
//   final BienModel bien;

//   const DetailScreen({
//     super.key,
//     required this.bien,
//   });

//   // -----------------------------
//   // DERIVED VALUES
//   // -----------------------------
//   DetailType get type {
//     switch (bien.category.toLowerCase()) {
//       case 'immobilier':
//         return DetailType.Immobilier;
//       case 'vehicule':
//         return DetailType.Vehicule;
//       case 'meuble':
//         return DetailType.Meuble;
//       case 'hotel':
//       case 'hebergement':
//         return DetailType.Hotel;
//       default:
//         return DetailType.Immobilier;
//     }
//   }

//   ActionType get action {
//     switch (bien.transactionType.toLowerCase()) {
//       case 'achat':
//         return ActionType.Acheter;
//       case 'location':
//         return type == DetailType.Hotel
//             ? ActionType.Reserver
//             : ActionType.Louer;
//       default:
//         return ActionType.Aucun;
//     }
//   }

//   String get imageUrl {
//     if (bien.images.isNotEmpty) {
//       return bien.images.first;
//     }
//     return 'assets/images/placeholder.png';
//   }

//   String get formattedPrice {
//     final price = bien.price.toStringAsFixed(0);
//     switch (action) {
//       case ActionType.Reserver:
//         return "$price F /nuit";
//       case ActionType.Louer:
//         return "$price F /mois";
//       case ActionType.Acheter:
//         return "$price F";
//       default:
//         return price;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: Text(
//           bien.title,
//           style: const TextStyle(
//             color: AppColors.textDark,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         iconTheme: const IconThemeData(color: AppColors.textDark),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildImage(),
//             const SizedBox(height: 16),

//             // TITLE
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 bien.title,
//                 style: const TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),

//             // LOCATION
//             if (bien.city != null && bien.city!.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.location_on,
//                         size: 16, color: AppColors.secondaryBlue),
//                     const SizedBox(width: 6),
//                     Expanded(
//                       child: Text(
//                         bien.city!,
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//             // PRICE
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//               child: Text(
//                 formattedPrice,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.red,
//                 ),
//               ),
//             ),

//             // DESCRIPTION
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//               child: Text(
//                 bien.description,
//                 style: const TextStyle(fontSize: 14, height: 1.5),
//               ),
//             ),

//             const SizedBox(height: 24),

//             if (action != ActionType.Aucun)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     icon: _buildIcon(),
//                     label: _buildLabel(),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primary,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     onPressed: () {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(
//                             '${_actionText()} : ${bien.title}',
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),

//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }

//   // -----------------------------
//   // HELPERS
//   // -----------------------------
//   Widget _buildImage() {
//     if (imageUrl.startsWith('http')) {
//       return Image.network(
//         imageUrl,
//         width: double.infinity,
//         height: 220,
//         fit: BoxFit.cover,
//       );
//     }
//     return Image.asset(
//       imageUrl,
//       width: double.infinity,
//       height: 220,
//       fit: BoxFit.cover,
//     );
//   }

//   Widget _buildIcon() {
//     switch (action) {
//       case ActionType.Acheter:
//         return const Icon(Icons.shopping_cart, color: Colors.white);
//       case ActionType.Louer:
//         return const Icon(Icons.assignment, color: Colors.white);
//       case ActionType.Reserver:
//         return const Icon(Icons.book_online, color: Colors.white);
//       case ActionType.Aucun:
//         return const SizedBox();
//     }
//   }

//   Widget _buildLabel() {
//     return Text(
//       _actionText(),
//       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//     );
//   }

//   String _actionText() {
//     switch (action) {
//       case ActionType.Acheter:
//         return "Acheter";
//       case ActionType.Louer:
//         return "Louer";
//       case ActionType.Reserver:
//         return "Réserver";
//       case ActionType.Aucun:
//         return "";
//     }
//   }
// }








// import 'package:flutter/material.dart';
// import 'package:mobile/presentation/theme/colors.dart';
// import '../../theme/colors.dart';

// enum DetailType { Immobilier, Vehicule, Meuble, Hotel }
// enum ActionType { Acheter, Louer, Reserver, Aucun }

// class DetailScreen extends StatelessWidget {
//   final DetailType type;
//   final String title;
//   final String location;
//   final String price;
//   final String description;
//   final String imageUrl;
//   final ActionType action;

//   const DetailScreen({
//     super.key,
//     required this.type,
//     required this.title,
//     required this.location,
//     required this.price,
//     required this.description,
//     required this.imageUrl,
//     required this.action,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: Text(
//           title,
//           style: const TextStyle(
//             color: AppColors.textDark,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         iconTheme: const IconThemeData(color: AppColors.textDark),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Image.asset(
//               imageUrl,
//               width: double.infinity,
//               height: 220,
//               fit: BoxFit.cover,
//             ),
//             const SizedBox(height: 16),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 children: [
//                   const Icon(Icons.location_on, size: 16, color: AppColors.secondaryBlue),
//                   const SizedBox(width: 6),
//                   Expanded(
//                     child: Text(
//                       location,
//                       style: const TextStyle(fontSize: 14),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 12),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 price,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.red,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 description,
//                 style: const TextStyle(fontSize: 14, height: 1.5),
//               ),
//             ),
//             const SizedBox(height: 24),
//             if (action != ActionType.Aucun)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     icon: _buildIcon(),
//                     label: _buildLabel(),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primary,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     onPressed: () {
//                       // TODO: action selon type
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(
//                             '${_actionText()} sur $title',
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildIcon() {
//     switch (action) {
//       case ActionType.Acheter:
//         return const Icon(Icons.shopping_cart, color: Colors.white);
//       case ActionType.Louer:
//         switch (type) {
//           case DetailType.Immobilier:
//             return const Icon(Icons.home, color: Colors.white);
//           case DetailType.Vehicule:
//             return const Icon(Icons.directions_car, color: Colors.white);
//           case DetailType.Meuble:
//             return const Icon(Icons.chair, color: Colors.white);
//           default:
//             return const SizedBox();
//         }
//       case ActionType.Reserver:
//         return const Icon(Icons.book_online, color: Colors.white);
//       case ActionType.Aucun:
//         return const SizedBox();
//     }
//   }


//   Widget _buildLabel() {
//     switch (action) {
//       case ActionType.Acheter:
//         return const Text(
//           "Acheter",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         );
//       case ActionType.Louer:
//         return const Text(
//           "Louer",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         );
//       case ActionType.Reserver:
//         return const Text(
//           "Réserver",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         );
//       case ActionType.Aucun:
//         return const SizedBox();
//     }
//   }

//   String _actionText() {
//     switch (action) {
//       case ActionType.Acheter:
//         return "Acheter";
//       case ActionType.Louer:
//         return "Louer";
//       case ActionType.Reserver:
//         return "Réserver";
//       case ActionType.Aucun:
//         return "";
//     }
//   }
// }
