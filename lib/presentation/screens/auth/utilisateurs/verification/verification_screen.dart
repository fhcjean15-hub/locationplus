import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/business/states/auth_state.dart';
import 'package:intl/intl.dart';
import 'package:mobile/presentation/widgets/step1a_form.dart';
import 'package:mobile/presentation/widgets/step1b_entreprise_form.dart';
import 'package:mobile/presentation/widgets/step1b_particulier_form.dart';
import '../../../../theme/colors.dart';
import '../../../../../business/providers/auth_controller_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:dio/dio.dart';
// import 'package:mobile/data/providers/auth_providers.dart';

enum AccountType { particulier, entreprise }

class VerificationScreen extends ConsumerStatefulWidget {
  final bool hasPaid;
  final DateTime? paymentValidUntil;

  const VerificationScreen({
    super.key,
    this.hasPaid = false,
    this.paymentValidUntil,
  });

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  // Phases principales (1: formulaire, 2: validation, 3: paiement)
  int phase = 1;

  final _formKey = GlobalKey<FormState>();
  final url = "https://api-location-plus.lamadonebenin.com/storage/";

  // Sous-étape de la phase 1
  int phase1Sub = 1;

  // état UI
  bool isSubmitting = false;
  bool isValidated = false;

  double paymentPrice = 0;

  // -------------------------
  // État supplémentaire
  // -------------------------
  String? selectedCategoryId; // ID de la catégorie choisie

  // controllers correctement initialisés
  final TextEditingController ifuController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController villeController = TextEditingController();

  // uploaded files
  File? identityFile;
  File? rccmFile; // seulement pour entreprise
  File? avatarFile;

  // accountType par défaut
  AccountType accountType = AccountType.particulier;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();

    ifuController.addListener(() => setState(() {}));
    addressController.addListener(() => setState(() {}));
    villeController.addListener(() => setState(() {}));
  }

  void _loadUserInfo() {
    final authState = ref.read(authControllerProvider);
    final user = authState.user;

    if (user != null && user.accountType == "entreprise") {
      accountType = AccountType.entreprise;
    } else {
      accountType = AccountType.particulier;
    }

    if (user != null) {
      ifuController.text = user.ifu ?? "";
      addressController.text = user.address ?? "";
      villeController.text = user.ville ?? "";
      selectedCategoryId = user.accountCategoryId?.toString();
      isValidated = user.verifiedDocuments ?? false;

      // ✅ Persistance de la phase 2
      if (user.documentsUrls != null && user.documentsUrls!.isNotEmpty) {
        phase =
            2; // passe directement à la phase 2 si des documents sont déjà soumis
        phase1Sub = 2; // montre automatiquement la sous-étape documents
      }
    }
  }

  @override
  void dispose() {
    ifuController.dispose();
    addressController.dispose();
    villeController.dispose();
    super.dispose();
  }

  bool get isPaymentActive {
    final now = DateTime.now();
    final user = ref.read(authControllerProvider).user;

    if (user != null &&
        user.paymentStatus == 'paid' &&
        user.paymentValidUntil != null) {
      return user.paymentValidUntil!.isAfter(now);
    }

    return false;
  }

  // -------------------------
  // VALIDATIONS LOCALES
  // -------------------------
  bool _canProceedToSub2() {
    return ifuController.text.trim().isNotEmpty &&
        addressController.text.trim().isNotEmpty &&
        villeController.text.trim().isNotEmpty;
  }

  bool _canSubmitPhase1() {
    final identityOk = identityFile != null;
    final categoryOk = selectedCategoryId != null;

    if (accountType == AccountType.particulier) {
      return identityOk && categoryOk;
    } else {
      final rccmOk = rccmFile != null;
      return identityOk && rccmOk && categoryOk;
    }
  }

  // -------------------------
  // ACTIONS
  // -------------------------
  void _goToSub2() {
    if (!_canProceedToSub2()) {
      _showSnack("Veuillez remplir IFU, adresse et ville pour continuer.");
      return;
    }
    setState(() => phase1Sub = 2);
  }

  void _backToSub1() => setState(() => phase1Sub = 1);

  Future<void> _submitPhase1() async {
    if (!_canSubmitPhase1()) {
      _showSnack(
        "Veuillez remplir tous les champs requis et téléverser les documents.",
      );
      return;
    }

    setState(() => isSubmitting = true);

    final controller = ref.read(authControllerProvider.notifier);

    final success = await controller.updateProfile(
      ifu: ifuController.text.trim(),
      adresse: addressController.text.trim(),
      ville: villeController.text.trim(),
      accountCategoryId: selectedCategoryId,
      avatarUrl: avatarFile,
      documentsFiles: accountType == AccountType.particulier
          ? [identityFile!]
          : [identityFile!, rccmFile!],
    );

    final authState = ref.read(authControllerProvider);

    if (!mounted) return;

    setState(() {
      isSubmitting = false;
      if (success) {
        phase = 2;
        isValidated = false; // repasse à en attente
        _showSnack("Informations soumises — en attente de validation");
      } else {
        final err = authState.error!;
        _showSnack("Erreur lors de la soumission : $err");
        print("error: $err");
      }
    });
  }

  void _onIdentityPicked(File? f) => setState(() => identityFile = f);
  void _onRccmPicked(File? f) => setState(() => rccmFile = f);
  void _onAvatarPicked(File? f) => setState(() => avatarFile = f);

  void _simulateAdminValidation() {
    setState(() {
      isValidated = true;
      phase = 3;
    });
  }

  void _showSnack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // final Dio _dio = Dio(
  //   BaseOptions(
  //     baseUrl: "http://192.168.100.246:8000/api", // ⚠️ remplace par ton domaine
  //     connectTimeout: const Duration(seconds: 20),
  //     receiveTimeout: const Duration(seconds: 20),
  //   ),
  // );

  // Future<void> _startPayment() async {
  //   try {
  //     setState(() => isSubmitting = true);

  //     final authState = ref.read(authControllerProvider);
  //     final token = authState.token; // ou accessToken selon ton projet

  //     final response = await _dio.post(
  //       "/payments/init",
  //       data: {
  //         "amount": 10000, // ⚠️ mets le vrai prix de l’abonnement ici
  //       },
  //       options: Options(
  //         headers: {
  //           "Authorization": "Bearer $token",
  //           "Accept": "application/json",
  //         },
  //       ),
  //     );

  //     final paymentUrl = response.data["payment_url"];

  //     if (paymentUrl == null || paymentUrl.toString().isEmpty) {
  //       _showSnack("Impossible d'obtenir l’URL de paiement");
  //       return;
  //     }

  //     if (!mounted) return;

  //     // Ouvrir WebView
  //     Navigator.of(context).push(
  //       MaterialPageRoute(
  //         builder: (_) => _PaymentWebViewScreen(url: paymentUrl),
  //       ),
  //     );

  //   } catch (e) {
  //     debugPrint("Erreur init paiement: $e");
  //     _showSnack("Erreur lors de l'initialisation du paiement");
  //   } finally {
  //     if (mounted) setState(() => isSubmitting = false);
  //   }
  // }

  Future<void> _startPayment() async {
    try {
      setState(() => isSubmitting = true);

      final controller = ref.read(authControllerProvider.notifier);
      final user = ref.read(authControllerProvider).user;
      final int? categoryId = user?.accountCategoryId;

      double priceToPay = 0;

      if (categoryId != null) {
        final recupPrice = await controller.loadAccountCategory(categoryId);

        final priceStr = recupPrice?['price']?.toString() ?? "0";
        priceToPay = double.tryParse(priceStr) ?? 0.0;
      }

      final authRepo = ref.read(authRepositoryProvider);

      print("amount: $priceToPay");

      final response = await authRepo.initPayment(amount: priceToPay);

      final paymentUrl = response["payment_url"];

      if (paymentUrl == null || paymentUrl.toString().isEmpty) {
        _showSnack("Impossible d'obtenir l’URL de paiement");
        return;
      }

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _PaymentWebViewScreen(url: paymentUrl),
        ),
      );

      await controller.refreshUser();

    } catch (e) {
      debugPrint("Erreur init paiement: $e");
      _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  // -------------------------
  // BUILD
  // -------------------------
  @override
  Widget build(BuildContext context) {
    final title = "Vérification du compte";

    return Scaffold(
      backgroundColor: AppColors.primary50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildStepIndicator(),
              const SizedBox(height: 12),
              if (phase == 1) _buildPhase1Card(),
              if (phase == 2) _buildValidationCard(),
              if (phase == 3) _buildPaymentCard(),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------
  // STEP INDICATOR
  // -------------------------
  Widget _buildStepIndicator() {
    String pLabel = "Phase $phase";
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.verified_user, color: AppColors.primary),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Vérification",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(pLabel, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------
  // PHASE 1 CARD
  // -------------------------
  Widget _buildPhase1Card() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Phase 1 : Informations",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _subStepButton(1, "1 — Infos"),
                const SizedBox(width: 8),
                _subStepButton(
                  2,
                  "2 — Documents",
                  locked: !_canProceedToSub2(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: phase1Sub == 1 ? _buildSubStep1() : _buildSubStep2(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (phase1Sub == 2)
                  OutlinedButton(
                    onPressed: _backToSub1,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Retour",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                const Spacer(),
                if (phase1Sub == 1)
                  ElevatedButton(
                    onPressed: _canProceedToSub2() ? _goToSub2 : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 18,
                      ),
                    ),
                    child: const Text(
                      "Suivant",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                if (phase1Sub == 2)
                  ElevatedButton(
                    onPressed: isSubmitting ? null : _submitPhase1,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 18,
                      ),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Soumettre",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------
  // SUB STEP BUTTON
  // -------------------------
  Widget _subStepButton(int s, String label, {bool locked = false}) {
    final active = phase1Sub == s;
    return Expanded(
      child: GestureDetector(
        onTap: locked
            ? null
            : () {
                setState(() => phase1Sub = s);
              },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.primary50 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: active ? AppColors.primary : Colors.grey),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: locked
                    ? Colors.grey
                    : active
                    ? AppColors.primary
                    : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------
  // BUILD SUBSTEPS
  // -------------------------
  Widget _buildSubStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Step1AForm(
          ifuController: ifuController,
          addressController: addressController,
          villeController: villeController,
        ),
      ],
    );
  }

  Widget _buildSubStep2() {
    final authState = ref.read(authControllerProvider);
    final user = authState.user;
    // Supposons que tu as un User actuel stocké dans `currentUser`
    final String? existingIdentityFileName =
        user?.documentsUrls != null && user!.documentsUrls!.isNotEmpty
        ? user!
              .documentsUrls!
              .first // par exemple le premier document
        : null;

    // Pour le RCCM (entreprise)
    final String? existingRccmFileName =
        user?.documentsUrls != null && user!.documentsUrls!.length > 1
        ? user!.documentsUrls![1]
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (accountType == AccountType.particulier)
          Step1BParticulierForm(
            selectedCategoryId: selectedCategoryId,
            onCategorySelected: (id) => setState(() => selectedCategoryId = id),
            identityDocument: identityFile,
            identityDocumentName: existingIdentityFileName,
            onIdentityPicked: _onIdentityPicked,
          )
        else
          Step1BEntrepriseForm(
            selectedCategoryId: selectedCategoryId,
            onCategorySelected: (id) => setState(() => selectedCategoryId = id),
            identityDocument: identityFile,
            identityDocumentName: existingIdentityFileName,
            rccmDocument: rccmFile,
            rccmDocumentName: existingRccmFileName,
            onIdentityPicked: _onIdentityPicked,
            onRccmPicked: _onRccmPicked,
          ),
      ],
    );
  }

  // -------------------------
  // VALIDATION CARD
  // -------------------------
  Widget _buildValidationCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Phase 2 : Statut de validation",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isValidated
                  ? "Vos informations ont été validées par l'administrateur."
                  : "Vos informations sont en attente de validation.",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() {
                      phase = 1;
                      phase1Sub = 1;
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Modifier",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isValidated ? _simulateAdminValidation : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isValidated
                          ? AppColors.primary
                          : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      isValidated ? "Passer au paiement" : "En attente...",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------
  // PAYMENT CARD
  // -------------------------
  // Widget _buildPaymentCard() {
  //   final paymentActive = isValidated && !isPaymentActive;

  //   // 🔥 Récupération du prix
  //   final double priceToPay = AuthState().user?.accountCategory?.price ?? 0;
  //   final formattedPrice = priceToPay.toStringAsFixed(2); // format 2 décimales

  //   return Card(
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //     elevation: 4,
  //     color: Colors.white,
  //     child: Padding(
  //       padding: const EdgeInsets.all(20),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const Text(
  //             "Phase 3 : Paiement",
  //             style: TextStyle(
  //               fontSize: 20,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.black,
  //             ),
  //           ),
  //           const SizedBox(height: 12),
  //           if (isPaymentActive)
  //             const Text(
  //               "Paiement déjà effectué.",
  //               style: TextStyle(fontSize: 16),
  //             )
  //           else
  //             Text(
  //               "Veuillez effectuer le paiement de $formattedPrice FCFA pour activer votre compte.",
  //               style: TextStyle(fontSize: 16),
  //             ),
  //           const SizedBox(height: 16),
  //           if (!isPaymentActive)
  //             SizedBox(
  //               width: double.infinity,
  //               child: ElevatedButton.icon(
  //                 onPressed: paymentActive ? _startPayment : null,
  //                 icon: const Icon(Icons.payment),
  //                 label: const Text(
  //                   "Procéder au paiement",
  //                   style: TextStyle(color: Colors.white),
  //                 ),
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: AppColors.primary,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(12),
  //                   ),
  //                   padding: const EdgeInsets.symmetric(vertical: 14),
  //                 ),
  //               ),
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildPaymentCard() {
    final paymentActive = isValidated && !isPaymentActive;
    final controller = ref.read(authControllerProvider.notifier);
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final int? categoryId = user?.accountCategoryId;

    return FutureBuilder<Map<String, dynamic>?>(
      future: categoryId != null
          ? controller.loadAccountCategory(categoryId)
          : Future.value(null),
      builder: (context, snapshot) {
        double priceToPay = 0;

        if (snapshot.hasData && snapshot.data != null) {
          final priceStr = snapshot.data?['price']?.toString() ?? "0";
          priceToPay = double.tryParse(priceStr) ?? 0.0;
        }

        final formattedPrice = NumberFormat(
          '#,##0',
          'fr_FR',
        ).format(priceToPay);

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Phase 3 : Paiement",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                if (isPaymentActive)
                  const Text(
                    "Paiement déjà effectué.",
                    style: TextStyle(fontSize: 16),
                  )
                else
                  Text(
                    "Veuillez effectuer le paiement de $formattedPrice FCFA pour activer votre compte.",
                    style: const TextStyle(fontSize: 16),
                  ),
                const SizedBox(height: 16),
                if (!isPaymentActive)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: paymentActive ? _startPayment : null,
                      icon: const Icon(Icons.payment),
                      label: const Text(
                        "Procéder au paiement",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PaymentWebViewScreen extends StatefulWidget {
  final String url;

  const _PaymentWebViewScreen({required this.url, super.key});

  @override
  State<_PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<_PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool loading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            setState(() => loading = false);
          },
          onNavigationRequest: (request) {
            final url = request.url;

            // ✅ Paiement réussi
            if (url.contains("/api/payment/success")) {
              Navigator.of(context).pop(true); // retourne true au parent
              return NavigationDecision.prevent;
            }

            // ✅ Paiement annulé
            if (url.contains("/api/payment/cancel")) {
              Navigator.of(context).pop(false); // retourne false au parent
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paiement")),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}




















// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile/presentation/widgets/step1a_form.dart';
// import 'package:mobile/presentation/widgets/step1b_entreprise_form.dart';
// import 'package:mobile/presentation/widgets/step1b_particulier_form.dart';
// import '../../../../theme/colors.dart';
// import '../../../../../business/providers/auth_controller_provider.dart';

// enum AccountType { particulier, entreprise }

// class VerificationScreen extends ConsumerStatefulWidget {
//   final bool hasPaid;
//   final DateTime? paymentValidUntil;

//   const VerificationScreen({
//     super.key,
//     this.hasPaid = false,
//     this.paymentValidUntil,
//   });

//   @override
//   ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
// }

// class _VerificationScreenState extends ConsumerState<VerificationScreen> {
//   // Phases principales (1: formulaire, 2: validation, 3: paiement)
//   int phase = 1;

//   final _formKey = GlobalKey<FormState>();

//   // Sous-étape de la phase 1 (1 = step1A IFU/Adresse, 2 = step1B Num + Uploads)
//   int phase1Sub = 1;

//   // état UI
//   bool isSubmitting = false;
//   bool isValidated = false;

//   // -------------------------
//   // État supplémentaire
//   // -------------------------
//   String? selectedCategoryId; // ID de la catégorie choisie

//   // controllers correctement initialisés
//   final TextEditingController ifuController = TextEditingController();
//   final TextEditingController addressController = TextEditingController();
//   final TextEditingController numberController = TextEditingController();
//   final TextEditingController villeController = TextEditingController();

//   // uploaded files
//   File? identityFile;
//   File? rccmFile; // seulement pour entreprise

//   // accountType par défaut (sécurisé)
//   AccountType accountType = AccountType.particulier;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserInfo();

//     ifuController.addListener(() => setState(() {}));
//     addressController.addListener(() => setState(() {}));
//     villeController.addListener(() => setState(() {}));
//   }

//   void _loadUserInfo() {
//     final authState = ref.read(authControllerProvider);
//     final user = authState.user;

//     if (user != null && user.accountType == "entreprise") {
//       accountType = AccountType.entreprise;
//     } else {
//       accountType = AccountType.particulier;
//     }

//     if (user != null) {
//       ifuController.text = user.ifu ?? "";
//       addressController.text = user.address ?? "";
//       numberController.text = user.phone ?? "";
//       isValidated = user.verifiedDocuments ?? false;
//       villeController.text = user.ville ?? ""; 
//     }
//   }

//   @override
//   void dispose() {
//     ifuController.dispose();
//     addressController.dispose();
//     numberController.dispose();
//     villeController.dispose();
//     super.dispose();
//   }

//   bool get isPaymentActive {
//     final now = DateTime.now();
//     final user = ref.read(authControllerProvider).user;

//     if (user != null &&
//         user.paymentStatus == 'paid' &&
//         user.paymentValidUntil != null) {
//       return user.paymentValidUntil!.isAfter(now);
//     }

//     return false;
//   }

//   // -------------------------
//   // VALIDATIONS LOCALES
//   // -------------------------
//   bool _canProceedToSub2() {
//     return ifuController.text.trim().isNotEmpty &&
//         addressController.text.trim().isNotEmpty &&
//         villeController.text.trim().isNotEmpty;
//   }

//   // -------------------------
//   // Mise à jour de _canSubmitPhase1
//   // -------------------------
//   bool _canSubmitPhase1() {
//     final identityOk = identityFile != null;
//     final categoryOk = selectedCategoryId != null;
//     if (accountType == AccountType.particulier) {
//       return identityOk && categoryOk;
//     } else {
//       final rccmOk = rccmFile != null;
//       return identityOk && rccmOk && categoryOk;
//     }
//   }

//   // -------------------------
//   // ACTIONS
//   // -------------------------
//   void _goToSub2() {
//     if (!_canProceedToSub2()) {
//       _showSnack("Veuillez remplir IFU et adresse pour continuer.");
//       return;
//     }
//     setState(() => phase1Sub = 2);
//   }

//   void _backToSub1() => setState(() => phase1Sub = 1);

//   void _submitPhase1() {
//     if (!_canSubmitPhase1()) {
//       _showSnack(
//           "Veuillez remplir tous les champs requis et téléverser les documents.");
//       return;
//     }

//     setState(() => isSubmitting = true);

//     Future.delayed(const Duration(seconds: 1), () {
//       setState(() {
//         isSubmitting = false;
//         phase = 2;
//         isValidated = false;
//       });
//       _showSnack("Informations soumises — en attente de validation");
//     });
//   }

//   void _simulateAdminValidation() {
//     setState(() {
//       isValidated = true;
//       phase = 3;
//     });
//   }

//   void _onIdentityPicked(File? f) => setState(() => identityFile = f);
//   void _onRccmPicked(File? f) => setState(() => rccmFile = f);

//   void _showSnack(String text) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
//   }

//   // -------------------------
//   // BUILD
//   // -------------------------
//   @override
//   Widget build(BuildContext context) {
//     final title = "Vérification du compte";

//     return Scaffold(
//       backgroundColor: AppColors.primary50,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: Text(title,
//             style: const TextStyle(
//                 color: Colors.black, fontWeight: FontWeight.bold)),
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       body: GestureDetector(
//         behavior: HitTestBehavior.translucent, // 👈 permet de détecter le tap partout
//         onTap: () {
//           FocusScope.of(context).unfocus(); // 👈 fait disparaître le clavier
//         },
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               _buildStepIndicator(),
//               const SizedBox(height: 12),
//               if (phase == 1) _buildPhase1Card(),
//               if (phase == 2) _buildValidationCard(),
//               if (phase == 3) _buildPaymentCard(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStepIndicator() {
//     String pLabel = "Phase $phase";
//     return Row(
//       children: [
//         Expanded(
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.verified_user, color: AppColors.primary),
//                 const SizedBox(width: 8),
//                 Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("Vérification",
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, color: Colors.black)),
//                       const SizedBox(height: 2),
//                       Text(pLabel, style: const TextStyle(fontSize: 12)),
//                     ])
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPhase1Card() {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 4,
//       color: Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           const Text(
//             "Phase 1 : Informations",
//             style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               _subStepButton(1, "1 — Infos"),
//               const SizedBox(width: 8),
//               _subStepButton(2, "2 — Documents", locked: !_canProceedToSub2()),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Form(
//             key: _formKey,
//             child: phase1Sub == 1 ? _buildSubStep1() : _buildSubStep2(),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               if (phase1Sub == 2)
//                 OutlinedButton(
//                   onPressed: _backToSub1,
//                   style: OutlinedButton.styleFrom(
//                     side: const BorderSide(color: Colors.black),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                   ),
//                   child: const Text("Retour",
//                       style: TextStyle(color: Colors.black)),
//                 ),
//               const Spacer(),
//               if (phase1Sub == 1)
//                 ElevatedButton(
//                   onPressed: _canProceedToSub2() ? _goToSub2 : null,
//                   style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primary,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 14, horizontal: 18)),
//                   child: const Text("Suivant",
//                       style: TextStyle(color: Colors.white)),
//                 ),
//               if (phase1Sub == 2)
//                 ElevatedButton(
//                   onPressed: isSubmitting ? null : _submitPhase1,
//                   style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primary,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 14, horizontal: 18)),
//                   child: isSubmitting
//                       ? const SizedBox(
//                           height: 16,
//                           width: 16,
//                           child: CircularProgressIndicator(
//                               color: Colors.white, strokeWidth: 2))
//                       : const Text("Soumettre",
//                           style: TextStyle(color: Colors.white)),
//                 ),
//             ],
//           ),
//         ]),
//       ),
//     );
//   }

//   Widget _subStepButton(int s, String label, {bool locked = false}) {
//     final active = phase1Sub == s;
//     return Expanded(
//       child: GestureDetector(
//         onTap: locked
//             ? null
//             : () {
//                 setState(() => phase1Sub = s);
//               },
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             color: active ? AppColors.primary50 : Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: active ? AppColors.primary : Colors.grey),
//           ),
//           child: Center(
//             child: Text(
//               label,
//               style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: locked
//                       ? Colors.grey
//                       : active
//                           ? AppColors.primary
//                           : Colors.black),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSubStep1() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Step1AForm(
//             ifuController: ifuController,
//             addressController: addressController,
//             villeController: villeController,)
//       ],
//     );
//   }

//   // -------------------------
//   // Build subStep2 mis à jour
//   // -------------------------
//   Widget _buildSubStep2() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (accountType == AccountType.particulier)
//           Step1BParticulierForm(
//             selectedCategoryId: selectedCategoryId,
//             onCategorySelected: (id) => setState(() => selectedCategoryId = id),
//             identityDocument: identityFile,
//             onIdentityPicked: _onIdentityPicked,
//           )
//         else
//           Step1BEntrepriseForm(
//             selectedCategoryId: selectedCategoryId,
//             onCategorySelected: (id) => setState(() => selectedCategoryId = id),
//             identityDocument: identityFile,
//             rccmDocument: rccmFile,
//             onIdentityPicked: _onIdentityPicked,
//             onRccmPicked: _onRccmPicked,
//           ),
//       ],
//     );
//   }

//   Widget _buildValidationCard() {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 4,
//       color: Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           const Text("Phase 2 : Statut de validation",
//               style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black)),
//           const SizedBox(height: 12),
//           Text(
//             isValidated
//                 ? "Vos informations ont été validées par l'administrateur."
//                 : "Vos informations sont en attente de validation.",
//             style: const TextStyle(fontSize: 16),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () => setState(() {
//                     phase = 1;
//                     phase1Sub = 1;
//                   }),
//                   style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primary,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                       padding: const EdgeInsets.symmetric(vertical: 14)),
//                   child: const Text("Modifier",
//                       style: TextStyle(
//                           color: Colors.white, fontWeight: FontWeight.bold)),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: isValidated ? _simulateAdminValidation : null,
//                   style: ElevatedButton.styleFrom(
//                       backgroundColor: isValidated ? AppColors.primary : Colors.grey,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                       padding: const EdgeInsets.symmetric(vertical: 14)),
//                   child: Text(
//                     isValidated ? "Passer au paiement" : "En attente...",
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ]),
//       ),
//     );
//   }

//   Widget _buildPaymentCard() {
//     final paymentActive = isValidated && !isPaymentActive;

//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 4,
//       color: Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           const Text("Phase 3 : Paiement",
//               style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black)),
//           const SizedBox(height: 12),
//           if (isPaymentActive)
//             const Text("Paiement déjà effectué.",
//                 style: TextStyle(fontSize: 16))
//           else
//             const Text("Veuillez effectuer le paiement pour activer votre compte.",
//                 style: TextStyle(fontSize: 16)),
//           const SizedBox(height: 16),
//           if (!isPaymentActive)
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: paymentActive
//                     ? () {
//                         _showSnack("Ouvrir le flow de paiement (TODO)");
//                       }
//                     : null,
//                 icon: const Icon(Icons.payment),
//                 label: const Text("Procéder au paiement",
//                     style: TextStyle(color: Colors.white)),
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12)),
//                     padding: const EdgeInsets.symmetric(vertical: 14)),
//               ),
//             ),
//         ]),
//       ),
//     );
//   }
// }












