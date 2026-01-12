import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openMail({
  String recipient = 'info@marsa.com',
  String subject = 'رسالة من تطبيق',
  String? body,
  List<String>? cc,
  List<String>? bcc,
}) async {
  // بناء المعاملات
  final Map<String, String> queryParams = {'subject': subject};

  if (body != null && body.isNotEmpty) {
    queryParams['body'] = body;
  }

  if (cc != null && cc.isNotEmpty) {
    queryParams['cc'] = cc.join(',');
  }

  if (bcc != null && bcc.isNotEmpty) {
    queryParams['bcc'] = bcc.join(',');
  }

  // إنشاء الـ URI
  final Uri mailtoUri = Uri(
    scheme: 'mailto',
    path: recipient,
    queryParameters: queryParams,
  );

  // محاولة الإرسال
  try {
    if (await canLaunchUrl(mailtoUri)) {
      await launchUrl(mailtoUri);
    } else {
      throw 'لا يمكن فتح تطبيق البريد';
    }
  } catch (e) {
    throw 'خطأ في إرسال البريد: $e';
  }
}
Future<void> openWhatsApp(String phoneNumber, {String? message}) async {
  // تنظيف رقم الهاتف (إزالة الأصفار والرموز)
  String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

  // بناء رابط WhatsApp
  String url;
  if (message != null && message.isNotEmpty) {
    final encodedMessage = Uri.encodeComponent(message);
    url = 'https://wa.me/$cleanedNumber?text=$encodedMessage';
  } else {
    url = 'https://wa.me/$cleanedNumber';
  }

  final Uri whatsappUri = Uri.parse(url);

  try {
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      // محاولة مع الرابط البديل
      final Uri altUri = Uri.parse('whatsapp://send?phone=$cleanedNumber');
      if (await canLaunchUrl(altUri)) {
        await launchUrl(altUri);
      } else {
        throw 'تطبيق WhatsApp غير مثبت';
      }
    }
  } catch (e) {
    print('خطأ في فتح WhatsApp: $e');
    rethrow;
  }
}