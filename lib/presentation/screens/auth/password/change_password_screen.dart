import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../business/providers/auth_controller_provider.dart';
import '../../../theme/colors.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  void _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Les nouveaux mots de passe ne correspondent pas")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await ref.read(authControllerProvider.notifier).updateProfile(
          currentPassword: currentPassword,
          password: newPassword,
        );

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mot de passe mis à jour avec succès")),
      );
      Navigator.pop(context);
    } else {
      final error = ref.read(authControllerProvider).error ?? "Erreur lors de la mise à jour";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _buildDecoration(String label, bool show, VoidCallback toggle) {
    return InputDecoration(
      labelText: label,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      suffixIcon: IconButton(
        icon: Icon(show ? Icons.visibility : Icons.visibility_off, color: AppColors.secondaryBlue),
        onPressed: toggle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // 👈 Ferme le clavier au clic en dehors
      child: Scaffold(
        backgroundColor: AppColors.primary50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "Sécurité - Mot de passe",
            style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: AppColors.textDark),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      children: [
                        Text(
                          "Changer le mot de passe",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondaryBlue,
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _currentPasswordController,
                          obscureText: !_showCurrent,
                          cursorColor: Colors.black,
                          decoration: _buildDecoration("Mot de passe actuel", _showCurrent, () {
                            setState(() => _showCurrent = !_showCurrent);
                          }),
                          validator: (value) =>
                              value == null || value.isEmpty ? "Veuillez entrer votre mot de passe actuel" : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _newPasswordController,
                          obscureText: !_showNew,
                          cursorColor: Colors.black,
                          decoration: _buildDecoration("Nouveau mot de passe", _showNew, () {
                            setState(() => _showNew = !_showNew);
                          }),
                          validator: (value) => value == null || value.length < 6
                              ? "Le mot de passe doit contenir au moins 6 caractères"
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !_showConfirm,
                          decoration: _buildDecoration("Confirmer le nouveau mot de passe", _showConfirm, () {
                            setState(() => _showConfirm = !_showConfirm);
                          }),
                          validator: (value) =>
                              value == null || value.isEmpty ? "Veuillez confirmer le nouveau mot de passe" : null,
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _updatePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    "Mettre à jour le mot de passe",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
