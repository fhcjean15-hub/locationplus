import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/business/providers/bien_controller_provider.dart';
import 'package:mobile/presentation/theme/colors.dart';
import 'package:mobile/presentation/widgets/admin_bien_card.dart';
import '../../../../../business/providers/bien_controller_provider.dart';
import '../../../../../data/models/bien_model.dart';

class ManageBiensScreen extends ConsumerStatefulWidget {
  const ManageBiensScreen({super.key});

  @override
  ConsumerState<ManageBiensScreen> createState() => _ManageBiensScreenState();
}

class _ManageBiensScreenState extends ConsumerState<ManageBiensScreen> {
  String selectedCategory = "Tous";

  final categories = const {
    "Tous": "Tous",
    "immobilier": "Immobilier",
    "vehicule": "Véhicule",
    "meuble": "Meuble",
    "hotel": "Hôtel",
    "hebergement": "Hébergement",
  };

  
  final url = "https://api-location-plus.lamadonebenin.com/storage/";

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(bienControllerProvider.notifier).fetchAllUserBiens();
    });
  }

  @override
  Widget build(BuildContext context) {
    final biensAsync = ref.watch(bienControllerProvider);
    final action = ref.read(bienControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Gestion des Biens",
          style: TextStyle(color: AppColors.textDark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Column(
        children: [
          
          const SizedBox(height: 20),
          // ----------------- FILTRE CATEGORIE -----------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (_, i) {
                  final catKey = categories.keys.elementAt(i);    // clé de la catégorie
                  final catValue = categories[catKey]!;           // valeur lisible
                  final isActive = selectedCategory == catKey;
                  return GestureDetector(
                    onTap: () => setState(() => selectedCategory = catKey),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        catValue,
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),


          // ----------------- LISTE DES BIENS -----------------
          Expanded(
            child: biensAsync.when(
              data: (biens) {
                // Filtrage catégorie
                final biensFiltered = selectedCategory == "Tous"
                    ? biens
                    : biens
                          .where(
                            (b) =>
                                b.category.toLowerCase() ==
                                selectedCategory.toLowerCase(),
                          )
                          .toList();

                // Pas de biens
                if (biensFiltered.isEmpty) {
                  return const Center(child: Text("Aucun bien trouvé"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 10),
                  itemCount: biensFiltered.length,
                  itemBuilder: (_, i) => AdminBienCard(
                    item: biensFiltered[i],
                    ref: ref,
                    onToggleActif: (bool newValue) async {
                      await action.toggleBienActivation(
                        id: int.parse(biensFiltered[i].id),
                        actif: newValue, // modification souhaitée
                      );
                      action.fetchAllUserBiens();
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (err, stack) => Center(child: Text("Erreur: $err")),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile/business/providers/bien_controller_provider.dart';

// import '../../../../theme/colors.dart';
// import '../../../../../business/controllers/bien_controller.dart';
// import '../../../../../data/models/bien_model.dart';
// import '../../../../widgets/admin_bien_card.dart';

// class ManageBiensScreen extends ConsumerStatefulWidget {
//   const ManageBiensScreen({super.key});

//   @override
//   ConsumerState<ManageBiensScreen> createState() => _ManageBiensScreenState();
// }

// class _ManageBiensScreenState extends ConsumerState<ManageBiensScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() {
//       ref.read(bienControllerProvider.notifier).fetchAllUserBiens();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final biensAsync = ref.watch(bienControllerProvider);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text("Gestion des biens"),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         foregroundColor: Colors.black,
//       ),
//       body: biensAsync.when(
//         data: (biens) {
//           if (biens.isEmpty) {
//             return _buildEmptyState();
//           }

//           return RefreshIndicator(
//             color: AppColors.primary,
//             onRefresh: () async {
//               await ref.read(bienControllerProvider.notifier).fetchAllUserBiens();
//             },
//             child: ListView.builder(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
//               itemCount: biens.length,
//               itemBuilder: (_, i) {
//                 final bien = biens[i];
//                 return AdminBienCard(
//                   item: bien,
//                   onToggleActivation: () {
//                     ref.read(bienControllerProvider.notifier).toggleBienActivation(
//                           id: bien.id,
//                           actif: !bien.actif,
//                         );
//                   },
//                 );
//               },
//             ),
//           );
//         },
//         loading: () => const Center(
//           child: CircularProgressIndicator(color: AppColors.primary),
//         ),
//         error: (err, _) => Center(
//           child: Text(
//             "Erreur : $err",
//             style: const TextStyle(color: Colors.red),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return const Center(
//       child: Text(
//         "Aucun bien disponible",
//         style: TextStyle(fontSize: 15, color: Colors.grey),
//       ),
//     );
//   }
// }
