import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/business/providers/notification_provider.dart';
import 'package:mobile/presentation/theme/colors.dart';

class ReportProblemScreen extends ConsumerStatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  ConsumerState<ReportProblemScreen> createState() =>
      _ReportProblemScreenState();
}

class _ReportProblemScreenState
    extends ConsumerState<ReportProblemScreen> {
  final TextEditingController _noteCtrl = TextEditingController();

  Future<void> _submit() async {
    final note = _noteCtrl.text.trim();
    if (note.isEmpty) return;

    final controller =
        ref.read(notificationListControllerProvider.notifier);

    final success = await controller.sendReport(
      note: note,
      payload: {
        "source": "mobile_app",
        "screen": "help_support",
        "timestamp": DateTime.now().toIso8601String(),
      },
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Signalement envoyé avec succès"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final error = ref.read(notificationListControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? "Erreur lors de l’envoi du signalement"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationListControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Signaler un problème",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Décrivez le problème rencontré afin que notre équipe puisse vous aider.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // ================= TEXTAREA =================
            TextField(
              controller: _noteCtrl,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Votre message...",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ================= BUTTON =================
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: state.isSendingReport ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: state.isSendingReport
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Envoyer",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';

// class ReportProblemScreen extends StatefulWidget {
//   const ReportProblemScreen({super.key});

//   @override
//   State<ReportProblemScreen> createState() => _ReportProblemScreenState();
// }

// class _ReportProblemScreenState extends State<ReportProblemScreen> {
//   final TextEditingController _noteCtrl = TextEditingController();
//   bool loading = false;

//   Future<void> _submit() async {
//     if (_noteCtrl.text.trim().isEmpty) return;

//     setState(() => loading = true);

//     final payload = {
//       "note": _noteCtrl.text,
//       "timestamp": DateTime.now().toIso8601String(),
//       "source": "mobile_app",
//     };

//     // 🔥 ICI tu brancheras ton NotificationController
//     // type: signalement
//     // payload: payload

//     await Future.delayed(const Duration(seconds: 1));

//     setState(() => loading = false);

//     if (mounted) {
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Signalement envoyé avec succès")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Signaler un problème"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             const Text(
//               "Décrivez le problème rencontré afin que notre équipe puisse vous aider.",
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _noteCtrl,
//               maxLines: 5,
//               decoration: const InputDecoration(
//                 hintText: "Votre message...",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: loading ? null : _submit,
//                 child: loading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text("Envoyer"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
