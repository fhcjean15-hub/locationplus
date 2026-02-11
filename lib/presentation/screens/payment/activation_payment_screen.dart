import 'package:flutter/material.dart';

class ActivationPaymentScreen extends StatelessWidget {
  const ActivationPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Activation du compte")),
      body: const Center(
        child: Text("Paiement d’activation du compte"),
      ),
    );
  }
}
