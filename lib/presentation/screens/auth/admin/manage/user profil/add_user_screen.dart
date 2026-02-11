import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../theme/colors.dart';
import 'dart:math';
import '../../../../../../business/providers/auth_controller_provider.dart';

class AddUserScreen extends ConsumerStatefulWidget {
  const AddUserScreen({super.key});

  @override
  ConsumerState<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends ConsumerState<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String accountType = "particulier";
  bool isLoading = false;
  bool obscurePassword = true;

  String _generatePassword({int length = 10}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#\$%!';

    final rand = Random.secure();
    return List.generate(
      length,
      (index) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ajouter un utilisateur",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------- EMAIL -------------------
              Text("Email", style: _labelStyle()),
              const SizedBox(height: 6),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (val) =>
                    val == null || val.isEmpty ? "Email obligatoire" : null,
                decoration: _inputDecoration(hint: "ex: utilisateur@email.com"),
              ),

              const SizedBox(height: 16),

              // ------------------- MOT DE PASSE -------------------
              Text("Mot de passe", style: _labelStyle()),
              const SizedBox(height: 6),
              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                validator: (val) =>
                    val == null || val.isEmpty ? "Mot de passe obligatoire" : null,
                decoration: _inputDecoration(
                  hint: "Mot de passe généré ou manuel",
                ).copyWith(
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 👁️ afficher / masquer
                      IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),

                      // 🔑 générer mot de passe
                      IconButton(
                        icon: const Icon(Icons.autorenew),
                        tooltip: "Générer un mot de passe",
                        onPressed: () {
                          final generated = _generatePassword();
                          setState(() {
                            passwordController.text = generated;
                            obscurePassword = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),


              const SizedBox(height: 16),

              // ------------------- TYPE DE COMPTE -------------------
              Text("Type de compte", style: _labelStyle()),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: accountType,
                decoration: _inputDecoration(),
                items: const [
                  DropdownMenuItem(
                    value: "particulier",
                    child: Text("Particulier"),
                  ),
                  DropdownMenuItem(
                    value: "entreprise",
                    child: Text("Entreprise"),
                  ),
                  DropdownMenuItem(
                    value: "admin",
                    child: Text("Administrateur"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    accountType = value!;
                  });
                },
              ),

              const SizedBox(height: 30),

              // ------------------- BOUTON CREATION -------------------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Créer l'utilisateur",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SUBMIT
  // ---------------------------------------------------------------------------
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final success = await ref
        .read(authControllerProvider.notifier)
        .createUser(
          email: emailController.text.trim(),
          password: passwordController.text,
          accountType: accountType,
        );

    setState(() => isLoading = false);

    if (success) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Utilisateur ajouté avec succès"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur lors de la création"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ------------------- STYLES -------------------
  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  TextStyle _labelStyle() {
    return const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14,
      color: AppColors.textDark,
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../../../theme/colors.dart';
// import '../../../../../../business/providers/auth_controller_provider.dart';

// class AddUserScreen extends ConsumerStatefulWidget {
//   const AddUserScreen({super.key});

//   @override
//   ConsumerState<AddUserScreen> createState() => _AddUserScreenState();
// }

// class _AddUserScreenState extends ConsumerState<AddUserScreen> {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();

//   String accountType = "particulier";
//   bool isLoading = false;
//   bool obscurePassword = true;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Ajouter un utilisateur"),
//         backgroundColor: Colors.white,
//         foregroundColor: AppColors.textDark,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 8),

//             // EMAIL
//             TextField(
//               controller: emailController,
//               keyboardType: TextInputType.emailAddress,
//               decoration: const InputDecoration(
//                 labelText: "Email",
//                 filled: true,
//               ),
//             ),

//             const SizedBox(height: 16),

//             // PASSWORD
//             TextField(
//               controller: passwordController,
//               obscureText: obscurePassword,
//               decoration: InputDecoration(
//                 labelText: "Mot de passe",
//                 filled: true,
//                 suffixIcon: IconButton(
//                   icon: Icon(
//                     obscurePassword
//                         ? Icons.visibility_off
//                         : Icons.visibility,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       obscurePassword = !obscurePassword;
//                     });
//                   },
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // ACCOUNT TYPE
//             DropdownButtonFormField<String>(
//               value: accountType,
//               decoration: const InputDecoration(
//                 labelText: "Type de compte",
//                 filled: true,
//               ),
//               items: const [
//                 DropdownMenuItem(
//                   value: "particulier",
//                   child: Text("Particulier"),
//                 ),
//                 DropdownMenuItem(
//                   value: "entreprise",
//                   child: Text("Entreprise"),
//                 ),
//                 DropdownMenuItem(
//                   value: "admin",
//                   child: Text("Administrateur"),
//                 ),
//               ],
//               onChanged: (value) {
//                 setState(() {
//                   accountType = value!;
//                 });
//               },
//             ),

//             const SizedBox(height: 32),
//           ],
//         ),
//       ),

//       // 🔽 BOUTON FIXE EN BAS
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(16),
//         child: SizedBox(
//           height: 48,
//           width: double.infinity,
//           child: ElevatedButton(
//             onPressed: isLoading ? null : _submit,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(14),
//               ),
//             ),
//             child: isLoading
//                 ? const SizedBox(
//                     height: 24,
//                     width: 24,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       color: Colors.white,
//                     ),
//                   )
//                 : const Text(
//                     "Créer l'utilisateur",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ---------------------------------------------------------------------------
//   // SUBMIT
//   // ---------------------------------------------------------------------------
//   Future<void> _submit() async {
//     if (emailController.text.isEmpty ||
//         passwordController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Email et mot de passe obligatoires"),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     setState(() => isLoading = true);

//     final success = await ref
//         .read(authControllerProvider.notifier)
//         .createUser(
//           email: emailController.text.trim(),
//           password: passwordController.text,
//           accountType: accountType,
//         );

//     setState(() => isLoading = false);

//     if (success) {
//       Navigator.pop(context);

//       await ref.read(authControllerProvider.notifier).fetchAllUsers();

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Utilisateur ajouté avec succès"),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Erreur lors de la création"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
// }
