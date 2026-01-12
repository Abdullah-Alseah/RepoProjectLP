import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> callNumber(String phoneNumber) async {
  final Uri phoneUri = Uri.parse('tel:$phoneNumber');

  try {
    // استخدم launchUrl مباشرة بدون canLaunchUrl
    await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
  } catch (e) {
    print('خطأ في الاتصال: $e');
    // _showAlternativeDialog(phoneNumber);
  }
}

void _showAlternativeDialog(BuildContext context, String number) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('الرجاء الاتصال يدوياً'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الرقم: $number'),
          SizedBox(height: 20),
          Text('يمكنك:'),
          SizedBox(height: 10),
          Text('1. نسخ الرقم والاتصال يدوياً'),
          Text('2. فتح تطبيق الهاتف وإدخال الرقم'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            // Clipboard.setData(ClipboardData(text: number));
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('تم نسخ الرقم')));
          },
          child: Text('نسخ الرقم'),
        ),
      ],
    ),
  );
}
