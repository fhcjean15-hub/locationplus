import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/presentation/theme/colors.dart';
import '../../../../../business/providers/bien_controller_provider.dart';

class AddBiensScreen extends ConsumerStatefulWidget {
  const AddBiensScreen({super.key});

  @override
  ConsumerState<AddBiensScreen> createState() => _AddBiensScreenState();
}

class _AddBiensScreenState extends ConsumerState<AddBiensScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  List<XFile> selectedImages = [];

  /// ---------------- COMMON ----------------
  String category = "immobilier";
  String transactionType = "vente";
  String title = "";
  String description = "";
  String price = "";
  String city = "";

  /// ---------------- ATTRIBUTES ----------------
  Map<String, dynamic> attributes = {};

  /// Immobilier
  String surface = "";
  String rooms = "";
  String bathrooms = "";
  bool furnished = false;
  bool parking = false;
  bool electricity = false;
  bool water = false;

  /// Véhicule
  String brand = "";
  String model = "";
  String year = "";
  String fuel = "";
  String gearbox = "";
  String mileage = "";

  /// Meuble
  String meubleType = "";
  String material = "";
  String dimensions = "";
  String condition = "";

  /// Hôtel
  String roomType = "";
  String hotelCapacity = "";
  bool wifi = false;
  bool airConditioning = false;
  bool bathroomPrivate = false;

  /// Hébergement
  String bedrooms = "";
  String homeCapacity = "";
  bool kitchen = false;
  bool homeWifi = false;
  String rules = "";

  final categories = const {
    "immobilier": "Immobilier",
    "vehicule": "Véhicule",
    "meuble": "Meuble",
    "hotel": "Hôtel",
    "hebergement": "Hébergement",
  };

  @override
  Widget build(BuildContext context) {
    final biensAsync = ref.watch(bienControllerProvider);
    final isLoading = biensAsync is AsyncLoading;


    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ajouter un Bien",
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
            // ---------------- CATEGORIE ----------------
            _label("Catégorie"),
            DropdownButtonFormField(
              value: category,
              items: categories.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (val) => setState(() => category = val!),
              decoration: _input(),
            ),
            const SizedBox(height: 16),

            // ---------------- TRANSACTION ----------------
            _label("Type de transaction"),
              DropdownButtonFormField(
                value: transactionType,
                items: const [
                  DropdownMenuItem(value: "vente", child: Text("Vente")),
                  DropdownMenuItem(value: "location", child: Text("Location")),
                ],
                onChanged: (val) => setState(() => transactionType = val!),
                decoration: _input(),
              ),
              const SizedBox(height: 16),

            // ---------------- TITRE ----------------
            _label("Titre"),
            TextFormField(
              decoration: _input(hint: "Ex: Appartement moderne"),
              validator: _required,
              onChanged: (v) => title = v,
            ),
            const SizedBox(height: 16),

            // ---------------- DESCRIPTION ----------------
            _label("Description"),
            TextFormField(
              maxLines: 4,
              decoration: _input(),
              validator: _required,
              onChanged: (v) => description = v,
            ),
            const SizedBox(height: 16),

            // ---------------- PRIX ----------------
            _label("Prix"),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: _input(),
              validator: _required,
              onChanged: (v) => price = v,
            ),
            const SizedBox(height: 16),

            // ---------------- VILLE ----------------
            _label("Ville"),
            TextFormField(
              decoration: _input(hint: "Ex: Cotonou"),
              validator: _required,
              onChanged: (v) => city = v,
            ),
            const SizedBox(height: 16),
            
            // ================= ATTRIBUTES =================
            _buildAttributes(),
            const SizedBox(height: 16),

            // ---------------- IMAGES ----------------
            _label("Images"),
            const SizedBox(height: 8),
            FormField<List<XFile>>(
              initialValue: selectedImages,
              validator: (images) {
                if (images == null || images.isEmpty) {
                  return "Veuillez ajouter au moins une image";
                }
                return null;
              },
              builder: (field) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Bouton +
                        GestureDetector(
                          onTap: () async {
                            final images = await _picker.pickMultiImage(imageQuality: 80);
                            if (images.isNotEmpty) {
                              setState(() {
                                selectedImages.addAll(images);
                                field.didChange(selectedImages); // Met à jour le FormField
                              });
                            }
                          },
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.add_a_photo, color: Colors.grey),
                          ),
                        ),
                        // Images sélectionnées
                        ...selectedImages.map((image) => Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(image.path),
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: -6,
                                  right: -6,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red, size: 18),
                                    onPressed: () {
                                      setState(() {
                                        selectedImages.remove(image);
                                        field.didChange(selectedImages); // Met à jour le FormField
                                      });
                                    },
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ),
                    // Message d'erreur
                    if (field.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          field.errorText!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),

            // ---------------- SUBMIT ----------------
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Ajouter le bien",
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),
          ]),
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage(imageQuality: 80);
    if (images.isNotEmpty) {
      setState(() => selectedImages.addAll(images));
    }
  }

  /// ================= ATTRIBUTES UI =================
  Widget _buildAttributes() {
    switch (category) {
      case "immobilier":
        return Column(children: [
          _label("Surface (m²)"),
          _field((v) => surface = v),
          _label("Nombre de pièces"),
          _field((v) => rooms = v),
          _label("Nombre de salles de bain"),
          _field((v) => bathrooms = v),
          Row(
            children: [
              Checkbox(value: furnished,   activeColor: AppColors.primary,      // couleur du carré quand coché
  checkColor: Colors.white,       onChanged: (v) => setState(() => furnished = v!)),
              const Text("Meublé"),
              const SizedBox(width: 16),
              Checkbox(value: parking,   activeColor: AppColors.primary,      // couleur du carré quand coché
  checkColor: Colors.white,       onChanged: (v) => setState(() => parking = v!)),
              const Text("Parking"),
            ],
          ),
          Row(
            children: [
              Checkbox(value: electricity,   activeColor: AppColors.primary,      // couleur du carré quand coché
  checkColor: Colors.white,       onChanged: (v) => setState(() => electricity = v!)),
              const Text("Électricité"),
              const SizedBox(width: 16),
              Checkbox(value: water,   activeColor: AppColors.primary,      // couleur du carré quand coché
  checkColor: Colors.white,       onChanged: (v) => setState(() => water = v!)),
              const Text("Eau"),
            ],
          ),
        ]);

      case "vehicule":
        return Column(children: [
          _label("Marque"),
          _field((v) => brand = v),
          _label("Modèle"),
          _field((v) => model = v),
          _label("Année"),
          _field((v) => year = v),
          _label("Carburant"),
          _field((v) => fuel = v),
          _label("Boîte de vitesse"),
          _field((v) => gearbox = v),
          _label("Kilométrage"),
          _field((v) => mileage = v),
        ]);

      case "meuble":
        return Column(children: [
          _label("Type"),
          _field((v) => meubleType = v),
          _label("Matériau"),
          _field((v) => material = v),
          _label("Dimensions"),
          _field((v) => dimensions = v),
          _label("État"),
          _field((v) => condition = v),
        ]);

      case "hotel":
        return Column(children: [
          _label("Type de chambre"),
          _field((v) => roomType = v),
          _label("Capacité"),
          _field((v) => hotelCapacity = v),

          // Ligne 1 : Wifi + Climatisation
          Row(
            children: [
              Checkbox(value: wifi,   activeColor: AppColors.primary,      // couleur du carré quand coché
  checkColor: Colors.white,       onChanged: (v) => setState(() => wifi = v!)),
              const Text("Wifi"),
              const SizedBox(width: 16),
              Checkbox(value: airConditioning,   activeColor: AppColors.primary,      // couleur du carré quand coché
  checkColor: Colors.white,       onChanged: (v) => setState(() => airConditioning = v!)),
              const Text("Climatisation"),
            ],
          ),

          // Ligne 2 : Salle de bain privée
          Row(
            children: [
              Checkbox(value: bathroomPrivate, activeColor: AppColors.primary,   checkColor: Colors.white, onChanged: (v) => setState(() => bathroomPrivate = v!)),
              const Text("Salle de bain privée"),
            ],
          ),
        ]);


      case "hebergement":
        return Column(children: [
          _label("Nombre de chambres"),
          _field((v) => bedrooms = v),
          _label("Capacité"),
          _field((v) => homeCapacity = v),
          Row(
            children: [
              Checkbox(value: kitchen,   activeColor: AppColors.primary,   checkColor: Colors.white,   onChanged: (v) => setState(() => kitchen = v!)),
              const Text("Cuisine"),
              const SizedBox(width: 16),
              Checkbox(value: homeWifi,  activeColor: AppColors.primary, checkColor: Colors.white, onChanged: (v) => setState(() => homeWifi = v!)),
              const Text("Wifi"),
            ],
          ),
          _label("Règles"),
          _field((v) => rules = v),
        ]);

      default:
        return const SizedBox();
    }
  }

  /// ================= SUBMIT =================
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Construction des attributes
    switch (category) {
      case "immobilier":
        attributes = {
          "surface": double.parse(surface),
          "rooms": int.parse(rooms),
          "bathrooms": int.parse(bathrooms),
          "furnished": furnished,
          "parking": parking,
          "electricity": electricity,
          "water": water,
        };
        break;
      case "vehicule":
        attributes = {
          "brand": brand,
          "model": model,
          "year": int.parse(year),
          "fuel": fuel,
          "gearbox": gearbox,
          "mileage": int.parse(mileage),
        };
        break;
      case "meuble":
        attributes = {
          "type": meubleType,
          "material": material,
          "dimensions": dimensions,
          "condition": condition,
        };
        break;
      case "hotel":
        attributes = {
          "room_type": roomType,
          "capacity": int.parse(hotelCapacity),
          "wifi": wifi,
          "air_conditioning": airConditioning,
          "bathroom_private": bathroomPrivate,
        };
        break;
      case "hebergement":
        attributes = {
          "bedrooms": int.parse(bedrooms),
          "capacity": int.parse(homeCapacity),
          "kitchen": kitchen,
          "wifi": homeWifi,
          "rules": rules,
        };
        break;
    }

    final success = await ref.read(bienControllerProvider.notifier).createBien(
          category: category,
          transactionType: transactionType,
          title: title,
          description: description,
          price: double.parse(price),
          city: city,
          attributes: attributes,
          images: selectedImages,
        );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Bien ajouté avec succès"),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erreur lors de l’ajout du bien"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }



  /// ================= UI HELPERS =================
  Text _label(String text) => Text(text, style: const TextStyle(fontWeight: FontWeight.w600));

  String? _required(String? v) => v == null || v.isEmpty ? "Champ requis" : null;

  TextFormField _field(Function(String) onChanged) => TextFormField(
        decoration: _input(),
        validator: _required,
        onChanged: onChanged,
      );

  InputDecoration _input({String? hint}) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );
}







