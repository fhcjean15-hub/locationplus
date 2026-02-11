import 'user_model.dart';

class BienModel {
  final String id; // UUID Laravel
  final String category;
  final String transactionType;
  final String title;
  final double price;
  final String description;
  final String? city;
  final Map<String, dynamic> attributes;
  final List<String> images;
  final String? status;
  final bool actif;
  final String ownerName; // 🔥 pour affichage administrateur
  final String ownerAvatar; // 🔥 pour affichage administrateur
  final String ownerId; // 🔥 pour affichage administrateur

  /// 🔥 Nouveau : USER complet
  final User? user;

  /// UI ONLY
  bool expanded;

  BienModel({
    required this.id,
    required this.category,
    required this.transactionType,
    required this.title,
    required this.price,
    required this.description,
    this.city,
    required this.attributes,
    required this.images,
    required this.actif,
    required this.status,
    required this.ownerName,
    required this.ownerAvatar,
    required this.ownerId,
    this.user,
    this.expanded = false,
  });

  /// 🔹 Getter pratique pour le téléphone WhatsApp du propriétaire
  String get ownerWhatsapp {
    // Priorité : owner dans JSON
    if (user != null && user!.phone != null && user!.phone!.isNotEmpty) {
      return user!.phone!;
    }
    return '';
  }

  /// ================= FROM JSON =================
  factory BienModel.fromJson(Map<String, dynamic> json) {
    // -------------------- IMAGES --------------------
    List<String> parsedImages = [];
    if (json['images'] != null) {
      if (json['images'] is List) {
        parsedImages = List<String>.from(
          json['images'].map((e) => e.toString()),
        );
      } else if (json['images'] is Map && json['images']['url'] != null) {
        parsedImages = [json['images']['url'].toString()];
      } else if (json['images'] is String) {
        parsedImages = [json['images']];
      }
    }
    

    // -------------------- ATTRIBUTES --------------------
    Map<String, dynamic> parsedAttributes = {};
    if (json['attributes'] != null && json['attributes'] is Map) {
      parsedAttributes = Map<String, dynamic>.from(json['attributes']);
    }

    // -------------------- OWNER NAME --------------------
    String ownerName = '';
    String ownerAvatar = '';
    String ownerId = '';
    if (json['owner'] != null && json['owner'] is Map) {
      final owner = json['owner'] as Map;
      ownerName = owner['name'] ?? '';
      ownerAvatar = owner['avatar_url'] ?? '';
      ownerId = owner['id'] ?? '';
    } else if (json['user'] != null && json['user'] is Map) {
      final userFallback = json['user'] as Map;
      if ((userFallback['account_type'] ?? '') == 'company') {
        ownerName = userFallback['company_name'] ?? '';
      } else {
        ownerName = userFallback['full_name'] ?? '';
      }
    }

    // -------------------- USER COMPLET --------------------
    User? userMap;
    if (json['owner'] != null && json['owner'] is Map) {
      final ownerMap = json['owner'] as Map<String, dynamic>;
      userMap = ownerMap['user'] != null ? User.fromJson(Map<String, dynamic>.from(ownerMap['user'])) : null;
    }

    return BienModel(
      id: json['id'].toString(),
      category: json['category'] ?? '',
      transactionType: json['transaction_type'] ?? '',
      title: json['title'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      city: json['city'],
      attributes: parsedAttributes,
      images: parsedImages,
      actif: json['actif'] == true || json['actif'] == 1,
      status: json['status'],
      ownerName: ownerName,
      ownerAvatar: ownerAvatar,
      ownerId: ownerId,
      user: userMap,
      expanded: false,
    );
  }

  /// ================= TO JSON =================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'transaction_type': transactionType,
      'title': title,
      'price': price,
      'description': description,
      'city': city,
      'attributes': attributes,
      'images': images,
      'actif': actif,
      'status': status,
      'ownerName': ownerName,
      'ownerAvatar': ownerAvatar,
      'ownerId': ownerId,
      'user': user,
    };
  }
}
