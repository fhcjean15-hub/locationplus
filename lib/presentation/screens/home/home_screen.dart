import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/business/providers/bien_controller_provider.dart';
import 'package:mobile/business/providers/auth_controller_provider.dart';
import 'package:mobile/data/models/bien_model.dart';
import 'package:mobile/presentation/components/hebergement_card.dart';
import 'package:mobile/presentation/components/hotel_card.dart';
import 'package:mobile/presentation/components/immobilier_card.dart';
import 'package:mobile/presentation/components/meuble_card.dart';
import 'package:mobile/presentation/components/vehicule_card.dart';
import 'package:mobile/presentation/screens/account/account_screen.dart';
import 'package:mobile/presentation/screens/bien/biens_screen.dart';
import 'package:mobile/presentation/screens/notifications/notifications_screen.dart';
import 'package:mobile/presentation/screens/search/search_screen.dart';
import '../../theme/colors.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 0.92);

  final List<Map<String, String>> rubriqueCarousel = [
    {
      "title": "Immobilier",
      "description": "Maisons, appartements, terrains",
      "image": "assets/images/chambre.jpg",
    },
    {
      "title": "Hôtels & Hébergements",
      "description": "Hôtels & chambres meublées",
      "image": "assets/images/hotel.jpg",
    },
    {
      "title": "Véhicules",
      "description": "Voitures, motos à louer ou acheter",
      "image": "assets/images/vehicule.png",
    },
    {
      "title": "Meubles",
      "description": "Meubles à acheter",
      "image": "assets/images/meuble.jpg",
    },
  ];
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authControllerProvider);
      if (authState.user != null) {
        ref.read(bienControllerProvider.notifier).fetchAllUserBiens();
      } else {
        ref.read(bienControllerProvider.notifier).fetchAllBiensPublic();
      }
    });
    _startAutoScroll();
  }


  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;

      _currentPage = (_currentPage + 1) % rubriqueCarousel.length;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );

      _startAutoScroll();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      bottomNavigationBar: _buildBottomNav(),
      body: _buildBody(),
    );
  }

  // ---------------- APP BAR ----------------
  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Image.asset("assets/images/africalocation_logo.png", height: 32),
          const SizedBox(width: 8),
          const Text(
            "africaLocation",
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),

      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: AppColors.textDark),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ---------------- BOTTOM NAV ----------------
  BottomNavigationBar _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.black87,
      type: BottomNavigationBarType.fixed,
      onTap: (i) => setState(() => _selectedIndex = i),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Recherche"),
        BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Biens"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Compte"),
      ],
    );
  }


    // ---------------------------------------------------------
  // BODY NAVIGATION
  // ---------------------------------------------------------
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const SearchScreen();
      case 2:
        return const BiensScreen();
      case 3:
        return const AccountScreen();
      default:
        return _buildHomeContent();
    }
  }

  // ---------------- BODY ----------------

  Widget _buildHomeContent() {
    final biensAsync = ref.watch(bienControllerProvider);

    return biensAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Erreur : $e")),
      data: (biens) {
        final List<BienModel> allBiens = biens.whereType<BienModel>().toList();

        final immobiliers = allBiens
            .where((b) => b.category == 'immobilier')
            .toList();
        final meubles = allBiens.where((b) => b.category == 'meuble').toList();
        final hotels = allBiens.where((b) => b.category == 'hotel').toList();
        final vehicules = allBiens
            .where((b) => b.category == 'vehicule')
            .toList();
        final hebergements = allBiens
            .where((b) => b.category == 'hebergement')
            .toList();

        return RefreshIndicator(
          onRefresh: () async {
            final authState = ref.read(authControllerProvider);
            if (authState.user != null) {
              await ref
                  .read(bienControllerProvider.notifier)
                  .fetchAllUserBiens();
            } else {
              await ref
                  .read(bienControllerProvider.notifier)
                  .fetchAllBiensPublic();
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------------------- CAROUSEL RUBRIQUES --------------------
                SizedBox(
                  height: 220,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: rubriqueCarousel.length,
                    itemBuilder: (_, index) {
                      final item = rubriqueCarousel[index];

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: AssetImage(item["image"]!),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.5),
                                Colors.black.withOpacity(0.1),
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["title"]!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item["description"]!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                if (immobiliers.isNotEmpty) ...[
                  _section("Immobilier", immobiliers),
                  const SizedBox(height: 24),
                ],

                if (meubles.isNotEmpty) ...[
                  _section("Meubles", meubles),
                  const SizedBox(height: 24),
                ],

                if (hotels.isNotEmpty) ...[
                  _section("Hôtels", hotels),
                  const SizedBox(height: 24),
                ],

                if (vehicules.isNotEmpty) ...[
                  _section("Véhicules", vehicules),
                  const SizedBox(height: 24),
                ],

                if (hebergements.isNotEmpty) ...[
                  _section("Hébergements", hebergements),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardByCategory(BienModel bien) {
    switch (bien.category) {
      case 'immobilier':
        return ImmobilierCard(bien: bien);

      case 'meuble':
        return MeubleCard(bien: bien);

      // prêts pour la suite
      case 'hotel':
        return HotelCard(bien: bien);

      case 'vehicule':
        return VehiculeCard(bien: bien);

      case 'hebergement':
        return HebergementCard(bien: bien);

      default:
        return _SimpleBienCard(bien: bien);
    }
  }

  // ---------------- SECTION ----------------
  Widget _section(String title, List<BienModel> biens) {
    if (biens.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: biens.length,
            itemBuilder: (_, i) {
              return _buildCardByCategory(biens[i]);
            },

            //             itemBuilder: (_, index) {
            //   return ImmobilierCard(
            //     bien: biensImmobilier[index],
            //   );
            // },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ---------------- SIMPLE CARD (DEBUG SAFE) ----------------
class _SimpleBienCard extends StatelessWidget {
  final BienModel bien;

  const _SimpleBienCard({required this.bien});

  @override
  Widget build(BuildContext context) {
    final imageUrl = bien.images.isNotEmpty
        ? bien.images.first
        : "assets/images/chambre.jpg";
        
    final baseUrl = "https://api-location-plus.lamadonebenin.com/storage/";

    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
                    baseUrl + imageUrl,
                    height: 130,
                    width: 220,
                    fit: BoxFit.cover,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              bien.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              "${bien.city ?? ''} • ${bien.price.toStringAsFixed(0)} F",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}






























// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile/business/providers/auth_controller_provider.dart';
// import 'package:mobile/business/providers/bien_controller_provider.dart';
// import 'package:mobile/data/models/bien_model.dart';
// import 'package:mobile/presentation/screens/Details/DetailScreen.dart';
// import 'package:mobile/presentation/screens/notifications/notifications_screen.dart';
// import 'package:mobile/presentation/screens/search/search_screen.dart';
// import 'package:mobile/presentation/screens/account/account_screen.dart';
// import 'package:mobile/presentation/screens/bien/biens_screen.dart';
// import '../../theme/colors.dart';
// import '../../../../business/controllers/overlay_controller.dart';

// class HomeScreen extends ConsumerStatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   ConsumerState<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends ConsumerState<HomeScreen> {
//   int _selectedIndex = 0;
//   final PageController _pageController = PageController();
//   int _currentPage = 0;

//   final List<Map<String, String>> rubriqueCarousel = [
//     {
//       "title": "Immobilier",
//       "description": "Trouvez maisons, bureaux, studios...",
//       "image": "assets/images/rubriques/onboarding_immobilier.png",
//     },
//     {
//       "title": "Meubles",
//       "description": "Chaises, canapés, armoires et plus",
//       "image": "assets/images/rubriques/onboarding_meubles.png",
//     },
//     {
//       "title": "Véhicules",
//       "description": "Voitures, motos, camions disponibles",
//       "image": "assets/images/rubriques/onboarding_voitures.png",
//     },
//     {
//       "title": "Hôtels & Hébergement",
//       "description": "Chambres, résidences, appartements",
//       "image": "assets/images/rubriques/onboarding_hotels.png",
//     },
//   ];


//   @override
//   void initState() {
//     super.initState();
//     _startAutoScroll();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final authState = ref.read(authControllerProvider);
//       if (authState.user != null) {
//         ref.read(bienControllerProvider.notifier).fetchAllUserBiens();
//       } else {
//         ref.read(bienControllerProvider.notifier).fetchAllBiensPublic();
//       }
//     });
//   }

//   void _startAutoScroll() {
//     Future.delayed(const Duration(seconds: 5), () {
//       if (!mounted) return;

//       _currentPage = (_currentPage + 1) % rubriqueCarousel.length;
//       _pageController.animateToPage(
//         _currentPage,
//         duration: const Duration(milliseconds: 600),
//         curve: Curves.easeInOut,
//       );

//       _startAutoScroll();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: _buildAppBar(),
//       body: _buildBody(),
//       bottomNavigationBar: _buildBottomNav(),
//     );
//   }

//   AppBar _buildAppBar() {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: Colors.white,
//       title: Row(
//         children: [
//           Image.asset("assets/images/africalocation_logo.png", height: 32),
//           const SizedBox(width: 8),
//           const Text(
//             "africaLocation",
//             style: TextStyle(
//               color: AppColors.textDark,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.notifications_none, color: AppColors.textDark),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const NotificationsScreen()),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   BottomNavigationBar _buildBottomNav() {
//     return BottomNavigationBar(
//       currentIndex: _selectedIndex,
//       selectedItemColor: AppColors.primary,
//       unselectedItemColor: Colors.black87,
//       type: BottomNavigationBarType.fixed,
//       onTap: (i) => setState(() => _selectedIndex = i),
//       items: const [
//         BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
//         BottomNavigationBarItem(icon: Icon(Icons.search), label: "Recherche"),
//         BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Biens"),
//         BottomNavigationBarItem(icon: Icon(Icons.person), label: "Compte"),
//       ],
//     );
//   }

//   Widget _buildBody() {
//     switch (_selectedIndex) {
//       case 0:
//         return _buildHomeContent();
//       case 1:
//         return const SearchScreen();
//       case 2:
//         return const BiensScreen();
//       case 3:
//         return const AccountScreen();
//       default:
//         return _buildHomeContent();
//     }
//   }

//   Widget _buildHomeContent() {
//     final biensAsync = ref.watch(bienControllerProvider);

//     return biensAsync.when(
//       loading: () => const Center(child: CircularProgressIndicator()),
//       error: (e, _) => Center(child: Text("Erreur : $e")),
//       data: (biens) {
//         final allBiens = biens.whereType<BienModel>().toList();

//         final immobiliers = allBiens.where((b) => b.category == 'immobilier').take(10).toList();
//         final meubles = allBiens.where((b) => b.category == 'meuble').take(10).toList();
//         final vehicules = allBiens.where((b) => b.category == 'vehicule').take(10).toList();
//         final hotels = allBiens.where((b) => b.category == 'hotel').take(10).toList();
//         final hebergements = allBiens.where((b) => b.category == 'hebergement').take(10).toList();

//         return RefreshIndicator(
//           onRefresh: () async {
//             final authState = ref.read(authControllerProvider);
//             if (authState.user != null) {
//               await ref.read(bienControllerProvider.notifier).fetchAllUserBiens();
//             } else {
//               await ref.read(bienControllerProvider.notifier).fetchAllBiensPublic();
//             }
//           },
//           child: SingleChildScrollView(
//             physics: const AlwaysScrollableScrollPhysics(),
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 // ------------------- CAROUSEL RUBRIQUES --------------------
//                 SizedBox(
//                   height: 220,
//                   child: PageView.builder(
//                     controller: _pageController,
//                     itemCount: rubriqueCarousel.length,
//                     itemBuilder: (_, index) {
//                       final item = rubriqueCarousel[index];

//                       return Container(
//                         margin: const EdgeInsets.symmetric(horizontal: 6),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(16),
//                           image: DecorationImage(
//                             image: AssetImage(item["image"]!),
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(16),
//                             gradient: LinearGradient(
//                               colors: [
//                                 Colors.black.withOpacity(0.5),
//                                 Colors.black.withOpacity(0.1),
//                               ],
//                               begin: Alignment.bottomCenter,
//                               end: Alignment.topCenter,
//                             ),
//                           ),
//                           padding: const EdgeInsets.all(16),
//                           child: Align(
//                             alignment: Alignment.bottomLeft,
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   item["title"]!,
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 6),
//                                 Text(
//                                   item["description"]!,
//                                   style: const TextStyle(
//                                     color: Colors.white70,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),

//                 const SizedBox(height: 24),
                
//                 _section("Nouvelles offres immobilières", _buildImmobilierCarousel(immobiliers)),
//                 _section("Nouveaux meubles disponibles", _buildMeublesCarousel(meubles)),
//                 _section("Chambres d'hôtels récentes", _buildHotelsCarousel(hotels)),
//                 _section("Nouveaux véhicules", _buildVehiculeCarousel(vehicules)),
//                 _section("Hébergements récents", _buildHebergementsCarousel(hebergements)),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _section(String title, Widget content) {
//     if (content is SizedBox) return const SizedBox.shrink();
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 24),
//         Text(
//           title,
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
//         ),
//         const SizedBox(height: 10),
//         content,
//       ],
//     );
//   }

//   // ---------------------------------------------------------
//   // CAROUSELS & INTERNAL CARDS
//   // ---------------------------------------------------------
//   Widget _buildImmobilierCarousel(List<BienModel> biens) {
//     if (biens.isEmpty) return const SizedBox();
//     return SizedBox(height: 260, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: biens.length, itemBuilder: (_, i) => _ImmobilierCardWidget(bien: biens[i])));
//   }

//   Widget _buildMeublesCarousel(List<BienModel> biens) {
//     if (biens.isEmpty) return const SizedBox();
//     return SizedBox(height: 300, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: biens.length, itemBuilder: (_, i) => _MeubleCardWidget(bien: biens[i])));
//   }

//   Widget _buildHotelsCarousel(List<BienModel> biens) {
//     if (biens.isEmpty) return const SizedBox();
//     return SizedBox(height: 260, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: biens.length, itemBuilder: (_, i) => _HotelCardWidget(bien: biens[i])));
//   }

//   Widget _buildHebergementsCarousel(List<BienModel> biens) {
//     if (biens.isEmpty) return const SizedBox();
//     return SizedBox(height: 260, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: biens.length, itemBuilder: (_, i) => _HebergementCardWidget(bien: biens[i])));
//   }

//   Widget _buildVehiculeCarousel(List<BienModel> biens) {
//     if (biens.isEmpty) return const SizedBox();
//     return SizedBox(height: 260, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: biens.length, itemBuilder: (_, i) => _VehiculeCardWidget(bien: biens[i])));
//   }
// }









// class _HebergementCardWidget extends StatelessWidget {
//   final BienModel bien;
//   const _HebergementCardWidget({required this.bien});

//   @override
//   Widget build(BuildContext context) {
//     final String imageUrl = bien.images.isNotEmpty ? bien.images.first : 'assets/images/hotel.jpg';
//     final String city = bien.city ?? 'Localisation inconnue';
//     final String priceText = "${bien.price.toStringAsFixed(0)} F /nuit";

//     return Container(
//       width: 240,
//       margin: const EdgeInsets.only(right: 16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         color: Colors.white,
//         boxShadow: [BoxShadow(color: Colors.black12.withOpacity(.05), blurRadius: 6, spreadRadius: 2)],
//       ),
//       child: Stack(
//         children: [
//           // IMAGE AVEC OMBRAGE
//           ClipRRect(
//             borderRadius: BorderRadius.circular(16),
//             child: ColorFiltered(
//               colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.35), BlendMode.darken),
//               child: imageUrl.startsWith('http')
//                   ? Image.network(imageUrl, height: 260, width: 240, fit: BoxFit.cover)
//                   : Image.asset(imageUrl, height: 260, width: 240, fit: BoxFit.cover),
//             ),
//           ),

//           // FAVORI
//           const Positioned(
//             top: 10,
//             right: 10,
//             child: CircleAvatar(
//               radius: 16,
//               backgroundColor: Colors.white,
//               child: Icon(Icons.favorite_border, color: AppColors.primary),
//             ),
//           ),

//           // CONTENU TEXTE + BOUTON
//           Positioned(
//             left: 12,
//             right: 12,
//             bottom: 12,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   bien.title,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(city, style: const TextStyle(color: Colors.white, fontSize: 14)),
//                 if (bien.attributes.isNotEmpty)
//                   Text(
//                     bien.attributes.values.join(' • '),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(color: Colors.white70, fontSize: 13),
//                   ),
//                 const SizedBox(height: 8),
//                 Text(priceText, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 12),
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
//                   child: GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => DetailScreen(bien: bien)),
//                       );
//                     },
//                     child: const Center(
//                       child: Text("Réserver", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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






// class _HotelCardWidget extends StatelessWidget {
//   final BienModel bien;
//   const _HotelCardWidget({required this.bien});

//   @override
//   Widget build(BuildContext context) {
//     final String imageUrl = bien.images.isNotEmpty ? bien.images.first : 'assets/images/hotel.jpg';
//     final String city = bien.city ?? 'Localisation inconnue';
//     final String priceText = "${bien.price.toStringAsFixed(0)} F /nuit";

//     return Container(
//       width: 240,
//       margin: const EdgeInsets.only(right: 16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         color: Colors.white,
//         boxShadow: [BoxShadow(color: Colors.black12.withOpacity(.05), blurRadius: 6, spreadRadius: 2)],
//       ),
//       child: Stack(
//         children: [
//           // IMAGE AVEC OMBRAGE
//           ClipRRect(
//             borderRadius: BorderRadius.circular(16),
//             child: ColorFiltered(
//               colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.35), BlendMode.darken),
//               child: imageUrl.startsWith('http')
//                   ? Image.network(imageUrl, height: 260, width: 240, fit: BoxFit.cover)
//                   : Image.asset(imageUrl, height: 260, width: 240, fit: BoxFit.cover),
//             ),
//           ),

//           // FAVORI
//           const Positioned(
//             top: 10,
//             right: 10,
//             child: CircleAvatar(
//               radius: 16,
//               backgroundColor: Colors.white,
//               child: Icon(Icons.favorite_border, color: AppColors.primary),
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
//                 Text(
//                   bien.title,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(city, style: const TextStyle(color: Colors.white, fontSize: 14)),
//                 if (bien.attributes.isNotEmpty)
//                   Text(
//                     bien.attributes.entries
//                         .take(2)
//                         .map((e) => _formatAttribute(e.key, e.value))
//                         .join(' • '),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(color: Colors.white70, fontSize: 13),
//                   ),
//                 const SizedBox(height: 8),
//                 Text(priceText, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 12),
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
//                   child: GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => DetailScreen(bien: bien)),
//                       );
//                     },
//                     child: const Center(
//                       child: Text("Réserver", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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

//   String _formatAttribute(String key, dynamic value) {
//     switch (key) {
//       case 'room_type':
//         return value.toString();
//       case 'capacity':
//         return "$value pers.";
//       case 'bedrooms':
//         return "$value chambre(s)";
//       default:
//         return value.toString();
//     }
//   }
// }










// class _MeubleCardWidget extends StatelessWidget {
//   final BienModel bien;
//   const _MeubleCardWidget({required this.bien});

//   @override
//   Widget build(BuildContext context) {
//     final String imageUrl = bien.images.isNotEmpty ? bien.images.first : "assets/images/meuble.jpg";
//     final String city = bien.city ?? "Abomey-Calavi";
//     final String priceText = "${bien.price.toStringAsFixed(0)} F";

//     return ClipRRect(
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         width: 260,
//         margin: const EdgeInsets.only(right: 16),
//         color: Colors.white,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // IMAGE + TAG + FAVORI
//             Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//                   child: imageUrl.startsWith('http')
//                       ? Image.network(imageUrl, height: 120, width: 260, fit: BoxFit.cover)
//                       : Image.asset(imageUrl, height: 120, width: 260, fit: BoxFit.cover),
//                 ),
//                 Positioned(
//                   top: 10,
//                   left: 10,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//                     decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(30)),
//                     child: const Text(
//                       "Meuble",
//                       style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//                 const Positioned(
//                   top: 8,
//                   right: 10,
//                   child: CircleAvatar(radius: 16, backgroundColor: Colors.white, child: Icon(Icons.favorite_border, color: AppColors.primary)),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 8),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Text(
//                 bien.title,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//             ),

//             const SizedBox(height: 4),

//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 10),
//               child: Row(
//                 children: [
//                   Icon(Icons.star, color: Colors.amber, size: 18),
//                   Icon(Icons.star, color: Colors.amber, size: 18),
//                   Icon(Icons.star, color: Colors.amber, size: 18),
//                   Icon(Icons.star, color: Colors.amber, size: 18),
//                   Icon(Icons.star_half, color: Colors.amber, size: 18),
//                   SizedBox(width: 6),
//                   Text("(4)", style: TextStyle(fontSize: 12)),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 4),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Text(city, style: const TextStyle(fontSize: 12)),
//             ),

//             const SizedBox(height: 6),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Text(priceText, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red)),
//             ),

//             const SizedBox(height: 8),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
//                       child: GestureDetector(
//                         onTap: () {
//                           Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(bien: bien)));
//                         },
//                         child: const Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.shopping_cart, color: Colors.white),
//                             SizedBox(width: 6),
//                             Text("Acheter", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(12)),
//                     child: const Icon(Icons.remove_red_eye),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 10),
//           ],
//         ),
//       ),
//     );
//   }
// }







// class _ImmobilierCardWidget extends StatefulWidget {
//   final BienModel bien;
//   const _ImmobilierCardWidget({required this.bien});

//   @override
//   State<_ImmobilierCardWidget> createState() => _ImmobilierCardWidgetState();
// }

// class _ImmobilierCardWidgetState extends State<_ImmobilierCardWidget> {
//   bool isPressed = false;
//   Timer? overlayTimer;

//   @override
//   void initState() {
//     super.initState();
//     OverlayController.instance.register(hideOverlay);
//   }

//   void hideOverlay() {
//     if (!mounted) return;
//     if (isPressed) {
//       setState(() => isPressed = false);
//       overlayTimer?.cancel();
//     }
//   }

//   @override
//   void dispose() {
//     overlayTimer?.cancel();
//     OverlayController.instance.unregister(hideOverlay);
//     super.dispose();
//   }

//   void _showOverlay() {
//     OverlayController.instance.hideAllExcept(hideOverlay);
//     setState(() => isPressed = true);
//     overlayTimer?.cancel();
//     overlayTimer = Timer(const Duration(seconds: 5), () {
//       if (!mounted) return;
//       setState(() => isPressed = false);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final BienModel bien = widget.bien;
//     final bool isLocation = bien.transactionType == 'location';
//     final String badgeLabel = isLocation ? "Location" : "Achat";
//     final Color badgeColor = isLocation ? Colors.orange : AppColors.primary;
//     final String priceText = isLocation
//         ? "${bien.price.toStringAsFixed(0)} F /mois"
//         : "${bien.price.toStringAsFixed(0)} F";
//     final String imageUrl = bien.images.isNotEmpty
//         ? bien.images.first
//         : "assets/images/chambre.jpg";

//     return GestureDetector(
//       onTapDown: (_) => _showOverlay(),
//       onTapCancel: () {
//         overlayTimer?.cancel();
//         setState(() => isPressed = false);
//       },
//       child: Stack(
//         children: [
//           // Carte principale
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
//                 // Image + badges
//                 Stack(
//                   children: [
//                     ClipRRect(
//                       borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//                       child: imageUrl.startsWith('http')
//                           ? Image.network(imageUrl, height: 130, width: 240, fit: BoxFit.cover)
//                           : Image.asset(imageUrl, height: 130, width: 240, fit: BoxFit.cover),
//                     ),
//                     Positioned(
//                       top: 10,
//                       left: 10,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//                         decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(30)),
//                         child: Text(
//                           badgeLabel,
//                           style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                     ),
//                     const Positioned(
//                       top: 8,
//                       right: 10,
//                       child: CircleAvatar(
//                         radius: 16,
//                         backgroundColor: Colors.white,
//                         child: Icon(Icons.favorite_border, color: AppColors.primary),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   child: Text(
//                     bien.title,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   child: Row(
//                     children: [
//                       const Icon(Icons.location_on, size: 14, color: AppColors.secondaryBlue),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: Text(
//                           bien.city ?? "Localisation inconnue",
//                           maxLines: 2,
//                           style: const TextStyle(fontSize: 12),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   child: Text(
//                     priceText,
//                     style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isLocation ? Colors.orange : Colors.red),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//               ],
//             ),
//           ),
//           // Overlay
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
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
//                   decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(30)),
//                   child: GestureDetector(
//                     onTap: () {
//                       Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(bien: bien)));
//                     },
//                     child: const Text(
//                       "Voir détail",
//                       style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textLight),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }









// class _VehiculeCardWidget extends StatelessWidget {
//   final BienModel bien;
//   const _VehiculeCardWidget({required this.bien});

//   @override
//   Widget build(BuildContext context) {
//     final String imageUrl = bien.images.isNotEmpty ? bien.images.first : "assets/images/vehicule.png";
//     final bool isLocation = bien.transactionType == 'location';
//     final String badgeLabel = isLocation ? "Location" : "Achat";
//     final Color badgeColor = isLocation ? Colors.orange : AppColors.primary;
//     final String priceText = isLocation
//         ? "${bien.price.toStringAsFixed(0)} F / jour"
//         : "${bien.price.toStringAsFixed(0)} F";
//     final Color priceColor = isLocation ? Colors.orange : Colors.red;
//     final IconData actionIcon = isLocation ? Icons.directions_car : Icons.shopping_cart;
//     final String actionText = isLocation ? "Louer" : "Acheter";

//     return ClipRRect(
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         width: 260,
//         margin: const EdgeInsets.only(right: 16),
//         color: Colors.white,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // IMAGE + TAG + FAVORI
//             Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//                   child: imageUrl.startsWith('http')
//                       ? Image.network(imageUrl, height: 100, width: 260, fit: BoxFit.cover)
//                       : Image.asset(imageUrl, height: 100, width: 260, fit: BoxFit.cover),
//                 ),
//                 Positioned(
//                   top: 10,
//                   left: 10,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//                     decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(30)),
//                     child: Text(
//                       badgeLabel,
//                       style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//                 const Positioned(
//                   top: 8,
//                   right: 10,
//                   child: CircleAvatar(
//                     radius: 16,
//                     backgroundColor: Colors.white,
//                     child: Icon(Icons.favorite_border, color: AppColors.primary),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 8),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Text(
//                 bien.title,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//             ),

//             const SizedBox(height: 4),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Row(
//                 children: const [
//                   Icon(Icons.star, color: Colors.amber, size: 18),
//                   Icon(Icons.star, color: Colors.amber, size: 18),
//                   Icon(Icons.star, color: Colors.amber, size: 18),
//                   Icon(Icons.star_half, color: Colors.amber, size: 18),
//                   Icon(Icons.star_border, color: Colors.amber, size: 18),
//                   SizedBox(width: 6),
//                   Text("(23)", style: TextStyle(fontSize: 12)),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 4),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Text(bien.city ?? "Localisation inconnue", style: const TextStyle(fontSize: 12)),
//             ),

//             const SizedBox(height: 6),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Text(priceText, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: priceColor)),
//             ),

//             const SizedBox(height: 8),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(12)),
//                       child: GestureDetector(
//                         onTap: () {
//                           Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(bien: bien)));
//                         },
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(actionIcon, color: Colors.white),
//                             const SizedBox(width: 6),
//                             Text(actionText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(12)),
//                     child: const Icon(Icons.remove_red_eye),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 10),
//           ],
//         ),
//       ),
//     );
//   }
// }
























































































































// // ---------------------------------------------------------
// // INTERNAL CARD WIDGETS
// // ---------------------------------------------------------
// class _ImmobilierCardWidget extends StatefulWidget {
//   final BienModel bien;
//   const _ImmobilierCardWidget({required this.bien});

//   @override
//   State<_ImmobilierCardWidget> createState() => _ImmobilierCardWidgetState();
// }

// class _ImmobilierCardWidgetState extends State<_ImmobilierCardWidget> {
//   bool isPressed = false;
//   Timer? overlayTimer;

//   @override
//   void initState() {
//     super.initState();
//     OverlayController.instance.register(hideOverlay);
//   }

//   void hideOverlay() {
//     if (!mounted) return;
//     if (isPressed) {
//       setState(() => isPressed = false);
//       overlayTimer?.cancel();
//     }
//   }

//   @override
//   void dispose() {
//     overlayTimer?.cancel();
//     OverlayController.instance.unregister(hideOverlay);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bien = widget.bien;
//     final isLocation = bien.transactionType == 'location';
//     final badgeLabel = isLocation ? "Location" : "Achat";
//     final badgeColor = isLocation ? Colors.orange : AppColors.primary;
//     final priceText = isLocation ? "${bien.price.toStringAsFixed(0)} F /mois" : "${bien.price.toStringAsFixed(0)} F";
//     final imageUrl = bien.images.isNotEmpty ? bien.images.first : "assets/images/chambre.jpg";

//     return GestureDetector(
//       onTapDown: (_) {
//         OverlayController.instance.hideAllExcept(hideOverlay);
//         setState(() => isPressed = true);
//         overlayTimer?.cancel();
//         overlayTimer = Timer(const Duration(seconds: 5), () {
//           if (!mounted) return;
//           setState(() => isPressed = false);
//         });
//       },
//       onTapCancel: () {
//         overlayTimer?.cancel();
//         setState(() => isPressed = false);
//       },
//       child: Stack(
//         children: [
//           Container(
//             width: 240,
//             margin: const EdgeInsets.only(right: 16),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(16),
//               color: Colors.white,
//               boxShadow: [BoxShadow(color: Colors.black12.withOpacity(.06), blurRadius: 8, spreadRadius: 2)],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Stack(
//                   children: [
//                     ClipRRect(
//                       borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
//                       child: imageUrl.startsWith('http') ? Image.network(imageUrl, height: 130, width: 240, fit: BoxFit.cover) : Image.asset(imageUrl, height: 130, width: 240, fit: BoxFit.cover),
//                     ),
//                     Positioned(
//                       top: 10,
//                       left: 10,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//                         decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(30)),
//                         child: Text(badgeLabel, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
//                       ),
//                     ),
//                     const Positioned(
//                       top: 8,
//                       right: 10,
//                       child: CircleAvatar(radius: 16, backgroundColor: Colors.white, child: Icon(Icons.favorite_border, color: AppColors.primary)),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   child: Text(bien.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
//                 ),
//                 const SizedBox(height: 4),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   child: Row(
//                     children: [
//                       const Icon(Icons.location_on, size: 14, color: AppColors.secondaryBlue),
//                       const SizedBox(width: 4),
//                       Expanded(child: Text(bien.city ?? "Localisation inconnue", maxLines: 2, style: const TextStyle(fontSize: 12))),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   child: Text(priceText, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isLocation ? Colors.orange : Colors.red)),
//                 ),
//                 const SizedBox(height: 8),
//               ],
//             ),
//           ),
//           AnimatedOpacity(
//             opacity: isPressed ? 1 : 0,
//             duration: const Duration(milliseconds: 150),
//             child: Container(
//               width: 240,
//               height: 260,
//               decoration: BoxDecoration(color: Colors.black.withOpacity(.45), borderRadius: BorderRadius.circular(16)),
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
//                   decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(30)),
//                   child: GestureDetector(
//                     onTap: () {
//                       Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(bien: bien)));
//                     },
//                     child: const Text("Voir détail", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textLight)),
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

// Pour les autres cartes (_MeubleCardWidget, _HotelCardWidget, _HebergementCardWidget, _VehiculeCardWidget)
// tu peux copier exactement le même code et adapter la hauteur si besoin





// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile/business/providers/auth_controller_provider.dart';
// import 'package:mobile/business/providers/bien_controller_provider.dart';
// import 'package:mobile/data/models/bien_model.dart';

// import 'package:mobile/presentation/components/hotel_card.dart';
// import 'package:mobile/presentation/components/hebergement_card.dart';
// import 'package:mobile/presentation/components/immobilier_card.dart';
// import 'package:mobile/presentation/components/vehicule_card.dart';
// import 'package:mobile/presentation/components/meuble_card.dart';

// import 'package:mobile/presentation/screens/notifications/notifications_screen.dart';
// import 'package:mobile/presentation/screens/search/search_screen.dart';
// import 'package:mobile/presentation/screens/account/account_screen.dart';
// import 'package:mobile/presentation/screens/bien/biens_screen.dart';

// import '../../theme/colors.dart';

// class HomeScreen extends ConsumerStatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   ConsumerState<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends ConsumerState<HomeScreen> {
//   int _selectedIndex = 0;

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final authState = ref.read(authControllerProvider);

//       if (authState.user != null) {
//         // Utilisateur connecté → récupérer tous ses biens
//         ref.read(bienControllerProvider.notifier).fetchAllUserBiens();
//       } else {
//         // Utilisateur non connecté → récupérer les biens publics
//         ref.read(bienControllerProvider.notifier).fetchAllBiensPublic();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: _buildAppBar(),
//       body: _buildBody(),
//       bottomNavigationBar: _buildBottomNav(),
//     );
//   }

//   // ---------------------------------------------------------
//   // APP BAR
//   // ---------------------------------------------------------
//   AppBar _buildAppBar() {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: Colors.white,
//       title: Row(
//         children: [
//           Image.asset("assets/images/africalocation_logo.png", height: 32),
//           const SizedBox(width: 8),
//           const Text(
//             "africaLocation",
//             style: TextStyle(
//               color: AppColors.textDark,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.notifications_none, color: AppColors.textDark),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const NotificationsScreen()),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   // ---------------------------------------------------------
//   // BOTTOM NAV
//   // ---------------------------------------------------------
//   BottomNavigationBar _buildBottomNav() {
//     return BottomNavigationBar(
//       currentIndex: _selectedIndex,
//       selectedItemColor: AppColors.primary,
//       unselectedItemColor: Colors.black87,
//       type: BottomNavigationBarType.fixed,
//       onTap: (i) => setState(() => _selectedIndex = i),
//       items: const [
//         BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
//         BottomNavigationBarItem(icon: Icon(Icons.search), label: "Recherche"),
//         BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Biens"),
//         BottomNavigationBarItem(icon: Icon(Icons.person), label: "Compte"),
//       ],
//     );
//   }

//   // ---------------------------------------------------------
//   // BODY NAVIGATION
//   // ---------------------------------------------------------
//   Widget _buildBody() {
//     switch (_selectedIndex) {
//       case 0:
//         return _buildHomeContent();
//       case 1:
//         return const SearchScreen();
//       case 2:
//         return const BiensScreen();
//       case 3:
//         return const AccountScreen();
//       default:
//         return _buildHomeContent();
//     }
//   }

//   // // ---------------------------------------------------------
//   // // HOME CONTENT (API DATA)
//   // // ---------------------------------------------------------
//   // Widget _buildHomeContent() {
//   //   final biensAsync = ref.watch(bienControllerProvider);

//   //   return biensAsync.when(
//   //     loading: () => const Center(child: CircularProgressIndicator()),
//   //     error: (e, _) => Center(child: Text("Erreur : $e")),
//   //     data: (biens) {
//   //       final List<BienModel> allBiens = biens.whereType<BienModel>().toList();

//   //       final List<BienModel> immobiliers = allBiens
//   //           .where((b) => b.category == 'immobilier')
//   //           .take(10)
//   //           .toList();

//   //       final List<BienModel> meubles = allBiens
//   //           .where((b) => b.category == 'meuble')
//   //           .take(10)
//   //           .toList();

//   //       final List<BienModel> vehicules = allBiens
//   //           .where((b) => b.category == 'vehicule')
//   //           .take(10)
//   //           .toList();

//   //       final List<BienModel> hotels = allBiens
//   //           .where((b) => b.category == 'hotel')
//   //           .take(10)
//   //           .toList();

//   //       final List<BienModel> hebergements = allBiens
//   //           .where((b) => b.category == 'hebergement')
//   //           .take(10)
//   //           .toList();

//   //       return SingleChildScrollView(
//   //         padding: const EdgeInsets.all(16),
//   //         child: Column(
//   //           children: [
//   //             _section(
//   //               "Nouvelles offres immobilières",
//   //               _buildImmobilierCarousel(immobiliers),
//   //             ),
//   //             _section(
//   //               "Nouveaux meubles disponibles",
//   //               _buildMeublesCarousel(meubles),
//   //             ),
//   //             _section(
//   //               "Chambres d'hôtels récentes",
//   //               _buildHotelsCarousel(hotels),
//   //             ),
//   //             _section(
//   //               "Nouveaux véhicules",
//   //               _buildVehiculeCarousel(vehicules),
//   //             ),
//   //             _section(
//   //               "Hébergements récents",
//   //               _buildHebergementsCarousel(hebergements),
//   //             ),
//   //           ],
//   //         ),
//   //       );
//   //     },
//   //   );
//   // }

//   // ---------------------------------------------------------
//   // HOME CONTENT (API DATA) avec pull-to-refresh
//   // ---------------------------------------------------------
//   Widget _buildHomeContent() {
//     final biensAsync = ref.watch(bienControllerProvider);

//     return biensAsync.when(
//       loading: () => const Center(child: CircularProgressIndicator()),
//       error: (e, _) => Center(child: Text("Erreur : $e")),
//       data: (biens) {
//         final List<BienModel> allBiens = biens.whereType<BienModel>().toList();
        
//         final List<BienModel> immobiliers = allBiens
//             .where((b) => b.category == 'immobilier')
//             .take(10)
//             .toList();

//         final List<BienModel> meubles = allBiens
//             .where((b) => b.category == 'meuble')
//             .take(10)
//             .toList();

//         final List<BienModel> vehicules = allBiens
//             .where((b) => b.category == 'vehicule')
//             .take(10)
//             .toList();

//         final List<BienModel> hotels = allBiens
//             .where((b) => b.category == 'hotel')
//             .take(10)
//             .toList();

//         final List<BienModel> hebergements = allBiens
//             .where((b) => b.category == 'hebergement')
//             .take(10)
//             .toList();

//         return RefreshIndicator(
//           onRefresh: () async {
//             final authState = ref.read(authControllerProvider);
//             if (authState.user != null) {
//               await ref
//                   .read(bienControllerProvider.notifier)
//                   .fetchAllUserBiens();
//             } else {
//               await ref
//                   .read(bienControllerProvider.notifier)
//                   .fetchAllBiensPublic();
//             }
//           },
//           child: SingleChildScrollView(
//             physics: const AlwaysScrollableScrollPhysics(),
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 _section(
//                   "Nouvelles offres immobilières",
//                   _buildImmobilierCarousel(immobiliers),
//                 ),
//                 _section(
//                   "Nouveaux meubles disponibles",
//                   _buildMeublesCarousel(meubles),
//                 ),
//                 _section(
//                   "Chambres d'hôtels récentes",
//                   _buildHotelsCarousel(hotels),
//                 ),
//                 _section(
//                   "Nouveaux véhicules",
//                   _buildVehiculeCarousel(vehicules),
//                 ),
//                 _section(
//                   "Hébergements récents",
//                   _buildHebergementsCarousel(hebergements),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _section(String title, Widget content) {
//     if (content is SizedBox) return const SizedBox.shrink();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 24),
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: AppColors.textDark,
//           ),
//         ),
//         const SizedBox(height: 10),
//         content,
//       ],
//     );
//   }

//   // ---------------------------------------------------------
//   // CAROUSELS
//   // ---------------------------------------------------------
//   Widget _buildImmobilierCarousel(List<BienModel> biens) {
//     if (biens.isEmpty) return const SizedBox();
//     return SizedBox(
//       height: 260,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: biens.length,
//         itemBuilder: (_, i) => ImmobilierCard(bien: biens[i]),
//       ),
//     );
//   }

//   Widget _buildMeublesCarousel(List<BienModel> meubles) {
//     if (meubles.isEmpty) return const SizedBox();
//     return SizedBox(
//       height: 300,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: meubles.length,
//         itemBuilder: (_, i) => MeubleCard(bien: meubles[i]),
//       ),
//     );
//   }

//   Widget _buildHotelsCarousel(List<BienModel> hotels) {
//     if (hotels.isEmpty) return const SizedBox();
//     return SizedBox(
//       height: 260,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: hotels.length,
//         itemBuilder: (_, i) => HotelCard(bien: hotels[i]),
//       ),
//     );
//   }

//   Widget _buildHebergementsCarousel(List<BienModel> hebergements) {
//     if (hebergements.isEmpty) return const SizedBox();
//     return SizedBox(
//       height: 260,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: hebergements.length,
//         itemBuilder: (_, i) => HebergementCard(bien: hebergements[i]),
//       ),
//     );
//   }

//   Widget _buildVehiculeCarousel(List<BienModel> vehicules) {
//     if (vehicules.isEmpty) return const SizedBox();
//     return SizedBox(
//       height: 260,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: vehicules.length,
//         itemBuilder: (_, i) => VehiculeCard(bien: vehicules[i]),
//       ),
//     );
//   }
// }






// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile/business/providers/bien_controller_provider.dart';
// import 'package:mobile/data/models/bien_model.dart';

// import 'package:mobile/presentation/components/hotel_card.dart';
// import 'package:mobile/presentation/components/hebergement_card.dart';
// import 'package:mobile/presentation/components/immobilier_card.dart';
// import 'package:mobile/presentation/components/vehicule_card.dart';
// import 'package:mobile/presentation/components/meuble_card.dart';

// import 'package:mobile/presentation/screens/notifications/notifications_screen.dart';
// import 'package:mobile/presentation/screens/search/search_screen.dart';
// import 'package:mobile/presentation/screens/account/account_screen.dart';
// import 'package:mobile/presentation/screens/bien/biens_screen.dart';

// import '../../theme/colors.dart';

// class HomeScreen extends ConsumerStatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   ConsumerState<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends ConsumerState<HomeScreen> {
//   int _selectedIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: _buildAppBar(),
//       body: _buildBody(),
//       bottomNavigationBar: _buildBottomNav(),
//     );
//   }

//   // ---------------------------------------------------------
//   // APP BAR
//   // ---------------------------------------------------------
//   AppBar _buildAppBar() {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: Colors.white,
//       title: Row(
//         children: [
//           Image.asset("assets/images/africalocation_logo.png", height: 32),
//           const SizedBox(width: 8),
//           const Text(
//             "africaLocation",
//             style: TextStyle(
//               color: AppColors.textDark,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.notifications_none, color: AppColors.textDark),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const NotificationsScreen()),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   // ---------------------------------------------------------
//   // BOTTOM NAV
//   // ---------------------------------------------------------
//   BottomNavigationBar _buildBottomNav() {
//     return BottomNavigationBar(
//       currentIndex: _selectedIndex,
//       selectedItemColor: AppColors.primary,
//       unselectedItemColor: Colors.black87,
//       type: BottomNavigationBarType.fixed,
//       onTap: (i) => setState(() => _selectedIndex = i),
//       items: const [
//         BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
//         BottomNavigationBarItem(icon: Icon(Icons.search), label: "Recherche"),
//         BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Biens"),
//         BottomNavigationBarItem(icon: Icon(Icons.person), label: "Compte"),
//       ],
//     );
//   }

//   // ---------------------------------------------------------
//   // BODY NAVIGATION
//   // ---------------------------------------------------------
//   Widget _buildBody() {
//     switch (_selectedIndex) {
//       case 0:
//         return _buildHomeContent();
//       case 1:
//         return const SearchScreen();
//       case 2:
//         return const BiensScreen();
//       case 3:
//         return const AccountScreen();
//       default:
//         return _buildHomeContent();
//     }
//   }

//   // ---------------------------------------------------------
//   // HOME CONTENT (100% API)
//   // ---------------------------------------------------------
//   Widget _buildHomeContent() {
//     final biensAsync = ref.watch(bienControllerProvider);

//     return biensAsync.when(
//       loading: () => const Center(child: CircularProgressIndicator()),
//       error: (e, _) => Center(child: Text("Erreur : $e")),
//       data: (biens) {
//         final List<BienModel> immobiliers = biens
//           .where((b) => (b as BienModel).category == 'immobilier')
//           .map((b) => b as BienModel)
//           .toList();

//         final List<BienModel> meubles = biens
//           .where((b) => (b as BienModel).category == 'meuble')
//           .map((b) => b as BienModel)
//           .toList();

//         final List<BienModel> vehicules = biens
//           .where((b) => (b as BienModel).category == 'vehicule')
//           .map((b) => b as BienModel)
//           .toList();

//         final List<BienModel> hotels = biens
//           .where((b) => (b as BienModel).category == 'hotel')
//           .map((b) => b as BienModel)
//           .toList();

//         final List<BienModel> hebergement = biens
//           .where((b) => (b as BienModel).category == 'hebergement')
//           .map((b) => b as BienModel)
//           .toList();

//         return SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               _section(
//                 "Nouvelles offres immobilières",
//                 _buildImmobilierCarousel(immobiliers),
//               ),
//               _section(
//                 "Nouveaux meubles disponibles",
//                 _buildMeublesCarousel(meubles),
//               ),
//               _section(
//                 "Chambres d'hôtels récentes",
//                 _buildHotelsCarousel(hotels),
//               ),
//               _section(
//                 "Nouveaux véhicules",
//                 _buildVehiculeCarousel(vehicules),
//               ),
//               _section(
//                 "Hébergements récents",
//                 _buildHebergementsCarousel(hebergement),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _section(String title, Widget content) {
//     if (content is SizedBox) return const SizedBox.shrink();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 24),
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: AppColors.textDark,
//           ),
//         ),
//         const SizedBox(height: 10),
//         content,
//       ],
//     );
//   }

//   // ---------------------------------------------------------
//   // CAROUSELS (API DATA)
//   // ---------------------------------------------------------
//   Widget _buildImmobilierCarousel(List<BienModel> biens) {
//     if (biens.isEmpty) return const SizedBox();
//     return SizedBox(
//       height: 260,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: biens.length,
//         itemBuilder: (_, i) {
//           final bien = biens[i];
//           return bien.transactionType == 'achat'
//               ? ImmobilierCard(bien: bien)
//               : ImmobilierCard(bien: bien);
//         },
//       ),
//     );
//   }

//   Widget _buildMeublesCarousel(List<BienModel> meubles) {
//     if (meubles.isEmpty) return const SizedBox();
//     return SizedBox(
//       height: 300,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: meubles.length,
//         itemBuilder: (_, i) => MeubleCard(bien: meubles[i]),
//       ),
//     );
//   }

//   Widget _buildHotelsCarousel(List<BienModel> hotels) {
//     if (hotels.isEmpty) return const SizedBox();
//     return SizedBox(
//       height: 260,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: hotels.length,
//         itemBuilder: (_, i) => HotelCard(bien: hotels[i]),
//       ),
//     );
//   }

//   Widget _buildHebergementsCarousel(List<BienModel> hebergements) {
//     if (hebergements.isEmpty) return const SizedBox();
//     return SizedBox(
//       height: 260,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: hebergements.length,
//         itemBuilder: (_, i) => HebergementCard(bien: hebergements[i]),
//       ),
//     );
//   }

//   Widget _buildVehiculeCarousel(List<BienModel> vehicules) {
//     if (vehicules.isEmpty) return const SizedBox();
//     return SizedBox(
//       height: 260,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: vehicules.length,
//         itemBuilder: (_, i) {
//           final bien = vehicules[i];
//           return bien.transactionType == 'achat'
//               ? VehiculeCard(bien: bien)
//               : VehiculeCard(bien: bien);
//         },
//       ),
//     );
//   }
// }



































// import 'package:flutter/material.dart';
// import 'package:mobile/presentation/components/hotel_card.dart';
// import 'package:mobile/presentation/components/hebergement_card.dart';
// import 'package:mobile/presentation/components/immobilier_card.dart';
// import 'package:mobile/presentation/components/vehicule_card.dart';
// import 'package:mobile/presentation/screens/Immobilier/immobilier_screen.dart';
// import 'package:mobile/presentation/screens/hotels/hotels_screen.dart';
// import 'package:mobile/presentation/screens/meubles/meubles_screen.dart';
// import 'package:mobile/presentation/screens/notifications/notifications_screen.dart';
// import 'package:mobile/presentation/screens/vehicules/vehicules_screen.dart';
// import '../../theme/colors.dart';
// import '../../components/meuble_card.dart';
// import '../account/account_screen.dart';
// import '../search/search_screen.dart';
// import '../bien/biens_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedIndex = 0;
//   final PageController _pageController = PageController();
//   int _currentPage = 0;

//   final List<Map<String, dynamic>> immobilierData = [
//   {
//     "mode": "Location",
//     "image": "assets/images/chambre.jpg",
//     "titre": "Appartement Moderne 2 Chambres",
//     "lieu": "Abomey-Calavi, Godomey",
//     "prix": "120,000 F / mois",
//     "details": "2 chambres, salon, douche interne",
//   },
//   {
//     "mode": "Achat",
//     "image": "assets/images/chambre.jpg",
//     "titre": "Parcelle 500m² Lotissement",
//     "lieu": "Calavi Togoudo",
//     "prix": "6,500,000 F",
//     "details": "Titre foncier, prêt pour construction",
//   },
//   {
//     "mode": "Location",
//     "image": "assets/images/chambre.jpg",
//     "titre": "Studio Meublé",
//     "lieu": "Cotonou Fidjrossè",
//     "prix": "80,000 F / mois",
//     "details": "Meublé • Wifi • Climatisation",
//   },
//   {
//     "mode": "Achat",
//     "image": "assets/images/chambre.jpg",
//     "titre": "Villa Haut Standing",
//     "lieu": "Calavi Akassato",
//     "prix": "38,000,000 F",
//     "details": "3 chambres • Jardin • Garage",
//   },
// ];

// final List<Map<String, dynamic>> vehiculeData = [
//   {
//     "mode": "Achat",
//     "image": "assets/images/vehicule.png",
//     "titre": "Toyota Corolla 2015",
//     "lieu": "Cotonou, Ste Rita",
//     "prix": "3,200,000 F",
//     "details": "Essence • Automatique • 98,000 km",
//   },
//   {
//     "mode": "Location",
//     "image": "assets/images/voiture.png",
//     "titre": "Hyundai Tucson 2020",
//     "lieu": "Abomey-Calavi",
//     "prix": "35,000 F / jour",
//     "details": "Diesel • Automatique • Climatisation",
//   },
//   {
//     "mode": "Achat",
//     "image": "assets/images/vehicule.png",
//     "titre": "Kia Rio 2017",
//     "lieu": "Cotonou Vèdoko",
//     "prix": "2,500,000 F",
//     "details": "Essence • Boite manuelle • Très propre",
//   },
//   {
//     "mode": "Location",
//     "image": "assets/images/voiture.png",
//     "titre": "Toyota Hilux 2022",
//     "lieu": "Calavi Tankpè",
//     "prix": "55,000 F / jour",
//     "details": "4x4 • Diesel • Parfait pour terrain",
//   },
// ];


//   final List<Map<String, String>> rubriqueCarousel = [
//     {
//       "title": "Immobilier",
//       "description": "Trouvez maisons, bureaux, studios...",
//       "image": "assets/images/rubriques/onboarding_immobilier.png",
//     },
//     {
//       "title": "Meubles",
//       "description": "Chaises, canapés, armoires et plus",
//       "image": "assets/images/rubriques/onboarding_meubles.png",
//     },
//     {
//       "title": "Véhicules",
//       "description": "Voitures, motos, camions disponibles",
//       "image": "assets/images/rubriques/onboarding_voitures.png",
//     },
//     {
//       "title": "Hôtels & Hébergement",
//       "description": "Chambres, résidences, appartements",
//       "image": "assets/images/rubriques/onboarding_hotels.png",
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _startAutoScroll();
//   }


//   void _startAutoScroll() {
//     Future.delayed(const Duration(seconds: 5), () {
//       if (!mounted) return;

//       _currentPage = (_currentPage + 1) % rubriqueCarousel.length;
//       _pageController.animateToPage(
//         _currentPage,
//         duration: const Duration(milliseconds: 600),
//         curve: Curves.easeInOut,
//       );

//       _startAutoScroll();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         title: Row(
//           children: [
//             Image.asset("assets/images/africalocation_logo.png", height: 32),
//             const SizedBox(width: 8),
//             const Text(
//               "africaLocation",
//               style: TextStyle(
//                 color: AppColors.textDark,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),

//         actions: [
//           IconButton(
//             icon: const Icon(
//               Icons.notifications_none,
//               color: AppColors.textDark,
//             ),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const NotificationsScreen()),
//               );
//             },

//           ),
//           const SizedBox(width: 8),
//         ],
//       ),

//       body: _buildBody(),

//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         selectedItemColor: AppColors.primary,
//         unselectedItemColor: Colors.black87,
//         type: BottomNavigationBarType.fixed,
//         onTap: (i) => setState(() => _selectedIndex = i),
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
//           BottomNavigationBarItem(icon: Icon(Icons.search), label: "Recherche"),
//           BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Bien"),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: "Compte"),
//         ],
//       ),
//     );
//   }

//   // ---------------------------------------------------------
//   // NAVIGATION BODY
//   // ---------------------------------------------------------
//   Widget _buildBody() {
//     switch (_selectedIndex) {
//       case 0:
//         return _buildHomeContent(); // Home
//       case 1:
//         return const SearchScreen();
//       case 2:
//         return const BiensScreen();
//       case 3:
//         return const AccountScreen();
//       default:
//         return _buildHomeContent();
//     }
//   }

//   // ---------------------------------------------------------
//   // HOME CONTENT
//   // ---------------------------------------------------------
//   Widget _buildHomeContent() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ------------------- CAROUSEL RUBRIQUES --------------------
//           SizedBox(
//             height: 220,
//             child: PageView.builder(
//               controller: _pageController,
//               itemCount: rubriqueCarousel.length,
//               itemBuilder: (_, index) {
//                 final item = rubriqueCarousel[index];

//                 return Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 6),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(16),
//                     image: DecorationImage(
//                       image: AssetImage(item["image"]!),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(16),
//                       gradient: LinearGradient(
//                         colors: [
//                           Colors.black.withOpacity(0.5),
//                           Colors.black.withOpacity(0.1),
//                         ],
//                         begin: Alignment.bottomCenter,
//                         end: Alignment.topCenter,
//                       ),
//                     ),
//                     padding: const EdgeInsets.all(16),
//                     child: Align(
//                       alignment: Alignment.bottomLeft,
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             item["title"]!,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 6),
//                           Text(
//                             item["description"]!,
//                             style: const TextStyle(
//                               color: Colors.white70,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),

//           const SizedBox(height: 24),

//           // ---------------- IMMOBILIER ----------------
//           _buildSectionTitle("Nouvelles offres immobilières"),
//           _buildImmobilierCarousel(vehiculeData),

//           const SizedBox(height: 24),

//           // ---------------- MEUBLES ----------------
//           _buildSectionTitle("Nouveaux meubles disponibles"),
//           _buildMeublesCarousel(),

//           const SizedBox(height: 24),

//           // ---------------- HOTELS ----------------
//           _buildSectionTitle("Vos chambres d'hôtels récentes"),
//           _buildHotelsCarousel(),

//           const SizedBox(height: 24),

//           // ---------------- Vehicules ----------------
//           _buildSectionTitle("Nouvelles véhicules récentes"),
//           _buildVehiculeCarousel(immobilierData),

//           const SizedBox(height: 24),

//                     // ---------------- HOTELS ----------------
//           _buildSectionTitle("Vos hébergements récentes"),
//           _buildHebergementsCarousel(),

//           const SizedBox(height: 24),
//         ],
//       ),
//     );
//   }

//   // ---------------------------------------------------------
//   // TITRE CENTRÉ
//   // ---------------------------------------------------------
//   Widget _buildSectionTitle(String title) {
//     return Center(
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//           color: AppColors.textDark,
//         ),
//       ),
//     );
//   }

//   Widget _buildImmobilierCarousel(List<Map<String, dynamic>> biens) {
//     return SizedBox(
//       height: 260,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: biens.length,
//         padding: const EdgeInsets.only(top: 10),
//         itemBuilder: (_, i) {
//           final item = biens[i];

//           if (item["mode"] == "Achat") {
//             return const ImmobilierCardSale();
//           } else {
//             return const ImmobilierCard();
//           }
//         },
//       ),
//     );
//   }


//   Widget _buildMeublesCarousel() {
//     return SizedBox(
//       height: 300,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: 4,
//         padding: const EdgeInsets.only(top: 10),
//         itemBuilder: (_, i) => const MeubleCard(),
//       ),
//     );
//   }

//   Widget _buildHotelsCarousel() {
//     return SizedBox(
//       height: 260,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: 4,
//         padding: const EdgeInsets.only(top: 10),
//         itemBuilder: (_, i) => const HotelCard(),
//       ),
//     );
//   }

//     Widget _buildHebergementsCarousel() {
//     return SizedBox(
//       height: 260,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: 4,
//         padding: const EdgeInsets.only(top: 10),
//         itemBuilder: (_, i) => const HebergementCard(),
//       ),
//     );
//   }

//   Widget _buildVehiculeCarousel(List<Map<String, dynamic>> vehicules) {
//     return SizedBox(
//       height: 260,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: vehicules.length,
//         padding: const EdgeInsets.only(top: 10),
//         itemBuilder: (_, i) {
//           final item = vehicules[i];

//           if (item["mode"] == "Achat") {
//             return const VehiculeCardSale();
//           } else {
//             return const VehiculeCardRent();
//           }
//         },
//       ),
//     );
//   }

// }





