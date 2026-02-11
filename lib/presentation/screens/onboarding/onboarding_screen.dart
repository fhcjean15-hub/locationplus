import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/data/providers/onboarding_provider.dart';

import '../../../business/controllers/onboarding_controller.dart';
import '../../../data/providers/auth_providers.dart'; // si auth providers utiles

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0;
  Timer? _timer;

  final List<Map<String, String>> slides = [
    {
      "title": "Immobilier",
      "subtitle": "Louez ou proposez des maisons et appartements.",
      "image": "assets/images/onboarding_immobilier.png",
    },
    {
      "title": "Voitures",
      "subtitle": "Trouvez ou louez des véhicules à tout moment.",
      "image": "assets/images/onboarding_voitures.png",
    },
    {
      "title": "Meublés",
      "subtitle": "Des logements meublés prêts à habiter.",
      "image": "assets/images/onboarding_meubles.png",
    },
    {
      "title": "Hôtels",
      "subtitle": "Réservez des chambres rapidement et facilement.",
      "image": "assets/images/onboarding_hotels.png",
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = currentIndex + 1;

        if (nextPage == slides.length) {
          nextPage = 0;
        }

        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  /// ⏹ Marque la fin de l'onboarding + redirection
  Future<void> _finishOnboardingAndGo(String route) async {
    final onboarding = ref.read(onboardingProvider.notifier);
    await onboarding.completeOnboarding();

    if (!mounted) return;
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [

            // SLIDES
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (index) {
                  setState(() => currentIndex = index);
                  ref
                      .read(onboardingProvider.notifier)
                      .updatePage(index);
                },
                itemBuilder: (context, index) {
                  final item = slides[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(item["image"]!, height: 280),
                        const SizedBox(height: 30),
                        Text(
                          item["title"]!,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item["subtitle"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),

            // DOTS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  height: 8,
                  width: currentIndex == index ? 22 : 8,
                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? Colors.blueAccent
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // BUTTON: Créer un compte
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _finishOnboardingAndGo("/register"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Créer un compte",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // BUTTON: Se connecter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _finishOnboardingAndGo("/login"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.blueAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Se connecter",
                    style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // BUTTON: Continuer en invité
            TextButton(
              onPressed: () => _finishOnboardingAndGo("/home"),
              child: const Text(
                "Continuer sans compte",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}




// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({super.key});

//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends State<OnboardingScreen> {
//   final PageController _pageController = PageController();
//   int currentIndex = 0;
//   Timer? _timer;

//   final List<Map<String, String>> slides = [
//     {
//       "title": "Immobilier",
//       "subtitle": "Louez ou proposez des maisons et appartements.",
//       "image": "assets/images/onboarding_immobilier.png",
//     },
//     {
//       "title": "Voitures",
//       "subtitle": "Trouvez ou louez des véhicules à tout moment.",
//       "image": "assets/images/onboarding_voitures.png",
//     },
//     {
//       "title": "Meublés",
//       "subtitle": "Des logements meublés prêts à habiter.",
//       "image": "assets/images/onboarding_meubles.png",
//     },
//     {
//       "title": "Hôtels",
//       "subtitle": "Réservez des chambres rapidement et facilement.",
//       "image": "assets/images/onboarding_hotels.png",
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _startAutoScroll();
//   }

//   void _startAutoScroll() {
//     _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
//       if (_pageController.hasClients) {
//         int nextPage = currentIndex + 1;

//         if (nextPage == slides.length) {
//           nextPage = 0; // retour à la première slide
//         }

//         _pageController.animateToPage(
//           nextPage,
//           duration: const Duration(milliseconds: 400),
//           curve: Curves.easeInOut,
//         );
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // SLIDES
//             Expanded(
//               child: PageView.builder(
//                 controller: _pageController,
//                 itemCount: slides.length,
//                 onPageChanged: (index) {
//                   setState(() => currentIndex = index);
//                 },
//                 itemBuilder: (context, index) {
//                   final item = slides[index];

//                   return Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Image.asset(
//                           item["image"]!,
//                           height: 280,
//                         ),
//                         const SizedBox(height: 30),
//                         Text(
//                           item["title"]!,
//                           style: const TextStyle(
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         Text(
//                           item["subtitle"]!,
//                           textAlign: TextAlign.center,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             color: Colors.black54,
//                           ),
//                         )
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // DOTS INDICATORS
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: List.generate(
//                 slides.length,
//                 (index) => AnimatedContainer(
//                   duration: const Duration(milliseconds: 300),
//                   margin: const EdgeInsets.symmetric(horizontal: 5),
//                   height: 8,
//                   width: currentIndex == index ? 22 : 8,
//                   decoration: BoxDecoration(
//                     color: currentIndex == index
//                         ? Colors.blueAccent
//                         : Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 30),

//             // BUTTON: Créer un compte
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () => context.go("/register"),
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     backgroundColor: Colors.blueAccent,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text(
//                     "Créer un compte",
//                     style: TextStyle(fontSize: 16, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 12),

//             // BUTTON: Se connecter
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton(
//                   onPressed: () => context.go("/login"),
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     side: const BorderSide(color: Colors.blueAccent),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text(
//                     "Se connecter",
//                     style: TextStyle(fontSize: 16, color: Colors.blueAccent),
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 12),

//             // BUTTON: Continuer en invité
//             TextButton(
//               onPressed: () => context.push("/home"),
//               child: const Text(
//                 "Continuer sans compte",
//                 style: TextStyle(
//                   fontSize: 15,
//                   color: Colors.black54,
//                   decoration: TextDecoration.underline,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }









































// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({super.key});

//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends State<OnboardingScreen> {
//   final PageController _pageController = PageController();
//   int currentIndex = 0;

//   final List<Map<String, String>> slides = [
//     {
//       "title": "Immobilier",
//       "subtitle": "Louez ou proposez des maisons et appartements.",
//       "image": "assets/images/onboarding_immobilier.png",
//     },
//     {
//       "title": "Voitures",
//       "subtitle": "Trouvez ou louez des véhicules à tout moment.",
//       "image": "assets/images/onboarding_voitures.png",
//     },
//     {
//       "title": "Meublés",
//       "subtitle": "Des logements meublés prêts à habiter.",
//       "image": "assets/images/onboarding_meubles.png",
//     },
//     {
//       "title": "Hôtels",
//       "subtitle": "Réservez des chambres rapidement et facilement.",
//       "image": "assets/images/onboarding_hotels.png",
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // SLIDES
//             Expanded(
//               child: PageView.builder(
//                 controller: _pageController,
//                 itemCount: slides.length,
//                 onPageChanged: (index) {
//                   setState(() => currentIndex = index);
//                 },
//                 itemBuilder: (context, index) {
//                   final item = slides[index];

//                   return Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Image.asset(
//                           item["image"]!,
//                           height: 280,
//                         ),
//                         const SizedBox(height: 30),
//                         Text(
//                           item["title"]!,
//                           style: const TextStyle(
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         Text(
//                           item["subtitle"]!,
//                           textAlign: TextAlign.center,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             color: Colors.black54,
//                           ),
//                         )
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // DOTS INDICATORS
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: List.generate(
//                 slides.length,
//                 (index) => AnimatedContainer(
//                   duration: const Duration(milliseconds: 300),
//                   margin: const EdgeInsets.symmetric(horizontal: 5),
//                   height: 8,
//                   width: currentIndex == index ? 22 : 8,
//                   decoration: BoxDecoration(
//                     color: currentIndex == index
//                         ? Colors.blueAccent
//                         : Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 30),

//             // BUTTON: Créer un compte
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () => context.go("/register"),
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     backgroundColor: Colors.blueAccent,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text(
//                     "Créer un compte",
//                     style: TextStyle(fontSize: 16, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 12),

//             // BUTTON: Se connecter
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton(
//                   onPressed: () => context.go("/login"),
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     side: const BorderSide(color: Colors.blueAccent),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text(
//                     "Se connecter",
//                     style: TextStyle(fontSize: 16, color: Colors.blueAccent),
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 12),

//             // BUTTON: Continuer en invité
//             TextButton(
//               onPressed: () => context.go("/home"),
//               child: const Text(
//                 "Continuer en mode invité",
//                 style: TextStyle(
//                   fontSize: 15,
//                   color: Colors.black54,
//                   decoration: TextDecoration.underline,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }
