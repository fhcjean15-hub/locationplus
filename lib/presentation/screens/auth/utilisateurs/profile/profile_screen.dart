import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../business/providers/auth_controller_provider.dart';
import '../../../../theme/colors.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool isEditing = false;
  File? _pickedImage;
  final url = "https://api-location-plus.lamadonebenin.com/storage/";

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController companyController;

  final FocusNode nameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode companyFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    nameController = TextEditingController(
      text: user?.fullName?.isNotEmpty == true
          ? user!.fullName
          : user?.companyName?.isNotEmpty == true
          ? user!.companyName
          : "Votre Nom",
    );
    emailController = TextEditingController(text: user?.email ?? "");
    phoneController = TextEditingController(text: user?.phone ?? "");
    companyController = TextEditingController(text: user?.companyName ?? "");

    // Listeeners : perte de focus → sauvegarde
    nameFocus.addListener(_onFocusLost);
    emailFocus.addListener(_onFocusLost);
    phoneFocus.addListener(_onFocusLost);
    companyFocus.addListener(_onFocusLost);
  }

  void _onFocusLost() {
    if (!isEditing) return;
    if (!nameFocus.hasFocus &&
        !emailFocus.hasFocus &&
        !phoneFocus.hasFocus &&
        !companyFocus.hasFocus) {
      _save();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    companyController.dispose();
    nameFocus.dispose();
    emailFocus.dispose();
    phoneFocus.dispose();
    companyFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final fullName = _sanitizeText(nameController.text.trim());
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final companyName = _sanitizeText(companyController.text.trim());

    // Validation stricte
    if (fullName.isEmpty || email.isEmpty) return;
    if (!RegExp(r"^[^@]+@[^@]+\.[^@]+$").hasMatch(email)) return;
    if (phone.isNotEmpty && !RegExp(r'^\+?[0-9]{6,15}$').hasMatch(phone))
      return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .updateProfile(
          fullName: fullName,
          email: email,
          phone: phone,
          companyName: companyName,
        );

    if (!mounted) return;

    if (!success) {
      final err = ref.read(authControllerProvider).error;
      if (err != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err)));
      }
    }
  }

  String _sanitizeText(String input) {
    // Supprime balises HTML et scripts
    return input.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  Future<void> _pickAvatar() async {
    if (!isEditing) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (image != null &&
        RegExp(
          r'\.(jpg|jpeg|png|gif)$',
          caseSensitive: false,
        ).hasMatch(image.name)) {
      final File pickedFile = File(image.path); // <-- crée l'objet File
      setState(() => _pickedImage = pickedFile);

      final userId = ref.read(authControllerProvider).user?.id;
      if (userId == null) return;

      // Appel du controller / repository avec File
      final success = await ref
          .read(authControllerProvider.notifier)
          .updateProfile(
            avatarUrl: pickedFile, // <-- maintenant c'est un File
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? "Photo mise à jour" : "Erreur lors de la mise à jour",
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fichier non valide")));
    }
  }

  // Future<void> _pickAvatar() async {
  //   if (!isEditing) return;

  //   final ImagePicker picker = ImagePicker();
  //   final XFile? image = await picker.pickImage(
  //     source: ImageSource.gallery,
  //     maxWidth: 800,
  //     maxHeight: 800,
  //     imageQuality: 80,
  //   );

  //   if (image != null &&
  //       RegExp(r'\.(jpg|jpeg|png|gif)$', caseSensitive: false)
  //           .hasMatch(image.name)) {
  //     setState(() => _pickedImage = File(image.path));
  //     final userId = ref.read(authControllerProvider).user?.id;
  //     if (userId == null) return;

  //     final success = await ref.read(authControllerProvider.notifier).updateProfile(
  //           avatarUrl: image.path, // pour le backend, utiliser multipart/form-data
  //         );

  //     if (!mounted) return;

  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: Text(success ? "Photo mise à jour" : "Erreur lors de la mise à jour")));
  //   } else {
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(const SnackBar(content: Text("Fichier non valide")));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;

    // On suppose que user.role contient "particulier" ou "entreprise"
    final isEntreprise = user?.accountType == 'entreprise';
    final isAdmin = user?.accountType == 'admin';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Mon profil"),
          actions: [
            IconButton(
              icon: Icon(isEditing ? Icons.close : Icons.edit),
              onPressed: () {
                setState(() => isEditing = !isEditing);
                if (!isEditing && user != null) {
                  // Rechargement des champs
                  nameController.text = user.fullName ?? "";
                  companyController.text = user.companyName ?? "";
                  emailController.text = user.email ?? "";
                  phoneController.text = user.phone ?? "";
                  _pickedImage = null;
                }
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: AppColors.primary,
                    backgroundImage: _pickedImage != null
                        ? FileImage(_pickedImage!)
                        : (user?.avatarUrl != null ? NetworkImage(url + user!.avatarUrl!) : null),
                    child: _pickedImage == null && (user?.avatarUrl == null)
                        ? const Icon(Icons.person, size: 55, color: Colors.white)
                        : null,
                  ),
                  if (isEditing)
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: GestureDetector(
                        onTap: _pickAvatar,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 30),

              // Affichage selon rôle
              if (isEntreprise) ...[
                _buildField(
                  "Nom de l'entreprise",
                  companyController,
                  companyFocus,
                ),
                const SizedBox(height: 12),
                _buildField(
                  "Nom du dirigeant",
                  nameController,
                  nameFocus,
                ),
              ] else if (isAdmin) ...[
                _buildField(
                  "Nom de l'entreprise",
                  companyController,
                  companyFocus,
                ),
                const SizedBox(height: 12),
                _buildField(
                  "Nom complet",
                  nameController,
                  nameFocus,
                ),
              ] else ...[
                _buildField(
                  "Nom complet",
                  nameController,
                  nameFocus,
                ),
              ],

              const SizedBox(height: 12),

              _buildField(
                "Email",
                emailController,
                emailFocus,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 12),

              _buildField(
                "Téléphone",
                phoneController,
                phoneFocus,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 30),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    FocusNode focusNode, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: isEditing,
      keyboardType: keyboardType,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
