import 'package:mobile/data/models/bien_model.dart';
import 'package:mobile/data/models/search_model.dart';


const Map<String, List<String>> allowedAttributesByCategory = {
  'immobilier': [
    'surface',
    'rooms',
    'bathrooms',
    'bedrooms',
    'furnished',
    'parking',
    'electricity',
    'water',
  ],
  'meuble': [
    'material',
    'dimensions',
    'condition',
    'brand',
  ],
  'vehicule': [
    'brand',
    'model',
    'year',
    'fuel',
    'gearbox',
    'mileage',
  ],
  'hotel': [
    'room_type',
    'capacity',
    'wifi',
    'air_conditioning',
    'bathroom_private',
  ],
};


Map<String, dynamic> _filteredAttributes(
  String category,
  Map<String, dynamic> data,
) {
  final allowedKeys = allowedAttributesByCategory[category] ?? [];

  return Map.fromEntries(
    data.entries.where((e) => allowedKeys.contains(e.key)),
  );
}



extension SearchResultToBien on SearchResultModel {
  // BienModel toBienModel() {
  //   return BienModel(
  //     id: id,
  //     category: attributes['category'] ?? '',
  //     transactionType: attributes['transaction_type'] ?? '',
  //     title: title,
  //     price: price ?? 0.0,
  //     description: attributes['description'] ?? '',
  //     city: location,
  //     attributes: Map<String, dynamic>.from(attributes),
  //     images: attributes['images'] != null && attributes['images'] is List
  //         ? List<String>.from(attributes['images'])
  //         : imageUrl != null
  //             ? [imageUrl!]
  //             : [],
  //     actif: attributes['actif'] == true || attributes['actif'] == 1,
  //     status: attributes['status'],
  //     ownerName: _resolveOwnerName(),
  //     ownerAvatar: _resolveOwnerAvatar(),
  //     ownerId: _resolveOwnerId(),
  //     user: null, // ⚠️ non disponible depuis la recherche
  //     expanded: false,
  //   );
  // }

  BienModel toBienModel() {
    final category = attributes['category'] ?? '';

    return BienModel(
      id: id,
      category: category,
      transactionType: attributes['transaction_type'] ?? '',
      title: title,
      price: price ?? 0.0,
      description: attributes['description'] ?? '',
      city: location,
      attributes: _filteredAttributes(category, attributes), // 🔥 FIX
      images: attributes['images'] != null && attributes['images'] is List
          ? List<String>.from(attributes['images'])
          : imageUrl != null
              ? [imageUrl!]
              : [],
      actif: attributes['actif'] == true || attributes['actif'] == 1,
      status: attributes['status'],
      ownerName: _resolveOwnerName(),
      ownerAvatar: _resolveOwnerAvatar(),
      ownerId: _resolveOwnerId(),
      user: null,
    );
    }


  // ================= HELPERS =================

  String _resolveOwnerName() {
    final owner = attributes['owner'];
    if (owner is Map) {
      return owner['name'] ?? '';
    }
    return '';
  }

  String _resolveOwnerAvatar() {
    final owner = attributes['owner'];
    if (owner is Map) {
      return owner['avatar_url'] ?? '';
    }
    return '';
  }

  String _resolveOwnerId() {
    final owner = attributes['owner'];
    if (owner is Map) {
      return owner['id']?.toString() ?? '';
    }
    return '';
  }
}
