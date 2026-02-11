import 'dart:convert';

import 'package:mobile/data/models/bien_model.dart';

class ReservationModel {
  final String id;
  final int bienId;
  final String? userId;
  final String ownerId;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final String category;
  final String transactionType;
  final String reservationType;
  final double price;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? visitDate;
  final String? message;
  final String? status;
  final String? trackingToken;
  final DateTime createdAt;
  final DateTime updatedAt;
  final BienModel? bien;

  ReservationModel({
    required this.id,
    required this.bienId,
    this.userId,
    required this.ownerId,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.category,
    required this.transactionType,
    required this.reservationType,
    required this.price,
    this.startDate,
    this.endDate,
    this.visitDate,
    this.message,
    this.status,
    this.trackingToken,
    required this.createdAt,
    required this.updatedAt,
    this.bien, // 👈 AJOUT
  });

  /// ================= FROM JSON =================
  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    final client = json['client'] ?? {};
    final dates = json['dates'] ?? {};

    return ReservationModel(
      id: json['id']?.toString() ?? '',
      bienId: json['bien_id'] is int ? json['bien_id'] : int.tryParse(json['bien_id'].toString()) ?? 0,
      userId: json['user_id']?.toString(),
      ownerId: json['owner_id']?.toString() ?? '',
      clientName: client['name'] ?? '',
      clientEmail: client['email'] ?? '',
      clientPhone: client['phone'] ?? '',
      category: json['category'] ?? '',
      transactionType: json['transaction_type'] ?? '',
      reservationType: json['reservation_type'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      startDate: dates['start'] != null ? DateTime.tryParse(dates['start']) : null,
      endDate: dates['end'] != null ? DateTime.tryParse(dates['end']) : null,
      visitDate: dates['visit'] != null ? DateTime.tryParse(dates['visit']) : null,
      message: json['message'],
      status: json['status'],
      trackingToken: json['tracking_token']?.toString(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      
      // 🔥 BIEN (relation)
      bien: json['bien'] != null
          ? BienModel.fromJson(json['bien'])
          : null,
    );
  }

  /// ================= TO JSON =================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bien_id': bienId,
      'user_id': userId,
      'owner_id': ownerId,
      'client_name': clientName,
      'client_email': clientEmail,
      'client_phone': clientPhone,
      'category': category,
      'transaction_type': transactionType,
      'reservation_type': reservationType,
      'price': price,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'visit_date': visitDate?.toIso8601String(),
      'message': message,
      'status': status,
      'tracking_token': trackingToken,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}






// import 'dart:convert';

// class ReservationModel {
//   final String id;
//   final int bienId;
//   final String? userId;
//   final String ownerId;
//   final String clientName;
//   final String clientEmail;
//   final String clientPhone;
//   final String category;
//   final String transactionType;
//   final String reservationType;
//   final double price;
//   final DateTime? startDate;
//   final DateTime? endDate;
//   final DateTime? visitDate;
//   final String? message;
//   final String status;
//   final String? trackingToken;
//   final DateTime createdAt;
//   final DateTime updatedAt;

//   ReservationModel({
//     required this.id,
//     required this.bienId,
//     this.userId,
//     required this.ownerId,
//     required this.clientName,
//     required this.clientEmail,
//     required this.clientPhone,
//     required this.category,
//     required this.transactionType,
//     required this.reservationType,
//     required this.price,
//     this.startDate,
//     this.endDate,
//     this.visitDate,
//     this.message,
//     required this.status,
//     this.trackingToken,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory ReservationModel.fromJson(Map<String, dynamic> json) {
//     return ReservationModel(
//       id: json['id'],
//       bienId: json['bien_id'],
//       userId: json['user_id'],
//       ownerId: json['owner_id'],
//       clientName: json['client']['name'],
//       clientEmail: json['client']['email'],
//       clientPhone: json['client']['phone'],
//       category: json['category'],
//       transactionType: json['transaction_type'],
//       reservationType: json['reservation_type'],
//       price: (json['price'] as num).toDouble(),
//       startDate: json['dates']['start'] != null ? DateTime.parse(json['dates']['start']) : null,
//       endDate: json['dates']['end'] != null ? DateTime.parse(json['dates']['end']) : null,
//       visitDate: json['dates']['visit'] != null ? DateTime.parse(json['dates']['visit']) : null,
//       message: json['message'],
//       status: json['status'],
//       trackingToken: json['tracking_token'],
//       createdAt: DateTime.parse(json['created_at']),
//       updatedAt: DateTime.parse(json['updated_at']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'bien_id': bienId,
//       'user_id': userId,
//       'owner_id': ownerId,
//       'client_name': clientName,
//       'client_email': clientEmail,
//       'client_phone': clientPhone,
//       'category': category,
//       'transaction_type': transactionType,
//       'reservation_type': reservationType,
//       'price': price,
//       'start_date': startDate?.toIso8601String(),
//       'end_date': endDate?.toIso8601String(),
//       'visit_date': visitDate?.toIso8601String(),
//       'message': message,
//       'status': status,
//       'tracking_token': trackingToken,
//     };
//   }
// }
