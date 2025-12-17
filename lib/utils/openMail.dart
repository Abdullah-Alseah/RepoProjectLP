import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


Future<void> openMail() async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: 'info@marsa.com',
    query: 'subject=رسالة من تطبيق',
  );

  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
  } else {
    throw 'لا يمكن فتح تطبيق البريد';
  }
}
