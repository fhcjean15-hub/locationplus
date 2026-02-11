class NotificationModel {
  final String id;
  final String type;
  final Map<String, dynamic> payload;
  final bool read;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.payload,
    required this.read,
    required this.createdAt,
  });

  // ================= FROM JSON =================
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      payload: Map<String, dynamic>.from(json['payload'] ?? {}),
      read: json['read'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  // ================= HELPERS =================

  /// Message principal à afficher
  String get message {
    if (payload['note'] != null) {
      return payload['note'];
    }

    switch (type) {
      case 'paiement':
        return "Un paiement a été effectué avec succès.";
      case 'demande':
        return "Vous avez reçu une nouvelle demande.";
      case 'signalement':
        return "Un signalement a été effectué.";
      case 'admin_action':
        return "Une action administrative a été effectuée sur votre compte.";
      case 'compte_validé':
        return "Votre compte a été validé.";
      case 'compte_rejeté':
        return "Votre compte a été rejeté.";
      default:
        return "Nouvelle notification.";
    }
  }

  /// Icône selon le type
  String get iconType => type;

  /// Date formatée
  String get formattedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}/'
        '${createdAt.month.toString().padLeft(2, '0')}/'
        '${createdAt.year}';
  }
}
