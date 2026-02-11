import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        "q": "Comment publier un bien ?",
        "a":
            "Allez dans l’onglet Mes biens puis cliquez sur Ajouter un bien et remplissez le formulaire."
      },
      {
        "q": "Comment contacter un propriétaire ?",
        "a":
            "Ouvrez le détail du bien et cliquez sur le bouton WhatsApp pour discuter directement."
      },
      {
        "q": "Que faire si mon compte est rejeté ?",
        "a":
            "Vous pouvez mettre à jour vos documents depuis votre profil et soumettre une nouvelle demande."
      },
      {
        "q": "Comment signaler un problème ?",
        "a":
            "Rendez-vous dans Aide & Support puis cliquez sur Signaler un problème."
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("FAQ"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return ExpansionTile(
            title: Text(
              faq["q"]!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(faq["a"]!),
              ),
            ],
          );
        },
      ),
    );
  }
}
