import 'package:intl/intl.dart';
import 'package:mobile/data/models/bien_model.dart';

class ReservationWhatsappMessage {
  static String build({
    required BienModel bien,
    required String clientName,
    required String clientPhone,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? visitDate,
    String? message,
  }) {
    final df = DateFormat('dd/MM/yyyy');

    String dates = '';
    if (visitDate != null) {
      dates = '📅 Date de visite : ${df.format(visitDate)}';
    } else if (startDate != null && endDate != null) {
      dates =
          '📅 Du ${df.format(startDate)} au ${df.format(endDate)}';
    }

    return '''
Bonjour 👋

Je souhaite réserver le bien suivant :

🏠 *${bien.title}*
💰 Prix : ${bien.price.toStringAsFixed(0)} F
📍 Catégorie : ${bien.category}

👤 Client : $clientName
📞 Téléphone : $clientPhone

$dates

📝 Message :
${message ?? ""}

Merci 🙏
''';
  }
}
