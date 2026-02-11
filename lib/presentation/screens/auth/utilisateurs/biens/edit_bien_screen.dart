import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/business/providers/bien_controller_provider.dart';
import 'package:mobile/data/models/bien_model.dart';
import 'package:mobile/presentation/theme/colors.dart';

class EditBiensScreen extends ConsumerStatefulWidget {
  final BienModel bien;

  const EditBiensScreen({super.key, required this.bien});

  @override
  ConsumerState<EditBiensScreen> createState() => _EditBiensScreenState();
}

class _EditBiensScreenState extends ConsumerState<EditBiensScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  /// Images
  List<XFile> newImages = [];
  late List<String> existingImages;
  
  final baseUrl = "https://api-location-plus.lamadonebenin.com/storage/";

  /// COMMON
  late String category;
  late String transactionType;
  late String title;
  late String description;
  late String price;
  late String city;

  /// ATTRIBUTES
  Map<String, dynamic> attributes = {};

  // Immobilier
  String surface = "";
  String rooms = "";
  String bathrooms = "";
  bool furnished = false;
  bool parking = false;
  bool electricity = false;
  bool water = false;

  // Véhicule
  String brand = "";
  String model = "";
  String year = "";
  String fuel = "";
  String gearbox = "";
  String mileage = "";

  // Meuble
  String meubleType = "";
  String material = "";
  String dimensions = "";
  String condition = "";

  // Hôtel
  String roomType = "";
  String hotelCapacity = "";
  bool wifi = false;
  bool airConditioning = false;
  bool bathroomPrivate = false;

  // Hébergement
  String bedrooms = "";
  String homeCapacity = "";
  bool kitchen = false;
  bool homeWifi = false;
  String rules = "";

  @override
  void initState() {
    super.initState();

    final b = widget.bien;

    category = b.category;
    transactionType = b.transactionType;
    title = b.title;
    description = b.description;
    price = b.price.toString();
    city = b.city ?? "";
    attributes = Map<String, dynamic>.from(b.attributes);

    existingImages = List<String>.from(b.images);

    bool parseBool(dynamic val) => val == true || val == 1 || val == "1";

    /// Pré-remplissage des attributs
    surface = attributes["surface"]?.toString() ?? "";
    rooms = attributes["rooms"]?.toString() ?? "";
    bathrooms = attributes["bathrooms"]?.toString() ?? "";
    furnished = parseBool(attributes["furnished"]);
    parking = parseBool(attributes["parking"]);
    electricity = parseBool(attributes["electricity"]);
    water = parseBool(attributes["water"]);

    brand = attributes["brand"] ?? "";
    model = attributes["model"] ?? "";
    year = attributes["year"]?.toString() ?? "";
    fuel = attributes["fuel"] ?? "";
    gearbox = attributes["gearbox"] ?? "";
    mileage = attributes["mileage"]?.toString() ?? "";

    meubleType = attributes["type"] ?? "";
    material = attributes["material"] ?? "";
    dimensions = attributes["dimensions"] ?? "";
    condition = attributes["condition"] ?? "";

    roomType = attributes["room_type"] ?? "";
    hotelCapacity = attributes["capacity"]?.toString() ?? "";
    wifi = parseBool(attributes["wifi"]);
    airConditioning = parseBool(attributes["air_conditioning"]);
    bathroomPrivate = parseBool(attributes["bathroom_private"]);

    bedrooms = attributes["bedrooms"]?.toString() ?? "";
    homeCapacity = attributes["capacity"]?.toString() ?? "";
    kitchen = parseBool(attributes["kitchen"]);
    homeWifi = parseBool(attributes["wifi"]);
    rules = attributes["rules"] ?? "";
  }


  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(bienControllerProvider) is AsyncLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier le bien", style: TextStyle(color: AppColors.textDark)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _label("Titre"),
            _field((v) => title = v, initialValue: title),

            _label("Description"),
            _field((v) => description = v, initialValue: description, maxLines: 4),

            _label("Prix"),
            _field((v) => price = v, initialValue: price, keyboard: TextInputType.number),

            if (category != "meuble") ...[
              _label("Ville"),
              _field((v) => city = v, initialValue: city),
            ],

            const SizedBox(height: 16),
            _buildAttributes(),

            const SizedBox(height: 16),
            _label("Images existantes"),
            Wrap(
              spacing: 8,
              children: existingImages.map((url) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(baseUrl + url, width: 90, height: 90, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red, size: 18),
                        onPressed: () => setState(() => existingImages.remove(url)),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),

            const SizedBox(height: 12),
            _label("Ajouter des images"),
            Wrap(
              spacing: 8,
              children: [
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add_a_photo),
                  ),
                ),
                ...newImages.map((img) => Image.file(File(img.path), width: 90, height: 90, fit: BoxFit.cover)),
              ],
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Mettre à jour", style: TextStyle(color: Colors.white)),
              ),
            )
          ]),
        ),
      ),
    );
  }

  /// ================= SUBMIT =================
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(bienControllerProvider.notifier).updateBien(
          id: int.parse(widget.bien.id.toString()),
          title: title,
          description: description,
          price: double.parse(price),
          city: city,
          attributes: attributes,
          newImages: newImages,
          keepImages: existingImages,
        );

    if (mounted && success) {
      Navigator.pop(context);
    }
  }

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage(imageQuality: 80);
    if (images.isNotEmpty) setState(() => newImages.addAll(images));
  }

  /// ================= HELPERS =================
  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
      );

  TextFormField _field(
    Function(String) onChanged, {
    String? initialValue,
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) =>
      TextFormField(
        initialValue: initialValue,
        maxLines: maxLines,
        keyboardType: keyboard,
        validator: (v) => v == null || v.isEmpty ? "Champ requis" : null,
        onChanged: onChanged,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      );

  Widget _buildAttributes() {
    // 👉 Tu peux réutiliser EXACTEMENT la même méthode que AddBiensScreen
    return const SizedBox(); // volontairement simplifié ici
  }
}



