import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/business/states/search_state.dart';
import 'package:mobile/data/models/search_to_bien_mapper.dart';
import 'package:mobile/presentation/screens/Details/DetailScreen.dart';
import '../../theme/colors.dart';
import 'package:mobile/business/controllers/search_controller.dart';
import 'package:mobile/data/models/search_model.dart';


class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  
  final baseUrl = "https://api-location-plus.lamadonebenin.com/storage/";

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchControllerProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Recherche",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= CHAMP DE RECHERCHE =================
            TextField(
              controller: _searchCtrl,
              onSubmitted: (_) => _startSearch(),
              decoration: InputDecoration(
                hintText:
                    "Rechercher un bien, prix, localisation, entreprise...",
                filled: true,
                fillColor: Colors.grey.shade100,
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ================= FILTRES =================
            if (searchState.results.isNotEmpty) _filters(),

            const SizedBox(height: 16),

            // ================= CONTENU =================
            Expanded(
              child: _body(searchState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(SearchState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Text(
          state.error!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (state.results.isEmpty) {
      return _suggestionsView();
    }

    return ListView.separated(
      itemCount: state.results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final item = state.results[index];
        return _resultItem(item);
      },
    );
  }

  // ================= SUGGESTIONS =================
  Widget _suggestionsView() {
    return ListView(
      children: const [
        _SuggestionItem(text: "Maisons à louer"),
        _SuggestionItem(text: "Voitures disponibles"),
        _SuggestionItem(text: "Chambres d’hôtel"),
        _SuggestionItem(text: "Meubles pour salon"),
        _SuggestionItem(text: "Studios meublés"),
      ],
    );
  }

  // ================= FILTRES =================
  Widget _filters() {
    final filters = [
      "Immobilier",
      "Location",
      "Achat",
      "Prix",
      "Meublé",
      "Hôtel",
      "Véhicule",
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = ref
                  .read(searchControllerProvider)
                  .filters
                  .containsKey(filter) &&
              ref.read(searchControllerProvider).filters[filter] == true;

          return FilterChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (_) {
              final controller = ref.read(searchControllerProvider.notifier);
              if (isSelected) {
                controller.removeFilter(filter);
              } else {
                controller.setFilter(filter, true);
              }
              controller.search();
            },
          );
        },
      ),
    );
  }

  // ================= RESULT ITEM =================
  // Widget _resultItem(SearchResultModel item) {
  //   return Container(
  //     padding: const EdgeInsets.all(14),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(14),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 6,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       children: [
  //         if (item.imageUrl != null)
  //           Image.network(item.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
  //         else
  //           const Icon(Icons.home_work, color: AppColors.primary, size: 50),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 item.title,
  //                 style: const TextStyle(
  //                   fontWeight: FontWeight.bold,
  //                   color: AppColors.textDark,
  //                 ),
  //               ),
  //               if (item.subtitle != null)
  //                 Text(
  //                   item.subtitle!,
  //                   style: const TextStyle(color: Colors.grey),
  //                 ),
  //               if (item.price != null)
  //                 Text(
  //                   "${item.price!.toStringAsFixed(0)} FCFA",
  //                   style: const TextStyle(color: AppColors.primary),
  //                 ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _resultItem(SearchResultModel item) {
    return InkWell(
      onTap: () {
        if (item.type == 'bien') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailScreen(
                bien: item.toBienModel(), // ou item.attributes
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (item.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  baseUrl + item.imageUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              )
            else
              const Icon(Icons.home_work,
                  color: AppColors.primary, size: 50),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  if (item.subtitle != null)
                    Text(
                      item.subtitle!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  if (item.price != null)
                    Text(
                      "${item.price!.toStringAsFixed(0)} FCFA",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    }


  // ================= ACTION =================
  void _startSearch() {
    if (_searchCtrl.text.trim().isEmpty) return;

    final controller = ref.read(searchControllerProvider.notifier);
    controller.updateQuery(_searchCtrl.text.trim());
    controller.search();
  }
}

// ================= SUGGESTION ITEM =================
class _SuggestionItem extends StatelessWidget {
  final String text;
  const _SuggestionItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.search, color: AppColors.primary),
      title: Text(text),
      onTap: () {
        // Tap sur suggestion = lancer recherche
      },
    );
  }
}















// import 'package:flutter/material.dart';
// import '../../theme/colors.dart';

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController _searchCtrl = TextEditingController();

//   bool isSearching = false;

//   // 🔹 Résultats mock (sera remplacé par l’API)
//   final List<Map<String, dynamic>> results = [
//     {
//       "title": "Maison meublée à louer",
//       "subtitle": "Cotonou • 150 000 FCFA",
//       "type": "immobilier",
//     },
//     {
//       "title": "Entreprise Africa Location",
//       "subtitle": "Location & hébergement",
//       "type": "entreprise",
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         title: const Text(
//           "Recherche",
//           style: TextStyle(
//             color: AppColors.textDark,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [

//             // ================= CHAMP DE RECHERCHE =================
//             TextField(
//               controller: _searchCtrl,
//               onSubmitted: (_) => _startSearch(),
//               decoration: InputDecoration(
//                 hintText: "Rechercher un bien, prix, localisation, entreprise...",
//                 filled: true,
//                 fillColor: Colors.grey.shade100,
//                 prefixIcon: const Icon(Icons.search, color: AppColors.primary),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 14),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(14),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // ================= FILTRES =================
//             if (isSearching) _filters(),

//             const SizedBox(height: 16),

//             // ================= CONTENU =================
//             Expanded(
//               child: isSearching ? _resultsView() : _suggestionsView(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ================= SUGGESTIONS =================
//   Widget _suggestionsView() {
//     return ListView(
//       children: const [
//         _SuggestionItem(text: "Maisons à louer"),
//         _SuggestionItem(text: "Voitures disponibles"),
//         _SuggestionItem(text: "Chambres d’hôtel"),
//         _SuggestionItem(text: "Meubles pour salon"),
//         _SuggestionItem(text: "Studios meublés"),
//       ],
//     );
//   }

//   // ================= FILTRES =================
//   Widget _filters() {
//     final filters = [
//       "Immobilier",
//       "Location",
//       "Achat",
//       "Prix",
//       "Meublé",
//       "Hôtel",
//       "Véhicule",
//     ];

//     return SizedBox(
//       height: 40,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: filters.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 8),
//         itemBuilder: (context, index) {
//           return Chip(
//             label: Text(filters[index]),
//             backgroundColor: Colors.grey.shade200,
//           );
//         },
//       ),
//     );
//   }

//   // ================= RÉSULTATS =================
//   Widget _resultsView() {
//     if (results.isEmpty) {
//       return const Center(
//         child: Text(
//           "Aucun résultat trouvé",
//           style: TextStyle(color: Colors.grey),
//         ),
//       );
//     }

//     return ListView.separated(
//       itemCount: results.length,
//       separatorBuilder: (_, __) => const SizedBox(height: 12),
//       itemBuilder: (context, index) {
//         final item = results[index];

//         return Container(
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(14),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 6,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               const Icon(Icons.home_work, color: AppColors.primary),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       item["title"],
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.textDark,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       item["subtitle"],
//                       style: const TextStyle(color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // ================= ACTION =================
//   void _startSearch() {
//     if (_searchCtrl.text.trim().isEmpty) return;

//     setState(() {
//       isSearching = true;
//     });

//     // 🔜 Ici appel API :
//     // searchRepository.search(keyword: _searchCtrl.text)
//   }
// }

// // ================= SUGGESTION ITEM =================
// class _SuggestionItem extends StatelessWidget {
//   final String text;
//   const _SuggestionItem({required this.text});

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: const Icon(Icons.search, color: AppColors.primary),
//       title: Text(text),
//       onTap: () {},
//     );
//   }
// }










// import 'package:flutter/material.dart';
// import '../../theme/colors.dart';

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController _searchCtrl = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         title: const Text(
//           "Recherche",
//           style: TextStyle(
//             color: AppColors.textDark,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         // actions: [
//         //   IconButton(
//         //     onPressed: () {},
//         //     icon: const Icon(Icons.notifications_none, color: AppColors.textDark),
//         //   ),
//         // ],
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [

//             // Champ de recherche
//             TextField(
//               controller: _searchCtrl,
//               decoration: InputDecoration(
//                 hintText: "Rechercher un bien, meuble, voiture...",
//                 filled: true,
//                 fillColor: Colors.grey.shade100,
//                 prefixIcon: const Icon(Icons.search, color: AppColors.primary),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 14),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(14),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             const Text(
//               "Suggestions",
//               style: TextStyle(
//                 color: AppColors.textDark,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 16),

//             Expanded(
//               child: ListView(
//                 children: [
//                   _suggestionItem("Maisons à louer"),
//                   _suggestionItem("Voitures disponibles"),
//                   _suggestionItem("Chambres d’hôtel"),
//                   _suggestionItem("Meubles pour salon"),
//                   _suggestionItem("Studios meublés"),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _suggestionItem(String text) {
//     return ListTile(
//       leading: const Icon(Icons.search, color: AppColors.primary),
//       title: Text(text),
//       onTap: () {
//         // action lorsque l'utilisateur clique sur une suggestion
//       },
//     );
//   }
// }
