import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:fluttertoast/fluttertoast.dart';

class ImageCopyPage extends StatefulWidget {
  @override
  _ImageCopyPageState createState() => _ImageCopyPageState();
}

class _ImageCopyPageState extends State<ImageCopyPage> {
  File? _selectedImage;
  bool _isWeb = false;

  // المسار الثابت للمجلد الهدف
  final String _destinationPath = '/home/alseahy/Desktop/New Folder';
  final String _newFileName = 'newPic';
  bool _isCopying = false;

  @override
  void initState() {
    super.initState();
    _isWeb = kIsWeb;

    if (!_isWeb) {
      _initializeDestination();
    }
  }

  Future<void> _initializeDestination() async {
    try {
      // التحقق من وجود المجلد وإنشاؤه إذا لزم الأمر
      final directory = Directory(_destinationPath);

      if (!await directory.exists()) {
        print('المجلد غير موجود، جاري الإنشاء...');
        await directory.create(recursive: true);
        print('تم إنشاء المجلد: ${directory.path}');

        // التحقق من الصلاحيات
        final testFile = File('${directory.path}/test.txt');
        await testFile.writeAsString('test');
        await testFile.delete();
        print('الصلاحيات جيدة');
      } else {
        print('المجلد موجود بالفعل: ${directory.path}');

        // التحقق من إمكانية الكتابة
        final testFile = File('${directory.path}/test_permission.txt');
        try {
          await testFile.writeAsString('test');
          await testFile.delete();
          print('إمكانية الكتابة جيدة');
        } catch (e) {
          print('خطأ في الصلاحيات: $e');
          _showToast('لا يمكن الكتابة في المجلد، تحقق من الصلاحيات');
        }
      }
    } catch (e) {
      print('خطأ في تهيئة المجلد: $e');
      _showToast('خطأ في الوصول إلى المجلد الهدف: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('نسخ الصورة إلى سطح المكتب')),
      body: Center(
        child: SingleChildScrollView(
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
                      child: _isWeb
                          ? Image.network(
                              _selectedImage!.path,
                              fit: BoxFit.cover,
                            )
                          : Image.file(_selectedImage!, fit: BoxFit.cover),
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
                onPressed: _isCopying ? null : _pickImage,
                icon: _isCopying
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.photo_library),
                label: Text(_isCopying ? 'جاري النسخ...' : 'اختر صورة'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),

              SizedBox(height: 20),

              // معلومات المسار
              Card(
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'مسار الحفظ:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: SelectableText(
                          _destinationPath,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Monospace',
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo, color: Colors.green, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'اسم الملف: $_newFileName',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // زر إعادة المحاولة يدوياً
              if (_selectedImage != null && !_isWeb)
                ElevatedButton.icon(
                  onPressed: _isCopying ? null : _copyImageManually,
                  icon: Icon(Icons.refresh),
                  label: Text('نسخ يدوي'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),

              SizedBox(height: 20),

              // زر لفتح المجلد (للمنصات غير الويب)
              if (!_isWeb)
                OutlinedButton.icon(
                  onPressed: _openDestinationFolder,
                  icon: Icon(Icons.open_in_browser),
                  label: Text('فتح المجلد'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        _showToast('تم اختيار الصورة: ${path.basename(pickedFile.path)}');

        // نسخ الصورة تلقائياً
        if (!_isWeb) {
          await _copyImage();
        }
      }
    } catch (e) {
      _showToast('خطأ في اختيار الصورة: $e');
      print('خطأ pickImage: $e');
    }
  }

  Future<void> _copyImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isCopying = true;
    });

    try {
      // التحقق من وجود الصورة المختارة
      final sourceFile = _selectedImage!;
      if (!await sourceFile.exists()) {
        throw Exception('الصورة المختارة غير موجودة');
      }

      // إنشاء المجلد إذا لم يكن موجوداً
      final destinationDir = Directory(_destinationPath);
      if (!await destinationDir.exists()) {
        print('إنشاء المجلد...');
        await destinationDir.create(recursive: true);
      }

      // الحصول على امتداد الملف
      final originalExtension = path.extension(sourceFile.path);
      final newFileName = '$_newFileName$originalExtension';
      final destPath = '$_destinationPath/$newFileName';

      print('المصدر: ${sourceFile.path}');
      print('الهدف: $destPath');
      print('حجم الملف: ${await sourceFile.length()} بايت');

      // نسخ الملف
      print('بدء النسخ...');
      await sourceFile.copy(destPath);
      print('تم النسخ بنجاح!');

      // التحقق من الملف المنسوخ
      final copiedFile = File(destPath);
      if (await copiedFile.exists()) {
        final fileSize = await copiedFile.length();
        print('تم التحقق: الملف المنسوخ موجود - الحجم: $fileSize بايت');

        _showToast('تم نسخ الصورة بنجاح ✓');

        // عرض تأكيد
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 10),
                  Text('تم النسخ بنجاح'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('تم نسخ الصورة إلى:'),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: SelectableText(
                      destPath,
                      style: TextStyle(fontFamily: 'Monospace', fontSize: 12),
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('حسناً'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _openDestinationFolder();
                  },
                  child: Text('فتح المجلد'),
                ),
              ],
            ),
          );
        }
      } else {
        throw Exception('الملف المنسوخ غير موجود');
      }
    } catch (e) {
      print('خطأ مفصل في النسخ: $e');
      print('نوع الخطأ: ${e.runtimeType}');

      if (e is FileSystemException) {
        print('مسار المصدر: ${_selectedImage?.path}');
        print('مسار الهدف: $_destinationPath');
      }

      _showToast('خطأ في النسخ: ${e.toString()}');

      // عرض تفاصيل الخطأ
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 10),
                Text('خطأ في النسخ'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('حدث خطأ:'),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red),
                    ),
                    child: SelectableText(
                      e.toString(),
                      style: TextStyle(
                        fontFamily: 'Monospace',
                        fontSize: 12,
                        color: Colors.red[800],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('نصائح:'),
                  SizedBox(height: 5),
                  Text('• تحقق من صلاحيات المجلد'),
                  Text('• تأكد من وجود مساحة كافية'),
                  Text('• جرب مساراً مختلفاً'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('حسناً'),
              ),
            ],
          ),
        );
      }
    } finally {
      setState(() {
        _isCopying = false;
      });
    }
  }

  Future<void> _copyImageManually() async {
    await _copyImage();
  }

  Future<void> _openDestinationFolder() async {
    try {
      // محاولة فتح المجلد باستخدام أمر النظام
      final directory = Directory(_destinationPath);

      if (await directory.exists()) {
        String command;

        if (Platform.isLinux) {
          command = 'xdg-open "$_destinationPath"';
        } else if (Platform.isMacOS) {
          command = 'open "$_destinationPath"';
        } else if (Platform.isWindows) {
          command = 'explorer "$_destinationPath"';
        } else {
          _showToast('لا يمكن فتح المجلد على هذه المنصة');
          return;
        }

        final result = await Process.run('bash', ['-c', command]);

        if (result.exitCode != 0) {
          print('خطأ في فتح المجلد: ${result.stderr}');
          _showToast('تعذر فتح المجلد، افتحه يدوياً');
        }
      } else {
        _showToast('المجلد غير موجود: $_destinationPath');
      }
    } catch (e) {
      print('خطأ في فتح المجلد: $e');
      _showToast('تعذر فتح المجلد: $e');
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }
}

bool get kIsWeb {
  return identical(0, 0.0);
}
