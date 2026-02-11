import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/business/providers/auth_controller_provider.dart';

// 🟦 IMPORT AJOUTÉ
import 'package:mobile/data/providers/onboarding_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final trapCtrl = TextEditingController();

  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final ctrl = ref.read(authControllerProvider.notifier);

    final isLoading = auth.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go("/onboarding");
            }
          },
        ),
        centerTitle: true,
        title: const Text(
          "Connexion",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: IgnorePointer(
            ignoring: isLoading,
            child: Opacity(
              opacity: isLoading ? 0.6 : 1,
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Image.asset(
                    "assets/images/onboarding_voitures.png",
                    height: 200,
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Ravi de vous revoir ! Connectez-vous pour continuer.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),

                  const SizedBox(height: 30),

                  // ******************
                  // CHAMP EMAIL
                  // ******************
                  TextField(
                    enabled: !isLoading,
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ******************
                  // CHAMP MOT DE PASSE
                  // ******************
                  TextField(
                    enabled: !isLoading,
                    controller: passCtrl,
                    obscureText: obscure,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      labelText: "Mot de passe",
                      labelStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure ? Icons.visibility_off : Icons.visibility,
                          color: Colors.black54,
                        ),
                        onPressed: () => setState(() => obscure = !obscure),
                      ),
                    ),
                  ),

                  // Champ invisible honeypot
                  SizedBox(
                    height: 0,
                    child: TextField(
                      controller: trapCtrl,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ******************
                  // BOUTON CONNEXION
                  // ******************
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              final email = emailCtrl.text.trim();
                              final pass = passCtrl.text.trim();

                              if (trapCtrl.text.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Erreur interne."),
                                  ),
                                );
                                return;
                              }

                              if (!RegExp(
                                r"^[^@]+@[^@]+\.[^@]+$",
                              ).hasMatch(email)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Email invalide"),
                                  ),
                                );
                                return;
                              }

                              if (pass.length < 8) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Le mot de passe doit contenir au moins 8 caractères",
                                    ),
                                  ),
                                );
                                return;
                              }

                              final success = await ctrl.login(email, pass);

                              if (!mounted) return;

                              if (success) {
                                // 1️⃣ redirection sécurisée
                                print("mounted = $mounted");
                                GoRouter.of(context).go("/home");

                                // 2️⃣ puis marquer onboarding comme complété
                                await ref
                                    .read(onboardingProvider.notifier)
                                    .completeOnboarding();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      auth.error ?? "Connexion impossible",
                                    ),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              "Se connecter",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => context.go("/forgot-password"),
                    child: const Text(
                      "Mot de passe oublié ?",
                      style: TextStyle(
                        color: Colors.black54,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextButton(
                    onPressed: isLoading ? null : () => context.go("/register"),
                    child: const Text(
                      "Créer un compte",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}







