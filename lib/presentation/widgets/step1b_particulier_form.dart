
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/business/providers/register_provider.dart';
import 'upload_document_widget.dart';

class Step1BParticulierForm extends ConsumerWidget {
  final String? selectedCategoryId;
  final Function(String?) onCategorySelected;

  // Fichier choisi par l'utilisateur
  final File? identityDocument;

  // Nom de fichier existant depuis la base
  final String? identityDocumentName;

  final Function(File?) onIdentityPicked;

  const Step1BParticulierForm({
    super.key,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.identityDocument,
    this.identityDocumentName,
    required this.onIdentityPicked,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(registerCategoriesProvider("agent"));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Étape 2 — Vérification d'identité",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        categoriesAsync.when(
          data: (categories) {
            return _styledDropdown(
              label: "Catégorie de compte",
              value: selectedCategoryId,
              items: categories
                  .map<DropdownMenuItem<String>>(
                    (c) => DropdownMenuItem(
                      value: c['id'].toString(),
                      child: Text(c['name']),
                    ),
                  )
                  .toList(),
              onChanged: onCategorySelected,
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, _) => Text("Erreur : $error"),
        ),

        const SizedBox(height: 20),

        UploadDocumentWidget(
          title: "Votre document d'identité",
          description: "Le fichier doit être une image ou un PDF.",
          initialFile: identityDocument,
          initialFileName: identityDocumentName, // nom existant affiché
          onFileSelected: onIdentityPicked,
        ),
      ],
    );
  }

  Widget _styledDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          border: InputBorder.none,
        ),
        items: items,
        onChanged: onChanged,
        validator: (v) => v == null ? "Champ requis" : null,
        icon: const Icon(Icons.arrow_drop_down),
        iconSize: 24,
      ),
    );
  }
}