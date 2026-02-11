import 'package:flutter/material.dart';
import 'package:mobile/data/models/bien_model.dart';
import 'package:mobile/presentation/screens/Details/DetailScreen.dart';
import 'package:mobile/presentation/theme/colors.dart';
import '../theme/colors.dart';

class MeubleListCard extends StatelessWidget {
  final BienModel bien;

  const MeubleListCard({super.key, required this.bien});

  @override
  Widget build(BuildContext context) {
    final String imageUrl = bien.images.isNotEmpty
        ? bien.images.first
        : "assets/images/meuble.jpg";
        
    final url = "https://api-location-plus.lamadonebenin.com/storage/";

    final String transactionLabel =
        (bien.transactionType?.toLowerCase() == 'achat')
            ? 'Achat'
            : (bien.transactionType?.toLowerCase() == 'location')
                ? 'Location'
                : 'Meuble';

    return Container(
      width: double.infinity,
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
        children: [
          // IMAGE
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.35),
                    BlendMode.darken,
                  ),
                  child: Image.network(
                          url + imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
              ),

              // TAG
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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

              // FAVORI
              const Positioned(
                top: 8,
                right: 10,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child:
                      Icon(Icons.favorite_border, color: AppColors.primary),
                ),
              ),
            ],
          ),

          // CONTENU
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TITRE
                Text(
                  bien.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                // LOCALISATION
                Text(
                  bien.city ?? "Localisation inconnue",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),

                const SizedBox(height: 6),

                // STARS
                Row(
                  children: const [
                    Icon(Icons.star, color: Colors.amber, size: 18),
                    Icon(Icons.star, color: Colors.amber, size: 18),
                    Icon(Icons.star, color: Colors.amber, size: 18),
                    Icon(Icons.star, color: Colors.amber, size: 18),
                    Icon(Icons.star_half, color: Colors.amber, size: 18),
                    SizedBox(width: 6),
                    Text("(4)", style: TextStyle(fontSize: 12)),
                  ],
                ),

                const SizedBox(height: 10),

                // PRIX
                Text(
                  "${bien.price.toStringAsFixed(0)} F",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),

                const SizedBox(height: 12),

                // BOUTONS
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailScreen(bien: bien),
                            ),
                          );
                        },
                        child: const Text(
                          "Voir détail",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
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
                      child: const Icon(Icons.remove_red_eye),
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
