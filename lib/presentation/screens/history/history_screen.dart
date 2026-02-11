import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  final List<Map<String, dynamic>> mockHistory = const [
    {
      "date": "Aujourd'hui",
      "items": [
        {
          "type": "Immobilier",
          "title": "Consultation villa 4 pièces",
          "action": "Vue détaillée",
          "icon": Icons.house
        },
        {
          "type": "Véhicule",
          "title": "Recherche Toyota Corolla",
          "action": "Recherche",
          "icon": Icons.directions_car
        },
      ],
    },
    {
      "date": "Hier",
      "items": [
        {
          "type": "Hôtel",
          "title": "Réservation Hôtel du Lac",
          "action": "Réservation",
          "icon": Icons.hotel
        },
      ],
    },
    {
      "date": "28 Janv 2025",
      "items": [
        {
          "type": "Meuble",
          "title": "Canapé 3 places consulté",
          "action": "Consultation",
          "icon": Icons.chair
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Historique",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: mockHistory.length,
        itemBuilder: (_, index) {
          final section = mockHistory[index];
          return _buildSection(section);
        },
      ),
    );
  }

  // ---------------- SECTION ----------------
  Widget _buildSection(Map<String, dynamic> section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre de section (date)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Text(
            section["date"],
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ),

        // Liste des actions du jour
        ...List.generate(
          (section["items"] as List).length,
          (i) => _buildHistoryCard(section["items"][i]),
        ),

        const SizedBox(height: 12),
      ],
    );
  }

  // ---------------- CARTE D'HISTORIQUE ----------------
  Widget _buildHistoryCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item["icon"], color: AppColors.primary, size: 26),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["title"],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item["action"],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade500),
        ],
      ),
    );
  }
}
