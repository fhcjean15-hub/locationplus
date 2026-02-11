import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/business/providers/register_provider.dart';
import 'upload_document_widget.dart';

class Step1BEntrepriseForm extends ConsumerWidget {
  final String? selectedCategoryId;
  final Function(String?) onCategorySelected;

  // Fichiers choisis par l'utilisateur
  final File? identityDocument;
  final File? rccmDocument;

  // Noms de fichiers existants depuis la base
  final String? identityDocumentName;
  final String? rccmDocumentName;

  final Function(File?) onIdentityPicked;
  final Function(File?) onRccmPicked;

  const Step1BEntrepriseForm({
    super.key,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.identityDocument,
    this.identityDocumentName,
    required this.rccmDocument,
    this.rccmDocumentName,
    required this.onIdentityPicked,
    required this.onRccmPicked,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(registerCategoriesProvider("agence"));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Étape 2 — Documents de l’entreprise",
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
          title: "Document d'identité du responsable",
          description: "Le fichier doit être une image ou un PDF.",
          initialFile: identityDocument,
          initialFileName: identityDocumentName, // nom existant affiché
          onFileSelected: onIdentityPicked,
        ),

        const SizedBox(height: 20),

        UploadDocumentWidget(
          title: "Registre de commerce (RCCM)",
          description: "Image ou PDF autorisé.",
          initialFile: rccmDocument,
          initialFileName: rccmDocumentName, // nom existant affiché
          onFileSelected: onRccmPicked,
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


// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile/business/providers/register_provider.dart';
// import 'upload_document_widget.dart';

// class Step1BEntrepriseForm extends ConsumerWidget {
//   final String? selectedCategoryId;
//   final Function(String?) onCategorySelected;

//   final File? identityDocument;
//   final File? rccmDocument;
//   final Function(File?) onIdentityPicked;
//   final Function(File?) onRccmPicked;

//   const Step1BEntrepriseForm({
//     super.key,
//     required this.selectedCategoryId,
//     required this.onCategorySelected,
//     required this.identityDocument,
//     required this.rccmDocument,
//     required this.onIdentityPicked,
//     required this.onRccmPicked,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final categoriesAsync = ref.watch(registerCategoriesProvider("agence"));

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Étape 2 — Documents de l’entreprise",
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 20),

//         categoriesAsync.when(
//           data: (categories) {
//             return _styledDropdown(
//               label: "Catégorie de compte",
//               value: selectedCategoryId,
//               items: categories
//                   .map<DropdownMenuItem<String>>(
//                     (c) => DropdownMenuItem(
//                       value: c['id'].toString(),
//                       child: Text(c['name']),
//                     ),
//                   )
//                   .toList(),
//               onChanged: onCategorySelected,
//             );
//           },
//           loading: () => const CircularProgressIndicator(),
//           error: (error, _) => Text("Erreur : $error"),
//         ),

//         const SizedBox(height: 20),

//         UploadDocumentWidget(
//           title: "Document d'identité du responsable",
//           description: "Le fichier doit être une image ou un PDF.",
//           initialFile: identityDocument,
//           onFileSelected: onIdentityPicked,
//         ),

//         const SizedBox(height: 20),

//         UploadDocumentWidget(
//           title: "Registre de commerce (RCCM)",
//           description: "Image ou PDF autorisé.",
//           initialFile: rccmDocument,
//           onFileSelected: onRccmPicked,
//         ),
//       ],
//     );
//   }

//   Widget _styledDropdown({
//     required String label,
//     required String? value,
//     required List<DropdownMenuItem<String>> items,
//     required Function(String?) onChanged,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF7F9FB),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: DropdownButtonFormField<String>(
//         value: value,
//         isExpanded: true, // ← important pour que la flèche ne chevauche pas le texte
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: const TextStyle(color: Colors.black),
//           border: InputBorder.none, // ← supprime la ligne de base
//         ),
//         items: items,
//         onChanged: onChanged,
//         validator: (v) => v == null ? "Champ requis" : null,
//         icon: const Icon(Icons.arrow_drop_down), // flèche personnalisée si besoin
//         iconSize: 24,
//       ),
//     );
//   }

// }




// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'upload_document_widget.dart';
// import 'package:mobile/business/providers/register_provider.dart';

// class Step1BEntrepriseForm extends ConsumerWidget {
//   final String? selectedCategoryId;
//   final Function(String?) onCategorySelected;

//   final File? identityDocument;
//   final File? rccmDocument;
//   final Function(File?) onIdentityPicked;
//   final Function(File?) onRccmPicked;

//   const Step1BEntrepriseForm({
//     super.key,
//     required this.selectedCategoryId,
//     required this.onCategorySelected,
//     required this.identityDocument,
//     required this.rccmDocument,
//     required this.onIdentityPicked,
//     required this.onRccmPicked,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final categoriesAsync = ref.watch(registerCategoriesProvider("agence"));

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Étape 2 — Documents de l’entreprise",
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 20),

//         // -------------------- Dropdown catégories --------------------
//         categoriesAsync.when(
//           data: (categories) {
//             return _styledDropdown(
//               label: "Catégorie de compte",
//               value: selectedCategoryId,
//               items: categories
//                   .map<DropdownMenuItem<String>>(
//                     (c) => DropdownMenuItem(
//                       value: c['id'],
//                       child: Text(c['name']),
//                     ),
//                   )
//                   .toList(),
//               onChanged: onCategorySelected,
//             );
//           },
//           loading: () => const CircularProgressIndicator(),
//           error: (e, _) => Text("Erreur : $e"),
//         ),

//         const SizedBox(height: 20),

//         UploadDocumentWidget(
//           title: "Document d'identité du responsable",
//           description: "Le fichier doit être une image ou un PDF.",
//           initialFile: identityDocument,
//           onFileSelected: onIdentityPicked,
//         ),

//         const SizedBox(height: 20),

//         UploadDocumentWidget(
//           title: "Registre de commerce (RCCM)",
//           description: "Image ou PDF autorisé.",
//           initialFile: rccmDocument,
//           onFileSelected: onRccmPicked,
//         ),
//       ],
//     );
//   }

//   Widget _styledDropdown({
//     required String label,
//     required String? value,
//     required List<DropdownMenuItem<String>> items,
//     required Function(String?) onChanged,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF7F9FB),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: DropdownButtonFormField<String>(
//         value: value,
//         decoration: InputDecoration(
//           labelText: label,
//           border: InputBorder.none,
//         ),
//         items: items,
//         onChanged: onChanged,
//         validator: (value) =>
//             value == null ? "Veuillez choisir une catégorie" : null,
//       ),
//     );
//   }
// }



// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'upload_document_widget.dart';

// class Step1BEntrepriseForm extends StatelessWidget {
//   final TextEditingController numberController;
//   final File? identityDocument;
//   final File? rccmDocument;
//   final Function(File?) onIdentityPicked;
//   final Function(File?) onRccmPicked;

//   const Step1BEntrepriseForm({
//     super.key,
//     required this.numberController,
//     required this.identityDocument,
//     required this.rccmDocument,
//     required this.onIdentityPicked,
//     required this.onRccmPicked,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Étape 2 — Documents de l’entreprise",
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 20),

//         // Numéro fonctionnel
//         _styledField(
//           label: "Numéro fonctionnel",
//           controller: numberController,
//         ),

//         const SizedBox(height: 20),

//         // Upload identité
//         UploadDocumentWidget(
//           title: "Document d'identité du responsable",
//           description: "Le fichier doit être une image ou un PDF.",
//           initialFile: identityDocument,
//           onFileSelected: onIdentityPicked,
//         ),

//         const SizedBox(height: 20),

//         // Upload RCCM
//         UploadDocumentWidget(
//           title: "Registre de commerce (RCCM)",
//           description: "Image ou PDF autorisé.",
//           initialFile: rccmDocument,
//           onFileSelected: onRccmPicked,
//         ),
//       ],
//     );
//   }

//   Widget _styledField({
//     required String label,
//     required TextEditingController controller,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF7F9FB),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: TextFormField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: label,
//           border: InputBorder.none,
//         ),
//         validator: (value) =>
//             value == null || value.isEmpty ? "Champ requis" : null,
//       ),
//     );
//   }
// }
