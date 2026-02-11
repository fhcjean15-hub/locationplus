import 'dart:convert';

class User {
  final String id;
  final String? fullName;
  final String? companyName;
  final String email;
  final String? phone;
  final String accountType; // particulier | entreprise | admin
  final int? accountCategoryId;
  final List<String>? documentsUrls;
  final bool verifiedDocuments;
  final bool activated;
  final String paymentStatus; // none | pending | paid
  final String? avatarUrl;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Champs supplémentaires
  final String? ifu;
  final String? address;
  final String? ville;
  final DateTime? paymentValidUntil;

  User({
    required this.id,
    required this.fullName,
    required this.companyName,
    required this.email,
    required this.phone,
    required this.accountType,
    required this.accountCategoryId,
    required this.documentsUrls,
    required this.verifiedDocuments,
    required this.activated,
    required this.paymentStatus,
    required this.avatarUrl,
    required this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.ifu,
    required this.address,
    required this.ville,
    this.paymentValidUntil,
  });

  // -------------------------------------------------------
  // COPYWITH → permet de modifier les champs individuellement
  // -------------------------------------------------------
  User copyWith({
    String? id,
    String? fullName,
    String? companyName,
    String? email,
    String? phone,
    String? accountType,
    int? accountCategoryId,
    List<String>? documentsUrls,
    bool? verifiedDocuments,
    bool? activated,
    String? paymentStatus,
    String? avatarUrl,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? ifu,
    String? address,
    String? ville,
    DateTime? paymentValidUntil,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      accountType: accountType ?? this.accountType,
      accountCategoryId: accountCategoryId ?? this.accountCategoryId,
      documentsUrls: documentsUrls ?? this.documentsUrls,
      verifiedDocuments: verifiedDocuments ?? this.verifiedDocuments,
      activated: activated ?? this.activated,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ifu: ifu ?? this.ifu,
      address: address ?? this.address,
      ville: ville ?? this.ville,
      paymentValidUntil: paymentValidUntil ?? this.paymentValidUntil,
    );
  }

  // -------------------------------------------------------
  // FROM JSON
  // -------------------------------------------------------
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      fullName: json["full_name"],
      companyName: json["company_name"],
      email: json["email"],
      phone: json["phone"]?.toString(),
      accountType: json["account_type"],
      accountCategoryId: json["account_category_id"] is int
          ? json["account_category_id"]
          : int.tryParse(json["account_category_id"]?.toString() ?? ''),

      documentsUrls: json["documents_urls"] != null
          ? List<String>.from(
              json["documents_urls"].map((e) => e.toString()),
            )
          : null,
      verifiedDocuments: json["verified_documents"] ?? false,
      activated: json["activated"] ?? false,
      paymentStatus: json["payment_status"] ?? 'none',
      avatarUrl: json["avatar_url"],
      emailVerifiedAt: json["email_verified_at"] != null
          ? DateTime.parse(json["email_verified_at"])
          : null,
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
      ifu: json["ifu"]?.toString(),
      address: json["adresse"],
      ville: json["ville"],
      paymentValidUntil: json["payment_valid_until"] != null
          ? DateTime.parse(json["payment_valid_until"])
          : null,
    );
  }

  // -------------------------------------------------------
  // TO JSON
  // -------------------------------------------------------
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "full_name": fullName,
      "company_name": companyName,
      "email": email,
      "phone": phone,
      "account_type": accountType,
      "account_category_id": accountCategoryId,
      "documents_urls": documentsUrls,
      "verified_documents": verifiedDocuments,
      "activated": activated,
      "payment_status": paymentStatus,
      "avatar_url": avatarUrl,
      "email_verified_at": emailVerifiedAt?.toIso8601String(),
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
      "ifu": ifu,
      "adresse": address,
      "ville": ville,
      "payment_valid_until": paymentValidUntil?.toIso8601String(),
    };
  }
}
