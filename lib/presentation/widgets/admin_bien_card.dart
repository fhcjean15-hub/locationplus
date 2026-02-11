import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/presentation/screens/auth/admin/manage/user%20profil/users_profil_screen.dart';
import 'package:mobile/presentation/theme/colors.dart';
import '../../data/models/bien_model.dart';

class AdminBienCard extends StatefulWidget {
  final BienModel item;
  final WidgetRef ref;
  final Future<void> Function(bool newValue) onToggleActif;

  const AdminBienCard({
    super.key,
    required this.item,
    required this.ref,
    required this.onToggleActif,
  });

  @override
  State<AdminBienCard> createState() => _AdminBienCardState();
}

class _AdminBienCardState extends State<AdminBienCard> {
  final PageController _controller = PageController();
  
  final url = "https://api-location-plus.lamadonebenin.com/storage/";


  @override
  Widget build(BuildContext context) {
    final isExpanded = widget.item.expanded;

    return Container(
      margin: const EdgeInsets.only(bottom: 18, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------- IMAGE CAROUSEL ----------------
          if (widget.item.images.isNotEmpty)
            SizedBox(
              height: 170,
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.item.images.length,
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: Image.network(
                    url + widget.item.images[i],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

          // ---------------- CONTENU ----------------
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👤 PROPRIÉTAIRE
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserProfilScreen(
                          user: widget.item.user!,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: widget.item.ownerAvatar != null
                            ? NetworkImage(url + widget.item.ownerAvatar!)
                            : null,
                        child: widget.item.ownerAvatar == null
                            ? const Icon(Icons.person, size: 18, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.item.ownerName,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 🏷 TITRE
                Text(
                  widget.item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 4),

                // 📍 LOCALISATION
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      widget.item.city ?? "Ville non précisée",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "• ${widget.item.category}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),


                // 🔽 TOUT CE QUI EST CACHÉ PAR DÉFAUT
                if (isExpanded) ...[
                  const SizedBox(height: 12),

                  // 📊 ATTRIBUTS
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.item.attributes.entries.take(4).map((e) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${_getAttributeLabel(e.key)}: ${_formatAttributeValue(e.value)}",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 12),

                  // 💰 PRIX + STATUT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${widget.item.price.toStringAsFixed(0)} F",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.item.actif
                              ? Colors.green.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.item.actif ? "Activé" : "Désactivé",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                widget.item.actif ? Colors.green : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 📖 DESCRIPTION
                  Text(
                    widget.item.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 🔘 TOGGLE ACTIF
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        "Statut",
                        style:
                            TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 6),
                      Switch(
                        value: widget.item.actif,
                        onChanged: _toggleActif,
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ],


                const SizedBox(height: 8),

                // 👁️ VOIR PLUS / MOINS
                GestureDetector(
                  onTap: () =>
                      setState(() => widget.item.expanded = !widget.item.expanded),
                  child: Text(
                    isExpanded ? "Voir moins ↑" : "Voir plus →",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w500,
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


  // ---------------- HELPERS ----------------

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
    if (value is int) return value == 1 ? "Oui" : "Non";
    if (value is String) {
      if (value == "1") return "Oui";
      if (value == "0") return "Non";
    }
    return value?.toString() ?? "-";
  }

  void _toggleActif(bool newValue) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await widget.onToggleActif(newValue);
    });
  }
}






// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile/presentation/theme/colors.dart';
// import '../../data/models/bien_model.dart';

// class AdminBienCard extends StatefulWidget {
//   final BienModel item;
//   final WidgetRef ref;
//   final Future<void> Function(bool newValue) onToggleActif;

//   const AdminBienCard({
//     super.key,
//     required this.item,
//     required this.ref,
//     required this.onToggleActif,
//   });

//   @override
//   State<AdminBienCard> createState() => _AdminBienCardState();
// }

// class _AdminBienCardState extends State<AdminBienCard> {
//   final PageController _controller = PageController();

//   @override
//   Widget build(BuildContext context) {
//     final isExpanded = widget.item.expanded;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 18, left: 16, right: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // TITRE + PRIX + PROPRIETAIRE
//           Padding(
//             padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     widget.item.title,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//                 Text(
//                   "${widget.item.price} F",
//                   style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primary),
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
//             child: Text(
//               "Propriétaire: ${widget.item.ownerName}",
//               style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
//             ),
//           ),

//           // CAROUSEL
//           if (widget.item.images.isNotEmpty)
//             SizedBox(
//               height: 160,
//               child: PageView.builder(
//                 controller: _controller,
//                 itemCount: widget.item.images.length,
//                 itemBuilder: (_, i) => ClipRRect(
//                   borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
//                   child: Image.network(widget.item.images[i], fit: BoxFit.cover),
//                 ),
//               ),
//             ),

//           Padding(
//             padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // DESCRIPTION
//                 Text(
//                   widget.item.description,
//                   maxLines: isExpanded ? 10 : 2,
//                   overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
//                   softWrap: true,
//                   style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.35),
//                 ),
//                 const SizedBox(height: 10),

//                 // ATTRIBUTES si expanded
//                 if (isExpanded)
//                   ...widget.item.attributes.entries.map(
//                     (e) => Padding(
//                       padding: const EdgeInsets.only(bottom: 6),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text("${_getAttributeLabel(e.key)}: ",
//                               style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
//                           Expanded(
//                             child: Text(
//                               _formatAttributeValue(e.value),
//                               style: const TextStyle(fontSize: 13, color: Colors.black87),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                 const SizedBox(height: 10),

//                 // VOIR PLUS / VOIR MOINS
//                 GestureDetector(
//                   onTap: () => setState(() => widget.item.expanded = !(widget.item.expanded)),
//                   child: Text(
//                     widget.item.expanded ? "Voir moins ↑" : "Voir plus →",
//                     style: TextStyle(fontSize: 13, color: Colors.blue.shade600, fontWeight: FontWeight.w500),
//                   ),
//                 ),

//                 const SizedBox(height: 10),

//                 // TOGGLE ACTIF
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     Text(
//                       widget.item.actif ? "Activé" : "Désactivé",
//                       style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
//                     ),
//                     Switch(
//                       value: widget.item.actif,
//                       onChanged: _toggleActif,
//                       activeColor: AppColors.primary,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
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
//       case "electricity":
//         return "Électricité";
//       case "water":
//         return "Eau";
//       case "brand":
//         return "Marque";
//       case "model":
//         return "Modèle";
//       case "year":
//         return "Année";
//       case "fuel":
//         return "Carburant";
//       case "gearbox":
//         return "Boîte de vitesse";
//       case "mileage":
//         return "Kilométrage";
//       case "type":
//         return "Type";
//       case "material":
//         return "Matériau";
//       case "dimensions":
//         return "Dimensions";
//       case "condition":
//         return "État";
//       case "room_type":
//         return "Type de chambre";
//       case "capacity":
//         return "Capacité";
//       case "wifi":
//         return "Wifi";
//       case "air_conditioning":
//         return "Climatisation";
//       case "bathroom_private":
//         return "Salle de bain privée";
//       case "bedrooms":
//         return "Chambres";
//       case "kitchen":
//         return "Cuisine";
//       case "rules":
//         return "Règles";
//       default:
//         return key;
//     }
//   }

//   // String _formatAttributeValue(dynamic value) {
//   //   if (value is bool) return value ? "Oui" : "Non";
//   //   return value.toString();
//   // }

//     String _formatAttributeValue(dynamic value) {
//     if (value is bool) {
//       return value ? "Oui" : "Non";
//     }

//     if (value is int) {
//       if (value == 1) return "Oui";
//       if (value == 0) return "Non";
//     }

//     if (value is String) {
//       if (value == "1") return "Oui";
//       if (value == "0") return "Non";
//     }

//     return value?.toString() ?? "-";
//   }

//   void _toggleActif(bool newValue) {
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await widget.onToggleActif(newValue);
//     });
//   }

// }



// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile/presentation/theme/colors.dart';

// import '../theme/colors.dart';
// import '../../data/models/bien_model.dart';


// class AdminBienCard extends StatefulWidget {
//   final BienModel item;
//   final WidgetRef ref;
//   final Future<void> Function(bool newValue) onToggleActif;

//   const AdminBienCard({
//     super.key,
//     required this.item,
//     required this.ref,
//     required this.onToggleActif,
//   });

//   @override
//   State<AdminBienCard> createState() => _AdminBienCardState();
// }

// class _AdminBienCardState extends State<AdminBienCard> {
//   final PageController _controller = PageController();

//   @override
//   Widget build(BuildContext context) {
//     final isExpanded = widget.item.expanded;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 18, left: 16, right: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ----------------- TITRE + PRIX + PROPRIETAIRE -----------------
//           Padding(
//             padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     widget.item.title,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                   ),
//                 ),
//                 Text(
//                   "${widget.item.price} F",
//                   style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primary),
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
//             child: Text(
//               "Propriétaire: ${widget.item.ownerName}",
//               style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
//             ),
//           ),

//           // ----------------- CAROUSEL -----------------
//           if (widget.item.images.isNotEmpty)
//             SizedBox(
//               height: 160,
//               child: PageView.builder(
//                 controller: _controller,
//                 itemCount: widget.item.images.length,
//                 itemBuilder: (_, i) => ClipRRect(
//                   borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
//                   child: Image.network(widget.item.images[i], fit: BoxFit.cover),
//                 ),
//               ),
//             ),

//           Padding(
//             padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // ----------------- DESCRIPTION -----------------
//                 Text(
//                   widget.item.description,
//                   maxLines: (isExpanded ?? false) ? 10 : 2,
//                   overflow: (isExpanded ?? false) ? TextOverflow.visible : TextOverflow.ellipsis,
//                   softWrap: true,
//                   style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.35),
//                 ),
//                 const SizedBox(height: 10),

//                 // ----------------- ATTRIBUTES -----------------
//                 if (isExpanded ?? false)
//                   ...widget.item.attributes.entries.map(
//                     (e) => Padding(
//                       padding: const EdgeInsets.only(bottom: 6),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text("${_getAttributeLabel(e.key)}: ",
//                               style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
//                           Expanded(
//                             child: Text(
//                               _formatAttributeValue(e.value),
//                               style: const TextStyle(fontSize: 13, color: Colors.black87),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                 const SizedBox(height: 10),

//                 // ----------------- VOIR PLUS / VOIR MOINS -----------------
//                 GestureDetector(
//                   onTap: () => setState(() => widget.item.expanded = !(widget.item.expanded ?? false)),
//                   child: Text(
//                     (widget.item.expanded ?? false) ? "Voir moins ↑" : "Voir plus →",
//                     style: TextStyle(fontSize: 13, color: Colors.blue.shade600, fontWeight: FontWeight.w500),
//                   ),
//                 ),

//                 const SizedBox(height: 10),

//                 // ----------------- TOGGLE ACTIF -----------------
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     Text(
//                       widget.item.actif ? "Activé" : "Désactivé",
//                       style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
//                     ),
//                     Switch(
//                       value: widget.item.actif,
//                       onChanged: (val) async {
//                         await widget.onToggleActif(val);
//                       },
//                       activeColor: AppColors.primary,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getAttributeLabel(String key) {
//     // Retourne des labels lisibles selon la clé
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
//       case "electricity":
//         return "Électricité";
//       case "water":
//         return "Eau";
//       case "brand":
//         return "Marque";
//       case "model":
//         return "Modèle";
//       case "year":
//         return "Année";
//       case "fuel":
//         return "Carburant";
//       case "gearbox":
//         return "Boîte de vitesse";
//       case "mileage":
//         return "Kilométrage";
//       case "type":
//         return "Type";
//       case "material":
//         return "Matériau";
//       case "dimensions":
//         return "Dimensions";
//       case "condition":
//         return "État";
//       case "room_type":
//         return "Type de chambre";
//       case "capacity":
//         return "Capacité";
//       case "wifi":
//         return "Wifi";
//       case "air_conditioning":
//         return "Climatisation";
//       case "bathroom_private":
//         return "Salle de bain privée";
//       case "bedrooms":
//         return "Chambres";
//       case "kitchen":
//         return "Cuisine";
//       case "rules":
//         return "Règles";
//       default:
//         return key;
//     }
//   }

//   String _formatAttributeValue(dynamic value) {
//     if (value is bool) return value ? "Oui" : "Non";
//     return value.toString();
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:mobile/presentation/theme/colors.dart';

// import '../theme/colors.dart';
// import '../../data/models/bien_model.dart';

// class AdminBienCard extends StatefulWidget {
//   final BienModel item;
//   final VoidCallback onToggleActivation;

//   const AdminBienCard({
//     super.key,
//     required this.item,
//     required this.onToggleActivation,
//   });

//   @override
//   State<AdminBienCard> createState() => _AdminBienCardState();
// }

// class _AdminBienCardState extends State<AdminBienCard> {
//   @override
//   Widget build(BuildContext context) {
//     final isExpanded = widget.item.expanded;

//     return Opacity(
//       opacity: widget.item.actif ? 1 : 0.5,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 18),
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
//             // ================= TITRE + PRIX =================
//             Padding(
//               padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       widget.item.title,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   Text(
//                     "${widget.item.price} F",
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // ================= PROPRIÉTAIRE =================
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 14),
//               child: Text(
//                 "Propriétaire : ${widget.item.ownerName}",
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: Colors.grey.shade700,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 10),

//             // ================= IMAGES =================
//             SizedBox(
//               height: 150,
//               child: PageView.builder(
//                 itemCount: widget.item.images.length,
//                 itemBuilder: (_, i) => ClipRRect(
//                   borderRadius: BorderRadius.circular(0),
//                   child: Image.network(
//                     widget.item.images[i],
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ),

//             // ================= DESCRIPTION + ATTRIBUTS =================
//             Padding(
//               padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.item.description,
//                     maxLines: (isExpanded ?? false) ? 10 : 2,
//                     overflow: (isExpanded ?? false)
//                         ? TextOverflow.visible
//                         : TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: Colors.grey.shade700,
//                       height: 1.35,
//                     ),
//                   ),

//                   const SizedBox(height: 8),

//                   if (isExpanded ?? false)
//                     ...widget.item.attributes.entries.map(
//                       (e) => Padding(
//                         padding: const EdgeInsets.only(bottom: 6),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "${e.key} : ",
//                               style: const TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             Expanded(
//                               child: Text(
//                                 e.value.toString(),
//                                 style: const TextStyle(fontSize: 13),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),

//                   const SizedBox(height: 10),

//                   // ================= ACTIONS =================
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       GestureDetector(
//                         onTap: () => setState(
//                           () => widget.item.expanded =
//                               !(widget.item.expanded ?? false),
//                         ),
//                         child: Text(
//                           (widget.item.expanded ?? false)
//                               ? "Voir moins ↑"
//                               : "Voir plus →",
//                           style: TextStyle(
//                             fontSize: 13,
//                             color: Colors.blue.shade600,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),

//                       TextButton.icon(
//                         onPressed: widget.onToggleActivation,
//                         icon: Icon(
//                           widget.item.actif
//                               ? Icons.visibility_off
//                               : Icons.visibility,
//                           color: widget.item.actif
//                               ? Colors.red
//                               : Colors.green,
//                         ),
//                         label: Text(
//                           widget.item.actif ? "Désactiver" : "Activer",
//                           style: TextStyle(
//                             color: widget.item.actif
//                                 ? Colors.red
//                                 : Colors.green,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
