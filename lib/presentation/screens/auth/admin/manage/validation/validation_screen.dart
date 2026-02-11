import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/business/providers/auth_controller_provider.dart';
import 'package:mobile/data/models/user_model.dart';
import 'package:mobile/presentation/screens/pdf/pdf_viewer_screen.dart';
import '../../../../../theme/colors.dart';
import 'package:photo_view/photo_view.dart';

class ValidationScreen extends ConsumerStatefulWidget {
  final User user;

  const ValidationScreen({super.key, required this.user});

  @override
  ConsumerState<ValidationScreen> createState() => _ValidationScreenState();
}

class _ValidationScreenState extends ConsumerState<ValidationScreen> {
  bool isReexamination = false;
  Map<String, dynamic>? lastNotification;
  
  final baseUrl = "https://api-location-plus.lamadonebenin.com/storage/";
  

  bool isLoadingValidate = false;
  bool isLoadingReject = false;

  @override
  void initState() {
    super.initState();
    _loadLastVerification();
  }

  Future<void> _loadLastVerification() async {
    final controller = ref.read(authControllerProvider.notifier);

    await controller.loadVerificationStatus(widget.user.id);

    final state = ref.read(authControllerProvider);
    if (state.hasVerification == true) {
      setState(() {
        isReexamination = true;
        lastNotification = state.lastVerificationNotification;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEntreprise = widget.user.accountType == "entreprise";
    final fullName = widget.user.fullName ?? "";
    final companyName = widget.user.companyName ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Validation Utilisateur"),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nom : ${isEntreprise ? "$companyName ($fullName)" : fullName}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _infoRow("Email", widget.user.email),
            if (widget.user.phone != null && widget.user.phone!.isNotEmpty)
              _infoRow("Téléphone", widget.user.phone!),
            if (isEntreprise &&
                widget.user.ifu != null &&
                widget.user.ifu!.isNotEmpty)
              _infoRow("IFU", widget.user.ifu!),
            if (widget.user.address != null && widget.user.address!.isNotEmpty)
              _infoRow("Adresse", widget.user.address!),
            if (widget.user.ville != null && widget.user.ville!.isNotEmpty)
              _infoRow("Ville", widget.user.ville!),
            const SizedBox(height: 16),
            Text(
              "Documents à vérifier :",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._buildDocuments(context, widget.user, isEntreprise),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: widget.user.verifiedDocuments
            ? Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  "Ce compte est validé",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              )
            : isReexamination
            ? ElevatedButton(
                onPressed: () {
                  setState(() {
                    isReexamination = false;
                    lastNotification = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Modifier l'examen",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showNoteModal(context, rejected: true),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Rejeter",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoadingValidate
                          ? null
                          : () => _validateUser(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: AppColors.textLight),
                        ),
                      ),
                      child: isLoadingValidate
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Valider",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label : ",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(color: AppColors.textDark),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDocuments(
    BuildContext context,
    User user,
    bool isEntreprise,
  ) {
    final urls = user.documentsUrls ?? [];
    if (urls.isEmpty) return [const Text("Aucun document disponible.")];

    return urls.map((url) {
      final isPdf = url.toLowerCase().endsWith(".pdf");
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () {
            if (isPdf) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PdfViewerScreen(pdfUrl: baseUrl + url)),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    backgroundColor: Colors.black,
                    appBar: AppBar(backgroundColor: Colors.black),
                    body: PhotoView(imageProvider: NetworkImage(baseUrl + url)),
                  ),
                ),
              );
            }
          },
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade200,
            ),
            child: isPdf
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.picture_as_pdf, size: 40, color: Colors.red),
                        SizedBox(height: 6),
                        Text(
                          "PDF",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(baseUrl + url, fit: BoxFit.cover),
                  ),
          ),
        ),
      );
    }).toList();
  }

  void _showNoteModal(BuildContext context, {required bool rejected}) {
    final _controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    rejected
                        ? "Rejeter l'utilisateur"
                        : "Valider l'utilisateur",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Ajouter une note (optionnel)",
                      filled: true,
                      fillColor: Color(0xFFF7F9FB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height:
                        48, // fixe la hauteur du bouton pour garder la taille
                    child: ElevatedButton(
                      onPressed: isLoadingReject
                          ? null
                          : () async {
                              setModalState(() {
                                isLoadingReject = true;
                              });
                              await _submitNotification(
                                ctx,
                                rejected: rejected,
                                note: _controller.text,
                              );
                              setModalState(() {
                                isLoadingReject = false;
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: rejected ? Colors.red : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: rejected ? Colors.red : AppColors.textLight,
                          ),
                        ),
                      ),
                      child: isLoadingReject
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: rejected
                                    ? Colors.white
                                    : AppColors.primary,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              rejected ? "Rejeter" : "Valider",
                              style: TextStyle(
                                color: rejected
                                    ? Colors.white
                                    : AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // Future<void> _validateUser(BuildContext context) async {
  //   setState(() {
  //     isLoadingValidate = true;
  //   });

  //   final controller = ref.read(authControllerProvider.notifier);

  //   final notificationData = {"type": "compte_validé", "payload": null};

  //   if (isReexamination && lastNotification != null) {
  //     await controller.updateNotification(
  //       notificationId: lastNotification!['id'],
  //       type: notificationData['type'] as String,
  //       payload: notificationData['payload'] as Map<String, dynamic>?,
  //       read: false,
  //     );
  //   } else {
  //     await controller.postNotification(
  //       userId: widget.user.id,
  //       type: notificationData['type'] as String,
  //       payload: notificationData['payload'] as Map<String, dynamic>?,
  //     );
  //   }

  //   setState(() {
  //     isLoadingValidate = false;
  //     isReexamination = true;
  //   });
  // }

  Future<void> _validateUser(BuildContext context) async {
    setState(() {
      isLoadingValidate = true;
    });

    final controller = ref.read(authControllerProvider.notifier);

    final notificationData = {"type": "compte_validé", "payload": null};

    try {
      if (isReexamination && lastNotification != null) {
        await controller.updateNotification(
          notificationId: lastNotification!['id'],
          type: notificationData['type'] as String,
          payload: notificationData['payload'] as Map<String, dynamic>?,
          read: false,
        );
      } else {
        await controller.postNotification(
          userId: widget.user.id,
          type: notificationData['type'] as String,
          payload: notificationData['payload'] as Map<String, dynamic>?,
        );
      }

      // ✅ Snackbar de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Le compte a été validé avec succès."),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      setState(() {
        isLoadingValidate = false;
        isReexamination = true;
      });
    } catch (e) {
      // Snackbar d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Une erreur est survenue. Veuillez réessayer."),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );

      setState(() {
        isLoadingValidate = false;
      });
    }
  }

  Future<void> _submitNotification(
    BuildContext ctx, {
    required bool rejected,
    required String note,
  }) async {
    final controller = ref.read(authControllerProvider.notifier);

    final payload = rejected ? {"titre": "Manque d'informations", "note": note} : null;
    final type = rejected ? "compte_rejeté" : "compte_validé";

    try {
      if (isReexamination && lastNotification != null) {
        await controller.updateNotification(
          notificationId: lastNotification!['id'],
          type: type,
          payload: payload,
          read: false,
        );
      } else {
        await controller.postNotification(
          userId: widget.user.id,
          type: type,
          payload: payload,
        );
      }

      // ✅ Après succès : montrer le Snackbar
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(
            rejected
                ? "Le compte a été rejeté avec succès."
                : "Le compte a été validé avec succès.",
          ),
          backgroundColor: rejected ? Colors.red : Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      setState(() {
        isReexamination = true;
      });

      Navigator.pop(ctx); // fermer le modal
    } catch (e) {
      // Optionnel : Snackbar d'erreur
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text("Une erreur est survenue. Veuillez réessayer."),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

}




















// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile/business/providers/auth_controller_provider.dart';
// import 'package:mobile/data/models/user_model.dart';
// import 'package:mobile/presentation/screens/pdf/pdf_viewer_screen.dart';
// import '../../../../../theme/colors.dart';
// import 'package:photo_view/photo_view.dart';

// class ValidationScreen extends ConsumerStatefulWidget {
//   final User user;

//   const ValidationScreen({super.key, required this.user});

//   @override
//   ConsumerState<ValidationScreen> createState() => _ValidationScreenState();
// }

// class _ValidationScreenState extends ConsumerState<ValidationScreen> {
//   bool isReexamination = false;
//   Map<String, dynamic>? lastNotification;

//   @override
//   void initState() {
//     super.initState();
//     _loadLastVerification();
//   }

//   Future<void> _loadLastVerification() async {
//     final controller = ref.read(authControllerProvider.notifier);

//     await controller.loadVerificationStatus(widget.user.id);

//     final state = ref.read(authControllerProvider); // lecture du state mis à jour
//     if (state.hasVerification == true) {
//       setState(() {
//         isReexamination = true;
//         lastNotification = state.lastVerificationNotification;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isEntreprise = widget.user.accountType == "entreprise";
//     final fullName = widget.user.fullName ?? "";
//     final companyName = widget.user.companyName ?? "";

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Validation Utilisateur"),
//         backgroundColor: Colors.white,
//         foregroundColor: AppColors.textDark,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Nom : ${isEntreprise ? "$companyName ($fullName)" : fullName}",
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
//             _infoRow("Email", widget.user.email),
//             if (widget.user.phone != null && widget.user.phone!.isNotEmpty)
//               _infoRow("Téléphone", widget.user.phone!),
//             if (isEntreprise && widget.user.ifu != null && widget.user.ifu!.isNotEmpty)
//               _infoRow("IFU", widget.user.ifu!),
//             if (widget.user.address != null && widget.user.address!.isNotEmpty)
//               _infoRow("Adresse", widget.user.address!),
//             if (widget.user.ville != null && widget.user.ville!.isNotEmpty)
//               _infoRow("Ville", widget.user.ville!),
//             const SizedBox(height: 16),
//             Text(
//               "Documents à vérifier :",
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
//             ..._buildDocuments(context, widget.user, isEntreprise),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(16),
//         child: widget.user.verifiedDocuments
//             ? Container(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   color: Colors.green.shade50,
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: const Text(
//                   "Ce compte est validé",
//                   style: TextStyle(
//                     color: Colors.green,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//               )
//             : isReexamination
//                 ? ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         isReexamination = false;
//                         lastNotification = null;
//                       });
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                     ),
//                     child: const Text(
//                       "Modifier l'examen",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   )
//                 : Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton(
//                           onPressed: () => _showNoteModal(context, rejected: true),
//                           style: OutlinedButton.styleFrom(
//                             side: const BorderSide(color: Colors.red),
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14),
//                             ),
//                           ),
//                           child: const Text(
//                             "Rejeter",
//                             style: TextStyle(
//                               color: Colors.red,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () => _validateUser(context),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14),
//                               side: BorderSide(color: AppColors.textLight),
//                             ),
//                           ),
//                           child: Text(
//                             "Valider",
//                             style: TextStyle(
//                               color: AppColors.primary,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//       ),
//     );
//   }

//   Widget _infoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: RichText(
//         text: TextSpan(
//           children: [
//             TextSpan(
//               text: "$label : ",
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.textDark,
//               ),
//             ),
//             TextSpan(
//               text: value,
//               style: const TextStyle(color: AppColors.textDark),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildDocuments(BuildContext context, User user, bool isEntreprise) {
//     final urls = user.documentsUrls ?? [];
//     if (urls.isEmpty) {
//       return [const Text("Aucun document disponible.")];
//     }
//     return urls.map((url) {
//       final isPdf = url.toLowerCase().endsWith(".pdf");
//       return Padding(
//         padding: const EdgeInsets.only(bottom: 12),
//         child: GestureDetector(
//           onTap: () {
//             if (isPdf) {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => PdfViewerScreen(pdfUrl: url)),
//               );
//             } else {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => Scaffold(
//                     backgroundColor: Colors.black,
//                     appBar: AppBar(backgroundColor: Colors.black),
//                     body: PhotoView(imageProvider: NetworkImage(url)),
//                   ),
//                 ),
//               );
//             }
//           },
//           child: Container(
//             height: 120,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               color: Colors.grey.shade200,
//             ),
//             child: isPdf
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: const [
//                         Icon(Icons.picture_as_pdf, size: 40, color: Colors.red),
//                         SizedBox(height: 6),
//                         Text(
//                           "PDF",
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                   )
//                 : ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: Image.network(url, fit: BoxFit.cover),
//                   ),
//           ),
//         ),
//       );
//     }).toList();
//   }

//   void _showNoteModal(BuildContext context, {required bool rejected}) {
//     final _controller = TextEditingController();
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (ctx) {
//         return Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(ctx).viewInsets.bottom,
//             left: 16,
//             right: 16,
//             top: 16,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 rejected ? "Rejeter l'utilisateur" : "Valider l'utilisateur",
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: _controller,
//                 maxLines: 3,
//                 decoration: const InputDecoration(
//                   hintText: "Ajouter une note (optionnel)",
//                   filled: true,
//                   fillColor: Color(0xFFF7F9FB),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(12)),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () => _submitNotification(ctx, rejected: rejected, note: _controller.text),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: rejected ? Colors.red : Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       side: BorderSide(color: rejected ? Colors.red : AppColors.textLight),
//                     ),
//                   ),
//                   child: Text(
//                     rejected ? "Rejeter" : "Valider",
//                     style: TextStyle(
//                       color: rejected ? Colors.white : AppColors.primary,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _validateUser(BuildContext context) async {
//     final controller = ref.read(authControllerProvider.notifier);

//     final notificationData = {
//       "type": "compte_validé",
//       "payload": null,
//     };

//     if (isReexamination && lastNotification != null) {
//       await controller.updateNotification(
//         notificationId: lastNotification!['id'],
//         type: notificationData['type'] as String,
//         payload: notificationData['payload'] as Map<String, dynamic>?,
//         read: false,
//       );
//     } else {
//       await controller.postNotification(
//         userId: widget.user.id,
//         type: notificationData['type'] as String,
//         payload: notificationData['payload'] as Map<String, dynamic>?,
//       );
//     }

//     setState(() {
//       isReexamination = true;
//     });
//   }

//   Future<void> _submitNotification(BuildContext ctx, {required bool rejected, required String note}) async {
//     final controller = ref.read(authControllerProvider.notifier);

//     final payload = rejected ? {"titre": "Manque d'informations'", "note": note} : null;
//     final type = rejected ? "compte_rejeté" : "compte_validé";

//     if (isReexamination && lastNotification != null) {
//       await controller.updateNotification(
//         notificationId: lastNotification!['id'],
//         type: type,
//         payload: payload,
//         read: false,
//       );
//     } else {
//       await controller.postNotification(
//         userId: widget.user.id,
//         type: type,
//         payload: payload,
//       );
//     }

//     setState(() {
//       isReexamination = true;
//     });

//     Navigator.pop(ctx);
//   }
// }








// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mobile/data/models/user_model.dart';
// import 'package:mobile/presentation/screens/pdf/pdf_viewer_screen.dart';
// import '../../../../../theme/colors.dart';
// import 'package:photo_view/photo_view.dart';

// class ValidationScreen extends StatelessWidget {
//   final User user;

//   const ValidationScreen({super.key, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     final isEntreprise = user.accountType == "entreprise";
//     final fullName = user.fullName ?? "";
//     final companyName = user.companyName ?? "";

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Validation Utilisateur"),
//         backgroundColor: Colors.white,
//         foregroundColor: AppColors.textDark,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ------------------- NOM -------------------
//             Text(
//               "Nom : ${isEntreprise ? "$companyName ($fullName)" : fullName}",
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),

//             // ------------------- EMAIL -------------------
//             _infoRow("Email", user.email ?? ""),

//             // ------------------- TELEPHONE -------------------
//             if (user.phone != null && user.phone!.isNotEmpty)
//               _infoRow("Téléphone", user.phone!),

//             // ------------------- IFU -------------------
//             if (isEntreprise && user.ifu != null && user.ifu!.isNotEmpty)
//               _infoRow("IFU", user.ifu!),

//             // ------------------- Address / VILLE -------------------
//             if (user.address != null && user.address!.isNotEmpty)
//               _infoRow("Adresse", user.address!),
//             if (user.ville != null && user.ville!.isNotEmpty)
//               _infoRow("Ville", user.ville!),

//             const SizedBox(height: 16),

//             // ------------------- DOCUMENTS -------------------
//             Text(
//               "Documents à vérifier :",
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),

//             ..._buildDocuments(context, user, isEntreprise),
//           ],
//         ),
//       ),

//       // ------------------- BOUTONS EN BAS -------------------
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(16),
//         child: user.verifiedDocuments
//             ? Container(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   color: Colors.green.shade50,
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: const Text(
//                   "Ce compte est validé",
//                   style: TextStyle(
//                     color: Colors.green,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//               )
//             : Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => _showNoteModal(context, rejected: true),
//                       style: OutlinedButton.styleFrom(
//                         side: const BorderSide(color: Colors.red),
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                       ),
//                       child: const Text(
//                         "Rejeter",
//                         style: TextStyle(
//                           color: Colors.red,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () => _showNoteModal(context, rejected: false),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white, // fond blanc
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14),
//                           side: BorderSide(color: AppColors.textLight),
//                         ),
//                       ),
//                       child: Text(
//                         "Valider",
//                         style: TextStyle(
//                           color: AppColors.primary, // texte en couleur principale
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }

//   // ------------------- WIDGET INFO -------------------
//   Widget _infoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: RichText(
//         text: TextSpan(
//           children: [
//             TextSpan(
//               text: "$label : ",
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.textDark,
//               ),
//             ),
//             TextSpan(
//               text: value,
//               style: const TextStyle(color: AppColors.textDark),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ------------------- DOCUMENTS -------------------
//   List<Widget> _buildDocuments(
//       BuildContext context, User user, bool isEntreprise) {
//     final urls = user.documentsUrls ?? [];
//     if (urls.isEmpty) {
//       return [const Text("Aucun document disponible.")];
//     }

//     return urls.map((url) {
//       final isPdf = url.toLowerCase().endsWith(".pdf");
//       return Padding(
//         padding: const EdgeInsets.only(bottom: 12),
//         child: GestureDetector(
//           onTap: () {
//             if (isPdf) {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => PdfViewerScreen(pdfUrl: url),
//                 ),
//               );
//             } else {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => Scaffold(
//                     backgroundColor: Colors.black,
//                     appBar: AppBar(backgroundColor: Colors.black),
//                     body: PhotoView(imageProvider: NetworkImage(url)),
//                   ),
//                 ),
//               );
//             }
//           },
//           child: Container(
//             height: 120,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               color: Colors.grey.shade200,
//             ),
//             child: isPdf
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: const [
//                         Icon(Icons.picture_as_pdf, size: 40, color: Colors.red),
//                         SizedBox(height: 6),
//                         Text(
//                           "PDF",
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                   )
//                 : ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: Image.network(url, fit: BoxFit.cover),
//                   ),
//           ),
//         ),
//       );
//     }).toList();
//   }

//   // ------------------- MODAL POUR NOTE -------------------
//   void _showNoteModal(BuildContext context, {required bool rejected}) {
//     final _controller = TextEditingController();
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (ctx) {
//         return Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(ctx).viewInsets.bottom,
//             left: 16,
//             right: 16,
//             top: 16,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 rejected ? "Rejeter l'utilisateur" : "Valider l'utilisateur",
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: _controller,
//                 maxLines: 3,
//                 decoration: const InputDecoration(
//                   hintText: "Ajouter une note (optionnel)",
//                   filled: true,
//                   fillColor: Color(0xFFF7F9FB),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(12)),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // TODO: Appel API pour valider ou rejeter avec note
//                     Navigator.pop(ctx);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor:
//                         rejected ? Colors.red : Colors.white, // fond blanc
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       side: BorderSide(color: rejected ? Colors.red : AppColors.textLight),
//                     ),
//                   ),
//                   child: Text(
//                     rejected ? "Rejeter" : "Valider",
//                     style: TextStyle(
//                       color: rejected ? Colors.white : AppColors.primary, // texte couleur principale
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }



















// 1️⃣ Notification d’une réservation
// {
//   "title": "Nouvelle réservation",
//   "message": "Votre bien 'Appartement moderne' vient d'être réservé.",
//   "reservation_id": "12345",
//   "date": "2025-12-11 14:30:00"
// }

// 2️⃣ Notification de validation de document
// {
//   "title": "Documents validés",
//   "message": "Vos documents ont été validés avec succès.",
//   "documents": ["IFU", "RCCM"]
// }

// 3️⃣ Notification d’alerte ou promotion
// {
//   "title": "Promotion spéciale",
//   "message": "Profitez de 20% de réduction sur la location ce mois-ci !",
//   "url": "https://example.com/promo"
// }

// 4️⃣ Notification de message ou chat
// {
//   "title": "Nouveau message",
//   "message": "Jean vous a envoyé un nouveau message.",
//   "conversation_id": "abc123"
// }

