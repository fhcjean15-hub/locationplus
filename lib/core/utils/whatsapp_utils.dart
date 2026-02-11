import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppUtils {
  static Future<void> sendMessage({
    required String phone, // +229XXXXXXXX
    required String message,
  }) async {
    final cleanPhone = phone.replaceAll(' ', '');

    final encodedMessage = Uri.encodeComponent(message);

    final url = Platform.isIOS
        ? 'https://wa.me/$cleanPhone?text=$encodedMessage'
        : 'https://api.whatsapp.com/send?phone=$cleanPhone&text=$encodedMessage';

    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Impossible d’ouvrir WhatsApp';
    }
  }
}




class WhatsAppUtilsMesReservation {
  static Future<void> sendMessage({
    required String phone, // +229XXXXXXXX
  }) async {
    final cleanPhone = phone.replaceAll(' ', '');

    final url = Platform.isIOS
        ? 'https://wa.me/$cleanPhone'
        : 'https://api.whatsapp.com/send?phone=$cleanPhone';

    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Impossible d’ouvrir WhatsApp';
    }
  }
}
