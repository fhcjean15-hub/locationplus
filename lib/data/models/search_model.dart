import 'package:mobile/data/models/bien_model.dart';

class SearchResultModel {
  final String id;
  final String type; // bien | user | company | vehicle | hotel ...
  final String title;
  final String? subtitle;
  final double? price;
  final String? location;
  final Map<String, dynamic> attributes;
  final String? imageUrl;

  SearchResultModel({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.price,
    this.location,
    this.attributes = const {},
    this.imageUrl,
  });

  // factory SearchResultModel.fromJson(Map<String, dynamic> json) {
  //   return SearchResultModel(
  //     id: json['id'].toString(),
  //     type: json['type'] ?? 'unknown',
  //     title: json['title'] ?? '',
  //     subtitle: json['subtitle'],
  //     price: json['price'] != null
  //         ? double.tryParse(json['price'].toString())
  //         : null,
  //     location: json['location'],
  //     attributes: Map<String, dynamic>.from(json['attributes'] ?? {}),
  //     imageUrl: json['image_url'],
  //   );
  // }

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    return SearchResultModel(
      id: data['id'].toString(),
      type: json['type'] ?? 'unknown',
      title: data['title'] ?? '',
      subtitle: data['city'],
      price: data['price'] != null
          ? double.tryParse(data['price'].toString())
          : null,
      location: data['city'],
      attributes: Map<String, dynamic>.from(data),
      imageUrl:
          (data['images'] != null &&
              data['images'] is List &&
              data['images'].isNotEmpty)
          ? data['images'][0] // ✅ première image
          : null,
    );
  }
}
