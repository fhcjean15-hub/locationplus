import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/business/providers/bien_controller_provider.dart';
import 'package:mobile/data/models/bien_model.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/presentation/screens/auth/admin/manage/user profil/demande/faire_demande_screen.dart';
import 'package:mobile/presentation/widgets/bien_card.dart';
import 'package:mobile/presentation/widgets/public_bien_card.dart';
import '../../../../../theme/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfilScreen extends ConsumerStatefulWidget {
  final User user;

  const UserProfilScreen({super.key, required this.user});

  @override
  ConsumerState<UserProfilScreen> createState() => _UserProfilScreenState();
}

class _UserProfilScreenState extends ConsumerState<UserProfilScreen> {
  final List<String> categories = [
    "Immobilier",
    "Véhicule",
    "Hôtel",
    "Hébergement",
    "Meuble",
  ];

  
  final url = "https://api-location-plus.lamadonebenin.com/storage/";

  String selectedCategory = "Immobilier";

  String _mapCategoryToBackend(String category) {
    switch (category) {
      case "Immobilier":
        return "immobilier";
      case "Véhicule":
        return "vehicule";
      case "Hôtel":
        return "hotel";
      case "Hébergement":
        return "hebergement";
      case "Meuble":
        return "meuble";
      default:
        return "";
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(bienControllerProvider.notifier)
          .fetchCompanyBiens(id: int.parse(widget.user.id));
    });
  }

  void _callPhoneNumber(String phoneNumber) async {
    final Uri telUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final biensAsync = ref.watch(bienControllerProvider);

    final isEntreprise = user.accountType == "entreprise";

    final displayName = user.accountType == "admin"
        ? "Administrateur"
        : isEntreprise
            ? "${user.companyName ?? '-'}${user.fullName != null ? ' (${user.fullName})' : ''}"
            : user.fullName ?? "-";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Utilisateur"),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- AVATAR + INFOS ----------
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary,
                    backgroundImage:
                        user.avatarUrl != null ? NetworkImage(url + user.avatarUrl!) : null,
                    child: user.avatarUrl == null
                        ? const Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(user.email ?? "-", style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    FaireDemandeScreen(utilisateur: user),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            "Faire une demande",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (user.phone != null && user.phone!.isNotEmpty) {
                              _callPhoneNumber(user.phone!);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "Appeler",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ---------- BARRE CATEGORIES ----------
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = cat == selectedCategory;

                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedCategory = cat);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      margin: const EdgeInsets.only(right: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            cat,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textDark,
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 3,
                            width: 30,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ---------- BIENS ----------
            Expanded(
              child: biensAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    const Center(child: Text("Erreur lors du chargement des biens")),
                data: (biens) {
                  final backendCategory =
                      _mapCategoryToBackend(selectedCategory);

                  final filteredBiens = biens.where((b) {
                    return b.category == backendCategory;
                  }).toList();

                  if (filteredBiens.isEmpty) {
                    return const Center(
                      child: Text("Aucun bien dans cette catégorie"),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredBiens.length,
                    itemBuilder: (_, index) {
                      final bien = filteredBiens[index];

                      return PublicBienCard(
                        item: bien,
                        ref: ref,
                        onDelete: () {},
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}







// import 'package:flutter/material.dart';
// import 'package:mobile/data/models/user_model.dart';
// import 'package:mobile/presentation/screens/auth/admin/manage/user%20profil/demande/faire_demande_screen.dart';
// import '../../../../../theme/colors.dart';
// import 'package:url_launcher/url_launcher.dart';

// class UserProfilScreen extends StatefulWidget {
//   final User user;

//   const UserProfilScreen({super.key, required this.user});

//   @override
//   State<UserProfilScreen> createState() => _UserProfilScreenState();
// }

// class _UserProfilScreenState extends State<UserProfilScreen> {
//   final List<String> categories = [
//     "Immobilier",
//     "Véhicule",
//     "Hôtel & Hébergement",
//     "Meuble",
//   ];

//   String selectedCategory = "Immobilier";
//   List<String> userBiens = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadBiens(selectedCategory);
//   }

//   void _loadBiens(String category) {
//     // TODO: Remplacer par appel API réel
//     setState(() {
//       userBiens = List.generate(
//         20,
//         (index) => "$category - Bien #${index + 1}",
//       );
//     });
//   }

//   void _callPhoneNumber(String phoneNumber) async {
//     final Uri telUri = Uri(scheme: 'tel', path: phoneNumber);
//     if (await canLaunchUrl(telUri)) {
//       await launchUrl(telUri);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Impossible de lancer l'appel")),
//       );
//     }
//   }

//   void _openWhatsApp(String phoneNumber) async {
//     final whatsappUrl = Uri.parse("https://wa.me/$phoneNumber");
//     try {
//       if (!await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication)) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Impossible d'ouvrir WhatsApp")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Erreur lors de l'ouverture de WhatsApp")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = widget.user;
//     final isEntreprise = user.accountType == "entreprise";

//     final displayName = user.accountType == "admin"
//         ? "Administrateur"
//         : isEntreprise
//             ? "${user.companyName ?? '-'}${user.fullName != null ? ' (${user.fullName})' : ''}"
//             : user.fullName ?? "-";

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Profil Utilisateur"),
//         backgroundColor: Colors.white,
//         foregroundColor: AppColors.textDark,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ---------- AVATAR + NOM + EMAIL ----------
//             Center(
//               child: Column(
//                 children: [
//                   CircleAvatar(
//                     radius: 50,
//                     backgroundColor: AppColors.primary,
//                     backgroundImage:
//                         user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
//                     child: user.avatarUrl == null
//                         ? const Icon(Icons.person, size: 50, color: Colors.white)
//                         : null,
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     displayName,
//                     style: const TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(user.email ?? "-", style: const TextStyle(fontSize: 16)),
//                   const SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton(
//                           onPressed: () {
//                             // Ouvrir directement l'écran de demande au clic
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(builder: (_) => FaireDemandeScreen(utilisateur: user)),
//                             );
//                           },
//                           style: OutlinedButton.styleFrom(
//                             side: BorderSide(color: AppColors.primary),
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: Text(
//                             "Faire une demande",
//                             style: TextStyle(
//                               color: AppColors.primary,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () {
//                             if (user.phone != null && user.phone!.isNotEmpty) {
//                               _callPhoneNumber(user.phone!);
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(content: Text("Numéro non disponible")),
//                               );
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.primary,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: const Text(
//                             "Appeler",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                 ],
//               ),
//             ),

//             // ---------- CATEGORIES HORIZONTALES ----------
//             SizedBox(
//               height: 40,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: categories.length,
//                 itemBuilder: (context, index) {
//                   final cat = categories[index];
//                   final isSelected = cat == selectedCategory;
//                   return GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         selectedCategory = cat;
//                         _loadBiens(cat);
//                       });
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 12),
//                       margin: const EdgeInsets.only(right: 16),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           Text(
//                             cat,
//                             style: TextStyle(
//                               color: isSelected ? AppColors.primary : AppColors.textDark,
//                               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Container(
//                             height: 3,
//                             width: 30,
//                             decoration: BoxDecoration(
//                               color: isSelected ? AppColors.primary : Colors.transparent,
//                               borderRadius: BorderRadius.circular(2),
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             const SizedBox(height: 16),

//             // ---------- LISTE VERTICALE DES BIENS ----------
//             Expanded(
//               child: ListView.builder(
//                 itemCount: userBiens.length,
//                 itemBuilder: (context, index) {
//                   final bien = userBiens[index];
//                   return Card(
//                     elevation: 2,
//                     margin: const EdgeInsets.only(bottom: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: InkWell(
//                       borderRadius: BorderRadius.circular(12),
//                       onTap: () {
//                         // TODO: afficher détail du bien
//                       },
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               bien,
//                               style: const TextStyle(fontWeight: FontWeight.w500),
//                             ),
//                             const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }








// import 'package:flutter/material.dart';
// import 'package:mobile/data/models/user_model.dart';
// import '../../../../../theme/colors.dart';
// import 'package:url_launcher/url_launcher.dart';

// class UserProfilScreen extends StatefulWidget {
//   final User user;

//   const UserProfilScreen({super.key, required this.user});

//   @override
//   State<UserProfilScreen> createState() => _UserProfilScreenState();
// }

// class _UserProfilScreenState extends State<UserProfilScreen> {
//   final List<String> categories = [
//     "Immobilier",
//     "Véhicule",
//     "Hôtel & Hébergement",
//     "Meuble",
//   ];

//   String selectedCategory = "Immobilier";
//   List<String> userBiens = []; // placeholder pour liste de biens

//   @override
//   void initState() {
//     super.initState();
//     _loadBiens(selectedCategory);
//   }

//   void _loadBiens(String category) {
//     // TODO: Remplacer par appel API pour récupérer biens de l'utilisateur
//     setState(() {
//       userBiens = List.generate(
//         20,
//         (index) => "$category - Bien #${index + 1}",
//       ); // placeholder
//     });
//   }

//   void _callPhoneNumber(String phoneNumber) async {
//     final Uri telUri = Uri(scheme: 'tel', path: phoneNumber);
//     if (await canLaunchUrl(telUri)) {
//       await launchUrl(telUri);
//     } else {
//       // Si impossible d'appeler
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Impossible de lancer l'appel")),
//       );
//     }
//   }

//   void _openWhatsApp(String phoneNumber) async {
//     final whatsappUrl = Uri.parse("https://wa.me/$phoneNumber");

//     try {
//       if (!await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication)) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Impossible d'ouvrir WhatsApp")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Erreur lors de l'ouverture de WhatsApp")),
//       );
//     }
//   }


//   @override
//   Widget build(BuildContext context) {
//     final user = widget.user;
//     final isEntreprise = user.accountType == "entreprise";

//     final displayName = user.accountType == "admin"
//         ? "Administrateur"
//         : isEntreprise
//         ? "${user.companyName ?? '-'}${user.fullName != null ? ' (${user.fullName})' : ''}"
//         : user.fullName ?? "-";

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Profil Utilisateur"),
//         backgroundColor: Colors.white,
//         foregroundColor: AppColors.textDark,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ---------------- AVATAR + NOM + EMAIL ----------------
//             Center(
//               child: Column(
//                 children: [
//                   CircleAvatar(
//                     radius: 50,
//                     backgroundColor: AppColors.primary,
//                     backgroundImage: user.avatarUrl != null
//                         ? NetworkImage(user.avatarUrl!)
//                         : null,
//                     child: user.avatarUrl == null
//                         ? const Icon(
//                             Icons.person,
//                             size: 50,
//                             color: Colors.white,
//                           )
//                         : null,
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     displayName,
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(user.email ?? "-", style: const TextStyle(fontSize: 16)),
//                   const SizedBox(height: 16),
//                   // ---------------- BOUTONS JUSTE SOUS L'EMAIL ----------------
//                   Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton(
//                           onPressed: () {
//                             // TODO: Faire une demande
//                           },
//                           style: OutlinedButton.styleFrom(
//                             side: BorderSide(color: AppColors.textLight),
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(7),
//                             ),
//                             backgroundColor: AppColors.primary,
//                           ),
//                           child: Text(
//                             "Faire une demande",
//                             style: TextStyle(
//                               color: AppColors.textLight,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () {
//                             if (user.phone != null && user.phone!.isNotEmpty) {
//                               final phone = user.phone;
//                               print('my phone = $phone');
//                               _callPhoneNumber(user.phone!);
//                               // _openWhatsApp(user.phone!);
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(content: Text("Numéro WhatsApp non disponible")),
//                               );
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(7),
//                             ),
//                           ),
//                           child: const Text(
//                             "Appeler",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                 ],
//               ),
//             ),

//             // ---------------- CATEGORIES HORIZONTALES ----------------
//             SizedBox(
//               height: 50,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: categories.length,
//                 itemBuilder: (context, index) {
//                   final cat = categories[index];
//                   final isSelected = cat == selectedCategory;
//                   return GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         selectedCategory = cat;
//                         _loadBiens(cat);
//                       });
//                     },
//                     child: Container(
//                       margin: const EdgeInsets.only(right: 12),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 12,
//                       ),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? AppColors.primary
//                             : Colors.grey.shade200,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         cat,
//                         style: TextStyle(
//                           color: isSelected ? Colors.white : AppColors.textDark,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             const SizedBox(height: 16),

//             // ---------------- LISTE VERTICALE BIENS SCROLLABLE ----------------
//             Expanded(
//               child: ListView.builder(
//                 itemCount: userBiens.length,
//                 itemBuilder: (context, index) {
//                   final bien = userBiens[index];
//                   return Card(
//                     margin: const EdgeInsets.only(bottom: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: ListTile(
//                       title: Text(bien),
//                       trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                       onTap: () {
//                         // TODO: afficher détail du bien
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



























// import 'package:flutter/material.dart';
// import 'package:mobile/data/models/user_model.dart';
// import '../../../../../theme/colors.dart';

// class UserProfilScreen extends StatefulWidget {
//   final User user;

//   const UserProfilScreen({super.key, required this.user});

//   @override
//   State<UserProfilScreen> createState() => _UserProfilScreenState();
// }

// class _UserProfilScreenState extends State<UserProfilScreen> {
//   final List<String> categories = [
//     "Immobilier",
//     "Véhicule",
//     "Hôtel & Hébergement",
//     "Meuble"
//   ];

//   String selectedCategory = "Immobilier";
//   List<String> userBiens = []; // placeholder pour liste de biens

//   @override
//   void initState() {
//     super.initState();
//     _loadBiens(selectedCategory);
//   }

//   void _loadBiens(String category) {
//     // TODO: Remplacer par appel API pour récupérer biens de l'utilisateur
//     setState(() {
//       userBiens = List.generate(
//           20, (index) => "$category - Bien #${index + 1}"); // placeholder
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = widget.user;
//     final isEntreprise = user.accountType == "entreprise";

//     final displayName = user.accountType == "admin"
//         ? "Administrateur"
//         : isEntreprise
//             ? "${user.companyName ?? '-'}${user.fullName != null ? ' (${user.fullName})' : ''}"
//             : user.fullName ?? "-";

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Profil Utilisateur"),
//         backgroundColor: Colors.white,
//         foregroundColor: AppColors.textDark,
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // ---------------- AVATAR + NOM + EMAIL ----------------
//                   Center(
//                     child: Column(
//                       children: [
//                         CircleAvatar(
//                           radius: 50,
//                           backgroundColor: AppColors.primary,
//                           backgroundImage: user.avatarUrl != null
//                               ? NetworkImage(user.avatarUrl!)
//                               : null,
//                           child: user.avatarUrl == null
//                               ? const Icon(Icons.person,
//                                   size: 50, color: Colors.white)
//                               : null,
//                         ),
//                         const SizedBox(height: 12),
//                         Text(
//                           displayName,
//                           style: const TextStyle(
//                               fontSize: 20, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           user.email ?? "-",
//                           style: const TextStyle(fontSize: 16),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 24),

//                   // ---------------- CATEGORIES HORIZONTALES ----------------
//                   SizedBox(
//                     height: 50,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: categories.length,
//                       itemBuilder: (context, index) {
//                         final cat = categories[index];
//                         final isSelected = cat == selectedCategory;
//                         return GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               selectedCategory = cat;
//                               _loadBiens(cat);
//                             });
//                           },
//                           child: Container(
//                             margin: const EdgeInsets.only(right: 12),
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 16, vertical: 12),
//                             decoration: BoxDecoration(
//                               color: isSelected
//                                   ? AppColors.primary
//                                   : Colors.grey.shade200,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Text(
//                               cat,
//                               style: TextStyle(
//                                 color: isSelected
//                                     ? Colors.white
//                                     : AppColors.textDark,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),

//                   const SizedBox(height: 16),

//                   // ---------------- LISTE VERTICALE BIENS ----------------
//                   ListView.builder(
//                     physics: const NeverScrollableScrollPhysics(),
//                     shrinkWrap: true,
//                     itemCount: userBiens.length,
//                     itemBuilder: (context, index) {
//                       final bien = userBiens[index];
//                       return Card(
//                         margin: const EdgeInsets.only(bottom: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: ListTile(
//                           title: Text(bien),
//                           trailing:
//                               const Icon(Icons.arrow_forward_ios, size: 16),
//                           onTap: () {
//                             // TODO: afficher détail du bien
//                           },
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // ---------------- BOUTONS EN BAS ----------------
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // TODO: Appeler utilisateur
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                     ),
//                     child: const Text(
//                       "Appeler",
//                       style: TextStyle(
//                           color: Colors.white, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () {
//                       // TODO: Faire une demande
//                     },
//                     style: OutlinedButton.styleFrom(
//                       side: BorderSide(color: AppColors.textLight),
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                       backgroundColor: Colors.blueAccent,
//                     ),
//                     child: Text(
//                       "Faire une demande",
//                       style: TextStyle(
//                           color: AppColors.textLight, fontWeight: FontWeight.bold),
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











// import 'package:flutter/material.dart';
// import 'package:mobile/data/models/user_model.dart';
// import '../../../../../theme/colors.dart';

// class UserProfilScreen extends StatefulWidget {
//   final User user;

//   const UserProfilScreen({super.key, required this.user});

//   @override
//   State<UserProfilScreen> createState() => _UserProfilScreenState();
// }

// class _UserProfilScreenState extends State<UserProfilScreen> {
//   final List<String> categories = [
//     "Immobilier",
//     "Véhicule",
//     "Hôtel & Hébergement",
//     "Meuble"
//   ];

//   String selectedCategory = "Immobilier";
//   List<String> userBiens = []; // placeholder pour liste infinie

//   @override
//   void initState() {
//     super.initState();
//     _loadBiens(selectedCategory);
//   }

//   void _loadBiens(String category) {
//     // TODO: Remplacer par appel API pour récupérer biens de l'utilisateur
//     setState(() {
//       userBiens = List.generate(
//           20, (index) => "$category - Bien #${index + 1}"); // placeholder
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = widget.user;
//     final isEntreprise = user.accountType == "entreprise";
//     final displayName = user.accountType == "admin"
//         ? "Administrateur"
//         : isEntreprise
//             ? "${user.companyName ?? '-'} (${user.fullName ?? '-'})"
//             : user.fullName ?? "-";

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Profil Utilisateur"),
//         backgroundColor: Colors.white,
//         foregroundColor: AppColors.textDark,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ---------------- AVATAR + NOM ----------------
//             Center(
//               child: Column(
//                 children: [
//                   CircleAvatar(
//                     radius: 50,
//                     backgroundColor: AppColors.primary,
//                     backgroundImage:
//                         user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
//                     child: user.avatarUrl == null
//                         ? const Icon(Icons.person, size: 50, color: Colors.white)
//                         : null,
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     displayName,
//                     style: const TextStyle(
//                         fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),

//             // ---------------- INFOS ----------------
//             _infoRow("Email", user.email ?? "-"),
//             if (user.phone != null && user.phone!.isNotEmpty)
//               _infoRow("Téléphone", user.phone!),
//             _infoRow("Type", user.accountType),
//             _infoRow("Statut documents",
//                 user.verifiedDocuments ? "Validé" : "En attente"),
//             _infoRow("Activé", user.activated ? "Oui" : "Non"),

//             const SizedBox(height: 20),

//             // ---------------- BOUTONS ----------------
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () {
//                       // TODO: Faire une demande
//                     },
//                     style: OutlinedButton.styleFrom(
//                       side: BorderSide(color: AppColors.primary),
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                     ),
//                     child: Text(
//                       "Faire une demande",
//                       style: TextStyle(
//                           color: AppColors.primary, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // TODO: Appeler utilisateur
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primary,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                     ),
//                     child: const Text(
//                       "Appeler",
//                       style: TextStyle(
//                           color: Colors.white, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 24),

//             // ---------------- CATEGORIES HORIZONTALES ----------------
//             SizedBox(
//               height: 50,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: categories.length,
//                 itemBuilder: (context, index) {
//                   final cat = categories[index];
//                   final isSelected = cat == selectedCategory;
//                   return GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         selectedCategory = cat;
//                         _loadBiens(cat);
//                       });
//                     },
//                     child: Container(
//                       margin: const EdgeInsets.only(right: 12),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 12),
//                       decoration: BoxDecoration(
//                         color: isSelected
//                             ? AppColors.primary
//                             : Colors.grey.shade200,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         cat,
//                         style: TextStyle(
//                           color: isSelected ? Colors.white : AppColors.textDark,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             const SizedBox(height: 16),

//             // ---------------- LISTE VERTICALE BIENS ----------------
//             ListView.builder(
//               physics: const NeverScrollableScrollPhysics(),
//               shrinkWrap: true,
//               itemCount: userBiens.length,
//               itemBuilder: (context, index) {
//                 final bien = userBiens[index];
//                 return Card(
//                   margin: const EdgeInsets.only(bottom: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: ListTile(
//                     title: Text(bien),
//                     trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                     onTap: () {
//                       // TODO: afficher détail du bien
//                     },
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _infoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: RichText(
//         text: TextSpan(
//           children: [
//             TextSpan(
//               text: "$label : ",
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.textDark,
//               ),
//             ),
//             TextSpan(
//               text: value,
//               style: const TextStyle(color: AppColors.textDark),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }































// import 'package:flutter/material.dart';
// import 'package:mobile/data/models/user_model.dart';
// import '../../../../../theme/colors.dart';

// class UserProfilScreen extends StatelessWidget {
//   final User user;

//   const UserProfilScreen({super.key, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Profil Utilisateur"),
//         backgroundColor: Colors.white,
//         foregroundColor: AppColors.textDark,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             CircleAvatar(
//               radius: 50,
//               backgroundImage:
//                   user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
//               child: user.avatarUrl == null
//                   ? const Icon(Icons.person, size: 50, color: Colors.white)
//                   : null,
//             ),
//             const SizedBox(height: 16),
//             Text("Nom : ${user.fullName ?? user.companyName ?? '-'}"),
//             Text("Email : ${user.email}"),
//             Text("Téléphone : ${user.phone ?? '-'}"),
//             Text("Type : ${user.accountType}"),
//             Text(
//                 "Statut documents : ${user.verifiedDocuments ? "Validé" : "En attente"}"),
//             Text("Activé : ${user.activated ? "Oui" : "Non"}"),
//           ],
//         ),
//       ),
//     );
//   }
// }
