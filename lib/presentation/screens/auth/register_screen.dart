import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/business/providers/register_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // Form controllers
  final ctrl1 = TextEditingController();
  final ctrl2 = TextEditingController();
  final ctrl3 = TextEditingController();
  final ctrl4 = TextEditingController();
  final ctrl5 = TextEditingController();
  final ctrl6 = TextEditingController();
  final Map<TextEditingController, bool> _obscureMap = {};


  String? selectedType;
  dynamic selectedCategory;

  int step = 0;

  @override
  void dispose() {
    ctrl1.dispose();
    ctrl2.dispose();
    ctrl3.dispose();
    ctrl4.dispose();
    ctrl5.dispose();
    ctrl6.dispose();
    super.dispose();
  }

  // -----------------------
  // VALIDATORS (regex)
  // -----------------------
  bool _isValidName(String v) {
    final s = v.trim();
    return s.length >= 3 && RegExp(r"^[\p{L}\s\.'-]+$", unicode: true).hasMatch(s);
  }

  bool _isValidEmail(String v) {
    return RegExp(r"^[^@]+@[^@]+\.[^@]+$").hasMatch(v.trim());
  }

  // bool _isValidPhone(String v) {
  //   return RegExp(r'^\d{8,}$').hasMatch(v.trim());
  // }

  bool _isValidPhone(String v) {
    // Commence par + puis indicatif (1 à 3 chiffres), suivi de 8 à 12 chiffres
    return RegExp(r'^\+\d{1,3}\d{8,12}$').hasMatch(v.trim());
  }


  bool _isStrongPassword(String v) {
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$').hasMatch(v);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerControllerProvider);
    final isLoading = registerState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: isLoading
              ? null
              : () {
                  if (step > 0) {
                    setState(() {
                      step--;
                      if (step < 2) selectedCategory = null;
                    });
                  } else {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go("/onboarding");
                    }
                  }
                },
        ),
        title: const Text("Créer un compte", style: TextStyle(color: Colors.black87)),
        centerTitle: true,
      ),

      body: AbsorbPointer(
        absorbing: isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                Image.asset(
                  "assets/images/onboarding_immobilier.png",
                  height: 180,
                ),

                const SizedBox(height: 25),
                const Text("Inscription",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                const Text(
                  "Rejoignez-nous et commencez vos locations facilement.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),

                const SizedBox(height: 30),

                // --- CHOIX TYPE ---
                if (step == 0 && !isLoading) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ctrl1.clear();
                        ctrl2.clear();
                        ctrl3.clear();
                        ctrl5.clear();
                        ctrl6.clear();
                        selectedCategory = null;
                        selectedType = "agent";
                        setState(() => step = 1);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Agent indépendant",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ctrl1.clear();
                        ctrl2.clear();
                        ctrl3.clear();
                        ctrl5.clear();
                        ctrl6.clear();
                        selectedCategory = null;
                        selectedType = "agence";
                        setState(() => step = 1);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Agence", style: TextStyle(color: Colors.white)),
                    ),
                  ),

                  const SizedBox(height: 25),
                ],

                if (step > 0) ..._buildFormSteps(isLoading),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // STEPS
  // ---------------------------------------------------------
  List<Widget> _buildFormSteps(bool isLoading) {
    return [
      Text(
        "${selectedType == "agent" ? "Agent indépendant" : "Agence"} — Étape $step/3",
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),

      const SizedBox(height: 20),

      if (step == 1) ..._step1Fields(),
      if (step == 2) ..._step2Fields(),
      if (step == 3) ..._step3Fields(),

      const SizedBox(height: 25),

      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : _onNext,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(step < 3 ? "Suivant" : "Terminer",
                  style: const TextStyle(color: Colors.white)),
        ),
      ),

      TextButton(
        onPressed: isLoading ? null : () => context.go("/login"),
        child: const Text(
          "Déjà un compte ? Se connecter",
          style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
        ),
      ),
    ];
  }

  // ---------------------------------------------------------
  // NEXT BUTTON HANDLER (avec validations)
  // ---------------------------------------------------------
  Future<void> _onNext() async {
    final controller = ref.read(registerControllerProvider.notifier);

    // step 1 validation
    if (step == 1) {
      final name = ctrl1.text.trim();
      final email = ctrl2.text.trim();

      if (!_isValidName(name)) {
        _showError("Nom invalide (au moins 3 caractères, lettres seulement).");
        return;
      }
      if (!_isValidEmail(email)) {
        _showError("Email invalide.");
        return;
      }

      setState(() => step = 2);

      if (selectedType != null) {
        await controller.loadCategories(selectedType!);
      }
      return;
    }

    // step 2 validation
    if (step == 2) {
      if (!_isValidPhone(ctrl3.text.trim())) {
        _showError("Numéro invalide. Utilisez le format international, par ex. +229XXXXXXXX.");
        return;
      }

      if (selectedCategory == null) {
        _showError("Veuillez choisir une catégorie.");
        return;
      }

      setState(() => step = 3);
      return;
    }

    // step 3 validation
    if (step == 3) {
      final pass = ctrl5.text;
      final confirm = ctrl6.text;

      if (!_isStrongPassword(pass)) {
        _showError("Mot de passe invalide. 8+ caractères, majuscule, minuscule et chiffre requis.");
        return;
      }
      if (pass != confirm) {
        _showError("Les mots de passe ne correspondent pas.");
        return;
      }

      final payload = {
        "name": ctrl1.text.trim(),
        "email": ctrl2.text.trim(),
        "numero": ctrl3.text.trim(),
        "categorie_id": selectedCategory?["id"],
        "password": pass,
        "password_confirmation": confirm,
      };

      bool ok = false;

      if (selectedType == "agent") {
        ok = await controller.registerAgent(payload);
      } else {
        ok = await controller.registerAgence(payload);
      }

      if (ok) {
        context.go("/home");
      } else {
        final state = ref.read(registerControllerProvider);
        if (state is AsyncError) {
          _showError(state.error.toString());
        } else {
          _showError("Échec de l'inscription.");
        }
      }
    }
  }

  // ---------------------------------------------------------
  // ÉTAPE 1
  // ---------------------------------------------------------
  List<Widget> _step1Fields() {
    if (selectedType == "agent") {
      return [
        _input(ctrl1, "Nom & Prénoms"),
        const SizedBox(height: 15),
        _input(ctrl2, "Email"),
      ];
    }

    return [
      _input(ctrl1, "Nom de l’entreprise"),
      const SizedBox(height: 15),
      _input(ctrl2, "Email de l’entreprise"),
    ];
  }

  // ---------------------------------------------------------
  // ÉTAPE 2
  // ---------------------------------------------------------
  List<Widget> _step2Fields() {
    final categoriesAsync =
        ref.watch(registerCategoriesProvider(selectedType ?? "agent"));

    return [
      _input(
        ctrl3,
        selectedType == "agent" ? "Numéro fonctionnel" : "Numéro de l’entreprise",
      ),
      const SizedBox(height: 15),

      categoriesAsync.when(
        data: (list) {
          return DropdownButtonFormField<dynamic>(
            value: selectedCategory,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            hint: Text(
              selectedType == "agent" ? "Type d’agent" : "Type d’agence",
            ),
            items: list.map<DropdownMenuItem>((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item["name"]),
              );
            }).toList(),
            onChanged: (v) => setState(() => selectedCategory = v),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Text("Erreur : $e"),
      ),
    ];
  }

  // ---------------------------------------------------------
  // ÉTAPE 3
  // ---------------------------------------------------------
  List<Widget> _step3Fields() {
    return [
      _input(ctrl5, "Mot de passe", isPassword: true),
      const SizedBox(height: 15),
      _input(ctrl6, "Confirmer le mot de passe", isPassword: true),
    ];
  }

  // ---------------------------------------------------------
  // INPUT
  // ---------------------------------------------------------
  // Widget _input(TextEditingController c, String label,
  //     {bool isPassword = false}) {
  //   return TextField(
  //     controller: c,
  //     obscureText: isPassword,
  //     decoration: InputDecoration(
  //       labelText: label,
  //       labelStyle: const TextStyle(color: Colors.black),
  //       filled: true,
  //       fillColor: Colors.grey.shade100,
  //       border: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(12),
  //         borderSide: BorderSide.none,
  //       ),
  //     ),
  //   );
  // }

  Widget _input(TextEditingController c, String label, {bool isPassword = false}) {
  // Initialisation de l’état obscure par champ
  _obscureMap.putIfAbsent(c, () => isPassword);

  return TextField(
    controller: c,
    obscureText: isPassword ? _obscureMap[c]! : false,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),

      // 👁️ Ajout de l’icône visible uniquement sur les champs mot de passe
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                _obscureMap[c]! ? Icons.visibility_off : Icons.visibility,
                color: Colors.black54,
              ),
              onPressed: () {
                setState(() {
                  _obscureMap[c] = !_obscureMap[c]!;
                });
              },
            )
          : null,
    ),
  );
}

}






















// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:mobile/business/providers/register_provider.dart';

// class RegisterScreen extends ConsumerStatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends ConsumerState<RegisterScreen> {
//   // Form controllers
//   final ctrl1 = TextEditingController();
//   final ctrl2 = TextEditingController();
//   final ctrl3 = TextEditingController();
//   final ctrl4 = TextEditingController();
//   final ctrl5 = TextEditingController();
//   final ctrl6 = TextEditingController();

//   String? selectedType;
//   dynamic selectedCategory;

//   int step = 0;

//   @override
//   void dispose() {
//     ctrl1.dispose();
//     ctrl2.dispose();
//     ctrl3.dispose();
//     ctrl4.dispose();
//     ctrl5.dispose();
//     ctrl6.dispose();
//     super.dispose();
//   }

//   // -----------------------
//   // VALIDATORS (regex)
//   // -----------------------
//   bool _isValidName(String v) {
//     final s = v.trim();
//     return s.length >= 3 && RegExp(r"^[\p{L}\s\.'-]+$", unicode: true).hasMatch(s);
//   }

//   bool _isValidEmail(String v) {
//     final s = v.trim();
//     return RegExp(r"^[^@]+@[^@]+\.[^@]+$").hasMatch(s);
//   }

//   bool _isValidPhone(String v) {
//     final s = v.trim();
//     return RegExp(r'^\d{8,}$').hasMatch(s); // min 8 chiffres
//   }

//   bool _isStrongPassword(String v) {
//     // >=8, au moins une minuscule, une majuscule et un chiffre
//     return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$').hasMatch(v);
//   }

//   void _showError(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final registerState = ref.watch(registerControllerProvider);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       resizeToAvoidBottomInset: true,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () {
//             if (step > 0) {
//               setState(() {
//                 step--;
//                 // clear selectedCategory when going back to step 1
//                 if (step < 2) selectedCategory = null;
//               });
//             } else {
//               if (context.canPop()) {
//                 context.pop();
//               } else {
//                 context.go("/onboarding");
//               }
//             }
//           },
//         ),
//         title: const Text("Créer un compte", style: TextStyle(color: Colors.black87)),
//         centerTitle: true,
//       ),

//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 20),

//               Image.asset(
//                 "assets/images/onboarding_immobilier.png",
//                 height: 180,
//               ),

//               const SizedBox(height: 25),
//               const Text("Inscription",
//                   style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 10),

//               const Text(
//                 "Rejoignez-nous et commencez vos locations facilement.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 15, color: Colors.black54),
//               ),

//               const SizedBox(height: 30),

//               // --- CHOIX TYPE ---
//               if (step == 0) ...[
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       /// 🔥 RESET COMPLET
//                       ctrl1.clear();
//                       ctrl2.clear();
//                       ctrl3.clear();
//                       ctrl5.clear();
//                       ctrl6.clear();
//                       selectedCategory = null;
//                       step = 0;
//                       selectedType = "agent";
//                       setState(() => step = 1);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       backgroundColor: Colors.blueAccent,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text("Agent indépendant", style: TextStyle(color: Colors.white)),
//                   ),
//                 ),

//                 const SizedBox(height: 15),

//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       /// 🔥 RESET COMPLET
//                       ctrl1.clear();
//                       ctrl2.clear();
//                       ctrl3.clear();
//                       ctrl5.clear();
//                       ctrl6.clear();
//                       selectedCategory = null;
//                       step = 0;
//                       selectedType = "agence";
//                       setState(() => step = 1);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       backgroundColor: Colors.black87,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text("Agence", style: TextStyle(color: Colors.white)),
//                   ),
//                 ),

//                 const SizedBox(height: 25),
//               ],

//               if (step > 0) ..._buildFormSteps(),

//               if (registerState.isLoading)
//                 const Padding(
//                   padding: EdgeInsets.all(12),
//                   child: CircularProgressIndicator(),
//                 ),

//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ---------------------------------------------------------
//   // STEPS
//   // ---------------------------------------------------------
//   List<Widget> _buildFormSteps() {
//     return [
//       Text(
//         "${selectedType == "agent" ? "Agent indépendant" : "Agence"} — Étape $step/3",
//         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       ),

//       const SizedBox(height: 20),

//       if (step == 1) ..._step1Fields(),
//       if (step == 2) ..._step2Fields(),
//       if (step == 3) ..._step3Fields(),

//       const SizedBox(height: 25),

//       SizedBox(
//         width: double.infinity,
//         child: ElevatedButton(
//           onPressed: _onNext,
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(vertical: 14),
//             backgroundColor: Colors.blueAccent,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           child: Text(step < 3 ? "Suivant" : "Terminer",
//               style: const TextStyle(color: Colors.white)),
//         ),
//       ),

//       TextButton(
//         onPressed: () => context.go("/login"),
//         child: const Text(
//           "Déjà un compte ? Se connecter",
//           style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
//         ),
//       ),
//     ];
//   }

//   // ---------------------------------------------------------
//   // NEXT BUTTON HANDLER (avec validations)
//   // ---------------------------------------------------------
//   Future<void> _onNext() async {
//     // step 1 validation (name + email)
//     if (step == 1) {
//       final name = ctrl1.text.trim();
//       final email = ctrl2.text.trim();

//       if (!_isValidName(name)) {
//         _showError("Nom invalide (au moins 3 caractères, lettres seulement).");
//         return;
//       }
//       if (!_isValidEmail(email)) {
//         _showError("Email invalide.");
//         return;
//       }

//       // ok → avancer à l'étape 2
//       setState(() => step = 2);

//       // CHARGER CATEGORIES À L'AFFICHAGE DE L'ÉTAPE 2 (si nécessaire)
//       if (selectedType != null) {
//         await ref.read(registerControllerProvider.notifier).loadCategories(selectedType!);
//       }
//       return;
//     }

//     // step 2 validation (numero + category)
//     if (step == 2) {
//       final numero = ctrl3.text.trim();

//       if (!_isValidPhone(numero)) {
//         _showError("Numéro invalide (au moins 8 chiffres).");
//         return;
//       }

//       // ensure categories loaded and selected
//       if (selectedCategory == null) {
//         _showError("Veuillez choisir une catégorie.");
//         return;
//       }

//       // ok → avancer à l'étape 3
//       setState(() => step = 3);
//       return;
//     }

//     // step 3 validation (passwords) -> final submit
//     if (step == 3) {
//       final pass = ctrl5.text;
//       final confirm = ctrl6.text;

//       if (!_isStrongPassword(pass)) {
//         _showError("Mot de passe invalide. 8+ caractères, majuscule, minuscule et chiffre requis.");
//         return;
//       }

//       if (pass != confirm) {
//         _showError("Les mots de passe ne correspondent pas.");
//         return;
//       }

//       // ---------- PREPARE PAYLOAD ----------
//       final payload = {
//         "name": ctrl1.text.trim(),
//         "email": ctrl2.text.trim(),
//         "numero": ctrl3.text.trim(),
//         "categorie_id": selectedCategory?["id"],
//         "password": pass,
//         "password_confirmation": confirm,
//       };

//       final controller = ref.read(registerControllerProvider.notifier);

//       /// 🔥 APPEL CORRECT SELON TYPE
//       bool ok = false;
//       if (selectedType == "agent") {
//         ok = await controller.registerAgent(payload);
//       } else {
//         ok = await controller.registerAgence(payload);
//       }

//       if (ok) {
//         // registration succeeded and controller already attempted auto-login
//         context.go("/dashboard");
//       } else {
//         // controller sets AsyncError, present readable message
//         final state = ref.read(registerControllerProvider);
//         if (state is AsyncError) {
//           _showError(state.error.toString());
//         } else {
//           _showError("Échec de l'inscription.");
//         }
//       }
//     }
//   }

//   // ---------------------------------------------------------
//   // ÉTAPE 1
//   // ---------------------------------------------------------
//   List<Widget> _step1Fields() {
//     if (selectedType == "agent") {
//       return [
//         _input(ctrl1, "Nom & Prénoms"),
//         const SizedBox(height: 15),
//         _input(ctrl2, "Email"),
//       ];
//     }

//     return [
//       _input(ctrl1, "Nom de l’entreprise"),
//       const SizedBox(height: 15),
//       _input(ctrl2, "Email de l’entreprise"),
//     ];
//   }

//   // ---------------------------------------------------------
//   // ÉTAPE 2
//   // ---------------------------------------------------------
//   List<Widget> _step2Fields() {
//     // selectedType is guaranteed non-null when entering step 2 because of validations above
//     final categoriesAsync = ref.watch(
//       registerCategoriesProvider(selectedType ?? "agent"),
//     );

//     return [
//       _input(ctrl3,
//           selectedType == "agent" ? "Numéro fonctionnel" : "Numéro de l’entreprise"),
//       const SizedBox(height: 15),

//       categoriesAsync.when(
//         data: (list) {
//           return Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade100,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: DropdownButtonFormField<dynamic>(
//               value: selectedCategory,
//               decoration: const InputDecoration(border: InputBorder.none),
//               items: list.map<DropdownMenuItem>((item) {
//                 return DropdownMenuItem(
//                   value: item,
//                   child: Text(item["name"]),
//                 );
//               }).toList(),
//               onChanged: (v) => setState(() => selectedCategory = v),
//               hint: Text(
//                   selectedType == "agent" ? "Type d’agent" : "Type d’agence"),
//             ),
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (e, s) => Text("Erreur : $e"),
//       ),
//     ];
//   }

//   // ---------------------------------------------------------
//   // ÉTAPE 3
//   // ---------------------------------------------------------
//   List<Widget> _step3Fields() {
//     return [
//       _input(ctrl5, "Mot de passe", isPassword: true),
//       const SizedBox(height: 15),
//       _input(ctrl6, "Confirmer le mot de passe", isPassword: true),
//     ];
//   }

//   // ---------------------------------------------------------
//   // INPUT
//   // ---------------------------------------------------------
//   Widget _input(TextEditingController c, String label,
//       {bool isPassword = false}) {
//     return TextField(
//       controller: c,
//       obscureText: isPassword,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Colors.black),
//         filled: true,
//         fillColor: Colors.grey.shade100,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }
// }




















// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:mobile/business/providers/register_provider.dart';

// class RegisterScreen extends ConsumerStatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends ConsumerState<RegisterScreen> {
//   // Form controllers
//   final ctrl1 = TextEditingController();
//   final ctrl2 = TextEditingController();
//   final ctrl3 = TextEditingController();
//   final ctrl4 = TextEditingController();
//   final ctrl5 = TextEditingController();
//   final ctrl6 = TextEditingController();

//   String? selectedType;
//   dynamic selectedCategory;

//   int step = 0;

//   @override
//   Widget build(BuildContext context) {
//     final registerState = ref.watch(registerControllerProvider);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       resizeToAvoidBottomInset: true,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () {
//             if (step > 0) {
//               setState(() => step--);
//             } else {
//               if (context.canPop()) {
//                 context.pop();
//               } else {
//                 context.go("/onboarding");
//               }
//             }
//           },
//         ),
//         title: const Text("Créer un compte", style: TextStyle(color: Colors.black87)),
//         centerTitle: true,
//       ),

//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 20),

//               Image.asset(
//                 "assets/images/onboarding_immobilier.png",
//                 height: 180,
//               ),

//               const SizedBox(height: 25),
//               const Text("Inscription",
//                   style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 10),

//               const Text(
//                 "Rejoignez-nous et commencez vos locations facilement.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 15, color: Colors.black54),
//               ),

//               const SizedBox(height: 30),

//               // --- CHOIX TYPE ---
//               if (step == 0) ...[
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () async {
//                       selectedType = "agent";

//                       /// 🔥 CHARGE CATEGORIES AGENT
//                       await ref
//                           .read(registerControllerProvider.notifier)
//                           .loadCategories("agent");

//                       setState(() => step = 1);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       backgroundColor: Colors.blueAccent,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text("Agent indépendant", style: TextStyle(color: Colors.white)),
//                   ),
//                 ),

//                 const SizedBox(height: 15),

//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () async {
//                       selectedType = "agence";

//                       /// 🔥 CHARGE CATEGORIES AGENCE
//                       await ref
//                           .read(registerControllerProvider.notifier)
//                           .loadCategories("agence");

//                       setState(() => step = 1);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       backgroundColor: Colors.black87,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text("Agence", style: TextStyle(color: Colors.white)),
//                   ),
//                 ),

//                 const SizedBox(height: 25),
//               ],

//               if (step > 0) ..._buildFormSteps(),

//               if (registerState.isLoading)
//                 const Padding(
//                   padding: EdgeInsets.all(12),
//                   child: CircularProgressIndicator(),
//                 ),

//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ---------------------------------------------------------
//   // STEPS
//   // ---------------------------------------------------------
//   List<Widget> _buildFormSteps() {
//     return [
//       Text(
//         "${selectedType == "agent" ? "Agent indépendant" : "Agence"} — Étape $step/3",
//         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       ),

//       const SizedBox(height: 20),

//       if (step == 1) ..._step1Fields(),
//       if (step == 2) ..._step2Fields(),
//       if (step == 3) ..._step3Fields(),

//       const SizedBox(height: 25),

//       SizedBox(
//         width: double.infinity,
//         child: ElevatedButton(
//           onPressed: _onNext,
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(vertical: 14),
//             backgroundColor: Colors.blueAccent,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           child: Text(step < 3 ? "Suivant" : "Terminer",
//               style: const TextStyle(color: Colors.white)),
//         ),
//       ),

//       TextButton(
//         onPressed: () => context.go("/login"),
//         child: const Text(
//           "Déjà un compte ? Se connecter",
//           style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
//         ),
//       ),
//     ];
//   }

//   // ---------------------------------------------------------
//   // NEXT BUTTON HANDLER
//   // ---------------------------------------------------------
//   Future<void> _onNext() async {
//     if (step < 3) {
//       setState(() => step++);
//       return;
//     }

//     final payload = {
//       "name": ctrl1.text,
//       "email": ctrl2.text,
//       "numero": ctrl3.text,
//       "categorie_id": selectedCategory?["id"],
//       "password": ctrl5.text,
//       "password_confirmation": ctrl6.text,
//     };

//     final controller = ref.read(registerControllerProvider.notifier);

//     /// 🔥 APPEL CORRECT SELON TYPE
//     final ok = selectedType == "agent"
//         ? await controller.registerAgent(payload)
//         : await controller.registerAgence(payload);

//     if (ok) {
//       context.go("/dashboard");
//     }
//   }

//   // ---------------------------------------------------------
//   // ÉTAPE 1
//   // ---------------------------------------------------------
//   List<Widget> _step1Fields() {
//     if (selectedType == "agent") {
//       return [
//         _input(ctrl1, "Nom & Prénoms"),
//         const SizedBox(height: 15),
//         _input(ctrl2, "Email"),
//       ];
//     }

//     return [
//       _input(ctrl1, "Nom de l’entreprise"),
//       const SizedBox(height: 15),
//       _input(ctrl2, "Email de l’entreprise"),
//     ];
//   }

//   // ---------------------------------------------------------
//   // ÉTAPE 2
//   // ---------------------------------------------------------
//   List<Widget> _step2Fields() {
//     final categoriesAsync = ref.watch(
//       registerCategoriesProvider(selectedType!), // ⭐ NOUVEAU PROVIDER FIX
//     );

//     return [
//       _input(ctrl3,
//           selectedType == "agent" ? "Numéro fonctionnel" : "Numéro de l’entreprise"),
//       const SizedBox(height: 15),

//       categoriesAsync.when(
//         data: (list) {
//           return Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade100,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: DropdownButtonFormField<dynamic>(
//               value: selectedCategory,
//               decoration: const InputDecoration(border: InputBorder.none),
//               items: list.map<DropdownMenuItem>((item) {
//                 return DropdownMenuItem(
//                   value: item,
//                   child: Text(item["name"]),
//                 );
//               }).toList(),
//               onChanged: (v) => setState(() => selectedCategory = v),
//               hint: Text(
//                   selectedType == "agent" ? "Type d’agent" : "Type d’agence"),
//             ),
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (e, s) => Text("Erreur : $e"),
//       ),
//     ];
//   }

//   // ---------------------------------------------------------
//   // ÉTAPE 3
//   // ---------------------------------------------------------
//   List<Widget> _step3Fields() {
//     return [
//       _input(ctrl5, "Mot de passe", isPassword: true),
//       const SizedBox(height: 15),
//       _input(ctrl6, "Confirmer le mot de passe", isPassword: true),
//     ];
//   }

//   // ---------------------------------------------------------
//   // INPUT
//   // ---------------------------------------------------------
//   Widget _input(TextEditingController c, String label,
//       {bool isPassword = false}) {
//     return TextField(
//       controller: c,
//       obscureText: isPassword,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Colors.black),
//         filled: true,
//         fillColor: Colors.grey.shade100,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }
// }















































// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:mobile/business/providers/register_provider.dart';

// class RegisterScreen extends ConsumerStatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends ConsumerState<RegisterScreen> {
//   // Form controllers
//   final ctrl1 = TextEditingController(); 
//   final ctrl2 = TextEditingController(); 
//   final ctrl3 = TextEditingController(); 
//   final ctrl4 = TextEditingController(); 
//   final ctrl5 = TextEditingController(); 
//   final ctrl6 = TextEditingController(); 

//   String? selectedType; 
//   dynamic selectedCategory; 

//   int step = 0;

//   @override
//   Widget build(BuildContext context) {
//     final registerState = ref.watch(registerControllerProvider);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       resizeToAvoidBottomInset: true,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () {
//             if (step > 0) {
//               setState(() => step--);
//             } else {
//               if (context.canPop()) {
//                 context.pop();
//               } else {
//                 context.go("/onboarding");
//               }
//             }
//           },
//         ),
//         title: const Text("Créer un compte", style: TextStyle(color: Colors.black87)),
//         centerTitle: true,
//       ),

//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 20),

//               Image.asset(
//                 "assets/images/onboarding_immobilier.png",
//                 height: 180,
//               ),

//               const SizedBox(height: 25),
//               const Text("Inscription",
//                   style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 10),

//               const Text(
//                 "Rejoignez-nous et commencez vos locations facilement.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 15, color: Colors.black54),
//               ),

//               const SizedBox(height: 30),

//               // --- CHOIX TYPE ---
//               if (step == 0) ...[
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         selectedType = "agent";

//                         /// 🔥 CHARGER CATÉGORIES AGENT
//                         ref.read(registerCategoryProvider("agent").future);

//                         step = 1;
//                       });
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       backgroundColor: Colors.blueAccent,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text("Agent indépendant", style: TextStyle(color: Colors.white)),
//                   ),
//                 ),

//                 const SizedBox(height: 15),

//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         selectedType = "agence";

//                         /// 🔥 CHARGER CATÉGORIES AGENCE
//                         ref.read(registerCategoryProvider("agence").future);

//                         step = 1;
//                       });
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       backgroundColor: Colors.black87,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text("Agence", style: TextStyle(color: Colors.white)),
//                   ),
//                 ),

//                 const SizedBox(height: 25),
//               ],

//               if (step > 0) ..._buildFormSteps(),

//               if (registerState.isLoading)
//                 const Padding(
//                   padding: EdgeInsets.all(12),
//                   child: CircularProgressIndicator(),
//                 ),

//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ---------------------------------------------------------
//   // STEPS
//   // ---------------------------------------------------------
//   List<Widget> _buildFormSteps() {
//     return [
//       Text(
//         "${selectedType == "agent" ? "Agent indépendant" : "Agence"} — Étape $step/3",
//         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       ),

//       const SizedBox(height: 20),

//       if (step == 1) ..._step1Fields(),
//       if (step == 2) ..._step2Fields(),
//       if (step == 3) ..._step3Fields(),

//       const SizedBox(height: 25),

//       SizedBox(
//         width: double.infinity,
//         child: ElevatedButton(
//           onPressed: _onNext,
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(vertical: 14),
//             backgroundColor: Colors.blueAccent,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           child: Text(step < 3 ? "Suivant" : "Terminer", style: const TextStyle(color: Colors.white)),
//         ),
//       ),

//       TextButton(
//         onPressed: () => context.go("/login"),
//         child: const Text(
//           "Déjà un compte ? Se connecter",
//           style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
//         ),
//       ),
//     ];
//   }

//   // ---------------------------------------------------------
//   // NEXT BUTTON HANDLER
//   // ---------------------------------------------------------
//   Future<void> _onNext() async {
//     if (step < 3) {
//       setState(() => step++);
//       return;
//     }

//     /// 🔥 ÉTAPE 3 → ENVOI
//     final payload = {
//       "name": ctrl1.text,
//       "email": ctrl2.text,
//       "numero": ctrl3.text,
//       "categorie_id": selectedCategory?["id"],
//       "password": ctrl5.text,
//       "password_confirmation": ctrl6.text,
//     };

//     final ok = await ref.read(registerControllerProvider.notifier).register(payload);

//     if (ok) {
//       context.go("/dashboard");
//     }
//   }

//   // ---------------------------------------------------------
//   // ÉTAPE 1
//   // ---------------------------------------------------------
//   List<Widget> _step1Fields() {
//     if (selectedType == "agent") {
//       return [
//         _input(ctrl1, "Nom & Prénoms"),
//         const SizedBox(height: 15),
//         _input(ctrl2, "Email"),
//       ];
//     }

//     return [
//       _input(ctrl1, "Nom de l’entreprise"),
//       const SizedBox(height: 15),
//       _input(ctrl2, "Email de l’entreprise"),
//     ];
//   }

//   // ---------------------------------------------------------
//   // ÉTAPE 2
//   // ---------------------------------------------------------
//   List<Widget> _step2Fields() {
//     final categories = ref.watch(registerCategoryProvider(selectedType!));

//     return [
//       _input(ctrl3, selectedType == "agent" ? "Numéro fonctionnel" : "Numéro de l’entreprise"),
//       const SizedBox(height: 15),

//       categories.when(
//         data: (list) {
//           return Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade100,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: DropdownButtonFormField<dynamic>(
//               value: selectedCategory,
//               decoration: const InputDecoration(border: InputBorder.none),
//               items: list.map<DropdownMenuItem>((item) {
//                 return DropdownMenuItem(
//                   value: item,
//                   child: Text(item["name"]),
//                 );
//               }).toList(),
//               onChanged: (v) => setState(() => selectedCategory = v),
//               hint: Text(selectedType == "agent" ? "Type d’agent" : "Type d’agence"),
//             ),
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (e, s) => Text("Erreur : $e"),
//       ),
//     ];
//   }

//   // ---------------------------------------------------------
//   // ÉTAPE 3
//   // ---------------------------------------------------------
//   List<Widget> _step3Fields() {
//     return [
//       _input(ctrl5, "Mot de passe", isPassword: true),
//       const SizedBox(height: 15),
//       _input(ctrl6, "Confirmer le mot de passe", isPassword: true),
//     ];
//   }

//   // ---------------------------------------------------------
//   // INPUT
//   // ---------------------------------------------------------
//   Widget _input(TextEditingController c, String label, {bool isPassword = false}) {
//     return TextField(
//       controller: c,
//       obscureText: isPassword,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Colors.black),
//         filled: true,
//         fillColor: Colors.grey.shade100,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }
// }











// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   // Form controllers agents / agence
//   final ctrl1 = TextEditingController(); // step 1 champ 1
//   final ctrl2 = TextEditingController(); // step 1 champ 2
//   final ctrl3 = TextEditingController(); // step 2 champ 1
//   final ctrl4 = TextEditingController(); // step 2 champ 2
//   final ctrl5 = TextEditingController(); // step 3 champ 1
//   final ctrl6 = TextEditingController(); // step 3 champ 2

//   String? selectedType; // "agent" ou "agence"
//   String? selectedTypeAgent;
//   String? selectedTypeAgence;

//   int step = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       resizeToAvoidBottomInset: true,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () {
//             if (step > 0) {
//               setState(() => step--);
//             } else {
//               if (context.canPop()) {
//                 context.pop();
//               } else {
//                 context.go("/onboarding");
//               }
//             }
//           },
//         ),
//         title: const Text("Créer un compte", style: TextStyle(color: Colors.black87)),
//         centerTitle: true,
//       ),

//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 20),

//               Image.asset(
//                 "assets/images/onboarding_immobilier.png",
//                 height: 180,
//               ),

//               const SizedBox(height: 25),

//               const Text(
//                 "Inscription",
//                 style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//               ),

//               const SizedBox(height: 10),

//               const Text(
//                 "Rejoignez-nous et commencez vos locations facilement.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 15, color: Colors.black54),
//               ),

//               const SizedBox(height: 30),

//               // --- CHOIX TYPE ---
//               if (step == 0) ...[
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         selectedType = "agent";
//                         step = 1;
//                       });
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       backgroundColor: Colors.blueAccent,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text("Agent indépendant", style: TextStyle(color: Colors.white)),
//                   ),
//                 ),

//                 const SizedBox(height: 15),

//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         selectedType = "agence";
//                         step = 1;
//                       });
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       backgroundColor: Colors.black87,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text("Agence", style: TextStyle(color: Colors.white)),
//                   ),
//                 ),

//                 const SizedBox(height: 25),
//               ],

//               if (step > 0) ..._buildFormSteps(),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ---------------------------------------------------------
//   // STEPS
//   // ---------------------------------------------------------
//   List<Widget> _buildFormSteps() {
//     return [
//       Text(
//         "${selectedType == "agent" ? "Agent indépendant" : "Agence"} — Étape $step/3",
//         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       ),

//       const SizedBox(height: 20),

//       if (step == 1) ..._step1Fields(),
//       if (step == 2) ..._step2Fields(),
//       if (step == 3) ..._step3Fields(),

//       const SizedBox(height: 25),

//       SizedBox(
//         width: double.infinity,
//         child: ElevatedButton(
//           onPressed: () {
//             if (step < 3) {
//               setState(() => step++);
//             } else {
//               context.go("/login");
//             }
//           },
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(vertical: 14),
//             backgroundColor: Colors.blueAccent,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           child: Text(step < 3 ? "Suivant" : "Terminer", style: const TextStyle(color: Colors.white)),
//         ),
//       ),

//       TextButton(
//         onPressed: () => context.go("/login"),
//         child: const Text(
//           "Déjà un compte ? Se connecter",
//           style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
//         ),
//       ),
//     ];
//   }

//   // ---------------------------------------------------------
//   // ÉTAPE 1
//   // ---------------------------------------------------------
//   List<Widget> _step1Fields() {
//     if (selectedType == "agent") {
//       return [
//         _input(ctrl1, "Nom complet"),
//         const SizedBox(height: 15),
//         _input(ctrl2, "Email"),
//       ];
//     }

//     // 🔥 AGENCE — MODIFICATIONS DEMANDÉES
//     return [
//       _input(ctrl1, "Nom de l’entreprise"),
//       const SizedBox(height: 15),
//       _input(ctrl2, "Email de l’entreprise"),
//     ];
//   }

//   // ---------------------------------------------------------
//   // ÉTAPE 2
//   // ---------------------------------------------------------
//   List<Widget> _step2Fields() {
//     if (selectedType == "agent") {
//       return [
//         _input(ctrl3, "Numéro fonctionnel"),
//         const SizedBox(height: 15),

//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade100,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: DropdownButtonFormField<String>(
//             value: selectedTypeAgent,
//             decoration: const InputDecoration(border: InputBorder.none),
//             items: const [
//               DropdownMenuItem(value: "commercial", child: Text("Commercial")),
//               DropdownMenuItem(value: "terrain", child: Text("Agent de terrain")),
//               DropdownMenuItem(value: "partenaire", child: Text("Partenaire immobilier")),
//             ],
//             onChanged: (v) => setState(() => selectedTypeAgent = v),
//             hint: const Text("Type d’agent"),
//           ),
//         ),
//       ];
//     }

//     // 🔥 AGENCE — MODIFICATIONS DEMANDÉES
//     return [
//       _input(ctrl3, "Numéro de l’entreprise"),
//       const SizedBox(height: 15),

//       Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         decoration: BoxDecoration(
//           color: Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: DropdownButtonFormField<String>(
//           value: selectedTypeAgence,
//           decoration: const InputDecoration(border: InputBorder.none),
//           items: const [
//             DropdownMenuItem(value: "immobilier", child: Text("Agence immobilière")),
//             DropdownMenuItem(value: "gestion", child: Text("Société de gestion")),
//             DropdownMenuItem(value: "conciergerie", child: Text("Conciergerie immobilière")),
//           ],
//           onChanged: (v) => setState(() => selectedTypeAgence = v),
//           hint: const Text("Type d’agence"),
//         ),
//       ),
//     ];
//   }

//   // ---------------------------------------------------------
//   // ÉTAPE 3
//   // ---------------------------------------------------------
//   List<Widget> _step3Fields() {
//     return [
//       _input(ctrl5, "Mot de passe", isPassword: true),
//       const SizedBox(height: 15),
//       _input(ctrl6, "Confirmer le mot de passe", isPassword: true),
//     ];
//   }

//   // ---------------------------------------------------------
//   // INPUT DESIGN
//   // ---------------------------------------------------------
//   Widget _input(TextEditingController c, String label, {bool isPassword = false}) {
//     return TextField(
//       controller: c,
//       obscureText: isPassword,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Colors.black),
//         filled: true,
//         fillColor: Colors.grey.shade100,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }
// }





























































// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   // Form controllers agents / agence (réutilisés selon étape)
//   final ctrl1 = TextEditingController(); // step 1 champ 1
//   final ctrl2 = TextEditingController(); // step 1 champ 2
//   final ctrl3 = TextEditingController(); // step 2 champ 1
//   final ctrl4 = TextEditingController(); // step 2 champ 2 (si agence)
//   final ctrl5 = TextEditingController(); // step 3 champ 1
//   final ctrl6 = TextEditingController(); // step 3 champ 2

//   String? selectedType; // "agent" ou "agence"
//   String? selectedTypeAgent; // type d'agent (commercial, terrain...)
//   int step = 0; // 0 = boutons / 1-3 = étapes formulaires

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       resizeToAvoidBottomInset: true,

//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () {
//             if (step > 0) {
//               setState(() => step--);
//             } else {
//               if (context.canPop()) {
//                 context.pop();
//               } else {
//                 context.go("/onboarding");
//               }
//             }
//           },
//         ),
//         title: const Text("Créer un compte", style: TextStyle(color: Colors.black87)),
//         centerTitle: true,
//       ),

//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 20),

//               Image.asset(
//                 "assets/images/onboarding_immobilier.png",
//                 height: 180,
//               ),

//               const SizedBox(height: 25),

//               const Text(
//                 "Inscription",
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),

//               const SizedBox(height: 10),

//               const Text(
//                 "Rejoignez-nous et commencez vos locations facilement.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 15, color: Colors.black54),
//               ),

//               const SizedBox(height: 30),

//               // --- ÉTAPE 0 : CHOIX AGENT / AGENCE ---
//               if (step == 0) ...[
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         selectedType = "agent";
//                         step = 1;
//                       });
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       backgroundColor: Colors.blueAccent,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text(
//                       "Agent indépendant",
//                       style: TextStyle(fontSize: 16, color: Colors.white),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 15),

//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         selectedType = "agence";
//                         step = 1;
//                       });
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       backgroundColor: Colors.black87,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text(
//                       "Agence",
//                       style: TextStyle(fontSize: 16, color: Colors.white),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 25),
//               ],

//               // --- FORMULAIRE MULTI-ÉTAPES ---
//               if (step > 0) ..._buildFormSteps(),

//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ---------------------------------------------------------
//   // FORMULAIRE ÉTAPE PAR ÉTAPE
//   // ---------------------------------------------------------
//   List<Widget> _buildFormSteps() {
//     return [
//       Text(
//         "${selectedType == "agent" ? "Agent indépendant" : "Agence"} — Étape $step/3",
//         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       ),

//       const SizedBox(height: 20),

//       if (step == 1) ..._step1Fields(),
//       if (step == 2) ..._step2Fields(),
//       if (step == 3) ..._step3Fields(),

//       const SizedBox(height: 25),

//       SizedBox(
//         width: double.infinity,
//         child: ElevatedButton(
//           onPressed: () {
//             if (step < 3) {
//               setState(() => step++);
//             } else {
//               context.go("/login");
//             }
//           },
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(vertical: 14),
//             backgroundColor: Colors.blueAccent,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           child: Text(
//             step < 3 ? "Suivant" : "Terminer",
//             style: const TextStyle(fontSize: 16, color: Colors.white),
//           ),
//         ),
//       ),

//       TextButton(
//         onPressed: () => context.go("/login"),
//         child: const Text(
//           "Déjà un compte ? Se connecter",
//           style: TextStyle(
//             fontSize: 15,
//             color: Colors.blueAccent,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     ];
//   }

//   // ---------------------------------------------------------
//   // ÉTAPE 1 - Mise à jour demandée
//   // ---------------------------------------------------------
//   List<Widget> _step1Fields() {
//     if (selectedType == "agent") {
//       return [
//         _input(ctrl1, "Nom & Prénoms"),
//         const SizedBox(height: 15),
//         _input(ctrl2, "Email"),
//       ];
//     }

//     return [
//       _input(ctrl1, "Nom de l’agence"),
//       const SizedBox(height: 15),
//       _input(ctrl2, "RCCM / Identifiant"),
//     ];
//   }

//   // ---------------------------------------------------------
//   // ÉTAPE 2 - Mise à jour demandée
//   // ---------------------------------------------------------
//   List<Widget> _step2Fields() {
//     if (selectedType == "agent") {
//       return [
//         _input(ctrl3, "Numéro fonctionnel"),
//         const SizedBox(height: 15),

//         // TYPE D'AGENT (dropdown)
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade100,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: DropdownButtonFormField<String>(
//             value: selectedTypeAgent,
//             decoration: const InputDecoration(border: InputBorder.none),
//             items: const [
//               DropdownMenuItem(value: "commercial", child: Text("Commercial")),
//               DropdownMenuItem(value: "terrain", child: Text("Agent de terrain")),
//               DropdownMenuItem(value: "partenaire", child: Text("Partenaire immobilier")),
//             ],
//             onChanged: (v) => setState(() => selectedTypeAgent = v),
//             hint: const Text("Type d’agent"),
//           ),
//         ),
//       ];
//     }

//     // Pour agence (inchangé)
//     return [
//       _input(ctrl3, "Email"),
//       const SizedBox(height: 15),
//       _input(ctrl4, "Mot de passe", isPassword: true),
//     ];
//   }

//   // ---------------------------------------------------------
//   // ÉTAPE 3 - Mise à jour demandée
//   // ---------------------------------------------------------
//   List<Widget> _step3Fields() {
//     if (selectedType == "agent") {
//       return [
//         _input(ctrl5, "Mot de passe", isPassword: true),
//         const SizedBox(height: 15),
//         _input(ctrl6, "Confirmer le mot de passe", isPassword: true),
//       ];
//     }

//     return [
//       _input(ctrl5, "Adresse du siège"),
//       const SizedBox(height: 15),
//       _input(ctrl6, "Nom du responsable"),
//     ];
//   }

//   // ---------------------------------------------------------
//   // INPUT — Design intact
//   // ---------------------------------------------------------
//   Widget _input(TextEditingController c, String label,
//       {bool isPassword = false}) {
//     return TextField(
//       controller: c,
//       obscureText: isPassword,
//       cursorColor: Colors.black87,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Colors.black),
//         filled: true,
//         fillColor: Colors.grey.shade100,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   // Form controllers agents / agence (réutilisés selon étape)
//   final ctrl1 = TextEditingController();
//   final ctrl2 = TextEditingController();
//   final ctrl3 = TextEditingController();
//   final ctrl4 = TextEditingController();
//   final ctrl5 = TextEditingController();
//   final ctrl6 = TextEditingController();

//   String? selectedType; // "agent" ou "agence"
//   int step = 0; // 0 = boutons / 1-3 = étapes formulaires

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       resizeToAvoidBottomInset: true,

//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () {
//             if (step > 0) {
//               // revenir à l’étape précédente
//               setState(() => step--);
//             } else {
//               // revenir écran précédent
//               if (context.canPop()) {
//                 context.pop();
//               } else {
//                 context.go("/onboarding");
//               }
//             }
//           },
//         ),
//         title: const Text("Créer un compte", style: TextStyle(color: Colors.black87)),
//         centerTitle: true,
//       ),

//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 20),

//               Image.asset(
//                 "assets/images/onboarding_immobilier.png",
//                 height: 180,
//               ),

//               const SizedBox(height: 25),

//               const Text(
//                 "Inscription",
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),

//               const SizedBox(height: 10),

//               const Text(
//                 "Rejoignez-nous et commencez vos locations facilement.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 15, color: Colors.black54),
//               ),

//               const SizedBox(height: 30),

//               // --- ÉTAPE 0 : AFFICHAGE DES BOUTONS ---
//               if (step == 0) ...[
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         selectedType = "agent";
//                         step = 1;
//                       });
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       backgroundColor: Colors.blueAccent,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text(
//                       "Agent indépendant",
//                       style: TextStyle(fontSize: 16, color: Colors.white),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 15),

//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         selectedType = "agence";
//                         step = 1;
//                       });
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       backgroundColor: Colors.black87,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text(
//                       "Agence",
//                       style: TextStyle(fontSize: 16, color: Colors.white),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 25),
//               ],

//               // --- FORMULAIRE MULTI-ÉTAPES (1 à 3) ---
//               if (step > 0) ..._buildFormSteps(),

//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // FORMULAIRE ÉTAPE PAR ÉTAPE
//   List<Widget> _buildFormSteps() {
//     return [
//       Text(
//         "${selectedType == "agent" ? "Agent indépendant" : "Agence"} — Étape $step/3",
//         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       ),

//       const SizedBox(height: 20),

//       if (step == 1) ..._step1Fields(),
//       if (step == 2) ..._step2Fields(),
//       if (step == 3) ..._step3Fields(),

//       const SizedBox(height: 25),

//       // BOUTON SUIVANT / TERMINER
//       SizedBox(
//         width: double.infinity,
//         child: ElevatedButton(
//           onPressed: () {
//             if (step < 3) {
//               setState(() => step++);
//             } else {
//               context.go("/login");
//             }
//           },
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(vertical: 14),
//             backgroundColor: Colors.blueAccent,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           child: Text(
//             step < 3 ? "Suivant" : "Terminer",
//             style: const TextStyle(fontSize: 16, color: Colors.white),
//           ),
//         ),
//       ),

//       TextButton(
//         onPressed: () => context.go("/login"),
//         child: const Text(
//           "Déjà un compte ? Se connecter",
//           style: TextStyle(
//             fontSize: 15,
//             color: Colors.blueAccent,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     ];
//   }

//   // --- ÉTAPE 1 ---
//   List<Widget> _step1Fields() {
//     if (selectedType == "agent") {
//       return [
//         _input(ctrl1, "Nom & Prénoms"),
//         const SizedBox(height: 15),
//         _input(ctrl2, "Numéro de téléphone"),
//       ];
//     }
//     return [
//       _input(ctrl1, "Nom de l’agence"),
//       const SizedBox(height: 15),
//       _input(ctrl2, "RCCM / Identifiant"),
//     ];
//   }

//   // --- ÉTAPE 2 ---
//   List<Widget> _step2Fields() {
//     return [
//       _input(ctrl3, "Email"),
//       const SizedBox(height: 15),
//       _input(ctrl4, "Mot de passe", isPassword: true),
//     ];
//   }

//   // --- ÉTAPE 3 ---
//   List<Widget> _step3Fields() {
//     if (selectedType == "agent") {
//       return [
//         _input(ctrl5, "Adresse"),
//         const SizedBox(height: 15),
//         _input(ctrl6, "Ville"),
//       ];
//     }
//     return [
//       _input(ctrl5, "Adresse du siège"),
//       const SizedBox(height: 15),
//       _input(ctrl6, "Nom du responsable"),
//     ];
//   }

//   // INPUT WIDGET IDENTIQUE VISUELLEMENT À TON DESIGN
//   Widget _input(TextEditingController c, String label, {bool isPassword = false}) {
//     return TextField(
//       controller: c,
//       obscureText: isPassword,
//       cursorColor: Colors.black87,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Colors.black),
//         filled: true,
//         fillColor: Colors.grey.shade100,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }
// }


// ifu, adress, numero fonctionnel, cip, cni, cartebiométrie, registre de commerce











// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final nameCtrl = TextEditingController();
//   final emailCtrl = TextEditingController();
//   final passCtrl = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       resizeToAvoidBottomInset: true,

//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () {
//             if (context.canPop()) {
//               context.pop();
//             } else {
//               context.go("/onboarding");
//             }
//           },
//         ),
//         title: const Text(
//           "Créer un compte",
//           style: TextStyle(color: Colors.black87),
//         ),
//         centerTitle: true,
//       ),

//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [

//               const SizedBox(height: 20),

//               // Illustration
//               Image.asset(
//                 "assets/images/onboarding_immobilier.png",
//                 height: 180,
//               ),

//               const SizedBox(height: 25),

//               const Text(
//                 "Inscription",
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),

//               const SizedBox(height: 10),

//               const Text(
//                 "Rejoignez-nous et commencez vos locations facilement.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 15,
//                   color: Colors.black54,
//                 ),
//               ),

//               const SizedBox(height: 30),

//               // NOM
//               TextField(
//                 controller: nameCtrl,
//                 cursorColor: Colors.black87,
//                 decoration: InputDecoration(
//                   labelText: "Nom complet",
//                   labelStyle: const TextStyle(color: Colors.black),
//                   filled: true,
//                   fillColor: Colors.grey.shade100,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 15),

//               // EMAIL
//               TextField(
//                 controller: emailCtrl,
//                 cursorColor: Colors.black87,
//                 decoration: InputDecoration(
//                   labelText: "Email",
//                   labelStyle: const TextStyle(color: Colors.black),
//                   filled: true,
//                   fillColor: Colors.grey.shade100,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 15),

//               // MOT DE PASSE
//               TextField(
//                 controller: passCtrl,
//                 obscureText: true,
//                 cursorColor: Colors.black87,
//                 decoration: InputDecoration(
//                   labelText: "Mot de passe",
//                   labelStyle: const TextStyle(color: Colors.black),
//                   filled: true,
//                   fillColor: Colors.grey.shade100,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 25),

//               // BOUTON S'INSCRIRE
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () => context.go("/login"),
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     backgroundColor: Colors.blueAccent,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text(
//                     "S’inscrire",
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),

//               // const SizedBox(height: 5),

//               // Redirect login
//               TextButton(
//                 onPressed: () => context.go("/login"),
//                 child: const Text(
//                   "Déjà un compte ? Se connecter",
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: Colors.blueAccent,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// Même chose """import 'package:flutter/material.dart';

// class ForgotPasswordScreen extends StatelessWidget {
//   const ForgotPasswordScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final emailCtrl = TextEditingController();

//     return Scaffold(
//       appBar: AppBar(title: const Text("Mot de passe oublié")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             const Text(
//               "Recevez un lien de réinitialisation dans votre email.",
//               style: TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 20),

//             TextField(
//               controller: emailCtrl,
//               decoration: const InputDecoration(labelText: "Email"),
//             ),
//             const SizedBox(height: 20),

//             ElevatedButton(
//               onPressed: () {},
//               child: const Text("Envoyer le lien"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// } """