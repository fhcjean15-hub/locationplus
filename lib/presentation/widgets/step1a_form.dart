import 'package:flutter/material.dart';

class Step1AForm extends StatelessWidget {
  final TextEditingController ifuController;
  final TextEditingController addressController;
  final TextEditingController villeController; // 👈 NEW

  const Step1AForm({
    super.key,
    required this.ifuController,
    required this.addressController,
    required this.villeController, // 👈 NEW
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Étape 1 — Informations personnelles",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),

        // IFU
        _styledField(
          label: "IFU",
          controller: ifuController,
        ),

        const SizedBox(height: 16),

        // Adresse
        _styledField(
          label: "Adresse",
          controller: addressController,
        ),

        const SizedBox(height: 16),

        // Ville (NEW)
        _styledField(
          label: "Ville",
          controller: villeController,
        ),
      ],
    );
  }

  Widget _styledField({
    required String label,
    required TextEditingController controller,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextFormField(
        controller: controller,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          border: InputBorder.none,
        ),
        validator: (value) =>
            value == null || value.isEmpty ? "Champ requis" : null,
      ),
    );
  }
}




// import 'package:flutter/material.dart';

// class Step1AForm extends StatelessWidget {
//   final TextEditingController ifuController;
//   final TextEditingController addressController;

//   const Step1AForm({
//     super.key,
//     required this.ifuController,
//     required this.addressController,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Étape 1 — Informations personnelles",
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 20),

//         // IFU
//         _styledField(
//           label: "IFU",
//           controller: ifuController,
//         ),

//         const SizedBox(height: 16),

//         // Adresse
//         _styledField(
//           label: "Adresse",
//           controller: addressController,
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
