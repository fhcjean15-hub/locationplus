import 'package:flutter/material.dart';
import 'package:mobile/presentation/screens/Faq/faq_screen.dart';
import 'package:mobile/presentation/screens/signalement/report_problem_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Aide & Support",
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
          HelpItem(
            icon: Icons.help_outline,
            title: "FAQ",
            subtitle: "Consultez les questions fréquentes",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FaqScreen()),
              );
            },
          ),
          HelpItem(
            icon: Icons.chat_bubble_outline,
            title: "Chat avec le support",
            subtitle: "Discutez en direct avec notre équipe",
            onTap: () => showChatUnavailable(context),
          ),
          HelpItem(
            icon: Icons.email_outlined,
            title: "Envoyer un email",
            subtitle: "Contactez-nous par email",
            onTap: openSupportEmail,
          ),
          HelpItem(
            icon: Icons.phone_outlined,
            title: "Appeler le support",
            subtitle: "Appelez notre service client",
            onTap: callSupport,
          ),
          HelpItem(
            icon: Icons.report_problem_outlined,
            title: "Signaler un problème",
            subtitle: "Informez-nous d’un bug ou problème rencontré",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportProblemScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

  void showChatUnavailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Le chat avec le support n’est pas encore disponible."),
      ),
    );
  }

  Future<void> openSupportEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'hosanaconsulting@gmail.com',
      queryParameters: {
        'subject': 'Aide et support',
      },
    );

    try {
      await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint("Aucune application email disponible");
    }
  }




  Future<void> callSupport() async {
    final uri = Uri.parse("tel:+22990000000");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

class HelpItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const HelpItem({
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
