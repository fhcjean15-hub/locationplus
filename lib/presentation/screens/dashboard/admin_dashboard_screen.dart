import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: const Center(
        child: Text("Espace administrateur"),
      ),
    );
  }
}



// Okay, maintenant j'aimerais que l'accueil soit le dashboard générale pour tout l'app, la différence se trouve au niveau de l'écran profil. On aura plusieurs écran profil selon l'utilisateur connecter "sans compte, user(particulier ou entreprise), admin". Donc je vais changer le dossier dashboard en profil