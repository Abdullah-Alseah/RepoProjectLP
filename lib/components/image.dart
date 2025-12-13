import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'نسخ الصور',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: ImageCopyPage(),
//     );
//   }
// }

class ImageCopyPage extends StatefulWidget {
  @override
  _ImageCopyPageState createState() => _ImageCopyPageState();
}

class _ImageCopyPageState extends State<ImageCopyPage> {
  File? _selectedImage;
  String? _destinationPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('نسخ الصور إلى مجلد')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // عرض الصورة المختارة
            _selectedImage != null
                ? Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                  )
                : Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.image, size: 50, color: Colors.grey),
                  ),

            SizedBox(height: 20),

            // زر اختيار الصورة
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.photo_library),
              label: Text('اختر صورة'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),

            SizedBox(height: 20),

            // عرض المسار المختار
            if (_destinationPath != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'المجلد الهدف: $_destinationPath',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),

            SizedBox(height: 20),

            // زر اختيار المجلد الهدف
            ElevatedButton.icon(
              onPressed: _selectDestinationFolder,
              icon: Icon(Icons.folder_open),
              label: Text('اختر مجلد الهدف'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),

            SizedBox(height: 20),

            // زر نسخ الصورة
            ElevatedButton.icon(
              onPressed: _selectedImage != null && _destinationPath != null
                  ? _copyImage
                  : null,
              icon: Icon(Icons.copy),
              label: Text('نسخ الصورة إلى المجلد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة لاختيار الصورة
  Future<void> _pickImage() async {
    // طلب إذن الوصول إلى الصور
    var status = await Permission.photos.request();

    if (status.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        _showToast('تم اختيار الصورة بنجاح');
      }
    } else {
      _showToast('يجب منح إذن الوصول إلى الصور');
    }
  }

  // دالة لاختيار المجلد الهدف
  Future<void> _selectDestinationFolder() async {
    // طلب إذن التخزين
    var status = await Permission.storage.request();

    if (status.isGranted) {
      // يمكنك استخدام file_picker لاختيار مجلد
      // لكن لتبسيط المثال سنستخدم مجلد مستندات التطبيق

      // للحصول على مجلد في التخزين الخارجي (لأندرويد/iOS)
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        // إنشاء مجلد فرعي
        final newDir = Directory('${directory.path}/MyCopiedImages');
        if (!await newDir.exists()) {
          await newDir.create(recursive: true);
        }

        setState(() {
          _destinationPath = newDir.path;
        });
        _showToast('تم اختيار المجلد: ${newDir.path}');
      }
    } else {
      _showToast('يجب منح إذن التخزين');
    }
  }

  // دالة لنسخ الصورة
  Future<void> _copyImage() async {
    if (_selectedImage == null || _destinationPath == null) {
      _showToast('يرجى اختيار صورة ومجلد أولاً');
      return;
    }

    try {
      final sourceFile = _selectedImage!;
      final fileName = path.basename(sourceFile.path);
      final destPath = '$_destinationPath/$fileName';
      final destFile = File(destPath);

      // نسخ الملف
      await sourceFile.copy(destPath);

      _showToast('تم نسخ الصورة بنجاح إلى: $destPath');

      // تحديث الواجهة
      setState(() {
        // يمكنك إضافة أي تحديثات إضافية هنا
      });
    } catch (e) {
      _showToast('خطأ في نسخ الصورة: $e');
    }
  }

  // دالة لعرض رسائل Toast
  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
