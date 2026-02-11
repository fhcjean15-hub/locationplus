import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/business/providers/bien_controller_provider.dart';
import 'package:mobile/data/models/bien_model.dart';
import 'package:mobile/presentation/screens/auth/utilisateurs/biens/edit_bien_screen.dart';
import 'package:mobile/presentation/screens/auth/admin/manage/user%20profil/users_profil_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';

import 'package:mobile/presentation/theme/colors.dart';

class PublicBienCard extends StatefulWidget {
  final BienModel item;
  final VoidCallback onDelete;
  final WidgetRef ref;

  const PublicBienCard({super.key, required this.item, required this.onDelete, required this.ref});

  @override
  State<PublicBienCard> createState() => _PublicBienCardState();
}

class _PublicBienCardState extends State<PublicBienCard> {
  late final PageController _controller;
  late Timer _timer;
  int _currentPage = 0;
  
  final url = "https://api-location-plus.lamadonebenin.com/storage/";

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_controller.hasClients && widget.item.images.isNotEmpty) {
        _currentPage++;
        if (_currentPage >= widget.item.images.length) _currentPage = 0;
        _controller.animateToPage(_currentPage, duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isExpanded = widget.item.expanded;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3)),
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

          // ---------------- CONTENU INFÉRIEUR ----------------
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👤 PROPRIÉTAIRE CLIQUABLE
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
                        backgroundImage: widget.item.ownerAvatar.isNotEmpty
                            ? NetworkImage(url + widget.item.ownerAvatar)
                            : null,
                        child: widget.item.ownerAvatar.isEmpty
                            ? const Icon(Icons.person, size: 18, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.item.ownerName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
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

                // 📍 META (ville + catégorie)
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

                const SizedBox(height: 6),

                if (isExpanded) ...[
                  // 📊 ATTRIBUTS CLÉS (CHIPS)
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
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 📖 DESCRIPTION
                  Text(
                    widget.item.description,
                    maxLines: isExpanded ? 6 : 2,
                    overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
                  ),

                ],

                // VOIR PLUS / MOINS
                GestureDetector(
                  onTap: () => setState(() => widget.item.expanded = !widget.item.expanded),
                  child: Text(
                    widget.item.expanded ? "Voir moins ↑" : "Voir plus →",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
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
    if (value is int) return value == 1 ? "Oui" : "Non";
    if (value is String) {
      if (value == "1") return "Oui";
      if (value == "0") return "Non";
    }
    return value?.toString() ?? "-";
  }
}

