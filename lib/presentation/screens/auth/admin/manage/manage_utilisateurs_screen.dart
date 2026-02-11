import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/presentation/screens/auth/admin/manage/user%20profil/add_user_screen.dart';
import 'package:mobile/presentation/screens/auth/admin/manage/user%20profil/users_profil_screen.dart';
import 'package:mobile/presentation/screens/auth/admin/manage/validation/validation_screen.dart';
import '../../../../theme/colors.dart';
import '../../../../../data/models/user_model.dart';
import '../../../../../business/providers/auth_controller_provider.dart';

class GestionUtilisateursScreen extends ConsumerStatefulWidget {
  const GestionUtilisateursScreen({super.key});

  @override
  ConsumerState<GestionUtilisateursScreen> createState() =>
      _GestionUtilisateursScreenState();
}

class _GestionUtilisateursScreenState
    extends ConsumerState<GestionUtilisateursScreen> {
      
  final url = "https://api-location-plus.lamadonebenin.com/storage/";
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authControllerProvider.notifier).fetchAllUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Gestion des Utilisateurs",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      /// ➕ BOUTON AJOUT (ÉCRAN FULL)
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        mini: true,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddUserScreen()),
          );

          // Refresh après retour
          await ref.read(authControllerProvider.notifier).fetchAllUsers();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(authControllerProvider.notifier).fetchAllUsers();
        },
        child: state.isUsersLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : state.error != null
                ? Center(
                    child: Text(
                      "Erreur : ${state.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : state.adminUsers.isEmpty
                    ? const Center(child: Text("Aucun utilisateur trouvé."))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.adminUsers.length,
                        itemBuilder: (context, index) {
                          final user = state.adminUsers[index];
                          return _itemUser(context, user);
                        },
                      ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ITEM USER
  // ---------------------------------------------------------------------------
  Widget _itemUser(BuildContext context, User user) {
    final nomAffiche = user.accountType == "entreprise"
        ? (user.companyName ?? "Entreprise")
        : user.accountType == "admin"
            ? "Administrateur"
            : (user.fullName ?? "Utilisateur");

    final statutTexte = user.accountType == "admin"
        ? ""
        : (user.verifiedDocuments ? "Validé" : "En attente de validation");

    final statutCouleur =
        user.verifiedDocuments ? AppColors.primary : Colors.red;

    final suspendText = user.activated ? "Suspendre" : "Activer";

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UserProfilScreen(user: user)),
          );
        },
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          backgroundImage:
              user.avatarUrl != null ? NetworkImage(url + user.avatarUrl!) : null,
          child: user.avatarUrl == null
              ? const Icon(Icons.person, color: Colors.white)
              : null,
        ),
        title: Text(
          nomAffiche,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: statutTexte.isEmpty
            ? Text(user.email)
            : Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: "${user.email}\n"),
                    TextSpan(
                      text: statutTexte,
                      style: TextStyle(color: statutCouleur),
                    ),
                  ],
                ),
              ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            final controller = ref.read(authControllerProvider.notifier);

            switch (value) {
              case "verify":
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ValidationScreen(user: user),
                  ),
                );
                break;

              case "suspend":
                final newActivated = !user.activated;
                print('Suspending/Activating user: ${user.id}, current state: ${user.activated}');
                final success = await controller.toggleUserActivation(
                  userId: user.id,
                  activated: newActivated,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? (newActivated ? "Compte activé" : "Compte suspendu")
                          : "Action impossible",
                    ),
                    backgroundColor:
                        success ? AppColors.primary : Colors.red,
                  ),
                );

                if (success) {
                  await controller.fetchAllUsers();
                }
                break;

            }
          },
          itemBuilder: (context) => [
            if (user.accountType != "admin")
              const PopupMenuItem(
                value: "verify",
                child: Text("Vérification"),
              ),
            PopupMenuItem(
              value: "suspend",
              child: Text(suspendText),
            ),
          ],
        ),
      ),
    );
  }
}







// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile/presentation/screens/auth/admin/manage/user%20profil/users_profil_screen.dart';
// import 'package:mobile/presentation/screens/auth/admin/manage/validation/validation_screen.dart';
// import '../../../../theme/colors.dart';
// import '../../../../../data/models/user_model.dart';
// import '../../../../../business/providers/auth_controller_provider.dart';

// class GestionUtilisateursScreen extends ConsumerStatefulWidget {
//   const GestionUtilisateursScreen({super.key});

//   @override
//   ConsumerState<GestionUtilisateursScreen> createState() =>
//       _GestionUtilisateursScreenState();
// }

// class _GestionUtilisateursScreenState
//     extends ConsumerState<GestionUtilisateursScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(authControllerProvider.notifier).fetchAllUsers();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(authControllerProvider);

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           "Gestion des Utilisateurs",
//           style: TextStyle(
//             color: AppColors.textDark,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           await ref.read(authControllerProvider.notifier).fetchAllUsers();
//         },
//         child: state.isUsersLoading
//             ? const Center(
//                 child: CircularProgressIndicator(color: AppColors.primary),
//               )
//             : state.error != null
//                 ? Center(
//                     child: Text(
//                       "Erreur : ${state.error}",
//                       style: const TextStyle(color: Colors.red),
//                     ),
//                   )
//                 : state.adminUsers.isEmpty
//                     ? const Center(
//                         child: Text("Aucun utilisateur trouvé."),
//                       )
//                     : ListView.builder(
//                         padding: const EdgeInsets.all(16),
//                         itemCount: state.adminUsers.length,
//                         itemBuilder: (context, index) {
//                           final user = state.adminUsers[index];
//                           return _itemUser(context, user);
//                         },
//                       ),
//       ),
//     );
//   }

//   Widget _itemUser(BuildContext context, User user) {
//     final nomAffiche = user.accountType == "entreprise"
//         ? (user.companyName ?? "Entreprise")
//         : user.accountType == "admin"
//             ? (user.companyName ?? "Administrateur")
//             : (user.fullName ?? "Utilisateur");

//     final statutTexte = user.accountType == "admin"
//         ? ""
//         : (user.verifiedDocuments ? "Validé" : "En attente de validation");

//     final statutCouleur = user.accountType == "admin"
//         ? null
//         : (user.verifiedDocuments ? AppColors.primary : Colors.red);

//     // Texte Suspend/Activer
//     final isActive = user.activated;
//     final suspendText = isActive ? "Suspendre" : "Activer";

//     return Card(
//       elevation: 2,
//       margin: const EdgeInsets.only(bottom: 16),
//       child: ListTile(
//         onTap: () {
//           // Ouvre directement le profil de l'utilisateur au clic
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => UserProfilScreen(user: user)),
//           );
//         },
//         leading: CircleAvatar(
//           backgroundColor: AppColors.primary,
//           backgroundImage:
//               user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
//           child: user.avatarUrl == null
//               ? const Icon(Icons.person, color: Colors.white)
//               : null,
//         ),
//         title: Text(
//           nomAffiche,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: statutTexte.isEmpty
//             ? Text(user.email)
//             : Text.rich(
//                 TextSpan(
//                   children: [
//                     TextSpan(text: "${user.email}\n"),
//                     TextSpan(
//                       text: "$statutTexte",
//                       style: TextStyle(color: statutCouleur),
//                     ),
//                   ],
//                 ),
//               ),
//         isThreeLine: true,
//         trailing: PopupMenuButton<String>(
//           onSelected: (value) async {
//             final controller = ref.read(authControllerProvider.notifier);

//             switch (value) {
//               case "details":
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (_) => UserProfilScreen(user: user)),
//                 );
//                 break;

//               case "verify":
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (_) => ValidationScreen(user: user)),
//                 );
//                 break;

//               case "suspend":
//                 final success = await controller.updateProfile(
//                   userId: user.id,
//                   // Toggle activated
//                   activated: !user.activated,
//                 );

//                 if (success) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(
//                         user.activated
//                             ? "Compte activé"
//                             : "Compte suspendu",
//                       ),
//                       backgroundColor: AppColors.primary,
//                     ),
//                   );
//                   await controller.fetchAllUsers(); // refresh list
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: const Text("Impossible de changer le statut"),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                 }
//                 break;
//             }
//           },
//           itemBuilder: (context) => [
//             const PopupMenuItem(value: "details", child: Text("Voir profil")),
//             if (user.accountType != "admin")
//               const PopupMenuItem(value: "verify", child: Text("Vérification")),
//             PopupMenuItem(value: "suspend", child: Text(suspendText)),
//           ],
//         ),
//       ),
//     );
//   }
// }




































// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../../theme/colors.dart';
// import '../../../../../data/models/user_model.dart';
// import '../../../../../business/providers/auth_controller_provider.dart';

// class GestionUtilisateursScreen extends ConsumerStatefulWidget {
//   const GestionUtilisateursScreen({super.key});

//   @override
//   ConsumerState<GestionUtilisateursScreen> createState() =>
//       _GestionUtilisateursScreenState();
// }

// class _GestionUtilisateursScreenState
//     extends ConsumerState<GestionUtilisateursScreen> {
//   @override
//   void initState() {
//     super.initState();

//     // ⚡ Appel automatique au premier rendu
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(authControllerProvider.notifier).fetchAllUsers();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(authControllerProvider);

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           "Gestion des Utilisateurs",
//           style: TextStyle(
//             color: AppColors.textDark,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),

//       body: RefreshIndicator(
//         onRefresh: () async {
//           await ref.read(authControllerProvider.notifier).fetchAllUsers();
//         },

//         child: state.isUsersLoading
//             ? const Center(
//                 child: CircularProgressIndicator(color: AppColors.primary),
//               )
//             : state.error != null
//                 ? Center(
//                     child: Text(
//                       "Erreur : ${state.error}",
//                       style: const TextStyle(color: Colors.red),
//                     ),
//                   )
//                 : state.adminUsers.isEmpty
//                     ? const Center(
//                         child: Text("Aucun utilisateur trouvé."),
//                       )
//                     : ListView.builder(
//                         padding: const EdgeInsets.all(16),
//                         itemCount: state.adminUsers.length,
//                         itemBuilder: (context, index) {
//                           final user = state.adminUsers[index];
//                           return _itemUser(context, user);
//                         },
//                       ),
//       ),
//     );
//   }

//   // ---------------------------------------------
//   // Widget pour afficher chaque utilisateur
//   // ---------------------------------------------
//   Widget _itemUser(BuildContext context, User user) {
//     final nomAffiche = user.accountType == "entreprise"
//         ? (user.companyName ?? "Entreprise")
//         : user.accountType == "admin"
//             ? (user.companyName ?? "Administrateur")
//             : (user.fullName ?? "Utilisateur");


//     final statutTexte = user.accountType == "admin"
//     ? ""
//     : (user.verifiedDocuments ? "Validé" : "En attente de validation");

//     // Couleur du statut
//     final statutCouleur = user.accountType == "admin"
//       ? null
//       : (user.verifiedDocuments ? AppColors.primary : Colors.red);

//     return Card(
//       elevation: 2,
//       margin: const EdgeInsets.only(bottom: 16),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: AppColors.primary,
//           backgroundImage:
//               user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
//           child: user.avatarUrl == null
//               ? const Icon(Icons.person, color: Colors.white)
//               : null,
//         ),
//         title: Text(
//           nomAffiche,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: statutTexte.isEmpty
//           ? Text(user.email)
//           : Text.rich(
//               TextSpan(
//                 children: [
//                   TextSpan(text: "${user.email}\n"),
//                   TextSpan(
//                     text: "$statutTexte",
//                     style: TextStyle(color: statutCouleur),
//                   ),
//                 ],
//               ),
//             ),
//         isThreeLine: true,
//         trailing: PopupMenuButton<String>(
//           onSelected: (value) {
//             switch (value) {
//               case "details":
//                 // TODO: Naviguer vers profil
//                 break;
//               case "verify":
//                 // TODO: Validation admin
//                 break;
//               case "suspend":
//                 // TODO: Suspendre user
//                 break;
//             }
//           },
//           itemBuilder: (context) => const [
//             PopupMenuItem(value: "details", child: Text("Voir profil")),
//             PopupMenuItem(value: "verify", child: Text("Vérification")),
//             PopupMenuItem(value: "suspend", child: Text("Suspendre")),
//           ],
//         ),
//       ),
//     );
//   }
// }

