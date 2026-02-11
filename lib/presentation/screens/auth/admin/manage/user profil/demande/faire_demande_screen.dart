import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/business/providers/auth_controller_provider.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/presentation/theme/colors.dart';

class FaireDemandeScreen extends ConsumerStatefulWidget {
  final User utilisateur; // ★ Destinataire de la demande

  const FaireDemandeScreen({
    super.key,
    required this.utilisateur,
  });

  @override
  ConsumerState<FaireDemandeScreen> createState() => _FaireDemandeScreenState();
}

class _FaireDemandeScreenState extends ConsumerState<FaireDemandeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController contactCtrl = TextEditingController();
  final TextEditingController noteCtrl = TextEditingController();

  bool isLoading = false;

  Future<void> _envoyerDemande() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final auth = ref.read(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);

    final isConnected = auth.user != null;

    // ★ Récupération IP si non connecté
    final deviceIp = InternetAddress.anyIPv4.address;

    // ★ sender_id = user.id OU ip
    final senderId = isConnected ? auth.user!.id : deviceIp;

    // ★ payload final
    final payload = {
      "title": "Nouvelle demande",
      "note": noteCtrl.text.trim(),
      "contact": contactCtrl.text.trim(),
      "sender_id": senderId,   // IMPORTANT
    };

    try {
      await controller.postNotification(
        userId: widget.utilisateur.id, // ★ destinataire
        type: "demande",
        payload: payload,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Votre demande a été envoyée avec succès 🎉"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur : ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Contacter ${widget.utilisateur.fullName}"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Contact", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),

              TextFormField(
                controller: contactCtrl,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  hintText: "Email, téléphone ou WhatsApp",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? "Ce champ est obligatoire" : null,
              ),

              const SizedBox(height: 16),

              const Text("Message", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),

              TextFormField(
                controller: noteCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  hintText: "Expliquez votre demande…",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? "Veuillez entrer un message" : null,
              ),

              const Spacer(),

              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _envoyerDemande,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Text(
                          "Envoyer la demande",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
