import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/business/providers/reservation_provider.dart';
import 'package:mobile/data/models/bien_model.dart';
import 'package:mobile/presentation/theme/colors.dart';
import 'package:mobile/core/utils/whatsapp_utils.dart';
import '../../../business/providers/auth_controller_provider.dart';
import 'package:mobile/core/utils/reservation_whatsapp_message.dart';


class ReservationScreen extends ConsumerStatefulWidget {
  final BienModel bien;

  const ReservationScreen({super.key, required this.bien});

  @override
  ConsumerState<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends ConsumerState<ReservationScreen> {
  final _formKey = GlobalKey<FormState>();

  // -------- CLIENT --------
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // -------- SPÉCIFIQUE --------
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _visitDate;
  final _messageController = TextEditingController();
  final _placeController = TextEditingController();
  final _peopleController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    _placeController.dispose();
    _peopleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(reservationActionControllerProvider);
    final actionController =
        ref.read(reservationActionControllerProvider.notifier);
    final authState = ref.read(authControllerProvider);
    final userId = authState.user?.id;


    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Réservation",
          style: TextStyle(color: AppColors.textDark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ================= RÉSUMÉ BIEN =================
            Text(
              widget.bien.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              getCategoryLabel(widget.bien.category),
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              "${widget.bien.price.toStringAsFixed(0)} F • ${_getTransactionLabel(widget.bien.transactionType)}",
              style: const TextStyle(fontSize: 16),
            ),

            const Divider(height: 32),

            // ================= CLIENT =================
            _label("Nom et prénoms"),
            TextFormField(
              controller: _nameController,
              decoration: _input(),
              validator: _required,
            ),
            const SizedBox(height: 16),

            _label("Email"),
            TextFormField(
              controller: _emailController,
              decoration: _input(),
              validator: _required,
            ),
            const SizedBox(height: 16),

            _label("Téléphone (WhatsApp)"),
            TextFormField(
              controller: _phoneController,
              decoration: _input(hint: "+229 XXXXXXXX"),
              validator: _required,
            ),

            const SizedBox(height: 24),

            // ================= FORMULAIRE SPÉCIFIQUE =================
            _buildSpecificForm(),

            const SizedBox(height: 30),

            // ================= SUBMIT =================
            // SizedBox(
            //   width: double.infinity,
            //   child: ElevatedButton(
            //     onPressed: () async {
            //       if (!_formKey.currentState!.validate()) return;

            //       await reservationController.createReservation(
            //         bienId: int.parse(widget.bien.id),
            //         ownerId: widget.bien.ownerId,
            //         userId: null,
            //         clientName: _nameController.text,
            //         clientEmail: _emailController.text,
            //         clientPhone: _phoneController.text,
            //         category: widget.bien.category,
            //         transactionType: widget.bien.transactionType,
            //         reservationType: getReservationType(widget.bien.category),
            //         price: widget.bien.price,
            //         startDate: _startDate,
            //         endDate: _endDate,
            //         visitDate: _visitDate,
            //         message: _messageController.text.isEmpty
            //             ? null
            //             : _messageController.text,
            //       );

            //       if (!mounted) return;

            //       ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(
            //           content: Text("Réservation envoyée"),
            //           backgroundColor: AppColors.primary,
            //         ),
            //       );

            //       Navigator.pop(context);
            //     },
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: AppColors.primary,
            //       padding: const EdgeInsets.symmetric(vertical: 14),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(14),
            //       ),
            //     ),
            //     child: const Text(
            //       "Confirmer la réservation",
            //       style: TextStyle(color: Colors.white),
            //     ),
            //   ),
            // ),


            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: actionState.isLoading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;

                        try {
                          final reservation = await actionController.createReservation(
                            bienId: int.parse(widget.bien.id),
                            ownerId: widget.bien.ownerId,
                            userId: userId,
                            clientName: _nameController.text,
                            clientEmail: _emailController.text,
                            clientPhone: _phoneController.text,
                            category: widget.bien.category,
                            transactionType: widget.bien.transactionType,
                            reservationType:
                                getReservationType(widget.bien.category),
                            price: widget.bien.price,
                            startDate: _startDate,
                            endDate: _endDate,
                            visitDate: _visitDate,
                            message: _messageController.text.isEmpty
                                ? null
                                : _messageController.text,
                          );

                          // 🔥 MESSAGE WHATSAPP
                          final whatsappMessage =
                              ReservationWhatsappMessage.build(
                            bien: widget.bien,
                            clientName: _nameController.text,
                            clientPhone: _phoneController.text,
                            startDate: _startDate,
                            endDate: _endDate,
                            visitDate: _visitDate,
                            message: _messageController.text,
                          );

                          final phone = widget.bien.ownerWhatsapp;

                          if (phone.isNotEmpty) {
                            await WhatsAppUtils.sendMessage(
                              phone: phone,
                              message: whatsappMessage,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Numéro WhatsApp du propriétaire introuvable"),
                              ),
                            );
                          }


                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Réservation envoyée avec succès"),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Erreur : $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: actionState.isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Confirmer la réservation",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),

          ]),
        ),
      ),
    );
  }

  // ================= FORMULAIRES SPÉCIFIQUES =================
  Widget _buildSpecificForm() {
    switch (widget.bien.category) {
      case 'immobilier':
      case 'meuble':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label("Date de visite"),
            _datePicker("Choisir une date", (d) => _visitDate = d),
            const SizedBox(height: 16),
            _label("Message (optionnel)"),
            TextFormField(
              controller: _messageController,
              maxLines: 3,
              decoration: _input(),
            ),
          ],
        );

      case 'vehicule':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label("Dates de location"),
            Row(children: [
              Expanded(child: _datePicker("Début", (d) => _startDate = d)),
              const SizedBox(width: 12),
              Expanded(child: _datePicker("Fin", (d) => _endDate = d)),
            ]),
            const SizedBox(height: 16),
            _label("Lieu de récupération"),
            TextFormField(
              controller: _placeController,
              decoration: _input(),
            ),
          ],
        );

      case 'hebergement':
      case 'hotel':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label("Dates du séjour"),
            Row(children: [
              Expanded(child: _datePicker("Arrivée", (d) => _startDate = d)),
              const SizedBox(width: 12),
              Expanded(child: _datePicker("Départ", (d) => _endDate = d)),
            ]),
            const SizedBox(height: 16),
            _label("Nombre de personnes"),
            TextFormField(
              controller: _peopleController,
              keyboardType: TextInputType.number,
              decoration: _input(),
            ),
          ],
        );

      default:
        return const SizedBox();
    }
  }

  // ================= UI HELPERS (IDENTIQUES) =================
  Text _label(String text) =>
      Text(text, style: const TextStyle(fontWeight: FontWeight.w600));

  InputDecoration _input({String? hint}) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );

  Widget _datePicker(String label, Function(DateTime) onSelected) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (date != null) setState(() => onSelected(date));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label),
      ),
    );
  }

  String? _required(String? v) =>
      v == null || v.isEmpty ? "Champ requis" : null;

  String _getTransactionLabel(String type) =>
      type == 'sale' ? 'Vente' : 'Location';

  String getReservationType(String category) {
    switch (category) {
      case 'immobilier':
        return 'visit';
      case 'vehicule':
      case 'meuble':
        return 'rental';
      case 'hebergement':
      case 'hotel':
        return 'stay';
      default:
        return 'visit';
    }
  }

  String getCategoryLabel(String category) {
    const labels = {
      'immobilier': 'Immobilier',
      'vehicule': 'Véhicule',
      'meuble': 'Meuble',
      'hotel': 'Hôtel',
      'hebergement': 'Hébergement',
    };
    return labels[category] ?? category;
  }
}



















// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile/business/providers/reservation_provider.dart';
// import 'package:mobile/data/models/bien_model.dart';
// import 'package:mobile/presentation/theme/colors.dart';

// class ReservationScreen extends ConsumerStatefulWidget {
//   final BienModel bien;

//   const ReservationScreen({super.key, required this.bien});

//   @override
//   ConsumerState<ReservationScreen> createState() => _ReservationScreenState();
// }

// class _ReservationScreenState extends ConsumerState<ReservationScreen> {
//   final _formKey = GlobalKey<FormState>();

//   // Formulaire client
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();

//   // Formulaire spécifique
//   DateTime? _startDate;
//   DateTime? _endDate;
//   DateTime? _visitDate;
//   final _messageController = TextEditingController();
//   final _placeController = TextEditingController();
//   final _peopleController = TextEditingController();

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _messageController.dispose();
//     _placeController.dispose();
//     _peopleController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final reservationController =
//         ref.read(reservationControllerProvider.notifier);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Réservation",
//           style: TextStyle(color: AppColors.textDark),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: AppColors.textDark),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             // ================= RÉSUMÉ BIEN =================
//             Text(
//               widget.bien.title,
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               getCategoryLabel(widget.bien.category),
//               style: const TextStyle(color: Colors.grey),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               "${widget.bien.price.toStringAsFixed(0)} F • ${_getTransactionLabel(widget.bien.transactionType)}",
//               style: const TextStyle(fontSize: 16),
//             ),

//             const Divider(height: 32),

//             // ================= CLIENT =================
//             _label("Nom et prénoms"),
//             TextFormField(
//               controller: _nameController,
//               decoration: _input(),
//               validator: _required,
//             ),
//             const SizedBox(height: 16),

//             _label("Email"),
//             TextFormField(
//               controller: _emailController,
//               decoration: _input(),
//               validator: _required,
//             ),
//             const SizedBox(height: 16),

//             _label("Téléphone (WhatsApp)"),
//             TextFormField(
//               controller: _phoneController,
//               decoration: _input(hint: "+229 XXXXXXXX"),
//               validator: _required,
//             ),

//             const Divider(height: 32),

//             // ================= FORMULAIRE SPÉCIFIQUE =================
//             _buildSpecificForm(),

//             const SizedBox(height: 30),

//             // ================= SUBMIT =================
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () async {
//                   if (_formKey.currentState!.validate()) {
//                     await reservationController.createReservation(
//                       bienId: int.parse(widget.bien.id),
//                       ownerId: widget.bien.ownerId,
//                       userId: null,
//                       clientName: _nameController.text,
//                       clientEmail: _emailController.text,
//                       clientPhone: _phoneController.text,
//                       category: widget.bien.category,
//                       transactionType: widget.bien.transactionType,
//                       reservationType:
//                           getReservationType(widget.bien.category),
//                       price: widget.bien.price,
//                       startDate: _startDate,
//                       endDate: _endDate,
//                       visitDate: _visitDate,
//                       message: _messageController.text.isEmpty
//                           ? null
//                           : _messageController.text,
//                     );

//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                           content: Text("Réservation envoyée !")),
//                     );

//                     Navigator.pop(context);
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                 ),
//                 child: const Text(
//                   "Confirmer la réservation",
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ),
//           ]),
//         ),
//       ),
//     );
//   }

//   // ================= FORMULAIRES SPÉCIFIQUES =================
//   Widget _buildSpecificForm() {
//     switch (widget.bien.category) {
//       case 'immobilier':
//       case 'meuble':
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _label("Date de visite"),
//             _buildDatePicker(
//               label: "Choisir une date",
//               onDateSelected: (d) => setState(() => _visitDate = d),
//             ),
//             const SizedBox(height: 16),
//             _label("Message (optionnel)"),
//             TextFormField(
//               controller: _messageController,
//               maxLines: 3,
//               decoration: _input(),
//             ),
//           ],
//         );

//       case 'vehicule':
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _label("Dates de location"),
//             Row(children: [
//               Expanded(
//                 child: _buildDatePicker(
//                   label: "Début",
//                   onDateSelected: (d) => setState(() => _startDate = d),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _buildDatePicker(
//                   label: "Fin",
//                   onDateSelected: (d) => setState(() => _endDate = d),
//                 ),
//               ),
//             ]),
//             const SizedBox(height: 16),
//             _label("Lieu de récupération"),
//             TextFormField(
//               controller: _placeController,
//               decoration: _input(),
//             ),
//           ],
//         );

//       case 'hebergement':
//       case 'hotel':
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _label("Dates du séjour"),
//             Row(children: [
//               Expanded(
//                 child: _buildDatePicker(
//                   label: "Arrivée",
//                   onDateSelected: (d) => setState(() => _startDate = d),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _buildDatePicker(
//                   label: "Départ",
//                   onDateSelected: (d) => setState(() => _endDate = d),
//                 ),
//               ),
//             ]),
//             const SizedBox(height: 16),
//             _label("Nombre de personnes"),
//             TextFormField(
//               controller: _peopleController,
//               keyboardType: TextInputType.number,
//               decoration: _input(),
//             ),
//           ],
//         );

//       default:
//         return const SizedBox.shrink();
//     }
//   }

//   // ================= UI HELPERS =================
//   Widget _label(String text) => Padding(
//         padding: const EdgeInsets.only(bottom: 6),
//         child: Text(
//           text,
//           style: const TextStyle(fontWeight: FontWeight.w600),
//         ),
//       );

//   InputDecoration _input({String? hint}) => InputDecoration(
//         hintText: hint,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//       );

//   Widget _buildDatePicker({
//     required String label,
//     required Function(DateTime) onDateSelected,
//   }) {
//     return GestureDetector(
//       onTap: () async {
//         final date = await showDatePicker(
//           context: context,
//           initialDate: DateTime.now(),
//           firstDate: DateTime.now(),
//           lastDate: DateTime(2100),
//         );
//         if (date != null) onDateSelected(date);
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey.shade400),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Text(label),
//       ),
//     );
//   }

//   String? _required(String? value) {
//     if (value == null || value.isEmpty) {
//       return "Champ obligatoire";
//     }
//     return null;
//   }


//   String _getTransactionLabel(String type) {
//     switch (type) {
//       case 'sale':
//         return 'Vente';
//       case 'rent':
//         return 'Location';
//       default:
//         return type;
//     }
//   }

//   String getReservationType(String category) {
//     switch (category) {
//       case 'immobilier':
//         return 'visit';
//       case 'vehicule':
//       case 'meuble':
//         return 'rental';
//       case 'hebergement':
//       case 'hotel':
//         return 'stay';
//       default:
//         return 'visit';
//     }
//   }

//   String getCategoryLabel(String category) {
//     switch (category) {
//       case 'immobilier':
//         return 'Immobilier';
//       case 'vehicule':
//         return 'Véhicule';
//       case 'meuble':
//         return 'Meuble';
//       case 'hebergement':
//         return 'Hébergement';
//       case 'hotel':
//         return 'Hôtel';
//       default:
//         return category;
//     }
//   }
// }










// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile/business/providers/reservation_provider.dart';
// import 'package:mobile/data/models/bien_model.dart';

// class ReservationScreen extends ConsumerStatefulWidget {
//   final BienModel bien;

//   const ReservationScreen({super.key, required this.bien});

//   @override
//   ConsumerState<ReservationScreen> createState() => _ReservationScreenState();
// }

// class _ReservationScreenState extends ConsumerState<ReservationScreen> {
//   final _formKey = GlobalKey<FormState>();

//   // Formulaire client
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();

//   // Formulaire spécifique
//   DateTime? _startDate;
//   DateTime? _endDate;
//   DateTime? _visitDate;
//   final TextEditingController _messageController = TextEditingController();
//   final TextEditingController _placeController = TextEditingController();
//   final TextEditingController _peopleController = TextEditingController();

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _messageController.dispose();
//     _placeController.dispose();
//     _peopleController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final reservationController = ref.read(reservationControllerProvider.notifier);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Réservation'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 1,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // ---------------- Résumé du bien ----------------
//               Text(
//                 widget.bien.title,
//                 style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 getCategoryLabel(widget.bien.category),
//                 style: const TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 "${widget.bien.price.toStringAsFixed(0)} F • ${_getTransactionLabel(widget.bien.transactionType)}",
//                 style: const TextStyle(fontSize: 16, color: Colors.black87),
//               ),
//               const Divider(height: 32, thickness: 1),

//               // ---------------- Formulaire client ----------------
//               const Text(
//                 "Informations du client",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(
//                   labelText: "Nom et prénoms",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) => (value == null || value.isEmpty) ? "Champ obligatoire" : null,
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(
//                   labelText: "Email",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) => (value == null || value.isEmpty) ? "Champ obligatoire" : null,
//               ),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _phoneController,
//                 decoration: const InputDecoration(
//                   labelText: "Téléphone (WhatsApp)",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) => (value == null || value.isEmpty) ? "Champ obligatoire" : null,
//               ),
//               const Divider(height: 32, thickness: 1),

//               // ---------------- Formulaire spécifique ----------------
//               _buildSpecificForm(),

//               const SizedBox(height: 32),

//               // ---------------- Bouton confirmer ----------------
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     if (_formKey.currentState!.validate()) {
//                       await reservationController.createReservation(
//                         bienId: int.parse(widget.bien.id),
//                         ownerId: widget.bien.ownerId,
//                         userId: null, // TODO : récupérer userId si connecté
//                         clientName: _nameController.text,
//                         clientEmail: _emailController.text,
//                         clientPhone: _phoneController.text,
//                         category: widget.bien.category,
//                         transactionType: widget.bien.transactionType,
//                         reservationType: getReservationType(widget.bien.category),
//                         price: widget.bien.price,
//                         startDate: _startDate,
//                         endDate: _endDate,
//                         visitDate: _visitDate,
//                         message: _messageController.text.isEmpty ? null : _messageController.text,
//                       );

//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text("Réservation envoyée !")),
//                       );

//                       Navigator.pop(context);
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   child: const Text(
//                     "Confirmer la réservation",
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ---------------- Formulaire spécifique selon catégorie ----------------
//   Widget _buildSpecificForm() {
//     switch (widget.bien.category) {
//       case 'immobilier':
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("Date de visite"),
//             const SizedBox(height: 6),
//             _buildDatePicker(
//               label: "Choisir la date",
//               onDateSelected: (date) => setState(() => _visitDate = date),
//             ),
//             const SizedBox(height: 12),
//             TextFormField(
//               controller: _messageController,
//               decoration: const InputDecoration(
//                 labelText: "Message (optionnel)",
//                 border: OutlineInputBorder(),
//               ),
//               maxLines: 3,
//             ),
//           ],
//         );

//       case 'vehicule':
//       case 'meuble':
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("Dates de location"),
//             const SizedBox(height: 6),
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildDatePicker(
//                     label: "Début",
//                     onDateSelected: (date) => setState(() => _startDate = date),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildDatePicker(
//                     label: "Fin",
//                     onDateSelected: (date) => setState(() => _endDate = date),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             TextFormField(
//               controller: _placeController,
//               decoration: const InputDecoration(
//                 labelText: "Lieu de récupération",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ],
//         );

//       case 'hebergement':
//       case 'hotel':
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("Dates du séjour"),
//             const SizedBox(height: 6),
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildDatePicker(
//                     label: "Arrivée",
//                     onDateSelected: (date) => setState(() => _startDate = date),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildDatePicker(
//                     label: "Départ",
//                     onDateSelected: (date) => setState(() => _endDate = date),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             TextFormField(
//               controller: _peopleController,
//               decoration: const InputDecoration(
//                 labelText: "Nombre de personnes",
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.number,
//             ),
//           ],
//         );

//       default:
//         return const SizedBox.shrink();
//     }
//   }

//   // ---------------- Helper pour picker date ----------------
//   Widget _buildDatePicker({required String label, required Function(DateTime) onDateSelected}) {
//     return GestureDetector(
//       onTap: () async {
//         final date = await showDatePicker(
//           context: context,
//           initialDate: DateTime.now(),
//           firstDate: DateTime.now(),
//           lastDate: DateTime(2100),
//         );
//         if (date != null) onDateSelected(date);
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey.shade400),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Text(label),
//       ),
//     );
//   }

//   // ---------------- Helpers UI ----------------
//   String _getTransactionLabel(String type) {
//     switch (type) {
//       case 'sale':
//         return 'Vente';
//       case 'rent':
//         return 'Location';
//       case 'booking':
//         return 'Réservation';
//       default:
//         return type;
//     }
//   }

//   String getReservationType(String category) {
//     switch (category) {
//       case 'immobilier':
//         return 'visit';
//       case 'vehicule':
//       case 'meuble':
//         return 'rental';
//       case 'hebergement':
//       case 'hotel':
//         return 'stay';
//       default:
//         return 'visit';
//     }
//   }

//   String getCategoryLabel(String category) {
//     switch (category) {
//       case 'immobilier':
//         return 'Immobilier';
//       case 'vehicule':
//         return 'Véhicule';
//       case 'meuble':
//         return 'Meuble';
//       case 'hebergement':
//         return 'Hébergement';
//       case 'hotel':
//         return 'Hôtel';
//       default:
//         return category;
//     }
//   }


// }
