import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/presentation/screens/auth/admin/manage/manage_biens_screen.dart';
import 'package:mobile/presentation/screens/auth/admin/manage/manage_utilisateurs_screen.dart';
import 'package:mobile/presentation/screens/auth/utilisateurs/biens/biens_screen.dart';
import 'package:mobile/presentation/screens/auth/utilisateurs/expiration/expiration_screen.dart';
import 'package:mobile/presentation/screens/auth/utilisateurs/profile/profile_screen.dart';
import 'package:mobile/presentation/screens/auth/utilisateurs/verification/verification_screen.dart';
import 'package:mobile/presentation/screens/home/home_screen.dart';
import '../../theme/colors.dart';

// Import des écrans
import '../favoris/favoris_screen.dart';
import '../mes reservation/mes_reservations_screen.dart';
import '../history/history_screen.dart';
import '../notifications/notifications_screen.dart';
import '../security/security_screen.dart';
import '../assistance/help_support_screen.dart';
import '../auth/login_screen.dart';
import '../../../business/providers/auth_controller_provider.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    final roleString = user?.accountType?.toLowerCase() ?? "invite";
    final bool isInvite = roleString == "invite" || user == null;
    final bool isAdmin = roleString == "admin";
    final bool isUser =
        roleString == "particulier" || roleString == "entreprise";
    
    final url = "https://api-location-plus.lamadonebenin.com/storage/";

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Mon Compte",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ----------------------------------------------------
          // HEADER PROFIL
          // ----------------------------------------------------
          if (!isInvite)
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: AppColors.primary,
                    backgroundImage:
                        user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                        ? NetworkImage(url + user!.avatarUrl!)
                        : null,
                    child: (user?.avatarUrl == null || user!.avatarUrl!.isEmpty)
                        ? const Icon(
                            Icons.person,
                            size: 55,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              // Détermination du rôle
                              (user?.accountType == 'entreprise')
                                  ? (user?.companyName?.isNotEmpty == true
                                        ? user!.companyName!
                                        : "Nom de l'entreprise")
                                  : (user?.accountType == 'admin')
                                  ? "Administrateur"
                                  : (user?.fullName?.isNotEmpty == true
                                        ? user!.fullName!
                                        : "Votre Nom"),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          // 🔹 Bouton crayon pour modifier le profil (optionnel)
                          // IconButton(
                          //   padding: EdgeInsets.zero,
                          //   constraints: const BoxConstraints(),
                          //   icon: const Icon(Icons.edit, size: 20, color: AppColors.primary),
                          //   onPressed: () {
                          //     context.push("/edit-profile");
                          //   },
                          // ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? "email@example.com",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

          if (!isInvite) const SizedBox(height: 30),

          // ----------------------------------------------------
          // SECTIONS COMMUNES
          // ----------------------------------------------------
          // _item(context, Icons.favorite_border, "Mes favoris",
          //     screen: const FavorisScreen()),
          _item(
            context,
            Icons.receipt_long,
            "Mes réservations",
            screen: const MesReservationsScreen(),
          ),

          _item(
            context,
            Icons.notifications_none,
            "Notifications",
            screen: const NotificationsScreen(),
          ),

          // if (!isInvite)
          //   _item(context, Icons.history, "Historique",
          //       screen: const HistoryScreen()),
          if (isUser || isAdmin)
            _item(
              context,
              Icons.home_work,
              "Mes biens",
              onTap: () {
                if (user != null && user.verifiedDocuments == false) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Veuillez valider votre compte avant d'accéder à vos biens.",
                      ),
                    ),
                  );
                  return; // Stopper la navigation
                }

                // Sinon → navigation normale
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MesBiensScreen()),
                );
              },
            ),

          if (isUser)
            _item(
              context,
              Icons.verified_user,
              "Vérification & Validation du compte",
              screen: const VerificationScreen(),
            ),

          if (isUser)
            _item(
              context,
              Icons.timer_outlined,
              "Expiration / Validité du compte",
              screen: const ExpirationScreen(),
            ),

          if (!isInvite)
            _item(
              context,
              Icons.security,
              "Sécurité",
              screen: const SecurityScreen(),
            ),

          _item(
            context,
            Icons.help_outline,
            "Aide & Support",
            screen: const HelpSupportScreen(),
          ),

          if (isAdmin)
            _item(
              context,
              Icons.settings_applications,
              "Gestion des biens",
              screen: const ManageBiensScreen(),
            ),

          if (isAdmin)
            _item(
              context,
              Icons.group,
              "Gestion des utilisateurs",
              screen: const GestionUtilisateursScreen(),
            ),

          const SizedBox(height: 20),

          // ----------------------------------------------------
          // LOGIN / DECONNEXION
          // ----------------------------------------------------
          if (isInvite)
            _item(
              context,
              Icons.login,
              "S'inscrire / Connexion",
              route: "/login",
            ),

          if (!isInvite)
            _item(
              context,
              Icons.logout,
              "Déconnexion",
              isLogout: true,
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icône circulaire moderne
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.logout,
                                color: Colors.red,
                                size: 32,
                              ),
                            ),

                            const SizedBox(height: 16),

                            const Text(
                              "Déconnexion",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              "Voulez-vous vraiment vous déconnecter de votre compte ?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 25),

                            // Boutons
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: const BorderSide(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      "Annuler",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      shadowColor: Colors.red.withOpacity(0.4),
                                      elevation: 3,
                                    ),
                                    child: const Text(
                                      "Déconnecter",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );

                // Si l’utilisateur annule → on stoppe ici
                if (confirm != true) return;

                // Déconnexion
                await ref.read(authControllerProvider.notifier).logout();

                if (context.mounted) {
                  context.go("/home"); // 🚀 Redirection GoRouter OK
                }
              },
            ),
        ],
      ),
    );
  }

  // ***********************************************************
  // WIDGET LIST TILE GLOBAL
  // ***********************************************************
  Widget _item(
    BuildContext context,
    IconData icon,
    String text, {
    bool isLogout = false,
    Widget? screen,
    String? route,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : AppColors.primary),
      title: Text(
        text,
        style: TextStyle(
          color: isLogout ? Colors.red : AppColors.textDark,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        if (onTap != null) {
          onTap(); // <-- Custom action (déconnexion avec modal)
          return;
        }

        if (route != null) {
          context.go(route);
          return;
        }

        if (screen != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        }
      },
    );
  }
}
