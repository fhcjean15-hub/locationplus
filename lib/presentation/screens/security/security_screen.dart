import 'package:flutter/material.dart';
import 'package:mobile/presentation/screens/auth/password/change_password_screen.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  void _showNotAvailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Cette fonctionnalité n'est pas encore disponible"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Sécurité",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SecurityItem(
            icon: Icons.lock,
            title: "Changer le mot de passe",
            subtitle: "Mettez à jour votre mot de passe pour sécuriser votre compte",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            },
          ),

          SecurityItem(
            icon: Icons.phonelink_lock,
            title: "Authentification à deux facteurs",
            subtitle: "Activez la 2FA pour plus de sécurité",
            onTap: () => _showNotAvailable(context),
          ),
          SecurityItem(
            icon: Icons.devices,
            title: "Appareils connectés",
            subtitle: "Gérez vos appareils connectés à ce compte",
            onTap: () => _showNotAvailable(context),
          ),
          SecurityItem(
            icon: Icons.exit_to_app,
            title: "Déconnexion de tous les appareils",
            subtitle: "Déconnectez votre compte de tous les appareils",
            onTap: () => _showNotAvailable(context),
          ),
        ],
      ),
    );
  }
}

class SecurityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SecurityItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
