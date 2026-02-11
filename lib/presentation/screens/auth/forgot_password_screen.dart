import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/business/providers/forgot_password_provider.dart';
import 'package:mobile/business/states/forgot_password_state.dart';


class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  int step = 0; // 0 = email, 1 = OTP, 2 = new password

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  // OTP
  final List<TextEditingController> otpCtrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> otpFocus = List.generate(6, (_) => FocusNode());

  bool passVisible = false;
  bool confirmVisible = false;

  String? emailError;
  String? otpError;
  String? passError;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    for (final c in otpCtrls) c.dispose();
    for (final f in otpFocus) f.dispose();
    super.dispose();
  }

  // --- Validators ---
  bool isValidEmail(String email) =>
      RegExp(r"^[\w\.-]+@[\w\.-]+\.\w{2,4}$").hasMatch(email);

  bool isStrongPassword(String pass) =>
      RegExp(r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$")
          .hasMatch(pass);

  bool otpComplete() => otpCtrls.every((c) => c.text.isNotEmpty);

  String otpValue() => otpCtrls.map((e) => e.text).join();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordControllerProvider);

    // STEP AUTO CHANGES
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.emailSent && step == 0) setState(() => step = 1);
      if (state.codeVerified && step == 1) setState(() => step = 2);
      if (state.passwordReset && mounted) context.pop();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildStep(state),
          ),
        ),
      ),
    );
  }

  // --- APP BAR ---
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () {
          if (step > 0) {
            setState(() => step--);
          } else {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go("/onboarding");
            }
          }
        },
      ),
      title: const Text(
        "Mot de passe oublié",
        style: TextStyle(color: Colors.black87),
      ),
      centerTitle: true,
    );
  }

  // --- SELECT STEP ---
  Widget _buildStep(ForgotPasswordState state) {
    switch (step) {
      case 0:
        return _stepEmail(state);
      case 1:
        return _stepOtp(state);
      case 2:
        return _stepNewPassword(state);
      default:
        return Container();
    }
  }

  // ---------------------------------------------------------
  // STEP 0 — EMAIL
  // ---------------------------------------------------------
  Widget _stepEmail(ForgotPasswordState state) {
    return Column(
      key: const ValueKey(0),
      children: [
        const SizedBox(height: 30),
        Image.asset("assets/images/onboarding_meubles.png", height: 180),
        const SizedBox(height: 25),
        const Text(
          "Réinitialiser votre mot de passe",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          "Entrez votre adresse email pour recevoir un code de vérification.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Colors.black54),
        ),
        const SizedBox(height: 30),

        // Email field
        TextField(
          controller: emailCtrl,
          onChanged: (_) => setState(() => emailError = null),
          cursorColor: Colors.black,
          decoration: InputDecoration(
            labelText: "Email",
            labelStyle: const TextStyle(color: Colors.black),
            errorText: emailError ?? state.error,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 25),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state.isLoading
                ? null
                : () async {
                    final email = emailCtrl.text.trim();

                    if (!isValidEmail(email)) {
                      setState(() => emailError = "Email invalide");
                      return;
                    }

                    await ref
                        .read(forgotPasswordControllerProvider.notifier)
                        .sendEmail(email);
                  },
            style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
            child: state.isLoading
                ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                : const Text("Envoyer le code",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // STEP 1 — OTP
  // ---------------------------------------------------------
  Widget _stepOtp(ForgotPasswordState state) {
    return Column(
      key: const ValueKey(1),
      children: [
        const SizedBox(height: 30),
        Image.asset("assets/images/onboarding_meubles.png", height: 180),
        const SizedBox(height: 25),
        const Text(
          "Vérification du code",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        Text(
          "Un code à 6 chiffres a été envoyé à\n${state.email}",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, color: Colors.black54),
        ),

        const SizedBox(height: 30),

        // OTP Fields
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) {
            return SizedBox(
              width: 45,
              child: TextField(
                controller: otpCtrls[i],
                focusNode: otpFocus[i],
                maxLength: 1,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  if (v.isNotEmpty && i < 5) otpFocus[i + 1].requestFocus();
                  if (v.isEmpty && i > 0) otpFocus[i - 1].requestFocus();
                  setState(() => otpError = null);
                },
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  counterText: "",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            );
          }),
        ),

        if (otpError != null || state.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              otpError ?? state.error!,
              style: const TextStyle(color: Colors.red),
            ),
          ),

        const SizedBox(height: 25),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: otpComplete() && !state.isLoading
                ? () async {
                    await ref
                        .read(forgotPasswordControllerProvider.notifier)
                        .verifyCode(otpValue());
                  }
                : null,
            style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
            child: state.isLoading
                ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                : const Text("Vérifier", style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ),

        const SizedBox(height: 15),
        TextButton(
          onPressed: state.isLoading
              ? null
              : () async {
                  await ref
                      .read(forgotPasswordControllerProvider.notifier)
                      .sendEmail(state.email!);
                },
          child: const Text("Renvoyer le code"),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // STEP 2 — NEW PASSWORD
  // ---------------------------------------------------------
  Widget _stepNewPassword(ForgotPasswordState state) {
    return Column(
      key: const ValueKey(2),
      children: [
        const SizedBox(height: 30),
        Image.asset("assets/images/onboarding_meubles.png", height: 180),
        const SizedBox(height: 25),

        const Text(
          "Créer un nouveau mot de passe",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),
        const Text(
          "Votre nouveau mot de passe doit être sécurisé.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Colors.black54),
        ),

        const SizedBox(height: 30),

        // New password
        TextField(
          controller: passCtrl,
          obscureText: !passVisible,
          onChanged: (_) => setState(() => passError = null),
          cursorColor: Colors.black,
          decoration: InputDecoration(
            labelText: "Nouveau mot de passe",
             labelStyle: const TextStyle(color: Colors.black),
            errorText: passError ?? state.error,
            filled: true,
            fillColor: Colors.grey.shade100,
            suffixIcon: IconButton(
              icon: Icon(
                passVisible ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () => setState(() => passVisible = !passVisible),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 15),

        // Confirm password
        TextField(
          controller: confirmCtrl,
          obscureText: !confirmVisible,
          decoration: InputDecoration(
            labelText: "Confirmer le mot de passe",
            labelStyle: const TextStyle(color: Colors.black),
            errorText: passError ?? state.error,
            filled: true,
            fillColor: Colors.grey.shade100,
            suffixIcon: IconButton(
              icon: Icon(
                confirmVisible ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () =>
                  setState(() => confirmVisible = !confirmVisible),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 25),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state.isLoading
                ? null
                : () async {
                    final pass = passCtrl.text.trim();
                    final confirm = confirmCtrl.text.trim();

                    if (!isStrongPassword(pass)) {
                      setState(() => passError =
                          "8+ caractères, majuscule, minuscule, chiffre et symbole.");
                      return;
                    }
                    if (pass != confirm) {
                      setState(() =>
                          passError = "Les mots de passe ne correspondent pas.");
                      return;
                    }

                    final success = await ref
                        .read(forgotPasswordControllerProvider.notifier)
                        .resetPassword(pass);

                    if (success) { 
                      context.go("/login"); 
                      return;
                    }


                  },
            style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
            child: state.isLoading
                ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                : const Text("Réinitialiser",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

